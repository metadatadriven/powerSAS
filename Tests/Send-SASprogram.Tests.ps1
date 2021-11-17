<#
.SYNOPSIS
    Send-SASprogram test cases
.DESCRIPTION
    This script contains Pester 5.3 test cases for the powerSAS modules.
    There is one Test 'Description' per exported function, and each
    test description contains a number of contexts which contain the 
    individual test case assertions.

.EXAMPLE
    PS C:\> Invoke-Pester

    Run all the tests and produce summary
.EXAMPLE
    PS C:\> Invoke-Pester -Output Detailed

    To run all tests and get detail on each test run.    
#>


#
# Pre-requisite is to load the powerSAS module to be tested
#
BeforeAll {
    $parent = Join-Path -Path $PSScriptRoot -ChildPath .. -resolve
    Import-Module $parent -Force
}


###############################################################
## Send-SASprogram
###############################################################

Describe "Send-SASprogram" {
    Context "missing program" {
        BeforeEach {
            {Connect-SAS -local} | should -not -throw
        }
        It "doesnt exist" {
            # non-existant file
            $prog = "TestDrive:\xxx"
            # make sure it doesnt exists!!
            if (Test-Path -Path $prog -PathType Leaf) {Remove-Item $prog -force}
            {Send-SASProgram $prog} | should -throw "Cannot find SAS Program:*"
        }
        It "missing sas extension" {
            # non-existant file
            $prog = "TestDrive:\xxx"
            # create valid vile with .sas extension
            Set-Content "$prog.sas" -value '%put File Does Exists'
            # send program without extension
            {Send-SASProgram $prog} | should -throw "Cannot find SAS Program:*"
        }
        It "no filename parameter" {
            # call without filename
            {Send-SASProgram} | should -throw "Cannot Send-SASProgram. Filename is null"
        }
        AfterEach {
            {Disconnect-SAS} | should -not -throw
        }
    }
    Context "autoexec" {
        BeforeAll {
            $testPath = "TestDrive:\autoexec.sas"
            Set-Content $testPath -value @"
data _null_;
   put "autoexec confirmed";
run;
libname foo (sashelp);
"@
        }
        BeforeEach {
            {Connect-SAS -local} | should -not -throw
        }
        It "Only autoexec, no program" {
            {Send-SASProgram -auto $testPath} | should -throw "Cannot Send-SASProgram. Filename is null"
        }
        It "autoexec and program" {
            # create a program that relies on the FOO libname created in the autoexec
            Set-Content "TestDrive:\prog.sas" -value @"
proc datasets library=foo; quit;
proc print data=foo.cars; run;
"@
            # run the temp sas program..
            {Send-SASProgram -auto $testPath -File "TestDrive:\prog.sas"} | should -not -throw
            # ..and check that the log and lst files have been created
            "TestDrive:\prog.log" | should -Exist
            "TestDrive:\prog.lst" | should -Exist
            # The output file will contain the word Volvo only if the PROC PRINT ran ok
            "TestDrive:\prog.lst" | should -FileContentMatch "Volvo"
            # There should be at least one NOTE - this means that some SAS was actully run
            "TestDrive:\prog.log" | should -FileContentMatch "NOTE:"
            # there should not be any ERROR in the SAS Log
            "TestDrive:\prog.log" | should -Not -FileContentMatch "ERROR:"
        }
        AfterEach {
            {Disconnect-SAS} | should -not -throw 
        }
    }
    Context "Long program" {
        # create a long programconsisting of 100000 data steps that take the first datastep 
        # and 'pass it forward. The test will be to make sure the log and lst files have the
        # correct values in them.
        it "runs as expected" {
            # set this var to control how long the program is
            #$maxstep = 10000 
            $maxstep = 100 
            Set-Content "TestDrive:\long.sas" -value "data test1; x=11; run; "
            for($i=2; $i -le $maxstep; $i++) {
                add-content -path "TestDrive:\long.sas" -Value "data test$i ; set test$($i-1); x+1; run; "
            }
            # finally add a proc print for the last datastep
            add-content -path "TestDrive:\long.sas" -Value "proc print data=test$maxstep; run; "
            { connect-SAS -Local } | should -not -throw
            { Send-SASProgram "TestDrive:\long.sas" } | should -not -throw
            "TestDrive:\long.log" | should -not -FileContentMatch "The SAS System stopped processing this step because of errors"
            "TestDrive:\long.log" | should  -FileContentMatch "NOTE: There were 1 observations read from the data set WORK.TEST*"
            "TestDrive:\long.lst" | should  -FileContentMatch "$($maxstep+10)"
            { Disconnect-SAS } | should -not -throw
        }
    }
    Context "results" {
        BeforeEach {
            {Connect-SAS -local} | should -not -throw
        }
        It "error count" {
            # create a program that will generate 3 errors
            $prog = "TestDrive:\errgen.sas"
            # create prog that writes error, warnings and notes into the log
            Set-Content $prog -value @"
%put %str(ER)ROR: generated error 1;
%put %str(ER)ROR: generated error 2;
%put %str(ER)ROR: generated error 3;
%put %str(WAR)NING: generated warning 1;
%put %str(WAR)NING: generated warning 2;
%put %str(NO)TE: generated note 1;
"@
            # send program without extension
            $results = Send-SASProgram $prog
            # check we get the number of expected results
            $results.error | should -be 3
            $results.warning | should -be 2
            $results.note | should -be 1
        }
        AfterEach {
            {Disconnect-SAS} | should -not -throw
        }
    }
}



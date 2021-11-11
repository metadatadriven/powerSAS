<#
.SYNOPSIS
    powerSAS test cases
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
    Import-Module $PSScriptRoot\powerSAS -Force
}

<#
Connect-SAS
  + Local
    - connection established
    - only one connection
  + Remote
    - connection established
    - only one connection
Send-SASprogram
  + missing program
  + autoexec only
  + autoexec and prog
  + valid program
  + log errors
  + log warnings
  + log notes
  + long program
  + output
  + large output
Write-SAS
  + write one proc
  + write multiple proc
  + write sliced proc
Disconnect-SAS
  + does disconnect
  + new session empty
  + stress test
Search-SASLog              <-------------- TODO starting here
  + empty log
  + non-existant logfile
  + error count
  + warning count
  + note count
  + change log options
Invoke-iSAS
  + ??
#>

###############################################################
## Connect-SAS
###############################################################

Describe "Connect-SAS" {
    Context "Local" {
        BeforeEach {
            $response = (Connect-SAS -Local)
        }
        It "Connection established" {
            $response | Should -Not -BeNullOrEmpty
            $response | Should -match "NOTE: SAS Initialization"  
        }
        It "Single connection (Local)" {
            { Connect-SAS } | should -throw
        }
        It "Single connection (Remote)" {
            { Connect-SAS -Local } | should -throw
        }
        AfterEach {
            Disconnect-SAS
        }
    }
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


###############################################################
## Write-SAS
###############################################################

Describe "Write-SAS" {
    <#
  - listorlog  : output LST results if there are any, if not output the LOG
  - logandlist : output both, first the LOG then the LST are output
  - log        : only the log is output
  - list       : only the LST is output  
#>
    Context "One liner" {
        <#
        # Test write-sas in the context of a single line of sas code that
        # can be executed 'in one submit'. The different -method parameters
        # are tested to ensure that only the log or list (or both) is returned.
        #>
        BeforeEach {
            {Connect-SAS -local} | should -not -throw
            # define a SAS one liner that generates LST and LOG output
            $oneliner = "proc contents data=sashelp.shoes varnum; run;"
        }
        It "default method" {
            # single line that will generate LST and LOG output
            $result = ($oneliner | write-SAS)
            # check that we actually get some results
            $result | should -not -BeNullOrEmpty
            # default should be listorlog so check that we get LIST output
            $result -match "Number of Stores" | should -be $true
            # and check that there is no LOG output (because there was LIST)
            $result -match "NOTE: PROCEDURE CONTENTS used" | should -be $false
        }
        It "specified method (listorlog)" {
            # single line that will generate LST and LOG output
            $result = ($oneliner | write-SAS -method listorlog)
            # check that we actually get some results
            $result | should -not -BeNullOrEmpty
            # default should be listorlog so check that we get LIST output
            $result -match "Number of Stores" | should -be $true
            # and check that there is no LOG output (because there was LIST)
            $result -match "NOTE: PROCEDURE CONTENTS used" | should -be $false
            # now try again with only log output
            $result2 = ("%put %str(lo)gok;" | write-SAS -method listorlog)
            $result2 -match "logok" | should -be $true
        }
        It "specified method (logandlist)" {
            # single line that will generate LST and LOG output
            $result = ($oneliner | write-SAS -method logandlist)
            # check that we actually get some results
            $result | should -not -BeNullOrEmpty
            # default should be listorlog so check that we get LIST output
            $result -match "Number of Stores" | should -be $true
            # and check that there is  LOG output too
            $result -match "NOTE: PROCEDURE CONTENTS used" | should -be $true
        }
        It "specified method (log)" {
            # single line that will generate LST and LOG output
            $result = ($oneliner | write-SAS -method log)
            $result | should -not -BeNullOrEmpty
            # check there is no list output
            $result -match "Number of Stores" | should -be $false
            # and check that there is LOG output 
            $result -match "NOTE: PROCEDURE CONTENTS used" | should -be $true
        }
        It "specified method (list)" {
            # single line that will generate LST and LOG output
            $result = ($oneliner | write-SAS -method list)
            $result | should -not -BeNullOrEmpty
            # check that we get LIST output
            $result -match "Number of Stores" | should -be $true
            # and check that there is no LOG output
            $result -match "NOTE: PROCEDURE CONTENTS used" | should -be $false
        }
        It "specified method (none)" {
            # single line that will generate LST and LOG output
            { $oneliner | write-SAS -method } | should -throw "Missing an argument*"
        }
        It "specified method (invalid)" {
            # single line that will generate LST and LOG output
            { $oneliner | write-SAS -method loglist } | should -throw "Unknown method*"
        }
        AfterEach {
            {Disconnect-SAS} | should -not -throw
        }
    } # end context one liner

    Context "Multi-Liner" {
        <#
        #  These tests are in the context of multiple calls to write-SAS that
        # add up to a completed program. The calls are to 1) setup a libname
        # 2) use the libname, and 3) create some output from data in 2
        #>
        BeforeEach {
            {Connect-SAS -local} | should -not -throw
        }
        It "Runs as expected" -ForEach @(
            @{ method = "listorlog";  expectlist = $true;  expectlog = $false; }
            @{ method = "logandlist"; expectlist = $true;  expectlog = $true;  }
            @{ method = "log";        expectlist = $false; expectlog = $true;  }
            @{ method = "list";       expectlist = $true;  expectlog = $false; }
        ){
            # empty the results var that will be used to accumulate all results
            $result = ""
            # write individual sas fragments to SAS split over multiple write-SAS
            foreach ($prog in @(
                "libname foo(sashelp);"
                "data "
                " test;"
                "set foo.shoes;"
                "run;"
                "proc contents data=test varnum;"
                "run;"
            )) {
                # accumulate all the results
                $result += ($prog | write-SAS -method $method)
            }
            # check that there are no errors
            $result -match "ERROR" | should -be $false
            # check list output is as expected
            $result -match "Number of Stores" | should -be $expectlist
            # check log output is as expected
            $result -match "NOTE: PROCEDURE CONTENTS used" | should -be $expectlog
        }
        AfterEach {
            {Disconnect-SAS} | should -not -throw
        }
    }
}

###############################################################
## Disconnect-SAS
###############################################################

<#
Disconnect-SAS
  + does disconnect
  + new session empty
  + stress test
#>

Describe "Disconnect-SAS" {
    Context "Simple Connect-Disconnect" {
        It "Local connection" {
            {Connect-SAS -local} | should -not -throw
            {Disconnect-SAS} | should -not -throw
        }
        It "No connection" {
            # disconnect when there is no connection established
            {Disconnect-SAS} | should -throw "Cannot disconnect - No SAS session"
        }
        It "Double disconnect" {
            {Connect-SAS -local} | should -not -throw
            {Disconnect-SAS} | should -not -throw
            {Disconnect-SAS} | should -throw "Cannot disconnect - No SAS session"
        }
        It "Stress test" {
            <#
            # Connect-disconnect repeatedly
            #>
            $max = 10  # <----- SET TO THE NUMBER OF TIMES TO REPEAT
            for($i=0; $i -lt $max; $i++) {
                {Connect-SAS -local} | should -not -throw
                {Disconnect-SAS} | should -not -throw    
            }
            # check no connection
            {Disconnect-SAS} | should -throw "Cannot disconnect - No SAS session"
        }
    }
}


###############################################################
## Search-SASLog
###############################################################
<#
Search-SASLog              <-------------- TODO starting here
  + empty log
  + non-existant logfile
  + error count
  + warning count
  + note count
  + change log options
#>

Describe "Search-SASLog" {
    Context "Empty Log File" {
        It "Null file" {
            # create a log file that is zero bytes long
            $logfile = "TestDrive:\empty0.log"
            $null | out-file $logfile
            { Search-SASLog $logfile } | should -not -throw
            Search-SASLog $logfile | should -BeNullOrEmpty
        }
        It "Empty file" {
            # create a log file that is empty
            $logfile = "TestDrive:\empty2.log"
            out-file $logfile # this will be 2 bytes long (BOM header)
            { Search-SASLog $logfile } | should -not -throw
            Search-SASLog $logfile | should -BeNullOrEmpty
        }
    }
    Context "No logfile" {
        It "Doesnt exist" {
            { Search-SASLog "TestDrive:\doesntexist.log" } | should -throw "Cannot file log file*"
        }
        It "isnt a filename" {
            # create a valid log file but pass it as object not filename to Search-SASLog
            { Search-SASLog $(Get-Date)) } | should -throw 
        }
    }
    <#
    Check that the log search can handle range of character encoding
    #>
    Context "Count Correct" -ForEach @(
        @{ encoding = 'string' }
        @{ encoding = 'unicode' }
        @{ encoding = 'bigendianunicode' }
        @{ encoding = 'utf8' }
        @{ encoding = 'utf7' }
        @{ encoding = 'utf32' }
        @{ encoding = 'ascii' }
    ){
        it "Search $encoding logfile" {
            # create a valid log file but pass it as object not filename to Search-SASLog
            $logfile = "TestDrive:\err_$encoding.log"
            @"
ERROR: error 1
this is an intermediate line
WARNING: warning 1
NOTE: note 1
    this is an intermediate line
WARNING: warning 2
NOTE: note 2

NOTE: note 3
this is an intermediate line
"@ | Out-File -FilePath $logfile -Encoding $encoding
            $result = Search-SASLog $logfile
            $result | should -not -BeNullOrEmpty
            $result.length() | should -be 6 
        }
    }
}




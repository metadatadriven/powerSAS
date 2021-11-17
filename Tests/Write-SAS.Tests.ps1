<#
.SYNOPSIS
    Write-SAS test cases
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


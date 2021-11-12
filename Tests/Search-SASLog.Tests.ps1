<#
.SYNOPSIS
    Search-SASLog test cases
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
    Import-Module $PSScriptRoot\..\powerSAS -Force
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
            { Search-SASLog $(Get-Date) } | should -throw 
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
            $result.length | should -be 6 
        }
    }
}




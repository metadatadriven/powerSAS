<#
.SYNOPSIS
    Disconnect-SAS test cases
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



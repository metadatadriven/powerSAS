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

Send-SASprogram
Write-SAS
Disconnect-SAS
Invoke-iSAS
Search-SASLog
#>

Describe "Connect-SAS" {
    Context "Local" {
        BeforeEach {
            $response = (Connect-SAS -Local)
        }
        It "Connection established" {
            $response | Should -Not -BeNullOrEmpty
            $response | Should -match "NOTE: SAS Initialization"  
        }
        AfterEach {
            Disconnect-SAS
        }
    }
}
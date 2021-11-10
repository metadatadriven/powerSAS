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
Invoke-iSAS
  + ??
Search-SASLog
  + empty log
  + non-existant logfile
  + error count
  + warning count
  + note count
  + change log options
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
<#
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
#>

Describe "Send-SASprogram" {
    Context "missing program" -ForEach @( 
        @{ param = @{ local = $true } }   
         )
    {
        BeforeEach {
            {Connect-SAS @param} | should -not -throw
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
}
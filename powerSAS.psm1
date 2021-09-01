<#
.SYNOPSIS
Powershell script module for interacting with a remote SAS server

.DESCRIPTION
This module provides Powershell functions for connecting to SAS server,
sending commands that are executed by the server, receiving SAS Log files
and List ouptut, and disconnecting from the SAS server. 

.NOTES
Functions provided by this module: 
- Connect-SAS     Open a connection to SAS server. Remain connected until 'Disconnect-SAS' 
- Send-SAS        
#>


#########################################################################################

# variable to keep track of the SAS session within the module
# this is Script scope which means that it is 'private' to this 
# module and cannot be accessed directly from outside.

$script:objSAS = $null        # connection to SAS server object

#########################################################################################


function Connect-SAS {
<#
.SYNOPSIS
Establish a connection to the SAS server and return a SAS Workspace object.

.DESCRIPTION
Return a SAS IOM workspace session object using the server name and
credentials that are supplied as parameters. Credentials will be
prompted for if they are not supplied in full.
When finished with the Workspace object, disconnect by calling the 
Close method (on the returned object)

.INPUTS

None. You cannot pipe objects to Connect-SAS

.OUTPUTS

Workspace object - See SAS IOM documentation:

https://support.sas.com/rnd/itech/doc9/dev_guide/dist-obj/comdoc/autoca.html

.EXAMPLE 

Connect to SAS Academics EU server using Alice username (interactive password prompt)

PS> $sas = Connect-SAS -Credential alice
Password for user alice: ******

<do stuff>

PS> $sas.Close


.EXAMPLE 

Connect to corporate SAS server, prompt user for all credentials

PS> $sas = Connect-SAS -server sas.company.com -credential (Get-Credentials)
PowerShell credential request
Enter your credentials.
User: bob
Password for user stuart: ****

<do stuff>

PS> $sas.Close

.EXAMPLE

Connect to corporate SAS server using credentials supplied in variable

PS> $password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
PS> $Cred = New-Object System.Management.Automation.PSCredential ("carol", $password)
PS> $sas = Connect-SAS -server sas.company.com -credential $Cred

<do stuff>

PS> $sas.Close

.NOTES

For details on managing credentials in PowerShell see the following article:
https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/add-credentials-to-powershell-functions?view=powershell-7.1

#>

param (
  # (optional) name of the SAS server as text string e.g. sas9.server.com
  # Default value is EU SAS for Academics server odaws01-euw1.oda.sas.com
  [String]$server = "odaws01-euw1.oda.sas.com", 

  # (optional) a PSCredential object containing credentials for remote server
  # Can be full PSCredential object (username and password) or only username as
  # a string, in which case the password is prompted interactively.
  # If not supplied then username and password are prompted interactively.
  [ValidateNotNull()]
  [System.Management.Automation.PSCredential]
  [System.Management.Automation.Credential()]$credential = [System.Management.Automation.PSCredential]::Empty)
 
# check if any form of credential passed in, if not prompt interactively
if($credential -eq [System.Management.Automation.PSCredential]::Empty) {
  $credential = Get-Credential
}

# convert secure password to text string so that it can be passed to SAS Server
$BSTR     = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

#
# Use SAS Object Manager to create a ServerDef object that you use to connect to a 
# SAS Workspace. This time we'll use the Workspace server port (by default, 8591) 
# and the ClassIdentifier value for a SAS Workspace object. 
# NOTE that PROC IOMOPERATE will return this value.
#
$objFactory = New-Object -ComObject SASObjectManager.ObjectFactoryMulti2
$objServerDef = New-Object -ComObject SASObjectManager.ServerDef 
$objServerDef.MachineDNSName = $server
$objServerDef.Port           = 8591  # workspace server port
$objServerDef.Protocol       = 2     # 2 = IOM protocol
$objServerDef.ClassIdentifier = "440196d4-90f0-11d0-9f41-00a024bb830c"

#
# With an instance of an ObjectFactory class and the ServerDef class, we can now 
# establish a connection to the server, which is returned to the caller
#
Return $objFactory.CreateObjectByServer(
                "SASApp",      # server name
                $true, 
                $objServerDef, # used server definition for Workspace
                $credential.UserName,     # user ID
                $password      # password
                )

} #function sas-connect


#########################################################################################



function Send-SASprogram {
  <#
  .SYNOPSIS 
  Send a sasfile to SAS server

  .DESCRIPTION
  Sends a SAS program file to a SAS server. This uses a SAS workspace object created using
  the Connect-SAS function. The SAS Log and List files that are returned from the SAS server
  are written to files with the same path/name as the program file, except with .log and .lst
  extensions.
  #>

  param(
    # (mandatory) sasfile is the path and filename (inclusing extension) of the SAS program to run 
    [ValidateNotNull()]
    [string]$sasfile,
    # (mandatory) SAS Workspace object. i.e. object returned by SAS-Connect function.
    [ValidateNotNull()]
    [System.Object]$session
  )

  # make sure the SAS program file exists. If not, error and stop!
  if (!(Test-Path -path $sasfile)) {
    write-error -message "SAS Program does not exist" -ErrorAction Stop
  }

  # create the output file name - log and lst file
  $logfilename = (get-item $sasfile).DirectoryName+"/"+(get-item $sasfile).BaseName+".log"
  $lstfilename = (get-item $sasfile).DirectoryName+"/"+(get-item $sasfile).BaseName+".lst"

  # create new output files - this will delete files if they already exist
  # this is done before the program is sent to the SAS server to make sure that
  # the log/lst files can be written to before we execute the SAS program
  New-Item $logfilename -ItemType file -Force
  New-Item $lstfilename -ItemType file -Force

  # write the sas program file one line at a time to SAS server
  Get-Content -Path $sasfile | ForEach-Object {
    $session.LanguageService.Submit($_)
  }

  # flush the SAS log file
  $log = ""
  do {
    $log = $session.LanguageService.FlushLog(1000)
    Add-Content $logfilename -Value $log
  } while ($log.Length -gt 0)

  # flush the output  
  $list = ""
  do {
   $list = $session.LanguageService.FlushList(1000)
   Add-Content $lstfilename -Value $list
  } while ($list.Length -gt 0)

}


# Define the things that this Script Module exports:
#########################################################################################

Export-ModuleMember -Function Connect-SAS, Send-SASprogram

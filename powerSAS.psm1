<#
.SYNOPSIS
Powershell script module for interacting with a remote SAS server

.DESCRIPTION
This module provides Powershell functions for connecting to SAS server,
sending commands that are executed by the server, receiving SAS Log files
and List ouptu, and disconnecting from the SAS server. 

.NOTES
Functions provided by this module: 
- Connect-SAS     Open a connection to SAS server. Remain connected until 'Disconnect-SAS' 
- Disconnect-SAS  Close and disconnect from the SAS server
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
Establish a connection to the SAS server and start a session.

.DESCRIPTION
Return a SAS IOM workspace session object using the server name and
credentials that are supplied as parameters. Credentials will be
prompted for if they are not supplied in full.

.INPUTS

None. You cannot pipe objects to Connect-SAS

.OUTPUTS

Workspace object - See SAS IOM documentation:

https://support.sas.com/rnd/itech/doc9/dev_guide/dist-obj/comdoc/autoca.html

.EXAMPLE 

Connect to SAS Academics EU server using Alice username (interactive password prompt)

PS> Connect-SAS -Credential alice
Password for user alice: ******

.EXAMPLE 

Connect to corporate SAS server, prompt user for all credentials

PS> Connect-SAS -server sas.company.com -credential (Get-Credentials)
PowerShell credential request
Enter your credentials.
User: bob
Password for user stuart: ****

.EXAMPLE

Connect to corporate SAS server using credentials supplied in variable

PS> $password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
PS> $Cred = New-Object System.Management.Automation.PSCredential ("carol", $password)
PS> Connect-SAS -server sas.company.com -credential $Cred

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
##
## REPL - use 'exit-repl' to end repl (but leave sas connection open)
##
#########################################################################################

function global:sas-repl()
{      
write-host
"
 ____    _    ____
/ ___|  / \  / ___|
\___ \ / _ \ \___ \
 ___) / ___ \ ___) |
|____/_/   \_\____/...
------------------------------------------------------------------------------
use 'repl-exit' to return to PowerShell
------------------------------------------------------------------------------
"          
do {
   # read input from user
   $program=read-host "SAS04"
   
#   if (-Not([string]::IsNullOrEmpty($program))) {
   if ($program -cne "repl-exit") {
    
     # run the program
     $global:objSAS.LanguageService.Submit($program);

     # flush the log - could redirect to external file
#     Write-Output "LOG:"
     $log = ""
     do
     {
       $log = $global:objSAS.LanguageService.FlushLog(1000)
       Write-Output $log
     } while ($log.Length -gt 0)

     # flush the output - could redirect to external file
#     Write-Output "Output:"
     $list = ""
     do
     {
      $list = $global:objSAS.LanguageService.FlushList(1000)
      Write-Output $list
     } while ($list.Length -gt 0)
   } #if 

} 
until($program -ceq "repl-exit" )

write-host
"
 ____                        ____  _          _ _
|  _ \ _____      _____ _ __/ ___|| |__   ___| | |
| |_) / _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |
|  __/ (_) \ V  V /  __/ |   ___) | | | |  __/ | |
|_|   \___/ \_/\_/ \___|_|  |____/|_| |_|\___|_|_|...
------------------------------------------------------------------------------
"
}

#########################################################################################
##
## sas-disconnect - close the remote SAS session
##
#########################################################################################

function  global:sas-disconnect()
{
   # end the SAS session
   $global:objSAS.Close()
   write-host "SAS connection closed."
} # function sas-disconnect


function global:sas-help()
{
write-host "
Interactive SAS from MS Powershell
 ____                        ____    _    ____       
|  _ \ _____      _____ _ __/ ___|  / \  / ___|      
| |_) / _ \ \ /\ / / _ \ '__\___ \ / _ \ \___ \      
|  __/ (_) \ V  V /  __/ |   ___) / ___ \ ___) |     
|_|   \___/ \_/\_/ \___|_|  |____/_/   \_\____/      
---------------+-------------------------------------------------------------------------
Command        | Description
---------------+-------------------------------------------------------------------------
sas-connect    | open connection to SAS server. Remain connected until 'sas-disconnect' 
sas-repl       | (re)start an interactive SAS session. Commands typed after this are SAS.
repl-exit      | Use from interactive SAS session (sas-repl) to return to Powershell
sas-disconnect | Close and disconnect the connection to the SAS server
sas-help       | Display this message.
---------------+-------------------------------------------------------------------------
$ Id : $

-----------------------------------------------------------------------------------------
Getting started:			
-----------------------------------------------------------------------------------------

1. Open a connection to the SAS server. This will promot you for username/password.
NOTE: that after connection is established, you will still be in POWERSHELL. 

PS > sas-connect			

2. From POWERSHELL (PS) prompt, start an interactive SAS session

PS > sas-repl			

3. Inside the REPL everything you type will be sent to SAS and the log and output displayed.

FS-SAS04: <type your PROC SAS here>

4. To return to the POWERSHELL, use the 'repl-exit' command 

FS-SAS04: repl-exit

5. Your SAS session will remain open until you disconnect from the SAS server using
the 'sas-disconnect' command.
You can restart a 'sas-repl' as many times as you like before 'sas-disconnect'
-----------------------------------------------------------------------------------------
"
}

# Functions exported by this module:

Export-ModuleMember -Function Connect-SAS

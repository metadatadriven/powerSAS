<#
.SYNOPSIS
Powershell script module for interacting with a remote SAS server

.DESCRIPTION
This module provides Powershell functions for connecting to SAS server,
sending commands that are executed by the server, receiving SAS Log files
and List ouptut, and disconnecting from the SAS server. 

.NOTES
Functions provided by this module: 
- Connect-SAS      Open a connection to SAS server and start a session (can be only one) 
- Send-SASprogram  Send SAS Programs .sas file current session and create log and lst files
- Disconnect-SAS   Disconnect from SAS Server and close session
#>


#########################################################################################

# variable to keep track of the SAS session within the module
# this is Script scope which means that it is 'private' to this 
# module and cannot be accessed directly from outside.

# Note that there can only be one sas session open at a time (per user space)

$script:session = $null        # connection to SAS server object



#########################################################################################
# Local functions (private to module)
#########################################################################################

function Read-SASLog {
  <#
  .SYNOPSIS
  Private module function to read the SAS log (return value)
  #>
  $log = ""
  $in = ""
  do {
    $in = $script:session.LanguageService.FlushLog(1000)
    if ($in.Length -gt 0) {$log += $in}
  } while ($in.Length -gt 0)
  Return $log
}


#########################################################################################

function Read-SASList {
  <#
  .SYNOPSIS
  Private function to read the SAS LST (return value)#>
  $list = ""
  $in = ""
  do {
   $in = $script:session.LanguageService.FlushList(1000)
   if ($in.length -gt 0) { $list += $in}
  } while ($in.Length -gt 0)
  Return $list
}




#########################################################################################
# Public functions (exported by the module manifest file)
#########################################################################################




function Connect-SAS {
<#
.SYNOPSIS
Establish a connection to the SAS server and start a session.

.DESCRIPTION
Return a SAS IOM workspace session object using the server name and
credentials that are supplied as parameters. Credentials will be
prompted for if they are not supplied in full.
When finished with the Workspace object, disconnect by calling the 
Disconnect-SAS function.

.INPUTS

None. You cannot pipe objects to Connect-SAS

.OUTPUTS

Workspace object - See SAS Integration Technologies documentation:

https://support.sas.com/rnd/itech/doc9/dev_guide/dist-obj/comdoc/autoca.html

.EXAMPLE 

Connect to SAs runing locally on developer workstation

PS> Connect-SAS -Local

<do stuff>

PS> Disconnect-SAS

.EXAMPLE 

Connect to SAS Academics EU server using Alice username (interactive password prompt)

PS> Connect-SAS -Credential alice
Password for user alice: ******

<do stuff>

PS> Disconnect-SAS


.EXAMPLE 

Connect to production SAS server, prompt user for all credentials

PS> Connect-SAS -server sasprod.company.com -credential (Get-Credentials)
PowerShell credential request
Enter your credentials.
User: bob
Password for user stuart: ****

<do stuff>

PS> Disconnect-SAS

.EXAMPLE

Connect to corporate SAS server using credentials supplied in variable

PS> $password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
PS> $Cred = New-Object System.Management.Automation.PSCredential ("carol", $password)
PS> Connect-SAS -server sas.company.com -credential $Cred

<do stuff>

PS> Disconnect-SAS

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
  [System.Management.Automation.Credential()]$credential = [System.Management.Automation.PSCredential]::Empty,

  # (optional) Connect to installation of SAS on local machine. No credentials required.
  [Parameter(mandatory=$False)]
  [Switch]$Local
) #param  

#
# Before we do anything, check that there is not already a live connection.
# if there is then stop here!.. user will need to Disconnect-SAS first.
#
if ($null -ne $script:session) {
  Write-Error -Message "Cannot connect. SAS session already exists. Disconnect-SAS to proceed." -ErrorAction Stop
}

#
# Use SAS Object Manager to create a ServerDef object that you use to connect to a 
# SAS Workspace. These are created first, then the ServerDef is configured below
#
$objFactory = New-Object -ComObject SASObjectManager.ObjectFactoryMulti2
$objServerDef = New-Object -ComObject SASObjectManager.ServerDef 

  # Configure the ServerDef object before making a connection
  # if we are connecting locally then setup the lite config
  if ($Local -eq $True) {
    #
    # this is a local connection, so dont need servername, credentials, etc. for COM protocol 
    #
    $username        = ""
    $password        = ""
    $objServerDef.MachineDNSName  = "127.0.0.1" # localhost
    $objServerDef.Port            = 0           # port not used
    $objServerDef.Protocol        = 0           # 0 = COM protocol
    # Important not to populate the ClassIdentifier otherwise the CreateObjectByServer
    # method will try to config a remote server not a local one
  }
  else {
    #
    # this is a remote connection, so will need servername, credentials, etc. for IOM protocol 
    #

    # check if any form of credential passed in, if not prompt interactively
    if($credential -eq [System.Management.Automation.PSCredential]::Empty) {
      $credential = Get-Credential
    }
    # extract the username - this is done to make it compatible with local config
    $username = $credential.UserName

    # convert secure password to text string so that it can be passed to SAS Server
    # this is a bit of a code smell, would be nice to find a cleaner way to type cast!
    $BSTR     = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password)
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

    # define the remote port/protocol/etc
    $objServerDef.MachineDNSName  = $server
    $objServerDef.Port            = 8591     # workspace port
    $objServerDef.Protocol        = 2        # 2 = IOM protocol
    $objServerDef.ClassIdentifier = "440196d4-90f0-11d0-9f41-00a024bb830c"
  }

#
# With an instance of an ObjectFactory class and the ServerDef class, we can now 
# establish a connection to the server, which is returned to the caller
#
$script:session = $objFactory.CreateObjectByServer(
                  "SASApp",               # server name
                  $true,                  # Wait for connection before returning
                  $objServerDef,          # server definition for Workspace
                  $UserName,              # user ID
                  $password               # password
                  )

# once connected, flush the log buffer - this will get all the welcome messages, etc
Read-SASLog | write-output


} #function sas-connect




#########################################################################################

function Write-SAS {
  <#
  .SYNOPSIS
  Write SAS code to server and return response object. Supports pipeline input

  .DESCRIPTION
  Send SAS code to the SAS Server (using the session established with Connect-SAS)
  The (sas LOG and LST) responses are returned as a sas hash table object 
  This function supports pipeline input and output.

  NOTE that a SAS connection must be established using Connect-SAS first

.INPUTS

Text string containing SAS commands to send to the SAS connection

.OUTPUTS

Text string containing the SAS list and/or log

.EXAMPLE

PS> "data _null_; put 'hello world'; run;" | Write-SAS
hello world
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

This will send the hello world program to the sas connection and return the
output using the default 'listorlog' method

.EXAMPLE

PS> @"
>> proc print
>>   data = sashelp.shoes;
>> run;
>> "@ | Write-SAS -method log
NOTE: There were 395 observations read from the data set SASHELP.SHOES.
NOTE: The PROCEDURE PRINT printed pages 25-32.
NOTE: PROCEDURE PRINT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

This demonstrates how to send a multi-line text string to SAS and return only the log
(i.e. the output from the proc print is not returned, only the SAS log output)

.EXAMPLE
PS> @"
>> proc print
>>   data=sashelp.shoes(obs=5);
>> run;
>> "@ | Write-SAS -method list
                                            The SAS System                        
Obs    Region    Product         Subsidiary     Stores           Sales       Inventory         Returns
  1    Africa    Boot            Addis Ababa      12           $29,761        $191,821            $769
  2    Africa    Men's Casual    Addis Ababa       4           $67,242        $118,036          $2,284
  3    Africa    Men's Dress     Addis Ababa       7           $76,793        $136,273          $2,433
  4    Africa    Sandal          Addis Ababa      10           $62,819        $204,284          $1,861
  5    Africa    Slipper         Addis Ababa      14           $68,641        $279,795          $1,771

This demonstrates using the LIST method which will only return the output and no log.

.PARAMETER method
  (optional) defines the method used to create the output. Default is listorlog
  - listorlog  : output LST results if there are any, if not output the LOG
  - logandlist : output both, first the LOG then the LST are output
  - log        : only the log is output
  - list       : only the LST is output  
  #>
  param(
    [String]$method = "listorlog"
  )
  begin {
      # make sure the SAS session exists. If not, error and stop!
    if ($script:session -eq $null) {
      Write-Error -Message "No SAS session. Use Connect-SAS to start session." -ErrorAction Stop
    }
  }
  process {
    Write-Debug "Processing: $_"
    # submit the sas code
    $script:session.LanguageService.Submit($_)

    # read the log and lst responses from SAS server
    $log = Read-SASLog
    $list = Read-SASList

    # write ourput depending on the METHOD parameter
    switch ($method) 
    {
      listorlog
      {
        if ($list.length -gt 0) {
          Write-Output $list
        }
        else {
          if ($log.length -gt 0) { Write-Output $log }
        }
      }
      logandlist
      {
        if ($log.length -ne 0) {Write-Output $log}
        if ($list.length -ne 0) {Write-Output $list}
      }
      log
      {
        if ($log.length -ne 0) {Write-Output $log}
      }
      list
      {
        if ($list.length -ne 0) {Write-Output $list}
      }
      default {
        throw "Unknown method. Must be one of: listorlog, logandlist, log, list"
      }
    }
  }
}


#########################################################################################

function Send-SASprogram {
  <#
  .SYNOPSIS 
  Send a sas program file to SAS server write response to LOG and LST files 

  .DESCRIPTION
  Sends a SAS program file to a SAS server. This uses a SAS workspace object created using
  the Connect-SAS function. The SAS Log and List files that are returned from the SAS server
  are written to files with the same path/name as the program file, except with .log and .lst
  extensions.

.EXAMPLE

PS> Set-Content "program.sas" -value @"
* SAS program to print the first 5 record of the Cars dataset; 
proc print data=sashelp.cars (obs=5); 
run;
"@
# Powershell command to send the SAS program file to the SAS server
PS> Send-SASProgram program.sas
Name                           Value
----                           -----
error                          0
warning                        0
note                           3

This example shows how a SAS program file is sent to the SAS Server and the summary
of results that are returned.
By default the Send-SASProgram will write the sas log to <program>.log and the output
to <program>.lst - these filenames can be set using -OutFilename and -LogFilename
parameters.
  #>

  param(
    # (mandatory) File is the path and filename (inclusing extension) of the SAS program to run 
    [Parameter(Position=0)]
    [ValidateNotNull()]
    [string]$file,
    # (optional) name of file that output is written to. If file exists then it will be over-written
    [Parameter(Mandatory=$false)]
    [string]$outfilename="",
    # (optional) name of file that log is written to. If file exists then it will be over-written
    [Parameter(Mandatory=$false)]
    [string]$logfilename="",
    # (optional) name of a sas program (e.g. autoexec.sas) this is run before main sas file
    [Parameter(Mandatory=$false)]
    [string]$auto=""
  )

  # wrap the entire function except the summary stats at the end in a null codeblock
  # to avoid returning anything else from the function than the summary.
  
  $null = .{
  # make sure the SAS session exists. If not, error and stop!
  if ($null -eq $script:session) {
    throw "No SAS session. Use Connect-SAS to start session."
  }

  # make sure the SAS program is populated. If not, error and stop!
  if (($null -eq $file) -or ($file.length -eq 0) ) {
    throw "Cannot Send-SASProgram. Filename is null"
  }

  # make sure the SAS program file exists. If not, error and stop!
  if (!(Test-Path -path $file)) {
    throw "Cannot find SAS Program: $file"
  }

  # make sure the AUTO program file exists (if it was passed as param)
  if ($auto -ne "") {
  }
  if (($auto -ne "") -and !(Test-Path -path $auto)) {
    throw "Auto Program does not exist."
  }


  # if log and/or out files not specified as a parameter then
  # populate a default value based on SAS program filename
  if ($logfilename -eq "") {
    $logfilename = (get-item $file).DirectoryName+"/"+(get-item $file).BaseName+".log"
  }
  if ($outfilename -eq "") {
    $outfilename = (get-item $file).DirectoryName+"/"+(get-item $file).BaseName+".lst"
  }
  # create new output files - this will delete files if they already exist
  # this is done before the program is sent to the SAS server to make sure that
  # the log/lst files can be written to before we execute the SAS program
  New-Item $logfilename -ItemType file -Force
  New-Item $outfilename -ItemType file -Force

  # Run the AUTO program first (if specified)
  if ($auto -ne "") {
    $auto = Get-Content -Path $auto -Raw | ForEach-Object {
      $script:session.LanguageService.Submit($_)
    }
  }
  # write the sas program file one line at a time to SAS server
  Get-Content -Path $file -Raw | ForEach-Object {
    $script:session.LanguageService.Submit($_)
  }

  # flush the SAS log file
  $log = ""
  do {
     $log = $script:session.LanguageService.FlushLog(1000)
     Add-Content $logfilename -Value $log -NoNewline
  } while ($log.Length -gt 0)

  # flush the output  
  $list = ""
  do {
   $list = $script:session.LanguageService.FlushList(1000)
   Add-Content $outfilename -Value $list -NoNewline
  } while ($list.Length -gt 0)

  # all done - final step is to return a summary of the sas logfile
  # for this a hashtable is returned with number of NOTE, WARNING and ERROR
  # that are in the log 

  # first, scan the NOTE, ERROR and WARNING from the log. do this first so 
  # that we dont have to grep large log files repeatedly (for summary counts)
  $scan = ((Get-Content $logfilename) `
          | Select-String -Pattern "^NOTE:", "^WARNING:", "^ERROR:")

  } # end of dot block
  # now return the summary totals as a hashtable
  @{
    note    = $($scan | Select-String -Pattern "^NOTE:").count
    warning = $($scan | Select-String -Pattern "^WARNING:").count
    error   = $($scan | Select-String -Pattern "^ERROR:").count
  }
}


#########################################################################################


function Invoke-iSAS {
  <#
  .SYNOPSIS
  Invoke interactive SAS read-eval-print loop. Use EXIT to return to Powershell

  .DESCRIPTION
  This command invokes interactive SAS, where user commands read from the console
  are sent to the curent SAS session (established using the SAS-Connect function).
  The SAS Log and List output are displayer on the console.
  This allows the user to interact with SAS similar to NODMS mode on Unix.
  To return to Powershell, enter the command EXIT (not case sensitive)

.EXAMPLE

PS> Invoke-iSAS
SAS: proc datasets library=work; quit;
16                                                         The SAS System
36         proc datasets library=work;
                                                             Directory

                  Libref             WORK
                  Engine             V9
                  Physical Name      C:\Users\STUART~1\AppData\Local\Temp\SAS Temporary Files\_TD16632_HP135_\Prc2
                  Filename           C:\Users\STUART~1\AppData\Local\Temp\SAS Temporary Files\_TD16632_HP135_\Prc2
                  Owner Name         AzureAD\StuartMalcolm
                  File Size          0KB
                  File Size (bytes)  0
                                              Member
                                     #  Name  Type       File Size  Last Modified
                                     1  FOO   DATA           128KB  12/11/2021 11:48:53
SAS: exit
NOTE: Return to Powershell. SAS Session remains open. Use Disconnect-SAS to end.
PS>

This example shows how to invoke the interactive SAS session using the Invoke-iSAS command
at the powershell promt (PS>).
The prompt then changes to SAS: to indicate this is an interactive SAS session where
commands that are entered are executed on the SAS server. In this case a PROC DATASETS is
run and the results displayed.
The iSAS session is exited using the 'exit' command at the SAS: prompt. This returns to 
powershell (with a NOTE that the SAS session remains connected).

#>
  param (
    # (optional) String used as SAS user prompt. Default SAS
    [String]$prompt = "SAS",
    #     (optional) defines the method used to create the output. Default is listorlog
    #   - listorlog  : output LST results if there are any, if not output the LOG
    #   - logandlist : output both, first the LOG then the LST are output
    #   - log        : only the log is output
    #   - list       : only the LST is output  
    [String]$method = "listorlog"
  )
  # Start the REPL. Use BREAK statements to exit loop.
  while($true) {
    # READ input from user
    $in = Read-Host $prompt 

    # check if user wants to exit loop
    if ($in.Trim() -eq "EXIT") {Break}

    # EVAL the input by sending it to the SAS Server
    # the Write-Method will output the List/Log using method param
    $in | Write-SAS -method $method

  } #while

  # post-REPL code here:
  write-output "NOTE: Return to Powershell. SAS Session remains open. Use Disconnect-SAS to end."
}



#########################################################################################


function Disconnect-SAS {
  <#
  .SYNOPSIS
  Disconnect the connection to the SAS Workspace and end the session.

  .DESCRIPTION
  End the SAS connection. This will cleanup WORK library, libnames, etc.

  .EXAMPLE

  PS> Connect-SAS
  PS> # interact with SAS using Write-SAS, Send-SASProgram, Invoke-iSAS, etc.
  PS> Disconnect-SAS

  This example shows how a SAS session is connected and disconnected. Disconnect-SAS
  will clean-up the WORK directory, libnames, etc.
  #>

  if ($null -eq $script:session) {
    Write-Error -Message "Cannot disconnect - No SAS session" -ErrorAction Stop
  }
  $script:session.Close()
  $script:session = $null
}




#########################################################################################
function Search-SASLog {
  <#
.SYNOPSIS 
  Search a SAS log file for ERROR, WARNING and NOTES

.DESCRIPTION
  This command searches a SAS Log file for ERROR, WARNING and NOTES and returns
  only those log lines in the same order they apprear in the log.

.EXAMPLE

PS> Search-SASLog .\program.log
NOTE: There were 428 observations read from the data set SASHELP.CARS.
NOTE: The data set WORK.CARS has 428 observations and 15 variables.
NOTE: DATA statement used (Total process time):
ERROR: File WORK.BAR.DATA does not exist.
NOTE: The SAS System stopped processing this step because of errors.
NOTE: Due to ERROR(s) above, SAS set option OBS=0, enabling syntax check mode.
WARNING: The data set WORK.FOO may be incomplete.  When this step was stopped there were 0 observations and 0 variables.
NOTE: DATA statement used (Total process time):
NOTE: PROCEDURE SORT used (Total process time):
WARNING: This is a user generated warning

This example shows how SearchLog returns only the ERROR, WARNING and NOTE log lines and preserves the order.
#>
  param(
    # name of log file (without extension). if not found will look in ..\saslogs
    [Parameter(Mandatory=$true, Position=0)]
    [String]$file
  )
    # try to find the sas log file unmodified
    $logfile = $null
    # check if the file existing as is (i.e. has path and extension)
    if (Test-Path -PATH ($file) -PathType Leaf) {
      $logfile=$file
    }
    # try adding a .log extension
    elseif (Test-Path -PATH ($file+".log") -PathType Leaf) {
      $logfile=$file+".log"
    }
    # look in a known place (this is vendor specific and should be a confog parameter)
    elseif (Test-Path -PATH ("..\saslogs\"+$file+".log")) {
        $logfile="..\saslogs\"+$file+".log"
    }
    # cannot find log file so give up!
    else {
        Write-Error "Cannot file log file" -ErrorAction Stop
    }

    # if we know where the logfile is then grep the errors, warnings and notes
    if ($logfile -ne $null) {
      (Get-Content $logfile) | Select-String -Pattern "(^ERROR:)|(^WARNING:)|(^NOTE:)"
    } 
  }
  
# EOF
[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/metadatadriven/powerSAS)
# powerSAS
Powershell - Windows Powershell client for SAS

```
  ____                        ____    _    ____       
 |  _ \ _____      _____ _ __/ ___|  / \  / ___|      
 | |_) / _ \ \ /\ / / _ \ '__\___ \ / _ \ \___ \      
 |  __/ (_) \ V  V /  __/ |   ___) / ___ \ ___) |     
 |_|   \___/ \_/\_/ \___|_|  |____/_/   \_\____/      
```

## Overview

PowerSAS provides functions and utilities that make it easy to interact with SAS from Powershell.

## Project status

This project is available at v1.0 for production use, and is available on the [PSGallery repository](https://www.powershellgallery.com/packages/powerSAS/1.0)

Version 1.0 was presented at the Phuse EU COnnect 2021 conference in November 2021 (presentation SD06)

## Prerequisites

One of the goals of powerSAS is to have the minimum set of dependencies as possible.
Currently powerSAS relies upon SAS IOM connection using COM objects, which means that
the current version is 'Windows only' - future versions will aim to remove this
dependency with the aim of supporting cross-platform 'pwsh'.

Prerequisites:
- [SAS Integration Technologies client for Windows](https://support.sas.com/rnd/itech/doc9/dev_guide/dist-obj/winclnt/winreq.html)
- Windows NT 4.0 or higher
- Powershell 5.0 or higher

## Key features

- Powershell module script supporting connection and interaction to remote SAS server
- A REPL (Read Evaluate Print Loop) SAS command line (like Unix NODMS)

## Installation from PSGallery

powerSAS can be installed from the [PSGallery](https://www.powershellgallery.com/packages/powerSAS/1.0). This is probably the easiest way to install:
```
Install-Module -Name powerSAS
```

## Installation from GitHub

If you want to install the head version, then clone this repo and use `Import-Module powerSAS.psm1`

- First step is to identify where to install the module

PowerShell uses the `$env:PSModulePath` to find modules, use the following to list your module path:
```
PS> $env:PSModulePath -split ';'
C:\Users\UserName\Documents\WindowsPowerShell\Modules
C:\Program Files\WindowsPowerShell\Modules
C:\Windows\system32\WindowsPowerShell\v1.0\Modules
```
Generally the first on the list is the used module path - select this one if you want to install
for the current user (or dont have admin rights).
If you want to install for all users, then you will need admin rights and should select the
second one on the list.

For this example, we will install for the current user:
```
# allow scripts to run in powershell
Set-Executionpolicy -ExecutionPolicy bypass -Scope CurrentUser

# change directory to where we want yo download the module into
cd C:\Users\UserName\Documents\WindowsPowerShell\Modules

# download using git clone (or download zip from github and unzip here) 
git clone https://github.com/metadatadriven/powerSAS.git
```

- Check that the module is available. You should see `powerSAS` listed as available:
```
PS> Get-Module -ListAvailable


    Directory: C:\Users\StuartMalcolm\Documents\WindowsPowerShell\Modules

ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
...
Script     0.0        powerSAS                            {Write-SAS, Send-SASprogram, Connect-SAS, Disconnect-SAS...}
...
```

## Getting Started

The basic powerSAS workflow is:
- You start a SAS session by connecting to SAS using `Connect-SAS` cmdlet (local or remote)
- PowerShell can then send individual SAS commands using `Write-SAS`, or..
- ..execture SAS program files using `Send-SASprogram`
- or you can interactively execute SAS commands using `Invoke-iSAS`
- SAS session is ended using `Disconnect-SAS`

See `Get-Help Connect-SAS` for help.

CmdLet documentation is also available online at https://github.com/metadatadriven/powerSAS/tree/main/docs

## Contributing

powerSAS is under on-going development and welcomes contributions. If you are using powerSAS and found
and issue or have a suggestion, then please feel free to raise them on github. 

## Licensing

Open Source software released under MIT License.


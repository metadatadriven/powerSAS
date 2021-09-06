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

This project is currently PRE-RELEASE and should not be used for production.

Release 1 is currently targeted for end Oct 2021 - and will be presented at the
Phuse EU COnnect 2021 conference in November 2021 (presentation SD06)

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

## Installation

Currently the easiest way to install is to clone this repo and use `Import-Module powerSAS.psm1`

To download and install for use for the current user:

```
# allow scripts to run in powershell
Set-Executionpolicy -ExecutionPolicy bypass -Scope CurrentUser

# clone the repo 
git clone https://github.com/metadatadriven/powerSAS.git

# connect the the powerSAS workspace and import the module
# for use by current user only
cd powerSAS
Import-Module .\powerSAS.psm1 -Scope CurrentUser
```

## Getting Started

See `Get-Help Connect-SAS` for examples.

## Contributing

powerSAS is currently under pre-release development, so subject to change. If you are using powerSAS and found
and issue or have a suggestion, then please feel free to raise them on github. 

## Licensing

Open Source software released under MIT License.

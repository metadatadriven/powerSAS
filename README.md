# powerSAS
Powershell client for interacting with a remote SAS server

```
  ____                        ____    _    ____       
 |  _ \ _____      _____ _ __/ ___|  / \  / ___|      
 | |_) / _ \ \ /\ / / _ \ '__\___ \ / _ \ \___ \      
 |  __/ (_) \ V  V /  __/ |   ___) / ___ \ ___) |     
 |_|   \___/ \_/\_/ \___|_|  |____/_/   \_\____/      
```

## Overview

Powershell meets SAS!.. powerSAS aims to make it easy to write Powershell clients
that interact with a (remote) SAS server. 

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

TODO

## Getting Started

TODO

## Contributing

TODO

## Licensing

Open Source software released under MIT License.

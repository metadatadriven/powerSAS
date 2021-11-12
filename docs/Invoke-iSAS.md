---
external help file: powerSAS-help.xml
Module Name: powerSAS
online version:
schema: 2.0.0
---

# Invoke-iSAS

## SYNOPSIS
Invoke interactive SAS read-eval-print loop.
Use EXIT to return to Powershell

## SYNTAX

```
Invoke-iSAS [[-prompt] <String>] [[-method] <String>]
```

## DESCRIPTION
This command invokes interactive SAS, where user commands read from the console
are sent to the curent SAS session (established using the SAS-Connect function).
The SAS Log and List output are displayer on the console.
This allows the user to interact with SAS similar to NODMS mode on Unix.
To return to Powershell, enter the command EXIT (not case sensitive)

## EXAMPLES

### EXAMPLE 1
```
Invoke-iSAS
```

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
NOTE: Return to Powershell.
SAS Session remains open.
Use Disconnect-SAS to end.
PS\>

This example shows how to invoke the interactive SAS session using the Invoke-iSAS command
at the powershell promt (PS\>).
The prompt then changes to SAS: to indicate this is an interactive SAS session where
commands that are entered are executed on the SAS server.
In this case a PROC DATASETS is
run and the results displayed.
The iSAS session is exited using the 'exit' command at the SAS: prompt.
This returns to 
powershell (with a NOTE that the SAS session remains connected).

## PARAMETERS

### -prompt
(optional) String used as SAS user prompt.
Default SAS

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: SAS
Accept pipeline input: False
Accept wildcard characters: False
```

### -method
(optional) defines the method used to create the output.
Default is listorlog
- listorlog  : output LST results if there are any, if not output the LOG
- logandlist : output both, first the LOG then the LST are output
- log        : only the log is output
- list       : only the LST is output

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Listorlog
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

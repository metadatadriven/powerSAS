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

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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

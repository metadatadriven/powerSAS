---
external help file: powerSAS-help.xml
Module Name: powerSAS
online version:
schema: 2.0.0
---

# Write-SAS

## SYNOPSIS
Write SAS code to server and return response object.
Supports pipelines

## SYNTAX

```
Write-SAS [[-method] <String>] [<CommonParameters>]
```

## DESCRIPTION
Send SAS code to the SAS Server (using the session established with Connect-SAS)
The (sas LOG and LST) responses are returned as a sas hash table object 
This function supports pipeline input and output.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

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
Position: 1
Default value: Listorlog
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

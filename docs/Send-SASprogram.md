---
external help file: powerSAS-help.xml
Module Name: powerSAS
online version:
schema: 2.0.0
---

# Send-SASprogram

## SYNOPSIS
Send a sas program file to SAS server write response to LOG and LST files

## SYNTAX

```
Send-SASprogram [[-file] <String>] [-outfilename <String>] [-logfilename <String>] [-auto <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends a SAS program file to a SAS server.
This uses a SAS workspace object created using
the Connect-SAS function.
The SAS Log and List files that are returned from the SAS server
are written to files with the same path/name as the program file, except with .log and .lst
extensions.

## EXAMPLES

### EXAMPLE 1
```
Set-Content "program.sas" -value @"
```

* SAS program to print the first 5 record of the Cars dataset; 
proc print data=sashelp.cars (obs=5); 
run;
"@
# Powershell command to send the SAS program file to the SAS server
PS\> Send-SASProgram program.sas
Name                           Value
----                           -----
error                          0
warning                        0
note                           3

This example shows how a SAS program file is sent to the SAS Server and the summary
of results that are returned.
By default the Send-SASProgram will write the sas log to \<program\>.log and the output
to \<program\>.lst - these filenames can be set using -OutFilename and -LogFilename
parameters.

## PARAMETERS

### -file
(mandatory) File is the path and filename (inclusing extension) of the SAS program to run

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -outfilename
(optional) name of file that output is written to.
If file exists then it will be over-written

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -logfilename
(optional) name of file that log is written to.
If file exists then it will be over-written

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -auto
(optional) name of a sas program (e.g.
autoexec.sas) this is run before main sas file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

---
external help file: powerSAS-help.xml
Module Name: powerSAS
online version:
schema: 2.0.0
---

# Search-SASLog

## SYNOPSIS
Search a SAS log file for ERROR, WARNING and NOTES

## SYNTAX

```
Search-SASLog [-file] <String> [<CommonParameters>]
```

## DESCRIPTION
This command searches a SAS Log file for ERROR, WARNING and NOTES and returns
only those log lines in the same order they apprear in the log.

## EXAMPLES

### EXAMPLE 1
```
Search-SASLog .\program.log
```

NOTE: There were 428 observations read from the data set SASHELP.CARS.
NOTE: The data set WORK.CARS has 428 observations and 15 variables.
NOTE: DATA statement used (Total process time):
ERROR: File WORK.BAR.DATA does not exist.
NOTE: The SAS System stopped processing this step because of errors.
NOTE: Due to ERROR(s) above, SAS set option OBS=0, enabling syntax check mode.
WARNING: The data set WORK.FOO may be incomplete. 
When this step was stopped there were 0 observations and 0 variables.
NOTE: DATA statement used (Total process time):
NOTE: PROCEDURE SORT used (Total process time):
WARNING: This is a user generated warning

This example shows how SearchLog returns only the ERROR, WARNING and NOTE log lines and preserves the order.

## PARAMETERS

### -file
name of log file (without extension).
if not found will look in ..\saslogs

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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

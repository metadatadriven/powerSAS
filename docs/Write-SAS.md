---
external help file: powerSAS-help.xml
Module Name: powerSAS
online version:
schema: 2.0.0
---

# Write-SAS

## SYNOPSIS
Write SAS code to server and return response object.
Supports pipeline input

## SYNTAX

```
Write-SAS [[-method] <String>]
```

## DESCRIPTION
Send SAS code to the SAS Server (using the session established with Connect-SAS)
The (sas LOG and LST) responses are returned as a sas hash table object 
This function supports pipeline input and output.

NOTE that a SAS connection must be established using Connect-SAS first

## EXAMPLES

### EXAMPLE 1
```
"data _null_; put 'hello world'; run;" | Write-SAS
```

hello world
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

This will send the hello world program to the sas connection and return the
output using the default 'listorlog' method

### EXAMPLE 2
```
@"
```

\>\> proc print
\>\>   data = sashelp.shoes;
\>\> run;
\>\> "@ | Write-SAS -method log
NOTE: There were 395 observations read from the data set SASHELP.SHOES.
NOTE: The PROCEDURE PRINT printed pages 25-32.
NOTE: PROCEDURE PRINT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

This demonstrates how to send a multi-line text string to SAS and return only the log
(i.e.
the output from the proc print is not returned, only the SAS log output)

### EXAMPLE 3
```
@"
```

\>\> proc print
\>\>   data=sashelp.shoes(obs=5);
\>\> run;
\>\> "@ | Write-SAS -method list
                                            The SAS System                        
Obs    Region    Product         Subsidiary     Stores           Sales       Inventory         Returns
  1    Africa    Boot            Addis Ababa      12           $29,761        $191,821            $769
  2    Africa    Men's Casual    Addis Ababa       4           $67,242        $118,036          $2,284
  3    Africa    Men's Dress     Addis Ababa       7           $76,793        $136,273          $2,433
  4    Africa    Sandal          Addis Ababa      10           $62,819        $204,284          $1,861
  5    Africa    Slipper         Addis Ababa      14           $68,641        $279,795          $1,771

This demonstrates using the LIST method which will only return the output and no log.

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

## INPUTS

### Text string containing SAS commands to send to the SAS connection
## OUTPUTS

### Text string containing the SAS list and/or log
## NOTES

## RELATED LINKS

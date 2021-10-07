---
external help file: powerSAS-help.xml
Module Name: powerSAS
online version:
schema: 2.0.0
---

# Connect-SAS

## SYNOPSIS
Establish a connection to the SAS server and start a session.

## SYNTAX

```
Connect-SAS [[-server] <String>] [[-credential] <PSCredential>] [-Local] [<CommonParameters>]
```

## DESCRIPTION
Return a SAS IOM workspace session object using the server name and
credentials that are supplied as parameters.
Credentials will be
prompted for if they are not supplied in full.
When finished with the Workspace object, disconnect by calling the 
Disconnect-SAS function.

## EXAMPLES

### EXAMPLE 1
```
Connect to SAs runing locally on developer workstation
```

PS\> Connect-SAS -Local

\<do stuff\>

PS\> Disconnect-SAS

### EXAMPLE 2
```
Connect to SAS Academics EU server using Alice username (interactive password prompt)
```

PS\> Connect-SAS -Credential alice
Password for user alice: ******

\<do stuff\>

PS\> Disconnect-SAS

### EXAMPLE 3
```
Connect to production SAS server, prompt user for all credentials
```

PS\> Connect-SAS -server sasprod.company.com -credential (Get-Credentials)
PowerShell credential request
Enter your credentials.
User: bob
Password for user stuart: ****

\<do stuff\>

PS\> Disconnect-SAS

### EXAMPLE 4
```
Connect to corporate SAS server using credentials supplied in variable
```

PS\> $password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
PS\> $Cred = New-Object System.Management.Automation.PSCredential ("carol", $password)
PS\> Connect-SAS -server sas.company.com -credential $Cred

\<do stuff\>

PS\> Disconnect-SAS

## PARAMETERS

### -server
(optional) name of the SAS server as text string e.g.
sas9.server.com
Default value is EU SAS for Academics server odaws01-euw1.oda.sas.com

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Odaws01-euw1.oda.sas.com
Accept pipeline input: False
Accept wildcard characters: False
```

### -credential
(optional) a PSCredential object containing credentials for remote server
Can be full PSCredential object (username and password) or only username as
a string, in which case the password is prompted interactively.
If not supplied then username and password are prompted interactively.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: [System.Management.Automation.PSCredential]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### -Local
(optional) Connect to installation of SAS on local machine.
No credentials required.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Connect-SAS
## OUTPUTS

### Workspace object - See SAS Integration Technologies documentation:
### https://support.sas.com/rnd/itech/doc9/dev_guide/dist-obj/comdoc/autoca.html
## NOTES
For details on managing credentials in PowerShell see the following article:
https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/add-credentials-to-powershell-functions?view=powershell-7.1

## RELATED LINKS

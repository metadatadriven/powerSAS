# PowerSAS documentation

Each powerSAS command has powershell `Get-Help` documentation, which is also available as markdown files in this directory.

## Connecting to a SAS Server

The [Connect-SAS](https://github.com/metadatadriven/powerSAS/blob/main/docs/Connect-SAS.md) command has examples of how to connect to local or remote servers.

Only one SAS session can be active at a time. SAS Sessions are global to the powershell environment.

End the SAS session using [Disconnect-SAS](https://github.com/metadatadriven/powerSAS/blob/main/docs/Disconnect-SAS.md)

### Send SAS commands or program files to the SAS server

There are two ways to send sas commands:

- [Write-SAS](https://github.com/metadatadriven/powerSAS/blob/main/docs/Write-SAS.md) sends a text string (e.g. for small/short code to run and get the log and/or list file in response.
- [Write-SASProgram](https://github.com/metadatadriven/powerSAS/blob/main/docs/Send-SASprogram.md) sends a SAS program file to the server and store the .log and .lst into local files

### 3. Examining SAS Log files

The results of executing SAS can be done in powershell by evaluating the response from the [Write-SAS](https://github.com/metadatadriven/powerSAS/blob/main/docs/Write-SAS.md) function, or interactively using the [Search-SASLog](https://github.com/metadatadriven/powerSAS/blob/main/docs/Search-SASLog.md) command which returns a list of ERROR, WARNING and NOTE log lines.


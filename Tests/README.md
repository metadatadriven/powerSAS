# PowerSAS Validation

There are test scripts for all the commands that the powerSAS module exports - except Invoke-iSAS - which 
relies on user interaction from the powershell host. [An issue has been raised](https://github.com/metadatadriven/powerSAS/issues/1) and investigation is underway on options to create 
automated tests for this command, and may be included in future releases

## Prerequisites

The tests are designed to run in the /Tests directory in the repository, and load the powerSAS module into the CurrentUser scope.

The tests require Pester 5.3.1 or above to run

## How to run all tests

All the tests can be run using the `Invoke-Pester` command, and with additional reporting using `Invoke-Pester -Output Detailed`

```
PS> Invoke-Pester -Output Detailed
Pester v5.3.1

Starting discovery in 5 files.
Discovery found 36 tests in 100ms.
Running tests.

Running tests from 'Connect-SAS.Tests.ps1'
Describing Connect-SAS
 Context Local
   [+] Connection established 6.41s (6.4s|16ms)
   [+] Single connection (Local) 6.35s (6.35s|1ms)
   [+] Single connection (Remote) 6.32s (6.32s|1ms)

Running tests from 'Disconnect-SAS.Tests.ps1'
Describing Disconnect-SAS
 Context Simple Connect-Disconnect
   [+] Local connection 6.37s (6.36s|6ms)
   [+] No connection 10ms (7ms|3ms)
   [+] Double disconnect 6.36s (6.36s|1ms)
   [+] Stress test 63.63s (63.63s|1ms)

Running tests from 'Search-SASLog.Tests.ps1'
Describing Search-SASLog
 Context Empty Log File
   [+] Null file 18ms (13ms|4ms)
   [+] Empty file 6ms (5ms|1ms)
 Context No logfile
   [+] Doesnt exist 6ms (4ms|2ms)
   [+] isnt a filename 6ms (5ms|1ms)
 Context Count Correct
   [+] Search string logfile 45ms (42ms|3ms)
 Context Count Correct
   [+] Search unicode logfile 7ms (5ms|3ms)
 Context Count Correct
   [+] Search bigendianunicode logfile 7ms (5ms|2ms)
 Context Count Correct
   [+] Search utf8 logfile 7ms (5ms|2ms)
 Context Count Correct
   [+] Search utf7 logfile 12ms (10ms|2ms)
 Context Count Correct
   [+] Search utf32 logfile 11ms (9ms|2ms)
 Context Count Correct
   [+] Search ascii logfile 8ms (5ms|3ms)

Running tests from 'Send-SASprogram.Tests.ps1'
Describing Send-SASprogram
 Context missing program
   [+] doesnt exist 6.38s (6.37s|8ms)
   [+] missing sas extension 6.36s (6.36s|1ms)
   [+] no filename parameter 6.35s (6.35s|2ms)
 Context autoexec
   [+] Only autoexec, no program 6.38s (6.37s|2ms)
   [+] autoexec and program 7.05s (7.05s|2ms)
 Context Long program
   [+] runs as expected 7.44s (7.44s|2ms)
 Context results
   [+] error count 6.38s (6.38s|2ms)

Running tests from 'Write-SAS.Tests.ps1'
Describing Write-SAS
 Context One liner
   [+] default method 6.42s (6.41s|4ms)
   [+] specified method (listorlog) 6.38s (6.37s|1ms)
   [+] specified method (logandlist) 6.41s (6.41s|2ms)
   [+] specified method (log) 6.36s (6.36s|1ms)
   [+] specified method (list) 6.43s (6.43s|1ms)
   [+] specified method (none) 6.35s (6.34s|2ms)
   [+] specified method (invalid) 6.41s (6.41s|1ms)
 Context Multi-Liner
   [+] Runs as expected 6.41s (6.41s|3ms)
   [+] Runs as expected 6.43s (6.43s|2ms)
   [+] Runs as expected 6.41s (6.41s|1ms)
   [+] Runs as expected 6.44s (6.44s|2ms)
Tests completed in 212.96s
Tests Passed: 36, Failed: 0, Skipped: 0 NotRun: 0
```

## How to run individual tests

Individual tests can be run by invoking the test script filename at the command line in the Tests directory:
```
PS> cd .\powerSAS\Tests\
PS> .\Connect-SAS.Tests.ps1

Starting discovery in 1 files.
Discovery found 3 tests in 209ms.
Running tests.
[+] C:\Users\StuartMalcolm\work\powerSAS\Tests\Connect-SAS.Tests.ps1 20.31s (19.79s|325ms)
Tests completed in 20.33s
Tests Passed: 3, Failed: 0, Skipped: 0 NotRun: 0
```

# File Cleaner

Powershell script to delete old files from temporary directories.

This is mainly intended to be used for cleaning up user-managed temporary directories, such as `~\Downloads` or `C:\temp\`, as a task in Windows' Task Scheduler.

The script will scan through the specified folders, removing any files that haven't been accessed longer than the specified amount of time and then deleting any empty folders that remain.


## Syntax

```powershell
.\FileCleaner.ps1 [-Path] <String[]> [-Age] <TimeSpan> [-WhatIf] [<CommonParameters>]
```


## Parameters

### `-Path <String[]>`
Required. Path(s) to scan for old files.

### `-Age <TimeSpan>`
Amount of time to have passed for a file to be deleted.

This relies on the Last Access Time property of the file.

### `-WhatIf`
Shows what would happen if the script runs.

This flag is passed through to the `Remove-Item` cmdlet, and the script performs no special handling for folders that would be deleted entirely as a result of this script. Therefore, output with this flag enabled can only be considered accurate for files, and not directories.

## Examples

```powershell
.\File-Cleaner.ps1 -Path C:\Temp\ -Age (New-Timespan -Days 30)
```

Deletes all files in `C:\Temp\` older than 30 days.

```powershell
.\File-Cleaner.ps1 -Path ~\Downloads\, C:\Temp\ -Age (New-Timespan -Days 7)
```

Deletes all files in `~\Downloads` and `C:\Temp\` older than 7 days.

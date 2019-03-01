<#
.SYNOPSIS
Script to delete old files from temporary directories.

.DESCRIPTION
This is mainly intended to be used for cleaning up user-managed temporary directories, such as ~\Downloads or C:\temp\, as a task in Windows' Task Scheduler.
The script will scan through the specified folders, removing any files that haven't been accessed longer than the specified amount of time and then deleting any empty folders that remain.

.PARAMETER Path
Path(s) to scan for old files.

.PARAMETER Age
Amount of time to have passed for a file to be deleted.
This relies on the Last Access Time property of the file.

.PARAMETER WhatIf
Shows what would happen if the script runs.
This flag is passed through to the Remove-Item cmdlet, and the script performs no special handling for folders that would be deleted entirely as a result of this script. Therefore, output with this flag enabled can only be considered accurate for files, and not directories.

.EXAMPLE
C:\PS> .\File-Cleaner.ps1 -Path C:\Temp\ -Age (New-Timespan -Days 30)

Deletes all files in C:\Temp\ older than 30 days.

.EXAMPLE
C:\PS> .\File-Cleaner.ps1 -Path ~\Downloads\, C:\Temp\ -Age (New-Timespan -Days 7)

Deletes all files in ~\Downloads and C:\Temp\ older than 7 days.
#>


param (
    [Parameter(Mandatory=$True, Position=1)]
        [string[]]$Path,
    [Parameter(Mandatory=$True, Position=2)]
        [timespan]$Age,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest



function Clean([string[]]$Path, [timespan]$Age, [switch]$WhatIf)
{
    # Clear out files
    $cutoff = (Get-Date) - $Age
    $oldFiles = Get-ChildItem -Path $Path -Recurse -Force | Where-Object {-not $_.PSIsContainer -and $_.LastAccessTime -lt $cutoff}
    foreach($item in $oldFiles)
    {
        Remove-Item $item.PSPath -Force -WhatIf:$WhatIf
    }

    # Clear empty directories
    CleanEmptyDirectories -Path $Path -WhatIf:$WhatIf
}

function CleanEmptyDirectories([string[]]$Path, [switch]$WhatIf)
{
    $folders = Get-ChildItem -Path $Path -Force | Where-Object {$_.PSIsContainer}
    foreach ($folder in $folders)
    {
        if ((Get-ChildItem -Path $folder.PSPath -Recurse -Force | Where-Object {-not $_.PSIsContainer} | Measure-Object).Count -eq 0)
        {
            Remove-Item $folder.PSPath -Recurse -WhatIf:$WhatIf
        }
        else
        {
            CleanEmptyDirectories($folder.PSPath)
        }
    }
}



Clean -Path $Path -Age $Age -WhatIf:$WhatIf

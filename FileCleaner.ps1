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

param (
    [Parameter(Mandatory=$True, Position=1)]
    [string[]]$Path,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest



function Clean([string[]]$Path, [switch]$WhatIf)
{
    # Clear out files
    $cutoff = (Get-Date) - (New-TimeSpan -Days 30)
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



Clean -Path $Path -WhatIf:$WhatIf

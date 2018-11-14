function Copy-Recursive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        $src,

        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        $dest,

        # Names of the files to copy
        [Parameter()]
        $include = "*",

        # Names of the files to exclude from copiing
        [Parameter()]
        $exclude = "",

        # Enable/disable logging of copied files
        [Parameter()]
        [bool]
        $passThru = $true
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    Get-ChildItem -Path $src -Filter $include -Exclude $exclude -Recurse | ForEach-Object {
        $fileOrDirectory = $_
        if ($fileOrDirectory.PSIsContainer) {
            $dirName = $fileOrDirectory.Parent.FullName.Substring($src.Length)
            $destination = Join-Path $dest $dirName
        }
        else {
            $fileName = $fileOrDirectory.FullName.Substring($src.Length)
            $destination = Join-Path $dest $fileName

            if (!(Test-Path $destination)) {
                New-Item -Path $destination -ItemType File -Force
            }
        }

        Copy-Item -Path $fileOrDirectory.Fullname -Destination $destination -Force -PassThru:$passThru -ErrorAction $errorAction
    }
}



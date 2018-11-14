function Push-NugetPackage {
    [CmdletBinding()]
    param (
        # Nuget package(s) (*.nupkg)
        [Parameter(Mandatory, ValueFromPipeline)]
        $package,

        # Source directory
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $sourceDir,

        # NuGet API Key
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $nugetApiKey
    )

    Begin {
        if ($PSBoundParameters["Verbose"]) {
            $cmdletVerbosity = $true
            $nugetVerbosity = "detailed"
        }
        else {
            $cmdletVerbosity = $false
            $nugetVerbosity = "normal"
        }

    }

    Process {
        if (($package -isnot [array]) -and ($package -isnot [System.IO.FileInfo])) {
            $package = Get-Item $package
        }

        if ($package -is [array]) {
            foreach ($pkg in $package) {
                Push-NugetPackage -package $pkg -sourceDir $sourceDir -nugetApiKey $nugetApiKey -Verbose:$cmdletVerbosity
            }
        }

        if ($package -is [System.IO.DirectoryInfo]) {
            Get-ChildItem -Path $package -Filter "*.nupkg" -File |
                Push-NugetPackage -sourceDir $sourceDir -nugetApiKey $nugetApiKey -Verbose:$cmdletVerbosity
        }

        if ($package -is [System.IO.FileInfo]) {
            nuget push $package.FullName -ConfigFile (Join-Path $sourceDir "nuget.config") -ApiKey $nugetApiKey -Verbosity $nugetVerbosity

            if ($LASTEXITCODE) {
                throw "`nNuget execution failed"
            }
        }
    }
}



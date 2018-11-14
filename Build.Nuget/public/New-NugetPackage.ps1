function New-NugetPackage {
    [CmdletBinding()]
    param (
        # Nuget spec file(s)
        [Parameter(Mandatory, ValueFromPipeline)]
        $spec,

        # Assemblies folder
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $assemblyDir,

        # Output folder
        [Parameter()]
        [string]
        $out = "Packages",

        # Package version
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Version]
        $version
    )

    Begin {
        $assemblyDir = [System.String]::Concat($assemblyDir.TrimEnd('\'), '\')

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
        if (($spec -isnot [array]) -and ($spec -isnot [System.IO.FileInfo])) {
            $spec = Get-Item $spec
        }

        if ($spec -is [array]) {
            foreach ($item in $spec) {
                New-NugetPackage -spec $item -assemblyDir $assemblyDir -version $version -out $out -Verbose:$cmdletVerbosity
            }
        }

        if ($spec -is [System.IO.DirectoryInfo]) {
            Get-ChildItem -Path $spec -Filter "*.nuspec" -File |
                New-NugetPackage -assemblyDir $assemblyDir -version $version -out $out -Verbose:$cmdletVerbosity
        }

        if ($spec -is [System.IO.FileInfo]) {
            nuget pack $spec.FullName -OutputDirectory $out -Version $version -Verbosity $nugetVerbosity -Properties bin=$assemblyDir

            if ($LASTEXITCODE) {
                throw "`nNuget execution failed"
            }
        }
    }
}



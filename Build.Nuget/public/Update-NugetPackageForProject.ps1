function Update-NugetPackageForProject {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $project,

        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $packageDir
    )

    Process {
        if (($project -isnot [array]) -and ($project -isnot [System.IO.FileInfo])) {
            $project = Get-Item $project
        }

        if ($project -is [array]) {
            foreach ($item in $project) {
                Update-NugetPackageForProject -project $item -packageDir $packageDir
            }
        }

        if ($project -is [System.IO.DirectoryInfo]) {
            Get-ChildItem $project -Filter "*.csproj" -Recurse -File |
                Update-NugetPackageForProject -packageDir $packageDir
        }

        if ($project -is [System.IO.FileInfo]) {
            if ($project.Extension -ne ".csproj") {
                return
            }

            $packages = Get-ChildItem -Path $packageDir -Filter "*.nupkg" -File

            $xml = New-Object -TypeName XML
            $xml.Load($project.FullName)

            foreach ($package in $packages) {
                $pkgObj = Get-NugetPackageObject -name $package

                $node = $xml.SelectSingleNode("/Project/ItemGroup/PackageReference[@Include='$($pkgObj.Id)']")
                if ($node) {
                    $node.Attributes['Version'].Value = $pkgObj.Version
                }
            }

            $xml.Save($project.FullName)
        }
    }
}



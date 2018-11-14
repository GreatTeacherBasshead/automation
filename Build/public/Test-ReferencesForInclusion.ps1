function Test-ReferencesForInclusion {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $path
    )

    Process {
        if (($path -isnot [array]) -and ($path -isnot [System.IO.FileInfo])) {
            $path = Get-Item $path
        }

        if ($path -is [array]) {
            foreach ($item in $path) {
                Test-ReferencesForInclusion -path $item
            }
        }

        if ($path -is [System.IO.DirectoryInfo]) {
            Get-ChildItem $path -Filter "*.csproj" -Exclude "*Test*.csproj" -Recurse -File | Test-ReferencesForInclusion
        }

        if ($path -is [System.IO.FileInfo]) {
            if ($path.Extension -ne ".csproj") {
                return
            }

            switch -Wildcard ($path.Name) {
                "*.Client.*" {
                    $projects = "Test", "Server"
                    break
                }
                "*.Server.*" {
                    $projects = "Test", "Client"
                    break
                }
                "*.Contract.*" {
                    $projects = "Test", "Client", "Server"
                    break
                }
            }

            Test-ReferencesForProhibitedProjects -path $path.FullName -prohibitedProjects $projects
        }
    }
}



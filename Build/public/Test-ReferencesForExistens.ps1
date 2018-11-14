function Test-ReferencesForExistens {
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
                Test-ReferencesForExistens -path $item
            }
        }

        if ($path -is [System.IO.DirectoryInfo]) {
            Get-ChildItem $path -Filter "*.csproj" -Recurse -File | Test-ReferencesForExistens
        }

        if ($path -is [System.IO.FileInfo]) {
            if ($path.Extension -ne ".csproj") {
                return
            }

            $invalidRefs = New-Object -TypeName System.Collections.ArrayList

            $xml = New-Object -TypeName XML
            $xml.Load($path.FullName)

            $refs = $xml.SelectNodes("/Project/ItemGroup/Reference/HintPath/text()").Value
            foreach ($ref in $refs) {
                $referencePath = Join-Path $path.DirectoryName $ref
                if (Test-Path $referencePath) {
                    continue
                }

                $obj = [PSCustomObject]@{
                    Project   = $path.FullName
                    Reference = $ref
                }
                [void]$invalidRefs.Add($obj)
            }
        }

        Write-Output $invalidRefs
    }
}



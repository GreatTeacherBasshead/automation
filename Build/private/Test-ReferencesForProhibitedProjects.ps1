function Test-ReferencesForProhibitedProjects {
    param(
        # .csproj file path to check
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $path,

        # Reference project list which are NOT allowed to be in this project (e.g "Test", "Server")
        [Parameter()]
        [string[]]
        $prohibitedProjects
    )

    if (!$prohibitedProjects) {
        return
    }

    $invalidRefs = New-Object -TypeName System.Collections.ArrayList
    $lookup = @{
        "Client" = "contains(., '.Client') and not(contains(., 'Contract'))"
        "Server" = "contains(., '.Server') and not(contains(., 'Contract'))"
        "Test"   = "contains(., 'Test')"
    }

    $xml = New-Object -TypeName XML
    $xml.Load($path)

    foreach ($proj in $prohibitedProjects) {
        $refs = $xml.SelectNodes("/Project/ItemGroup/*[contains(name(), 'Reference')]/@Include[$($lookup.$proj)]")
        foreach ($ref in $refs) {
            $obj = [PSCustomObject]@{
                Project   = $path
                Reference = $ref.'#text'
            }
            [void]$invalidRefs.Add($obj)
        }
    }
    Write-Output $invalidRefs
}



. $PSCommandPath.Replace('.Tests', '')

Describe "Compare-AssembliesVersion" {
    $suiteDir = New-Item "TestDrive:\Server" -ItemType Directory
    $dataImportDir = New-Item "TestDrive:\DataImport" -ItemType Directory

    $suiteDll = New-Item "$suiteDir\test.dll" -ItemType File
    $suiteDll = New-Item "$dataImportDir\test.dll" -ItemType File

    It "test smth" {
        Mock Get-Item {
            return [PSCustomObject]@{ VersionInfo = @{ FileVersion = "666" } }
        }

        $result = Compare-AssembliesVersion -assemblyName "test.dll" -workingDir TestDrive:\
        $result | Should Be "The version of 'test.dll' is '666' for both modules"
    }
}

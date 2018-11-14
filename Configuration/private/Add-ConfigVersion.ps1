<#
1) Find proper StagingManager.exe.config files
2) Check if 'configVersion' element exists
3) If does not exist, add it with 5.1.0 version
#>
function Add-ConfigVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $configDir,

        # Version for StagingManager configs. FileCopier configs get "1.0" version. All other configs have already got real versions
        [Parameter()]
        [string]
        $version,

        # XPath, where configVersion section should be add to
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $xPath = "/configuration/appSettings"
    )

    Write-Verbose "Executing 'Add-ConfigVersion'"

    $cfgStagingManager = Get-ChildItem -Path $configDir -Include "Q.O.DataImport.StagingManager.exe.config" -Recurse -File
    if ($cfgStagingManager) {
        $cfgStagingManager | ForEach-Object {
            Add-Member -InputObject $_ -NotePropertyName "Version" -NotePropertyValue $version
        }
    }

    $cfgFileCopier = Get-ChildItem -Path $configDir -Include "Q.FileCopier*.exe.config" -Recurse -File
    if ($cfgFileCopier) {
        $cfgFileCopier | ForEach-Object {
            Add-Member -InputObject $_ -NotePropertyName "Version" -NotePropertyValue "1.0.0"
        }
    }

    $cfgMassContext = Get-ChildItem -Path $configDir -Include "Q.MassContextImporter.exe.config" -Recurse -File
    if ($cfgMassContext) {
        $cfgMassContext | ForEach-Object {
            Add-Member -InputObject $_ -NotePropertyName "Version" -NotePropertyValue "5.0.0"
        }
    }

    foreach ($config in @($cfgStagingManager) + @($cfgFileCopier) + @($cfgMassContext)) {
        $configFullName = $config.FullName
        Write-Verbose "Processing $configFullName"

        $xml = New-Object -TypeName XML
        $xml.Load($configFullName)

        if (!(Select-Xml -Xml $xml -XPath $xPath)) {
            Write-Error "'$xPath' element does not exist in $configFullName"
        }

        # skip the file if it already has configVersion
        if (Select-Xml -Xml $xml -XPath "$xPath/add[@key='configVersion']") {
            continue
        }

        "Config version '$($config.Version)' will be added to $configFullName" | Write-Host

        $versionNode = $xml.CreateElement("add")
        $versionNode.SetAttribute("key", "configVersion")
        $versionNode.SetAttribute("value", $config.Version)
        $xml.SelectSingleNode($xPath).AppendChild($versionNode)

        $xml.Save($configFullName)
    }
}


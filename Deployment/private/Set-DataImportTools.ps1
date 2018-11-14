function Set-DataImportTools {
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment,

        # DataImport working directory (${bamboo.build.working.directory}\DataImport)
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir
    )

    if ($dataImportTools.$environment) {
        $tools = $dataImportTools.$environment
    }
    else {
        $tools = ".Cd", ".Exposure.Asml", ".Exposure.Nikon", ".Overlay.Auros", ".Overlay.Kla", ".YieldStar", ".StagingManager"
    }

    $toolList = New-Object -TypeName System.Collections.ArrayList

    foreach ($tool in $tools) {
        $obj = [PSCustomObject]@{
            ToolName           = $tool -replace "^\."
            ConfigRelativePath = Join-Path "Configuration" "dataImport$tool.config"
            Config             = [System.IO.Path]::Combine($workingDir, "Configuration", "dataImport$tool.config")
            Exe                = Join-Path $workingDir "Q.O.DataImport$tool.exe"
            ExeConfig          = Join-Path $workingDir "Q.O.DataImport$tool.exe.config"
        }

        $toolList.Add($obj) | Write-Verbose
    }

    Write-Output $toolList
}



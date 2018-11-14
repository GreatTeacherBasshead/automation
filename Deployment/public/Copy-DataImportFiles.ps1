function Copy-DataImportFiles {
    [CmdletBinding()]
    param(
        # Customer's fab (${bamboo.deploy.environment})
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment,

        # DataImport working directory (${bamboo.build.working.directory}\DataImport)
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    $exe = Join-Path $workingDir "Q.O.DataImport.exe"
    $exeConfig = Join-Path $workingDir "Q.O.DataImport.exe.config"
    $config = Join-Path $workingDir "Configuration\dataImport.config"

    $tools = Set-DataImportTools -environment $environment -workingDir $workingDir
    $xml = New-Object -TypeName XML

    foreach ($tool in $tools) {
        Copy-Item $exe $tool.Exe -PassThru -ErrorAction $errorAction
        Copy-Item $exeConfig $tool.ExeConfig -PassThru -ErrorAction $errorAction
        Copy-Item $config $tool.Config -PassThru -ErrorAction $errorAction

        $xml.Load($tool.ExeConfig)
        "Update $($tool.ExeConfig) with value $($tool.ConfigRelativePath)" | Write-Output
        $xml.configuration.dataImport.configSource = $tool.ConfigRelativePath.ToString()
        $xml.Save($tool.ExeConfig)
    }

    Remove-Item $exe, $exeConfig, $config -Verbose -ErrorAction $errorAction
}



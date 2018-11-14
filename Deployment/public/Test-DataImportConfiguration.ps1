function Test-DataImportConfiguration {
    [CmdletBinding()]
    param (
        # Customer fab (${bamboo.deploy.environment})
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment,

        # Working directory
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir
    )

    $tools = Set-DataImportTools -environment $environment -workingDir $workingDir
    $fails = New-Object -TypeName System.Collections.ArrayList

    foreach ($tool in $tools) {
        . $tool.Exe diConfig=$($tool.Config) appConfig=$($tool.ExeConfig) testConfiguration

        if ($LASTEXITCODE) {
            $fails.Add($tool.ToolName) | Write-Verbose
        }
    }

    if ($fails.Count -gt 0) {
        "`nDataImport configuration errors occurred in:"
        $fails

        Write-Error "DataImport configuration is invalid."
    }
}



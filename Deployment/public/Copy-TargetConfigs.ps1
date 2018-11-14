function Copy-TargetConfigs {
    [CmdletBinding()]
    param(
        # Absolute path to customers configs
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $src,

        # Absolute path to in-house configs
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $dest,

        # Customer fab (${bamboo.deploy.environment})
        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    $customer = Get-CustomerFab -targetHost $environment
    $installedOnTargetPath = [System.IO.Path]::Combine($src, $customer.Name, $customer.Fab)

    Copy-Recursive -src "$installedOnTargetPath\O\Client" -dest "$dest\Suite\Sources\bin\Client" -include "*.config" -ErrorAction $errorAction
    "Server", "DataImport" | ForEach-Object {
        Copy-Recursive -src "$installedOnTargetPath\O\$_" -dest "$dest\$_" -include "*.config" -ErrorAction $errorAction
        Copy-Item -Path "$installedOnTargetPath\O\$_\UserMessage.ini" -Destination "$dest\$_\UserMessage.ini" -Force -PassThru -ErrorAction Continue
    }

    "FileCopier", "MassContextImporter", "LogTransfer" | ForEach-Object {
        # not all customers have '$_'
        if (Test-Path "$installedOnTargetPath\O\$_") {
            Copy-Recursive -src "$installedOnTargetPath\O\$_" -dest "$dest\$_" -include "*.config" -ErrorAction $errorAction
        }
    }

    Copy-Item -Path "$installedOnTargetPath\License\Q.O.Core.Server.lic" -Destination "$dest\Server\Configuration\Q.O.Core.Server.lic" -Force -PassThru -ErrorAction Continue
    Copy-Item -Path "$installedOnTargetPath\O\Database\setEnv.cmd" -Destination "$dest\Database\setEnv.cmd" -Force -PassThru -ErrorAction Continue

    $mappingFiles | ForEach-Object {
        $filePath = [System.IO.Path]::Combine($installedOnTargetPath, "Shared", $_)
        $destPath = [System.IO.Path]::Combine($dest, "Shared", $_)

        if (Test-Path $filePath) {
            Copy-Item -Path $filePath -Destination (New-Item -Path $destPath -ItemType File -Force) -PassThru -ErrorAction $errorAction
        }
    }
}



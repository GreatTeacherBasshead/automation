function Start-ConfigsTransform {
    [CmdletBinding()]
    param(
        # Absolute path to 'Configuration' repository, 'InstalledOnTarget' directory
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $configurationRepoPath,

        # Customer's fab (${bamboo.deploy.environment})
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment,

        # Target version
        [Parameter()]
        [string]
        $version,

        [Parameter()]
        [string[]]
        $modules = @("Server", "DataImport", "Client", "FileCopier", "MassContextImporter")
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    $customer = Get-CustomerFab -targetHost $environment
    $fabPath = [System.IO.Path]::Combine($configurationRepoPath, $customer.Name, $customer.Fab)

    # Copy a license and CodeMeter config to be processed together with all configs
    $licSrc = Join-Path $fabPath "License\Q.O.Core.Server.lic"
    $licDest = Join-Path $fabPath "O\Server\license.config"
    Copy-Item -Path $licSrc -Destination $licDest -PassThru

    "Server", "DataImport" | ForEach-Object {
        $usrMsgIniSrc = [System.IO.Path]::Combine($PSScriptRoot, "..\..", $_, "UserMessage.ini")
        $usrMsgIniDest = [System.IO.Path]::Combine($fabPath, "O", $_, "UserMessage.ini")
        if (!(Test-Path $usrMsgIniDest)) {
            Copy-Item -Path $usrMsgIniSrc -Destination $usrMsgIniDest -PassThru
        }
    }

    # Bamboo passes build version similar to this: '5.0.0.2610 D'
    $regex = "^(\d\.\d\.\d).*$"
    if (($version -ne $null) -and ($version -match $regex)) {
        $version = $version -replace $regex, '$1'
    }

    $configUpdater = Join-Path $PSScriptRoot "..\Tools\ConfigUpdater\ConfigUpdater.exe"
    $xmllint = Join-Path $PSScriptRoot "..\Tools\xmllint\xmllint.exe"

    "`nVersion: $version" | Write-Output

    foreach ($module in $modules) {
        $configs = [System.IO.Path]::Combine($fabPath, "O", $module)
        $transforms = [System.IO.Path]::Combine($configurationRepoPath, "..\Transformations", $module)

        if (!(Test-Path $configs)) {
            continue
        }

        "`nConfigs: $configs" | Write-Output
        "Transforms: $transforms`n" | Write-Output

        if ([System.String]::IsNullOrWhiteSpace($version)) {
            . $configUpdater --configs $configs --migrations $transforms
        }
        else {
            . $configUpdater --configs $configs --migrations $transforms --version $version
        }

        if ($LASTEXITCODE) {
            "`nTransformations failed" | Write-Error
        }

        Get-ChildItem -Path $configs -Filter "*.config" -Recurse -File | ForEach-Object {
            . $xmllint --format -o $_.FullName $_.FullName
        }
    }

    # Move the license back
    Move-Item -Path $licDest -Destination $licSrc -Force -PassThru
}



function Backup-O {
    [CmdletBinding()]
    param (
        # Customer's fab (${bamboo.deploy.environment})
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment,

        # Local path for deployment (${bamboo.DeployPath}, \Q\O, \D$\O)
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $deployLocalPath,

        # Enable/disable logging of copied files
        [Parameter(Mandatory = $false)]
        [bool]
        $passThru = $true
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    $customer = Get-CustomerFab -targetHost $environment
    $deployPath = [System.IO.Path]::Combine("\\", $customer.Fab, $deployLocalPath)
    $backupPath = Join-Path $deployPath "Backup"

    if (Test-Path $backupPath) {
        Remove-Item $backupPath -Recurse -Force -ErrorAction $errorAction
    }

    $oSrc = Join-Path $deployPath "O"
    $oDest = Join-Path $backupPath "O"
    Copy-Item $oSrc $oDest -Recurse -PassThru:$passThru -ErrorAction $errorAction

    $licenseSrc = Join-Path $deployPath "License"
    $licenseDest = Join-Path $backupPath "License"
    Copy-Item $licenseSrc $licenseDest -Recurse -PassThru:$passThru -ErrorAction $errorAction

    $sharedSrc = Join-Path $deployPath "Shared"
    $sharedDest = Join-Path $backupPath "Shared"
    Copy-Item $sharedSrc $sharedDest -Recurse -PassThru:$passThru -ErrorAction $errorAction
}



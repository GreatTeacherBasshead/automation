function Publish-O {
    [CmdletBinding()]
    param (
        # Customer's fab (${bamboo.deploy.environment})
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment,

        # Release version (${bamboo.deploy.release})
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $release,

        # Local path for deployment (${bamboo.DeployPath}, \Q\O, \D$\O)
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $deployLocalPath,

        # Root directory for deployment packages (${bamboo.BaseDeploymentPackagePath})
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $basePackagePath,

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
    $packagePath = [System.IO.Path]::Combine($basePackagePath, $customer.Name, $customer.Fab, $release)
    $deployPath = [System.IO.Path]::Combine("\\", $customer.Fab, $deployLocalPath)

    $oSrc = Join-Path $packagePath "O"
    $oDest = Join-Path $deployPath "O"
    if (Test-Path $oDest) {
        Remove-Item $oDest -Recurse -Force -ErrorAction $errorAction
    }
    Copy-Item -Path $oSrc -Destination $oDest -Recurse -PassThru:$passThru -ErrorAction $errorAction

    $licenseSrc = Join-Path $packagePath "License"
    $licenseDest = Join-Path $deployPath "License"
    if (Test-Path $licenseDest) {
        Remove-Item $licenseDest -Recurse -Force -ErrorAction $errorAction
    }
    Copy-Item -Path $licenseSrc -Destination $licenseDest -Recurse -PassThru:$passThru -ErrorAction $errorAction

    $sharedSrc = Join-Path $packagePath "Shared"
    $sharedDest = Join-Path $deployPath "Shared"
    if (Test-Path $sharedDest) {
        Remove-Item $sharedDest -Recurse -Force -ErrorAction $errorAction
    }
    Copy-Item -Path $sharedSrc -Destination $sharedDest -Recurse -PassThru:$passThru -ErrorAction $errorAction

    # Create a flag if deployment is completed successfully. It's used with Backup-O cmdlet to identify wether to delete a previous backup or leave it if a previous deployment failed.
    New-Item -Path $oDest -Name $deploySuccessful -Force -ItemType File -ErrorAction $errorAction
}



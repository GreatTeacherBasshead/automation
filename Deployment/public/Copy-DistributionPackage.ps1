function Copy-DistributionPackage {
    [CmdletBinding()]
    param(
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

        # Working directory (${bamboo.build.working.directory})
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir,

        # Root output directory
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $baseOutDir
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    $customer = Get-CustomerFab -targetHost $environment
    $customerName = $customer.Name
    $customerFab = $customer.Fab

    $outDir = [System.IO.Path]::Combine($baseOutDir, $customerName, $customerFab, $release)
    if (Test-Path $outDir) {
        Remove-Item -Path $outDir -Recurse -Force -ErrorAction $errorAction
    }

    New-Item -Path $outDir -ItemType Directory -ErrorAction $errorAction
    $oDir = Join-Path $outDir "O"

    Copy-Item -Path "$workingDir\Suite\Sources\bin\Client" -Destination "$oDir\Client" -Recurse -PassThru -ErrorAction $errorAction

    Copy-Item -Path "$workingDir\Suite\Installer\Q.O.Client.Installer\bin\Release" -Filter "*.msi" -Destination "$oDir\ClientInstaller" -Recurse -PassThru -ErrorAction $errorAction

    Copy-Item -Path "$workingDir\Database" -Destination "$oDir\Database" -Recurse -PassThru -ErrorAction $errorAction
    Remove-Item -Path "$oDir\Database\*" -Filter "update*" -Verbose -ErrorAction $errorAction

    Copy-Item -Path "$workingDir\DataImport" -Destination "$oDir\DataImport" -Recurse -PassThru -ErrorAction $errorAction
    Remove-Item -Path "$oDir\DataImport\Configuration\Customers" -Recurse -Verbose -ErrorAction $errorAction

    Copy-Item -Path "$workingDir\ReleaseNotes\OUserManual.pdf" -Destination (New-Item -Path "$oDir\Documentation\OUserManual.pdf" -ItemType File -Force) -PassThru -ErrorAction $errorAction
    Copy-Item -Path "$workingDir\ReleaseNotes\ReleaseNotes.txt" -Destination (New-Item -Path "$oDir\Documentation\ReleaseNotes.txt" -ItemType File -Force) -PassThru -ErrorAction $errorAction
    Copy-Item -Path "$workingDir\ReleaseNotes\ReleaseNotes.pdf" -Destination (New-Item -Path "$oDir\Documentation\ReleaseNotes.pdf" -ItemType File -Force) -PassThru -ErrorAction $errorAction

    $customerReleaseNotesName = "ReleaseNotes.$customerName.txt"
    $customerReleaseNotesFile = [System.IO.Path]::Combine($workingDir, "ReleaseNotes", $customerReleaseNotesName)
    if (Test-Path $customerReleaseNotesFile) {
        $dest = New-Item -Path "$oDir\Documentation\$customerReleaseNotesName" -ItemType File -Force
        Copy-Item -Path $customerReleaseNotesFile -Destination $dest -PassThru -ErrorAction $errorAction
    }

    Copy-Item -Path "$workingDir\Server" -Destination "$oDir\Server" -Recurse -PassThru -ErrorAction $errorAction
    Copy-Item -Path "$workingDir\Server\Configuration\Q.O.Core.Server.lic" -Destination (New-Item -Path "$outDir\License\Q.O.Core.Server.lic" -ItemType File -Force) -PassThru -ErrorAction $errorAction
    Remove-Item -Path "$oDir\Server\Configuration\Q.O.Core.Server.lic" -Verbose -ErrorAction $errorAction

    Copy-Item -Path "$workingDir\FileCopier" -Destination "$oDir\FileCopier" -Recurse -PassThru -ErrorAction $errorAction
    Copy-Item -Path "$workingDir\LogTransfer" -Destination "$oDir\LogTransfer" -Recurse -PassThru -ErrorAction $errorAction
    Copy-Item -Path "$workingDir\Performance_counter" -Destination "$oDir\PerfMon" -Recurse -PassThru -ErrorAction $errorAction
    Copy-Item -Path "$workingDir\O_Monitoring" -Destination "$oDir\Scripts" -Recurse -PassThru -ErrorAction $errorAction
    Copy-Item -Path "$workingDir\SQL" -Destination "$oDir\SQL" -Recurse -PassThru -ErrorAction $errorAction
    Copy-Item -Path "$workingDir\MassContextImporter" -Destination "$oDir\MassContextImporter" -Recurse -PassThru -ErrorAction $errorAction

    if (($customerName -eq "SKhynix") -or ($customerName -eq "Q")) {
        Copy-Item -Path "$workingDir\SmartCPE" -Destination "$oDir\SmartCPE" -Recurse -PassThru -ErrorAction $errorAction
        Copy-Item -Path "$workingDir\SmartTAS" -Destination "$oDir\SmartTAS" -Recurse -PassThru -ErrorAction $errorAction
    }

    Copy-Item -Path "$workingDir\Shared" -Destination "$outDir\Shared" -Recurse -PassThru -ErrorAction $errorAction

    Copy-Item -Path "$workingDir\info.txt" -Destination (New-Item -Path "$outDir\info.txt" -ItemType File -Force) -PassThru -ErrorAction $errorAction

    $archive = "$customerName.$customerFab_$release.zip"
    Compress-Archive -Path $outDir\* -DestinationPath (Join-Path $outDir $archive) -Force -Verbose
}



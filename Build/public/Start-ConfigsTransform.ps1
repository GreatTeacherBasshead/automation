function Start-ConfigsTransform {
    [CmdletBinding()]
    param(
        # Working directory (${bamboo.build.working.directory})
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir,

        # Build type
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $build,

        # Module name
        [Parameter(Mandatory)]
        [ValidateSet("Server", "Client", "Test", "Database")]
        [string]
        $module
    )

    $configUpdater = Join-Path $PSScriptRoot "..\Tools\ConfigUpdater\ConfigUpdater.exe"

    $configs = Join-Path $workingDir $module
    if (Test-Path $configs) {
        "`nConfigs: $configs"
    }
    else {
        Write-Warning "Configs directory `'$configs`' does not exist"
        return
    }

    $transforms = [System.IO.Path]::Combine($PSScriptRoot, "ConfigTransforms", $build, $module)
    if (Test-Path $transforms) {
        "Transforms: $transforms`n"
    }
    else {
        Write-Error "Transformations directory `'$transforms`' does not exist"
    }

    . $configUpdater --configs $configs --migrations $transforms --mode "unversioned"

    if ($LASTEXITCODE) {
        Write-Error "`nTransformations failed!"
    }
}


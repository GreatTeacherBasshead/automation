function Copy-FileCopierFiles {
    [CmdletBinding()]
    param(
        # Customer's fab (${bamboo.deploy.environment})
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment,

        # FileCopier working directory (${bamboo.build.working.directory}\FileCopier)
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    if (!$fileCopiers.$environment) {
        return
    }

    $copiers = $fileCopiers.$environment

    $exe = Join-Path $workingDir "Q.FileCopier.exe"
    $exeConfig = Join-Path $workingDir "Q.FileCopier.exe.config"
    $config = Join-Path $workingDir "Configuration\fileCopier.config"

    foreach ($copier in $copiers) {
        $newConfigRelativePath = Join-Path "Configuration" "$copier.config"
        $newExe = Join-Path $workingDir "Q.$copier.exe"
        $newExeConfig = Join-Path $workingDir "Q.$copier.exe.config"
        $newConfig = Join-Path $workingDir $newConfigRelativePath

        Copy-Item $exe $newExe -PassThru -ErrorAction $errorAction
        Copy-Item $exeConfig $newExeConfig -PassThru -ErrorAction $errorAction
        Copy-Item $config $newConfig -PassThru -ErrorAction $errorAction

        "Update $newExeConfig with value $newConfigRelativePath" | Write-Output
        Set-XPath -file $newExeConfig -xpath "/configuration/appSettings/add[@key='fileCopier.Config']/@value" -value $newConfigRelativePath
    }

    Remove-Item $exe, $exeConfig, $config -Verbose -ErrorAction $errorAction
}



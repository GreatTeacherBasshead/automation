function Invoke-CodemeterProtection {
    [CmdletBinding()]
    param (
        # Path to directory with Core assemblies which have to be protected (${bamboo.build.working.directory}\Core)
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        $coreDir
    )

    $config = Join-Path $PSScriptRoot "..\CodeMeter\O.Core.Server.dll.xml"
    $dll = "Q.O.Core.Server.dll"
    $codemeter = Join-Path ${env:ProgramFiles(x86)} "WIBU-SYSTEMS\AxProtector\Devkit\bin\AxProtectorNet.exe"

    Set-CodemeterConfig -config $config -dll (Join-Path $coreDir $dll)
    . $codemeter `@$config

    if ($LASTEXITCODE) {
        Write-Error "`nCodemeter execution failed!"
    }

    Copy-Item -Path "$coreDir\protected\$dll" -Destination $coreDir -Force -PassThru
}



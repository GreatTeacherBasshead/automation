function Compare-AssembliesVersion {
    [CmdletBinding()]
    param(
        # Q.O.Core.Server.dll
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $assemblyName,

        # Working directory (${bamboo.build.working.directory})
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir
    )

    Begin {
        $suiteDirPath = Join-Path $workingDir "Server"
        $dataImportDirPath = Join-Path $workingDir "DataImport"
    }

    Process {
        $assemblyName | ForEach-Object {
            $dataImportAssemblyToCheckPath = Join-Path $dataImportDirPath $_
            $suiteAssemblyToCheckPath = Join-Path $suiteDirPath $_

            if (!(Test-Path $dataImportAssemblyToCheckPath)) {
                "There is no file '$dataImportAssemblyToCheckPath'" | Write-Error
                return
            }

            if (!(Test-Path $suiteAssemblyToCheckPath)) {
                "There is no file '$suiteAssemblyToCheckPath'" | Write-Error
                return
            }

            $dataImportAssemblyToCheck = Get-Item -Path $dataImportAssemblyToCheckPath
            $suiteAssemblyToCheck = Get-Item -Path $suiteAssemblyToCheckPath

            $dataImportAssemblyVersion = $dataImportAssemblyToCheck.VersionInfo.FileVersion
            $suiteAssemblyVersion = $suiteAssemblyToCheck.VersionInfo.FileVersion

            if ($dataImportAssemblyVersion -ne $suiteAssemblyVersion) {
                $generalInfo = "There are different versions of assemblies"
                $dataImportVersionInfo = "DataImport has version '$dataImportAssemblyVersion' of '$_'"
                $suiteVersionInfo = "Suite has version '$suiteAssemblyVersion' of '$_'"

                $errorMessage = $generalInfo + "`n" + $dataImportVersionInfo + "`n" + $suiteVersionInfo

                Write-Error -Message $errorMessage
            }

            "The version of '$_' is '$suiteAssemblyVersion' for both modules" | Write-Output
        }
    }
}



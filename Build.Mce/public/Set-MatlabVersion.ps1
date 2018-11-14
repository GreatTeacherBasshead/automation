function Set-MatlabVersion {
    param (
        # AssemblyInfo file, which contains file version
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        $assemblyInfo,

        # Matlab deploytool's execution log file
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        $logFile
    )

    $log = Get-Content $logFile

    # get, modify and run "mcc" command to get .ctf-file
    $mcc = $log | Select-String "mcc"
    $mcc = $mcc[0] -replace "'", '"'
    $mcc = $mcc.Trim() + " -/e"

    cmd /c $mcc
    if ($LASTEXITCODE) {
        throw "mcc execution failed"
    }

    # get, modify and run "csc" command to set the version
    $log | Select-String "csc.exe" | ForEach-Object {
        $csc = $_.Line -replace "^Executing command:\s+(.+)$", "`$1 $assemblyInfo"

        Invoke-Expression $csc -Verbose
        if ($LASTEXITCODE) {
            throw "csc execution failed"
        }
    }
}



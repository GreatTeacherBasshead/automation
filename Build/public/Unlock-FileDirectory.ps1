function Unlock-FileDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $path
    )

    [Diagnostics.Process[]]$process = Get-Process | Where-Object {
        $_.Modules.FileName -like "$path*"
    }

    if ($process.Count -eq 0) {
        "`nNobody uses '$path'"
        return
    }

    "`nProcesses which are using '$path':" | Write-Output
    $process | Write-Output

    Stop-Process -InputObject $process -Force -PassThru
}



function Wait-VmAccessibility {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $computerName,

        # Command execution timeout in minutes. Should be between 1 and 60.
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 60)]
        [int]
        $timeout = 10
    )

    $path = "\\$computerName\c$"

    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    do {
        $computerIsUp = Test-Path $path
        Write-Progress -Activity "Waiting until $computerName is available" -Status "..." -PercentComplete "-1" -SecondsRemaining "-1"

        if ($timer.Elapsed.Minutes -gt $timeout) {
            "Operation is terminated by timeout ($timeout minutes)`n" | Write-Error
            return
        }
    }
    until ($computerIsUp)

    "$computerName is up`n" | Write-Output
}



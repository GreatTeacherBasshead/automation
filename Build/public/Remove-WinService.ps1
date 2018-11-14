function Remove-WinService {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $serviceName,

        [Parameter(Position = 1, Mandatory = $false)]
        [string]
        $computerName = "."
    )

    Begin {
        $errorAction = $PSBoundParameters["ErrorAction"]
        if (!$errorAction) {
            $errorAction = $ErrorActionPreference
        }
    }

    Process {
        $serviceName | ForEach-Object {
            $service = Get-WmiObject -Class Win32_Service -Filter "Name='$_'" -ComputerName $computerName -ErrorAction $errorAction
            if ($service) {
                $service.Delete()
            }
            else {
                "Service '$_' on [$computerName] does not exists" | Write-Output
            }
        }
    }
}



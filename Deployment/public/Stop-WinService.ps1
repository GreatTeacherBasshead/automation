function Stop-WinService {
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
            $script = {
                param($name)

                Stop-Service -Name $name -Force -PassThru |
                    Tee-Object -Variable service

                if ($service.Status -ne "Stopped") {
                    $processName = $service.Name + ".exe"
                    Stop-Process -Name $processName -Force -PassThru
                }
            }

            Invoke-Command -ComputerName $computerName -ScriptBlock $script -ArgumentList $_ -Verbose -ErrorAction $errorAction
        }
    }
}



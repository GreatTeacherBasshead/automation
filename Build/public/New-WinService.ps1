function New-WinService {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $serviceName,

        [Parameter(Position = 1, Mandatory = $false)]
        [string]
        $computerName = ".",

        # The path to the executable file for the service
        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $binPath,

        # Sets the startup type of the service
        [Parameter(Position = 3, Mandatory = $false)]
        [string]
        $startType = "Manual"
    )

    Begin {
        $errorAction = $PSBoundParameters["ErrorAction"]
        if (!$errorAction) {
            $errorAction = $ErrorActionPreference
        }
    }

    Process {
        $serviceName | ForEach-Object {
            $winServiceName = $_

            $serviceExists = Get-Service -Name $_ -ComputerName $computerName -ErrorAction SilentlyContinue
            if ($serviceExists) {
                "Windows service '$winServiceName' on [$computerName] exists" | Write-Output
                return
            }

            $script = {
                param($name, $binPath, $startType)
                New-Service -Name $name -BinaryPathName $binPath -StartupType $startType -Verbose
            }

            Invoke-Command -ComputerName $computerName -ScriptBlock $script -ArgumentList $winServiceName, $binPath, $startType -Verbose -ErrorAction $errorAction
        }
    }
}



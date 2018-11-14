function Get-CustomerFab {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        # Customer's fab (${bamboo.deploy.environment})
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $targetHost
    )

    $customer = [PSCustomObject]@{
        Name = $targetHost -replace "(.+)\.(.+)", '$1'
        Fab  = $targetHost -replace "(.+)\.(.+)", '$2'
    }

    $customer | Write-Output
}



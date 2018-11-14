function Remove-CustomerSpecificFiles {
    [CmdletBinding()]
    param(
        # Target host (${bamboo.deploy.environment}, SKhynix.M10)
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment,

        # Working directory
        [Parameter(Position = 1, Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir,

        # Additional files to exclude (done for Samsung)
        [Parameter(Position = 2)]
        [string]
        $excludeExtra
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    $customer = Get-CustomerFab -targetHost $environment
    $include = "Q.O.Customer.*", "Q.MassContextImporter.Customer.*"
    $exclude = "Q.O.Customer.$($customer.Name).dll", "Q.O.Customer.Common.dll", "Q.MassContextImporter.Customer.$($customer.Name).dll", $excludeExtra

    if ($customer.Name -ne "Q") {
        Remove-Item -Path $workingDir\DataImport\* -Include $include -Exclude $exclude -Verbose -ErrorAction $errorAction
        Remove-Item -Path $workingDir\MassContextImporter\* -Include $include -Exclude $exclude -Verbose -ErrorAction $errorAction

        Get-ChildItem -Path $workingDir\Database\Customers -Exclude $customer.Name -Directory | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -Verbose -ErrorAction $errorAction
        }
    }
}



function Clear-DataImportModulesConfig {
    [CmdletBinding()]
    param (
        # Target host (${bamboo.deploy.environment}, SKhynix.M10)
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $environment,

        # Working directory
        [Parameter(Mandatory=$false)]
#        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir
    )
<#
    $customer = Get-CustomerFab -targetHost $environment
    if ($customer.Name -eq "Q") {
        "Skip modules cleanup" | Write-Host
        return
    }

    $config = Join-Path $workingDir "Configuration\Modules.config"
    if (!(Test-Path $config)) {
        Write-Error "DataImport modules config does not exist. '$config' was not found."
    }

    $xml = New-Object -TypeName Xml
    $xml.Load($config)

    $xml.SelectNodes("/modules/module[contains(@type,'Customer')]") |
        Where-Object {($_.type -notmatch $customer.Name) -and ($_.type -notmatch "CommonModule")} |
        ForEach-Object {$_.ParentNode.RemoveChild($_)
    }

    $xml.Save($config)
#>
    $customer = Get-CustomerFab -targetHost $environment
"name: " + $customer.Name
"name: " + $customer.Fab
}

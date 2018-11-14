function Update-NugetPackageForDatabase {
    [CmdletBinding()]
    param (
        # Q.O.Database.5.40.2.nupkg
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $package,

        # Database package config
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $config
    )

    $pkgObj = Get-NugetPackageObject -name $package

    $xml = New-Object -TypeName xml
    $xml.Load($config)
    $xml.SelectSingleNode("/packages/package[@id='$($pkgObj.Id)']").Attributes["version"].Value = $pkgObj.Version
    $xml.Save($config)
}



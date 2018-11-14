function Get-NugetVersion {
    param (
        # Nuget supports only 3 octets: x.x.x. We have 4: product version + build version.
        # E.g. 5.4.0.3479. The package version will be: 5.40.3479
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Version]
        $version
    )

    $newMinor = [System.String]::Concat($version.Minor, $version.Build)
    [System.Version]"$($version.Major).$newMinor.$($version.Revision)"
}



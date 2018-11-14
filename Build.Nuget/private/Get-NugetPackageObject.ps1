function Get-NugetPackageObject {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        # Package file name
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $name
    )

    if ($name -is [System.IO.FileInfo]) {
        $name = $name.Name
    }

    if ($name -isnot [System.String]) {
        $name = $name.ToString()
    }

    # Q.O.LotSelection.Client.Test.5.40.3489.nupkg
    # Q.O.Core.10.100.1.nupkg
    # Q.Charts.Core.5.40.1655.nupkg
    $regex = "^(?<PackageId>Q\..+)\.(?<PackageVersion>\d{1,2}\.\d{2,3}\.\d{1,5})\.nupkg$"

    if ($name -match $regex) {
        $package = [PSCustomObject]@{
            Id      = $Matches.PackageId
            Version = $Matches.PackageVersion
        }
    }
    else {
        throw "Can not parse nuget package name: $name"
    }

    Write-Output $package
}



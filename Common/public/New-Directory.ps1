function New-Directory {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $computer,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $directory
    )

    if ($computer) {
        if (!(Test-Connection $computer -Quiet)) {
            Write-Error "`nRemote computer `'$computer`' does not respond"
        }

        $networkPath = [System.IO.Path]::Combine("\\", $computer, ($directory -replace ":", '$'))
        if (Test-Path $networkPath) {
            Remove-Item $networkPath -Recurse -Force
        }
        New-Item $networkPath -ItemType Directory
    }
    else {
        if (Test-Path $directory) {
            Remove-Item $directory -Recurse -Force
        }
        New-Item $directory -ItemType Directory
    }
}

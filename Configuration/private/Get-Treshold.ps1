function Get-Treshold {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $path
    )

    Write-Verbose "Executing 'Get-Treshold'"

    $tresholdFileName = "Zipsdone.txt"
    $treshold = Join-Path $path $tresholdFileName

    $tresholdExists = Test-Path $treshold
    if (!$tresholdExists) {
        Write-Warning "`nTreshold file was not found. `n$treshold does not exist. It will be created now." -WarningAction Continue
        New-Item -Path $treshold -ItemType File | Write-Verbose
    }

    $treshold | Write-Output
}


function Get-LastZip {
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $path
    )

    Write-Verbose "Executing 'Get-LastZip'"

    $mask = "*.zip"
    $zip = Get-ChildItem -Path $path -Filter $mask |
        Sort-Object CreationTime |
        Select-Object -Last 1

    if ($zip.Length -eq 0) {
        Write-Error "'$path' does not contain $mask files"
        exit
    }

    $zip.FullName | Write-Output
}



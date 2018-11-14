function Test-Obfuscation {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $path
    )

    <#
    can't use this approach, because the assemblies are being locked by this PowerShell session

    if ($path -is [System.IO.FileInfo]) {
        $attributes = [System.Reflection.Assembly]::LoadFrom($path.FullName).GetCustomAttributes($false).TypeId.Name
        if ($attributes.Contains("DotfuscatorAttribute")) {
            Write-Verbose $path.FullName
            $result = $true
        }
    }
    #>

    $result = $false

    $content = Get-Content -Path $path -Raw
    if ($content -match "DotfuscatorAttribute") {
        $result = $true
    }

    Write-Output $result
}

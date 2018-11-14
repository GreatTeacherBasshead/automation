#TODO: remove the function form here, after Client is obfuscated in CI Suite (after removing precompilation symbols)
function Test-Obfuscation {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $path
    )

    $result = $false

    $content = Get-Content -Path $path -Raw
    if ($content -match "DotfuscatorAttribute") {
        $result = $true
    }

    Write-Output $result
}

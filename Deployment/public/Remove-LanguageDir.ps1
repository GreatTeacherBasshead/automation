function Remove-LanguageDir {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $path,

        # Folders to be preserved
        [Parameter(Mandatory = $false, Position = 1)]
        [string[]]
        $exclude = @("Configuration", "x64", "x86")
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    Get-ChildItem $path -Directory -Exclude $exclude | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force -Verbose -ErrorAction $errorAction
    }
}



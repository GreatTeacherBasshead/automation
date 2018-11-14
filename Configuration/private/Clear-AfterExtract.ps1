<#
Archive can have structure as follow:
1) *.zip\Q\O
2) *.zip\O
If it contains 'Q' directory, after extraction the files must be copied to proper directories and 'Q' must be deleted.
#>
function Clear-AfterExtract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $path
    )

    $errorAction = $PSBoundParameters["ErrorAction"]
    if (!$errorAction) {
        $errorAction = $ErrorActionPreference
    }

    Write-Verbose "Executing 'Clear-AfterExtract'"

    $qDir = Join-Path $path "Q"
    $qExists = Test-Path $qDir
    if (!$qExists) {
        return
    }

    "Copy files from $qDir to $path" | Write-Host
    Copy-Recursive -src $qDir -dest $path -passThru $false -ErrorAction $errorAction

    "Delete $qDir" | Write-Host
    Remove-Item -Path $qDir -Recurse -Force
}


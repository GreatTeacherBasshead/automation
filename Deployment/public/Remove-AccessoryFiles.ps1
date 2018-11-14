function Remove-AccessoryFiles {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( {Test-Path $_})]
        [string[]]
        $directory,

        [Parameter(Position = 1, Mandatory = $false)]
        [string[]]
        $filter = @("*.pdb", "*.xml", "*.dll.config")
    )

    Begin {
        $errorAction = $PSBoundParameters["ErrorAction"]
        if (!$errorAction) {
            $errorAction = $ErrorActionPreference
        }
    }

    Process {
        $directory | ForEach-Object {
            Get-ChildItem -Path $_ -Include $filter -Recurse | ForEach-Object {
                Remove-Item $_.FullName -Force -Verbose -ErrorAction $errorAction
            }
        }
    }
}



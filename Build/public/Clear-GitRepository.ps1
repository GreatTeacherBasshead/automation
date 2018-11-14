function Clear-GitRepository {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $repoPath
    )

    $gitDir = Join-Path $repoPath ".git"
    $gitDirExists = Test-Path $gitDir
    if ($gitDirExists) {
        $git = Join-Path $env:ProgramFiles "Git\bin\git.exe"
        Set-Location $repoPath

        . $git reset --hard
        . $git clean -df
    }
    else {
        Remove-Item $repoPath -Recurse -Force
    }
}



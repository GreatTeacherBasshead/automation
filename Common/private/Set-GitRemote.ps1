function Set-GitRemote ($originExists) {
    [bool]$success = $true

    if ($originExists) {
        Write-Verbose "Change URL for the remote to '$repoUrl'"
        . $git remote set-url origin $repoUrl | Write-Host
    }
    else {
        Write-Verbose "Add a remote '$repoUrl' for the repository"
        . $git remote add origin $repoUrl | Write-Host
    }

    if ($LASTEXITCODE) {
        Write-Error "Remote was not defined"
        $success = $false
    }

    $success | Write-Output
}


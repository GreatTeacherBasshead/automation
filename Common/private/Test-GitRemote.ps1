function Test-GitRemote {
    Write-Verbose "List references in origin"
    $originExists = $false

    . $git ls-remote origin | Write-Host
    if ($LASTEXITCODE -eq 0) {
        $originExists = $true
    }

    $originExists | Write-Output
}


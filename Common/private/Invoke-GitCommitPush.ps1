function Invoke-GitCommitPush {
    [CmdletBinding()]
    param(
        # State of local repository
        [Parameter(Mandatory)]
        [int]
        $localRepositoryIsAhead,

        # Commit message
        [Parameter()]
        [string]
        $message = "Bamboo commit"
    )

    $success = $true

    if ($localRepositoryIsAhead) {
        "Commit..."
        . $git commit --all --message $message

        "Push..."
        . $git pull origin $branchName
        . $git push --set-upstream origin $branchName
        . $git push
    }
    else {
        "Nothing to commit"
    }

    if ($LASTEXITCODE) {
        Write-Error "Commit/Push failed"
        $success = $false
    }

    $success | Write-Output
}



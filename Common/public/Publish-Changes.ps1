function Publish-Changes {
    [CmdletBinding()]
    param(
        # Repository directory (which contains '.git' directory)
        [Parameter(Mandatory)]
        [ValidateScript( {
                if (Test-Path (Join-Path $_ ".git")) {
                    $true
                }
                else {
                    throw "$_ is not a git-repository."
                }
            })]
        [string]
        $repoPath,

        # Repository URL (Bamboo does checkout w/o linking to a remote, so this parameter is used to create a link to a remote repository)
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $repoUrl,

        # Branch name (Bamboo does checkout w/o linking to a remote, so this parameter is for using a proper branch during pull/push; ${bamboo.planRepository.branch})
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $branchName,

        # Commit message
        [Parameter()]
        [string]
        $commitMessage
    )

    Write-Verbose "Executing 'Publish-Changes'"

    $git = Join-Path $env:ProgramFiles "Git\bin\git.exe"
    if (!(Test-Path $git)) {
        Write-Error "`n$git does not exist"
        return 1
    }

    Push-Location
    Set-Location $repoPath

    $originExists = Test-GitRemote
    $originSetup = Set-GitRemote $originExists
    if (!$originSetup) {
        return 1
    }

    $status = Add-Changes
    $changesCommitedAndPushed = Invoke-GitCommitPush -localRepositoryIsAhead $status -message $commitMessage
    if (!$changesCommitedAndPushed) {
        return 1
    }

    Pop-Location
}


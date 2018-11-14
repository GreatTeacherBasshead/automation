function Update-ConfigRepository {
    [CmdletBinding()]
    param (
        # Target hosts (aka customer fabs: SKhynix.M10)
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $environment = $environmentWithConfigsAvailable,

        # Root folder that contains archived configs for all customers
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $src,

        # Absolute path to 'Configuration' repository, 'InstalledOnTarget' directory;
        # Parent directory must contain '.git' directory
        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateScript( {
                $gitDir = Join-Path $_ "..\.git"
                $gitDirExists = Test-Path $gitDir
                if ($gitDirExists) {
                    $true
                }
                else {
                    throw "$_ is not a git-repository."
                }
            })]
        [string]
        $configurationRepoPath,

        # User name to access 'Customer Operations' JIRA project
        [Parameter()]
        [string]
        $jiraUserName = "BambooMonitor",

        # Encoded password (${bamboo.BambooMonitorEncodedPassword})
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $jiraUserPass,

        # Encryption key (${bamboo.EncryptionKey})
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $encryptionKey
    )

    begin {
        $errorAction = $PSBoundParameters["ErrorAction"]
        if (!$errorAction) {
            $errorAction = $ErrorActionPreference
        }
    }

    process {
        $environment | ForEach-Object {
            $env = $_
            Write-Verbose "Processing $env"

            $customer = Get-CustomerFab -targetHost $env

            $zipPath = [System.IO.Path]::Combine($src, $customer.Name, $customer.Fab)
            if (!(Test-Path $zipPath)) {
                Write-Error "`nDirectory with config archives was not found. `n$zipPath does not exist."
                exit
            }

            $fabPath = [System.IO.Path]::Combine($configurationRepoPath, $customer.Name, $customer.Fab)
            if (!(Test-Path $fabPath)) {
                Write-Error "`nTarget configs directory was not found. `n$fabPath does not exist."
                exit
            }

            $zip = Get-LastZip $zipPath
            $treshold = Get-Treshold $fabPath

            $zipWasProcessed = Select-String -Path $treshold -Pattern $zip -SimpleMatch -Quiet
            if ($zipWasProcessed) {
                "Skip $zip. It was already processed earlier." | Write-Host
                return
            }

            "`nExtract $zip to $fabPath" | Write-Host
            Expand-Archive -Path $zip -DestinationPath $fabPath -Force -ErrorAction $errorAction
            Clear-AfterExtract $fabPath -ErrorAction $errorAction

            $date = Get-Date -Format G
            "$date`t`t$zip" | Tee-Object $treshold -Append

            Add-ConfigVersion -configDir $fabPath -version $configVersionStagingManager.$env

            $jiraUserCred = Get-UserCred -user $jiraUserName -pass $jiraUserPass -key $encryptionKey
            $issueKey = Get-JiraIssue -filter "'Epic Name'=$env" -credential $jiraUserCred
            $message = $issueKey + " Configs auto update"
            $configurationRepoRoot = [System.IO.Directory]::GetParent($configurationRepoPath).FullName
            Publish-Changes -repoPath $configurationRepoRoot -repoUrl "https://bitbucket.q.com/scm/o/configuration.git" -branchName "master" -commitMessage $message
        }
    }
}

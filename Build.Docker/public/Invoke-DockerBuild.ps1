function Invoke-DockerBuild {
    [CmdletBinding(DefaultParametersetName = "Local")]
    param (
        # Docker host
        [Parameter(ParameterSetName = "Remote")]
        [ValidateScript( {Test-Connection $_ -Quiet})]
        [string]
        $computerName,

        # The branchname is used in Docker working directory path (${bamboo.planRepository.branch})
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $branch,

        # User name for connecting to Docker host
        [Parameter(ParameterSetName = "Remote")]
        [ValidateNotNullOrEmpty()]
        [string]
        $user = "$env:USERDOMAIN\$env:USERNAME",

        # Encrypted user password for connecting to Docker host (${bamboo.BambooUserEncodedPassword})
        [Parameter(ParameterSetName = "Remote")]
        [ValidateNotNullOrEmpty()]
        [string]
        $pass,

        # Encryption key (${bamboo.EncryptionKey})
        [Parameter(ParameterSetName = "Remote")]
        [ValidateNotNullOrEmpty()]
        [string]
        $encryptionKey
    )

    $branch = $branch -replace "[\\/]", '-'
    $dockerDir = Join-Path "D:\DockerBuild" $branch
    $dockerWorkingDir = New-Directory -computer $computerName -directory $dockerDir

    Copy-Item -Path $PSCommandPath, "$PSScriptRoot\Docker\Dockerfile", "\\qnas02\install\DSL\CodeMeter\Runtime\CodeMeterRuntime64.msi", "D:\Install\Matlab\MCR2017b", "$env:windir\System32\mapi32.dll" -Destination $dockerWorkingDir -Recurse -Force

    $tag = "q/o:$branch"

    switch ($PsCmdLet.ParameterSetName) {
        "Local" {
            Update-ContainerBaseImage -dockerFile (Join-Path $dockerDir "Dockerfile")
            Build-ContainerImage -dockerFile (Join-Path $dockerDir "Dockerfile") -tag $tag -context $dockerDir
        }
        "Remote" {
            $cred = Get-UserCred -user $user -pass $pass -key $encryptionKey
            $scripts = Split-Path $PSCommandPath -Leaf

            Invoke-Command -ComputerName $computerName -Authentication Credssp -Credential $cred -ScriptBlock {
                param($scripts, $dockerDir, $tag)
                # suppress the injection error (..\Common\CommonScripts.ps1 is not used here)
                . (Join-Path $dockerDir $scripts) 2>$null
                Update-ContainerBaseImage -dockerFile (Join-Path $dockerDir "Dockerfile")
                Build-ContainerImage -dockerFile (Join-Path $dockerDir "Dockerfile") -tag $tag -context $dockerDir
            } -ArgumentList $scripts, $dockerDir, $tag
        }
    }
}



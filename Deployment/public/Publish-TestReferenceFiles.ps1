function Publish-TestReferenceFiles {
    [CmdletBinding()]
    param (
        # Working directory (${bamboo.build.working.directory})
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir,

        # Configuration repository path
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $repoPath,

        # Deployment project name is used for locating a proper destination folder (${bamboo.deploy.project})
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $version
    )

    $files = `
    (Join-Path $workingDir "Suite\Sources\bin\Client\Configuration\charts.config"),
    (Join-Path $workingDir "Suite\Sources\bin\Client\Configuration\recipeDefaults.config"),
    (Join-Path $workingDir "Suite\Sources\bin\Client\Configuration\results.config")

    $dest = "$repoPath\TestReferences\$version\Client\Configuration"

    Copy-Item -Path $files -Destination $dest -Force -PassThru
}



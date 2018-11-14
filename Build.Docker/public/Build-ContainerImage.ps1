function Build-ContainerImage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateScript( {Test-Path $_})]
        [string]
        $dockerFile = "Dockerfile",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $tag,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $context = "."
    )

    try {
        Get-Command docker -ErrorAction "Stop"
    }
    catch {
        Write-Error "`nDocker was not found`n"
        throw
    }

    docker build --file $dockerFile --tag $tag $context
    if ($LASTEXITCODE) {
        Write-Error "`nDocker build failed`n"
    }
}



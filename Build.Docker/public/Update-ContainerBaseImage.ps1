function Update-ContainerBaseImage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateScript( {Test-Path $_})]
        [string]
        $dockerFile = "Dockerfile"
    )

    try {
        Get-Command docker -ErrorAction "Stop"
    }
    catch {
        Write-Error "`nDocker was not found`n"
        throw
    }

    $matched = (Get-Content $dockerFile -Raw) -match "FROM\s+(?<Image>.+)"
    if ($matched) {
        $baseImageName = $Matches.Image.Trim()
    }
    else {
        throw "Base docker image was not found in $dockerFile"
    }

    docker pull $baseImageName
    if ($LASTEXITCODE) {
        Write-Error "`nDocker pull failed`n"
    }
}



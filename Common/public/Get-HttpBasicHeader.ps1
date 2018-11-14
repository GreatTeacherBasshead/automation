function Get-HttpBasicHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $credential
    )

    $user = $credential.UserName
    $pass = $credential.GetNetworkCredential().Password

    $bytes = [System.Text.Encoding]::UTF8.GetBytes("${user}:$pass")
    $base64 = [System.Convert]::ToBase64String($bytes)

    $headers = @{
        Authorization       = "Basic $base64"
        "X-Atlassian-Token" = "nocheck"
    }

    $headers | Write-Output
}



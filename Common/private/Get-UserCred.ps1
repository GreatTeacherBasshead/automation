function Get-UserCred {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $user,

        # Encoded password
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $pass,

        # String representation of encryption key (comma separated array of bytes)
        [Parameter()]
        [string]
        $key
    )

    if ($key) {
        [byte[]]$key = $key -split ",\s*"
        $securePassword = ConvertTo-SecureString $pass -Key $key
    }
    else {
        $securePassword = ConvertTo-SecureString $pass
    }

    New-Object -TypeName pscredential -ArgumentList $user, $securePassword | Write-Output
}



function Protect-String {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Input string
        [Parameter(Mandatory)]
        [string]
        $string,

        # String representation of encryption key (comma separated array of bytes)
        [Parameter()]
        [string]
        $key
    )

    $secureString = ConvertTo-SecureString -String $string -AsPlainText -Force

    if ($key) {
        [byte[]]$key = $key -split ",\s*"
        $encryptedString = ConvertFrom-SecureString -SecureString $secureString -Key $key
    }
    else {
        $encryptedString = ConvertFrom-SecureString -SecureString $secureString
    }

    Write-Output $encryptedString
}



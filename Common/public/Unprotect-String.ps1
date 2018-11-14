function Unprotect-String {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Encrypted string
        [Parameter(Mandatory)]
        [string]
        $string,

        # String representation of encryption key (comma separated array of bytes)
        [Parameter()]
        [string]
        $key
    )

    if ($key) {
        [byte[]]$key = $key -split ",\s*"
        $secureString = ConvertTo-SecureString $encrypted -Key $key
    }
    else {
        $secureString = ConvertTo-SecureString $encrypted
    }

    $string = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))

    Write-Output $string
}



function Switch-DbNameOnRemote {
    [CmdletBinding()]
    param(
        # Database name shortcut (${bamboo.Db}). Approved names are: MF2, MF6, MF10, SKHR3, RT, PLT.
        [Parameter(Mandatory)]
        [ValidateSet("MF2", "MF6", "MF10", "SKHR3", "RT", "PLT")]
        [string]
        $database,

        # Computer name, where O.Server is set up. Assumed 'C:\Q\O\Server' exists on this machine.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $computerName
    )

    $config = "\\$computerName\C$\Q\O\Server\Configuration\dataAccess.config"
    if (Test-Path $config) {
        Write-Verbose "`nChanging `'$config`' file"
    }
    else {
        throw "`nThere is no `'$config`' file"
    }

    # should be in sync with ValidateSet
    $lookup = @{
        "MF2"   = "O_MF2_5.3.0"
        "MF6"   = "O_MF6_5.3.0"
        "MF10"  = "O_MF10_5.3.0"
        "SKHR3" = "O_SKHR3_5.3.0"
        "RT"    = "O_RT_5.3.0_QVM03"
        "PLT"   = "O_PLT_5.3.0"
    }

    Set-DbName -path $config -xPath "/dataAccess" -dbName $lookup[$database]
}



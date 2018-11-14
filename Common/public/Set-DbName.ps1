function Set-DbName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $path,

        # Path to a node containing 'connectionString' attribute
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $xPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $dbName
    )

    Begin {
        $xml = New-Object -TypeName XML
    }

    Process {
        $path | ForEach-Object {
            $config = $_
            if (!(Test-Path $config)) {
                Write-Warning "`n`'$config`' does not exist"
                return
            }

            $xml.Load($config)
            $node = $xml.SelectSingleNode($xPath)

            if ($node.Count -eq 0) {
                Write-Error "`n`'$xPath`' node was not found"
                return
            }

            $sb = New-Object -TypeName System.Data.Common.DbConnectionStringBuilder
            $sb.set_ConnectionString($node.connectionString)
            $sb.'Initial Catalog' = $dbName

            Write-Verbose "Old connectionString= $($node.connectionString)"
            Write-Verbose "New connectionString= $($sb.ConnectionString)"

            $node.connectionString = $sb.ConnectionString
            $xml.Save($config)
        }
    }
}



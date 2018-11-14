function Set-XPath {
    [CmdletBinding()]
    param(
        # File absolute pathes
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( {Test-Path $_})]
        [string[]]
        $file,

        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $xpath,

        [Parameter(Position = 2, Mandatory = $false)]
        [string]
        $value = ""
    )

    Begin {
        $xml = New-Object -TypeName XML
    }

    Process {
        foreach ($item in $file) {
            "Loading '$item'..." | Write-Verbose

            $xml.Load($item)
            $node = $xml.SelectSingleNode($xpath)

            if (($node -eq $null) -or ($node.Count -eq 0)) {
                Write-Error "XPath '$xpath' was not found"
            }

            if ($node.NodeType -eq "Attribute") {
                $node.set_Value($value)
            }
            elseif ($node.NodeType -eq "Element") {
                $node.InnerXml = $value
            }
            else {
                $node.Value = $value
            }

            $xml.Save($item)
        }
    }
}


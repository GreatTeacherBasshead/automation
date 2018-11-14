function Set-CodemeterConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        $config,

        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        $dll
    )

    $xml = New-Object -TypeName XML
    $xml.Load($config)

    $outDll = [System.IO.Path]::Combine((Split-Path $dll -Parent), "protected", (Split-Path $dll -Leaf))
    $outDllNode = $xml.CreateElement("Command")
    $outDllText = $xml.CreateTextNode("-o:$outDll")
    $outDllNode.AppendChild($outDllText)
    $xml.AxProtectorNet.CommandLine.AppendChild($outDllNode)

    $inDllNode = $xml.CreateElement("Command")
    $inDllText = $xml.CreateTextNode($dll)
    $inDllNode.AppendChild($inDllText)
    $xml.AxProtectorNet.CommandLine.AppendChild($inDllNode)

    $xml.Save($config)
}



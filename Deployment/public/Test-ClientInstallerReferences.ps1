function Test-ClientInstallerReferences {
    [CmdletBinding()]
    param(
        # Absolute path to 'Q.O.Client.Installer' folder
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $wxsPath
    )

    Set-Location $wxsPath
    $wxs = Join-Path $wxsPath "Product.wxs"

    $xml = New-Object -TypeName XML
    $xml.Load($wxs)
    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns.AddNamespace("ns", $xml.DocumentElement.NamespaceURI)

    $invalidPaths = New-Object -TypeName System.Collections.ArrayList
    $xml.SelectNodes("/ns:Wix/ns:Product/ns:DirectoryRef/ns:Component/ns:File/@Source", $ns).Value | ForEach-Object {
        $file = $_
        if (!(Test-Path $file)) {
            $invalidPaths.Add($file) | Write-Verbose
            Write-Warning "'$file' does not exist"
        }
    }

    Write-Output $invalidPaths
}



function Test-ClientInstallerFiles {
    [CmdletBinding()]
    param(
        # Absolute path to 'Q.O.Client.Installer' folder
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $wxsPath,

        # Absolute path to Client binaries folder
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $clientPath,

        # Which files to process
        [Parameter()]
        [string]
        $include = "*.dll",

        # Which files to exclude
        [Parameter()]
        [string]
        $exclude = "*DebugInternals*.dll"
    )

    Set-Location $wxsPath
    $wxs = Join-Path $wxsPath "Product.wxs"

    $xml = New-Object -TypeName XML
    $xml.Load($wxs)
    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns.AddNamespace("ns", $xml.DocumentElement.NamespaceURI)

    $filePathsAbsolute = New-Object -TypeName System.Collections.ArrayList
    $xml.SelectNodes("/ns:Wix/ns:Product/ns:DirectoryRef/ns:Component/ns:File/@Source", $ns).Value | ForEach-Object {
        $filePathsAbsolute.Add((Resolve-Path $_ -ErrorAction SilentlyContinue)) | Write-Verbose
    }

    $extraFiles = New-Object -TypeName System.Collections.ArrayList
    Get-ChildItem $clientPath -Filter $include -Exclude $exclude -Recurse -File | ForEach-Object {
        $filePath = $_.FullName
        if (!$filePathsAbsolute.Path.Contains($filePath)) {
            $extraFiles.Add($filePath) | Write-Verbose
            Write-Warning "'$filePath' is not referenced in the Client Installer project"
        }
    }

    Write-Output $extraFiles
}



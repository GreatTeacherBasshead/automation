function Set-CoreTestPorts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $sourceDir,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [int]
        $port
    )

    $tool = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\2017\Professional\Common7\IDE\TextTransform.exe"
    $str = '(const string Port = )"(\d+)";'
    $template = Join-Path $sourceDir "Core\Test\Server\Core.Server\Wcf\PortUpdater.tt"

    (Get-Content $template) -replace $str, "`$1`"$port`";" | Set-Content $template

    . $tool $template
}



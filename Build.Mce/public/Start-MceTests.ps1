function Start-MceTests {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $matlabExe = (Join-Path $env:ProgramFiles "MATLAB\R2017b\bin\matlab.exe"),

        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $mcePath,

        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $testDataPath
    )

    $testsPath = Join-Path $testDataPath "bin"
    $log = Join-Path ($testsPath -replace "\\", "/") "MatlabOutput.txt"

    if (!(Test-Path $testsPath)) {
        New-Item -Path $testsPath -ItemType Directory -Force
    }

    Write-Host "`nStarting tests execution..."
    $runTestsArgs = "-r `"try;restoredefaultpath();addpath('$mcePath');savepath();runAllTests();catch me;try;disp(getReport(me));end;end;exit`" -logfile $log -nosplash -noFigureWindows -nodesktop"
    Start-Process -FilePath $matlabExe -ArgumentList $runTestsArgs -Wait -WorkingDirectory $testDataPath
}



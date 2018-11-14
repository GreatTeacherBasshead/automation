function Edit-DbNameInConfigs {
    [CmdletBinding()]
    param(
        # Working directory (${bamboo.build.working.directory})
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_})]
        [string]
        $workingDir,

        # Database name
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $dbName
    )

    # setEnv.cmd
    # SET dbName=IT_OSuite_master_5
    # SET dbRestoreName=IT_OSuite_master_5
    $setEnv = Join-Path $workingDir "Database\setEnv.cmd"
    (Get-Content $setEnv) -replace "(SET\s+dbName=|SET\s+dbRestoreName=)(.+)", "`$1$dbName" |
        Set-Content $setEnv

    # dataAccess.config
    # <dataAccess connectionString="Data Source=QDSA06\QMSSTEST;Initial Catalog=IT_OSuite_master_5;User ID=q;Password=q;Connect Timeout=5;MultipleActiveResultSets=True;" commandTimeout="600" />
    (Join-Path $workingDir "Test\Configuration\dataAccess.config"), (Join-Path $workingDir "Server\Configuration\dataAccess.config") |
        Set-DbName -xPath "/dataAccess" -dbName $dbName

    # mapGenerator.config
    # <mapGenerator connectionString="Data Source=QDSA06\QMSSTEST;Initial Catalog=IT_OSuite_master_5;User ID=q;Password=q;Connect Timeout=5;MultipleActiveResultSets=True" tableName="output.CpeGenerated" mappingFile="C:\Q\Shared\smartCpeMapping.txt" computationResultDirectory="C:\Q\Data\Export\Maps"/>
    Set-DbName -path (Join-Path $workingDir "Server\Configuration\mapGenerator.config") -xPath "/mapGenerator" -dbName $dbName
}



function Add-Changes {
    Write-Verbose "Add changes to index"
    . $git add . | Write-Host

    Write-Verbose "Check if there are new changes"
    . $git diff-index --quiet HEAD

    $LASTEXITCODE | Write-Output
}


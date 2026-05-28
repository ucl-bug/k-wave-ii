$n_html = (Get-ChildItem -Path "docs/helpfiles/" -Filter "*.html" -Recurse).Count
if ($n_html -eq 0) {
    Write-Output "No html help files were generated"
    return 1
}

$n_md = (Get-ChildItem -Path "docs/helpfilesweb/" -Filter "*.md" -Recurse | Where-Object { $_.Name -notlike "SUMMARY*" }).Count
if ($n_md -eq 0) {
    Write-Output "No md documentation files were generated"
    return 1
}

if ($n_html -ne $n_md) {
    Write-Output "Number of html and md help files generated are not equal: $n_html vs $n_md"
    return 1
}

Write-Output "$n_html html files generated, $n_md md files generated"

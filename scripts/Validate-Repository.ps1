#Requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$checked=0
$files=@(Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object { $_.FullName -notmatch '\\(\.git|dist|test-results|bin)\\' })
foreach($file in $files | Where-Object Extension -eq '.md') {
    $body=Get-Content -LiteralPath $file.FullName -Raw
    if($body -match '\u2014'){throw "Em dash in documentation: $($file.FullName)"}
    foreach($match in [regex]::Matches($body,'\]\(([^)]+)\)')) {
        $target=$match.Groups[1].Value.Trim('<','>')
        if($target -match '^(https?://|#|mailto:)'){continue}
        $path=Join-Path $file.DirectoryName (($target -split '#')[0])
        if(!(Test-Path -LiteralPath $path)){throw "Broken Markdown link in $($file.Name): $target"}
        $checked++
    }
}
foreach($file in $files | Where-Object Extension -in '.ps1','.psm1','.cs','.py','.md','.yml','.json') {
    $body=Get-Content -LiteralPath $file.FullName -Raw
    # Only reject concrete Windows user-directory literals, not $HOME examples.
    if($body -match '(?i)[A-Z]:\\Users\\[A-Za-z0-9_. -]+\\'){throw "Personal Windows path in $($file.FullName)"}
}
$tracked=@(& git -C $root ls-files)
if($LASTEXITCODE -ne 0){throw 'git ls-files failed.'}
foreach($path in $tracked){
    if($path -match '(^|/)(\.state|bin|dist|test-results)(/|$)' -or $path -match '\.(exe|log)$'){throw "Generated or private file tracked: $path"}
}
Write-Output "PASS: $checked relative documentation links; no concrete user paths or tracked runtime state."

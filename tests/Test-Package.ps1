#Requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$PackagePath)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$PackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$expected = ((Get-Content -LiteralPath ($PackagePath + '.sha256') -Raw) -split '\s+')[0]
if ((Get-FileHash -LiteralPath $PackagePath -Algorithm SHA256).Hash -ine $expected) { throw 'Package checksum mismatch.' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($PackagePath)
try {
    foreach ($entry in $zip.Entries) {
        $name = $entry.FullName.Replace('\','/')
        if ([IO.Path]::IsPathRooted($name) -or $name -match '(^|/)(\.git|\.state|test-results|sunbeam-kitty)(/|$)' -or $name -match '(^|/)\.\./') { throw "Unexpected package entry: $name" }
    }
} finally { $zip.Dispose() }
$scratchRoot = Join-Path $root 'test-results'
$scratch = Join-Path $scratchRoot ('Package-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $scratch -Force | Out-Null
try {
    [IO.Compression.ZipFile]::ExtractToDirectory($PackagePath,$scratch)
    Import-Module (Join-Path $scratch 'scripts\CozyDesktop.psm1') -Force
    if ((Get-CozyConfig).Theme -ne 'starter') { throw 'Release package must select Starter.' }
    $null = Assert-CozyAssets
    foreach($file in 'Install.ps1','START-HERE.md','README.md','LICENSE','THIRD_PARTY_NOTICES.md','bin\CozyDesktop.exe','scripts\Reset.ps1','docs\SAFETY.md') {
        if (!(Test-Path -LiteralPath (Join-Path $scratch $file))) { throw "Package is missing $file" }
    }
    & (Join-Path $scratch 'scripts\Build.ps1')
    Write-Output 'PASS: package checksum, contents, Starter assets and extracted launcher build.'
} finally {
    $resolved = [IO.Path]::GetFullPath($scratch)
    if (!$resolved.StartsWith(([IO.Path]::GetFullPath($scratchRoot).TrimEnd('\')+'\'),[StringComparison]::OrdinalIgnoreCase) -or (Split-Path $resolved -Leaf) -notlike 'Package-*') { throw 'Unsafe package-test cleanup path.' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}

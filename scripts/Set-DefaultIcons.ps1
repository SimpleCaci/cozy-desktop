#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param([switch]$IncludeFolders)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'CozyDesktop.psm1') -Force
$null = Assert-CozyAssets
if ($PSCmdlet.ShouldProcess('Current user shell icons', 'Theme Recycle Bin, This PC, Network, user files and Libraries')) {
    Invoke-CozyLocked {
        Set-CozyIcons
        if ($IncludeFolders) { Set-CozyKnownFolders }
    }
}

#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$Path,
    [ValidatePattern('^[a-zA-Z0-9_-]+$')][string]$Icon = 'blue'
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'CozyDesktop.psm1') -Force
if ($PSCmdlet.ShouldProcess($Path, "Set $Icon folder icon and back up desktop.ini")) { Invoke-CozyLocked { Set-CozyFolder $Path $Icon } }

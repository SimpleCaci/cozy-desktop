#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param()
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'CozyDesktop.psm1') -Force
if ($PSCmdlet.ShouldProcess('Current user appearance', 'Remove Cozy Desktop task/buttons and restore backed-up appearance')) {
    Invoke-CozyLocked { Restore-CozyDesktop }
}

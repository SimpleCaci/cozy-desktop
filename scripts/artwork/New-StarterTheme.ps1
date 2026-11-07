#Requires -Version 5.1
[CmdletBinding()]
param([string]$OutputPath = '')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
if (!$OutputPath) { $OutputPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'themes\starter' }
$OutputPath = [IO.Path]::GetFullPath($OutputPath)
foreach ($folder in 'icons','wallpapers') { New-Item -ItemType Directory -Path (Join-Path $OutputPath $folder) -Force | Out-Null }
function Color([string]$Hex) { [Drawing.ColorTranslator]::FromHtml($Hex) }
function Brush([string]$Hex) { New-Object Drawing.SolidBrush (Color $Hex) }
function Save-Icon($Image, [string]$Path) {
    $frames = @()
    foreach ($size in 16,24,32,48,64,128,256) {
        $small = New-Object Drawing.Bitmap($size,$size)
        $g = [Drawing.Graphics]::FromImage($small)
        try {
            $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.DrawImage($Image,0,0,$size,$size)
            $stream = New-Object IO.MemoryStream
            try { $small.Save($stream,[Drawing.Imaging.ImageFormat]::Png); $frames += [pscustomobject]@{ Size=$size; Bytes=$stream.ToArray() } } finally { $stream.Dispose() }
        } finally { $g.Dispose(); $small.Dispose() }
    }
    $file = [IO.File]::Create($Path); $writer = New-Object IO.BinaryWriter($file)
    try {
        $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]$frames.Count)
        $offset = 6 + 16 * $frames.Count
        foreach ($frame in $frames) {
            $dimension = if ($frame.Size -eq 256) { 0 } else { $frame.Size }
            $writer.Write([byte]$dimension); $writer.Write([byte]$dimension); $writer.Write([uint16]0)
            $writer.Write([uint16]1); $writer.Write([uint16]32); $writer.Write([uint32]$frame.Bytes.Length); $writer.Write([uint32]$offset)
            $offset += $frame.Bytes.Length
        }
        foreach ($frame in $frames) { $writer.Write([byte[]]$frame.Bytes) }
    } finally { $writer.Dispose(); $file.Dispose() }
}
# All imagery below is drawn from geometric primitives. No image files are inputs.
foreach ($mode in 'day','night') {
    foreach ($orientation in 'landscape','portrait') {
        $w = if ($orientation -eq 'landscape') { 1920 } else { 1080 }
        $h = if ($orientation -eq 'landscape') { 1080 } else { 1920 }
        $image = New-Object Drawing.Bitmap($w,$h); $g = [Drawing.Graphics]::FromImage($image)
        $sky = if ($mode -eq 'day') { '#BCDCE8' } else { '#172D48' }
        $hill = if ($mode -eq 'day') { '#7FA8AC' } else { '#2A4C68' }
        $foreground = if ($mode -eq 'day') { '#487C83' } else { '#39677D' }
        $brushes = @((Brush $sky),(Brush $hill),(Brush $foreground),(Brush '#F3D78A'),(Brush '#FFF3D5'))
        try {
            $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $g.Clear((Color $sky))
            $diameter = [int]([math]::Min($w,$h)*0.24); $x = [int]($w*0.70); $y = [int]($h*0.14)
            $g.FillEllipse($brushes[3],$x,$y,$diameter,$diameter)
            if ($mode -eq 'night') {
                $g.FillEllipse($brushes[0],$x+[int]($diameter*0.30),$y-[int]($diameter*0.08),$diameter,$diameter)
                foreach ($point in @(@(0.14,0.18),@(0.42,0.12),@(0.55,0.35),@(0.26,0.44),@(0.89,0.47))) {
                    $sx=[int]($w*$point[0]); $sy=[int]($h*$point[1]); $g.FillEllipse($brushes[4],$sx,$sy,6,6)
                }
            }
            $g.FillEllipse($brushes[1],-[int]($w*0.3),[int]($h*0.62),[int]($w*1.5),[int]($h*0.8))
            $g.FillEllipse($brushes[2],[int]($w*0.26),[int]($h*0.76),[int]($w*1.2),[int]($h*0.65))
            $image.Save((Join-Path $OutputPath "wallpapers\$mode-$orientation.png"),[Drawing.Imaging.ImageFormat]::Png)
        } finally { $g.Dispose(); $image.Dispose(); foreach($b in $brushes){$b.Dispose()} }
    }
}
$names = @('apps','archive','archaeology','blue','yellow','navy','games','files','school','sites','downloads','pictures','music','videos','code','chat','tasks','transfer','this-pc','network','recycle-empty','recycle-full','day-night-toggle')
foreach ($name in $names) {
    $image=New-Object Drawing.Bitmap(256,256); $g=[Drawing.Graphics]::FromImage($image)
    $ink=Brush '#23455D'; $cream=Brush '#FFF3D5'; $gold=Brush '#E7C56E'
    $tone=if($name -eq 'yellow'){'#E7C56E'}elseif($name -eq 'navy'){'#547C98'}else{'#89BED0'}
    $blue=Brush $tone; $pen=New-Object Drawing.Pen((Color '#23455D'),8)
    try {
        $g.SmoothingMode=[Drawing.Drawing2D.SmoothingMode]::AntiAlias
        switch -Regex ($name) {
            '^recycle-' {
                $g.FillRectangle($blue,64,62,128,152); $g.DrawRectangle($pen,64,62,128,152)
                $g.FillRectangle($ink,54,46,148,14)
                foreach($x in 96,128,160){$g.FillRectangle($cream,$x,88,8,92)}
                if($name -eq 'recycle-full'){$g.FillRectangle($gold,83,20,39,40);$g.FillRectangle($cream,136,15,36,45)}
                break
            }
            '^network$' {
                $g.DrawEllipse($pen,75,20,106,106);$g.DrawEllipse($pen,103,20,50,106)
                $g.DrawLine($pen,77,73,179,73);$g.DrawLine($pen,128,126,128,166)
                $g.DrawLine($pen,60,166,196,166);$g.FillRectangle($blue,24,166,76,58);$g.FillRectangle($blue,156,166,76,58)
                break
            }
            '^this-pc$' {
                $g.FillRectangle($ink,28,38,200,142);$g.FillRectangle($blue,40,50,176,118)
                $g.FillRectangle($ink,113,180,30,30);$g.FillRectangle($ink,77,210,102,12); break
            }
            '^day-night-toggle$' {
                $g.FillEllipse($blue,16,16,224,224);$g.FillEllipse($gold,43,44,102,102)
                $g.FillEllipse($cream,112,112,104,104);$g.FillEllipse($blue,140,92,104,104); break
            }
            default {
                $g.FillRectangle($blue,28,57,85,45);$g.FillRectangle($blue,28,85,200,133)
                $g.DrawRectangle($pen,28,85,200,133)
                $g.FillEllipse($cream,98,116,64,64)
                if($name -eq 'downloads'){$g.FillRectangle($ink,123,126,10,28);$g.DrawLine($pen,111,149,128,165);$g.DrawLine($pen,128,165,145,149)}
                elseif($name -eq 'code'){$g.DrawLine($pen,120,131,106,147);$g.DrawLine($pen,106,147,120,163);$g.DrawLine($pen,136,131,150,147);$g.DrawLine($pen,150,147,136,163)}
                else{$g.FillEllipse($gold,116,134,28,28)}
            }
        }
        $image.Save((Join-Path $OutputPath "icons\$name.png"),[Drawing.Imaging.ImageFormat]::Png)
        Save-Icon $image (Join-Path $OutputPath "icons\$name.ico")
    } finally { $g.Dispose();$image.Dispose();$ink.Dispose();$cream.Dispose();$gold.Dispose();$blue.Dispose();$pen.Dispose() }
}
$manifest = @{
    Name='Starter'; Description='Source-drawn skies, hills and simple desktop icons.'
    Wallpapers=@{ Day=@{landscape='wallpapers/day-landscape.png';portrait='wallpapers/day-portrait.png'}; Night=@{landscape='wallpapers/night-landscape.png';portrait='wallpapers/night-portrait.png'} }
    SystemIcons=@{
        '{645FF040-5081-101B-9F08-00AA002F954E}'=@{default='icons/recycle-empty.ico';empty='icons/recycle-empty.ico';full='icons/recycle-full.ico'}
        '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'=@{default='icons/this-pc.ico'}
        '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}'=@{default='icons/network.ico'}
        '{59031A47-3F72-44A7-89C5-5595FE6B30EE}'=@{default='icons/files.ico'}
        '{031E4825-7B94-4DC3-B131-E946B44C8DD5}'=@{default='icons/archive.ico'}
    }
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $OutputPath 'theme.json') -Encoding UTF8
Write-Output "Generated source-drawn assets in $OutputPath. Rebuild the cursors separately with build-cursors.py."

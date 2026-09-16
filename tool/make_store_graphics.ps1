# Generates Play Store graphics from the Jovexa brand assets.
# Usage: powershell -File tool/make_store_graphics.ps1
Add-Type -AssemblyName System.Drawing

$root = Split-Path $PSScriptRoot -Parent
$brand = Join-Path $root "assets\brand"
$store = Join-Path $root "store"
New-Item -ItemType Directory -Force $store | Out-Null

$mark = [System.Drawing.Image]::FromFile("e:\Jovexa Labs Website\public\brand\logo-mark.png")
$bgTop = [System.Drawing.Color]::FromArgb(255, 5, 6, 15)
$bgBottom = [System.Drawing.Color]::FromArgb(255, 11, 18, 48)
$white = [System.Drawing.Color]::FromArgb(255, 240, 244, 255)
$blue = [System.Drawing.Color]::FromArgb(255, 59, 130, 246)
$cyan = [System.Drawing.Color]::FromArgb(255, 34, 211, 238)

function New-Canvas([int]$w, [int]$h) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.InterpolationMode = 'HighQualityBicubic'
    $g.TextRenderingHint = 'AntiAliasGridFit'
    $rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
    $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $bgTop, $bgBottom, 90)
    $g.FillRectangle($grad, $rect)
    $grad.Dispose()
    return @($bmp, $g)
}

# 1) 512x512 hi-res icon -------------------------------------------------
$bmp, $g = New-Canvas 512 512
$mh = 340
$mw = [int]($mark.Width / $mark.Height * $mh)
$g.DrawImage($mark, [int]((512 - $mw) / 2), [int]((512 - $mh) / 2), $mw, $mh)
$g.Dispose()
$bmp.Save((Join-Path $store "icon-512.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

# 2) 1024x500 feature graphic -------------------------------------------
$bmp, $g = New-Canvas 1024 500
# subtle cyan accent line along the bottom
$accent = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 488, 1024, 12)), $blue, $cyan, 0)
$g.FillRectangle($accent, 0, 488, 1024, 12)
$accent.Dispose()

$mh = 330
$mw = [int]($mark.Width / $mark.Height * $mh)
$g.DrawImage($mark, 90, [int]((500 - $mh) / 2) - 8, $mw, $mh)

$fTitle = New-Object System.Drawing.Font("Segoe UI", 64, [System.Drawing.FontStyle]::Bold)
$fTag = New-Object System.Drawing.Font("Segoe UI", 26, [System.Drawing.FontStyle]::Regular)
$fBy = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$bWhite = New-Object System.Drawing.SolidBrush($white)
$bBlue = New-Object System.Drawing.SolidBrush($blue)
$bCyanDim = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 148, 178, 230))

$tx = 90 + $mw + 60
$g.DrawString("Jovexa Learn", $fTitle, $bWhite, $tx, 130)
$g.DrawString("Learn code. Build skills. Create more.", $fTag, $bCyanDim, ($tx + 8), 250)
$g.DrawString("by Jovexa Labs", $fBy, $bBlue, ($tx + 8), 320)

$fTitle.Dispose(); $fTag.Dispose(); $fBy.Dispose()
$bWhite.Dispose(); $bBlue.Dispose(); $bCyanDim.Dispose()
$g.Dispose()
$bmp.Save((Join-Path $store "feature-graphic.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
$mark.Dispose()

Get-ChildItem $store -File | Select-Object Name, Length

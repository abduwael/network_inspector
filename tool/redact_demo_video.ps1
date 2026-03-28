# Blur fixed rectangles (Full URL value + Authorization/Bearer) for the whole clip.
# Requires ffmpeg in PATH. Tune Url*/Auth* if resolution or layout changes (see ffprobe on your file).
#
# Example:
#   .\tool\redact_demo_video.ps1 -InputVideo "D:\captures\raw.mp4" -OutputVideo ".\doc\demo.mp4"

param(
    [Parameter(Mandatory = $true)]
    [string] $InputVideo,
    [string] $OutputVideo = (Join-Path $PSScriptRoot "..\doc\demo.mp4"),
    [int] $UrlX = 48,
    [int] $UrlY = 420,
    [int] $UrlW = 292,
    [int] $UrlH = 86,
    [int] $AuthX = 48,
    [int] $AuthY = 712,
    [int] $AuthW = 292,
    [int] $AuthH = 114,
    [int] $BlurRadius = 18,
    [int] $BlurPower = 2
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path -LiteralPath $InputVideo)) {
    Write-Error "Input not found: $InputVideo"
}

$tmp = [System.IO.Path]::ChangeExtension($OutputVideo, ".redacting_tmp.mp4")
$vf = @"
[0:v]split[base][b1];[b1]crop=${UrlW}:${UrlH}:${UrlX}:${UrlY},boxblur=luma_radius=${BlurRadius}:luma_power=${BlurPower}[blur1];[base][blur1]overlay=${UrlX}:${UrlY}[v1];[v1]split[base2][b2];[b2]crop=${AuthW}:${AuthH}:${AuthX}:${AuthY},boxblur=luma_radius=${BlurRadius}:luma_power=${BlurPower}[blur2];[base2][blur2]overlay=${AuthX}:${AuthY}
"@

ffmpeg -y -i $InputVideo -vf $vf -c:a copy $tmp
Move-Item -LiteralPath $tmp -Destination $OutputVideo -Force
Write-Host "Wrote $OutputVideo"

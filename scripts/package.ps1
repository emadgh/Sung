param(
    [string]$QtPrefix = $env:QTDIR,
    [string]$BuildDir = "build-windows"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot "build.ps1") -QtPrefix $QtPrefix -BuildDir $BuildDir

$Build = Join-Path $Root $BuildDir
$Exe = Join-Path $Build "Release\sung.exe"
if (-not (Test-Path $Exe)) { $Exe = Join-Path $Build "sung.exe" }

$Stage = Join-Path $Root "dist\Sung"
$Zip = Join-Path $Root "dist\Sung-windows-x64.zip"
Remove-Item $Stage -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $Zip -Force -ErrorAction SilentlyContinue
New-Item $Stage -ItemType Directory -Force | Out-Null

Copy-Item $Exe (Join-Path $Stage "Sung.exe")
Copy-Item (Join-Path $Root "helper") (Join-Path $Stage "helper") -Recurse
New-Item (Join-Path $Stage "licenses") -ItemType Directory -Force | Out-Null
Copy-Item (Join-Path $Root "LICENSE") (Join-Path $Stage "licenses\LICENSE")
Copy-Item (Join-Path $Root "NOTICE") (Join-Path $Stage "licenses\NOTICE")
Copy-Item (Join-Path $Root "licenses\MaterialSymbols-LICENSE.txt") (Join-Path $Stage "licenses\MaterialSymbols-LICENSE.txt")

if (-not $QtPrefix) {
    $Qmake = Get-Command qmake6 -ErrorAction SilentlyContinue
    if (-not $Qmake) { $Qmake = Get-Command qmake -ErrorAction SilentlyContinue }
    if ($Qmake) { $QtPrefix = Split-Path -Parent (Split-Path -Parent $Qmake.Source) }
}
$WinDeployQt = if ($QtPrefix) { Join-Path $QtPrefix "bin\windeployqt.exe" } else { "" }
if (-not (Test-Path $WinDeployQt)) {
    $Found = Get-Command windeployqt -ErrorAction SilentlyContinue
    if ($Found) { $WinDeployQt = $Found.Source }
}
if (-not $WinDeployQt -or -not (Test-Path $WinDeployQt)) {
    throw "windeployqt.exe was not found. Pass -QtPrefix pointing to your Qt kit."
}

& $WinDeployQt --release --qmldir (Join-Path $Root "qml") --no-translations (Join-Path $Stage "Sung.exe")

@"
Sung for Windows

This ZIP contains the native Sung executable and Qt runtime libraries.

For YouTube Music/helper features, install Python 3.11+ and:
  python -m pip install -r helper\requirements.txt

Then either keep python.exe on PATH or set SUNG_PYTHON to its full path.
Local metadata/artwork extraction additionally uses ffmpeg/ffprobe when available on PATH.
"@ | Set-Content -Encoding UTF8 (Join-Path $Stage "README-Windows.txt")

Compress-Archive -Path (Join-Path $Stage "*") -DestinationPath $Zip -CompressionLevel Optimal
Write-Host "Package: $Zip"

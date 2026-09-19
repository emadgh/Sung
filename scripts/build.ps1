param(
    [string]$QtPrefix = $env:QTDIR,
    [string]$BuildDir = "build-windows"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Build = Join-Path $Root $BuildDir

$ConfigureArgs = @(
    "-S", $Root,
    "-B", $Build,
    "-G", "Visual Studio 17 2022",
    "-A", "x64",
    "-DBUILD_TESTING=OFF",
    "-DSUNG_DIAGNOSTICS=OFF"
)

if (-not $QtPrefix) {
    $Qmake = Get-Command qmake6 -ErrorAction SilentlyContinue
    if (-not $Qmake) { $Qmake = Get-Command qmake -ErrorAction SilentlyContinue }
    if ($Qmake) {
        $QtBin = Split-Path -Parent $Qmake.Source
        $QtPrefix = Split-Path -Parent $QtBin
    }
}

if ($QtPrefix) {
    $ConfigureArgs += "-DCMAKE_PREFIX_PATH=$QtPrefix"
}

& cmake @ConfigureArgs
& cmake --build $Build --config Release --parallel

$Exe = Join-Path $Build "Release\sung.exe"
if (-not (Test-Path $Exe)) {
    $Exe = Join-Path $Build "sung.exe"
}
if (-not (Test-Path $Exe)) {
    throw "Build completed but sung.exe was not found."
}

Write-Host "Windows build: $Exe"

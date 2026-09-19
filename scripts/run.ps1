param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$SungArgs
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Python = Join-Path $Root "runtime\Scripts\python.exe"
if (-not (Test-Path $Python)) {
    throw "Python runtime is missing. Run scripts\setup.ps1 first."
}

$Exe = Join-Path $Root "build-windows\Release\sung.exe"
if (-not (Test-Path $Exe)) { $Exe = Join-Path $Root "build-windows\sung.exe" }
if (-not (Test-Path $Exe)) {
    throw "Windows build is missing. Run scripts\build.ps1 first."
}

$env:SUNG_HELPER = Join-Path $Root "helper\catalog.py"
$env:SUNG_PYTHON = $Python
& $Exe @SungArgs
exit $LASTEXITCODE

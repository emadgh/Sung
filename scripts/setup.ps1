$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$Runtime = Join-Path $Root "runtime"
$Python = Join-Path $Runtime "Scripts\python.exe"

if (-not (Test-Path $Python)) {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        & py -3 -m venv $Runtime
    }
    elseif (Get-Command python -ErrorAction SilentlyContinue) {
        & python -m venv $Runtime
    }
    else {
        throw "Python 3 was not found. Install Python 3.11+ and run this script again."
    }
}

& $Python -m pip install --disable-pip-version-check --upgrade pip
& $Python -m pip install --disable-pip-version-check -r (Join-Path $Root "helper\requirements.txt")

Write-Host "Sung Python runtime is ready at $Runtime"

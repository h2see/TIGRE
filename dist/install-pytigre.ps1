<# ===========================================================================
   install_pytigre.ps1 ─ installs pytigre-3.0.0 into the *current* venv
=========================================================================== #>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail {
    param([string]$Msg)
    Write-Host "`n$Msg" -ForegroundColor Red
    Read-Host "`nPress <Enter> to exit"
    exit 1
}

# ─────────────────────────────────────────────────────────────────────────────
# 1) Verify we are inside *some* virtual-environment
$isVenv = (& python -c "import sys, os; print(int((getattr(sys,'base_prefix',sys.prefix)!=sys.prefix) or hasattr(sys,'real_prefix')))").Trim()
if ($isVenv -ne '1') { Fail 'ERROR: No virtual environment detected.  Activate your Python-3.11 venv and re-run this script.' }

# ─────────────────────────────────────────────────────────────────────────────
# 2) Ensure the interpreter is Python 3.11.*
$verText = (& python --version 2>&1).Trim().Replace('Python ','')
try   { $verObj = [version]$verText }
catch { Fail "ERROR: Could not parse Python version ($verText)" }

if (($verObj.Major -ne 3) -or ($verObj.Minor -ne 11)) {
    Fail "ERROR: Python 3.11.x required - found $verText"
}

# ─────────────────────────────────────────────────────────────────────────────
# 3) Locate the wheel beside this script
$Wheel = Join-Path $PSScriptRoot 'pytigre-3.0.0-cp311-cp311-win_amd64.whl'
if (-not (Test-Path $Wheel)) { Fail "ERROR: Wheel not found:`n       $Wheel" }

# ─────────────────────────────────────────────────────────────────────────────
# 4) Install into the current venv
& python -m pip install $Wheel --only-binary :all: --disable-pip-version-check
if ($LASTEXITCODE -ne 0) { Fail 'ERROR: pip install failed.' }

# ─────────────────────────────────────────────────────────────────────────────
# 5) Success banner
$venvHome = (& python -c "import sys, pathlib; print(pathlib.Path(sys.prefix).resolve())").Trim()
Write-Host ''
Write-Host '============================================================'
Write-Host '     pytigre 3.0.0 successfully installed in:'
Write-Host "     $venvHome"
Write-Host '============================================================'
Read-Host 'Press <Enter> to exit'

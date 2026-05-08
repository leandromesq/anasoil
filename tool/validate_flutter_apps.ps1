$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot

function Invoke-Step($WorkingDirectory, $Command, $Arguments) {
  Push-Location (Join-Path $root $WorkingDirectory)
  try {
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
  finally {
    Pop-Location
  }
}

Invoke-Step 'packages/anasoil_shared' 'flutter' @('pub', 'get')
Invoke-Step 'packages/anasoil_shared' 'flutter' @('analyze')
Invoke-Step 'packages/anasoil_shared' 'flutter' @('test')

Invoke-Step 'anasoil_mobile' 'flutter' @('pub', 'get')
Invoke-Step 'anasoil_mobile' 'flutter' @('analyze')
Invoke-Step 'anasoil_mobile' 'flutter' @('test')

Invoke-Step 'anasoil_admin' 'flutter' @('pub', 'get')
Invoke-Step 'anasoil_admin' 'flutter' @('analyze')
Invoke-Step 'anasoil_admin' 'flutter' @('test')

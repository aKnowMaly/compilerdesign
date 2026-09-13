$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$toolDir = Join-Path $PSScriptRoot 'tectonic'
$exe = Join-Path $toolDir 'tectonic.exe'
$archive = Join-Path $root 'tmp\tectonic-0.15.0.zip'

if (Test-Path -LiteralPath $exe) {
  Write-Output $exe
  exit 0
}

New-Item -ItemType Directory -Force -Path $toolDir | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $archive) | Out-Null
Invoke-WebRequest `
  -Uri 'https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.15.0/tectonic-0.15.0-x86_64-pc-windows-msvc.zip' `
  -OutFile $archive
Expand-Archive -LiteralPath $archive -DestinationPath $toolDir -Force
if (-not (Test-Path -LiteralPath $exe)) {
  throw 'Tectonic installation did not produce tectonic.exe'
}
Write-Output $exe

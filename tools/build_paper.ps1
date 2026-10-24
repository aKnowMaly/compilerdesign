$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$paperDir = Join-Path $root 'paper'
$outputDir = Join-Path $root 'output\pdf'
$finalPdf = Join-Path $outputDir 'adaptive-width-memory-narrowing-paper.pdf'
$tectonic = Join-Path $PSScriptRoot 'tectonic\tectonic.exe'
$bundledPython = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'

if (-not (Test-Path -LiteralPath (Join-Path $root 'build\final-evaluation\final-evaluation.json'))) {
  throw 'Run the full test suite first so the authoritative evaluation exists.'
}
if (-not (Test-Path -LiteralPath (Join-Path $root 'build\external-benchmark-validation\results.json'))) {
  throw 'Run tools/external_benchmark_experiment.sh before building the external-validation paper.'
}
if (-not (Test-Path -LiteralPath (Join-Path $root 'build\width-choice\results.json'))) {
  throw 'Run tools/width_choice_experiment.py before building the revised paper.'
}
if (-not (Test-Path -LiteralPath $tectonic)) {
  & (Join-Path $PSScriptRoot 'install_tectonic.ps1') | Out-Null
}
$python = if (Test-Path -LiteralPath $bundledPython) { $bundledPython } else { 'python' }

& $python (Join-Path $root 'tests\check_external_results.py') (Join-Path $root 'build\external-benchmark-validation')
if ($LASTEXITCODE -ne 0) { throw 'External MiBench evidence validation failed.' }

& $python (Join-Path $PSScriptRoot 'generate_paper_assets.py')
if ($LASTEXITCODE -ne 0) { throw 'Paper asset generation failed.' }

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Push-Location $paperDir
try {
  & $tectonic -X compile main.tex --outdir $outputDir --keep-logs
  if ($LASTEXITCODE -ne 0) { throw 'LaTeX compilation failed.' }
} finally {
  Pop-Location
}
$tectonicPdf = Join-Path $outputDir 'main.pdf'
if (-not (Test-Path -LiteralPath $tectonicPdf)) {
  throw 'Tectonic did not produce main.pdf.'
}
Move-Item -LiteralPath $tectonicPdf -Destination $finalPdf -Force
Write-Output "pdf=$finalPdf"

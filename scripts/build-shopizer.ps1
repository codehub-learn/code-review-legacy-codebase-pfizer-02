# Build Shopizer once so the Maven dependencies are cached (tests skipped). Run it before the course.
#
#   scripts\build-shopizer.ps1
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not (Test-Path (Join-Path $Root 'shopizer'))) { throw 'No shopizer/ folder. Run scripts\setup-shopizer.ps1 first.' }
Set-Location (Join-Path $Root 'shopizer')
mvn -B -ntp clean install -DskipTests
exit $LASTEXITCODE

# Return a participant folder to its starting state between runs.
#
#   scripts\reset-lab.ps1 [-Yes]
#
# What it changes (it prints this first):
#   - shopizer/: discards local changes and untracked, non-ignored files, checks out the pinned SHA
#   - reports/: deletes everything except .gitkeep
# Build output (target/ folders) and ~/.m2 are kept, so the next run does not rebuild.
param([switch]$Yes)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$pins = @{}
Get-Content (Join-Path $Root 'scripts/lab.pins') | Where-Object { $_ -match '^\s*[A-Z_]+=' } | ForEach-Object {
  $k, $v = $_ -split '=', 2; $pins[$k.Trim()] = $v.Trim()
}

Write-Host "Reset of $Root"
Write-Host "  shopizer/ -> $($pins.SHOPIZER_TAG) ($($pins.SHOPIZER_SHA)), local changes discarded"
Write-Host '  reports/  -> emptied'
if (-not $Yes) {
  if ((Read-Host 'Continue? [y/N]') -ne 'y') { Write-Host 'Cancelled.'; exit 1 }
}

git -C "$Root/shopizer" reset --hard --quiet $pins.SHOPIZER_SHA
git -C "$Root/shopizer" clean -fdq
Get-ChildItem "$Root/reports" -Force | Where-Object Name -ne '.gitkeep' | Remove-Item -Recurse -Force
New-Item -ItemType File -Force "$Root/reports/.gitkeep" | Out-Null
Write-Host 'Reset done. Run scripts\verify-lab.ps1'

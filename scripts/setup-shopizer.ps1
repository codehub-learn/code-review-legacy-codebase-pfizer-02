# Clone Shopizer at the pinned tag into shopizer/ of the course folder. Safe to run again: if the checkout is already
# at the pinned SHA it does nothing.
#
#   scripts\setup-shopizer.ps1
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$pins = @{}
Get-Content (Join-Path $Root 'scripts/lab.pins') | Where-Object { $_ -match '^\s*[A-Z_]+=' } | ForEach-Object {
  $k, $v = $_ -split '=', 2; $pins[$k.Trim()] = $v.Trim()
}
$dir = Join-Path $Root 'shopizer'

if (Test-Path (Join-Path $dir '.git')) {
  $actual = git -C $dir rev-parse HEAD
  if ($actual -eq $pins.SHOPIZER_SHA) { Write-Host "shopizer/ is already at $($pins.SHOPIZER_TAG) ($actual). Nothing to do."; return }
  throw "shopizer/ exists but is at $actual, expected $($pins.SHOPIZER_SHA). Run scripts\reset-lab.ps1, or delete shopizer/ yourself and run this again."
}
if ((Test-Path $dir) -and (Get-ChildItem $dir -Force | Select-Object -First 1)) {
  throw 'shopizer/ exists and is not a git checkout. Move it away and run this again.'
}

git clone --filter=blob:none --no-checkout $pins.SHOPIZER_REPO $dir
if ($LASTEXITCODE) { throw 'git clone failed' }
git -C $dir checkout --quiet $pins.SHOPIZER_TAG
if ($LASTEXITCODE) { throw 'git checkout failed' }
$actual = git -C $dir rev-parse HEAD
if ($actual -ne $pins.SHOPIZER_SHA) { throw "Shopizer tag $($pins.SHOPIZER_TAG) is at $actual, expected $($pins.SHOPIZER_SHA). Stopping." }
Write-Host "shopizer/ is at $($pins.SHOPIZER_TAG) ($actual)"

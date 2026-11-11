# Create the section 3 review branches in a Shopizer checkout, one per real merged PR,
# each = the pinned tag + the PR's commit(s). Needs no network: the commits are already in the clone.
#
#   scripts\make-review-branches.ps1 [-Repo <shopizer-dir>]    default: <repo>\shopizer
#
# Existing review/* branches are left alone. The working tree of the checkout is not touched
# (a temporary worktree outside it is used and removed).
param([string]$Repo)
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$pins = @{}
Get-Content (Join-Path $Root 'scripts/lab.pins') | Where-Object { $_ -match '^\s*[A-Z_]+=' } | ForEach-Object {
  $k, $v = $_ -split '=', 2; $pins[$k.Trim()] = $v.Trim()
}
if (-not $Repo) { $Repo = Join-Path $Root 'shopizer' }

# branch = commit(s) cherry-picked in order. PR number is in the branch name.
$branches = [ordered]@{
  'review/pr-874'  = @('e0a1b61381f2f276974e534c54154c0ecd26d15c')
  'review/pr-890'  = @('4ce46e4bfa9726c4f8619ec32624beae7b8336c2')
  'review/pr-1054' = @('9a7196cefd0a59def94dbfb41195deefe8fe397d')
  'review/pr-1059' = @('9a20bc4ca65b0195efca2fe768517b3b9d7c3877')
}

$tagSha = git -C $Repo rev-parse "$($pins.SHOPIZER_TAG)^{commit}"
if ($tagSha -ne $pins.SHOPIZER_SHA) { throw "Tag $($pins.SHOPIZER_TAG) is not $($pins.SHOPIZER_SHA) in $Repo" }
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("review-branches-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $tmp | Out-Null
try {
  foreach ($name in $branches.Keys) {
    git -C $Repo show-ref --verify --quiet "refs/heads/$name"
    if ($LASTEXITCODE -eq 0) { Write-Host "exists   $name"; continue }
    foreach ($c in $branches[$name]) {
      git -C $Repo cat-file -e "$c^{commit}" 2>$null
      if ($LASTEXITCODE) { throw "Commit $c missing in $Repo (fetch origin first)" }
    }
    $wt = Join-Path $tmp ($name -replace '/', '-')
    git -C $Repo worktree add -q --detach $wt $pins.SHOPIZER_SHA
    if ($LASTEXITCODE) { throw 'worktree add failed' }
    git -C $wt -c user.name=lab -c user.email=lab@example.invalid cherry-pick --allow-empty @($branches[$name]) | Out-Null
    if ($LASTEXITCODE) { throw "cherry-pick failed for $name" }
    git -C $Repo branch $name (git -C $wt rev-parse HEAD)
    git -C $Repo worktree remove --force $wt
    Write-Host ("created  $name  (" + (git -C $Repo diff --shortstat $pins.SHOPIZER_SHA $name).Trim() + ")")
  }
} finally {
  git -C $Repo worktree prune
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

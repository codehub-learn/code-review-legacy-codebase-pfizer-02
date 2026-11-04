# Check a participant folder. Run from anywhere: scripts\verify-lab.ps1
# Does not start the agent. Checks that need the agent are manual (see the runbook).
param([ValidateRange(0, 4)][int]$Stage = 4)   # last course stage released so far (default 4)
$ErrorActionPreference = 'Continue'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$pins = @{}
Get-Content (Join-Path $Root 'scripts/lab.pins') | Where-Object { $_ -match '^\s*[A-Z_]+=' } | ForEach-Object {
  $k, $v = $_ -split '=', 2; $pins[$k.Trim()] = $v.Trim()
}
. (Join-Path $Root 'scripts/lib/check.ps1')
$Guard = Join-Path $Root '.claude/hooks/read-only-guard.mjs'
if (-not (Test-Path $Guard)) { $Guard = Join-Path $Root '.github/hooks/read-only-guard.mjs' } # copilot release

function Ok($m) { Write-Host "  ok    $m" }
function Bad($m) { Write-Host "  FAIL  $m"; $script:CheckFailed = $true }

# GuardExit <description> <expected exit code> <json>
function GuardExit($desc, $expected, $json) {
  $env:CLAUDE_PROJECT_DIR = $Root
  $json | node $Guard 2>$null | Out-Null
  Check $desc $expected $LASTEXITCODE
}

Write-Host 'Tools'
foreach ($t in 'git', 'java', 'mvn', 'node') {
  if (Get-Command $t -ErrorAction SilentlyContinue) { Ok "$t found" } else { Bad "$t not found on PATH" }
}

Write-Host 'Shopizer checkout'
Check "pinned SHA ($($pins.SHOPIZER_TAG))" $pins.SHOPIZER_SHA (git -C "$Root/shopizer" rev-parse HEAD 2>$null)
Check 'working tree clean (changed files)' 0 @(git -C "$Root/shopizer" status --porcelain 2>$null).Count
if (Test-Path "$Root/shopizer/sm-shop/target/shopizer.jar") { Ok 'build output present (sm-shop/target/shopizer.jar)' }
else { Bad 'not built yet: cd shopizer; mvn -B -ntp clean install -DskipTests' }

Write-Host "Lab package, stages 0 to $Stage (scripts/course-stages.txt)"
$marker = Join-Path $Root '.lab-agent'
$agent = if (Test-Path $marker) { (Get-Content $marker -Raw).Trim() } else { 'unknown' }
foreach ($line in Get-Content (Join-Path $Root 'scripts/course-stages.txt')) {
  if ($line -match '^\s*(#|$)') { continue }
  $p = $line -split '\|'
  if ([int]$p[0] -gt $Stage) { continue }
  $dst = if ($p.Count -gt 2 -and $p[2]) { $p[2] } else { $p[1] }
  if ($agent -eq 'copilot' -and $dst.StartsWith('.claude/')) { continue } # copilot gets .github/ instead
  $optional = $p.Count -gt 3 -and $p[3] -eq 'optional'
  if (Test-Path (Join-Path $Root $dst)) { Ok $dst }
  elseif ($optional) { Ok "$dst (optional, not present)" }
  else { Bad "missing $dst (stage $($p[0]))" }
}
if (Test-Path (Join-Path $Root 'reports')) { Ok 'reports' } else { Bad 'missing reports' }
Write-Host "Agent files (released for: $agent)"
if ($agent -in 'claude', 'both') { if (Test-Path (Join-Path $Root 'CLAUDE.md')) { Ok 'CLAUDE.md' } else { Bad 'missing CLAUDE.md' } }
if ($agent -in 'copilot', 'both') {
  $need = @('.github/hooks/read-only-guard.json', '.github/instructions/read-only.instructions.md')
  if ($Stage -ge 1) { $need += '.github/agents/code-explorer.agent.md' }
  if ($Stage -ge 3) { $need += '.github/prompts/review.prompt.md' }
  foreach ($f in $need) { if (Test-Path (Join-Path $Root $f)) { Ok $f } else { Bad "missing $f" } }
}
if ($Stage -ge 3) {
  Check 'review branches (review/pr-874, 890, 1054, 1059)' 4 @(git -C "$Root/shopizer" branch --list 'review/*' 2>$null).Count
}
foreach ($f in 'docs', 'COURSE-GUIDE.md', '.claude/tasks', '.claude/skills/lab-build-protocol', '.claude/skills/runbook-writer', '.github/skills/lab-build-protocol', '.github/skills/runbook-writer') {
  if (Test-Path "$Root/$f") { Bad "instructor material must not be here: $f" } else { Ok "no $f" }
}

Write-Host 'Read-only guard (simulated tool calls, no agent)'
$rootJson = $Root -replace '\\', '/'
GuardExit 'Edit shopizer/pom.xml is refused' 2 '{"tool_name":"Edit","tool_input":{"file_path":"shopizer/pom.xml"}}'
GuardExit 'Write new file in shopizer/ is refused' 2 "{`"tool_name`":`"Write`",`"tool_input`":{`"file_path`":`"$rootJson/shopizer/sm-core/NEW.java`"}}"
GuardExit 'Bash redirect into shopizer/ is refused' 2 '{"tool_name":"Bash","tool_input":{"command":"echo x > shopizer/pom.xml"}}'
GuardExit 'Bash rm in shopizer/ is refused' 2 '{"tool_name":"Bash","tool_input":{"command":"rm -rf shopizer/sm-core"}}'
GuardExit 'Bash cd then rm is refused' 2 '{"tool_name":"Bash","tool_input":{"command":"cd shopizer && rm pom.xml"}}'
GuardExit 'git commit in shopizer/ is refused' 2 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer commit -am x"}}'
GuardExit 'PowerShell Remove-Item in shopizer/ is refused' 2 '{"tool_name":"PowerShell","tool_input":{"command":"Remove-Item shopizer\\pom.xml"}}'
GuardExit 'Write reports/map.md is allowed' 0 '{"tool_name":"Write","tool_input":{"file_path":"reports/map.md"}}'
GuardExit 'git log in shopizer/ is allowed' 0 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer log --oneline -5"}}'
GuardExit 'git branch -D in shopizer/ is refused' 2 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer branch -D review/pr-874"}}'
GuardExit 'git branch --list is allowed' 0 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer branch --list review/*"}}'
GuardExit 'Copilot-style edit of shopizer/ is refused' 2 '{"hook_event_name":"PreToolUse","tool_name":"edit","tool_input":{"path":"shopizer/pom.xml"}}'
GuardExit 'Copilot-style bash rm in shopizer/ is refused' 2 '{"tool_name":"bash","tool_input":{"command":"rm -rf shopizer/sm-core"}}'
GuardExit 'Copilot-style create in reports/ is allowed' 0 '{"tool_name":"create","tool_input":{"path":"reports/map.md"}}'
GuardExit 'git diff between branches is allowed' 0 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer diff --stat 3.2.5 review/pr-874"}}'
GuardExit 'grep in shopizer/ is allowed' 0 '{"tool_name":"Bash","tool_input":{"command":"grep -rn Order shopizer/sm-core | head"}}'
GuardExit 'unreadable input is refused' 2 'not json'

Finish-Checks

# Tiny check helpers for verify-lab scripts. Dot-source this file, call Check, finish with Finish-Checks.
#
#   . "$PSScriptRoot/lib/check.ps1"
#   Check 'orders rows' 99441 (some command)
#   Finish-Checks   # prints ALL CHECKS PASSED or SOME CHECKS FAILED and sets the exit code

$script:CheckFailed = $false
function Check($desc, $expected, $actual) {
  if ("$expected" -eq "$actual") { Write-Host "  ok    $desc ($actual)" }
  else { Write-Host "  FAIL  ${desc}: expected '$expected', got '$actual'"; $script:CheckFailed = $true }
}
# Retry-Http <url> [tries] [sleepSeconds] -> returns 200 as soon as the url answers 200, otherwise 0
function Retry-Http($url, $tries = 40, $sleep = 3) {
  for ($i = 0; $i -lt $tries; $i++) {
    try { if ((Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 10).StatusCode -eq 200) { return 200 } } catch { }
    Start-Sleep -Seconds $sleep
  }
  0
}
function Finish-Checks {
  if ($script:CheckFailed) { Write-Host 'SOME CHECKS FAILED'; exit 1 } else { Write-Host 'ALL CHECKS PASSED' }
}

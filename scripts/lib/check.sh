#!/usr/bin/env bash
# Tiny check helpers for verify-lab scripts. Source this file, call check/ok/bad, finish with `finish`.
#
#   source scripts/lib/check.sh
#   check "orders rows" 99441 "$(some command)"
#   finish        # prints ALL CHECKS PASSED or SOME CHECKS FAILED and sets the exit code

CHECK_FAILED=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; CHECK_FAILED=1; }
# check <description> <expected> <actual>
check() {
  if [ "$2" = "$3" ]; then ok "$1 ($3)"; else bad "$1: expected '$2', got '$3'"; fi
}
# retry_http <url> [tries] [sleep_seconds]  -> prints the last HTTP status code (waits for 200)
retry_http() {
  local code=000 i
  for i in $(seq 1 "${2:-40}"); do
    code="$(curl -s -o /dev/null -w '%{http_code}' "$1")"
    [ "$code" = 200 ] && break
    sleep "${3:-3}"
  done
  echo "$code"
}
finish() {
  if [ "$CHECK_FAILED" = 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; exit 1; fi
}

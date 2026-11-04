#!/usr/bin/env bash
# Check a participant folder. Run from anywhere: scripts/verify-lab.sh [stage]
# [stage] is the last course stage released so far, 0 to 4 (default 4): the files of stages 0 to [stage] must be there.
# Does not start the agent. Checks that need the agent are manual (see the runbook).
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGE="${1:-4}"
case "$STAGE" in 0|1|2|3|4) ;; *) echo "Usage: scripts/verify-lab.sh [stage 0-4]" >&2; exit 2 ;; esac
# shellcheck disable=SC1091
source "$ROOT/scripts/lab.pins"
# shellcheck disable=SC1091
source "$ROOT/scripts/lib/check.sh"
GUARD="$ROOT/.claude/hooks/read-only-guard.mjs"
[ -e "$GUARD" ] || GUARD="$ROOT/.github/hooks/read-only-guard.mjs" # copilot release
# Native path for the JSON below (Git Bash on Windows reports /c/... but node sees C:/...)
NATIVE_ROOT="$(cygpath -m "$ROOT" 2>/dev/null || echo "$ROOT")"

# guard_exit <description> <expected exit code> <json>
guard_exit() {
  local code
  printf '%s' "$3" | CLAUDE_PROJECT_DIR="$ROOT" node "$GUARD" >/dev/null 2>&1
  code=$?
  check "$1" "$2" "$code"
}

echo "Tools"
for t in git java mvn node; do
  if command -v "$t" >/dev/null 2>&1; then ok "$t found"; else bad "$t not found on PATH"; fi
done

echo "Shopizer checkout"
check "pinned SHA ($SHOPIZER_TAG)" "$SHOPIZER_SHA" "$(git -C "$ROOT/shopizer" rev-parse HEAD 2>/dev/null)"
check "working tree clean (changed files)" "0" "$(git -C "$ROOT/shopizer" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
if [ -f "$ROOT/shopizer/sm-shop/target/shopizer.jar" ]; then ok "build output present (sm-shop/target/shopizer.jar)"
else bad "not built yet: cd shopizer && mvn -B -ntp clean install -DskipTests"; fi

echo "Lab package, stages 0 to $STAGE (scripts/course-stages.txt)"
AGENT="$(cat "$ROOT/.lab-agent" 2>/dev/null || echo unknown)"
while IFS='|' read -r st src dst opt; do
  case "$st" in ''|\#*) continue ;; esac
  [ "$st" -le "$STAGE" ] || continue
  dst="${dst:-$src}"
  [ "$AGENT" = "copilot" ] && case "$dst" in .claude/*) continue ;; esac # copilot gets .github/ instead
  if [ -e "$ROOT/$dst" ]; then ok "$dst"; elif [ "$opt" = "optional" ]; then ok "$dst (optional, not present)"; else bad "missing $dst (stage $st)"; fi
done < <(tr -d '\r' < "$ROOT/scripts/course-stages.txt")
[ -e "$ROOT/reports" ] && ok "reports" || bad "missing reports"
echo "Agent files (released for: $AGENT)"
case "$AGENT" in claude|both) [ -e "$ROOT/CLAUDE.md" ] && ok "CLAUDE.md" || bad "missing CLAUDE.md" ;; esac
case "$AGENT" in copilot|both)
  for f in .github/hooks/read-only-guard.json .github/instructions/read-only.instructions.md; do
    [ -e "$ROOT/$f" ] && ok "$f" || bad "missing $f"
  done
  [ "$STAGE" -ge 1 ] && { [ -e "$ROOT/.github/agents/code-explorer.agent.md" ] && ok ".github/agents/code-explorer.agent.md" || bad "missing .github/agents/code-explorer.agent.md"; }
  [ "$STAGE" -ge 3 ] && { [ -e "$ROOT/.github/prompts/review.prompt.md" ] && ok ".github/prompts/review.prompt.md" || bad "missing .github/prompts/review.prompt.md"; }
  ;;
esac
if [ "$STAGE" -ge 3 ]; then
  check "review branches (review/pr-874, 890, 1054, 1059)" "4" "$(git -C "$ROOT/shopizer" branch --list 'review/*' 2>/dev/null | wc -l | tr -d ' ')"
fi
for f in docs COURSE-GUIDE.md .claude/tasks .claude/skills/lab-build-protocol .claude/skills/runbook-writer .github/skills/lab-build-protocol .github/skills/runbook-writer; do
  if [ -e "$ROOT/$f" ]; then bad "instructor material must not be here: $f"; else ok "no $f"; fi
done

echo "Read-only guard (simulated tool calls, no agent)"
guard_exit "Edit shopizer/pom.xml is refused"     2 '{"tool_name":"Edit","tool_input":{"file_path":"shopizer/pom.xml"}}'
guard_exit "Write new file in shopizer/ is refused" 2 "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$NATIVE_ROOT/shopizer/sm-core/NEW.java\"}}"
guard_exit "Bash redirect into shopizer/ is refused" 2 '{"tool_name":"Bash","tool_input":{"command":"echo x > shopizer/pom.xml"}}'
guard_exit "Bash rm in shopizer/ is refused"        2 '{"tool_name":"Bash","tool_input":{"command":"rm -rf shopizer/sm-core"}}'
guard_exit "Bash cd then rm is refused"             2 '{"tool_name":"Bash","tool_input":{"command":"cd shopizer && rm pom.xml"}}'
guard_exit "git commit in shopizer/ is refused"     2 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer commit -am x"}}'
guard_exit "Write reports/map.md is allowed"        0 '{"tool_name":"Write","tool_input":{"file_path":"reports/map.md"}}'
guard_exit "git log in shopizer/ is allowed"        0 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer log --oneline -5"}}'
guard_exit "git branch -D in shopizer/ is refused"  2 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer branch -D review/pr-874"}}'
guard_exit "git branch --list is allowed"           0 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer branch --list review/*"}}'
guard_exit "Copilot-style edit of shopizer/ is refused"  2 '{"hook_event_name":"PreToolUse","tool_name":"edit","tool_input":{"path":"shopizer/pom.xml"}}'
guard_exit "Copilot-style bash rm in shopizer/ is refused" 2 '{"tool_name":"bash","tool_input":{"command":"rm -rf shopizer/sm-core"}}'
guard_exit "Copilot-style create in reports/ is allowed"  0 '{"tool_name":"create","tool_input":{"path":"reports/map.md"}}'
guard_exit "git diff between branches is allowed"   0 '{"tool_name":"Bash","tool_input":{"command":"git -C shopizer diff --stat 3.2.5 review/pr-874"}}'
guard_exit "grep in shopizer/ is allowed"           0 '{"tool_name":"Bash","tool_input":{"command":"grep -rn Order shopizer/sm-core | head"}}'
guard_exit "unreadable input is refused"           2 'not json'

finish

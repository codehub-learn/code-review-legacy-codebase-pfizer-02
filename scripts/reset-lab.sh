#!/usr/bin/env bash
# Return a participant folder to its starting state between runs.
#
#   scripts/reset-lab.sh
#
# What it changes (it prints this first):
#   - shopizer/: discards local changes and untracked, non-ignored files, checks out the pinned SHA
#   - reports/: deletes everything except .gitkeep
# Build output (target/ folders) and ~/.m2 are kept, so the next run does not rebuild.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/lab.pins"

echo "Reset of $ROOT"
echo "  shopizer/ -> $SHOPIZER_TAG ($SHOPIZER_SHA), local changes discarded"
echo "  reports/  -> emptied"
if [ "${1:-}" != "--yes" ]; then
  read -r -p "Continue? [y/N] " answer
  [ "$answer" = "y" ] || { echo "Cancelled."; exit 1; }
fi

git -C "$ROOT/shopizer" reset --hard --quiet "$SHOPIZER_SHA"
git -C "$ROOT/shopizer" clean -fdq
find "$ROOT/reports" -mindepth 1 ! -name .gitkeep -delete
touch "$ROOT/reports/.gitkeep"
echo "Reset done. Run scripts/verify-lab.sh"

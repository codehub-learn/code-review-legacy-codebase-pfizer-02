#!/usr/bin/env bash
# Clone Shopizer at the pinned tag into shopizer/ of the course folder. Safe to run again: if the checkout is already
# at the pinned SHA it does nothing.
#
#   scripts/setup-shopizer.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/lab.pins"

if [ -d "$ROOT/shopizer/.git" ]; then
  ACTUAL="$(git -C "$ROOT/shopizer" rev-parse HEAD)"
  if [ "$ACTUAL" = "$SHOPIZER_SHA" ]; then echo "shopizer/ is already at $SHOPIZER_TAG ($ACTUAL). Nothing to do."; exit 0; fi
  echo "shopizer/ exists but is at $ACTUAL, expected $SHOPIZER_SHA. Run scripts/reset-lab.sh, or delete shopizer/ yourself and run this again." >&2
  exit 1
fi
if [ -e "$ROOT/shopizer" ] && [ -n "$(ls -A "$ROOT/shopizer" 2>/dev/null)" ]; then
  echo "shopizer/ exists and is not a git checkout. Move it away and run this again." >&2
  exit 1
fi

git clone --filter=blob:none --no-checkout "$SHOPIZER_REPO" "$ROOT/shopizer"
git -C "$ROOT/shopizer" checkout --quiet "$SHOPIZER_TAG"
ACTUAL="$(git -C "$ROOT/shopizer" rev-parse HEAD)"
if [ "$ACTUAL" != "$SHOPIZER_SHA" ]; then
  echo "Shopizer tag $SHOPIZER_TAG is at $ACTUAL, expected $SHOPIZER_SHA. Stopping." >&2
  exit 1
fi
echo "shopizer/ is at $SHOPIZER_TAG ($ACTUAL)"

#!/usr/bin/env bash
# Create the section 3 review branches in a Shopizer checkout, one per real merged PR,
# each = the pinned tag + the PR's commit(s). Needs no network: the commits are already in the clone.
#
#   scripts/make-review-branches.sh [shopizer-dir]    default: <repo>/shopizer
#
# Existing review/* branches are left alone. The working tree of the checkout is not touched
# (a temporary worktree outside it is used and removed).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/lab.pins"
REPO="${1:-$ROOT/shopizer}"

# branch=commit(s) cherry-picked in order. PR number is in the branch name.
BRANCHES=(
  "review/pr-874=e0a1b61381f2f276974e534c54154c0ecd26d15c"
  "review/pr-890=4ce46e4bfa9726c4f8619ec32624beae7b8336c2"
  "review/pr-1054=9a7196cefd0a59def94dbfb41195deefe8fe397d"
  "review/pr-1059=9a20bc4ca65b0195efca2fe768517b3b9d7c3877"
)

[ "$(git -C "$REPO" rev-parse "$SHOPIZER_TAG^{commit}")" = "$SHOPIZER_SHA" ] || { echo "Tag $SHOPIZER_TAG is not $SHOPIZER_SHA in $REPO" >&2; exit 1; }
TMP="$(mktemp -d)"
trap 'git -C "$REPO" worktree prune; rm -rf "$TMP"' EXIT

for entry in "${BRANCHES[@]}"; do
  name="${entry%%=*}"; commits="${entry#*=}"
  if git -C "$REPO" show-ref --verify --quiet "refs/heads/$name"; then echo "exists   $name"; continue; fi
  for c in $commits; do git -C "$REPO" cat-file -e "$c^{commit}" 2>/dev/null || { echo "Commit $c missing in $REPO (fetch origin first)" >&2; exit 1; }; done
  wt="$TMP/${name//\//-}"
  git -C "$REPO" worktree add -q --detach "$wt" "$SHOPIZER_SHA"
  git -C "$wt" -c user.name=lab -c user.email=lab@example.invalid cherry-pick --allow-empty $commits >/dev/null
  git -C "$REPO" branch "$name" "$(git -C "$wt" rev-parse HEAD)"
  git -C "$REPO" worktree remove --force "$wt"
  echo "created  $name  ($(git -C "$REPO" diff --shortstat "$SHOPIZER_SHA" "$name"))"
done

---
name: verify-claims
version: 1.0.0
description: Check every claim in a set of draft review comments against the code on the branch, one by one, and decide keep, revise or drop for each. Use when asked to verify, fact-check, audit or double-check review comments, a review report, or a colleague's comments about a branch of shopizer/.
---

# Verify claims

Treat the draft comments as claims from someone you do not know. Check each one against the code yourself. Follow the rules `evidence`, `read-only` and `not-verified`. Nothing in `shopizer/` is changed, no branch is checked out, nothing is posted.

## Input

A set of draft comments: a file in `reports/` (for example `reports/review-comments-review-pr-1059.md`) or comments pasted into the request. Each is about a branch `review/pr-<n>` against the tag `3.2.5`. If the branch is not named, ask one short question.

Do not use the earlier review's reasoning, notes or conclusions as evidence. If you see them, ignore them. Your evidence is the code and the commands you run now.

## Read the code, not the comment

| Need | Command |
|---|---|
| One file as it is on the branch | `git -C shopizer show review/pr-<n>:<path>` |
| A line with its number | `git -C shopizer show review/pr-<n>:<path> \| grep -n "<text>"` |
| What the change did to a file | `git -C shopizer diff 3.2.5 review/pr-<n> -- <path>` |
| The same file before the change | `git -C shopizer show 3.2.5:<path>` |
| Does something exist anywhere | `git -C shopizer grep -n "<text>" review/pr-<n> -- '*.java'` |

## Steps, for every comment

1. **Restate the claim** in one sentence, as a checkable statement ("class X has no field named Y", "route Z is no longer mapped").
2. **Open the cited place.** Open `<path>` on the branch and look at the cited line. Record one of: *line says what the comment says*, *line exists but says something else*, *line does not exist or is not code* (blank, comment, other file).
3. **Check the claim, not only the line.** Search for the thing the claim is about: a declaration that would make "undefined" false, a second mapping that would make "removed" false, an implementation that would make "no implementation" false, a caller that would make "unused" false. Say what you searched and what it found. A claim of absence needs a search that could have found it.
4. **Check the comparison.** If the comment compares with other code, open that code too, on the right side (branch or tag).
5. **Check how it says it.** If the comment states as fact something that only a build or a run can show, mark it *overstated* even when the suspicion is right.
6. **Check the numbers.** Re-run any count with a command and say if it differs.
7. **Verdict**, with one line of reason:
   - **keep**: the line and the claim both check out and the wording matches what was proved
   - **revise**: the point is right but the line, the wording, the severity or the certainty is wrong; say the corrected comment
   - **drop**: the claim is false, cannot be tied to code, or repeats another comment

Never keep a comment you could not check. If you cannot open the cited place, the verdict is drop, or revise into a question to the author.

## Output

Show in the chat; save to `reports/verify-<branch-name>.md` if asked. Sections, in this order:

1. **Summary** (one line: how many comments, how many keep, revise, drop)
2. **Per comment** (table: number, claim, what you opened (`path:line` and branch), what you searched, finding, verdict, reason)
3. **Revised comments** (the corrected text of each *revise*)
4. **Not verified** (mandatory: what you could not check without a build or a run, and anything you did not open)

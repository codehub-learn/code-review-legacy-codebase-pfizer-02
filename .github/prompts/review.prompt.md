---
description: "Review a branch of shopizer/ against 3.2.5 and draft review comments"
argument-hint: "<branch, for example review/pr-874>"
---
Use the `code-explorer` agent with the `review-change` skill to review the branch ${input:arguments} against the tag `3.2.5`, then the `draft-review-comments` skill to draft the comments.

Read the branch with `git -C shopizer diff` and `git -C shopizer show`; do not check it out or change anything. Walk the diff in dependency order, flag risks, compare with nearby code, and give a `path:line` for every claim. Say what you could not build or run. If the change is sound, say so and write few or no comments. Finish with "Not verified". Show the result here; save it to `reports/review-<branch-name>.md` only if I ask.

---
name: draft-review-comments
version: 1.0.0
description: Turn the findings of a review of a branch in shopizer/ into draft review comments, each with a file and line, the evidence, and a suggested fix or a question. Use when asked to draft, write or prepare review comments for a branch, pull request or diff.
---

# Draft review comments

Write the comments a reviewer would leave on the change, as drafts for a human to decide on. Follow the rules `evidence`, `read-only` and `not-verified`. Nothing is posted anywhere and nothing in `shopizer/` is changed; a suggested fix is text in the comment, never an edit.

## Steps

1. **Start from findings you have.** Use the findings of a `review-change` run in this conversation. If there are none, run that skill first on the branch (`review/pr-<n>` against `3.2.5`). Do not invent a finding to fill the list.
2. **One comment per finding.** Open the file on the branch (`git -C shopizer show review/pr-<n>:<path>`) and take the line from there. A finding with no line you can open does not become a comment; list it under "Not verified".
3. **Say how you know.** Each comment states what you read or ran: "read in the source", "compile output", "compared with `<other file>:<line>`". Never say "this will fail" for something you only read; say "this looks like it will fail because ...".
4. **Ask or assert.** If the evidence settles it, state the problem. If it does not, write it as a question to the author. A question is better than a wrong claim.
5. **Suggest, short.** Give a fix in a few lines of code or one sentence, or say that you have none. Mark it as a suggestion.
6. **Few comments.** Fewer, sound comments are better than many. If the change is sound, say so and write few or no comments. Say honestly how many comments you wrote and why that number.
7. **Order** by severity: blocks the build or the release, wrong behaviour, risk, then style or question.

## Comment format

```
### <n>. <short title>
**Where:** shopizer/<path>:<line> (branch review/pr-<n>)
**Severity:** blocker | major | minor | question
**Evidence:** <what you read or ran, with the other file and line if you compared>
**Comment:** <what is wrong or unclear, in plain words, addressed to the author>
**Suggestion:** <fix in a few lines, or "none">
```

## Output

Show in the chat; save to `reports/review-comments-<branch-name>.md` if asked. Start with one line: the number of comments by severity. End with **Not verified**: findings you dropped for lack of a line, claims that need a build or a run, and anything you did not read.

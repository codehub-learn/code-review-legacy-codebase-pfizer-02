---
description: "Verify draft review comments against the code, then triage their confidence"
argument-hint: "<branch, and the comments: a file in reports/ or pasted text>"
---
Use the `review-verifier` agent to verify these draft review comments: ${input:arguments}

It must use the `verify-claims` skill (keep, revise or drop for every comment, with the line it opened) and then the `triage-confidence` skill (confidence, and post as a statement, post as a question, hold or drop). It starts from the comments only and reads the code on the branch with `git -C shopizer show` and `diff`; nothing is checked out or changed. Show the result here and finish with "Not verified". Save it to `reports/verify-<branch-name>.md` only if I ask; the agent has no write tool, so you save the text it returns.

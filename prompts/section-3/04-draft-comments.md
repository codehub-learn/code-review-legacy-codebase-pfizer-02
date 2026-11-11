# 3.4 Draft review comments

**Goal:** turn findings into draft comments with a file, a line, the evidence and a suggestion, and see how many comments a change really deserves.
**Time:** about 15 minutes. Nothing is posted anywhere.

Run the command on three branches, one at a time:

```
/review review/pr-1059
```

```
/review review/pr-1054
```

```
/review review/pr-874
```

For each, check:

1. How many comments, and at which severities? Does the number fit the size and the quality of the change?
2. Does each comment have a `path:line` that you can open on the branch, and an evidence line that says what was read and what was run?
3. Which comments are stated as fact and which are questions? Is anything stated as fact that the agent could only have read?
4. Is there a comment you would not send? Why?
5. Does the "Not verified" section list what needs a build or a run?

**Then, on your own:** save one report (`reports/review-<branch-name>.md`), mark each comment keep, change or drop, and write one line for each drop. Section 4 starts from that list.

# 3.2 Risk flags

**Goal:** get the risks in a change, each with a file and line, and learn what the agent can and cannot know without a build.
**Time:** about 10 minutes.

Paste, one at a time:

```
Use the review-change skill on the branch review/pr-1059. List the risk flags for error handling, concurrency, backward compatibility, data and security, and build and wiring. For each one give path:line, or say "none found" and what you searched.
```

```
Use the review-change skill on the branch review/pr-1054. Same risk flags. Separate what you read in the source from what would need a build or a run to confirm.
```

```
Use the review-change skill on the branch review/pr-890. Same risk flags. Look at every query in the diff and say what each one does and what it returns.
```

Check:

1. Does each flag have a `path:line` that you can open on the branch?
2. Which flags does the agent state as fact, and which as "looks like"? Is the wording honest about what it did not run?
3. Does the "Not verified" section list what needs a build or a run?

**Then, on your own:** the agent cannot build a branch from here. Decide how you would find out whether a branch builds, in a separate working copy, and what that tells you about what an agent that only reads the diff can claim.

# 3.1 Summarise a change and walk the diff

**Goal:** get the intent of a change and a reading order for its diff, and check both against the code.
**Time:** about 10 minutes. The agent only reads; the branches are never checked out or changed.

The branches `review/pr-874` and `review/pr-1054` each hold one real merged pull request on top of the tag `3.2.5`. List them yourself first:

```
git -C shopizer branch --list 'review/*'
```

Start with the smallest one. Paste:

```
Use the code-explorer agent and the review-change skill on the branch review/pr-874. Give me the intent of the change in two sentences, its size, and the diff walk. Do not draft comments yet.
```

Then the large one:

```
Use the code-explorer agent and the review-change skill on the branch review/pr-1054. Give me the intent, the shape of the change, and the diff walk in dependency order. Which file would you read first, and why?
```

Check:

1. Does the stated intent match the commit message (`git -C shopizer log --format=%B 3.2.5..review/pr-1054`)? Does the code do only what the message says?
2. Is the walk really in dependency order, or is it the order git prints the files?
3. Open two files on the branch with `git -C shopizer show review/pr-1054:<path>`. Do the `path:line` references point at what the agent says?

**Then, on your own:** read the diff yourself for five minutes, then compare. What did the agent's order change about how you read it?

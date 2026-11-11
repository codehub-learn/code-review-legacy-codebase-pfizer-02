# 4.3 Separate what is proved from what is guessed

**Goal:** tag each comment with a confidence level and decide, as the human, what to post, what to ask and what to hold.
**Time:** about 10 minutes. The agent proposes; you decide.

Use the verified draft from 4.1:

```
/verify-review review/pr-1054 reports/review-comments-review-pr-1054.md Verify, then triage the confidence of every comment that survives.
```

Do the same for the smallest branch. If you have no saved draft for it, run `/review review/pr-874` and save the result as `reports/review-comments-review-pr-874.md` first:

```
/verify-review review/pr-874 reports/review-comments-review-pr-874.md Verify, then triage the confidence of every comment that survives.
```

Check:

1. Does each confidence level name its basis (the second source that made it high, or what is missing)?
2. Pick one *high* and one *medium*. Is the difference really that one was cross-checked and the other only read?
3. Is any comment *high* on the strength of a build or a test that nobody ran?
4. What does the agent say would raise each *medium* or *low*?

**Then, on your own:** write your final list in `reports/to-post-review-pr-1054.md`: the comments you would post as statements, the ones you would post as questions, the ones you would hold and why. Mark any place where you overrode the agent.

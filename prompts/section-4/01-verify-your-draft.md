# 4.1 Verify your own draft

**Goal:** check the draft comments from section 3 with a second agent that did not write them, and compare its verdicts with yours.
**Time:** about 10 minutes. The verifier has no tool that writes files, and nothing is posted.

You need a saved draft. If you do not have one from 3.4, make it now and ask for it to be saved:

```
/review review/pr-1054
```

```
Save that review as reports/review-comments-review-pr-1054.md
```

Then start the verification. It runs in a fresh context, so it does not see how the comments were written:

```
/verify-review review/pr-1054 reports/review-comments-review-pr-1054.md
```

Check:

1. For each comment, did the verifier open the cited line on the branch? Open two of them yourself with `git -C shopizer show review/pr-1054:<path>`.
2. For each *drop* or *revise*: is the reason about the code, or about wording? Do you agree?
3. For each *keep*: what did it search for to confirm it, besides reading the cited line?
4. Compare with your own keep, change or drop list from 3.4. Where do you differ, and who is right?

**Then, on your own:** which comment would you have kept without the verifier? Which did the verifier catch that you did not?

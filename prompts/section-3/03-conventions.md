# 3.3 Check a change against the project's conventions

**Goal:** compare a change with the nearest existing code, and see how an agent finds that code.
**Time:** about 10 minutes.

Paste, one at a time:

```
Use the review-change skill on the branch review/pr-890, convention check only. Find the closest existing code that does the same kind of thing as the changed code, and compare them. Cite both sides with path:line.
```

```
Use the review-change skill on the branch review/pr-874, convention check only. Which other routes in the same controller map several paths to one method, and does the change follow the same pattern?
```

```
Use the review-change skill on the branch review/pr-1054, convention check only. How are services and their implementations declared and injected elsewhere in that package, and does the change follow the same pattern?
```

Check:

1. Did the agent pick comparison code that is really similar (same layer, same job), or just something with a similar name?
2. Are both sides cited, and do both lines say what the agent says?
3. Did it report only differences that matter, or style noise?

**Then, on your own:** pick one convention the agent reported. Is it a rule of the project, or one author's habit? How can you tell from the code?

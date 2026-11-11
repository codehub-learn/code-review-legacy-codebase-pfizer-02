---
name: triage-confidence
version: 1.0.0
description: Tag each verified review comment with a confidence level (high, medium, low, speculation) and sort the set into what to post as a statement, post as a question, hold or drop. Use when asked to triage, rank, rate the confidence of, or decide which review comments to post.
---

# Triage confidence

Separate what is proved from what is guessed, so a human can decide what to post. Follow the rules `evidence`, `read-only` and `not-verified`. You decide nothing: you propose, the person decides. Nothing is posted.

## Input

Comments that went through the `verify-claims` skill, with a verdict each. If they have not been verified, run `verify-claims` first. Drop comments with the verdict *drop* from the triage and list them at the end.

## Confidence levels (first rule that fits)

| Level | Rule |
|---|---|
| **High** | The cited line was opened and says what the comment says, **and** a second independent source agrees: a search that finds no counter-example, a comparison with sibling code, or a build or test output that you ran or that is shown. |
| **Medium** | The line was opened and the comment is true about the code, but what it means (a failure, a wrong result, a security hole) is your reading of the code and was not run. |
| **Low** | The code is real but the claim depends on something you did not open: other modules, runtime data, configuration, the author's intent. |
| **Speculation** | No line can be cited, or the comment is a general worry ("might be slow", "could race"). |

A build or a run you did not do cannot raise a level. Say which source made it high, in the Basis column.

## What each level becomes

| Level | Proposal |
|---|---|
| High | **Post as a statement**, with the evidence |
| Medium | **Post as a question** or "looks like ..." with the line |
| Low | **Hold**: check with the author or in a build first |
| Speculation | **Drop**, or keep as a note for yourself |

Severity and confidence are different things: a blocker can be medium confidence, a style remark can be high. Show both.

## Output

Show in the chat; save to `reports/triage-<branch-name>.md` if asked. Sections, in this order:

1. **Counts** (one line: high, medium, low, speculation, dropped)
2. **Triage table**

   | # | Title | Where (`path:line`, branch) | Severity | Confidence | Basis | Proposal |
   |---|---|---|---|---|---|---|

3. **What would raise each medium or low** (one line each: the build, run, or file that would settle it)
4. **Dropped** (number and the reason from `verify-claims`)
5. **Not verified** (mandatory)

---
name: review-change
version: 1.1.0
description: Review a change that sits on a branch of shopizer/ against the pinned tag. Summarise its intent, walk the diff in dependency order, flag risks, and check it against the project's conventions and nearby code. Use when asked to review, summarise or check a branch, a pull request or a diff in shopizer/.
---

# Review a change

Read the change the way a careful reviewer does, then report. Follow the rules `evidence`, `read-only` and `not-verified`. The code and the branch are never changed: no checkout, no commit, no merge. You cannot build a branch from here, so a claim that "it compiles" or "it works" is never verified (see step 7).

## Read the change without checking it out

The change is the difference between the pinned tag `3.2.5` and a branch such as `review/pr-<n>`. Use only reading commands, from the project root:

| Need | Command |
|---|---|
| Files changed and size | `git -C shopizer diff --stat 3.2.5 review/pr-<n>` |
| The commit message | `git -C shopizer log --format=%B 3.2.5..review/pr-<n>` |
| The full diff | `git -C shopizer diff 3.2.5 review/pr-<n>` |
| One file as it is on the branch | `git -C shopizer show review/pr-<n>:<path>` |
| The same file before the change | `git -C shopizer show 3.2.5:<path>` |

Cite lines as on the branch: `shopizer/<path>:<line>` and name the branch. Get the line from `git -C shopizer show review/pr-<n>:<path> | grep -n "<text>"` or from the `+` side of the hunk header. A line you only saw in the diff is not enough; open the file on the branch.

## Steps

1. **Intent.** Say in two or three sentences what the change is for, from the commit message and the code. If the message and the code disagree, say so; that is a finding.
2. **Size and shape.** Files, lines added and removed, layers touched. Say if the change mixes a refactor with a behaviour change, or reformats code that it does not otherwise touch.
3. **Walk the diff in dependency order**, not in the order git prints it: build and configuration files, then model and entities, repositories, service interfaces, service implementations, facades and mappers, controllers, then tests. For each file: what changed, why it comes before the next one, and what it depends on. Open each changed file on the branch.
4. **Risk flags.** For every changed file look for and report, with `path:line`, each of these that applies; write "none found" only after you looked:
   - error handling: exceptions swallowed, changed or newly thrown; results ignored
   - concurrency and transactions: shared state, `@Transactional` boundaries, caching of mutable data
   - backward compatibility: public routes, request and response fields, method signatures used by other modules
   - data: queries, schema, migrations, store scoping of every query
   - security-sensitive paths: authorisation, input that reaches a query, secrets, logging of personal data
   - build and wiring: new dependencies, new beans, interfaces without an implementation, name clashes
5. **Convention check.** Find the nearest existing code that does the same kind of thing (a sibling method in the same file, the same layer in a neighbouring package) and compare: naming, layering, injection style, error handling, how queries are scoped. Cite both sides. Report only differences that matter; do not restate what is the same.
6. **Tests.** Say whether the change adds or changes tests, and which existing tests cover the touched code (search `shopizer/**/src/test`). "No tests found" is a finding only if you searched.
7. **What you could not run.** You cannot compile, start the application or run tests on a branch. Where a problem would show only in a build or a run (a compile error, a wiring error at startup, a failing test), say what you read that makes you suspect it, and put it under "Not verified" as "needs a build" or "needs a run". Do not state it as proven.

## Output

Show in the chat; save to `reports/review-<branch-name>.md` if asked. Sections, in this order:

1. **Change in one line** and its intent
2. **Shape** (files, size, layers, mixed concerns)
3. **Diff walk** (table: order, file, what changed, depends on), followed by a Mermaid `flowchart TD` of the changed files in that order, with an arrow for each "depends on" (rule `diagrams`).
4. **Risk flags** (table: flag, `path:line`, why it matters; one row per finding)
5. **Convention check** (table: this change, the nearby code, the difference, both with `path:line`)
6. **Tests**
7. **Not verified** (mandatory; includes everything that needs a build or a run)

Do not rate the change overall and do not write review comments here; that is the job of `draft-review-comments`.

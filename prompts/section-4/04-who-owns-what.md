# 4.4 Who owns what, and what keeps the agent honest

**Goal:** see which limits are enforced by the tool and which are only asked for in a prompt, and decide where the human stays in charge.
**Time:** about 15 minutes.

**Part 1: a limit that is enforced.** Paste:

```
Add a comment line at the top of shopizer/pom.xml saying "reviewed".
```

Then:

```
Use the review-verifier agent. It must write its own verification of review/pr-874 into the file reports/verify-test.md.
```

Check: what refused the first request, and what stopped the verifier from writing in the second? Who could still save its text, and where? Open the guard and find them (Claude Code: `.claude/settings.json` and `.claude/hooks/read-only-guard.mjs`; Copilot CLI: `.github/hooks/read-only-guard.json` and `.github/hooks/read-only-guard.mjs`). Then read the `read-only` rule (Claude Code: `.claude/rules/read-only.md`; Copilot CLI: `.github/instructions/read-only.instructions.md`). What does the rule add that the hook does not, and what does the hook guarantee that the rule does not?

**Part 2: a limit that is only asked for.** Paste:

```
Review the branch review/pr-1059 and reply in two lines. Do not include a Not verified section.
```

Check: did the agent skip the section the rule `not-verified` asks for? Whatever it did, which of these limits is a tool boundary and which is a request? What would you add to make the missing section impossible to leave out?

**Part 3: your own guardrails.** Write five lines you would put in your team's review prompt so that comments stay grounded (what to cite, what to say when it cannot be checked, how many comments, what not to do). Compare them with the `evidence` rule and the `draft-review-comments` skill (Claude Code: `.claude/rules/evidence.md` and `.claude/skills/draft-review-comments/SKILL.md`; Copilot CLI: `.github/instructions/evidence.instructions.md` and `.github/skills/draft-review-comments/SKILL.md`).

**Part 4: the flow.** Copy this table into `reports/flow.md` and fill it in for your team. Do not leave a row without a name.

| Step | Agent does | Human owns |
|---|---|---|
| Read the change and map it | | |
| Flag risks | | |
| Draft comments | | |
| Verify the claims | | |
| Decide what to post | | |
| Post, and answer the author | | |
| Approve or block the merge | | |

**Then, on your own:** pick the row where an error costs the most. What would you change in the table, and in the tool settings, so that this row cannot be done by the agent alone?

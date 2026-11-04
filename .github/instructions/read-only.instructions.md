---
applyTo: "**"
---
# Read-only Shopizer

The `shopizer/` folder is the codebase under review. Never modify it: no edits, no new files, no deletes, no git commands that change the working tree or index.

- Write every report, diagram, glossary and draft comment to `reports/`.
- Reading, searching, `git log`, `git show`, `git diff` and `git blame` inside `shopizer/` are fine.
- If a tool refuses a write to `shopizer/`, say so and move the output to `reports/`. Do not look for another way to write there.
- If the user asks for a change to Shopizer code, describe the change in a report as a proposed diff instead of applying it.

This rule explains the boundary. The boundary itself is enforced by the permission rules (Claude Code only) and the `read-only-guard` hook, not by this text.

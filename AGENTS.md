# AGENTS.md

Lab: "AI-Assisted Code Review and Legacy Codebase Navigation". The learner uses an AI agent to find their way around Shopizer, a legacy Spring Boot e-commerce codebase, to trace changes through it, and to review a change before a human does.

## Stack

- Shopizer 3.2.5 (tag `3.2.5`, SHA `052d2ed3c026525329405cef433c0aca7dd2cee3`), a multi-module Spring Boot 2.5.12 / Maven e-commerce app, checked out in `shopizer/`.
- No MCP servers or external services. The agent works with files, git and Maven only.
- The security boundary is the read-only guard on `shopizer/`: permission deny rules plus the `read-only-guard` hook (registered in `.claude/settings.json` for Claude Code, in `.github/hooks/` for Copilot CLI, which has no deny rules). A prompt is never the boundary.

## Safety rules for the agent

- Show the exact command or SQL before anything that changes state.
- Ask before any destructive or hard-to-reverse action, and say what it would affect.
- Use the narrowest tool or server that can do the job; say which one you use.
- If a tool blocks an action, report it. Do not look for a way around it.
- Never print secrets or connection strings.
- Every claim about the code cites `path:line`; every report ends with a "Not verified" section (rules `evidence` and `not-verified`).
- Never modify `shopizer/`. Write reports to `reports/` (rule `read-only`).

## Working method

- Verify results before presenting them: counts, sanity checks, a second way to compute the same number.
- If a request is ambiguous, ask one short clarifying question before acting.
- State assumptions and what you could not verify.

## Repo layout

- `docs/`: runbook (`lab-runbook.md`) and reference material.
- `prompts/`: copy and paste prompts for learners, one folder per course section. They hold questions only.
- `scripts/`: setup, reset and verify scripts (`.sh` and `.ps1`).
- `.claude/` (Claude Code) or `.github/` (Copilot CLI): the agent components (skills, agents, commands or prompts, rules, guard hook). Which one you have depends on the agent chosen at release.
- `shopizer/`: the codebase under review, read-only. `reports/`: where the agent writes its output.

## Style

- Plain prose, no em dashes, write like a human.

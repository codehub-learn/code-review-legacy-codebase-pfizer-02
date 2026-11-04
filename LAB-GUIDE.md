# Lab guide: AI-Assisted Code Review and Legacy Codebase Navigation

This copy of the guide is for **GitHub Copilot CLI**, the agent your course uses.

Use this guide to do the lab, and to do it again on your own. You use an AI agent to find your way around Shopizer, a legacy Spring Boot e-commerce codebase, to trace a change through it, and to review a change before a human does. The agent reads files, git and Maven output. There are no databases, servers or MCP servers to start.

The course folder grows as the class moves on. You start with the setup files; the files for each section arrive with `git pull` when your instructor releases them. [Files you receive](#files-you-receive-with-each-release) explains what each batch is for.

## Syllabus

| Thematic unit | Topics |
|---|---|
| **Section 1. Getting Oriented in an Unfamiliar Codebase** | **Topic 1**<br>• Prompting the agent to produce a structural map: entry points, modules, layering, build targets<br>• Extracting the domain vocabulary and a glossary of core concepts from the code<br><br>**Topic 2**<br>• Locating where a feature lives: from a user-facing behaviour to the responsible files<br>• Sanity-checking the agent's map against the source before trusting it |
| **Section 2. Tracing Dependencies and Change Impact** | **Topic 3**<br>• Following a call path and a data path end to end with the agent narrating each hop<br>• Finding every caller and every implementation of an interface or method<br><br>**Topic 4**<br>• Estimating the blast radius of a proposed change: what breaks, what needs re-testing<br>• Spotting hidden coupling the agent surfaces: reflection, config, dynamic dispatch, generated code |
| **Section 3. Reading a Change: AI-Assisted Code Review** | **Topic 5**<br>• Getting the agent to summarise a pull request's intent and walk the diff in dependency order<br>• Risk flags: error handling, concurrency, backward compatibility, data migrations, security-sensitive paths<br><br>**Topic 6**<br>• Checking the change against project conventions and nearby existing patterns<br>• Drafting review comments with file and line references and a suggested fix or question |
| **Section 4. From Draft to Human Review** | **Topic 7**<br>• Verifying agent claims against the code: which comments to keep, revise, or drop<br>• Separating high-confidence findings from speculation before posting anything<br><br>**Topic 8**<br>• Fitting AI-assisted review into the team flow: what the agent does vs what the human owns<br>• Guardrails: prompts and context limits that keep review comments grounded and useful |

## How to read this guide

Only the lines marked **Run** and **Paste** are things you execute.

| Label | Meaning |
|---|---|
| **Run** | a command for a terminal, in the course folder |
| **Paste** | a prompt for the agent; the text is in the named `prompts/` file, or given here |
| **Check** | what to look at in the agent's answer before you trust it |

Your agent:

| | GitHub Copilot CLI |
|---|---|
| Start the agent in the course folder | `copilot` |
| First start | answer **yes** to trust the folder |
| List the skills | `/skills` |
| List the agents | `/agent` |
| Use an agent | `/agent`, choose it |
| Slash commands | `/map`, `/trace`, `/impact`, `/review`, `/verify-review` are prompt files in `.github/prompts/`. If the command is not offered, open the file, paste its body and put your argument where `${input:arguments}` stands. |
| Reload after new files arrive | restart `copilot` |

The prompts say "use the code-explorer agent and the X skill". You can just paste them; you do not have to pick the agent first.

## Rules of this lab

- `shopizer/` is read-only. The agent cannot edit, create or delete anything in it, and it cannot check out a branch. If it says a tool refused, that is the guard working. It writes its output to `reports/`.
- Every claim the agent makes about the code must point to a file and a line. Every report must end with a **Not verified** section. If an answer has neither, ask for them.
- The agent suggests; you decide. Sizes, comments and what to post are your decisions.
- Nothing is posted anywhere. All reviews are drafts.

## Before you start

| Need | Check |
|---|---|
| Git | `git --version` |
| A JDK (the source is Java 11; any recent JDK builds it) | `java -version` |
| Maven | `mvn -version` |
| Node.js (the safety guard runs on it) | `node --version` |
| GitHub Copilot CLI, logged in | `copilot --version` |
| Network for the first clone and the first Maven build | |

---

## Setup (before the first section)

### Step 1: Get the course folder and Shopizer

Shopizer 3.2.5 is cloned into `shopizer/` at one fixed commit, so everybody sees the same code.

**Run** (bash):

```bash
git clone <course-repo-url> code-review-lab
cd code-review-lab
cp .env.example .env
bash scripts/setup-shopizer.sh
```

**Run** (PowerShell):

```powershell
git clone <course-repo-url> code-review-lab
cd code-review-lab
Copy-Item .env.example .env
pwsh -File scripts/setup-shopizer.ps1
```

**Check:** the last line says `shopizer/ is at 3.2.5` followed by a 40-character commit id. Running the script again is harmless.

### Step 2: Build Shopizer once

This downloads the dependencies so later builds are fast. Allow a few minutes.

**Run** (bash):

```bash
bash scripts/build-shopizer.sh
bash scripts/verify-lab.sh 0
```

**Run** (PowerShell):

```powershell
pwsh -File scripts/build-shopizer.ps1
pwsh -File scripts/verify-lab.ps1 -Stage 0
```

**Check:** the Maven output ends with `BUILD SUCCESS` for six modules. The last line of `verify-lab` is `ALL CHECKS PASSED`. Before the build it fails once, on "not built yet".

`verify-lab` takes the number of the last release you have (0 to 4). It lists every file that should be there and tests the read-only guard with simulated calls.

---

## Section 1. Getting Oriented in an Unfamiliar Codebase

**First:** when your instructor says release 1 is out, run `git pull`, then restart the agent.

**Run** (bash): `git pull` then `bash scripts/verify-lab.sh 1`. **Run** (PowerShell): `git pull` then `pwsh -File scripts/verify-lab.ps1 -Stage 1`.

**Check:** skills `map-codebase`, `build-glossary`, `locate-feature`; agent `code-explorer`; command `/map`. The only failure allowed is "not built yet" if you skipped step 2.

### Topic 1, step 1: A structural map you can trust

**Paste:** `prompts/section-1/01-structural-map.md`: the `/map` block, then the follow-up block.

**Check:**
- `reports/map.md` exists and ends with a **Not verified** section.
- Pick three claims and open the files they cite. Do the lines say what the map says?
- Which numbers did the agent compute with a command, and which did it read from a name or a comment?

### Topic 1, step 2: The domain vocabulary

**Paste:** `prompts/section-1/02-glossary.md`.

**Check:**
- Does every term cite a class and a line?
- Open two classes you did not know and compare the definition with their fields.
- Is any term defined from general e-commerce knowledge with no class behind it?

### Topic 2, step 1: Locate a feature

**Paste:** `prompts/section-1/03-locate-feature.md`.

**Check:**
- Open the first and the last file in the list. Does each do what the agent says?
- Did the agent rule out look-alike classes, and say why?
- Did it say whether tests exist, and where it looked?

### Topic 2, step 2: Sanity-check the agent

**Paste:** `prompts/section-1/04-sanity-check.md`, three blocks, one at a time.

**Check:**
- For each number: how was it counted? Count it a second way yourself with `grep` or `git`.
- Did the agent check that a line it listed is not inside a comment?
- Would you put this number in a document?

---

## Section 2. Tracing Dependencies and Change Impact

**First:** `git pull` for release 2, then restart the agent.

**Run** (bash): `git pull` then `bash scripts/verify-lab.sh 2`. **Run** (PowerShell): `git pull` then `pwsh -File scripts/verify-lab.ps1 -Stage 2`.

**Check:** the new skills `trace-path`, `find-usages`, `impact-report` and the commands `/trace` and `/impact`.

### Topic 3, step 1: Trace a call path

**Paste:** `prompts/section-2/01-trace-call-path.md`: the `/trace` block, then the follow-up.

**Check:**
- Is every hop a file and a line you can open?
- For each interface: how many classes implement it, and how does the agent know which one runs?
- Does anything in the path look wrong to you when you read it?

### Topic 3, step 2: Trace a data path

**Paste:** `prompts/section-2/02-trace-data-path.md`.

**Check:** which type does the value have at each step? If someone changed the column type, which places the agent listed would have to change?

### Topic 3, step 3: Every caller, every implementation

**Paste:** `prompts/section-2/03-find-usages.md`, three blocks, one at a time.

**Check:**
- Run a plain text search for the method name yourself. Why is your number different from the agent's?
- Did it tell similar methods (same name, different arguments) apart?
- Are declarations, comments and tests counted separately from real callers?

### Topic 4, steps 1 and 2: Blast radius and hidden coupling

The compiler does not see everything that depends on a method. Look for links that no `import` shows.

**Paste:** `prompts/section-2/04-impact.md`: the four `/impact` requests, one at a time.

**Check:**
1. Does every number have a file and a line? Open two of them.
2. Does the **Rule hit** line name the rule and the numbers behind the size?
3. Did the agent search for aspects, events, configuration and string bean names, and does **Not verified** say what it could not see?
4. Is the confidence line separate from the size?

The size is a suggestion. You decide: would you accept it? Which change would you want a second person to look at, and what would you test first?

---

## Section 3. Reading a Change: AI-Assisted Code Review

**First:** `git pull` for release 3, then make the four review branches and restart the agent.

**Run** (bash):

```bash
git pull
bash scripts/make-review-branches.sh
bash scripts/verify-lab.sh 3
```

**Run** (PowerShell):

```powershell
git pull
pwsh -File scripts/make-review-branches.ps1
pwsh -File scripts/verify-lab.ps1 -Stage 3
```

**Check:** four lines `created  review/pr-...`; a second run prints `exists` four times. `verify-lab` shows `review branches ... (4)`. New skills `review-change` and `draft-review-comments`; command `/review`.

The four branches are real pull requests from the Shopizer project, each one the 3.2.5 tag plus that pull request's commit. You read them without checking them out:

```
git -C shopizer branch --list 'review/*'
git -C shopizer diff --stat 3.2.5 review/pr-874
```

The agent cannot build a branch from here. Where it says a change "will fail", ask whether it ran anything; "looks like it fails because ..." is the honest wording.

### Topic 5, step 1: Summarise a change and walk the diff

**Paste:** `prompts/section-3/01-summarise-and-walk.md`.

**Check:**
- Does the stated intent match the commit message (`git -C shopizer log --format=%B 3.2.5..review/pr-1054`)? Does the code do only what the message says?
- Is the walk in dependency order, or in the order git prints the files?
- Open two files on the branch with `git -C shopizer show review/pr-<n>:<path>`. Do the references point at what the agent says?

### Topic 5, step 2: Risk flags

**Paste:** `prompts/section-3/02-risk-flags.md`, three blocks.

**Check:**
- Does each flag have a file and line you can open on the branch?
- Which flags are stated as fact and which as "looks like"?
- Does **Not verified** list what needs a build or a run?

### Topic 6, step 1: Conventions

**Paste:** `prompts/section-3/03-conventions.md`, three blocks.

**Check:** is the comparison code really similar (same layer, same job)? Are both sides cited, and do both lines say what the agent says? Did it report differences that matter, or style noise?

### Topic 6, step 2: Draft review comments

**Paste:** `prompts/section-3/04-draft-comments.md`: `/review review/pr-1059`, `/review review/pr-1054`, `/review review/pr-874`.

**Check:**
- How many comments for each branch, and at which severity? Does the number fit the size and the quality of the change?
- Does each comment have a file and line, an evidence line, and a suggestion or a question?
- Is anything stated as fact that the agent could only have read?
- Is there a comment you would not send?

Save one report in `reports/` and mark every comment keep, change or drop. Section 4 starts from that list.

---

## Section 4. From Draft to Human Review

**First:** `git pull` for release 4, then restart the agent.

**Run** (bash): `git pull` then `bash scripts/verify-lab.sh 4`. **Run** (PowerShell): `git pull` then `pwsh -File scripts/verify-lab.ps1 -Stage 4`.

**Check:** the new skills `verify-claims` and `triage-confidence`, the agent `review-verifier` and the command `/verify-review`.

### Topic 7, step 1: Verify your own draft

**Paste:** `prompts/section-4/01-verify-your-draft.md`. It tells you how to save a draft if you have none.

**Check:**
- For each comment, did the verifier open the cited line on the branch? Open two yourself.
- For each *drop* or *revise*: is the reason about the code or about wording? Do you agree?
- For each *keep*: what did it search for besides reading the cited line?
- Where does your own list from section 3 differ, and who is right?

### Topic 7, step 2: Verify a colleague's comments

**Paste:** `prompts/section-4/02-colleagues-comments.md`.

**Check:** what did the verifier open and search before each verdict? Is every verdict backed by a line you can open on the branch? A real line number does not make a comment true.

### Topic 7, step 3: Separate what is proved from what is guessed

**Paste:** `prompts/section-4/03-triage-and-decide.md`.

**Check:** does each confidence level name its basis? Is any comment *high* because of a build or test that nobody ran? What would raise each *medium* or *low*?

Write your final list in `reports/to-post-review-pr-1054.md`: what you would post as statements, as questions, and hold, with a reason for each. Mark where you overrode the agent.

### Topic 8, steps 1 and 2: Who owns what, and what keeps the agent honest

**Paste:** `prompts/section-4/04-who-owns-what.md`, parts 1 to 4.

**Check:**
- Part 1: what refused the request, and what stopped the verifier from writing? Look at:
  - the guard: `.github/hooks/read-only-guard.json`, which runs `.github/hooks/read-only-guard.mjs` (Copilot CLI has no deny rules, so the hook is the only lock);
  - the verifier's tools: the `tools:` line of `.github/agents/review-verifier.agent.md`.
- Part 1, then: read the `read-only` rule (`.github/instructions/read-only.instructions.md`). What does the rule add that the hook does not, and what does the hook guarantee that the rule does not?
- Part 2: which of these limits is a tool boundary, and which is a request?
- Part 4: fill in `reports/flow.md` with a name in every row of the last column.

---

## Files you receive with each release

The course folder is released in five batches. Batch 0 is what you clone; batches 1 to 4 arrive with `git pull` at the start of each section. Files are only ever added, so a pull never overwrites your work. After each pull, restart your agent.
Skills, agents and commands are generated for Copilot CLI into `.github/skills/`, `.github/agents/` and `.github/prompts/`.

### Release 0: setup (`git clone`)

| File or folder | Role |
|---|---|
| `AGENTS.md` | Standing instructions for the agent: the stack, the safety rules, the working method. |
| `.github/hooks/read-only-guard.json` | Registers the read-only guard with Copilot CLI. It runs `.github/hooks/read-only-guard.mjs`, which sits next to it. Copilot has no deny rules, so this hook is the only lock. |
| `.github/instructions/` | The four always-on rules `read-only`, `evidence`, `not-verified` and `diagrams`, generated for Copilot CLI. Copilot reads `AGENTS.md` directly. |
| `scripts/setup-shopizer.*`, `scripts/build-shopizer.*` | Clone Shopizer at the fixed commit; build it once. |
| `scripts/verify-lab.*` | Checks that your folder has every file of the releases so far and tests the guard. |
| `scripts/reset-lab.*` | Puts `shopizer/` back to the fixed commit and empties `reports/`. |
| `scripts/lab.pins`, `scripts/course-stages.txt`, `scripts/lib/` | The pinned commit, the list of what each release contains, and helpers for the scripts. |
| `.env.example` | Template for `.env`; this lab needs no secrets. |
| `.gitignore`, `.gitattributes` | Keep `shopizer/`, `.env` and your reports out of git; keep line endings stable. |
| `reports/` | Where the agent writes its output. |
| `LAB-GUIDE.md` | This guide. |

### Release 1: start of section 1 (`git pull`)

| File or folder | Role |
|---|---|
| `prompts/section-1/` | The prompts for topics 1 and 2. |
| Skill `map-codebase` | Maps modules, entry points, layers and data, with a second way to check each number. |
| Skill `build-glossary` | Builds a glossary of 12 to 20 core terms from the entity classes. |
| Skill `locate-feature` | Goes from a behaviour to the files that implement it, and rules out look-alikes. |
| Agent `code-explorer` | A read-only explorer. It writes only to `reports/`. |
| Command `/map` | Runs the explorer with the map skill. |

### Release 2: start of section 2 (`git pull`)

| File or folder | Role |
|---|---|
| `prompts/section-2/` | The prompts for topics 3 and 4. |
| Skill `trace-path` | Follows a call path or a data path hop by hop. |
| Skill `find-usages` | Finds callers and implementations, tells overloads apart, counts a second way. |
| Skill `impact-report` | Produces a fixed-format impact report with a suggested size and a re-test list. |
| Commands `/trace`, `/impact` | Run the explorer with those skills. |

### Release 3: start of section 3 (`git pull`)

| File or folder | Role |
|---|---|
| `prompts/section-3/` | The prompts for topics 5 and 6. |
| `scripts/make-review-branches.*` | Creates the four `review/pr-*` branches from commits already in your clone. |
| Skill `review-change` | Summarises a branch, walks the diff in dependency order, flags risks, compares with nearby code, and says what it could not run. |
| Skill `draft-review-comments` | Turns findings into draft comments with a file, a line, evidence and a suggestion. |
| Command `/review` | Runs both skills on a branch. |

### Release 4: start of section 4 (`git pull`)

| File or folder | Role |
|---|---|
| `prompts/section-4/` | The prompts for topics 7 and 8. |
| Skill `verify-claims` | Checks each comment against the code and decides keep, revise or drop. |
| Skill `triage-confidence` | Tags each comment high, medium, low or speculation and proposes what to post. |
| Agent `review-verifier` | Checks comments in a fresh context. It has no tool that writes files. |
| Command `/verify-review` | Runs the verifier with both skills. |

---

## Start over

**Run** (bash):

```bash
bash scripts/reset-lab.sh
bash scripts/verify-lab.sh
```

**Run** (PowerShell):

```powershell
pwsh -File scripts/reset-lab.ps1
pwsh -File scripts/verify-lab.ps1
```

**Check:** `shopizer/` is back at the fixed commit with your local changes discarded, `reports/` is empty, the build output and the `review/pr-*` branches are kept. It asks before it does anything. Pass `--yes` (bash) or `-Yes` (PowerShell) to skip the question.

## Files you create during the lab

| What | When |
|---|---|
| `.env`, the `shopizer/` clone, Maven build output | setup |
| `reports/map.md`, `reports/glossary.md` and other reports | sections 1 and 2 |
| local branches `review/pr-874`, `review/pr-890`, `review/pr-1054`, `review/pr-1059` inside `shopizer/` | start of section 3 |
| `reports/review-comments-*.md`, `reports/verify-*.md`, `reports/to-post-*.md`, `reports/flow.md` | sections 3 and 4 |

## If something goes wrong

| Symptom | Likely cause and fix |
|---|---|
| Maven: `Failed to clean project ... target` | Another Maven run is using the same `shopizer/` folder. Stop it and run the build again. |
| `verify-lab` fails only on "not built yet" | Run `build-shopizer` once. |
| `verify-lab` says `missing ...` | You did not pull a release, or the instructor has not pushed it yet. Run `git pull`, or ask. |
| `make-review-branches` says a commit is missing | Your clone is partial or old. Run `git -C shopizer fetch origin`, then the script again. |
| New skills or agents do not appear after `git pull` | Restart the agent; it reads them only at startup. |
| The agent shows none of the project hooks, skills or rules | The folder is not trusted, or `copilot` was not started in the course folder. Restart it there and answer yes. |
| The agent says it cannot edit, create or check out something in `shopizer/` | That is the guard. Let it write to `reports/`; do not look for a way around it. |
| The agent says a branch "will not compile" | It cannot build here. Ask what it read; the honest wording is "looks like". |
| An answer has no file and line, or no **Not verified** section | Ask for them. The rules `evidence` and `not-verified` are requests, not locks. |
| `/review` or `/verify-review` is not offered | Open `.github/prompts/<name>.prompt.md`, paste its body, and put the branch where `${input:arguments}` stands. |
| Line numbers do not match what you see | A line on a review branch differs from the same line on `3.2.5`. Open the file on the branch with `git -C shopizer show review/pr-<n>:<path>`. |

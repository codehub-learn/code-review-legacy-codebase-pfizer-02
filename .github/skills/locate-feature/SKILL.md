---
name: locate-feature
version: 1.1.0
description: Find where a user-facing behaviour lives in the code, from the HTTP route down to the data, and list the responsible files with their roles. Use when asked where a feature is implemented or which files to read to understand a behaviour in shopizer/.
---

# Locate a feature

Go from the behaviour a user sees to the files that implement it. Follow the rules `evidence` and `not-verified`.

## Steps

1. **Restate the behaviour** in one line, and list the words a developer might have used for it (synonyms, abbreviations, the domain terms).
2. **Search from the outside in.** Search routes and annotations first (`@GetMapping`, `@PostMapping`, `@RequestMapping` and the path words), then class and method names, then messages or templates. Record what each search found and what it did not.
3. **Follow the chain.** From the controller method, follow the calls: facade, service, repository, entity. Open each file. For an interface, find its implementations and say which one is used and why. Note any class that has a look-alike twin elsewhere.
4. **Cover the sides.** Check for the request and response objects, the validation, the security rule, any e-mail or external call, and the tests that cover it.
5. **Rule out the decoys.** List files that match the words but are a different feature, and say why you left them out.
6. **Stop at the data.** End at the repository and entity (or at the external system). Do not describe the whole application.

## Output

Show in the chat (and save to `reports/feature-<name>.md` if asked). Sections:

1. Behaviour in one line
2. Entry route(s), each with HTTP method, path and `path:line`
3. Files, in call order (table: step, role, file `path:line`, what it does there)
   Add a Mermaid `flowchart TD` of the same files, from the route to the table (rule `diagrams`).
4. Data touched (entity, table, fields that matter)
5. Tests found (or "none found" and where you looked)
6. Looked like a match but is not
7. Not verified

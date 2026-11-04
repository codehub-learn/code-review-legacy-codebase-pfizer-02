---
name: build-glossary
version: 1.0.0
description: Extract the domain vocabulary of a codebase into a glossary of core concepts, each defined from the code with evidence. Use when asked for a glossary, domain model, or what the main business terms mean in shopizer/.
---

# Build a domain glossary

Define each term from what the code says about it, not from general e-commerce knowledge. Follow the rules `evidence` and `not-verified`.

## Steps

1. **Find the candidates.** Start from the persistent model: the `@Entity` classes and their `@Table` names. Add the main service interfaces and the top-level API resources. Group them by domain (for example catalog, customer, order, shipping, payment, system).
2. **Pick the core terms.** Choose 12 to 20 terms that a new developer must know to read the code. Prefer terms that other classes depend on. Say how you chose.
3. **Define each term from the code.** For each term: the class (`path:line`), the table, what its fields and relations tell you, and which other core terms it points to. One or two sentences, in plain words.
4. **Flag the confusing ones.** Mark terms whose name hides their meaning, terms that look alike (for example two classes with similar names in different packages), and terms that mean different things in different modules.
5. **Relations.** Add a short list of how the core terms connect (for example "an X belongs to a Y").

## Output

Save to `reports/glossary.md` (never inside `shopizer/`) and show it in the chat. Table columns: Term, Meaning in this code, Class and table, Related terms, Evidence. Then a section "Confusing or overloaded terms", a section "How the terms connect", and **Not verified**.

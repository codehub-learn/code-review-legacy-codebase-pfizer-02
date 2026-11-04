---
applyTo: "**"
---
# Diagrams

When a report is about structure or flow, add a Mermaid diagram next to the table it summarises. A skill says where the diagram goes; this rule says how to draw it.

- Draw only what you verified. Every box is a class, module, route or table you cited with `path:line` in the same report. Do not add a box from its name or from general knowledge.
- Label each box with the short name plus where it lives (module or file), and keep the `path:line` in the table, not in the diagram.
- Use the diagram type that fits: `flowchart TD` for a call path or layers, `flowchart LR` for a data path, `flowchart` with subgraphs for modules, `classDiagram` or `erDiagram` for entities and relations, `gitGraph` is not needed for a review.
- Put text with spaces or punctuation in double quotes: `A["OrderFacade"]`. Use `<br/>` for a line break.
- Mark what you could not confirm with a dashed arrow (`-.->`) and say so in the **Not verified** section. Never draw an arrow you have not seen in the code.
- Keep it small: about 15 boxes at most. If there are more, draw the main path and list the rest in the table.
- Write the diagram in a ```` ```mermaid ```` fenced block inside the report file in `reports/`, and show the same block in the chat.
- Skip the diagram when it would only repeat a table with fewer than three rows. Say "No diagram: <reason>" instead.

---
name: trace-path
version: 1.1.0
description: Follow a call path or a data path through the code hop by hop, from the entry point (route or response field) to the database, narrating each hop with file and line. Use when asked how a request is handled end to end, what happens when an endpoint is called, or where a value comes from.
---

# Trace a path

Walk the path in the order the code runs. Open every file you cite. Follow the rules `evidence` and `not-verified`.

## Call path (entry point to data)

1. **Start at the route.** Find the controller method for the endpoint and say which class and line map it.
2. **Take one hop at a time.** For each hop write: from (`path:line`), to (`path:line`), what is passed, what comes back. Open the called method before you describe it.
3. **Interfaces.** When the call goes through an interface, find the implementing classes. Say how many there are and which one is used, and why (field name, qualifier, profile, XML). If you cannot tell, say so.
4. **Check what runs outside the call chain.** For each hop, look for things that run without being called: aspects and their pointcuts, event listeners, `@Async`, caching, JPA entity listeners, filters. Say which ones apply to this path.
5. **Stop at the data.** End at the repository query, the entity and the table. Quote the query if there is one.
6. **Decoys.** Name any class with a similar name or a second implementation that a reader might follow by mistake.

## Data path (a value or field)

1. Start at the response object field (or the request field) and find where it is set.
2. Go backwards (or forwards) one assignment at a time: DTO field, populator or mapper, service, entity field, column. Note each place where the value is converted, formatted, defaulted or filtered, and its type at that point.
3. Say where the rule that decides the value lives (for example a discount rule), even if it is not on the straight path.

## Output

Show in the chat; save to `reports/trace-<name>.md` if asked. Sections:

1. Question in one line
2. Hops (table: step, from `path:line`, to `path:line`, what happens)
   Add a Mermaid diagram of the same hops (rule `diagrams`): `flowchart TD` for a call path, `flowchart RL` for a data path, labelling each arrow with what happens. Draw interfaces as `{{"Interface"}}` boxes with the chosen implementation behind them, and anything that runs outside the call chain (aspect, listener, async, cache) with a dashed arrow.
3. Interfaces and which implementation is used
4. Runs outside the call chain (aspects, listeners, async, cache)
5. Data touched (query, entity, table, fields)
6. Looked like part of the path but is not
7. Not verified

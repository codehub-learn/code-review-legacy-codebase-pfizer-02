---
description: "Trace a call path or data path hop by hop (controller to table), with file and line for each hop"
argument-hint: "<endpoint, method or field to trace>"
---
Use the `code-explorer` agent with the `trace-path` skill to trace: ${input:arguments}

Narrate every hop with `path:line`, name the implementation used at each interface, list what runs outside the call chain (aspects, listeners, async, cache), and finish with "Not verified". Save it to `reports/trace-<name>.md`.

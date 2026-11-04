---
description: "Map the Shopizer codebase (modules, layers, entry points) into reports/map.md"
argument-hint: "[optional focus, for example \"order flow\" or \"sm-core only\"]"
---
Use the `code-explorer` agent with the `map-codebase` skill to map the project in `shopizer/`.

Focus: ${input:arguments} (if empty, map the whole project).

Save the map to `reports/map.md`, show it here, and finish with the "Checks I ran" and "Not verified" sections.

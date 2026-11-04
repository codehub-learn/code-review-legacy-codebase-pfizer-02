---
name: map-codebase
version: 1.1.0
description: "Produce a structural map of an unfamiliar Maven or Spring codebase: modules, layers, entry points and build targets, with evidence for each claim. Use when asked to map, orient in, or give an overview of the project in shopizer/."
---

# Map the codebase

Build the map from the files, not from memory of what Spring projects usually look like. Follow the rules `evidence` and `not-verified`.

## Steps

1. **Modules and build targets.** Read the root `pom.xml` and each module `pom.xml`: module list, packaging, which module depends on which, parent and Java level. Note the build command if a README or wrapper states one.
2. **Entry points.** Search for `@SpringBootApplication`, `public static void main`, `@RestController`, `@Controller`, filters and `@ControllerAdvice`. Report the application class and how requests reach the code (routes grouped by controller).
3. **Layers.** For each module, list its top-level packages and say what role each plays. Decide the role from what the classes contain (annotations, what they call), not from the package name alone. Package names can mislead.
4. **Data.** Say where entities live and how many `@Entity` classes exist (count with a command).
5. **Counts.** For every number, show the command that produced it.
6. **Second check.** Recompute at least three numbers a different way (for example `git ls-files` against `find`, or a grep against a directory listing). Report any difference and which one is right and why.

## Output

Save to `reports/map.md` (never inside `shopizer/`) and show the same content in the chat. Use these sections, in this order:

1. Modules (table: module, role, depends on, main Java files)
   Add a module diagram under the table: `flowchart` with one box per module and an arrow for each dependency you read from a `pom.xml` (rule `diagrams`).
2. Entry points
3. Layers (table: layer, packages, what it does, example class with `path:line`)
   Add a layer diagram: top to bottom, one box per layer, with the example class in each box (rule `diagrams`).
4. Data model (entities, where they live)
5. Build and run
6. Checks I ran (the second-way comparisons)
7. Not verified

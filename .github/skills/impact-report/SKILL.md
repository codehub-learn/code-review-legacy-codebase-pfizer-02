---
name: impact-report
version: 1.2.0
description: Estimate the blast radius of a proposed change as a fixed-format impact report with evidence, a suggested t-shirt size (XS to XL) and a list of what to re-test. Use when asked what a change would affect, what breaks, how big or risky a change is, or what needs re-testing.
---

# Impact report

Estimate what a proposed change affects. The code is not changed. Follow the rules `evidence`, `read-only` and `not-verified`. The size is a suggestion: the person decides.

## Steps

1. **Restate the change** in one line: which type or method changes and how (signature, return type, behaviour, field, column).
2. **Trace the path** with the `trace-path` skill, from the controller to the table, so you know what the change sits in.
3. **Count the usages** with the `find-usages` skill: direct callers, callers to depth 3, implementations, tests.
4. **Layers and public surface.** Say which layers the callers are in. Say whether the change alters a public API (a controller method, a request or response object) or the database schema (an entity field or column), and which endpoints are reached.
5. **Look for hidden coupling** and report each hit with `path:line`; say "none found" only after you searched all of these:
   - aspects: `@Aspect`, `@Pointcut` and `execution(...)` strings that name the type or method
   - XML bean definitions and string bean names (`@Qualifier("...")`, `@Resource(name = ...)`)
   - reflection and `ApplicationContext` lookups
   - `@Profile`, `@Async`, `@Cacheable` and other proxy-based annotations on the type or method
   - Spring events (publishers and listeners) and JPA entity listeners
   - configuration keys and properties files
   - how the schema is created or migrated (Hibernate settings, SQL scripts)
6. **Size** the change with the rules below. Use the first rule that matches, from the top.
7. **Re-test list.** From the callers, the endpoints and the hidden links: what should be run or checked again, in priority order. Name existing tests that cover the path, and say where there are none.

## Size rules (first match from the top)

| Size | Rule |
|---|---|
| XL | Public API or DB schema changes and (hidden coupling is found, or 5 or more endpoints are reached) |
| L | Public API or schema changes, or hidden coupling is found, or more than 25 transitive callers |
| M | 10 to 25 transitive callers, or more than 1 implementation affected |
| S | 3 to 9 transitive callers |
| XS | At most 2 transitive callers |

Transitive callers means distinct calling methods in main source up to depth 3. Layers touched, endpoints reached and tests are reported in the table but do not change the size.

## Output

Show in the chat; save to `reports/impact-<short-name>.md` if asked. Use exactly these sections, in this order.

1. **Change** (one line)
2. **Path traced** (controller to table, each hop with `path:line`), followed by a Mermaid diagram of the path (rule `diagrams`). Colour or mark the hop that changes and draw callers that sit outside the path as separate boxes pointing in; draw hidden coupling with a dashed arrow.
3. **What is affected** (table; every row has evidence)

   | Input | Count or finding | Evidence |
   |---|---|---|
   | Direct callers | | |
   | Transitive callers, depth 3 | | |
   | Implementations | | |
   | Layers touched | | |
   | Endpoints reached | | |
   | Public API or schema affected | | |
   | Hidden coupling | | |
   | Tests covering the path | | |

4. **What to re-test**
5. **Not verified** (mandatory)

Then the **Verdict**, exactly in this form (the example numbers are only an illustration):

```
## Verdict

**Size: M** (suggested by the agent; you decide)

| Field | Value |
|---|---|
| Size | M |
| Rule hit | 14 transitive callers (10 to 25); no public API or schema change; no hidden coupling found |
| Confidence | High on counts, Medium on hidden coupling (see "Not verified") |

**Rule check** (read from the top; the first match wins)

| Size | Rule | What I found | Match |
|---|---|---|---|
| XL | Public API or schema changes and (hidden coupling, or 5 or more endpoints) | No API or schema change | No |
| L | Public API or schema changes, or hidden coupling, or more than 25 transitive callers | No API change, no coupling, 14 callers | No |
| M | 10 to 25 transitive callers, or more than 1 implementation affected | 14 transitive callers | **Yes** |
| S | 3 to 9 transitive callers | not reached | n/a |
| XS | At most 2 transitive callers | not reached | n/a |

**Confidence** (reported separately from size)

| Area | Level | What lowers it |
|---|---|---|
| Counts (callers, implementations) | High | Counted by command and re-counted a second way |
| Public API and schema | High | Read from the entity and controller source |
| Hidden coupling | Medium | Runtime wiring was not run; see "Not verified" |
```

Rules for the verdict:

- The "Rule hit" row and the Rule check table are mandatory. Name the rule you used and the numbers, and mark exactly one row **Yes**; rows below it are "not reached".
- Every "What I found" cell uses the numbers from the "What is affected" table, so the two tables agree.
- Report confidence separately from size, one row per area, and say what lowers each level. Never give one overall confidence.

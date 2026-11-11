---
description: "Impact report for a proposed change, with a suggested size (XS to XL) and a re-test list"
argument-hint: "<the proposed change, for example \"change the return type of FooService.bar\">"
---
Use the `code-explorer` agent with the `impact-report` skill (which uses `trace-path` and `find-usages`) to assess this proposed change: ${input:arguments}

Do not change any code. Use the fixed report format, including the "Rule hit" line and the separate confidence line, and finish with "Not verified". The size is a suggestion; I decide. Save the report to `reports/impact-<short-name>.md`.

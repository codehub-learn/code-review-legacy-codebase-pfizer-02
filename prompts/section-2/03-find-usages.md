# 2.3 Find every caller and every implementation

**Goal:** get complete answers about usage, and check them.
**Time:** about 10 minutes.

Paste, one at a time:

```
Use the code-explorer agent and the find-usages skill. Which classes implement the ProductFacade interface, and which of them does ProductApi get injected? How do you know?
```

```
Use the find-usages skill. How many places call the paged listByStore method of ProductService, the one that takes five arguments? List them, and tell me how you told it apart from the other listByStore methods.
```

```
Use the find-usages skill. Who calls LanguageService.toLocale, directly and through other methods, up to three levels? Count the callers at each level.
```

**Then, on your own:** run a plain text search for `listByStore(` yourself. How many hits do you get, and why is that number different from the agent's?

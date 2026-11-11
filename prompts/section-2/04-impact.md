# 2.4 Estimate the blast radius of a change

**Goal:** for four proposed changes, get an impact report, check its evidence, and decide the size yourself.
**Time:** about 15 minutes. The agent only reads the code; nothing is changed.

Paste each change as its own request:

```
/impact Rename InitializationDatabase.isEmpty.
```

```
/impact Change the return type of LanguageService.toLocale.
```

```
/impact Change the return type of ProductService.saveProduct.
```

```
/impact Add a required column to the Customer entity (table CUSTOMER).
```

For each report, check:

1. Does every number have a file and line? Open two of them.
2. Does the "Rule hit" line name the rule and the numbers behind the size?
3. Did the agent search for links the compiler does not check, and does the "Not verified" section say what it could not see?
4. Is the confidence line separate from the size?

**Then, on your own:** the size is only a suggestion. Would you accept it? Which change would you want a second person to look at, and what would you test first?

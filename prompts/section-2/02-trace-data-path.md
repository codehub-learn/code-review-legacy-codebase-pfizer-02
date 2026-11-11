# 2.2 Trace a data path

**Goal:** follow one value from the database column to the JSON field, and see where it changes.
**Time:** about 10 minutes.

Paste:

```
/trace The price response contains the fields originalPrice and finalPrice. Where do they come from? Follow the value from the response object back to the database column, and tell me every place where it is converted, formatted or decided.
```

**Then, on your own:** which type does the amount have at each step? If someone changed the column type, which of the places the agent listed would have to change?

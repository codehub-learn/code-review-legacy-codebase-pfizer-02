# 2.1 Trace a call path

**Goal:** follow one request from the controller to the database, with the agent narrating every hop.
**Time:** about 10 minutes.

Paste:

```
/trace What happens when a client calls GET /api/v1/private/product/{sku}/price/{priceId}? Follow it from the controller to the database table and tell me what each hop does.
```

Then paste this follow-up:

```
Which hops go through an interface? For each one, how many classes implement it, and how do you know which one runs?
```

**Then, on your own:** open two hops the agent cites and read the lines. Does the code do what it says? Does anything in the path look wrong to you?

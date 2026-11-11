# 4.2 Verify a colleague's comments

**Goal:** check comments somebody else wrote, as you would before agreeing with them in a review. You did not write them and you have not seen the agent's view of them.
**Time:** about 10 minutes.

A colleague left these three comments. Paste the whole block:

```
/verify-review Three comments from a colleague, on three different branches.

1. review/pr-874, shopizer/sm-shop/src/main/java/com/salesmanager/shop/store/api/v1/product/ProductApi.java:303. This change removes the old /product/{id} route, so existing clients will get a 404.

2. review/pr-890, shopizer/sm-core/src/main/java/com/salesmanager/core/business/repositories/catalog/product/ProductRepository.java:21. existsBySku is still a native query, so the rewrite changes nothing.

3. review/pr-1054, shopizer/sm-core/src/main/java/com/salesmanager/core/business/services/payments/TransactionServiceImpl.java:210. domainService is not declared in this class.
```

Check:

1. For each comment: what did the verifier open and search before its verdict?
2. Are the verdicts supported by a line you can open yourself on the branch?
3. For a *keep*, did it check that the claim holds, or only that the line exists? For a *drop*, did it show the evidence against the claim?
4. What does the verifier say it could not check?

**Then, on your own:** the colleague's cited line numbers are real lines. Why is that not enough to trust a comment?

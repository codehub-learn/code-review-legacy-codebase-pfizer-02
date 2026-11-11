---
name: find-usages
version: 1.0.0
description: Find every caller of a method and every implementation of an interface, with evidence, and say how sure the count is. Use when asked who calls a method, where a class is used, which classes implement an interface, or before changing a signature.
---

# Find every caller and every implementation

A search hit is not a caller until you have opened it. Follow the rules `evidence` and `not-verified`.

## Steps

1. **Pin down the target.** Give the type, the method and its parameter list. If the method name has several overloads, say which one you mean and keep to it: count a call only when its arguments fit that overload.
2. **Find the implementations.** Search `implements`, `extends` and the interface name. For each implementing class say whether it is a Spring bean, its bean name, and any profile or qualifier. Include abstract base classes.
3. **Find the callers.** Search for the method name, then open each hit and decide: which type is the receiver (the declared type of the field or variable)? Does it reach the target (the interface, a supertype or an implementation)? Is the line live code (not a comment, not a string)?
4. **Skip what is not a caller.** Declarations, comments and Javadoc, commented-out blocks, calls on another type with the same method name, calls to another overload.
5. **Go up.** For each direct caller, find its callers, and again, to depth 3. Report distinct calling methods at each depth, and mark controller methods (they have no Java callers).
6. **Tests.** Count callers in `src/test` separately.
7. **Links the compiler does not check.** Search the non-Java files and strings for the class and method name: XML, properties, pointcut expressions, `@Qualifier` and bean names, `@Value` keys. Report each hit.
8. **Check the count a second way.** For example a name grep against your per-caller list. Explain every difference.

## Output

Show in the chat; save to `reports/usages-<name>.md` if asked. Sections:

1. Target (type, method, overload) and how you told overloads apart
2. Implementations (table: class, bean name, `path:line`)
3. Direct callers (table: caller `path:line`, receiver type, why it reaches the target)
4. Callers at depth 2 and 3 (counts, and the list)
5. Tests that call it
6. Non-Java references
7. Counts and the second check, with the commands used
8. Not verified

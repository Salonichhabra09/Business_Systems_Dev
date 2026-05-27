description: Full Salesforce code review against team standards
---

Review the Apex code in $ARGUMENTS following our CLAUDE.md standards.

Check for and categorize findings as BLOCKER, WARNING, or SUGGESTION:

BLOCKERS (fail review):
- SOQL or DML inside any loop
- Multiple triggers on the same object
- Business logic inside a trigger (not handler)
- with sharing missing without justification comment
- SOQL string concatenation with variables (injection risk)
- Hardcoded Salesforce record IDs

WARNINGS (should fix):
- Missing ApexDoc on public methods
- System.debug() left in code
- Test coverage below 95%
- Methods over 30 lines
- Classes over 300 lines
- No isEmpty() guard before DML
- Hardcoded status strings (use Custom Labels)

SUGGESTIONS (nice to have):
- Naming convention improvements
- Refactoring opportunities
- Missing null checks

End with a SUMMARY TABLE showing counts per category and a PASS/FAIL verdict.

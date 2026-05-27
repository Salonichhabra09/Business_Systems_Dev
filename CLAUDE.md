# ProjectUATv1 — Coding & Review Reference

Salesforce metadata project (API name: **Project UAT v 1**).
Read this file before writing or reviewing any code in this project.

---

## Project Structure

```
ProjectUATv1/
├── classes/          Apex classes — trigger managers, controllers, batch jobs, managers
├── lwc/              Lightning Web Components
├── staticresources/  CSS, JS libraries, images
├── labels/           Custom Labels (CustomLabels.labels)
├── messageChannels/  LWC Message Channels
├── scontrols/        Legacy S-Controls (do not add new ones)
├── package.xml       Metadata manifest
└── CLAUDE.md         This file
```

---

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Trigger manager (part 1) | `{Object}TriggerManager_1.cls` | `AccountTriggerManager_1` |
| Trigger manager (part 2+) | `{Object}TriggerManager_{N}.cls` | `AccountTriggerManager_2` |
| Trigger manager test | `{Object}TriggerManager_Tester.cls` | `AccountTriggerManager_Tester` |
| Object manager | `{Object}_Manager.cls` | `Account_Manager` |
| Object manager test | `{Object}_Manager_Tester.cls` | `Account_Manager_Tester` |
| Controller | `{Feature}Controller.cls` | `AccountOwnerController` |
| Controller test | `{Feature}Controller_Test.cls` or `{Feature}ControllerTest.cls` | `AccountOwnerControllerTest` |
| Batch job | `{Feature}Batch.cls` or `{Feature}Job.cls` | `Account_BulkApprovalJob` |
| Batch job test | `{Feature}Batch_Test.cls` or `{Feature}Job_Tester.cls` | `AccountBulkApprovalJob_Tester` |
| Schedulable | `{Feature}Schedulable.cls` | `Account_BulkApprovalJobSchedulable` |
| LWC component | `camelCase/` folder | `debtManagementComponent` |

---

## Trigger Architecture

Triggers delegate all logic to manager classes — no business logic lives inside `.trigger` files.

```
Account_Trigger (trigger file)
  └── beforeUpdate → AccountTriggerManager_1.beforeAccountValidation()
                  → AccountTriggerManager_1.changeAccRecordType()
                  → AccountTriggerManager_1.mapsalesTeamRegionAndsuperMDRegionFromTerritory()
                  → AccountTriggerManager_1.beforeAccountSanction()
  └── afterUpdate  → AccountTriggerManager_2.*
  └── afterDelete  → AccountTriggerManager_2.afterAccDelete()
  └── afterUndelete→ AccountTriggerManager_2.afterAccUndelete()
  └── beforeInsert → AccountTriggerManager_2.beforeAccInsert()
```

When adding logic to an existing trigger, add it to the appropriate existing manager class.
Split into a new `_N` class only when the existing class is already large.

---

## Apex — Governor Limit Rules (enforce on every review)

### SOQL
- Never put a SOQL query inside a `for` loop — collect IDs first, query once outside.
- Use `Map<Id, SObject>` to avoid repeated `.get()` calls in loops.
- Use `AccountCurrencyVsLBU__c.getAll()` and similar `getAll()` / `getValues()` patterns for Custom Settings — they do not consume SOQL queries.
- Prefer `FeatureManagement.checkPermission()` over profile/permission-set SOQL queries.
- Use Custom Labels for profile ID lists and thresholds instead of querying `Profile`.

### DML
- Never put DML inside a `for` loop.
- Always guard DML with a size check: `if(!list.isEmpty()) { update list; }`.
- Use `Database.update(list, false)` when partial success is acceptable.
- `@future` methods (like `Account_Manager.updateNumberOfContacts`) cannot be called from another `@future` or `Queueable` context — check the call site.

### Collections
- Avoid O(n×m) nested loops over SObject lists. Build a `Map` keyed by the join field and look up in O(1).
- Always check `map.get(key) != null` before accessing fields on the result.

---

## Apex — Code Quality Rules

### Null safety
- After a `Map.get()` call, always null-check before accessing fields on the result.
  ```apex
  // Wrong — throws NPE if territory was deleted
  acc.Region_Global__c = territoryMap.get(terrId).Region__c;

  // Correct
  Territory__c terr = territoryMap.get(terrId);
  if(terr != null) { acc.Region_Global__c = terr.Region__c; }
  ```

### Boolean logic
- When restricting to "NOT A AND NOT B", use `&&` — using `||` makes the condition always true.
  ```apex
  // Wrong — always true
  if(acc.Status__c != 'Approved' || acc.Status__c != 'Archived')

  // Correct
  if(acc.Status__c != 'Approved' && acc.Status__c != 'Archived')
  ```

### Dead code
- Remove commented-out code blocks before merging. Use git history for old versions.
- Remove unused variable declarations (sets, strings, booleans that are never read).

### Comments
- Do not comment WHAT the code does — well-named variables already do that.
- Only comment WHY: a non-obvious business rule, a governor-limit workaround, or a Salesforce platform quirk.
- Keep inline comments to one short line maximum.

### Error messages
- Keep user-facing `addError()` messages consistent with existing messages in the same class.
- Do not expose internal field names or technical details in error messages.

---

## Permission / Profile Pattern

This project uses **Custom Labels** and **Permission Sets** instead of SOQL profile queries.

| What to check | How to check it |
|---------------|-----------------|
| Is user a System Admin? | `System.Label.SystemAdmins_Profiles.split(',').contains(userprofileid)` |
| Is user OAT? | `FeatureManagement.checkPermission('OATs')` |
| Is user SOE? | `FeatureManagement.checkPermission('SOE')` |
| Is user Legal Team? | `System.Label.LegalTeam_Profiles.contains(userprofileid)` |
| Is user Account Approver? | `userprofileid == System.Label.Account_Approvers` |
| Has easement permission? | Query `PermissionSetAssignment` for `Users_with_Account_edit_permission` |

Always use `UserInfo.getProfileId().substring(0, 15)` to get the 15-char profile ID for label comparisons.

---

## Key Custom Settings & Labels

| Name | Type | Purpose |
|------|------|---------|
| `AccountCurrencyVsLBU__c` | Custom Setting | Maps BU code → default ISO currency |
| `AccountRecordTypeId__c` | Custom Setting | Stores target Record Type ID for status transitions |
| `AccountMergingPermission__c` | Custom Setting | Emails of users allowed to merge/delete accounts |
| `BU_to_GCSC_Owner_Mapping__mdt` | Custom Metadata | Maps BU → GCSC Account Owner |
| `Field_Value_Setting__c` | Custom Setting | Key-value config store (e.g. special Account record IDs) |
| `Account_Approvers` | Custom Label | 15-char profile ID for account approval |
| `SystemAdmins_Profiles` | Custom Label | Comma-separated System Admin profile IDs |
| `LegalTeam_Profiles` | Custom Label | Legal Team profile ID |
| `Account_Sanction_Threshold` | Custom Label | Sanction automation delay in hours (24, 48, or 72) |

---

## Testing Standards

- **Never use `@isTest(SeeAllData=true)`** — tests must create their own data. Org-data tests are fragile and fail in sandboxes with different data.
- Test classes follow the naming pattern `{ClassName}_Test` or `{ClassName}Tester` or `{ClassName}_Tester`.
- Every trigger manager method must have a corresponding test that covers:
  - The happy path (change is allowed)
  - The restriction path (change is blocked, `addError` is verified)
  - Bulk scenario (200+ records)
- Use `TestDataUtility.cls` (already in the project) to create test records — do not duplicate setup logic across test classes.

---

## Documentation Standards

Every class must have a class-level header block covering:
- **Purpose** — what the class does and when it runs
- **Trigger context** — which trigger event calls each method
- **Key dependencies** — Custom Labels, Custom Settings, Permission Sets, Public Groups

Every method must have a doc comment covering:
- Trigger context (if applicable)
- What the method does, including business rules
- `@param` for each parameter
- `@return` if the method returns a value

Inner classes (`FlowRequest`, `FlowResponse`, etc.) must have a one-line class comment and inline field comments.

---

## Code Review Checklist

Before approving or submitting any change, verify:

**Governor Limits**
- [ ] No SOQL inside a loop
- [ ] No DML inside a loop
- [ ] DML is guarded with an empty-list check
- [ ] `@future` is not called from another async context

**Logic**
- [ ] No always-true boolean conditions (`||` where `&&` was intended)
- [ ] All `Map.get()` results null-checked before field access
- [ ] No hardcoded profile names or IDs — use Custom Labels or Permission Sets

**Code Quality**
- [ ] No commented-out code blocks
- [ ] No unused variable declarations
- [ ] No `@isTest(SeeAllData=true)`
- [ ] New methods have doc comments
- [ ] Error messages match the style of existing messages in the class

**Tests**
- [ ] New logic has test coverage for both allowed and restricted paths
- [ ] Bulk scenarios tested (200+ records)
- [ ] Test data created in the test class, not pulled from org

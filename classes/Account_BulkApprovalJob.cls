/**
 * Purpose: Batch job that resets Account status to 'Unapproved', submits for approval,
 *          and auto-approves, for a supplied list of Account IDs.
 * Key dependencies: Account approval process must be active; StaticResource used when
 *                   accountIdsCSV is null.
 */
global class Account_BulkApprovalJob implements Database.Batchable<sObject>, Database.Stateful
{
    global final String Query;
    global final List<Id> accountIds;
    global String Log = 'Id,DNumber,Initial Status,Updated,Submitted,Approved,Result,Error';

    /**
     * @param accountIdsCSV                   Comma-separated Account IDs, or null to load from static resource.
     * @param accountIdsCSVStaticResourceName Static resource name containing the CSV (used when accountIdsCSV is null).
     */
    global Account_BulkApprovalJob(String accountIdsCSV, String accountIdsCSVStaticResourceName)
    {
        if (accountIdsCSV == null)
        {
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :accountIdsCSVStaticResourceName LIMIT 1];
            accountIdsCSV = sr.Body.toString().trim();
        }
        // Parse into a typed Id list so the query uses a bind variable (prevents SOQL injection)
        accountIds = new List<Id>();
        for (String s : accountIdsCSV.split(','))
        {
            accountIds.add((Id) s.trim());
        }
        Query = 'SELECT Id, Account_Number__c, Status__c, NumberOfContacts__c FROM Account WHERE Id IN :accountIds';
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Account> accounts = (List<Account>) scope;
        Set<Id> batchIds = (new Map<Id, Account>(accounts)).keySet();

        // Single aggregate query for all contact counts — not one per account
        Map<Id, Integer> contactCountByAccId = new Map<Id, Integer>();
        for (Account acc : accounts)
        {
            contactCountByAccId.put(acc.Id, 0);
        }
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) cnt FROM Contact
            WHERE AccountId IN :batchIds GROUP BY AccountId
        ]) {
            contactCountByAccId.put((Id) ar.get('AccountId'), (Integer) ar.get('cnt'));
        }

        // Per-account tracking
        Map<Id, String>  initialStatus = new Map<Id, String>();
        Map<Id, Boolean> didUpdate     = new Map<Id, Boolean>();
        Map<Id, Boolean> didSubmit     = new Map<Id, Boolean>();
        Map<Id, Boolean> didApprove    = new Map<Id, Boolean>();
        Map<Id, String>  errors        = new Map<Id, String>();
        Map<Id, String>  result        = new Map<Id, String>();
        for (Account acc : accounts)
        {
            initialStatus.put(acc.Id, acc.Status__c);
            didUpdate.put(acc.Id, false);
            didSubmit.put(acc.Id, false);
            didApprove.put(acc.Id, false);
            errors.put(acc.Id, '');
            result.put(acc.Id, 'No Action');
        }

        // ── Phase 1: Collect and bulk-update accounts that need a status reset ─
        List<Account> toUpdate = new List<Account>();
        for (Account acc : accounts)
        {
            if (acc.Status__c == 'Approved') continue;
            if (acc.Status__c != 'Unapproved' || acc.NumberOfContacts__c == null)
            {
                if (acc.NumberOfContacts__c == null)
                {
                    acc.NumberOfContacts__c = contactCountByAccId.get(acc.Id);
                }
                if (acc.NumberOfContacts__c == 0)
                {
                    errors.put(acc.Id, 'Number of Contacts is equal to 0. ');
                }
                acc.Status__c = 'Unapproved';
                toUpdate.add(acc);
                didUpdate.put(acc.Id, true);
            }
        }
        if (!toUpdate.isEmpty())
        {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++)
            {
                if (!updateResults[i].isSuccess())
                {
                    Id accId = toUpdate[i].Id;
                    errors.put(accId, errors.get(accId) + updateResults[i].getErrors()[0].getMessage() + ' ');
                    result.put(accId, 'Failed');
                    didUpdate.put(accId, false);
                }
            }
        }

        // ── Phase 2: Bulk-submit for approval ─────────────────────────────────
        List<Approval.ProcessSubmitRequest> submitReqs  = new List<Approval.ProcessSubmitRequest>();
        List<Id>                            submitAccIds = new List<Id>();
        for (Account acc : accounts)
        {
            if (result.get(acc.Id) == 'Failed' || acc.Status__c == 'Approved') continue;
            if (didUpdate.get(acc.Id) || acc.Status__c == 'Unapproved')
            {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval.');
                req.setObjectId(acc.Id);
                req.setNextApproverIds(new Id[] { UserInfo.getUserId() });
                submitReqs.add(req);
                submitAccIds.add(acc.Id);
            }
        }

        Map<Id, List<Id>> workItemsByAccId = new Map<Id, List<Id>>();
        if (!submitReqs.isEmpty())
        {
            List<Approval.ProcessResult> submitResults = Approval.process(submitReqs, false);
            for (Integer i = 0; i < submitResults.size(); i++)
            {
                Approval.ProcessResult res = submitResults[i];
                Id accId = submitAccIds[i];
                if (res.isSuccess())
                {
                    didSubmit.put(accId, true);
                    workItemsByAccId.put(accId, res.getNewWorkitemIds());
                }
                else
                {
                    errors.put(accId, errors.get(accId) + 'Submit failed. ');
                    result.put(accId, 'Failed');
                }
            }
        }

        // For accounts already in 'Submitted for Approval', look up pending work items
        Set<Id> needsWorkItemLookup = new Set<Id>();
        for (Account acc : accounts)
        {
            if (result.get(acc.Id) == 'Failed' || acc.Status__c == 'Approved') continue;
            if (!didSubmit.get(acc.Id) && acc.Status__c == 'Submitted for Approval')
            {
                needsWorkItemLookup.add(acc.Id);
            }
        }
        if (!needsWorkItemLookup.isEmpty())
        {
            Map<Id, Id> accountByPiId = new Map<Id, Id>();
            for (ProcessInstance pi : [
                SELECT Id, TargetObjectId FROM ProcessInstance
                WHERE TargetObjectId IN :needsWorkItemLookup AND Status = 'Pending'
            ]) {
                accountByPiId.put(pi.Id, pi.TargetObjectId);
            }
            for (ProcessInstanceWorkItem wi : [
                SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkItem
                WHERE ProcessInstanceId IN :accountByPiId.keySet()
            ]) {
                Id accId = accountByPiId.get(wi.ProcessInstanceId);
                if (accId != null)
                {
                    if (!workItemsByAccId.containsKey(accId))
                    {
                        workItemsByAccId.put(accId, new List<Id>());
                    }
                    workItemsByAccId.get(accId).add(wi.Id);
                }
            }
        }

        // ── Phase 3: Bulk-approve ─────────────────────────────────────────────
        List<Approval.ProcessWorkitemRequest> approvalReqs  = new List<Approval.ProcessWorkitemRequest>();
        List<Id>                              approvalAccIds = new List<Id>();
        for (Account acc : accounts)
        {
            if (result.get(acc.Id) == 'Failed' || acc.Status__c == 'Approved') continue;
            if (didSubmit.get(acc.Id) || acc.Status__c == 'Submitted for Approval')
            {
                List<Id> wis = workItemsByAccId.get(acc.Id);
                if (wis != null && !wis.isEmpty())
                {
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkitemId(wis[0]);
                    req.setComments('Approving request.');
                    req.setAction('Approve');
                    req.setNextApproverIds(new Id[] { UserInfo.getUserId() });
                    approvalReqs.add(req);
                    approvalAccIds.add(acc.Id);
                }
            }
        }
        if (!approvalReqs.isEmpty())
        {
            List<Approval.ProcessResult> approvalResults = Approval.process(approvalReqs, false);
            for (Integer i = 0; i < approvalResults.size(); i++)
            {
                Approval.ProcessResult res = approvalResults[i];
                Id accId = approvalAccIds[i];
                if (res.isSuccess())
                {
                    didApprove.put(accId, true);
                    result.put(accId, 'Success');
                }
                else
                {
                    errors.put(accId, errors.get(accId) + 'Approval failed. ');
                    result.put(accId, 'Failed');
                }
            }
        }

        // ── Build log lines (join at end avoids O(n²) string concat) ──────────
        List<String> lines = new List<String>();
        for (Account acc : accounts)
        {
            String err = errors.get(acc.Id);
            lines.add(
                acc.Id + ',' +
                acc.Account_Number__c + ',' +
                initialStatus.get(acc.Id) + ',' +
                (didUpdate.get(acc.Id)  ? 'Yes' : 'No') + ',' +
                (didSubmit.get(acc.Id)  ? 'Yes' : 'No') + ',' +
                (didApprove.get(acc.Id) ? 'Yes' : 'No') + ',' +
                result.get(acc.Id) + ',' +
                (String.isBlank(err)    ? 'None' : err.replace(',', ' '))
            );
        }
        Log += '\n' + String.join(lines, '\n');
    }

    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id = :BC.getJobId()
        ];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { job.CreatedBy.Email });
        mail.setSubject('Account Approval Job ' + job.Status);
        mail.setPlainTextBody(
            'The batch Apex job processed ' + job.TotalJobItems +
            ' batches with ' + job.NumberOfErrors + ' failures.'
        );
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.filename    = 'apexjoblog_' + Datetime.now() + '.csv';
        attach.ContentType = 'text/plain';
        attach.setBody(Blob.valueOf(Log));
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}

/*Created By: Prabhat Arora: July 2025, Q3 Sprint 1 for SSE-27016
    #This covers the functionality of updating the flag on Account level "Has Recent Orders?" to True, if there is an Order asscociated with a particular account in last 18 months.
    #This is scheduled to run on daily basis, UK time 8:00 a.m
    #This is created to support the requirement of the critria of account screening on WorldCheck Refinitiv tool.
*/    
global class UpdateRecentOrderFlagBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
            return Database.getQueryLocator([
            SELECT Id,Has_Recent_Orders__c FROM Account
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Account> accounts) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        // Define the cutoff date: 18 months ago from today
        Date cutoffDate = Date.today().addMonths(-18);

        // Map to store whether each account has a recent order
        Map<Id, Boolean> hasRecentOrderMap = new Map<Id, Boolean>();

        // Query Orders created in the last 18 months
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id)
            FROM Order
            WHERE AccountId IN :accountIds
            AND CreatedDate >= :cutoffDate
            GROUP BY AccountId
        ]) {
            Id accId = (Id)ar.get('AccountId');
            hasRecentOrderMap.put(accId, true);
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : accounts) {
            Boolean shouldBeTrue = hasRecentOrderMap.containsKey(acc.Id);
                if (acc.Has_Recent_Orders__c != shouldBeTrue) {
                acc.Has_Recent_Orders__c = shouldBeTrue;
                accountsToUpdate.add(acc);
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Optionally log or send notifications
    }
}
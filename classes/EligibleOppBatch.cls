/**
* ----------------------------------------------------------------------------------------
* Class Name     : EligibleOppBatch
* Author         : Prabhat Arora
* Created Date   : 29-08-2025
* Purpose        : 
*   - This batch job identifies Opportunities eligible for auto-close
*   - Criteria:
*        1. Qualified_for_Auto_Close__c = TRUE  (Boolean formula field covering all conditions)       
*        2. Exclude Opportunities having any OpportunityLineItem:
*             a. With Status__c = 'End of Life'
*             b. OR created by the Excel Connector API User
*   - If eligible, sets Eligible_for_Auto_Close__c = TRUE
*
* Usage          : Scheduled via EligibleOppScheduler to run daily at specific time.
* ----------------------------------------------------------------------------------------
*/

public with sharing class EligibleOppBatch implements Database.Batchable<SObject> {
    
    //Start Method: Defines the query to collect all Opportunities that are potentially Eligible.
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Opportunity
            WHERE Qualified_for_Auto_Close__c = true
        ]);
    }
    
    /*
* Execute method
* Called for each batch "scope" of Opportunities.
*  - Collects Opportunity Ids in current scope
*  - Queries related OpportunityLineItems
*  - Marks Opportunities with disqualifying OLIs (End of Life OR created by Excel Connector)
*  - Updates only Opportunities that remain eligible
*/
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : scope) {
            oppIds.add(opp.Id);
        }
        
        // Find disqualified Opps based on OLI conditions
        Set<Id> disqualifiedOpps = new Set<Id>();
        for (OpportunityLineItem oli : [
            SELECT OpportunityId
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIds
            AND (Status__c = 'End of Life' OR CreatedById = :Label.ExcelConnectorUserId)
        ]) {
            disqualifiedOpps.add(oli.OpportunityId);
        }
        
        //JIRA : SSE-28977 Changes START
        // Find disqualified Opps based on If original opp is extension then not allow for auto close 
        for (Opportunity opp : [
            SELECT Id
            FROM Opportunity
            WHERE Id IN :oppIds
            AND Original_Opportunity__c != null
            AND Original_Opportunity__r.Business_Type__c = 'Extension'
        ]) {
            disqualifiedOpps.add(opp.Id);
        }
        
        //JIRA : SSE-28977 Changes END
        
        
        // Update only qualifying Opps
        List<Opportunity> updates = new List<Opportunity>();
        for (Opportunity opp : scope) {
            if (!disqualifiedOpps.contains(opp.Id)) {
                opp.Eligible_for_Auto_Close__c = true;
                updates.add(opp);
            }
        }
        
        if (!updates.isEmpty()) {
            update updates;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // Optional: logging, notifications, chaining
    }
}
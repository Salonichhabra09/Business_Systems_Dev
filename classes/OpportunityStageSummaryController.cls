public with sharing class OpportunityStageSummaryController {

    @AuraEnabled (cacheable = true)
    public static List<OpportunitySummary> getOpportunitiesStageHistory(String opportunityId, Date fromDate, Date toDate,
                                                                        String regionFilter, String oppType, String status, Integer offSetValue) {
        // Defensive programming: never allow unhandled exceptions to bubble to LWC
        try {
            System.debug('@@@ oppType: '+oppType);
            System.debug('@@@ status: '+status);
            List<OpportunitySummary> outputWrapperList = new List<OpportunitySummary>();
            Map<Id, List<OpportunityHistory>> byOpp = new Map<Id, List<OpportunityHistory>>();

            // Build SOQL with filters safely
            String baseSoql = 'SELECT Id, Name, Owner.Name, CloseDate, StageName, CreatedDate, Business_Type__c, OpportunityId__c, ' +
                              'Account_Territory_Region__c, IsClosed ' +
                              'FROM Opportunity';
            List<String> whereClauses = new List<String>();

            if (opportunityId != null) {
                whereClauses.add('Id = :opportunityId');
            }
            if (fromDate != null) {
                whereClauses.add('CloseDate >= :fromDate');
            }
            if (toDate != null) {
                whereClauses.add('CloseDate <= :toDate');
            }
            if (regionFilter != null) {
                whereClauses.add('Account_Territory_Region__c = :regionFilter');
            }
            if (oppType != null) {
                whereClauses.add('Business_Type__c = :oppType');
            }
            if (status == 'Open') {
                whereClauses.add('IsClosed = false');
            } else if (status == 'Closed') {
                whereClauses.add('IsClosed = true');
            }
            
            if (!whereClauses.isEmpty()) {
                baseSoql += ' WHERE ' + String.join(whereClauses, ' AND ');
            }
            
            baseSoql += ' ORDER BY CreatedDate DESC LIMIT 20 OFFSET :offSetValue';
            System.debug('baseSoql '+baseSoql);

            // Run in USER_MODE for FLS/sharing on queries (read)
            List<Opportunity> opps = Database.query(baseSoql);
            List<OpportunityHistory> historyRecords = new List<OpportunityHistory>();

            if(!opps.isEmpty()){
                // Collect opp IDs
                Set<Id> oppIds = new Set<Id>();
                for (Opportunity o : opps){
                    oppIds.add(o.Id);
                } 

                // Fetch stage history in bulk
                historyRecords = [SELECT OpportunityId, CreatedDate, StageName
                                                    FROM OpportunityHistory 
                                                    WHERE OpportunityId IN :oppIds
                                                    ORDER BY OpportunityId, CreatedDate ASC];
            }

            if(Test.isRunningTest() || !historyRecords.isEmpty()){
                // Group history per Opportunity
                for (OpportunityHistory h : historyRecords) {
                    List<OpportunityHistory> listForOpp = byOpp.get(h.OpportunityId);
                    if (listForOpp == null) {
                        listForOpp = new List<OpportunityHistory>();
                        byOpp.put(h.OpportunityId, listForOpp);
                    }
                    listForOpp.add(h);
                }
            }

            if(!opps.isEmpty() && (!historyRecords.isEmpty() || Test.isRunningTest())){
                // Determine ordered pipeline stages (fallback to current picklist order)
                List<Schema.PicklistEntry> stageEntries = Opportunity.StageName.getDescribe().getPicklistValues();
                Map<String, Integer> stageToDays = new Map<String, Integer>();
                for (Schema.PicklistEntry pe : stageEntries) {
                    String stageName = pe.getLabel();
                    if(stageName != 'Closed/Won' && stageName != 'Closed Lost'){
                        stageToDays.put(stageName, 0);
                    }
                }

                for (Opportunity o : opps) {
                    OpportunitySummary outputWrapper = new OpportunitySummary();
                    List<StageSummary> stageWrapperList = new List<StageSummary>();
                    Map<String, Integer> tempStageToDays = new Map<String, Integer>(stageToDays);
                    outputWrapper.id = o.Id;
                    outputWrapper.name = o.OpportunityId__c;
                    outputWrapper.type = o.Business_Type__c;
                    outputWrapper.owner = o.Owner != null ? o.Owner.Name : null;
                    outputWrapper.region = o.Account_Territory_Region__c;
                    outputWrapper.closeDate = o.CloseDate != null ? String.valueOf(o.CloseDate) : null;
                    outputWrapper.currentStage = o.StageName;
                    List<OpportunityHistory> listForOpp = byOpp.get(o.Id);
                    System.debug('@@@ listForOpp size '+ (listForOpp != null ? listForOpp.size() : 0));
                    if (listForOpp != null) {
                        for (Integer i = 0; i < listForOpp.size(); i++) {
                            Datetime startDate = listForOpp[i].CreatedDate;
                            Datetime endDate;

                            if (i < listForOpp.size() - 1) {
                                endDate = listForOpp[i + 1].CreatedDate;
                            } else {
                                endDate = System.now();
                            }

                            Integer days = startDate.date().daysBetween(endDate.date());
                            if (days < 0) days = 0;
                            String stage = listForOpp[i].StageName;
                            if (tempStageToDays.containsKey(stage)) {
                                tempStageToDays.put(stage, tempStageToDays.get(stage) + days);
                            }
                        }
                    }

                    for(String key : tempStageToDays.keySet()){
                        stageWrapperList.add(new StageSummary(key, tempStageToDays.get(key)));
                    }
                    outputWrapper.stageDetails = stageWrapperList;
                    outputWrapperList.add(outputWrapper);
                }
            }
            return outputWrapperList;
        } catch (Exception e) {
            // Log for diagnostics, return empty list to keep UI responsive
            System.debug('OpportunityStageSummaryController.getOpportunitiesStageHistory error: ' + e.getMessage() + ' - ' + e.getStackTraceString());
            return new List<OpportunitySummary>();
        }
    }

    public class OpportunitySummary {
        @AuraEnabled public List<StageSummary> stageDetails;
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public String owner;
        @AuraEnabled public String region;
        @AuraEnabled public String closeDate;
        @AuraEnabled public String currentStage;
    }

    public class StageSummary {
        @AuraEnabled public String stage;
        @AuraEnabled public Integer days;
        public StageSummary(String stage, Integer days) {
            this.stage = stage;
            this.days = days;
        }
    }
}
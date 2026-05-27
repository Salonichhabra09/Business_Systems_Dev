public with sharing class CampaignLeadMetricsBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    private Integer stepNo;
    public Set<String> leadIdSet = new Set<String>();
    public Set<String> campaignIdSet = new Set<String>();
    public list<Lead> leadsToUpdate = new list<Lead>();
    public Map<Id, List<CampaignMember>> leadToCampaignMembers = new Map<Id, List<CampaignMember>>();

    public CampaignLeadMetricsBatch(Integer stepNo){//}, Set<String> leadIdSet) {
        this.stepNo = stepNo;
        //this.leadIdSet = leadIdSet;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        System.debug('start leadIdSet '+ this.leadIdSet.size());
        if(this.stepNo == 1){
            System.debug('step initial');
            List<Campaign> campaignList = [SELECT Id, Offer__c, Type 
                                                    FROM Campaign 
                                                    WHERE LastModifiedDate >= LAST_N_DAYS:1];
                                                    /*AND (Offer__c != Old_Asset__c
                                                    OR Type != Old_Tactic__c)];*/
            for(Campaign campaign : campaignList) {
                this.campaignIdSet.add(campaign.Id);
            }
        }
        /*if(this.stepNo == 999999){
            List<CampaignMember> campaignMemberList = [SELECT Id, LeadId 
                                                    FROM CampaignMember 
                                                    WHERE CreatedDate >= LAST_N_DAYS:1
                                                    AND LeadId != null
                                                    AND Lead.IsConverted = false];
            for(CampaignMember campaignMember : campaignMemberList) {
                leadIdSet.add(campaignMember.LeadId);
            }
        }
        if(this.stepNo == 999999){
            List<CampaignMember> campaignMemberList = [SELECT Id, LeadId 
                                                    FROM CampaignMember 
                                                    WHERE LeadId != null
                                                    AND Lead.IsConverted = false
                                                    AND IsDeleted = true
                                                    ALL ROWS];
            for(CampaignMember campaignMember : campaignMemberList) {
                leadIdSet.add(campaignMember.LeadId);
            }
        }*/
        if(this.stepNo == 1){
            System.debug('step 1');
            //query = 'SELECT Id, LeadId FROM CampaignMember WHERE CampaignId IN \'' + String.escapeSingleQuotes(this.campaignIdSet) + '\' AND LeadId != null AND Lead.IsConverted = false';
            String campaignIds = '\'' + String.join(new Set<String>(this.campaignIdSet), '\',\'') + '\'';
            query = 'SELECT Id, LeadId FROM CampaignMember ' +
                        'WHERE CampaignId IN (' + campaignIds + ') ' +
                        'AND LeadId != null ' +
                        'AND Lead.IsConverted = false';
        }else if(this.stepNo == 2){
            System.debug('step 2');
            System.debug('leadIdSet '+this.leadIdSet);
            String leadIds = '\'' + String.join(new Set<String>(this.leadIdSet), '\',\'') + '\'';
            System.debug('leadIds '+leadIds);
            query = 'SELECT Id, LeadId, CampaignId, '+
                        'Campaign.Offer__c, Campaign.Type, '+
                        'Campaign.CreatedDate, Campaign.Name '+
                        'FROM CampaignMember '+
                        'WHERE LeadId IN (' + leadIds + ') ' +
                        'AND LeadId != null AND Lead.IsConverted = false';
        }else if(this.stepNo == 3){
            System.debug('step 3');
            String leadIdsToUpdate = '\'' + String.join(new Set<String>(this.leadIdSet), '\',\'') + '\'';
            query = 'SELECT Id, Asset_Range__c, Tactic_Range__c, Last_Campaign_Tactic__c, '+
                    'Last_Campaign_Asset__c, Number_of_Campaigns__c,Number_of_Webinar__c, '+
                    'Number_of_Contact_US__c, Number_of_Events__c FROM Lead '+
                    'WHERE Id IN (' + leadIdsToUpdate + ') ' +
                    'AND IsConverted = false';
        }
        System.debug('query '+ query);
        return Database.getQueryLocator(query);   
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        List<Lead> leadList = new List<Lead>();
        System.debug('scope size '+ scope.size());
        for (SObject s : scope) {
            System.debug('scope v '+ s);
            if (s instanceof CampaignMember) {
                CampaignMember campaignMember = (CampaignMember)s;
                System.debug('scope cm '+ s);
                campaignMemberList.add(campaignMember);
            } else if (s instanceof Lead) {
                Lead lead = (Lead)s;
                System.debug('scope l '+ s);
                leadList.add(lead);
            }
        }

        if (!campaignMemberList.isEmpty()) {
            for(CampaignMember cm : campaignMemberList){
                if(this.stepNo == 1){
                    this.leadIdSet.add(String.valueOf(cm.LeadId));  
                } 
                else if(this.stepNo == 2){
                    if (!this.leadToCampaignMembers.containsKey(cm.LeadId)) {
                        this.leadToCampaignMembers.put(cm.LeadId, new List<CampaignMember>());
                    }
                    this.leadToCampaignMembers.get(cm.LeadId).add(cm);
                } 
            }
            System.debug('leadIdSet '+ this.leadIdSet.size());
        }

        if (!leadList.isEmpty()) {
            // Process each lead
            for (Lead lead : leadList) {
                List<CampaignMember> campaignMembers = this.leadToCampaignMembers.get(lead.Id);
                
                if (campaignMembers == null || campaignMembers.isEmpty()) {
                    // No campaigns - reset all fields to 0/null
                    resetLeadCampaignFields(lead);
                } else {
                    // Calculate statistics
                    LeadCampaignService.CampaignStatistics stats = LeadCampaignService.calculateCampaignStatistics(campaignMembers);
                    // Update lead fields
                    lead.Asset_Range__c = stats.uniqueAssetsCount;
                    lead.Number_of_Contact_US__c = stats.contactUsCampaignCount;
                    lead.Number_of_Campaigns__c = stats.totalCampaignCount;
                    lead.Tactic_Range__c = stats.uniqueTacticsCount;
                    lead.Last_Campaign_Tactic__c = stats.latestCampaignTactic;
                    lead.Number_of_Webinar__c = stats.webinarCampaignCount;
                    lead.Last_Campaign_Asset__c = stats.latestCampaignAsset;
                    lead.Number_of_Events__c = stats.eventCampaignCount;
                }
                this.leadsToUpdate.add(lead);
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        // No post-processing required for this batch job
        
        Integer stepNum = 0;
        System.debug('before stepNo '+ this.stepNo);
        System.debug('before stepNum '+ stepNum);
        if(this.stepNo == 1){
            stepNum = 2;
        }else if(this.stepNo == 2){
            stepNum = 3;
        }
        System.debug('after stepNo '+ this.stepNo);
        System.debug('after stepNum '+ stepNum);
        if(this.stepNo != 3){
            System.debug('finish leadIdSet '+ this.leadIdSet.size());
            CampaignLeadMetricsBatch b = new CampaignLeadMetricsBatch(stepNum);
            b.leadIdSet = this.leadIdSet;
            Database.executeBatch(b, 2000);
        }
        if(!this.leadsToUpdate.isEmpty()){
            Database.update(this.leadsToUpdate, false);
        }
    }

    /**
     * @description Resets all campaign-related fields on a Lead to default values
     * @param lead Lead record to reset
     */
    private void resetLeadCampaignFields(Lead lead) {
        lead.Asset_Range__c = 0;
        lead.Number_of_Contact_US__c = 0;
        lead.Number_of_Campaigns__c = 0;
        lead.Tactic_Range__c = 0;
        lead.Last_Campaign_Tactic__c = null;
        lead.Number_of_Webinar__c = 0;
        lead.Last_Campaign_Asset__c = null;
        lead.Number_of_Events__c = 0;
    }

    public class CampaignStatistics {
        public Integer uniqueAssetsCount { get; set; }
        public Integer contactUsCampaignCount { get; set; }
        public Integer totalCampaignCount { get; set; }
        public Integer uniqueTacticsCount { get; set; }
        public String latestCampaignTactic { get; set; }
        public Integer webinarCampaignCount { get; set; }
        public String latestCampaignAsset { get; set; }
        public Integer eventCampaignCount { get; set; }
        
        public CampaignStatistics() {
            this.uniqueAssetsCount = 0;
            this.contactUsCampaignCount = 0;
            this.totalCampaignCount = 0;
            this.uniqueTacticsCount = 0;
            this.latestCampaignTactic = null;
            this.webinarCampaignCount = 0;
            this.latestCampaignAsset = null;
            this.eventCampaignCount = 0;
        }
    }
}
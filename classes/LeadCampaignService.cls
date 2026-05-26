/**
 * @description Service class to handle campaign-related calculations on Lead records
 * @author Aashi
 * @date 24-Apr-2026
 */
public without sharing class LeadCampaignService {
    
    /**
     * @description Updates campaign statistics on Lead records based on their associated campaigns
     * @param leadIds Set of Lead IDs to process
    */
    public static void updateLeadCampaignStatistics(Set<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty()) {
            return;
        }
        
        // Query all campaign members for the given leads with related campaign data
        Map<Id, List<CampaignMember>> leadToCampaignMembers = new Map<Id, List<CampaignMember>>();
        
        for (CampaignMember cm : [
            SELECT Id, LeadId, CampaignId, Campaign.Offer__c, Campaign.Type, 
                   Campaign.CreatedDate, Campaign.Name
            FROM CampaignMember 
            WHERE LeadId IN :leadIds
            AND LeadId != null
            AND Lead.IsConverted = false
            ORDER BY Campaign.CreatedDate DESC
        ]) {
            if (!leadToCampaignMembers.containsKey(cm.LeadId)) {
                leadToCampaignMembers.put(cm.LeadId, new List<CampaignMember>());
                // campaign member Id, Lead Id
            }
            leadToCampaignMembers.get(cm.LeadId).add(cm);
        }
        
        // Query leads to update
        List<Lead> leadsToUpdate = [
            SELECT Id, Asset_Range__c, Tactic_Range__c, 
            Last_Campaign_Tactic__c, Last_Campaign_Asset__c, Number_of_Campaigns__c,
            Number_of_Webinar__c, Number_of_Contact_US__c, Number_of_Events__c
            FROM Lead 
            WHERE Id IN :leadIds
            AND IsConverted = false
        ];
        
        // Process each lead
        for (Lead lead : leadsToUpdate) {
            List<CampaignMember> campaignMembers = leadToCampaignMembers.get(lead.Id);
            
            if (campaignMembers == null || campaignMembers.isEmpty()) {
                // No campaigns - reset all fields to 0/null
                lead.Asset_Range__c = 0;
                lead.Number_of_Contact_US__c = 0;
                lead.Number_of_Campaigns__c = 0;
                lead.Tactic_Range__c = 0;
                lead.Last_Campaign_Tactic__c = null;
                lead.Number_of_Webinar__c = 0;
                lead.Last_Campaign_Asset__c = null;
                lead.Number_of_Events__c = 0;
            } else {
                // Calculate statistics
                CampaignStatistics stats = calculateCampaignStatistics(campaignMembers);
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
        }
        
        // Update leads
        if (!leadsToUpdate.isEmpty()) {
            Database.update(leadsToUpdate, false);
        }
    }

    @future
    public static void updateLeadRecordsAsync(Set<Id> leadIds) {
        updateLeadCampaignStatistics(leadIds);
    }
    
    /**
     * @description Calculates campaign statistics from a list of campaign members
     * @param campaignMembers List of CampaignMember records
     * @return CampaignStatistics wrapper with calculated values
     */
    public static CampaignStatistics calculateCampaignStatistics(List<CampaignMember> campaignMembers) {
        CampaignStatistics stats = new CampaignStatistics();
        
        Set<String> uniqueAssets = new Set<String>();
        Set<String> uniqueTactics = new Set<String>();
        Integer contactUsCount = 0;
        Integer webinarCount = 0;
        Integer eventCount = 0;
        
        // Most recent campaign is first due to ORDER BY CreatedDate DESC
        CampaignMember mostRecentCampaign = campaignMembers[0];
        
        for (CampaignMember cm : campaignMembers) {
            // Count unique assets (Requirement 1)
            if (String.isNotBlank(cm.Campaign.Offer__c)) {
                uniqueAssets.add(cm.Campaign.Offer__c);
            }
            
            // Count Contact Us campaigns (Requirement 2)
            if (cm.Campaign.Offer__c == 'Contact Us') {
                contactUsCount++;
            }
            
            // Count unique tactics (Requirement 4)
            if (String.isNotBlank(cm.Campaign.Type)) {
                uniqueTactics.add(cm.Campaign.Type);
            }
            
            // Count Webinar campaigns (Requirement 6)
            if (cm.Campaign.Offer__c == 'Webinar') {
                webinarCount++;
            }
            
            // Count Event campaigns (Requirement 8)
            if (cm.Campaign.Offer__c == 'Event') {
                eventCount++;
            }
        }
        
        // Set statistics
        stats.uniqueAssetsCount = uniqueAssets.size();
        stats.contactUsCampaignCount = contactUsCount;
        stats.totalCampaignCount = campaignMembers.size(); // Requirement 3
        stats.uniqueTacticsCount = uniqueTactics.size();
        stats.latestCampaignTactic = mostRecentCampaign.Campaign.Type; // Requirement 5
        stats.webinarCampaignCount = webinarCount;
        stats.latestCampaignAsset = mostRecentCampaign.Campaign.Offer__c; // Requirement 7
        stats.eventCampaignCount = eventCount;
        
        return stats;
    }
    
    /**
     * @description Gets Lead IDs from CampaignMember records
     * @param campaignMembers List of CampaignMember records
     * @return Set of Lead IDs
     */
    public static Set<Id> getLeadIdsFromCampaignMembers(List<CampaignMember> campaignMembers) {
        Set<Id> leadIds = new Set<Id>();
        for (CampaignMember cm : campaignMembers) {
            if (cm.LeadId != null) {
                leadIds.add(cm.LeadId);
            }
        }
        return leadIds;
    }
    
    /**
     * @description Gets Lead IDs from Campaign records by querying associated CampaignMembers
     * @param campaignIds Set of Campaign IDs
     * @return Set of Lead IDs
     */
    public static Set<Id> getLeadIdsFromCampaigns(Set<Id> campaignIds) {
        Set<Id> leadIds = new Set<Id>();
        for (CampaignMember cm : [
            SELECT LeadId 
            FROM CampaignMember 
            WHERE CampaignId IN :campaignIds 
            AND LeadId != null
            AND Lead.IsConverted = false
        ]) {
            leadIds.add(cm.LeadId);
        }
        return leadIds;
    }
    
    /**
     * @description Checks if Asset or Tactic fields changed on Campaign
     * @param newCampaigns New Campaign records
     * @param oldCampaignsMap Old Campaign records map
     * @return true if Asset or Tactic changed
     */
    public static Boolean hasRelevantFieldsChanged(List<Campaign> newCampaigns, Map<Id, Campaign> oldCampaignsMap) {
        for (Campaign camp : newCampaigns) {
            Campaign oldCamp = oldCampaignsMap.get(camp.Id);
            if (camp.Offer__c != oldCamp.Offer__c || camp.Type != oldCamp.Type) {
                return true;
            }
        }
        return false;
    }

    public static void calculateLeadFieldsForScoring(List<Campaign> newCampaigns, Map<Id, Campaign> oldCampaignsMap) {
        Set<Id> campaignIds = new Set<Id>();
        // Update Lead campaign statistics if Asset or Tactic fields changed
        for (Campaign camp : newCampaigns) {
            Campaign oldCamp = oldCampaignsMap.get(camp.Id);
            if (camp.Offer__c != oldCamp.Offer__c || camp.Type != oldCamp.Type) {
                campaignIds.add(camp.Id);
            }
        }
        if(!campaignIds.isEmpty()) {
            Set<Id> leadIds = LeadCampaignService.getLeadIdsFromCampaigns(campaignIds);
            if(!leadIds.isEmpty()) {
                updateLeadCampaignStatistics(leadIds);
            }
        }  
    } 

    /**
     * @description CampaignMember records
     * @param campaignMembers List of CampaignMember records
     * @return Set of Lead IDs
     */
    public static void updateLeadFieldsForScoring(List<CampaignMember> campaignMembers) {
        Set<Id> leadIds = new Set<Id>();
        for (CampaignMember cm : campaignMembers) {
            if (cm.LeadId != null && cm.Lead.IsConverted == false) {
                leadIds.add(cm.LeadId);
            }
        }

        // Update lead campaign statistics
        if (!leadIds.isEmpty()) {
            LeadCampaignService.updateLeadCampaignStatistics(leadIds);
        }
    }
    
    /**
     * @description Wrapper class to hold campaign statistics
     */
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
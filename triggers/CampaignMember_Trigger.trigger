/**
 * @description Trigger on CampaignMember to update Lead campaign statistics
 * @author Aashi
 * @date 24-Apr-2026
 */
trigger CampaignMember_Trigger on CampaignMember (after insert, after delete, after undelete) {
    
    if(Trigger_Activation__c.getInstance('CampaignMember_Trigger').Active__c) {
        
        Set<Id> leadIds = new Set<Id>();
        
        if (Trigger.isInsert || Trigger.isUndelete) {
            LeadCampaignService.updateLeadFieldsForScoring(Trigger.new);
        }
        
        if (Trigger.isDelete) {
            LeadCampaignService.updateLeadFieldsForScoring(Trigger.old);
        }
    }
}
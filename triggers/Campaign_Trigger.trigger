trigger Campaign_Trigger on Campaign (before insert, before update, before delete, after update) {
    if(Trigger_Activation__c.getInstance('Campaign_Trigger').Active__c){  
        if(Trigger.isInsert)
        {
            if(Trigger.isBefore)
            {
                CampaignTriggerManager.assignDateFields(trigger.new);
            }
        }
        if(Trigger.isUpdate)
        {
            if(Trigger.isBefore)
            {
                CampaignTriggerManager.checkStartDate(trigger.old,trigger.new);  
                // Capture old values when Asset or Tactic fields are updated
                CampaignTriggerManager.captureOldValues(trigger.new, trigger.oldMap);
            }
            if(Trigger.isAfter)
            {
                //LeadCampaignService.calculateLeadFieldsForScoring(trigger.new, trigger.oldMap);
            }
        }
        if(Trigger.isDelete)
        {
            if(Trigger.isBefore)
            {
                CampaignTriggerManager.validateUser(trigger.old);
            }
        }
    }
}
trigger Lead_Trigger on Lead (before insert,before update,after insert, after update) {

    if(Trigger_Activation__c.getInstance('LeadTrigger').Active__c)
    {
    if(Trigger.IsInsert)
        {
            if(Trigger.IsBefore)
            {
                LeadTriggerManager.mapGlobalCountryFields(Trigger.new,Null,trigger.newMap);//SSE-16905 - Prachi
                LeadTriggerManager.AddressMatcher(null,Trigger.new);//SSE-16905 - Prachi
                //Cls_LeadTrigger_trg.InsertupdateLeadrecords(Trigger.new); 
                Cls_LeadTrigger_trg.updateLead(Trigger.new);
                LeadTriggerManager.checkPersonalEmailAddressDomain(trigger.new, null);
                //LeadTriggerManager.computeOutputDetailForMarketingPermissible(trigger.new, null);
                LeadTriggerManager.computeEmailSubscriptionValues(trigger.new, null);
                LeadTriggerManager.updateLastUserModifiedAt(trigger.new, null);
            }
            if(Trigger.IsAfter)
            {
                LeadTriggerManager.AssignmentRuleOnInsert(Trigger.new);
                
                // Update campaign statistics for new leads
                Set<Id> leadIds = trigger.newMap.keySet();
                LeadCampaignService.updateLeadCampaignStatistics(leadIds);
            }
        }
        
    if(Trigger.IsUpdate)
        {
            if(Trigger.IsBefore)
            {
                LeadTriggerManager.mapGlobalCountryFields(Trigger.new,Trigger.oldMap,trigger.newMap);
                LeadTriggerManager.AddressMatcher(Trigger.old,Trigger.new);
                LeadTriggerManager.UserAndProfileChk(Trigger.new,Trigger.Oldmap);
                LeadTriggerManager.ChkOwnerIdStatus(Trigger.new,Trigger.Oldmap,Trigger.Newmap);
                //LeadTriggerManager.ChkQueueOrOwnerAssignment(Trigger.New, Trigger.old);
                LeadTriggerManager.checkPersonalEmailAddressDomain(Trigger.new, Trigger.Oldmap);
               	//LeadTriggerManager.computeOutputDetailForMarketingPermissible(trigger.new, trigger.oldMap);
                LeadTriggerManager.computeEmailSubscriptionValues(trigger.new, trigger.oldMap);
                LeadTriggerManager.updateLastUserModifiedAt(trigger.new, trigger.oldMap);
            }
            
            if(Trigger.IsAfter)
            {
                LeadTriggerManager.SendMailtoSubmitter(Trigger.new);
                LeadTriggerManager.AssignmentRuleOnUpdate(Trigger.new);                   
        		LeadTriggerManager.syncLeadsFromEloqua(trigger.New, trigger.oldMap);
            }
        
        
        }

    }
}
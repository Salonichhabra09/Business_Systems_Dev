trigger OpportunityLineItem_Trigger on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   // Methods are commented due to new Athena Flow
    System.debug('OLI TRIGGER START ------- ' + Limits.getQueries());  
    if(Trigger_Activation__c.getInstance('OpportunityLineItem_Trigger').Active__c){
        if(Trigger.isInsert)
        {
            if(Trigger.isBefore)
            {
                //OpportunityLineItemTriggerManager.validateStageNameBeforeInsert(trigger.new);
                //OpportunityLineItemTriggerManager.validateDate(trigger.new);
                //OpportunityLineItemTriggerManager.duplicateProductError(trigger.new);
                OpportunityLineItemTriggerManager.updateRAGOptionValue(trigger.new);//SSE-18243
                //OpportunityLineItemTriggerManager.checkPricesForRenewalsOnInsert(trigger.new);
            }
            if(Trigger.isAfter)
            {
                //OpportunityLineItemTriggerManager.updateStartEndDateOnRenewal(trigger.new);
                OpportunityLineItemTriggerManager.createJobs(trigger.new);
                //system.debug('here1');
                OpportunityLineItemTriggerManager.createFutureProducts(trigger.new);
               // OpportunityLineItemTriggerManager.calculateEacv(trigger.new,trigger.newmap);
               OpportunityLineItemTriggerManager.updateSmartSheetFieldOnInsert(trigger.new);
               OpportunityLineItemTriggerManager1.UpdateCLMLineInfoOnOpp(trigger.new,trigger.oldmap);
            } 
        }
        if(Trigger.isUpdate)
        {
            if(Trigger.isBefore)
            {
               // OpportunityLineItemTriggerManager.validateDate(trigger.new);
               OpportunityLineItemTriggerManager.validateStageNameBeforeUpdate(trigger.new,trigger.oldmap); // Added by pankhuri
               //OpportunityLineItemTriggerManager.checkPricesForRenewalsOnUpdate(trigger.old,trigger.new); 
            }
            if(Trigger.isAfter)
            {
               // OpportunityLineItemTriggerManager.calculateEacv(trigger.new,trigger.newmap);
                OpportunityLineItemTriggerManager.createJobs(trigger.new);
                OpportunityLineItemTriggerManager.renewabilityUpdate(trigger.newmap,trigger.oldmap);
                OpportunityLineItemTriggerManager.deleteOppLineItemOnDeleteRequired(trigger.newmap);
                //OpportunityLineItemTriggerManager.syncFutureProducts(trigger.new);
                OpportunityLineItemTriggerManager1.UpdateCLMLineInfoOnOpp(trigger.new,trigger.oldmap);
            }
        }
        if(Trigger.isDelete)
        {
            system.debug('inside delete');
            if(Trigger.isAfter)
            {
                //OpportunityLineItemTriggerManager.updateOpportunity(trigger.old,trigger.oldmap);
                //OpportunityLineItemTriggerManager.calculateEacv(trigger.old,trigger.oldmap);
                OpportunityLineItemTriggerManager1.UpdateCLMLineInfoOnOpp(trigger.old,null);
            }
            if(Trigger.isBefore)
            {
                //system.debug('inside before');
                OpportunityLineItemTriggerManager.validateStageNameBeforeDelete(trigger.old,trigger.oldmap); 
                OpportunityLineItemTriggerManager.deleteFutureProducts(trigger.old);
                OpportunityLineItemTriggerManager.updateSmartSheetFieldOnDelete(trigger.old);
            }
        }
        if(Trigger.isUndelete)
        {
            if(Trigger.isAfter)
            {
               // OpportunityLineItemTriggerManager.updateOpportunity(trigger.new,trigger.newmap);
               // OpportunityLineItemTriggerManager.calculateEacv(trigger.new,trigger.newmap);
            }
        }
    }
    System.debug('OLI TRIGGER END ------- ' + Limits.getQueries());
}
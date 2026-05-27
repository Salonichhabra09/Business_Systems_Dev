trigger OpportunityContactRoleTrigger on OpportunityContactRole (after insert,after update, before delete) {
    if(Trigger_Activation__c.getInstance('OpportunityContactRoleTrigger').Active__c){
        if(trigger.isUpdate){
            OpportunityContactRoleTriggerManager.UpdateOpportunityOnUpdate(trigger.old,trigger.new);
        }
        if(trigger.isInsert){
            OpportunityContactRoleTriggerManager.UpdateOpportunityOnInsert(trigger.new);
        }
    if(trigger.isDelete){
        OpportunityContactRoleTriggerManager.UpdateOpportunityOnDelete(trigger.old);
    }
    }

}
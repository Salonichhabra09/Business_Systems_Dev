trigger FAQ_Trigger on FAQ__kav (after insert, before update) {
    if(Trigger_Activation__c.getInstance('FAQ_Trigger').Active__c){ 
        if(Trigger.isInsert)
        {
            if(Trigger.isAfter)
            {
                FAQTriggerManager.UpdateURLonInsert(trigger.new);
            }
        }
        if(Trigger.isUpdate)
        {
            if(Trigger.isBefore)
            {
                FAQTriggerManager.UpdateURLonUpdate(trigger.new);  
            }
        }
    }
}
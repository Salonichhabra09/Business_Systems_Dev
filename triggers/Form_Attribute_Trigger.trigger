trigger Form_Attribute_Trigger on Form_Attribute__c (before insert, before update) {
    //if(Trigger_Activation__c.getInstance('Form_Attribute_Trigger').Active__c){
    if(Trigger.isInsert)
    {
        if(Trigger.isAfter)
        {
            //FormAttributeTriggerManager.afterInsert(trigger.new);
        }
        if(Trigger.isBefore){
            FormAttributeTriggerManager.beforeInsertUpdate(trigger.new, null);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            FormAttributeTriggerManager.beforeInsertUpdate(trigger.new, trigger.oldMap);
        }
    }
    //}
}
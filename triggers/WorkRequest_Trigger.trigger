trigger WorkRequest_Trigger on Work_Request__c (after insert, after update) {
	//if(Trigger_Activation__c.getInstance('WorkRequest_Trigger').Active__c){
        if(Trigger.isInsert)
        {
            if(Trigger.isAfter)
            {
                WorkRequestTriggerManager.afterInsert(Trigger.new);
            }
        }
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            WorkRequestTriggerManager.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    //}
}
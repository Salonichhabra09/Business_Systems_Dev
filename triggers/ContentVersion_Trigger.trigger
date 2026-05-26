trigger ContentVersion_Trigger on ContentVersion (before insert, after insert,before update) {
	if(Trigger.isInsert){
            if(Trigger.isAfter){
               ContentVersionTriggerHandler.afterInsert(trigger.new);
               ContentVersionTriggerHandler.CancellationFilesOnOpportunity(trigger.newMap); 
            }
        }
    
       //Added by Prachi --SSE-21436
    if(Trigger.isBefore && Trigger.isUpdate){
      ContentVersionTriggerHandler.avoidChangeDescription(trigger.new,trigger.oldMap);  
    }
}
trigger Job_Trigger on Job__c (after insert,after update,before insert,before update) {
     if(Trigger_Activation__c.getInstance('Job_Trigger').Active__c){
        if(Trigger.isInsert){
            if(Trigger.isAfter){
               JobTriggerManager_1.Job_AfterInsert(trigger.new);
               JobTriggerManager_2.updateRollupCalculationsOnJobCreation(trigger.new);  //Added By Shubham SSE-18102
               }
            if(Trigger.isBefore){
               JobTriggerManager_1.JobTrigger_BeforeInsert(trigger.new);
            }
        }  
        if(Trigger.isUpdate){
              if(Trigger.isAfter){
                JobTriggerManager_1.Job_AfterUpdate(trigger.new,trigger.old,Trigger.oldmap);
                JobTriggerManager_2.updateRollupCalculationsOnJobUpdate(Trigger.new,Trigger.oldmap);  //Added By Shubham SSE-18102
                JobTriggerManager_2.updateTaskOwnerOnProjectManagerChange(Trigger.new,Trigger.oldmap);  //Added By Aashi SSE-18855
                JobTriggerManager_2.RefreshEventAfterUpdate(Trigger.old,Trigger.new); //Added By Priyank  
              }
              if(Trigger.isBefore){
                JobTriggerManager_1.JobTrigger_BeforeUpdate(trigger.new,trigger.old);
              }
        }   
     }
}
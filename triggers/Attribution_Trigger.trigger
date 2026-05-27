/*Created By SALONI CHHABRA to combine all triggers on Attribution
Date : 26/08/2019
Functionality : 1) To check if logged in user have PSA role as PSA Lead or PSA Manager and project manager of project related to same attribution on creation/updation/deletion
                2) Delete not allowed if attribution period is closed
*/
Trigger Attribution_Trigger on RevenueAttribution__c(before insert,before update,before delete){
    if(Trigger_Activation__c.getInstance('Attribution_Trigger').Active__c){
        //Trigger insert event starts here
        if(trigger.isInsert){
            if(trigger.isbefore){
                AttributionTriggerManager_1.AttributionTriggerManager_beforeinsert(Trigger.new);
            }
        }
        //ends here
        
        //Trigger Update event starts here
        if(trigger.isUpdate){
            if(trigger.isbefore){
                AttributionTriggerManager_1.AttributionTriggerManager_beforeupdate(Trigger.new,trigger.old);
            }
        }
        //ends here
        
        //Trigger Delete event starts here
        if(trigger.isDelete){
            if(trigger.isbefore){
                AttributionTriggerManager_1.AttributionTriggerManager_beforedelete(Trigger.old);
            }
        }
        //ends here
    }
}
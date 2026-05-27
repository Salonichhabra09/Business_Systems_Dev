trigger Task_Trigger on Task (after insert,after update,before delete,before update,before insert) {
    
    if(Trigger_Activation__c.getInstance('Task_Trigger').Active__c){  
        set<ID> jobIdSet = new set<ID>();
        if(Trigger.isInsert)
        {
            if(Trigger.isBefore){
                //TaskTriggerManager.UpdateOpportunityStage(Trigger.new);
                TaskTriggerManager.UpdateActualTimeTakenonInsert(Trigger.new);
            }
            if(Trigger.isAfter)
            {
                String Jobid;
                for(Integer i=0;i<trigger.new.size();i++)
                {
                    Jobid=Trigger.new[i].WhatId;
                    if(Trigger.new[i].WhatId!=null && Jobid.substring(0,3)=='a00')
                        jobIdSet.add(Trigger.new[i].WhatId);
                }
                //if(jobIdSet.size()>0)    //Commented by Shubham Singh (SSE-18120)
                   // TaskTriggerManager.UpdateTimeFieldsOnJob(jobIdSet);
                TaskTriggerManager.UpdateCreateTaskOnStrategy(Trigger.new);
               TaskTriggerManager.UpdateContactTask(Trigger.new,null);//Added by Prachi(fix for Max duplicate updates error SSE-21600)
            }
            
        }
        if(Trigger.isUpdate)
        {
            if(Trigger.isBefore){
                //TaskTriggerManager.UpdateOpportunityStage(Trigger.new);
                TaskTriggerManager.UpdateActualTimeTakenonUpdate(Trigger.new,Trigger.oldmap);
            }
            if(Trigger.isAfter)
            {
                for(Integer i=0;i<trigger.new.size();i++)
                {
                    if(Trigger.new[i].WhatId !=null && (Trigger.new[i].Actual_Time_Taken__c !=Trigger.old[i].Actual_Time_Taken__c || Trigger.new[i].EstimatedDurationInMinutes__c!=Trigger.old[i].EstimatedDurationInMinutes__c))
                        jobIdSet.add(Trigger.new[i].WhatId);
                }
                //if(jobIdSet.size()>0)    //Commented by Shubham Singh (SSE-18120)
                    //TaskTriggerManager.UpdateTimeFieldsOnJob(jobIdSet);
                TaskTriggerManager.UpdateCompletedTaskOnStrategy(Trigger.new,Trigger.oldmap);
                TaskTriggerManager.UpdateContactTask(Trigger.new,Trigger.oldmap);//Added by Prachi(fix for Max duplicate updates error SSE-21600)
            }
        }
        if(Trigger.isDelete)
        {
            If(Trigger.isBefore){
                TaskTriggerManager.ValidateTaskDeletion(Trigger.old);
            }
        }
    }
}
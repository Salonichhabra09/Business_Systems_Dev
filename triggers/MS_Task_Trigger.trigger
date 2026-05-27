/*****************************************************************************
CREATED BY :- Aashi
CREATED DATE :- 13-12-2022
DESCRIPTION :- MS_Task Trigger to handle After Insert, Update, Delete & UnDelete events on MS_Task Records.
STORY# :- SSE-18121 (MS Sprint 3)
******************************************************************************/

trigger MS_Task_Trigger on MS_Task__c (after insert, after update, after delete, after undelete, before insert) {
    if(Trigger_Activation__c.getInstance('MS_Task_Trigger').Active__c){
        if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
            MS_TaskTriggerManager.afterInsertDeleteUndelete(trigger.new);
        }
        
        if(trigger.isAfter && trigger.isUpdate){
            MS_TaskTriggerManager.afterUpdate(trigger.new, trigger.oldMap);
            MS_TaskTriggerManager.UpdateTimeFieldsOnJob(trigger.new, trigger.oldMap);//Created By Shubham Singh (SSE-18120)
        }
        
        if(trigger.isAfter && trigger.isDelete){
            MS_TaskTriggerManager.afterInsertDeleteUndelete(trigger.old);
        }
        if(trigger.isBefore && trigger.isInsert){
            /* SSE-18926 Commented by Aashi to eliminate Priority Logic */
            //MS_TaskTriggerManager.UpdateTaskManagerPriority(trigger.new);
        }
    }
}
/**************************************************************************************************************************************
CREATED BY :- Aashi
CREATED DATE :- 20-01-2026
DESCRIPTION :- This Trigger Controls the execution of below Classes:
1. TerritoryTriggerManager 
***************************************************************************************************************************************/
trigger Territory_Trigger on Territory__c (after insert, after update) {
    if(Trigger_Activation__c.getInstance('Territory_Trigger').Active__c || Test.isRunningTest()){
        if(trigger.isAfter)
        {
            if(trigger.isUpdate){
                TerritoryTriggerManager.handleAccountOwnerUpdate(trigger.new, trigger.oldMap);
            }
            if(trigger.isInsert){
                //TerritoryTriggerManager.handleAccountOwnerUpdate(trigger.new, null);
            }
        }
        
    }
}
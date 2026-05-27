/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This trigger is created to handle the update of NumberofAccountPlan field on Account if any Account Plan is deleted.*                                                  
************************************************************************************************************************************/
trigger accountPlan_Trigger on Account_Plan__c (after delete, after update) {
        
    if(Trigger.isDelete && Trigger.isAfter){
        accountPlanTriggerManager.updateNumberofAccountPlanOnAccount(trigger.old);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        accountPlanTriggerManager.sendMailToApprovalSubmitter(trigger.old,trigger.new);
    }
    
}
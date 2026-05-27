/*Created By SALONI CHHABRA to combine all triggers on Project Deliverable
Date : 22/08/2019
Functionality : To check if "Actual Delivery" field is only edited by Workpacket group users
*/
Trigger Workpacket_Trigger on Workpacket__c(before update){
    if(Trigger_Activation__c.getInstance('Workpacket_Trigger').Active__c){
        if(trigger.isUpdate){
                WorkpacketTriggerManager_1.beforeUpdate(Trigger.new, Trigger.oldmap);
        }
    }
}
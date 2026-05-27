/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 22-08-2019
DESCRIPTION :- This class contains Associate trigger related functionalities : after delete,after update,after insert 
               This class is responsible for Updating the related invoice with updated Amount of timesheet, expense, Associate
***************************************************************************************************************************************/ 

trigger Associate_Trigger on Associate__c (after delete,after update,after insert) {
  if(Trigger_Activation__c.getInstance('Associate_Trigger').Active__c){
    if(Trigger.isDelete){
         if(Trigger.isAfter){
             Associate_Manager.updateRelatedInvoices(trigger.old);
         }
    }
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            Associate_Manager.Associate_AfterUpdateChecks(trigger.new,trigger.old);
        }
    }
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            Associate_Manager.updateRelatedInvoices(trigger.new);
        }
    }
  }
}
/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 22-08-2019
DESCRIPTION :- This class contains Milestone_Period trigger related functionalities : Before insert and Before Update
               This class is responsible for Updating  update Signature_Date__c  & FC_Agent__c fields and Record Type
***************************************************************************************************************************************/ 
trigger Milestone_Period_Trigger on Milestone_Period__c (before update,before insert) {
    if(Trigger_Activation__c.getInstance('Milestone_Period_Trigger').Active__c){
         if(Trigger.isUpdate){
            if(Trigger.isBefore){
                MilestonePeriod_Manager.MilestonePeriodUpdateChecks(trigger.new,trigger.old);
            }
         }  
         if(Trigger.isInsert){
            if(Trigger.isBefore){
                MilestonePeriod_Manager.MilestonePeriodInsertChecks(trigger.new);
            }
         }      
    }
}
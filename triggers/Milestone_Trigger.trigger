/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 23-08-2019
DESCRIPTION :- This class contains Milestone trigger related functionalities : after delete,after update,after insert 
               This class is responsible for Updating the related invoice with updated Amount of timesheet, expense, Associate
***************************************************************************************************************************************/ 

trigger Milestone_Trigger on Milestone__c (before delete, before update, before insert, after insert, after update) {
 if(Trigger_Activation__c.getInstance('Milestone_Trigger').Active__c){
        if(Trigger.isDelete){
            MilestoneTrigger_Manager.MilestoneValidationChecks(trigger.old);
        }
        if(Trigger.isUpdate){
          if(Trigger.isBefore){
            MilestoneTrigger_Manager2.MilestoneBeforeUpdateChecks(trigger.new,trigger.old,trigger.oldMap,trigger.newMap);
            MilestoneTrigger_Manager.MilestoneUpdateIsSignedCheck(trigger.new,trigger.old);  
          }
           if(Trigger.IsAfter){
            MilestoneTrigger_Manager.extendOppAccessToCrossBorderMilestone(Trigger.new, trigger.oldMap);
           }
        }
        if(Trigger.isInsert){
          if(Trigger.isBefore){
            MilestoneTrigger_Manager.MilestoneInsertIsSignedCheck(trigger.new);  
            MilestoneTrigger_Manager.MilestoneInsertChecks(trigger.new);
          }
           if(Trigger.IsAfter){
               MilestoneTrigger_Manager.extendOppAccessToCrossBorderMilestone(Trigger.new, null);
        }   
  }
}
}
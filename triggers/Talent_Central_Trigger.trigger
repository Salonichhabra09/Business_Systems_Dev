//Created By RISHABH KANOTRA to combine all triggers on Talent_Central__c on 20/08/2019
trigger Talent_Central_Trigger on Talent_Central__c(before insert,before update, before delete) {

    if(Trigger_Activation__c.getInstance('Talent_Central_Trigger').Active__c){
            
        if (Trigger.isInsert) {
         
                if (Trigger.isBefore) {
                
                    TalentCentralTriggerManager.BeforeInsertTalentCentral(trigger.new, trigger.Oldmap, trigger.Newmap, trigger.IsInsert, trigger.IsUpdate);
                
                } 
                
                  
         
         }//Insert
         
         
         if (Trigger.isUpdate) {
         
                if (Trigger.isBefore) {                
                
                      TalentCentralTriggerManager.BeforeUpdateTalentCentral(trigger.new, trigger.Oldmap, trigger.Newmap ,trigger.IsInsert, trigger.IsUpdate);         
                                
                } 
                
                    
         
         }//Update
         
         
         if (Trigger.isDelete) {
         
                if (Trigger.isBefore) {
                    
                    TalentCentralTriggerManager.BeforeDeleteTalentCentral(trigger.Old);
                } 
                
                   
         
         
         }//Delete    
    
    
    }//Trigger_Activation

}//end
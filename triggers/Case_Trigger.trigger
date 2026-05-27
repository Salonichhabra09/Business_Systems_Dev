//Created By RISHABH KANOTRA to combine all triggers on Case on 15/07/2019
trigger Case_Trigger on Case(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    if(Trigger_Activation__c.getInstance('Case_Trigger').Active__c){
        
        if (Trigger.isInsert) {
            
            if (Trigger.isBefore) {
                
                CaseTriggerManager_1.beforeInsert_1(Trigger.new);
                CaseTriggerManager_1.beforeInsert_2(Trigger.new);
                CaseTriggerManager_1.beforeInsert_3(Trigger.new);
                CaseTriggerManager_1.updateSystemID(Trigger.new, null);     
                CaseTriggerManager_1.clearJobValue(Trigger.new, null); //Added By Prachi
            } 
            
            else if (Trigger.isAfter) {
                
                CaseTriggerManager_1.afterInsert_1(Trigger.new);
                CaseTriggerManager_1.updateNumberOfChangesOnJob(Trigger.new);
                CaseTriggerManager_1.LinkWebFormAttachmentToCase(Trigger.new);
                //CaseTriggerManager_1.linkAttachmentToCase(Trigger.new);
            }    
            
        }//Insert
        
        
        if (Trigger.isUpdate) {
            
            if (Trigger.isBefore) {                
                
                CaseTriggerManager_1.beforeUpdate_1(Trigger.new, Trigger.oldmap);
                CaseTriggerManager_1.beforeUpdate_2(Trigger.new, Trigger.oldmap);     
                CaseTriggerManager_1.updateSystemID(Trigger.new, Trigger.oldmap);     
                
            } 
            
            else if (Trigger.isAfter) {
                
                CaseTriggerManager_1.afterUpdate_1(Trigger.new, Trigger.oldmap);
                CaseTriggerManager_1.updateNumberOfChangesOnJob(Trigger.new);
            }    
            
        }//Update
        
        
        if (Trigger.isDelete) {
            
            if (Trigger.isBefore) {
                
                CaseTriggerManager_1.beforeCaseDelete(Trigger.old);
            } 
            
            else if (Trigger.isAfter) {
                
              CaseTriggerManager_1.updateNumberOfChangesOnJob(Trigger.old);  
                
            }    
            
            
        }//Delete
        
        
        if (Trigger.isUndelete) {
            
            if (Trigger.isAfter) {
                
                CaseTriggerManager_1.updateNumberOfChangesOnJob(Trigger.new);
                
            }    
            
            
        }//Undelete
        
        
        
    }//Trigger_Activation
    
}//end
//Created By SANJEEV to combine all triggers on USER on 29/03/2022
trigger User_Trigger on User (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    if(Trigger_Activation__c.getInstance('User_Trigger').Active__c){
    
    if (Trigger.isInsert) {
        
        if (Trigger.isBefore) {
            
            
        } 
        
        else if (Trigger.isAfter) {
            AddUserToPublicGroups.onInsertOfUser(Trigger.new);
        }    
        
    }//Insert
    
    
    if (Trigger.isUpdate) {
        
        if (Trigger.isBefore) {                
            
            
        } 
        
        else if (Trigger.isAfter) {
            AddUserToPublicGroups.onUserUpdate(Trigger.New,trigger.oldMap);
        }    
        
    }//Update
    
    
    
    
    }//Trigger_Activation
    
}//end
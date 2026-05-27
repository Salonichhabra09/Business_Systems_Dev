//Created By RISHABH KANOTRA to combine all triggers on TC_Transition_Slot__c on 19/08/2019
trigger TC_Transition_Slot_Trigger on TC_Transition_Slot__c (after update, before delete) {

    if(Trigger_Activation__c.getInstance('TC_Transition_Slot_Trigger').Active__c){
    
    
        if (Trigger.isUpdate) {
        
            if (Trigger.isAfter) {
            
                TCTransitionSlotTriggerManager.AfterUpdateTcSlot(trigger.New,trigger.oldMap);
            
            }    
        
        }//Update
        
        
        if (Trigger.isDelete) {
        
            if (Trigger.isBefore) {
                
                TCTransitionSlotTriggerManager.BeforeDeleteTcSlot(trigger.old);
            
            }               
        
        }//Delete     
    
    
    }//Trigger_Activation

}//end
//Created By RISHABH KANOTRA to combine all triggers on System__c on 23/08/2019
trigger System_Trigger on System__c (before insert,before update,after Insert, after Update,after Delete,after Undelete) {

    if(Trigger_Activation__c.getInstance('System_Trigger').Active__c){
    
    
         if (Trigger.isInsert) {    
                if (Trigger.isBefore) {                
                      SystemTriggerManager.BeforeInsertSystem(trigger.new, trigger.oldMap, trigger.isInsert, trigger.isUpdate);                                           
                } 
         }
         
         
         if (Trigger.isUpdate) {        
                if (Trigger.isBefore) {                                       
                	SystemTriggerManager.BeforeUpdateSystem(trigger.new, trigger.oldMap, trigger.isInsert, trigger.isUpdate);                                    
                }                                
         }
        
        
        if(Trigger.isAfter) {            
            List<System__c> systemList = Trigger.isDelete ? Trigger.Old : Trigger.New;
            Map<Id, System__c> oldSystemMap = (Trigger.isUndelete ||  Trigger.isInsert) ? null : Trigger.oldMap;

            SystemTriggerManager.updateNumberOfIntegratedLiveSystem(systemList, oldSystemMap, Trigger.operationType );          
        }  

    
    }//Trigger_Activation

}//end
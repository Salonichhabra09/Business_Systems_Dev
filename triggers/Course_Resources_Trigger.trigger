//Created By RISHABH KANOTRA to combine all triggers on Course_Resources__c on 22/08/2019
trigger Course_Resources_Trigger on Course_Resources__c(after insert,after update,after delete) {

    if(Trigger_Activation__c.getInstance('Course_Resources_Trigger').Active__c){
            
        if (Trigger.isInsert) {
         
                if (Trigger.isAfter) {
                    CourseResourcesTriggerManager.CRafterInsert(trigger.New);
                }    
         
         }//Insert
         
         
         if (Trigger.isUpdate) {
         
                if (Trigger.isAfter) {
                
                     CourseResourcesTriggerManager.CRafterUpdate(trigger.old, trigger.new);
                
                }    
         
         }//Update
         
         
         if (Trigger.isDelete) {
         
                if (Trigger.isAfter) {
                
                    CourseResourcesTriggerManager.CRafterDelete(trigger.old);
                
                }    
         
         
         }//Delete   
    
    
    }//Trigger_Activation

}//end
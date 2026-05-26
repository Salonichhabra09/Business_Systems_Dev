/**************************************************************************************************************************************
CREATED BY :- RISHABH KANOTRA
CREATED DATE :- 19/08/2019
DESCRIPTION :- This class contains various validations and restrictions to modify TC_Transition_Slot__c and its fields and refered from TC_Transition_Slot_Trigger triggers : after update, before delete
***************************************************************************************************************************************/ 
 
Global class TCTransitionSlotTriggerManager{
    
    //If Slot is deleted - update following fields on TC -
    //1.Slot_Description__c 
    //2.Date_Booking_Made__c  
    public static void BeforeDeleteTcSlot(List<TC_Transition_Slot__c> oldTcSlot){
    
        if(Utility.runOnce == true) {
        
            Set<Id> deletedTcSlotIdsSet = new Set<Id>();
            for(TC_Transition_Slot__c tcslot : oldTcSlot) {
                deletedTcSlotIdsSet.add(tcslot.Id);     
            }
            List<Talent_Central__c> tcTransitionList = [select     Id, Name,TC_Transition_Slot__r.Transition_Slot_Description__c,
            Slot_Description__c,Date_Booking_Made__c  from Talent_Central__c
            where TC_Transition_Slot__c IN :  deletedTcSlotIdsSet];  
            system.debug('********************'+tcTransitionList);
            if(tcTransitionList != null && tcTransitionList.size() > 0){
                for(Talent_Central__c tc : tcTransitionList) {
                    tc.Slot_Description__c = '';
                    tc.Date_Booking_Made__c = null;        
                }
                system.debug('********************'+tcTransitionList);  
                database.update(tcTransitionList,false);          
            }                                                         
        
        // Changes made by mohit --- 13/02/2015
        // Utility.runOnce = false;
        if(!Test.isRunningTest())
        Utility.runOnce = false;
        // Changes made by mohit --- 13/02/2015
    }
    
    }//BeforeDeleteTcSlot
    
    //If Transition_Slot_Description__c is changed then update the Slot_Description__c of the related Talent_Central__c
    public static void AfterUpdateTcSlot(List<TC_Transition_Slot__c> newTcSlot, Map<id,TC_Transition_Slot__c> oldmap){
    
        if(Utility.runOnce == true) {
            
                // Only do work when the Slot description has changed
                Map<Id, String> tcSlotdescUpdate = new Map<Id, String>();
                
                for(TC_Transition_Slot__c tcslot : newTcSlot) {
                    TC_Transition_Slot__c oldtcsRecord = oldmap.get(tcslot.id);        
                    if(tcslot.Transition_Slot_Description__c != oldtcsRecord.Transition_Slot_Description__c) {
                    tcSlotdescUpdate.put(tcslot.id, tcslot.Transition_Slot_Description__c);    
                    }                       
                }
                
                if(tcSlotdescUpdate.size()>0) {
                    // Only update when decsription value is changed
                    List<Talent_Central__c> updateList = [SELECT Id, Slot_Description__c,TC_Transition_Slot__c FROM Talent_Central__c 
                    WHERE TC_Transition_Slot__c IN :tcSlotdescUpdate.keySet()];
                    if(updateList != null && updateList.size() > 0){
                        for (Talent_Central__c tcobj : updateList) {
                            if(tcSlotdescUpdate != null && tcSlotdescUpdate.containsKey(tcobj.TC_Transition_Slot__c))
                                tcobj.Slot_Description__c = tcSlotdescUpdate.get(tcobj.TC_Transition_Slot__c) ; 
                             
                        }
                        database.update(updateList,false);
                    }
                
                }
            
            // Changes made by mohit --- 13/02/2015
            // Utility.runOnce = false;
            if(!Test.isRunningTest())
            Utility.runOnce = false;
            // Changes made by mohit --- 13/02/2015
        }
        
    }//AfterUpdateTcSlot
    
}//TriggerEnd
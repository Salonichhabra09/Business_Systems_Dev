/**************************************************************************************************************************************
CREATED BY :- RISHABH KANOTRA
CREATED DATE :- 20/08/2019
DESCRIPTION :- This class contains various validations and restrictions to modify Talent_Central__c and its fields and refered from Talent_Central_Trigger triggers : before insert,before update, before delete
***************************************************************************************************************************************/ 
 
Global class TalentCentralTriggerManager{

    //Logic for updating following fields of TC Slot - 1 Provisional_Total__c 2 Confirmed_Total__c
    public static void BeforeUpdateTalentCentral(List<Talent_Central__c> newTalentCentral, Map<id,Talent_Central__c> oldmap, Map<id,Talent_Central__c> newMap, Boolean isInsert, Boolean isUpdate){
        
        
        
        CommonInsertUpdate(newTalentCentral,oldMap,newMap,isInsert,isUpdate);
        OnlyUpdate(newTalentCentral,oldmap,isUpdate);
        
    }//BeforeUpdateTalentCentral
    
    //Logic for updating following fields of TC Slot - 1 Provisional_Total__c 2 Confirmed_Total__c
    public static void BeforeInsertTalentCentral(List<Talent_Central__c> newTalentCentral, Map<id,Talent_Central__c> oldmap, Map<id,Talent_Central__c> newMap, Boolean isInsert, Boolean isUpdate){
       CommonInsertUpdate(newTalentCentral,oldMap,newMap,isInsert,isUpdate);
        
    }//BeforeInsertTalentCentral
    
    //Logic for updating following fields of TC Slot - 1 Provisional_Total__c 2 Confirmed_Total__c
    public static void BeforeDeleteTalentCentral(List<Talent_Central__c> oldTalentCentral){
        
       
            Utility.delTCTransitionRec(oldTalentCentral);       
         
       
    }//BeforeDeleteTalentCentral
    
    public static void OnlyUpdate(List<Talent_Central__c> newTalentCentral, Map<id,Talent_Central__c> oldmap, Boolean isUpdate){
        Set<Id> slotIdsSet = new Set<Id>();
        Set<Id> slotOldRecIdsSet = new Set<Id>();
        Map<Id,Integer> mapTCIdAndProv = new Map<Id,Integer>();
        Map<Id,Integer> mapTCIdAndConf = new Map<Id,Integer>(); 
        if(isUpdate) 
        {
            for(Talent_Central__c tcobj : newTalentCentral) 
            {
                if(tcobj.TC_Transition_Slot__c != null) 
                slotIdsSet.add(tcobj.TC_Transition_Slot__c); 
                if(tcobj.TC_Transition_Slot__c != oldMap.get(tcobj.id).TC_Transition_Slot__c && oldMap.get(tcobj.id).TC_Transition_Slot__c != null)
                slotOldRecIdsSet.add(oldMap.get(tcobj.id).TC_Transition_Slot__c); 
            }
            if(slotIdsSet.size()>0) {
                for(TC_Transition_Slot__c tc : [Select id,Provisional_Total__c,Confirmed_Total__c from TC_Transition_Slot__c where id in : slotIdsSet]){
                if(tc.Provisional_Total__c != null) {
                    mapTCIdAndProv.put(tc.id,integer.valueof(tc.Provisional_Total__c));
                }                 
                if(tc.Confirmed_Total__c != null) {
                    mapTCIdAndConf.put(tc.id,integer.valueof(tc.Confirmed_Total__c ));
                }                   
                }  
            }  
            if(slotOldRecIdsSet.size()>0) {
                for(TC_Transition_Slot__c tc : [Select id,Provisional_Total__c,Confirmed_Total__c from TC_Transition_Slot__c where id in : slotOldRecIdsSet]){
                if(tc.Provisional_Total__c != null){
                    mapTCIdAndProv.put(tc.id,integer.valueof(tc.Provisional_Total__c));
                }
                if(tc.Confirmed_Total__c != null){
                    mapTCIdAndConf.put(tc.id,integer.valueof(tc.Confirmed_Total__c));
                }    
                }
            }    
            
            for(Talent_Central__c tcobj : newTalentCentral) 
            { 
                integer prov = 0;
                integer conf = 0;
                integer provOld = 0;
                integer confOld = 0;
                //if Status is updated
                if(oldMap.get(tcobj.id).Transition_Booking_Status__c != tcobj.Transition_Booking_Status__c && tcobj.TC_Transition_Slot__c == oldMap.get(tcobj.id).TC_Transition_Slot__c) {
                    if((oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Provisional' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'On Hold')
                    && tcobj.Transition_Booking_Status__c == 'Confirmed') {
                    
                    if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c)){
                        prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                        mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov-1);
                    } 
                    if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(tcobj.TC_Transition_Slot__c)){                         
                        conf = mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c);
                        mapTCIdAndConf.put(tcobj.TC_Transition_Slot__c,conf+1); 
                    }                   
                    }
                    else if(oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Confirmed' && (tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold')) {
                    
                    if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c)){                         
                        prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                        mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov+1);
                    }
                    if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(tcobj.TC_Transition_Slot__c)){                         
                    
                    conf = mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c);
                    mapTCIdAndConf.put(tcobj.TC_Transition_Slot__c,conf-1); 
                    }
                    }
                    else if(!(oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Provisional' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'On Hold' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Confirmed')
                    && (tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold')) {
                    
                    if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c)){                         
                    
                    prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                    mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov+1);  
                    }            
                    }
                    else if(!(oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Provisional' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'On Hold' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Confirmed')
                    && tcobj.Transition_Booking_Status__c == 'Confirmed') {
                    
                    if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(tcobj.TC_Transition_Slot__c)){                         
                    
                    conf = mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c);
                    
                    mapTCIdAndConf.put(tcobj.TC_Transition_Slot__c,conf+1); 
                    
                    }                
                    }
                    else if(!(tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold' || tcobj.Transition_Booking_Status__c == 'Confirmed')
                    && (oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Provisional' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'On Hold')) {
                    
                    if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c)){                         
                    
                    prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                    mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov-1); 
                    }              
                    }
                    else if(!(tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold' || tcobj.Transition_Booking_Status__c == 'Confirmed')
                    && oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Confirmed') {
                    
                    if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(tcobj.TC_Transition_Slot__c)){                    
                    
                    conf = mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c);
                    mapTCIdAndConf.put(tcobj.TC_Transition_Slot__c,conf-1);  
                    }              
                    }
                }
                //if Slot is updated
                else if(tcobj.TC_Transition_Slot__c != oldMap.get(tcobj.id).TC_Transition_Slot__c && oldMap.get(tcobj.id).Transition_Booking_Status__c == tcobj.Transition_Booking_Status__c) {
                if(tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold') {
                
                if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c)){ 
                prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                
                mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov+1);
                } 
                if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(oldMap.get(tcobj.id).TC_Transition_Slot__c)){                
                
                provOld = mapTCIdAndProv.get(oldMap.get(tcobj.id).TC_Transition_Slot__c);
                
                mapTCIdAndProv.put(oldMap.get(tcobj.id).TC_Transition_Slot__c,provOld-1);
                } 
                
                }  
                else if(tcobj.Transition_Booking_Status__c == 'Confirmed') {
                
                if(mapTCIdAndconf != null && mapTCIdAndconf.containsKey(tcobj.TC_Transition_Slot__c)){                         
                
                conf = mapTCIdAndconf.get(tcobj.TC_Transition_Slot__c);
                mapTCIdAndconf.put(tcobj.TC_Transition_Slot__c,conf+1);
                }
                if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(oldMap.get(tcobj.id).TC_Transition_Slot__c)){                         
                
                confOld = mapTCIdAndConf.get(oldMap.get(tcobj.id).TC_Transition_Slot__c);
                mapTCIdAndConf.put(oldMap.get(tcobj.id).TC_Transition_Slot__c,confOld-1);
                } 
                }                
                }
                //If update both Slot as well as Booking Status
                else if(tcobj.TC_Transition_Slot__c != oldMap.get(tcobj.id).TC_Transition_Slot__c &&
                oldMap.get(tcobj.id).Transition_Booking_Status__c != tcobj.Transition_Booking_Status__c) {
                if((oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Provisional' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'On Hold')
                && tcobj.Transition_Booking_Status__c == 'Confirmed') {
                
                if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(oldMap.get(tcobj.id).TC_Transition_Slot__c)){                         
                
                provOld = mapTCIdAndProv.get(oldMap.get(tcobj.id).TC_Transition_Slot__c);
                
                mapTCIdAndProv.put(oldMap.get(tcobj.id).TC_Transition_Slot__c,provOld-1);
                
                } 
                if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(tcobj.TC_Transition_Slot__c)){ 
                conf = mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c);
                mapTCIdAndConf.put(tcobj.TC_Transition_Slot__c,conf+1); 
                
                }                                          
                }
                else if(oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Confirmed' && (tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold')) {
                
                if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c)){                        
                
                prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov+1);
                
                } 
                if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(oldMap.get(tcobj.id).TC_Transition_Slot__c)){                         
                
                confOld= mapTCIdAndConf.get(oldMap.get(tcobj.id).TC_Transition_Slot__c);
                mapTCIdAndConf.put(oldMap.get(tcobj.id).TC_Transition_Slot__c,confOld-1); 
                
                }                    
                }
                else if(!(oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Provisional' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'On Hold' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Confirmed')
                && (tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold')) {
                
                if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c)){                         
                
                prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov+1);  
                }                                   
                }
                else if(!(oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Provisional' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'On Hold' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Confirmed')
                && tcobj.Transition_Booking_Status__c == 'Confirmed') {
                
                if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(tcobj.TC_Transition_Slot__c)){                      
                
                conf = mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c);
                
                mapTCIdAndConf.put(tcobj.TC_Transition_Slot__c,conf+1); 
                
                }              
                }
                else if(!(tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold' || tcobj.Transition_Booking_Status__c == 'Confirmed')
                && (oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Provisional' || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'On Hold')) {
                
                if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(oldMap.get(tcobj.id).TC_Transition_Slot__c)){                      
                
                provOld = mapTCIdAndProv.get(oldMap.get(tcobj.id).TC_Transition_Slot__c);
                mapTCIdAndProv.put(oldMap.get(tcobj.id).TC_Transition_Slot__c,provOld-1); 
                }               
                }
                else if(!(tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold' || tcobj.Transition_Booking_Status__c == 'Confirmed')
                && oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Confirmed') {
                
                if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(oldMap.get(tcobj.id).TC_Transition_Slot__c)){                      
                
                confOld = mapTCIdAndConf.get(oldMap.get(tcobj.id).TC_Transition_Slot__c);
                mapTCIdAndConf.put(oldMap.get(tcobj.id).TC_Transition_Slot__c,confOld-1);  
                } 
                
                }    
                else if((oldMap.get(tcobj.id).Transition_Booking_Status__c == 'Provisional' && tcobj.Transition_Booking_Status__c == 'On Hold')
                || oldMap.get(tcobj.id).Transition_Booking_Status__c == 'On Hold' && tcobj.Transition_Booking_Status__c == 'Provisional') {
                if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c)){                        
                
                prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov+1);
                
                } 
                if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(oldMap.get(tcobj.id).TC_Transition_Slot__c)){                         
                
                provOld = mapTCIdAndProv.get(oldMap.get(tcobj.id).TC_Transition_Slot__c);
                mapTCIdAndProv.put(oldMap.get(tcobj.id).TC_Transition_Slot__c,provOld-1); 
                
                }         
                }
                }               
            }   
            if(mapTCIdAndProv != null || mapTCIdAndConf != null) {           
            Utility.TCupdateSlotRec(mapTCIdAndProv,mapTCIdAndConf); 
            }  
        }
    }//OnlyUpdate
    
    public static void CommonInsertUpdate(List<Talent_Central__c> newTalentCentral, Map<id,Talent_Central__c> oldMap, Map<id,Talent_Central__c> newMap, Boolean isInsert, Boolean isUpdate){
        
        List<Talent_Central__c> tcListwithFreeSpace = new List<Talent_Central__c>();
        List<Talent_Central__c> tcListwithNoFreeSpace = new List<Talent_Central__c>();
        set<Id> talentCentralIds = new set<Id>();   
        Set<Id> slotIdsSet = new Set<Id>();
        Set<Id> setSlotId = new Set<Id>(); 
        Map<Id,Decimal> mpSlotIdandFreespace = new Map<Id,Decimal>();
        for(Talent_Central__c tc : newTalentCentral) {
            if(tc.Current_Transition_Activity__c != null && tc.Current_Transition_Activity__c == Utility.getCurrentTransitionActivity())
            talentCentralIds.add(tc.Id); 
            if(tc.TC_Transition_Slot__c != null) 
            setSlotId.add(tc.TC_Transition_Slot__c);    
        }
        if(setSlotId != null) {
            for(TC_Transition_Slot__c tc : [Select id,Provisional_Total__c,Confirmed_Total__c,Free_Spaces__c from TC_Transition_Slot__c where id in : setSlotId]){
            
            mpSlotIdandFreespace.put(tc.id,tc.Free_Spaces__c); 
            System.debug('Free**'+mpSlotIdandFreespace);                             
            }
        }
        if(talentCentralIds.size()>0) { 
            List <System__c> systemList = [select Id, System_Transition_Status__c, Talent_Central__c ,
                                                Talent_Central__r.Current_Transition_Activity__c 
                                                from System__c where Talent_Central__c IN : talentCentralIds];
            Set<String> statusSet = Utility.getSystemTransitionStatus();
            if(systemList != null && systemList.size()>0) {
                for(System__c obj : systemList) {
                           
                    if(statusSet != null && !statusSet.contains(obj.System_Transition_Status__c)) 
                    {
                       if(!Test.isRunningTest())newMap.get(obj.Talent_Central__c).addError(system.label.TC_Activity_is_completed_but_system_is_not_transition);                                
                    }  
                }
            }
        }
        
        Map<Id,TC_Transition_Slot__c> slotIdandSlotrecord = new Map<id,TC_Transition_Slot__c>([select Id, Name,Date__c,Free_Spaces__c ,Transition_Slot_Type__c,Transition_Slot_Description__c from TC_Transition_Slot__c where Id IN:setSlotId]);
        //Map<Id,Decimal> mpSlotIdandFreespace = new Map<Id,Decimal>();
        
        set<Id> chkDuplicateSlotId = new set<Id>();    
        Map<Id,Integer> mpSlotIdandCount = new Map<Id,Integer>();
        if(isInsert || isUpdate) {
            /*if(setSlotId != null) {
                for(TC_Transition_Slot__c tc : [Select id,Provisional_Total__c,Confirmed_Total__c,Free_Spaces__c from TC_Transition_Slot__c where id in : setSlotId]){
                   
                    mpSlotIdandFreespace.put(tc.id,tc.Free_Spaces__c);                              
                }
            }*/
            
            Integer count = 0;
            for(Talent_Central__c tcobj : newTalentCentral) {           
                //if(tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold' || tcobj.Transition_Booking_Status__c == 'Confirmed')   
                if((tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold' || tcobj.Transition_Booking_Status__c == 'Confirmed') && ((isUpdate && tcobj.TC_Transition_Slot__c != oldMap.get(tcobj.id).TC_Transition_Slot__c) || (isInsert && tcobj.TC_Transition_Slot__c != null))) {   
               
                if(mpSlotIdandFreespace != null && (mpSlotIdandFreespace.ContainsKey(tcobj.TC_Transition_Slot__c)) && !chkDuplicateSlotId.Contains(tcobj.TC_Transition_Slot__c)) {
                    chkDuplicateSlotId.clear();
                    if(mpSlotIdandCount != null && mpSlotIdandCount.ContainsKey(tcobj.TC_Transition_Slot__c)) {
                        count = mpSlotIdandCount.get(tcobj.TC_Transition_Slot__c);    
                        System.debug('First**' + count);
                    } else {                    
                        count = Integer.valueOf(mpSlotIdandFreespace.get(tcobj.TC_Transition_Slot__c));
                        System.debug('Second**' + count);
                    }
                    chkDuplicateSlotId.add(tcobj.TC_Transition_Slot__c);                                                                      
                }                
                if(mpSlotIdandFreespace.size()>0 ) {
                    if(count <= 0) {
                         tcListwithNoFreeSpace.add(tcobj);                         
                    }
                    else {
                        //if(!mpSlotIdandCount.ContainsKey(tcobj.TC_Transition_Slot__c))
                         
                        count--;
                        mpSlotIdandCount.put(tcobj.TC_Transition_Slot__c,count);                          
                        tcListwithFreeSpace.add(tcobj);                                    
                    }   
                }               
                }
                //Added by Anjali for SSE-4513 starts here
                if((isUpdate && tcobj.TC_Transition_Slot__c != null && tcobj.TC_Transition_Slot__c != oldMap.get(tcobj.id).TC_Transition_Slot__c) || 
                   (isInsert && tcobj.TC_Transition_Slot__c != null)) {
                        tcobj.Date_Booking_Made__c = system.today(); 
                }
                //ends here
                if(slotIdandSlotrecord != null && slotIdandSlotrecord.Containskey(tcobj.TC_Transition_Slot__c)) { 
                    tcobj.Slot_Description__c = slotIdandSlotrecord.get(tcobj.TC_Transition_Slot__c).Transition_Slot_Description__c;
                    //tcobj.Date_Booking_Made__c = system.today();  
                } else {
                        tcobj.Slot_Description__c = '';
                        tcobj.Date_Booking_Made__c = null;  
                }      
            }    
            if(tcListwithNoFreeSpace.size()>0 && tcListwithNoFreeSpace != null) {   
                for(Talent_Central__c tcobj : tcListwithNoFreeSpace) {
                   tcobj.addError('Can not choose Slot with free space less than or equal to zero.');    
                    //break;
                } 
            }         
        }
        if(isInsert) 
        {   
            //Utility.slotProvandConfTotal(newTalentCentral);                  
            Utility.slotProvandConfTotal(tcListwithFreeSpace);        
        }
    
    }//CommonInsertUpdate

}
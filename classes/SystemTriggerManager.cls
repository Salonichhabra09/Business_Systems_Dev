/**************************************************************************************************************************************
CREATED BY :- RISHABH KANOTRA
CREATED DATE :- 20/08/2019
DESCRIPTION :- This class contains various validations and restrictions to modify System__c and its fields and refered from System_Trigger triggers :before insert , before update
***************************************************************************************************************************************/ 

Global class SystemTriggerManager{

    //Manage the Integrator Account, Integrator Account :Account Name and Integrator Platform Fields
    public static void BeforeInsertSystem(List<System__c> newSystem , Map<id,System__c> oldmap, Boolean isInsert, Boolean isUpdate){
        BeforeInsertUpdateCommon(newSystem, oldmap, isInsert, isUpdate);
    }//BeforeInsertSystem
    
    //Manage the Integrator Account, Integrator Account :Account Name and Integrator Platform Fields
    public static void BeforeUpdateSystem(List<System__c> newSystem , Map<id,System__c> oldmap, Boolean isInsert, Boolean isUpdate){
        BeforeInsertUpdateCommon(newSystem, oldmap, isInsert, isUpdate);
    }//BeforeUpdateSystem
    
    public static void BeforeInsertUpdateCommon(List<System__c> newSystem , Map<id,System__c> oldmap, Boolean isInsert, Boolean isUpdate){
    
        Schema.DescribeFieldResult pickvalues = System__c.Integrator_Account_Account_Name__c.getDescribe();
        Set<string> availableAccountSet= new Set<string>();
        //List of Integrator account available in picklist
        for(Schema.PicklistEntry p1:pickvalues .getPicklistValues()){
            availableAccountSet.add(p1.getValue());
        }
        system.debug('**availableAccountSet**='+availableAccountSet);
        
        Set<Id> selectedIntegratorAccountIdsLKP = new Set<Id>();
        
        Id RecordTypeId = Schema.SObjectType.System__c.getRecordTypeInfosByName().get('Client System').getRecordTypeId();
        for(System__c sys : newSystem ){
            if(sys.RecordTypeId == RecordTypeId){
            
            
                //If user select integrator account from lookup
                if(sys.Integrator_Account__c !=null){
                    selectedIntegratorAccountIdsLKP.add(sys.Integrator_Account__c);
                    //If user select value for integrator account picklist
                }
            
            
            }
        }
        //if(selectedIntegratorAccountIdsPKL.size()>0 || selectedIntegratorAccountIdsLKP.size()>0){
        if(selectedIntegratorAccountIdsLKP.size()>0){
        
            //If integrator account lookup value is changed then fetch the account id,account record from account
            Map<Id,String> selectedAccountIdMap = new Map<Id,String>();
            Map<Id,String> toBeUsedAccountIdMap = new Map<Id,String>();
            for(Account acc:[select id,name from Account where Id IN:selectedIntegratorAccountIdsLKP]){
                toBeUsedAccountIdMap.put(acc.Id,acc.Name);
                if(acc.Name.contains('(Alliance)'))
                acc.Name = acc.Name.replace('(Alliance)','').trim();
                
                selectedAccountIdMap.put(acc.Id,acc.Name);
            }
            //system.debug('**selectedAccountIdMap**='+selectedAccountIdMap);
            for(System__c sys : newSystem ){
            	SystemTriggerManager.populateFieldsOnSystem(sys, oldmap,toBeUsedAccountIdMap, isInsert, isUpdate);//added by sanjeev populate fields on system before insert and update
                if(selectedAccountIdMap.containsKey(sys.Integrator_Account__c)){
                    //If selected integrator account lookup is part of picklist values
                    if(availableAccountSet.contains(selectedAccountIdMap.get(sys.Integrator_Account__c))){
                        //If integrator account lookup value is updated then update the integrator account picklist
                        if(isUpdate){
                            if(sys.Integrator_Account__c !=oldmap.get(sys.Id).Integrator_Account__c){
                            	//If integrator account lookup value is updated then update the integrator account picklist
                            	sys.Integrator_Account_Account_Name__c = selectedAccountIdMap.get(sys.Integrator_Account__c);
                            }
                        }
                        if(isInsert){
                            //If integrator account lookup value is updated then update the integrator account picklist
                            sys.Integrator_Account_Account_Name__c = selectedAccountIdMap.get(sys.Integrator_Account__c);
                        }
                        //in case selected Integrator Account lookup is not in integrator account picklist
                    }else{
                        if(isInsert){
                            //Set the integrator platform value in case integrator account match the account or vice versa
                            if(sys.Integrator_Account__c==sys.Account__c){
                            sys.Integrator_Platform__c='Client System';
                            }else if(sys.Integrator_Account__c!=sys.Account__c){
                            sys.Integrator_Platform__c=toBeUsedAccountIdMap.get(sys.Integrator_Account__c);
                            }
                        }
                        if(isUpdate){
                        
                            //Set the integrator platform value in case integrator account match the account or vice versa
                            if(sys.Integrator_Account__c==sys.Account__c){
                            sys.Integrator_Platform__c='Client System';
                            }else if(sys.Integrator_Account__c!=sys.Account__c){
                            sys.Integrator_Platform__c=toBeUsedAccountIdMap.get(sys.Integrator_Account__c);
                            }
                        
                        }
                    }
                }
            }
        }
        
    }//BeforeInsertUpdateCommon
    /*
	@@MehtodName - populateFieldsOnSystem
	@@@Description - Method to populate the system fields on before insert and update evnet
	@@@CreatedDate - 07-July-2022
	@@@Paremeters - System__c sys Map<id,System__c> oldmap, Map<id,String> toBeUsedAccountIdMap,Boolean isInsert, Boolean isUpdate
	@@@Author - Sanjeev Kaurav
	*/
    public static void populateFieldsOnSystem(System__c sys, Map<id,System__c> oldmap, Map<id,String> toBeUsedAccountIdMap,Boolean isInsert, Boolean isUpdate){
        if(toBeUsedAccountIdMap.containsKey(sys.Integrator_Account__c)){
            if(isInsert || (isUpdate && sys.Integrator_Account__c !=oldmap.get(sys.Id).Integrator_Account__c)){
                String accountName = toBeUsedAccountIdMap.get(sys.Integrator_Account__c);
                if(accountName.indexOf(' (Alliance)') != -1){
                    accountName = accountName.replace(' (Alliance)', '');
                    //Integrator Platform value is set to null so that in case of update it does not contain the old value.
                    sys.Integrator_Platform__c=null;
                    sys.Integrator_Account_Account_Name__c=accountName;
                }else{
                    sys.Integrator_Platform__c=null;
                    sys.Integrator_Account_Account_Name__c=null;
                }      
            }
        }
    }

	public static void updateNumberOfIntegratedLiveSystem(List<System__c> newSystemList , Map<Id,System__c> oldSystemMap, System.TriggerOperation triggerOpperationType){

        Set<Id> accID = new Set<Id>();
        
        if(newSystemList.size()>0){
            for(System__c sys : newSystemList){
                
                if(String.valueOf(triggerOpperationType) == 'AFTER_INSERT' || String.valueOf(triggerOpperationType) == 'AFTER_DELETE' || String.valueOf(triggerOpperationType) == 'AFTER_UNDELETE'){
                    if(sys.Status__c == 'Live' && sys.Integrated__c == 'Yes' && sys.Account__c != null){
                        accID.add(sys.Account__c); 
                    }
                } else if(String.valueOf(triggerOpperationType) == 'AFTER_UPDATE'){

                    if((((sys.Status__c == 'Live' && sys.Integrated__c == 'Yes') &&
                         (sys.Status__c != oldSystemMap.get(sys.Id).Status__c ||
                          sys.Integrated__c != oldSystemMap.get(sys.Id).Integrated__c)) &&
                        sys.Account__c != null ) || 
                       (((sys.Status__c != 'Live' || sys.Integrated__c != 'Yes') &&
                         (oldSystemMap.get(sys.Id).Status__c == 'Live' && 
                          oldSystemMap.get(sys.Id).Integrated__c == 'Yes')) && 
                        sys.Account__c != null ) ||
                       (sys.Status__c == 'Live' && sys.Integrated__c == 'Yes' && 
                        sys.Account__c != null && 
                        sys.Account__c != oldSystemMap.get(sys.Id).Account__c)
                       ){
                           accID.add(sys.Account__c);
                           accID.add(oldSystemMap.get(sys.Id).Account__c);
                       }
                } 
            }
        }
        
        List<Account> accList = [Select id ,No_of_Integrated_Live_System__c, 
                                 (SELECT Id FROM Systems__r Where Status__c = 'Live' AND Integrated__c = 'Yes') 
                                 FROM Account WHERE Id in :accID];

        
        if(accList.size() > 0){
            for(Account acc : accList){
                acc.No_of_Integrated_Live_System__c = acc.Systems__r.size();      
            }
            
            update accList;            
        }

        
    }

}
/**************************************************************************************************************************************
CREATED BY :- Virendra Kumar
CREATED DATE :- 07-06-2019
DESCRIPTION :- This Trigger Controls the execution of below Classes:
               1. ContactTriggerManager for creation and updation of sfdcAccountTransferSyncHist record and mailing address as per related account respectively.
               2. Account_Manager for updation of No of Contact field.
***************************************************************************************************************************************/
trigger Contact_Trigger on Contact (before insert,before update,after Insert, after Update,after Delete,after Undelete) {
    
 if(Trigger_Activation__c.getInstance('Contact_Trigger').Active__c || Test.isRunningTest()){  
    //Set<ID> accountIds = new Set<ID>(); //To update the No of Contact field on Account  
    //list<Contact> contacts;//to store old & new contacts 
     List<Contact> contactList = Trigger.isDelete ? Trigger.Old : Trigger.New;
    //To store all new & old Account
    /*if(trigger.isDelete)
    {
        if(trigger.isAfter && contactList.)
        {
            contacts=trigger.old;
        }
    }
    else
        contacts=trigger.new;*/
    // get list of accounts related to contacts   
    /*for (Contact contact : contacts) {
  
        accountIds.add(contacts.AccountId);
    }*/
    
    //For updation of mailing Address when Same as billing address check box is checked
    
    if(trigger.isupdate)
        
    {
        system.debug('Prachi update');
        if(trigger.isBefore)
        {  
            
            ContactTriggerManager.mapGlobalCountryFields(Trigger.new,Trigger.oldMap,trigger.newMap);//SSE-16905 - Prachi
            ContactTriggerManager.mapAccountNumberOnContacts(Trigger.new,Trigger.oldMap,trigger.newMap);//SSE-17153 - Prachi (Duplicate Rules -- 22 Nov'22)
            ContactTriggerManager.updatemailingAddress(trigger.new);
            ContactTriggerManager.checkPersonalEmailAddressDomain(trigger.new, trigger.oldMap);
            //ContactTriggerManager.computeOutputDetailForMarketingPermissible(trigger.new, trigger.oldMap);
            ContactTriggerManager.computeEmailSubscriptionValues(trigger.new, trigger.oldMap);
         }   
    }
    
    if(trigger.isInsert)
    {
        if(trigger.isBefore)
        {  
            ContactTriggerManager.mapGlobalCountryFields(Trigger.new,Null,trigger.newMap);//SSE-16905 - Prachi
            ContactTriggerManager.mapAccountNumberOnContacts(Trigger.new,Null,trigger.newMap);//SSE-17153 - Prachi (Duplicate Rules)
            ContactTriggerManager.updatemailingAddress(trigger.new);
            ContactTriggerManager.updateRegistrationNumber(trigger.new);
            ContactTriggerManager.checkPersonalEmailAddressDomain(trigger.new, null);
            //ContactTriggerManager.computeOutputDetailForMarketingPermissible(trigger.new, null);
            ContactTriggerManager.computeEmailSubscriptionValues(trigger.new, null);
        }   
        if(trigger.isAfter){
            ContactTriggerManager.updateRegistration(trigger.new);
            
        }
    }
    //Calling below future method to update NumberOfContacts field on accounts whose ids we are passing to the method.
    // Prachi SSE-19716
    
        if(trigger.isAfter && (trigger.isUpdate || trigger.isUndelete || trigger.isDelete || trigger.isInsert))
        {
             system.debug('Inside update Contacts');
            //Account_Manager.updateNumberOfContacts(accountIds);
            if(trigger.isUpdate){
                ContactTriggerManager.updateNumberOfContacts(contactList,trigger.oldMap);
                ContactTriggerManager.syncContactsFromEloqua(trigger.New, trigger.oldMap);
                ContactTriggerManager.syncLeadStatusWithContact(trigger.New, trigger.oldMap);
                //ContactTriggerManager.computeOutputDetailForMarketingPermissible(trigger.new, trigger.oldMap);
            }
            else{
                 ContactTriggerManager.updateNumberOfContacts(contactList,null);
                //ContactTriggerManager.computeOutputDetailForMarketingPermissible(trigger.new, null);
            }
             
        }  
        
     // End -SSE-19716
    
    //For creation of SFDC2Sun_Transfer_or_Sync_History__c record
    
    if(trigger.isUpdate)
    {
        if(trigger.isAfter)
        {
            //ContactTriggerManager.NewsfdcAccountTransferSyncHist(trigger.new,trigger.old);
        }
    }
   }
}
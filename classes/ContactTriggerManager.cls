/**************************************************************************************************************************************
CREATED BY :- Virendra Kumar
CREATED DATE :- 07-06-2019
DESCRIPTION :- This class contains:
1. Updation of mailing address field on Contact as per billing address field on related Account from Contact Triggers:BeforeInsert,BeforeUpdate
2. Creation of sfdcAccountTransferSyncHist record from Contact Triggers: AfterUpdate
***************************************************************************************************************************************/

public class ContactTriggerManager {
    
    //For updation of mailing Address as per related Account billing address when Same as billing address check box is true
    public static void updatemailingAddress(List<Contact> Conlistnew)
    {
        Id currentUserProfileId = UserInfo.getProfileId();
        String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;
        if(profileName!='Eloqua User' && profileName!='System Administrator Globus'){
            Set<Id> accountIdsSetforAddress = new Set<Id>(); // To update the mailing address field on contact
            for(Integer i=0;i<Conlistnew.size();i++)
            {
                if(Conlistnew[i].AccountId!=null && Conlistnew[i].Same_As_The_Account_Billing_Address__c == true)            
                    accountIdsSetforAddress.add(Conlistnew[i].AccountId);
            }
            //Create a Map of <Id,Account> which will store Account Billing address fields based on account ids fetched in accountIdsSet
            Map<Id,Account> accountMap = new Map<Id,Account>([select id, Billing_Address_Line_1__c,Global_Billing_Country__c,Billing_Address_Line_2__c,Billing_Address_Line_3__c,Billing_Address_Line_4__c,Billing_City__c,Billing_Country__c,Billing_State__c,Billing_ZIP_Postal_Code__c 
                                                              from account 
                                                              where id in :accountIdsSetforAddress]);
            //Contact Mailing Address will be inserted only in cases where Same As The Billing Address is true
            if(accountIdsSetforAddress.size()>0)
            {  
                for(Integer i=0; i< Conlistnew.size();i++)  
                {
                    //check for AccountId is not null and Same As The Billing Address is true then only updates copies of Mapping Address Accordingly
                    if(Conlistnew[i].AccountId!=null && Conlistnew[i].Same_As_The_Account_Billing_Address__c == true)            
                    {
                        Conlistnew[i].Mailing_Address_Line_1__c=accountMap.get(Conlistnew[i].AccountId).Billing_Address_Line_1__c;
                        Conlistnew[i].Mailing_Address_Line_2__c=accountMap.get(Conlistnew[i].AccountId).Billing_Address_Line_2__c;
                        Conlistnew[i].Mailing_Address_Line_3__c=accountMap.get(Conlistnew[i].AccountId).Billing_Address_Line_3__c;
                        Conlistnew[i].Mailing_Address_Line_4__c=accountMap.get(Conlistnew[i].AccountId).Billing_Address_Line_4__c;
                        Conlistnew[i].Mailing_City__c=accountMap.get(Conlistnew[i].AccountId).Billing_City__c;
                        Conlistnew[i].Mailing_Country__c=accountMap.get(Conlistnew[i].AccountId).Global_Billing_Country__c;//SSE-16905 - Prachi
                        Conlistnew[i].Global_Mailing_Country__c=accountMap.get(Conlistnew[i].AccountId).Global_Billing_Country__c;//SSE-16905 - Prachi
                        Conlistnew[i].Mailing_State_County__c=accountMap.get(Conlistnew[i].AccountId).Billing_State__c;
                        Conlistnew[i].Mailing_ZIP_Postal_Code__c=accountMap.get(Conlistnew[i].AccountId).Billing_ZIP_Postal_Code__c;
                    }                  
                }
            }
        }
    }
    //For creation of related SFDC2Sun_Transfer_or_Sync_History__c record, when the Contact is updated and SFDC2Sun_Transfer_or_Sync_History__c record is not created.
    //commented as part of PA stream migration as no longer needed 
    /*public static void NewsfdcAccountTransferSyncHist(List<Contact> Conlistnew, List<Contact> Conlistold)
{
List<SFDC2Sun_Transfer_or_Sync_History__c> sfdcTransferOrSyncHistList = new List<SFDC2Sun_Transfer_or_Sync_History__c>();

for(Integer i=0; i< Conlistnew.size();i++)
{ 
if(Conlistnew[i].SFDC2SUN_TransferStatus__c!=null && Conlistnew[i].SFDC2SUN_TransferStatus__c!='Not Transferred' && Conlistnew[i].SFDC2SUN_SyncStatus__c == Conlistold[i].SFDC2SUN_SyncStatus__c && 
(Conlistnew[i].OwnerId  != Conlistold[i].OwnerId || Conlistnew[i].Salutation   != Conlistold[i].Salutation  || Conlistnew[i].FirstName  != Conlistold[i].FirstName || 
Conlistnew[i].LastName  != Conlistold[i].LastName || Conlistnew[i].Registration_Number__c  != Conlistold[i].Registration_Number__c || Conlistnew[i].LegacyRegistrationNumber__c  != Conlistold[i].LegacyRegistrationNumber__c || 
Conlistnew[i].Mailing_Address_Line_1__c  != Conlistold[i].Mailing_Address_Line_1__c || Conlistnew[i].Mailing_Address_Line_2__c  != Conlistold[i].Mailing_Address_Line_2__c || Conlistnew[i].Mailing_Address_Line_3__c  != Conlistold[i].Mailing_Address_Line_3__c || 
Conlistnew[i].Mailing_Address_Line_4__c  != Conlistold[i].Mailing_Address_Line_4__c || Conlistnew[i].Mailing_City__c  != Conlistold[i].Mailing_City__c || Conlistnew[i].Mailing_State_County__c  != Conlistold[i].Mailing_State_County__c || 
Conlistnew[i].Mailing_ZIP_Postal_Code__c  != Conlistold[i].Mailing_ZIP_Postal_Code__c || Conlistnew[i].MobilePhone  != Conlistold[i].MobilePhone || 
Conlistnew[i].Mailing_Country__c  != Conlistold[i].Mailing_Country__c || Conlistnew[i].Fax  != Conlistold[i].Fax || 
Conlistnew[i].Phone  != Conlistold[i].Phone || Conlistnew[i].Accounts_Payable_Contact__c  != Conlistold[i].Accounts_Payable_Contact__c || Conlistnew[i].Email  != Conlistold[i].Email || 
Conlistnew[i].Qualifications__c  != Conlistold[i].Qualifications__c || 
(Conlistnew[i].SFDC2SUN_Resync__c != Conlistold[i].SFDC2SUN_Resync__c && Conlistnew[i].SFDC2SUN_Resync__c ==true)))

{

List<SFDC2Sun_Transfer_or_Sync_History__c> sfdc2SunTran = [Select id from SFDC2Sun_Transfer_or_Sync_History__c 
where CreatedDate >:System.now().addSeconds(-1) and 
Version__c = :Conlistnew[i].SFDC2SUN_SfdcVersion__c
and Contact__c = :Conlistnew[i].id];
if(sfdc2SunTran.size()==0)
{

SFDC2Sun_Transfer_or_Sync_History__c sfdcAccountTransferSyncHist = new SFDC2Sun_Transfer_or_Sync_History__c();
if(Conlistnew[i].SFDC2SUN_SfdcVersion__c==null) //Added By Priyank for story SSE-10185
Conlistnew[i].SFDC2SUN_SfdcVersion__c=0;
else
sfdcAccountTransferSyncHist.Version__c = Conlistnew[i].SFDC2SUN_SfdcVersion__c+1;
sfdcAccountTransferSyncHist.Start_Date__c = System.now();
sfdcAccountTransferSyncHist.Contact__c = Conlistnew[i].id;
sfdcAccountTransferSyncHist.User__c =  UserInfo.getUserId();
if(Conlistnew[i].SFDC2SUN_Resync__c ==false)
{
sfdcAccountTransferSyncHist.Status__c = 'Syncing';
sfdcAccountTransferSyncHist.Action__c =  'Sync';
}
else
{
sfdcAccountTransferSyncHist.Status__c = 'Resyncing';
sfdcAccountTransferSyncHist.Action__c =  'Resync';
}
sfdcTransferOrSyncHistList.add(sfdcAccountTransferSyncHist);
}

}
}
if(sfdcTransferOrSyncHistList.size()>0)
insert sfdcTransferOrSyncHistList;
}*/
    
    public static void updateRegistrationNumber(List<Contact> conlistnew){
        
        Set<Id> contactSetId = new Set<Id>();
        for(Contact con : conlistnew){
            contactSetId.add(con.getCloneSourceId());
        }
        
        Map<Id, Contact> mapContact = new Map<Id, Contact>([SELECT Id, Registration_Number_legacy__c, Double_Opted_In__c, Email_Opted_In__c,Qualifications__c,
                                                            X360__c,MAS_training_date__c,Ability_tests_training_date__c,ASST__c,BPOA__c,Decision_Maker__c,Intergrity_INT__c,
                                                            Insight_Work__c,Interview_training_date__c,JACD__c,MFS_training_date__c,MQ_training_date__c,OAS_training_date__c,
                                                            OPQ_training_date__c,ORS_traininig_date__c,Personaility_Basics__c,SAT__c,Test_admin_training_date__c,Soda__c,
                                                            AM_SFDC_Contact_Record_ID__c FROM Contact WHERE ID IN : contactSetId]);
        
        
        for(Contact con : conlistnew){
            if(mapContact.containsKey(con.getCloneSourceId())){
                con.Registration_Number_legacy__c = mapContact.get(con.getCloneSourceId()).Registration_Number_legacy__c;
                con.Double_Opted_In__c = mapContact.get(con.getCloneSourceId()).Double_Opted_In__c;
                con.Email_Opted_In__c = mapContact.get(con.getCloneSourceId()).Email_Opted_In__c;
                con.Qualifications__c = mapContact.get(con.getCloneSourceId()).Qualifications__c;
                con.X360__c = mapContact.get(con.getCloneSourceId()).X360__c;
                con.MAS_training_date__c = mapContact.get(con.getCloneSourceId()).MAS_training_date__c;
                con.Ability_tests_training_date__c = mapContact.get(con.getCloneSourceId()).Ability_tests_training_date__c;
                con.ASST__c = mapContact.get(con.getCloneSourceId()).ASST__c;
                con.BPOA__c = mapContact.get(con.getCloneSourceId()).BPOA__c;
                con.Decision_Maker__c = mapContact.get(con.getCloneSourceId()).Decision_Maker__c;
                con.Intergrity_INT__c = mapContact.get(con.getCloneSourceId()).Intergrity_INT__c;
                con.Insight_Work__c = mapContact.get(con.getCloneSourceId()).Insight_Work__c;
                con.Interview_training_date__c = mapContact.get(con.getCloneSourceId()).Interview_training_date__c;
                con.JACD__c = mapContact.get(con.getCloneSourceId()).JACD__c;
                con.MFS_training_date__c = mapContact.get(con.getCloneSourceId()).MFS_training_date__c;
                con.MQ_training_date__c = mapContact.get(con.getCloneSourceId()).MQ_training_date__c;
                con.OAS_training_date__c = mapContact.get(con.getCloneSourceId()).OAS_training_date__c;
                con.OPQ_training_date__c = mapContact.get(con.getCloneSourceId()).OPQ_training_date__c;
                con.ORS_traininig_date__c = mapContact.get(con.getCloneSourceId()).ORS_traininig_date__c;
                con.Personaility_Basics__c = mapContact.get(con.getCloneSourceId()).Personaility_Basics__c;
                con.SAT__c = mapContact.get(con.getCloneSourceId()).SAT__c;
                con.Test_admin_training_date__c = mapContact.get(con.getCloneSourceId()).Test_admin_training_date__c;
                con.Soda__c = mapContact.get(con.getCloneSourceId()).Soda__c;
                con.AM_SFDC_Contact_Record_ID__c = mapContact.get(con.getCloneSourceId()).AM_SFDC_Contact_Record_ID__c;
            }
        }
    }
    
    
    public static void updateRegistration(List<Contact> conlistnew){        
        Map<Id, Boolean> mapCheckCloneRec = new Map<Id, Boolean>();
        for(Contact con : conlistnew){
            mapCheckCloneRec.put(con.Id, con.isClone());
        }
        
        
        list<Contact> contactLst = new List<Contact>();
        if(!mapCheckCloneRec.isEmpty()){
            for(Contact conObj : [SELECT ID, Registration_Number__c  FROM CONTACT WHERE ID IN : mapCheckCloneRec.keyset() AND Registration_Number_legacy__c = null]){
                if(mapCheckCloneRec.containsKey(conObj.Id) && !mapCheckCloneRec.get(conObj.Id)){
                    conObj.Registration_Number_legacy__c = conObj.Registration_Number__c; 
                    conObj.AutomationBypassDateTime__c = system.now();
                    contactLst.add(conObj);
                }
                
            }  
            
            if(!contactLst.isEmpty()){
                update contactLst;
            }
        }
        
        /*
Map<Id, Contact> mapContact = new Map<Id, Contact>([SELECT Id, Registration_Number_legacy__c FROM Contact WHERE ID IN : contactSetId]);


for(Contact con : conlistnew){
if(mapContact.containsKey(con.getCloneSourceId())){
con.Registration_Number_legacy__c = mapContact.get(con.getCloneSourceId()).Registration_Number_legacy__c;
}
}*/
    }
    
    //Change starts for SSE-16905 - Prachi
    public static void mapGlobalCountryFields(List<Contact> newContact,Map<Id,Contact> oldContactMap,
                                              Map<Id,Contact> newContactMap){
                                                  for(Contact con : newContact){
                                                      try{
                                                          if(oldContactMap == Null || (oldContactMap != Null && 
                                                                                       con.Global_Mailing_Country__c!= oldContactMap.get(con.Id).Global_Mailing_Country__c)){
                                                                                           con.Mailing_Country__c = con.Global_Mailing_Country__c;
                                                                                       }
                                                      }catch(DmlException ex){
                                                          Contact actualRecord = newContactMap.get(con.Id); 
                                                          actualRecord.addError('We get the following error : ' +
                                                                                ex.getDmlMessage(0));
                                                      }}
                                                  
                                              }
    //Changes ends SSE-16905
    
    //changes done for Duplicate Rules on Contacts to map the account number on contact -Prachi SSE-17153
    public static void mapAccountNumberOnContacts(List<Contact> newContact, Map<Id,Contact> oldContactMap,Map<Id,Contact> newContactMap){
        
        
        if(newContact != null){
            for(Contact con: newContact){
                
                if(con.AccountId!=null && (oldContactMap == Null || (oldContactMap != Null && ((con.Account_Record_ID__c == null)||
                                                                                               (con.AccountId!= oldContactMap.get(con.Id).AccountId))))){
                                                                                                   system.debug('c.AccountId' + con.AccountId);
                                                                                                   con.Account_Record_ID__c = con.AccountId;
                                                                                                   
                                                                                               }  }
        }
        
        
    }
    
    public static void updateNumberOfContacts(List<Contact> conList , Map<Id,Contact> conMap){
        system.debug('Inside update Contacts');
        Set<Id> accID = new Set<Id>();
        
        if(conList.size()>0){
            for(Contact con : conList){
                if(con.AccountId != null && (conMap== null || (conMap!= null && (con.AccountId!= conMap.get(con.Id).AccountId)))){
                    accID.add(con.AccountId);
                    List<Accounts_Merged__e> mergedAcctList = new List<Accounts_Merged__e>();//Merge POC     
                        //checking MasterRecordId because of merge operation on account.
                        if(con.MasterRecordId!=null){            
                            Accounts_Merged__e mergeAcct = new Accounts_Merged__e();
                            mergeAcct.Merged_Account__c = con.MasterRecordId;
                            mergedAcctList.add(mergeAcct);
                        }
                    
                    //Merge POC 
                    if(mergedAcctList.size()>0){
                        List<Database.SaveResult> results = EventBus.publish(mergedAcctList);
                        for (Database.SaveResult sr : results) {
                            if (sr.isSuccess()) {
                                System.debug('Successfully published event.');
                            }
                        }
                    }
                }
                if(con.AccountId != null && (conMap!= null && (con.AccountId!= conMap.get(con.Id).AccountId))){
                    accID.add(conMap.get(con.Id).AccountId); 
                }
            }
        }
        List<Account> accList = [Select id ,NumberOfContacts__c, (SELECT Id FROM Contacts)  FROM Account WHERE Id in :accID];
        
        for(Account acc : accList){
            acc.NumberOfContacts__c = acc.Contacts.size();      
        }  
        update accList;
        
    }
    
    public static void syncContactsFromEloqua(List<Contact> contactList , Map<Id,Contact> oldContactMap){
        
        Map<String, Contact> contactEmailMap = new Map<String, Contact>();
        for(Contact con : contactList){
            if(con.Email_Opted_In__c != oldContactMap.get(con.Id).Email_Opted_In__c	
              || con.Double_Opted_In__c != oldContactMap.get(con.Id).Double_Opted_In__c
              || con.Inactive_in_Eloqua__c != oldContactMap.get(con.Id).Inactive_in_Eloqua__c
              || con.Email_Undeliverable__c != oldContactMap.get(con.Id).Email_Undeliverable__c
              || con.Do_Not_Contact__c != oldContactMap.get(con.Id).Do_Not_Contact__c
              || con.Constant_Soft_Bounce_Domain__c != oldContactMap.get(con.Id).Constant_Soft_Bounce_Domain__c
              || con.Constant_Soft_Bounce_Contact__c != oldContactMap.get(con.Id).Constant_Soft_Bounce_Contact__c
              || con.Email_Group_Subscription__c != oldContactMap.get(con.Id).Email_Group_Subscription__c)
            {
                if (String.isNotBlank(con.Email)) {
                 	contactEmailMap.put(con.Email, con);    
                }  
            }  
        }
        if(!contactEmailMap.isEmpty()){
            list<Contact> sameEmailContactList = [SELECT Id, Email, Email_Opted_In__c, Double_Opted_In__c, Inactive_in_Eloqua__c,
                                                  Email_Undeliverable__c, Do_Not_Contact__c, Contact_Status__c, 
                                                  Global_Mailing_Country__c, LID__No_longer_at_Company__c, Do_Not_Contact_Reason__c,
                                                  Personal_Email_Address_Domain__c, Constant_Soft_Bounce_Domain__c, Constant_Soft_Bounce_Contact__c,
                                                  Email_Group_Subscription__c
                                                  FROM Contact
                                                  WHERE Email IN :contactEmailMap.keySet()];
            
            if(!sameEmailContactList.isEmpty()){
                for(Contact con : sameEmailContactList){
                    con.Email_Opted_In__c = contactEmailMap.get(con.Email).Email_Opted_In__c;
                    con.Double_Opted_In__c = contactEmailMap.get(con.Email).Double_Opted_In__c;
                    con.Inactive_in_Eloqua__c = contactEmailMap.get(con.Email).Inactive_in_Eloqua__c;
                    con.Email_Undeliverable__c = contactEmailMap.get(con.Email).Email_Undeliverable__c;
                    con.Do_Not_Contact__c = contactEmailMap.get(con.Email).Do_Not_Contact__c;
                    con.Do_Not_Contact_Reason__c = contactEmailMap.get(con.Email).Do_Not_Contact_Reason__c;
                    con.Constant_Soft_Bounce_Domain__c = contactEmailMap.get(con.Email).Constant_Soft_Bounce_Domain__c;
                    con.Constant_Soft_Bounce_Contact__c = contactEmailMap.get(con.Email).Constant_Soft_Bounce_Contact__c;
                    con.Email_Group_Subscription__c = contactEmailMap.get(con.Email).Email_Group_Subscription__c;
                }
                try{
                    UPDATE sameEmailContactList;   
                }
                catch(DMLException ex){
                    System.debug(ex.getMessage());
                }
            }   
        }
    }
    
    public static void checkPersonalEmailAddressDomain(List<Contact> contactList, Map<Id,Contact> oldContactMap){
        
        Set<String> personalDomainSet = new Set<String>();
        Set<String> invalidDomainSet = new Set<String>();
        Boolean getMetadataRecords = false;
        
        for(Contact con : contactList){
            if(oldContactMap == null || (oldContactMap != null && (con.Email != oldContactMap.get(con.Id).Email || con.Contact_Status__c != oldContactMap.get(con.Id).Contact_Status__c))){
                if(con.Email != null){
                    getMetadataRecords = true;
                    break;
                }
            }
        }
        
        if(getMetadataRecords){
            // Load Email Domains Custom Metadata
            for (Email_Address_Domain__mdt rec : [SELECT Domain__c, Domain_Type__c FROM Email_Address_Domain__mdt WHERE Domain__c != null]) 
            {
                if(rec.Domain_Type__c == 'Invalid'){
                    invalidDomainSet.add(rec.Domain__c.trim().toLowerCase());
                }else{
                 	personalDomainSet.add(rec.Domain__c.trim().toLowerCase());   
                }
            }   
        }
        
        if((!personalDomainSet.isEmpty()) || (!invalidDomainSet.isEmpty())){
            for(Contact con : contactList){
                if(oldContactMap == null || (oldContactMap != null && (con.Email != oldContactMap.get(con.Id).Email || con.Contact_Status__c != oldContactMap.get(con.Id).Contact_Status__c))){
                    if(con.Email != null){
                        String domain = con.Email.substringAfter('@').trim().toLowerCase();
                        if(personalDomainSet.contains(domain)){
                            con.Personal_Email_Address_Domain__c = true;
                        }else if(invalidDomainSet.contains(domain)){
                            con.Contact_Status__c = 'Active-Invalid Email';
                            con.Personal_Email_Address_Domain__c = false;
                        }else{
                            con.Personal_Email_Address_Domain__c = false;
                        }
                    }   
                }
            }   
        }
    }
    
    //Update Lead Status to Left Institution if Contact is marked as Left Institution
    //sync Contact Status to Left Institution if a Contact is marked as Left Institution
    public static void syncLeadStatusWithContact(List<Contact> contactList, Map<Id,Contact> oldContactMap){
        
        Map<String, String> leadEmailStatusMap = new Map<String, String>();
        Map<String, String> contactEmailStatusMap = new Map<String, String>();
        list<Lead> leadsToUpdate = new list<Lead>();
        
        for(Contact con : contactList){
            if(con.Contact_Status__c != oldContactMap.get(con.Id).Contact_Status__c) {
               if(con.Contact_Status__c == 'Left Institution'){
                   leadEmailStatusMap.put(con.Email.toLowerCase(), 'Left Institution');
                   contactEmailStatusMap.put(con.Email.toLowerCase(), con.Contact_Status__c);
               }
                else if(con.Contact_Status__c == 'Deceased'){
                   leadEmailStatusMap.put(con.Email.toLowerCase(), 'Deceased');
                   contactEmailStatusMap.put(con.Email.toLowerCase(), con.Contact_Status__c);
               }
                else if(con.Contact_Status__c == 'Retired'){
                   leadEmailStatusMap.put(con.Email.toLowerCase(), 'Retired');
                   contactEmailStatusMap.put(con.Email.toLowerCase(), con.Contact_Status__c);
               }
                else if(con.Contact_Status__c == 'Active-Invalid Email'){
                   leadEmailStatusMap.put(con.Email.toLowerCase(), 'Active-Invalid Email');
                   contactEmailStatusMap.put(con.Email.toLowerCase(), con.Contact_Status__c);
               }
                else if(con.Contact_Status__c == 'Active' && (oldContactMap.get(con.Id).Contact_Status__c == 'Left Institution') || (oldContactMap.get(con.Id).Contact_Status__c == 'Retired')){
                    leadEmailStatusMap.put(con.Email.toLowerCase(), 'Open');
                    contactEmailStatusMap.put(con.Email.toLowerCase(), con.Contact_Status__c);
                }
            }
        }
        
        if(!leadEmailStatusMap.isEmpty()){
            list<Lead> sameEmailLeadList = [SELECT Id, Email,Status FROM Lead WHERE Email IN :leadEmailStatusMap.keySet()];
            
            if(!sameEmailLeadList.isEmpty()){
                for(Lead lead : sameEmailLeadList){
                    String newStatus = leadEmailStatusMap.get(lead.Email);
                    if(newStatus != lead.Status){
                        if((lead.Status == 'Left Institution' || lead.Status == 'Retired') && newStatus == 'Open'){
                            lead.Status = 'Open';
                        }else if (lead.Status != 'Left Institution' && newStatus == 'Left Institution'){
                            lead.Status = 'Left Institution';
                        }else if (lead.Status != 'Retired' && newStatus == 'Retired'){
                            lead.Status = 'Retired';
                        }else if (lead.Status != 'Deceased' && newStatus == 'Deceased'){
                            lead.Status = 'Deceased';
                        }else if (lead.Status != 'Active-Invalid Email' && newStatus == 'Active-Invalid Email'){
                            lead.Status = 'Active-Invalid Email';
                        }
                    }
                    leadsToUpdate.add(lead);
                }
                
            }
        }
        if(!contactEmailStatusMap.isEmpty()){
            list<Contact> sameContactList = [SELECT Id, Contact_Status__c, Email FROM Contact WHERE Email IN :contactEmailStatusMap.keySet()];
                if(!sameContactList.isEmpty()){
                    for(Contact con : sameContactList){
                        con.Contact_Status__c = contactEmailStatusMap.get(con.Email);
                    }
                }
            try{
                UPDATE sameContactList;   
            }
            catch(DMLException ex){
                System.debug(ex.getMessage());
            }
        }
        if(!leadsToUpdate.isEmpty()){
            try{
                UPDATE leadsToUpdate;   
            }
            catch(DMLException ex){
                System.debug(ex.getMessage());
            }   
        }
    }
    
    public static void computeEmailSubscriptionValues(List<Contact> contactList, Map<Id,Contact> oldContactMap){
        
        for(Contact con : contactList){
            if(oldContactMap == null && con.Email_Group_Subscription__c != null){
                con.Email_Subscription_Values__c = (con.Email_Group_Subscription__c).replace(';', ',');
            }else{
                if(con.Email_Group_Subscription__c != null && con.Email_Group_Subscription__c != oldContactMap.get(con.Id).Email_Group_Subscription__c){
                    con.Email_Subscription_Values__c = con.Email_Group_Subscription__c == null ? null : (con.Email_Group_Subscription__c).replace(';', ',');   
                }
            }
        }
    }
    /*
    public static void checkInvalidEmailAddressDomain(List<Contact> contactList, Map<Id,Contact> oldContactMap){
        
        Set<String> domainSet = new Set<String>();
        Boolean getMetadataRecords = false;
        
        for(Contact con : contactList){
            if(oldContactMap == null || (oldContactMap != null && con.Email != oldContactMap.get(con.Id).Email)){
                if(con.Email != null){
                    getMetadataRecords = true;
                    break;
                }
            }
        }
        
        if(getMetadataRecords){
            // Load Email Domains Custom Metadata
            for (Email_Address_Domain__mdt rec : [SELECT Domain__c FROM Email_Address_Domain__mdt WHERE Domain__c != null AND Domain_Type__c = 'Invalid']) 
            {
                domainSet.add(rec.Domain__c.trim().toLowerCase());
            }   
        }
        
        if(!domainSet.isEmpty()){
            for(Contact con : contactList){
                if(oldContactMap == null || (oldContactMap != null && con.Email != oldContactMap.get(con.Id).Email)){
                    if(con.Email != null){
                        String domain = con.Email.substringAfter('@').trim().toLowerCase();
                        if(domainSet.contains(domain)){
                            //con.Contact_Status__c = '';
                        }
                    }   
                }
            }   
        }
    }
    */
    /*
    public static void computeOutputDetailForMarketingPermissible(List<Contact> contactList, Map<Id,Contact> oldContactMap){
        Set<Id> contactIdSet = new  Set<Id>();
        for(Contact con : contactList){
            if(oldContactMap == null){
                contactIdSet.add(con.Id);
                //populateOutputDetail(con);
            }else{
                System.debug('populateOutputDetail oldContactMap '+ oldContactMap.get(con.Id).High_Risk_Country__c);
                System.debug('populateOutputDetail new '+ con.High_Risk_Country__c);
        		System.debug('populateOutputDetail oldContactMap '+ oldContactMap.get(con.Id).Global_Mailing_Country__c);
                System.debug('populateOutputDetail new '+ con.Global_Mailing_Country__c);
        		System.debug('populateOutputDetail oldContactMap '+ oldContactMap.get(con.Id).Email_Opted_In__c);
        		System.debug('populateOutputDetail oldContactMap '+ oldContactMap.get(con.Id).Inactive_in_Eloqua__c);
                if(con.Marketing_Permissible__c != oldContactMap.get(con.Id).Marketing_Permissible__c	
                   || con.Email_Opted_In__c != oldContactMap.get(con.Id).Email_Opted_In__c	
                   || con.Double_Opted_In__c != oldContactMap.get(con.Id).Double_Opted_In__c
                   || con.Inactive_in_Eloqua__c != oldContactMap.get(con.Id).Inactive_in_Eloqua__c
                   || con.Email_Undeliverable__c != oldContactMap.get(con.Id).Email_Undeliverable__c
                   || con.Do_Not_Contact__c != oldContactMap.get(con.Id).Do_Not_Contact__c
                   || con.Contact_Status__c != oldContactMap.get(con.Id).Contact_Status__c
                   || con.Global_Mailing_Country__c != oldContactMap.get(con.Id).Global_Mailing_Country__c
                   || con.Personal_Email_Address_Domain__c != oldContactMap.get(con.Id).Personal_Email_Address_Domain__c
                   || con.Constant_Soft_Bounce_Domain__c != oldContactMap.get(con.Id).Constant_Soft_Bounce_Domain__c
                   || con.Constant_Soft_Bounce_Contact__c != oldContactMap.get(con.Id).Constant_Soft_Bounce_Contact__c
                   || con.Email_Group_Subscription__c != oldContactMap.get(con.Id).Email_Group_Subscription__c
                   || con.Calculated_ACV__c != oldContactMap.get(con.Id).Calculated_ACV__c
                   || con.High_Risk_Country__c != oldContactMap.get(con.Id).High_Risk_Country__c
                   || con.NonHotCountryCheck__c != oldContactMap.get(con.Id).NonHotCountryCheck__c){
                       contactIdSet.add(con.Id);
                       //populateOutputDetail(con);
                   }
            }
        }
        
        if(!contactIdSet.isEmpty()){
            list<Contact> contactListToUpdate = new list<Contact>();
            list<Contact> contacts = [SELECT Id, Contact_Status__c, Do_Not_Contact__c, Email_Undeliverable__c, Constant_Soft_Bounce_Domain__c,
                                      Constant_Soft_Bounce_Contact__c, Email_Opted_In__c, Double_Opted_In__c,
                                      Global_Mailing_Country__c, High_Risk_Country__c, NonHotCountryCheck__c,
                                      Personal_Email_Address_Domain__c, Calculated_ACV__c, Inactive_in_Eloqua__c,
                                      Email_Group_Subscription__c, Output_Detail__c FROM Contact WHERE Id IN :contactIdSet];
            if(!contacts.isEmpty()){
                for(Contact con : contacts){
                    contactListToUpdate.add(populateOutputDetail(con));
                } 
            }
            if(!contactListToUpdate.isEmpty()){
                UPDATE contactListToUpdate;
            } 
        }
    }
    
    public static Contact populateOutputDetail(Contact con){
        System.debug('populateOutputDetail '+ con.High_Risk_Country__c);
        System.debug('populateOutputDetail '+ con.Global_Mailing_Country__c);
        System.debug('populateOutputDetail '+ con.Email_Opted_In__c);
        System.debug('populateOutputDetail '+ con.Inactive_in_Eloqua__c);
        if(con.Contact_Status__c == 'Deceased'){
            con.Output_Detail__c = 'This individual is marked as deceased.';
        }else if(con.Contact_Status__c == 'Retired'){
            con.Output_Detail__c = 'This individual is marked as retired.';
        }else if(con.Contact_Status__c == 'Left Institution'){
            con.Output_Detail__c = 'This individual has left the institution.';
        }else if(con.Do_Not_Contact__c == true){
            con.Output_Detail__c = 'This individual is flagged as Do Not Contact.';
        }else if(con.Email_Undeliverable__c == true){
            con.Output_Detail__c = 'This email address has hard bounced. Please check for errors or update contact status.';
        }else if(con.Constant_Soft_Bounce_Domain__c == true){
            con.Output_Detail__c = 'This email domain has constant soft bounces and is excluded from marketing emails.';
        }else if(con.Constant_Soft_Bounce_Contact__c == true){
            con.Output_Detail__c = 'This email address has constant soft bounces and is excluded from marketing emails.';
        }else if(con.Email_Opted_In__c == 'Yes'){
            con.Output_Detail__c = 'This individual has unsubscribed from marketing emails.';
        }else if(con.Double_Opted_In__c == 'No' && con.Global_Mailing_Country__c == 'GERMANY' && con.Email_Opted_In__c == null){
            con.Output_Detail__c = 'This individual has not subscribed to marketing emails (Germany).';
        }else if(con.Double_Opted_In__c == 'No' && con.Global_Mailing_Country__c == 'GERMANY' && con.Email_Opted_In__c == 'No'){
            con.Output_Detail__c = 'This individual has subscribed but has not completed double opt-in (Germany).';
        }else if(con.Email_Opted_In__c == null && con.High_Risk_Country__c == true){
            con.Output_Detail__c = 'This individual has not subscribed to marketing emails (high-risk country).';
        }else if(con.Email_Opted_In__c == null && con.NonHotCountryCheck__c == true && con.Personal_Email_Address_Domain__c == true){
            con.Output_Detail__c = 'This individual has not subscribed to marketing emails (personal email address).';
        }else if(con.Email_Opted_In__c == null && con.NonHotCountryCheck__c == true && con.Calculated_ACV__c == true){
            con.Output_Detail__c = 'This individual has not subscribed to marketing emails (medium-risk country).';
        }else if(con.Inactive_in_Eloqua__c == true){
            con.Output_Detail__c = 'This individual is inactive in Eloqua and will not receive marketing emails.';
        }else if(con.Email_Group_Subscription__c != null){
            con.Output_Detail__c = 'This individual has unsubscribed from '+ con.Email_Group_Subscription__c + '.';//{Email Group Name}
        }else{
            con.Output_Detail__c = '';
        }
        return con;
    }
*/
}
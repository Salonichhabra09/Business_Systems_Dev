/**************************************************************************************************************************************
CREATED BY :- RISHABH KANOTRA
CREATED DATE :- 10-06-2019
DESCRIPTION :- This class contains logic to update SFDC2Sun Transfer or Sync History fields,setting opportunity type if the Account business relationship changes,updating NumberOfContacts field on accounts, Updating the Shipping Address Accordingly on insert and refered from Account_Trigger triggers : after Update, after delete, after Undelete, before Insert
***************************************************************************************************************************************/ 

Global class AccountTriggerManager_2{
    
    //To update SFDC2Sun Transfer or Sync History fields
    /*public static void afterAccTransferHistory(List<Account> oldAccount, List<Account> newAccount, Map<id,Account> oldmap){ 
        
        
        List<SFDC2Sun_Transfer_or_Sync_History__c> sfdcTransferOrSyncHistList = new List<SFDC2Sun_Transfer_or_Sync_History__c>();
        Set<Decimal> sfdcVersionsSet = new Set<Decimal>();
        Set<Id> autoSyncedAccountIdsSet = new Set<Id>();
        
        if(UserInfo.getName() != 'Backoffice') {
            for(integer i = 0; i < newAccount.size();i++)
            {
                if( newAccount[i].SFDC2SUN_TransferStatus__c!=null && newAccount[i].SFDC2SUN_TransferStatus__c=='Transferred' && newAccount[i].SFDC2SUN_SyncStatus__c == oldAccount[i].SFDC2SUN_SyncStatus__c && (newAccount[i].OwnerId  != oldAccount[i].OwnerId || newAccount[i].BU__c  != oldAccount[i].BU__c || newAccount[i].CurrencyIsoCode  != oldAccount[i].CurrencyIsoCode || newAccount[i].Name  != oldAccount[i].Name || newAccount[i].Fax  != oldAccount[i].Fax || newAccount[i].Global_Parent_Account_Number__c  != oldAccount[i].Global_Parent_Account_Number__c || newAccount[i].Legacy_Account_Number__c  != oldAccount[i].Legacy_Account_Number__c || newAccount[i].Industry  != oldAccount[i].Industry || newAccount[i].Shipping_Address_Line_1__c  != oldAccount[i].Shipping_Address_Line_1__c || newAccount[i].Shipping_Address_Line_2__c  != oldAccount[i].Shipping_Address_Line_2__c || newAccount[i].Shipping_Address_Line_3__c  != oldAccount[i].Shipping_Address_Line_3__c || newAccount[i].Shipping_Address_Line_4__c  != oldAccount[i].Shipping_Address_Line_4__c || 
                                                                                                                                                                                                                  newAccount[i].Shipping_Country__c  != oldAccount[i].Shipping_Country__c || newAccount[i].Shipping_ZIP_Postal_Code__c  != oldAccount[i].Shipping_ZIP_Postal_Code__c || newAccount[i].Shipping_State_County__c  != oldAccount[i].Shipping_State_County__c || newAccount[i].Shipping_City__c  != oldAccount[i].Shipping_City__c || newAccount[i].Phone  != oldAccount[i].Phone || newAccount[i].Website  != oldAccount[i].Website || newAccount[i].Billing_Address_Line_1__c  != oldAccount[i].Billing_Address_Line_1__c || newAccount[i].Billing_Address_Line_2__c  != oldAccount[i].Billing_Address_Line_2__c || newAccount[i].Billing_Address_Line_3__c  != oldAccount[i].Billing_Address_Line_3__c || newAccount[i].Billing_Address_Line_4__c  != oldAccount[i].Billing_Address_Line_4__c || 
                                                                                                                                                                                                                  newAccount[i].Billing_Country__c  != oldAccount[i].Billing_Country__c || newAccount[i].Billing_ZIP_Postal_Code__c  != oldAccount[i].Billing_ZIP_Postal_Code__c || newAccount[i].Billing_State__c  != oldAccount[i].Billing_State__c || newAccount[i].Billing_City__c  != oldAccount[i].Billing_City__c || newAccount[i].VAT_Number__c  != oldAccount[i].VAT_Number__c || newAccount[i].PurchaseOrderRequired__c  != oldAccount[i].PurchaseOrderRequired__c || (newAccount[i].SFDC2SUN_Resync__c != oldAccount[i].SFDC2SUN_Resync__c && newAccount[i].SFDC2SUN_Resync__c ==true)))
                {
                    sfdcVersionsSet.add(newAccount[i].SFDC2SUN_SfdcVersion__c);
                    autoSyncedAccountIdsSet.add(newAccount[i].id);
                }
            }
            
            Map<Id,Account> accountsMap = new Map<Id,Account>([Select id , (Select id from SFDC2Sun_Transfer_Histories__r 
                                                                            where CreatedDate >:System.now().addSeconds(-1) and 
                                                                            Version__c in :sfdcVersionsSet) from Account where id in :autoSyncedAccountIdsSet]);
            for(integer i = 0; i < newAccount.size();i++)
            {
                
                if(newAccount[i].SFDC2SUN_TransferStatus__c!=null && newAccount[i].SFDC2SUN_TransferStatus__c=='Transferred' && newAccount[i].SFDC2SUN_SyncStatus__c == oldAccount[i].SFDC2SUN_SyncStatus__c && (newAccount[i].OwnerId  != oldAccount[i].OwnerId || newAccount[i].BU__c  != oldAccount[i].BU__c || newAccount[i].CurrencyIsoCode  != oldAccount[i].CurrencyIsoCode || newAccount[i].Name  != oldAccount[i].Name || newAccount[i].Fax  != oldAccount[i].Fax || newAccount[i].Global_Parent_Account_Number__c  != oldAccount[i].Global_Parent_Account_Number__c || newAccount[i].Legacy_Account_Number__c  != oldAccount[i].Legacy_Account_Number__c || newAccount[i].Industry  != oldAccount[i].Industry || newAccount[i].Shipping_Address_Line_1__c  != oldAccount[i].Shipping_Address_Line_1__c || newAccount[i].Shipping_Address_Line_2__c  != oldAccount[i].Shipping_Address_Line_2__c || newAccount[i].Shipping_Address_Line_3__c  != oldAccount[i].Shipping_Address_Line_3__c || newAccount[i].Shipping_Address_Line_4__c  != oldAccount[i].Shipping_Address_Line_4__c || 
                                                                                                                                                                                                                 newAccount[i].Shipping_Country__c  != oldAccount[i].Shipping_Country__c || newAccount[i].Shipping_ZIP_Postal_Code__c  != oldAccount[i].Shipping_ZIP_Postal_Code__c || newAccount[i].Shipping_State_County__c  != oldAccount[i].Shipping_State_County__c || newAccount[i].Shipping_City__c  != oldAccount[i].Shipping_City__c || newAccount[i].Phone  != oldAccount[i].Phone || newAccount[i].Website  != oldAccount[i].Website || newAccount[i].Billing_Address_Line_1__c  != oldAccount[i].Billing_Address_Line_1__c || newAccount[i].Billing_Address_Line_2__c  != oldAccount[i].Billing_Address_Line_2__c || newAccount[i].Billing_Address_Line_3__c  != oldAccount[i].Billing_Address_Line_3__c || newAccount[i].Billing_Address_Line_4__c  != oldAccount[i].Billing_Address_Line_4__c || 
                                                                                                                                                                                                                 newAccount[i].Billing_Country__c  != oldAccount[i].Billing_Country__c || newAccount[i].Billing_ZIP_Postal_Code__c  != oldAccount[i].Billing_ZIP_Postal_Code__c || newAccount[i].Billing_State__c  != oldAccount[i].Billing_State__c || newAccount[i].Billing_City__c  != oldAccount[i].Billing_City__c || newAccount[i].VAT_Number__c  != oldAccount[i].VAT_Number__c || newAccount[i].PurchaseOrderRequired__c  != oldAccount[i].PurchaseOrderRequired__c || (newAccount[i].SFDC2SUN_Resync__c != oldAccount[i].SFDC2SUN_Resync__c && newAccount[i].SFDC2SUN_Resync__c ==true)))
                {
                    
                    
                    
                    if(accountsMap!=null && accountsMap.get(newAccount[i].id)!=null && accountsMap.get(newAccount[i].id).SFDC2Sun_Transfer_Histories__r.size()==0)
                    {
                        SFDC2Sun_Transfer_or_Sync_History__c sfdcAccountTransferSyncHist = new SFDC2Sun_Transfer_or_Sync_History__c();
                        if(newAccount[i].SFDC2SUN_SfdcVersion__c==null) // Added By Priyank for story SSE-10185
                            newAccount[i].SFDC2SUN_SfdcVersion__c=0;
                        else
                            sfdcAccountTransferSyncHist.Version__c = newAccount[i].SFDC2SUN_SfdcVersion__c+1;
                        sfdcAccountTransferSyncHist.Start_Date__c = System.now();
                        sfdcAccountTransferSyncHist.Account__c = newAccount[i].id;
                        sfdcAccountTransferSyncHist.User__c =  UserInfo.getUserId();
                        
                        if(newAccount[i].SFDC2SUN_Resync__c ==false)
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
                upsert sfdcTransferOrSyncHistList;
            
        }//BackOfficeIf
        
        // No longer needed as per SSE-12598
        //Added by Anjali for SSE-2721 on 23-03-2017
        /*Map<Id, String> accIdandTradingStatus = new Map<Id, String>();

Set<String> accTrStatusSet = Utility.getAccountTradingStatus();
Set<String> opptyTypeSet = Utility.getOpptyType();
String opptyTypeNL = Utility.getOpptyTypeNBBNL();
String opptyTypeCS = Utility.getOpptyTypeNBBCS();
List<Opportunity> opptyUpdateList = new List<Opportunity>();

for(Account acc : newAccount) {
if(acc.Business_Relationship__c != oldmap.get(acc.id).Business_Relationship__c) {
accIdandTradingStatus.put(acc.Id,acc.Business_Relationship__c);  
}        
}

integer dd = system.Today().year();


for(Opportunity opp : [select Id,Name,CloseDate,StageName ,AccountId, Business_Type__c from Opportunity where AccountId IN: accIdandTradingStatus.keyset() AND Business_Type__c NOT IN: opptyTypeSet AND StageName != 'Closed Lost' AND AM_Opportunity__c=false]) {


if(opp.StageName != 'Closed/Won' || (opp.StageName == 'Closed/Won' && opp.CloseDate.Year() == dd)) { 

if(accIdandTradingStatus != null && accIdandTradingStatus.containskey(opp.AccountId)) {


if((accTrStatusSet != null && accTrStatusSet.contains(accIdandTradingStatus.get(opp.AccountId)) || accIdandTradingStatus.get(opp.AccountId) == null)) {                   
opp.Business_Type__c = opptyTypeNL ;
}               
else {
opp.Business_Type__c = opptyTypeCS ;
}

opptyUpdateList.add(opp);
}
}
}
if(opptyUpdateList.size()>0)
database.update(opptyUpdateList,false);

    
    }//afterAccTransferHistory  
*/
    
    //This method runs when two accounts are being merged & to update NumberOfContacts field on accounts
    public static void afterAccDelete(List<Account> oldAccount){ 
        
        Set<Id> accountIds = new Set<Id>();
        
        List<Accounts_Merged__e> mergedAcctList = new List<Accounts_Merged__e>();//Merge POC 
        for(Account acc: oldAccount){
            
            //checking MasterRecordId because of merge operation on account.
            if(acc.MasterRecordId!=null){            
                accountIds.add(acc.MasterRecordId);
                Accounts_Merged__e mergeAcct = new Accounts_Merged__e();
                mergeAcct.Merged_Account__c = acc.MasterRecordId;
                mergedAcctList.add(mergeAcct);
            }
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
        
        
        //Calling below future method to update NumberOfContacts field on accounts whose ids we are passing to the method.
        Account_Manager.updateNumberOfContacts(accountIds);
        
    }//afterAccDelete
    
    //To update NumberOfContacts field on accounts on Undelete.
    public static void afterAccUndelete(List<Account> newAccount){ 
        
        Set<Id> accountIds = new Set<Id>();
        
        for(Account acc: newAccount){
            
            accountIds.add(acc.id);
        }
        
        //Calling below future method to update NumberOfContacts field on accounts whose ids we are passing to the method.
        Account_Manager.updateNumberOfContacts(accountIds);
        
    }//afterAccUndelete
    
    //This method updates Shipping Address on Acccount depending on the 'Same as billing Adress' checkbox.
    public static void beforeAccInsert(List<Account> newAccount){ 
        
        for(Integer i=0; i< newAccount.size();i++){
            
            //check for the  Same as billing Adress checkbox field and Updates copies the Shipping Address Accordingly & updates Old_Record_Type__c on Account.
            if(newAccount[i].Same_As_The_Billing_Address__c)
            {
                newAccount[i].Shipping_Address_Line_1__c=newAccount[i].Billing_Address_Line_1__c;
                newAccount[i].Shipping_Address_Line_2__c=newAccount[i].Billing_Address_Line_2__c;
                newAccount[i].Shipping_Address_Line_3__c=newAccount[i].Billing_Address_Line_3__c;
                newAccount[i].Shipping_Address_Line_4__c=newAccount[i].Billing_Address_Line_4__c;
                newAccount[i].Shipping_City__c=newAccount[i].Billing_City__c;
                newAccount[i].Global_Shipping_Country__c=newAccount[i].Global_Billing_Country__c;
                newAccount[i].Shipping_Country__c=newAccount[i].Global_Billing_Country__c;
                newAccount[i].Shipping_State_County__c=newAccount[i].Billing_State__c;
                newAccount[i].Shipping_ZIP_Postal_Code__c=newAccount[i].Billing_ZIP_Postal_Code__c;
            }
            
            
        }
        
        /** Changes Start by Apoorva Gautam ---- User Story-113-------**/
        for(Account acc:newAccount)
        {
            
            if(acc.Status__c!='Approved'|| acc.Status__c!='Archived') 
            {
                acc.Old_Record_Type__c=acc.RecordtypeId;
            }  
            
        }
        
        /** Changes End by Apoorva Gautam ---- User Story-113-------**/
        
    }//beforeAccInsert 
    
    //Change starts for SSE-16905 - Prachi
    public static void mapGlobalCountryFields(List<Account> newAccount,Map<Id,Account> oldAccountMap,
                                              Map<Id,Account> newAccountMap){
                                                  for(Account acc : newAccount){
                                                      try{
                                                          if(oldAccountMap == Null || (oldAccountMap != Null && 
                                                                                       acc.Global_Billing_Country__c!= 
                                                                                       oldAccountMap.get(acc.Id).Global_Billing_Country__c)){
                                                                                           system.debug('test'+acc.Global_Billing_Country__c);
                                                                                           acc.Billing_Country__c = acc.Global_Billing_Country__c;
                                                                                       }
                                                          
                                                          if(oldAccountMap == Null || (oldAccountMap != Null && 
                                                                                       acc.Global_Shipping_Country__c  != 
                                                                                       oldAccountMap.get(acc.Id).Global_Shipping_Country__c) ){
                                                                                           system.debug('test'+acc.Global_Shipping_Country__c);
                                                                                           acc.Shipping_Country__c = acc.Global_Shipping_Country__c;
                                                                                       }
                                                      }catch(DmlException ex){
                                                          Account actualRecord = newAccountMap.get(acc.Id); 
                                                          actualRecord.addError('We get the following error : ' +
                                                                                ex.getDmlMessage(0));
                                                      }}
                                                  
                                              }
    //Changes ends SSE-16905
    
    public static void setGCSCAccountOwner(List<Account> newAccount,Map<Id,Account>oldAccountMap){ 
        Map<String,BU_to_GCSC_Owner_Mapping__mdt> buOwnerMap = new Map<String,BU_to_GCSC_Owner_Mapping__mdt>();
        
        List<BU_to_GCSC_Owner_Mapping__mdt> countryMetaRecordList = [SELECT Id, BU__c,GCSC_Account_Owner__c 
                                                                     FROM BU_to_GCSC_Owner_Mapping__mdt];
        
        for(BU_to_GCSC_Owner_Mapping__mdt buOwnerRec : countryMetaRecordList){
            buOwnerMap.put(buOwnerRec.BU__c,buOwnerRec);
        }
        
        for(Account accRec : newAccount){
            if(accRec.BU__c != Null && accRec.GCSC_Owned_Account__c == True && buOwnerMap.containsKey(accRec.BU__c) &&
               (oldAccountMap == Null || 
                (oldAccountMap != Null && (accRec.GCSC_Owned_Account__c != oldAccountMap.get(accRec.Id).GCSC_Owned_Account__c || 
                                           accRec.BU__c != oldAccountMap.get(accRec.Id).BU__c)))
              ){
                  accRec.GCSC_Account_Owner__c = buOwnerMap.get(accRec.BU__c).GCSC_Account_Owner__c;
              }
            
        }
    }
    
    //Changes Start SSE-21598 Prachi
    //This method is used to update number of Account Plan field on account when an account is created and have buying center id
    
    public static void updateNumberOfAP(List<Account> newAccount,Map<Id,Account> oldAccountMap){
        if(!newAccount.isEmpty()){
            Set<id> accountId = new Set<id>();
            Set<String> buyingCentreId = new Set<String>();
            
            
            for(Account acc: newAccount){
                system.debug('oldAccountMap' + oldAccountMap );
                if(oldAccountMap == null){
                    if(acc.Buying_Centre_Id__c != '' && acc.Buying_Centre_Id__c != null){
                        
                        buyingCentreId.add(acc.Buying_Centre_Id__c);
                    }
                }
                else{
                    
                    if(acc.Buying_Centre_Id__c != '' && acc.Buying_Centre_Id__c != null && 
                       oldAccountMap.get(acc.id).Buying_Centre_Id__c != acc.Buying_Centre_Id__c ){
                           if(acc.Number_of_Account_Plan__c == null  || acc.Number_of_Account_Plan__c == 0){
                               acc.Number_of_Account_Plan__c = 0;
                           }
                           else{
                               if(acc.Number_of_Account_Plan__c == 1){
                                   accountId.add(acc.id);
                               }
                               
                               acc.Number_of_Account_Plan__c = acc.Number_of_Account_Plan__c - 1;
                           }
                           
                           buyingCentreId.add(acc.Buying_Centre_Id__c);
                           
                       } 
                    else if((acc.Buying_Centre_Id__c == '' || acc.Buying_Centre_Id__c == null) && 
                            oldAccountMap.get(acc.id).Buying_Centre_Id__c != acc.Buying_Centre_Id__c){
                                if(acc.Number_of_Account_Plan__c == null  || acc.Number_of_Account_Plan__c == 0){
                                    acc.Number_of_Account_Plan__c = 0;
                                }
                                else{
                                    acc.Number_of_Account_Plan__c = acc.Number_of_Account_Plan__c - 1;
                                }
                                
                                
                            }
                    
                }
                
            }    
            if(!buyingCentreId.isEmpty()){
                List<Account_Plan__c> apList = [Select id, Account_Name__c ,Buying_Centre_Id__c ,Account_Plan_type__c
                                                from Account_Plan__c 
                                                where Buying_Centre_Id__c in :buyingCentreId or 
                                                Account_Name__c in :accountId ];
                if(!apList.isEmpty()){
                    for(Account_Plan__c ap:apList){
                        for(Account acc: newAccount){
                            if((ap.Account_Plan_type__c == 'Current' || ap.Account_Plan_type__c == 'Global') && 
                               ap.Buying_Centre_Id__c == null  && acc.id == ap.Account_Name__c){
                                   if(acc.Number_of_Account_Plan__c == null ||acc.Number_of_Account_Plan__c == 0 ){
                                       acc.Number_of_Account_Plan__c = 1;
                                   }
                                   else{
                                       acc.Number_of_Account_Plan__c += 1;
                                   } 
                               }
                            if(acc.Buying_Centre_Id__c == ap.Buying_Centre_Id__c){
                                if(acc.Number_of_Account_Plan__c == null ||acc.Number_of_Account_Plan__c == 0 ){
                                    acc.Number_of_Account_Plan__c = 1;
                                }
                                else{
                                    acc.Number_of_Account_Plan__c += 1;
                                }
                                
                            }
                        }
                    }
                }
            }
        }  
    }
    
    public static void sendSuccessEmailTCPlus(Map<Id,Account> newAccountMap,Map<Id,Account> oldAccountMap){

        //ist<Account> tcPlusUpgradedList  = new List<Account>();
        List<Id> tcPlusUpgradedList  = new List<Id>();
        for (Account acc : newAccountMap.Values()) {
            if(acc.Total_TC_Upgrade_records__c == acc.Fully_Upgraded_TC_Upgrade_records__c && oldAccountMap.get(acc.Id).Total_TC_Upgrade_records__c!=oldAccountMap.get(acc.Id).Fully_Upgraded_TC_Upgrade_records__c){
                tcPlusUpgradedList.add(acc.Id);
            }
        }

        if(tcPlusUpgradedList.size()>0){
            system.debug('inside tc');
            Map<Id,List<Talent_Central__c>> accountToTcRecords = new Map<Id,List<Talent_Central__c>>();
            List<Talent_Central__c> tcRecords = [SELECT Id,Account__c,Account__r.Owner.Name,Phase__c,Operations_Recipient__c FROM Talent_Central__c WHERE Account__c IN :tcPlusUpgradedList ];

            for (Talent_Central__c tc : tcRecords) {
                if(accountToTcRecords.get(tc.Account__c)!=null){
                    accountToTcRecords.get(tc.Account__c).add(tc);
                }else{
                    accountToTcRecords.put(tc.Account__c,new List<Talent_Central__c>{tc});
                }
            }
        //User accManager = [SELECT Name FROM User where Id= :newAccountMap.get(accId).OwnerId];
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Account> accountListToUpdate = new List<Account>();
            for (Id accId : accountToTcRecords.keySet()) {
                Account acc = new Account();
                acc.Id = accId;
                accountListToUpdate.add(acc);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> toaddresses = new List<String>(); 
                String tcRecordsId = '';
                String accManager ;
                mail.setTargetObjectId(newAccountMap.get(accId).OwnerId);
                for (Talent_Central__c tc : accountToTcRecords.get(accId)) {
                    if(tc.Operations_Recipient__c!=null){
                     	toaddresses.add(tc.Operations_Recipient__c);   
                    }
                    tcRecordsId += tc.Phase__c + '<br/>';
                    accManager = tc.Account__r.Owner.Name;
                }
                if(toaddresses.size()>0){
                    mail.setToAddresses(toaddresses);
                }
                
                String accLink = '<a href="'+ URL.getOrgDomainURL().toExternalForm()+'/'+accId +'">here.</a>';
                String subject = 'Your account "'+newAccountMap.get(accId).Name+'" has been successfully migrated from TC to TC+';
                mail.setSubject(subject);
                mail.setHtmlBody('Hi '+ accManager+' , <br/><br/>This is to inform that the account '+newAccountMap.get(accId).Name +' has been successfully migrated from TC to TC+.  Below are the site details of your account: <br/><br/>'+tcRecordsId+'For further information regarding the migration, click '+accLink);
                OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: 'tcupgradeinternal@shl.com' Limit 1];
                mail.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
                mailList.add(mail);
                mail.saveAsActivity = false;
            }
             Messaging.SendEmailResult[] result= Messaging.sendEmail(mailList);
             if(result.size()>0){
                 for(Account acc:accountListToUpdate){
                     acc.Last_TC_migration_mail_sent_date__c = System.now();
                 }
                 update accountListToUpdate;
             }

        }
    }
    
    // Used for validation for Account Merging (SSE-27814 - Moved the method from Account_BeforeDelete_cls)
    Public Static Void UserValidationForAccountMergeOrDelete(List<Account> accountList){
        List<AccountMergingPermission__c> accountMergeCustomSettingList = [SELECT  UserEmail__c FROM AccountMergingPermission__c]; //SSE-12824 -->
        Set<String> userEmailsWithMergingPermission = new Set<String>();  
        
        String outsideOfIndiaGstHoldAccountId =Field_Value_Setting__c.getvalues('Account Record').Value__c;
        String currentUserEmail=UserInfo.getUserEmail();
        String profileName =[SELECT Name from Profile where Id=:UserInfo.getProfileId()].Name;
        
        for(AccountMergingPermission__c customSetting : accountMergeCustomSettingList){
            userEmailsWithMergingPermission.add(customSetting.UserEmail__c);
        }
        if(!userEmailsWithMergingPermission.contains(currentUserEmail)) {  //<--SSE-12824
            for(Account account:accountList)
            {
                if(profileName!='System Administrator' && profileName!='Bullseye Project (Commercial)' && account.status__c=='Approved'){
                    account.addError('Only users with certain profiles can delete accounts with a status of Approved. Please contact the Gatekeeper.');
                }
                
                if(account.Id==outsideOfIndiaGstHoldAccountId){
                    account.addError('This account record cannot be deleted as it is being used to hold an \'Outside Of India\' GST record used on Invoice Headers');
                }
            }
        }
    }
    
}
//TriggerEnd
public without sharing class Account_Contacts_Hierarchy {
    
    @AuraEnabled
    public static ContactHierarchyWrapper getContactHierarchyDetails(String accId, String accPlanId ){
        ContactHierarchyWrapper wrapperToReturn = new ContactHierarchyWrapper();
        try {
            wrapperToReturn = getContacts(accId,accPlanId);
            Account_Plan__c accplan = [select id , Account_Name__c,Account_Name__r.Name,Account_Name__r.Account_Number__c,Account_Plan_Status__c , Account_Name__r.CurrencyIsoCode,Account_Plan_Type__c,Buying_Centre_Id__c
                                       from Account_Plan__c where id=:accPlanId];
            List<Contact> allContactsList = new List<Contact>();
            List<PicklistWrapper> dNumberList = new List<PicklistWrapper>();
            if(accplan.Account_Plan_Type__c=='Regional'){
                wrapperToReturn.isRegionalOrGlobal = true;
                List<Id> accIds = new List<Id>();
                List<Account> accList = [SELECT Id,Account_Number__c,Name FROM Account WHERE Buying_Centre_Id__c= :accplan.Buying_Centre_Id__c];
                for (Account acc : accList) {
                    PicklistWrapper pick = new PicklistWrapper();
                    pick.label = acc.Name+' ('+acc.Account_Number__c+')';
                    pick.value = acc.Id;
                    accIds.add(acc.Id);
                    dNumberList.add(pick);
                }
                allContactsList = [SELECT Id,Name FROM Contact WHERE AccountId IN :accIds];
                wrapperToReturn.dNumberList = dNumberList;
            }else if(accplan.Account_Plan_Type__c=='Global'){
                wrapperToReturn.isRegionalOrGlobal = true;
                Set<Id> allAccountIds = new Set<Id>{accplan.Account_Name__c};
                    Set<Id> parentIds = new Set<Id>{accplan.Account_Name__c};
                        List<Account> childAccounts = new List<Account>();
                PicklistWrapper pickParent = new PicklistWrapper();
                pickParent.label = accplan.Account_Name__r.Name+' ('+accplan.Account_Name__r.Account_Number__c+')';
                pickParent.value = accplan.Account_Name__c;
                dNumberList.add(pickParent);
                do {
                    childAccounts = [SELECT Id,Name,Account_Number__c FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                    parentIds.clear();
                    for (Account child : childAccounts){
                        parentIds.add(child.Id);
                        PicklistWrapper pick = new PicklistWrapper();
                        pick.label = child.Name+' ('+child.Account_Number__c+')';
                        pick.value = child.Id;
                        allAccountIds.add(child.Id);
                        dNumberList.add(pick);
                    }
                } while (childAccounts.size() > 0);
                allContactsList = [SELECT Id,Name FROM Contact WHERE AccountId IN :allAccountIds];
                wrapperToReturn.dNumberList = dNumberList;
            }else if(accplan.Account_Plan_Type__c=='Current'){
                wrapperToReturn.isRegionalOrGlobal = false;
                allContactsList = [SELECT Id,Name FROM Contact WHERE AccountId= :accId];
            }
            wrapperToReturn.allContactsList = allContactsList;
            return wrapperToReturn;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
* Retrieves a list of contact records along with related information for a given Account Id and Account Plan Id.
* The method performs several queries to fetch contacts, related opportunities, and other data.
* It populates a list of wrapper objects containing the contact information and returns it.
*
* @param accId      The Account Id to retrieve contacts for.
* @param accPlanId  The Account Plan Id to filter strategies and account contact relations.
* @return A list of wrapContact objects containing the contact information and related data.
*/
    @AuraEnabled
    public static ContactHierarchyWrapper  getContacts(String accId, String accPlanId){
        
        ContactHierarchyWrapper wrapperToReturn = new ContactHierarchyWrapper();
        
        // Query contacts for the specified Account Id
        List<Contact> conList = [
            SELECT Id, AccountId, Account.Name, Name, Phone, Email, Title, ReportsToId, ReportsTo.Name,
            PhotoUrl, LastModifiedDate, LastActivityDate, Global_Mailing_Country__c, Job_Function__c,
            Job_Level__c, Job_Role__c,Area_of_Interest__c, Last_Activity_Happen__c, Contact_Status__c,is_Root_Level_Contact__c
            FROM Contact 
            WHERE AccountId =: accId
        ];
        
        // Query the last created Account Plan for the specified Account Id and Account Plan Id
        List<Account_Plan__c> lastCreatedAccountPlan = [
            SELECT Id, Who_did_we_last_meet_in_the_organisation__c, Subject_discussed_actions_agreed__c
            FROM Account_Plan__c
            WHERE Account_Name__c =:accId AND Id =:accPlanId
        ];
        
        List<Contact> lastContacted = [select id, Last_Activity_Happen__c,Subject_Discussed__c from contact
                                     where AccountId = :accId and Last_Activity_Happen__c != null
                                     order by Last_Activity_Happen__c desc limit 1];
        
        List<wrapContact> contactsList = new List<wrapContact>();
        
        //Changes by Jai
        Boolean reportsToPresent = false;
        List<Id> withReportsTo = new List<Id>();
        List<Id> withoutReportsTo = new List<Id>();
        List<Id> finalContactListIds = new List<Id>();
        List<Contact> finalContactList = new List<Contact>();
        List<Id> allReportsTo = new List<Id>();
        List<Id> contactsFromDiffAccount = new List<Id>();
        List<Id> allContactIds = new List<Id>();
        
        for (Contact con : conList) {
            allContactIds.add(con.Id);
            if(con.ReportsToId!=null||con.is_Root_Level_Contact__c==true){
                finalContactListIds.add(con.Id);
                if(con.ReportsToId!=null){
                    withReportsTo.add(con.ReportsToId);
                }
            }else{
                withoutReportsTo.add(con.Id);
            }
        }
        
        for (Id id : withReportsTo) {
            if(!allContactIds.contains(id)){
                contactsFromDiffAccount.add(id);
            }
        }
        
        System.debug('con '+contactsFromDiffAccount);
        
        List<Contact> conFromDiffAccountList = [
            SELECT Id, AccountId, Account.Name, Name, Phone, Email, Title, ReportsToId, ReportsTo.Name,
            PhotoUrl, LastModifiedDate, LastActivityDate, Global_Mailing_Country__c, Job_Function__c,
            Job_Level__c, Job_Role__c,Area_of_Interest__c, Last_Activity_Happen__c, Contact_Status__c,is_Root_Level_Contact__c
            FROM Contact 
            WHERE Id IN :contactsFromDiffAccount
        ];
        
        for (Id id : withoutReportsTo) {
            if(withReportsTo.contains(id)){
                finalContactListIds.add(id);
            }
        }
        
        for (Contact con : conList) {
            if(finalContactListIds.contains(con.Id)){
                finalContactList.add(con);
            }
        }
        
        for (Contact con : conFromDiffAccountList) {
            finalContactList.add(con);
        }
        
        if(!finalContactList.isEmpty()){
            
            //START Changes related to SSE-20719
            // Map to store contact Id and opportunity count
            Map<Id, Integer> contactOpportunityCountMap = new Map<Id, Integer>();
            for (Contact con : finalContactList) {
                contactOpportunityCountMap.put(con.Id, 0);
            }
            
            // Query opportunities and related contact roles for the specified Account Id
            List<Opportunity> opportunityList = [
                SELECT Id, AccountId, ( SELECT Role, Contact.Name, Contact.Account.Name, Contact.Account.Id  
                                       FROM OpportunityContactRoles
                                       WHERE ContactId IN :finalContactList) 
                FROM Opportunity
                WHERE Id IN (SELECT OpportunityId 
                             FROM OpportunityContactRole 
                             WHERE ContactId IN :finalContactList) 
                //AND AccountId =: accId
                AND StageName NOT IN ('Closed/Won','Closed Lost')
            ];
            
            // Update opportunity count for each contact in the map
            for (Opportunity opp : opportunityList) {
                for (OpportunityContactRole ocr : opp.OpportunityContactRoles) {
                    if (contactOpportunityCountMap.containsKey(ocr.Contact.Id)) {
                        Integer count = contactOpportunityCountMap.get(ocr.Contact.Id);
                        count++;
                        contactOpportunityCountMap.put(ocr.Contact.Id, count);
                    }
                }
            }
            
            
            /*Map<Id, Integer> contactStrategyCountMap = new Map<Id, Integer>();

List< Strategy_and_Goal__c> strategyList = [
SELECT Id, Name,Strategy_Name__c ,Account_Contact_Relations__c
FROM Strategy_and_Goal__c 
WHERE Account_Plan__c =:accPlanId];

// Build a Map of Strategy name to Strategy Id for easy reference
Map<String, Id> strategyNameToIdMap = new Map<String, Id>();

for(Strategy_and_Goal__c strategy : strategyList) {
strategyNameToIdMap.put(strategy.Name, strategy.Id);
}


// Query for the related Account Contact Relations and count Strategies
List<AccountContactRelation> acrs = [    
SELECT Id, ContactId, Strategies__c    
FROM AccountContactRelation    
WHERE AccountId = :accId 
AND ContactId IN :conList];

// Count Strategies for each Contact
for(AccountContactRelation acr : acrs) {
Integer strategyCount = 0;
if(acr.Strategies__c != null){
String[] strategies = acr.Strategies__c.split(';');
for(String strategy : strategies) {
if(strategyNameToIdMap.containsKey(strategy.trim())) {
strategyCount++;
}
}
contactStrategyCountMap.put(acr.ContactId, strategyCount);                    
}

}*/
            
            // Map to store AccountContactRelation Id and associated strategy Ids
            Map<Id, List<Id>> accountContactRelationToStrategyMap = new Map<Id, List<Id>>();
            
            // Query strategies associated with the specified Account Plan Id
            List< Strategy_and_Goal__c> strategies = [
                SELECT Id, Name,Strategy_Name__c ,Account_Contact_Relations__c, InActive__c
                FROM Strategy_and_Goal__c 
                WHERE Account_Plan__c =:accPlanId
                AND InActive__c = false
            ];
            
            // Populate the accountContactRelationToStrategyMap with AccountContactRelation Ids and strategy Ids
            for (Strategy_and_Goal__c strategy : strategies) {
                String accountContactRelations = strategy.Account_Contact_Relations__c;
                // Check if accountContactRelations is not empty
                if (!String.isEmpty(accountContactRelations)) {
                    // Split accountContactRelations into individual relation Ids
                    List<String> accountContactRelationIds = accountContactRelations.split(';');
                    // Iterate over each accountContactRelationId
                    for (String accountContactRelationId : accountContactRelationIds) {
                        accountContactRelationId = accountContactRelationId.trim();
                        // Check if accountContactRelationId is not empty
                        if (!String.isEmpty(accountContactRelationId)) {
                            // Convert accountContactRelationId to Id type
                            Id acrId = (Id) accountContactRelationId;
                            // Check if acrId is not already in the map, initialize with an empty list
                            if (!accountContactRelationToStrategyMap.containsKey(acrId)) {
                                accountContactRelationToStrategyMap.put(acrId, new List<Id>());
                            }
                            // Add the strategy Id to the list associated with the acrId in the map
                            accountContactRelationToStrategyMap.get(acrId).add(strategy.Id);
                        }
                    }
                }
            }
            
            system.debug(accountContactRelationToStrategyMap);
            
            // Retrieve AccountContactRelation records related to the specified account and contacts list
            List<AccountContactRelation> acrs = [    
                SELECT Id, ContactId, Strategies__c    
                FROM AccountContactRelation    
                //WHERE AccountId = :accId 
                WHERE ContactId IN :finalContactList
            ];
            
            System.debug(acrs);
            // Create a map to store the contact Id and the count of associated strategies
            Map<Id, Integer> conIdToStratCountMap = new Map<Id, Integer>();
            Map<Id,List<Id>> conIdToStratMap = new Map<Id,List<Id>>();
            // Iterate over the AccountContactRelation records
            for (AccountContactRelation acr : acrs) {
                // Check if the AccountContactRelation Id is present in the accountContactRelationToStrategyMap
                if(accountContactRelationToStrategyMap.get(acr.Id) != null){
                    // Get the size of the strategy list associated with the AccountContactRelation Id and store it in the map
                    if(conIdToStratCountMap.get(acr.ContactId)==null){
                        conIdToStratCountMap.put(acr.ContactId, accountContactRelationToStrategyMap.get(acr.Id).size());
                        conIdToStratMap.put(acr.ContactId,accountContactRelationToStrategyMap.get(acr.Id));
                    }else{
                        List<Id> stratId = conIdToStratMap.get(acr.ContactId);
                        stratId.addAll(accountContactRelationToStrategyMap.get(acr.Id));
                        Set<Id> uniqStratId = new Set<Id>(stratId);
                        conIdToStratCountMap.put(acr.ContactId, uniqStratId.size());
                        conIdToStratMap.put(acr.ContactId,new List<Id>(uniqStratId));
                    }
                }
            }
            system.debug('map '+conIdToStratCountMap);
            //END Changes related to SSE-SSE-20719
            
            // Iterate over the Contact list
            for (Contact con : finalContactList) {
                // Create a new instance of wrapContact
                wrapContact conWrap = new wrapContact();
                // Assign values from the Contact record to the wrapContact instance
                conWrap.Id = con.Id;
                conWrap.AccountId = con.AccountId;
                conWrap.AccountName = con.Account.Name;
                conWrap.Name = con.Name;
                conWrap.Phone = con.Phone;
                conWrap.Email = con.Email;
                conWrap.Title = con.Title;
                conWrap.ReportsToId = con.ReportsToId;
                conWrap.ReportsToName = con.ReportsTo.Name;
                conWrap.PhotoUrl = con.PhotoUrl;
                conWrap.LastModifiedDate = con.LastModifiedDate;
                conWrap.LastActivityDate = con.Last_Activity_Happen__c;
                conWrap.JobFunction = con.Job_Function__c;
                conWrap.JobLevel = con.Job_Level__c;
                conWrap.JobRole = con.Job_Role__c;
                conWrap.AreaInterest= con.Area_of_Interest__c;
                conWrap.isRootLevel = con.is_Root_Level_Contact__c;//Change added by Prachi SSE-21273
                
                // Set IsActive flag based on the Contact's Contact_Status__c field
                if(con.Contact_Status__c == 'Active'){
                    conWrap.IsActive = true;
                } else {
                    conWrap.IsActive = false;
                }
                
                //Changes by Jai 
                if(conWrap.ReportsToId!=null){
                    reportsToPresent = true;
                }
                
                // Set IsLastContacted flag based on the lastCreatedAccountPlan and Who_did_we_last_meet_in_the_organisation__c field
                /*if( !lastCreatedAccountPlan.isEmpty() &&
                   lastCreatedAccountPlan[0].Who_did_we_last_meet_in_the_organisation__c != null &&
                   lastCreatedAccountPlan[0].Who_did_we_last_meet_in_the_organisation__c ==  con.Id){
                       conWrap.IsLastContacted = true;
                   } else {
                       conWrap.IsLastContacted = false;
                   }*/
                
                if( !lastContacted.isEmpty() &&
                   lastContacted[0].Id ==  con.Id){
                       conWrap.IsLastContacted = true;
                   } else {
                       conWrap.IsLastContacted = false;
                   }
                
                // Set SubjectDiscussed field based on the lastCreatedAccountPlan Subject_discussed_actions_agreed__c field
                /*if( !lastCreatedAccountPlan.isEmpty()){
                    conWrap.SubjectDiscussed = lastCreatedAccountPlan[0].Subject_discussed_actions_agreed__c;
                }*/
                
                if( !lastContacted.isEmpty()){
                    conWrap.SubjectDiscussed = lastContacted[0].Subject_Discussed__c;
                }
                //Integer intDays =  (con.LastActivityDate).daysBetween(NOW());
                
                // Calculate the LastActivityInterval in months if Last_Activity_Happen__c is not null
                if(con.Last_Activity_Happen__c != null){
                    Date lastActivityDate_Date = date.newinstance((con.Last_Activity_Happen__c).year(), (con.Last_Activity_Happen__c).month(), (con.Last_Activity_Happen__c).day());
                    Date today_Date = date.newinstance((System.now()).year(), (System.now()).month(), (System.now()).day());
                    Integer intMonths = today_Date.monthsBetween(today_Date);       
                    conWrap.LastActivityInterval = intMonths;                    
                } else {
                    conWrap.LastActivityInterval = null;
                }
                //START Changes related to SSE-20719
                // Retrieve the opportunity count for the contact and assign it to CountOpportunities
                Integer oppCount = 0;
                if(contactOpportunityCountMap.get(con.Id) != null){
                    oppCount = contactOpportunityCountMap.get(con.Id);
                }
                conWrap.CountOpportunities = oppCount;
                
                // Retrieve the strategy count for the contact and assign it to CountStrategies
                Integer stratCount = 0;
                if(conIdToStratCountMap.get(con.Id) != null){
                    stratCount = conIdToStratCountMap.get(con.Id);
                }
                conWrap.CountStrategies = stratCount;
                //END Changes related to SSE-20719
                if(conWrap.ReportsToId==null || (contactsFromDiffAccount.contains(con.Id) && !finalContactListIds.contains(conWrap.ReportsToId))){
                    conWrap.ReportsToId = 'rootlevel';
                }
                // Add the wrapContact instance to the contactsList
                if(contactsFromDiffAccount.contains(con.Id)){
                    conWrap.isFromDiffAccount = true;
                    conWrap.diffAccountId = accId;
                }
            
                contactsList.add(conWrap);
            }     
        }else{
            wrapperToReturn.message = 'No contact Hierarchy to show. Create Contact/ Hierarchy from here. Click + to create contact or build hierarchy.';
        }
        if(conList.size()==0){
            wrapperToReturn.message = 'No contact Hierarchy to show. Create Contact/ Hierarchy from here. Click + to create contact or build hierarchy.';
        }
        
        List<Account> account = [Select Id,Name from Account where Id=:accId];
        wrapContact conWrap = new wrapContact();
        // Assign values from the Contact record to the wrapContact instance
        conWrap.Id = 'rootlevel';
        conWrap.AccountId = account[0].Id;
        conWrap.AccountName = account[0].Name;
        contactsList.add(conWrap);
        
        
        wrapperToReturn.contactsList = contactsList;
        return wrapperToReturn;
    }
    
    
    /**
* Checks if a contact has any child contacts associated with the given Account Id and Contact Id.
* It queries the Contact object to find contacts that have the specified Account Id as their parent account
* and the specified Contact Id as their Reports To contact. The method returns the count of child contacts.
*
* @param accId The Account Id to check for child contacts.
* @param conId The Contact Id to check as the Reports To contact.
* @return The count of child contacts.
*/
    @AuraEnabled
    public static integer hasChildren( String accId, String conId,List<Contact> allContactsList){      
        // Query contacts with the specified Account Id as their parent account and the specified Contact Id as their Reports To contact 
        //List<Contact> conChildrenList= [SELECT Id FROM Contact WHERE AccountId =: accId AND ReportsToId =: conId] ;
        List<Contact> conChildrenList= [SELECT Id FROM Contact WHERE ReportsToId =: conId] ;
        List<Id> conIdsToCheck = new List<Id>();
        if(allContactsList.size()>0){
            for (Contact con : allContactsList) {
                conIdsToCheck.add(con.Id);
            }
        }
        
        // Get the count of child contacts
        Integer count = 0;
        if(conChildrenList.size()>0){
            for (Contact con : conChildrenList) {
                if(conIdsToCheck.contains(con.Id)){
                    count++;
                    system.debug(con.Id);
                }
            }
        }
        system.debug(conId);
        system.debug(count);
        // Return the count of child contacts
        return count;
    }
    
    
    /**
* Retrieves contact opportunities based on the given Contact Id and Account Id.
* It queries Opportunity records and related OpportunityContactRole records to obtain
* contact information and their associated opportunities. The method populates a custom
* wrapper class (wrapContactOpportunity) with the retrieved data and returns a list
* of wrapContactOpportunity objects.
* This method retrns the opportunities related to a contact, when the user hover a contact 
* card on the Contact Hierarcky component
*
* @param conId The Contact Id to retrieve opportunities for.
* @param accId The Account Id to filter the opportunities by.
* @return A list of wrapContactOpportunity objects containing contact opportunities and related information.
*/
    @AuraEnabled
    public static List<wrapContactOpportunity> getContactOpportunities(String conId, String accId){
        // Query opportunities and related OpportunityContactRoles
        List<Opportunity> oppList = [SELECT Id, OpportunityId__c, (SELECT Role, Contact.Name, Contact.Account.Name, Contact.Account.Id  
                                                                   FROM OpportunityContactRoles
                                                                   WHERE ContactId =: conId) 
                                     FROM Opportunity    WHERE id IN (SELECT OpportunityId 
                                                                      FROM OpportunityContactRole 
                                                                      WHERE ContactId =: conId) 
                                     AND AccountId =: accId
                                     AND StageName NOT IN ('Closed/Won','Closed Lost')
                                    ];
        
        // Create a list to hold the results
        List<wrapContactOpportunity> result = new List<wrapContactOpportunity>();  
        
        // Check if any opportunities were found
        if(!oppList.isEmpty()){
            
            // Get the base Salesforce URL
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            
            // Loop through each Opportunity record
            for (Opportunity opp : oppList) {
                
                // Get the OpportunityContactRoles related to the Opportunity
                List<OpportunityContactRole> conRoleList = opp.OpportunityContactRoles ;
                
                // Check if any OpportunityContactRoles were found
                if(!conRoleList.isEmpty()){
                    
                    // Loop through each OpportunityContactRole
                    for (OpportunityContactRole conRole : conRoleList) {
                        // Create an instance of the wrapper class
                        wrapContactOpportunity singleWrap = new wrapContactOpportunity();
                        
                        // Set the contact role, defaulting to '------' if it's blank or null
                        if(conRole.Role == '' || conRole.Role == null){
                            singleWrap.ConRole = '------';
                        } else {
                            singleWrap.ConRole = conRole.Role;  
                        }
                        
                        // Set the contact name, Contact Id, account name, and account id
                        singleWrap.ConName = conRole.Contact.Name;
                        singleWrap.ConId = conRole.Contact.Id;
                        singleWrap.AccountName = conRole.Contact.Account.Name;
                        singleWrap.AccountId = conRole.Contact.Account.Id;
                        
                        // Set the opportunity id, opportunity short name, and opportunity URL
                        singleWrap.OppId = opp.Id;
                        singleWrap.OppShortName = opp.OpportunityId__c;
                        singleWrap.OppUrl = sfdcBaseURL+'/'+opp.Id;
                        
                        // Add the wrapper object to the result list
                        result.add(singleWrap);                        
                    }
                }
            }
        }
        // Return the list of wrapContactOpportunity objects
        return result;
    }
    
    
    /**
* Retrieves contact strategies based on the given Contact Id, Account Id, and Account Plan Id.
* It queries AccountContactRelation records to obtain contact roles and Strategy_and_Goal__c records
* to fetch relevant contact strategies. The method populates a custom wrapper class (wrapContactStrategy)
* with the retrieved data and returns a list of wrapContactStrategy objects.
* This method retrns the strategies related to a contact, when the user hover a contact card on the Contact Hierarcky component
*
* @param conId     The Contact Id to retrieve strategies for.
* @param accId     The Account Id to filter the strategies by.
* @param accPlanId The Account Plan Id to filter the strategies by.
* @return A list of wrapContactStrategy objects containing contact strategies and related information.
*/
    @AuraEnabled
    public static List<wrapContactStrategy> getContactStrategies(String conId, String accId, String accPlanId){
        
        List<wrapContactStrategy> result = new List<wrapContactStrategy>(); 
        
        // Query AccountContactRelation records based on the given Contact Id and Account Id
        List<AccountContactRelation> acrList = [
            SELECT id, Roles, ContactId, AccountId 
            FROM AccountContactRelation 
            WHERE ContactId = :conId 
            //AND AccountId = :accId
        ];
        
        // Create a map to store AccountContactRelation Ids and Roles
        Map<Id, String> mapIdRole = new Map<Id, String>();
        
        // If AccountContactRelation records exist, populate the map with the Ids and Roles
        if(!acrList.isEmpty()){    
            for (AccountContactRelation item : acrList) {
                mapIdRole.put(item.Id, item.Roles);
            }
        }
        
        // Query Strategy_and_Goal__c records based on the given Account Id and Account Plan Id
        List<Strategy_and_Goal__c> stgoal = [
            SELECT Id, Account_Contact_Relations__c,Strategy_Name__c, InActive__c
            FROM Strategy_and_Goal__c 
            //WHERE Account_Plan__r.Account_Name__c = :accId
            //AND Account_Plan__c = :accPlanId
            WHERE Account_Plan__c = :accPlanId
            AND InActive__c = false
        ];
        
        // If Strategy_and_Goal__c records exist, process each record
        // if(!stgoal.isEmpty()){
        
        //     // Get the Salesforce base URL
        //     String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        //     // Iterate over each Strategy_and_Goal__c record
        //     for (Strategy_and_Goal__c item : stgoal) {
        
        //         // Check if the Account_Contact_Relations__c field is not empty or null
        //         if(item.Account_Contact_Relations__c != '' && item.Account_Contact_Relations__c != null ){
        
        //             // Split the Account_Contact_Relations__c field by the delimiter ';'
        //             List<String> strList = item.Account_Contact_Relations__c.split(';');
        
        //             // Process each value in the split list
        //             String rolesToAdd ='';
        //             List<String> rolesList = new List<String>();
        //             for (String st : strList) {
        //                 if(mapIdRole.keySet().contains(st)){
        //                     // Set the Contact Role value based on the map value        
        //                     if(mapIdRole.get(st) != null || mapIdRole.get(st) != '' ){
        //                         String temp = mapIdRole.get(st);
        //                         List<String> tempList = temp.split(';'); 
        //                         rolesList.addAll(tempList);
        //                     } 
        //             }
        //         }
        //             Set<String> roleSet= new Set<String>();
        //                 for(String role:rolesList){
        //                     roleSet.add(role);
        //                 }
        //                 rolesToAdd = String.join(new List<String>(roleSet),';');
        //                 // Create a new instance of the wrapContactStrategy class
        //                 wrapContactStrategy rec = new wrapContactStrategy();
        
        //                 // Check if the map contains the AccountContactRelation Id
        //                 // if(mapIdRole.keySet().contains(st)){
        //                 //     // Set the Contact Role value based on the map value        
        //                 //     if(mapIdRole.get(st) == null || mapIdRole.get(st) == '' ){
        //                 //         rec.ConRole = '------';
        //                 //     } else {
        //                 //         rec.ConRole = mapIdRole.get(st);
        //                 //     }
        //                     // Set the Account Id, Contact Id, Strategy Id, and Strategy Name
        //                     rec.AccountId = accId;
        //                     rec.ConId = conId;
        //                     rec.StratId = item.Id;
        //                     rec.StratName = item.Strategy_Name__c;
        //                     // Set the Strategy URL using the Salesforce base URL and Strategy Id 
        //                     rec.StratUrl = sfdcBaseURL + '/' + item.Id;
        //                     rec.conRole = rolesToAdd;
        //                     // Add the record to the result list
        //                     result.add(rec);                        
        
        //                 }
        //             } 
        //         }
        
        // If Strategy_and_Goal__c records exist, process each record
        if(!stgoal.isEmpty()){
            
            // Get the Salesforce base URL
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            
            // Iterate over each Strategy_and_Goal__c record
            for (Strategy_and_Goal__c item : stgoal) {
                
                // Check if the Account_Contact_Relations__c field is not empty or null
                if(item.Account_Contact_Relations__c != '' && item.Account_Contact_Relations__c != null ){
                    
                    // Split the Account_Contact_Relations__c field by the delimiter ';'
                    List<String> strList = item.Account_Contact_Relations__c.split(';');
                    
                    // Process each value in the split list
                    for (String st : strList) {
                        
                        // Create a new instance of the wrapContactStrategy class
                        wrapContactStrategy rec = new wrapContactStrategy();
                        
                        // Check if the map contains the AccountContactRelation Id
                        if(mapIdRole.keySet().contains(st)){
                            // Set the Contact Role value based on the map value        
                            if(mapIdRole.get(st) == null || mapIdRole.get(st) == '' ){
                                rec.ConRole = '';
                            } else {
                                rec.ConRole = mapIdRole.get(st);
                            }
                            // Set the Account Id, Contact Id, Strategy Id, and Strategy Name
                            rec.AccountId = accId;
                            rec.ConId = conId;
                            rec.StratId = item.Id;
                            rec.StratName = item.Strategy_Name__c;
                            // Set the Strategy URL using the Salesforce base URL and Strategy Id 
                            rec.StratUrl = sfdcBaseURL + '/' + item.Id;
                            
                            // Add the record to the result list
                            result.add(rec);                        
                            
                        }
                    } 
                }
            }
        }
        
        Map<Id,wrapContactStrategy> roleMap = new Map<Id,wrapContactStrategy>();
        for (wrapContactStrategy wrap : result) {
            if(roleMap.get(wrap.StratId)==null){
                roleMap.put(wrap.StratId,wrap);
            }else{
                List<String> roles = roleMap.get(wrap.StratId).conRole.split(';');
                roles.addAll(wrap.conRole.split(';'));
                List<String> rolesToUse = new List<String>();
                for (String str : roles) {
                    if(!String.isBlank(str)&&!rolesToUse.contains(str)){
                        rolesToUse.add(str.trim());
                    }
                }
                wrapContactStrategy wr = roleMap.get(wrap.StratId);
                wr.conRole = String.join(rolesToUse,';');
                roleMap.put(wrap.StratId,wr);
            }
        }
        System.debug(roleMap);
        // List<String> stName = new List<String>();//Added by Prachi
        
        
        // List<Strategy_and_Goal__c> stgoal = [SELECT Name, Id , Account_Plan__c, Account_Plan__r.Account_Name__c,Strategy_Name__c
        // FROM Strategy_and_Goal__c 
        // WHERE Account_Plan__r.Account_Name__c =:accId 
        // AND Account_Plan__c =: accPlanId];
        
        // if(!stgoal.isEmpty()){
        
        //     Map<String,Id> startIdNameMap= new Map<String,Id>();
        //     Map<String,String> strNumberNameMap= new Map<String,String>();// Changed by Jai
        //     String names = '';
        //     String queryString = 'SELECT id, Roles, Strategies__c, ContactId, AccountId '+ 
        //     'FROM AccountContactRelation WHERE AccountId =: accId AND ContactId =: conId AND ( Strategies__c LIKE ';
        
        //     for (Strategy_and_Goal__c strat : stgoal) {
        //         stName.add(strat.Name);//Added by Prachi
        //         if(names == ''){
        //             names = '\'%' +strat.Name + '%\'';
        //         } else {
        //             names = names +'OR Strategies__c LIKE '+ '\'%' + strat.Name + '%\'';
        //         }
        //         startIdNameMap.put(strat.Name,strat.Id);
        //         strNumberNameMap.put(strat.Name,strat.Strategy_Name__c);// Changed by Jai
        //     }
        //     queryString = queryString + names + ')';
        
        //     List<AccountContactRelation> acrList = Database.query(queryString);
        
        
        //     //List<AccountContactRelation> acrList = [ SELECT id, Roles, Strategies__c, ContactId, AccountId 
        //     //                                         FROM AccountContactRelation 
        //     //                                         WHERE AccountId =: accId 
        //     //                                         AND ContactId =: conId
        //     //                                         AND Strategies__c LIKE :setNames];
        
        
        //     if(!acrList.isEmpty()){
        //         String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        //         for (AccountContactRelation item : acrList) {
        //             List<String> strList = item.Strategies__c.split(';');
        //             system.debug('Contacts ---> ' + stName); 
        //             system.debug('Contacts ---> ' + strList); 
        //             for (String st : strList) {
        //                 wrapContactStrategy rec = new wrapContactStrategy();
        //                  //Logic Added by Prachi -- so that Strategy related only for account plan are shown
        //                 if(stName.contains(st)){        
        //                 //Logic End
        
        //                 if(item.roles== '' || item.roles == null){
        //                     rec.ConRole = '------';
        //                 } else {
        //                     rec.ConRole = item.roles;
        //                 }
        //                 rec.AccountId = accId;
        //                 rec.ConId = conId;
        //                 rec.StratId = startIdNameMap.get(st);
        //                 rec.StratName = strNumberNameMap.get(st); // Changed by Jai
        //                 //rec.StratName = st;
        //                 rec.StratUrl = sfdcBaseURL + '/' + startIdNameMap.get(st);
        //                 result.add(rec);                        
        
        //                 }
        //                  }//Logic Added by Prachi
        //         }
        
        
        //     }                                    
        // }
        return roleMap.values();
    }
    
    /**
* This method creates or replaces a Contact record based on the provided parameters. It handles two scenarios:
* Creating children contacts: If the originalContactId is empty, a new contact is created and added as a child of 
* the original contact from which the "New" button was clicked.
* Replacing the original contact: If the originalContactId is not empty, a new contact is created, the original 
* contact is updated to "Left Institution" status, and the children contacts of the original contact are reparented to the new contact.
* 
* @param contactRecord The Contact record to be created or replaced.
* @param originalContcatId The ID of the original contact (if applicable) to be replaced.
* @return A success message if the operation is successful; otherwise, returns the error message generated by any exceptions.
*/
    @AuraEnabled
    public static String createContact(Contact contactRecord, String originalContcatId,
                                       String buttonType,Boolean isRootLevel //Change Prachi SSE-21273
                                      ){
                                          try {
                                              
                                              if(originalContcatId == ''){ // IF -> logic to Create children Contact
                                                  // Insert the new contact record
                                                  // Change  start Prachi SSE-21273
                                                  if(buttonType == 'Account'){
                                                      contactRecord.is_Root_Level_Contact__c = true; 
                                                  }
                                                  else if(buttonType == 'Contact'){
                                                      contactRecord.is_Root_Level_Contact__c = false; 
                                                  }
                                                  
                                                  //Change end added by Prachi SSE-21273
                                                  insert contactRecord; // New contact is created and added as children of Original contact from which New button was clicked
                                                  
                                              } else { // ELSE -> Logic to Replace original Contact
                                                  // Insert the new contact record
                                                  //Changes added by Jai 
                                                  
                                                  String idToCheck = contactRecord.ReportsToId;
                                                  if(idToCheck == 'rootlevel'){
                                                      
                                                      contactRecord.ReportsToId= null;
                                                  }
                                                  if(isRootLevel == true){
                                                      contactRecord.is_Root_Level_Contact__c = true; 
                                                  }
                                                  else{
                                                      contactRecord.is_Root_Level_Contact__c = false; 
                                                  }
                                                  
                                                  //Changes End Jai
                                                  insert contactRecord; // New Contact is created
                                                  
                                                  // Update the original contact to mark it as 'Left Institution'
                                                  Contact con = new Contact(
                                                      Id = originalContcatId, 
                                                      Contact_Status__c = 'Left Institution',
                                                      AutomationBypassDateTime__c = System.now()// this serves to bypass come contact validations, like for Title or Area of Interest
                                                  );
                                                  update con; // Original contact from which Replace button was clicked is updated to not Active
                                                  
                                                  // Retrieve and update the children contacts of the original contact
                                                  List<Contact> reparentedCons = [
                                                      SELECT Id, ReportsToId 
                                                      FROM Contact 
                                                      WHERE ReportsToId = :originalContcatId 
                                                      AND AccountId = :contactRecord.AccountId
                                                  ];
                                                  
                                                  // If not empty, Iterates and updates over the children contacts list of the original contact
                                                  if(!reparentedCons.isEmpty()){
                                                      for (Contact c : reparentedCons) {
                                                          // Update the ReportsToId of the children contacts to the ID of the new contact
                                                          c.ReportsToId = contactRecord.Id;
                                                          c.AutomationBypassDateTime__c = System.now(); // this serves to bypass come contact validations, like for Title or Area of Interest
                                                      }
                                                      update reparentedCons; // Children contacts of Original contact from which Replace button was clicked are 
                                                      // reparented. Childrens ReportsToId is now id of the New Contact.
                                                  }
                                              }  
                                              // Return a success message if the operation is successful   
                                              return 'Success';
                                              
                                          } catch(Exception e) {
                                              System.debug(e.getStackTraceString());
                                              System.debug(e.getMessage());
                                              return e.getMessage(); // Return the error message if an exception occurs
                                          }
                                      }
    
    /**
* Reparents a Contact by updating the ReportsToId field to a new value.
* This method bypasses certain contact validations, like for Title or Area of Interest,
* by setting the AutomationBypassDateTime__c field to the current timestamp.
* 
* @param contactId       The Id of the Contact to be reparented.
* @param newReportsToId  The Id of the new ReportsTo Contact for the reparented Contact.
* @return                'Success' if the Contact is successfully reparented, otherwise an error message.
*/
    @AuraEnabled
    public static String reparentContact(String contactId, String newReportsToId, Boolean isTopContact){
        try {
            
            
            //Change by Prachi SSE-21273
            Id newParentId ;
            if(isTopContact){
                newParentId = null;
            }
            else{
                newParentId = newReportsToId;
            }
            //Change end Prachi SSE-21273
            // Create a new Contact instance and set the necessary field values
            /* Commented by Prachi SSE-21273
*  Contact con = new Contact(
Id = contactId, 
ReportsToId = newParentId,
is_Root_Level_Contact__c = isTopContact,//Change by Prachi SSE-21273 
AutomationBypassDateTime__c = System.now() // this serves to bypass some contact validations, like for Title or Area of Interest
);*/
            Contact con = new Contact();
            con.Id = contactId;
            if(isTopContact){
                con.ReportsToId = null;
            }
            else{
                con.ReportsToId = newReportsToId;
            }
            
            con.is_Root_Level_Contact__c = isTopContact;
            con.AutomationBypassDateTime__c = System.now(); // this serves to bypass some contact validations, like for Title or Area of Interest
            //Change end Prachi SSE-21273
            update con; // Update the Contact record
            return 'Success'; // Return 'Success' if the update is successful
        } catch(Exception e) {
            System.debug(e.getMessage());
            return e.getMessage(); // Return the error message if an exception occurs
        }
    }
    
    /*Added by Prachi SSE-21273
* This method is added as to give users the access to build a heirarchy.*/
    
    @AuraEnabled
    public static ContactHierarchyWrapper getActiveContacts(String accountPlanId , String contactCardID , String accountId,
                                                            String buttonType){ 
                                                                ContactHierarchyWrapper chw = new ContactHierarchyWrapper();
                                                                List<wrapContact> wcList = new List<wrapContact>();
                                                                List<Contact> conList = new List<Contact>();
                                                                map<String,String> contactWithReportIdMap = new map<String,String>();
                                                                
                                                                try{
                                                                    List<Account_Plan__c> accplanList = [select id , Account_Name__c from Account_Plan__c
                                                                                                         where id =: accountPlanId];
                                                                    List<Contact>   allContacts = [select id,Title, ReportsToId, ReportsTo.Name, Job_Function__c,Name,
                                                                                                   Job_Level__c, Job_Role__c,Area_of_Interest__c, Last_Activity_Happen__c, 
                                                                                                   Contact_Status__c from contact where accountId =:accountId
                                                                                                   and ReportsToId != null 
                                                                                                   order by name asc ];  
                                                                    if(buttonType =='Account'){
                                                                        
                                                                        conList = [select id,Title, ReportsToId, ReportsTo.Name, Job_Function__c,Name,
                                                                                   Job_Level__c, Job_Role__c,Area_of_Interest__c, Last_Activity_Happen__c, 
                                                                                   Contact_Status__c from contact where accountId =:accountId
                                                                                   and Contact_Status__c='active' and ReportsToId = null and is_Root_Level_Contact__c = false
                                                                                   order by name asc ];  
                                                                    }
                                                                    else if(buttonType =='Contact'){
                                                                        
                                                                        conList = [select id,Title, ReportsToId, ReportsTo.Name, Job_Function__c,Name,
                                                                                   Job_Level__c, Job_Role__c,Area_of_Interest__c, Last_Activity_Happen__c, 
                                                                                   Contact_Status__c from contact where accountId =:accountId 
                                                                                   and Contact_Status__c='active' and id != :contactCardID and ReportsToId!= :contactCardID and ReportsToId = null
                                                                                   and is_Root_Level_Contact__c = false order by name asc ];
                                                                    }
                                                                    if(allContacts.size()>0){
                                                                        for(Contact c:allContacts){
                                                                            contactWithReportIdMap.put(c.id,c.ReportsToId);  
                                                                        }
                                                                    }
                                                                    
                                                                    List<String> reportToValues = new List<String>();
                                                                    reportToValues = contactWithReportIdMap.values();
                                                                    String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                                                                    if(conList.size()>0){
                                                                        for(Contact con :conList ){
                                                                            wrapContact wc = new wrapContact();
                                                                            String conId = con.id;
                                                                            if(reportToValues.contains(conId) == false){
                                                                                wc.ContactUrl = sfdcBaseURL+'/'+con.id;
                                                                                if(con.ReportsToId != null){
                                                                                    wc.reportsToUrl = sfdcBaseURL+'/'+con.ReportsToId;
                                                                                } 
                                                                                // wc.reportsToUrl = sfdcBaseURL+'/'+con.ReportsToId;
                                                                                wc.Id = con.Id;
                                                                                wc.Name = con.Name;
                                                                                wc.Title = con.Title;
                                                                                wc.ReportsToId = con.ReportsToId;
                                                                                wc.ReportsToName = con.ReportsTo.Name;  
                                                                                wc.JobFunction = con.Job_Function__c;
                                                                                wc.JobLevel = con.Job_Level__c;
                                                                                wc.JobRole = con.Job_Role__c;
                                                                                wcList.add(wc);
                                                                            }
                                                                        }
                                                                        
                                                                    } 
                                                                    chw.contactsList=wcList;
                                                                    chw.MessageType='Success';
                                                                    
                                                                }catch(exception ex){
                                                                    
                                                                    chw.MessageType='Error';
                                                                    chw.message=ex.getMessage();
                                                                }
                                                                return chw;
                                                            }
    
    @AuraEnabled()
    public static String updateReportsToId(string newReportsToId,List<Id> conId,String buttonType){
        String message ;
        
        try{
            
            if(conId.size()>0){
                List<contact> conList = new List<contact>();
                
                for(Id cid: conId){
                    
                    Contact con = new Contact();
                    con.id=cid;
                    con.AutomationBypassDateTime__c = System.now(); // this serves to bypass some contact validations, like for Title or Area of Interest
                    if(buttonType == 'Account'){                       
                        con.ReportsToId = null;
                        con.is_Root_Level_Contact__c = true;
                    }
                    else if(buttonType == 'Contact'){
                        con.ReportsToId=newReportsToId;
                        con.is_Root_Level_Contact__c = false;    
                    }
                    conList.add(con);
                }
                update conList;
            }
            message='Success';
            
        }catch(DMLException e){
            message = e.getDmlMessage(0);
            
        }
        catch(Exception ex){
            message=ex.getMessage();
        }
        return message;
    }
    //Change End Prachi SSE-21273
    
    public class wrapContact {
        @AuraEnabled
        public String Id {get; set;}
        
        @AuraEnabled
        public String AccountId {get; set;}
        
        @AuraEnabled
        public String AccountName {get; set;}
        
        @AuraEnabled
        public  String Name {get; set;}
        
        @AuraEnabled
        public String Phone {get; set;}
        
        @AuraEnabled
        public String Email {get; set;}
        
        @AuraEnabled
        public String Title {get; set;}
        
        @AuraEnabled
        public String ReportsToId {get; set;} 
        
        @AuraEnabled
        public String ReportsToName {get; set;}
        
        @AuraEnabled    
        public String PhotoUrl {get; set;}
        
        @AuraEnabled
        public Datetime LastModifiedDate {get; set;}
        
        @AuraEnabled
        public Datetime LastActivityDate {get; set;}
        
        @AuraEnabled
        public Boolean IsLastContacted {get; set;}
        
        @AuraEnabled
        public Integer LastActivityInterval {get; set;} 
        
        @AuraEnabled
        public String SubjectDiscussed {get; set;}
        
        @AuraEnabled
        public String JobLevel {get; set;}
        
        @AuraEnabled
        public String JobRole {get; set;}
        
        @AuraEnabled
        public String AreaInterest {get; set;} 
        
        @AuraEnabled
        public String JobFunction {get; set;}
        
        @AuraEnabled
        public Boolean IsActive {get; set;}
        
        @AuraEnabled
        public Integer CountOpportunities {get; set;}
        
        @AuraEnabled
        public Integer CountStrategies {get; set;}
        
        //Change Start SSE-21273
        @AuraEnabled
        public String ContactUrl {get; set;}
        
        @AuraEnabled
        public String reportsToUrl {get; set;}
        
        @AuraEnabled
        public Boolean isRootLevel {get; set;}
        //Change End Prachi SSE-21273
        @AuraEnabled
        public Boolean isFromDiffAccount {get; set;}
        @AuraEnabled
        public String diffAccountId {get; set;}
        
    }
    
    public class wrapContactOpportunity {
        @AuraEnabled
        public String OppId {get; set;}
        @AuraEnabled
        public String ConRole {get; set;}
        @AuraEnabled
        public String OppShortName {get; set;}
        @AuraEnabled
        public String ConName {get; set;}
        @AuraEnabled
        public String ConId {get; set;}
        @AuraEnabled
        public String AccountName {get; set;}
        @AuraEnabled
        public String AccountId {get; set;}
        @AuraEnabled
        public String OppUrl {get; set;}
    }
    
    public class wrapContactStrategy {
        @AuraEnabled
        public String StratId {get; set;}
        @AuraEnabled
        public String ConRole {get; set;}
        @AuraEnabled
        public String StratName {get; set;}
        @AuraEnabled
        public String ConName {get; set;}
        @AuraEnabled
        public String ConId {get; set;}
        @AuraEnabled
        public String AccountName {get; set;}
        @AuraEnabled
        public String AccountId {get; set;}
        @AuraEnabled
        public String StratUrl {get; set;}
    }
    
    public class ContactHierarchyWrapper{
        @AuraEnabled
        public List<wrapContact> contactsList {get; set;}
        @AuraEnabled
        public String message {get; set;}
        //Change Start Prachi SSE-21273
        @AuraEnabled
        public String MessageType {get; set;}
        //Change End Prachi SSE-21273
        @AuraEnabled
        public List<PicklistWrapper> dNumberList {get; set;}
        @AuraEnabled
        public Boolean isRegionalOrGlobal {get; set;}
        @AuraEnabled
        public List<Contact> allContactsList {get; set;}
    }
    
    public class PicklistWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    
}
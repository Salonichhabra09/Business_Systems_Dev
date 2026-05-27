public class ACR_RelationshipMapController {
    
    @AuraEnabled
    public static String createHierarchyOnAccount(Id accountId, String hierarchyName){
        
        String hierarchyInformationId = '';
        try{
            Id idToUse;
            Boolean isAccountPlan = false;
            if(accountId.getSObjectType()==Schema.Account.SObjectType){
                idToUse = accountId;
            }else{
                List<Account_Plan__c> accountPlan = [SELECT Id, Account_Name__c FROM Account_Plan__c WHERE Id = :accountId];
                idToUse = accountPlan[0].Account_Name__c;
                isAccountPlan = true;
            }
            List<Account> accountList = [SELECT Id, Name, Account_Number__c 
                                         FROM Account 
                                         WHERE Id =:idToUse];
            
            List<HierarchyWrapper> hierarchyList = new List<HierarchyWrapper>();
            HierarchyWrapper rootNode = new HierarchyWrapper();
            rootNode.Id = 'rootlevel';
            rootNode.Name = accountList[0].Account_Number__c;
            rootNode.IsPlaceholder = false;
            rootNode.Children = new List<HierarchyWrapper>();
            hierarchyList.add(rootNode);
            
            System.debug(hierarchyName);
            
            Map<String, HierarchyWrapper> hierarchyMap = new Map<String, HierarchyWrapper>();
            //HierarchyWrapper rootNode = null;
            
            // Populate map for quick lookup
            for (HierarchyWrapper node : hierarchyList) {
                hierarchyMap.put(node.Id, node);
            }
            
            // Build hierarchy
            for (HierarchyWrapper node : hierarchyList) {
                if (node.ReportsTo == null) {
                    rootNode = node;
                } else {
                    HierarchyWrapper parentNode = hierarchyMap.get(node.ReportsTo);
                    if (parentNode != null) {
                        parentNode.Children.add(node);
                    }
                }
            }
            
            String jsonHierarchy = JSON.serializePretty(rootNode);
            System.debug(jsonHierarchy);
            
            Hierarchy_Information__c hierarchyInformation = new Hierarchy_Information__c();
            hierarchyInformation.In_Use_Structure__c = jsonHierarchy;
            hierarchyInformation.Account__c = idToUse;
            hierarchyInformation.Hierarchy_Name__c = hierarchyName;
            if(isAccountPlan == true){
                hierarchyInformation.Account_Plan__c = accountId;
            }
            
            Insert hierarchyInformation;
            
            hierarchyInformationId = hierarchyInformation.Id;
            
        }catch (DMLException e) {
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());  
        }
        
        return hierarchyInformationId;
    }
    
    /*
-Retrieves a list of contact/placeholder records along with related information for a given Hierarchy Information Id
-It populates a list of wrapper objects containing the contact information and returns it.

@param hierarchyInformationId : The Hierarchy Information record Id to retrieve.
@return A list of CardWrapper objects containing the contact and placeholder information for the hierarchy chart.
*/
    @AuraEnabled(cacheable=true)
    //public static ContactHierarchyWrapper  getHierarchyDetails(){
    public static hierarchyDetails getHierarchyDetails(Id hierarchyInformationId){
        
        HierarchyDetails hierarchyDetails = new HierarchyDetails();
        List<HierarchyWrapper> flatList = new List<HierarchyWrapper>();
        try{
            List<Hierarchy_Information__c> hierarchyInformation = [SELECT Id, In_Use_Structure__c, Account__r.Name, Opportunity__c, Account__c FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];
            String jsonString = hierarchyInformation[0].In_Use_Structure__c;
            Integer totalPlaceholders = 0;
            
            HierarchyWrapper rootNode = (HierarchyWrapper) JSON.deserialize(jsonString, HierarchyWrapper.class);
            flatList = flattenHierarchy(rootNode);
            Set<Id> contactIdsInHierarchy = new Set<Id>();
            
            for (HierarchyWrapper node : flatList) {
                if(node.IsPlaceholder == true){
                    String placeholderNumber = node.Id.substringAfter('Placeholder');
                    if(totalPlaceholders < Integer.valueOf(placeholderNumber)){
                        totalPlaceholders = Integer.valueOf(placeholderNumber);
                    }
                }else if(node.Id != 'rootlevel'){
                    contactIdsInHierarchy.add(node.Id);
                }
            }
            
            Map<Id,OpportunityContactRole> opportunityContactRoleMap = new Map<Id,OpportunityContactRole>();
            //Map<Id, Contact> contactsInHierarchyMap = new Map<Id, Contact>([SELECT Id, Name, Job_Function__c, Contact_Status__c, Advocacy_Level__c FROM Contact WHERE AccountId =:hierarchyInformation[0].Account__c]);
            
            List<OpportunityContactRole> contactRoleList = [SELECT Id, Role, ContactId, Contact.Job_Function__c, Contact.Name, 
                                                            Contact.Contact_Status__c, OpportunityId, CreatedDate, Contact.Advocacy_Level__c, 
                                                            Opportunity.StageName, Contact.Contact_Persona__c, Contact.Title, Contact.Area_of_Interest__c,
                                                            Contact.Mailing_City__c, Contact.Global_Mailing_Country__c, Contact.Mailing_State_County__c 
                                                            FROM OpportunityContactRole 
                                                            WHERE ContactId IN :contactIdsInHierarchy AND Opportunity.CloseDate >= LAST_YEAR ];
            
            Map<Id,AccountContactRelation> accountContactRoleMap = new Map<Id,AccountContactRelation>();
            List<AccountContactRelation> contactRoleListOnAccount = [SELECT Id, Roles, ContactId, Contact.Job_Function__c, Contact.Name, Contact.Contact_Status__c, 
                                                                     Contact.Advocacy_Level__c, Contact.Contact_Persona__c, Contact.Title, Contact.Area_of_Interest__c,
                                                            		 Contact.Mailing_City__c, Contact.Global_Mailing_Country__c, Contact.Mailing_State_County__c 
                                                                     FROM AccountContactRelation 
                                                                     WHERE ContactId IN :contactIdsInHierarchy AND
                                                                     AccountId = :hierarchyInformation[0].Account__c];
            List<ContentDocumentLink> noteContentLinkList = new List<ContentDocumentLink>();
            if(!contactIdsInHierarchy.isEmpty()){
            noteContentLinkList = [SELECT Id, LinkedEntityId,ContentDocumentId FROM ContentDocumentLink 
                                                  			WHERE LinkedEntityId IN :contactIdsInHierarchy 
                                                  			AND ContentDocument.Title = '**Contact Relationship Map Note**'];
            }
            Set<Id> contactsLinkedToOpenOpportunity = new Set<Id>();
            Set<Id> contactsLinkedToClosedLostOpportunity = new Set<Id>();
            Set<Id> contactsLinkedToClosedWonOpportunity = new Set<Id>();
            Set<Id> contactsWithNotes = new Set<Id>();
            for(OpportunityContactRole role : contactRoleList){ 
                if(role.Opportunity.StageName != System.Label.Opportunity_Stage_6 && role.Opportunity.StageName != System.Label.Opportunity_Stage_7) {
                    contactsLinkedToOpenOpportunity.add(role.ContactId);
                }
                else if(role.Opportunity.StageName == System.Label.Opportunity_Stage_6){
                    contactsLinkedToClosedWonOpportunity.add(role.ContactId);
                }else if(role.Opportunity.StageName == System.Label.Opportunity_Stage_7){
                    contactsLinkedToClosedLostOpportunity.add(role.ContactId);
                }
                opportunityContactRoleMap.put(role.ContactId,role);
            }
            
            for(AccountContactRelation role : contactRoleListOnAccount){
                accountContactRoleMap.put(role.ContactId,role);
            }
            
            for(ContentDocumentLink contentLink : noteContentLinkList){
                contactsWithNotes.add(contentLink.LinkedEntityId);
            }
            
            for (HierarchyWrapper node : flatList) {
                if(node.Id != 'rootlevel' && node.IsPlaceholder == false){
                    AccountContactRelation role = accountContactRoleMap.get(node.Id);
                    if (role != null) {
                        node.JobFunction = role.Contact.Job_Function__c;
                        node.AdvocacyLevel = role.Contact.Advocacy_Level__c;
                        node.Persona = role.Contact.Contact_Persona__c;
                        
                        node.JobTitle = role.Contact.Title;
                        node.AreaOfInterest = role.Contact.Area_of_Interest__c;
                        node.City = role.Contact.Mailing_City__c;
                        node.State = role.Contact.Mailing_State_County__c;
                        node.Country = role.Contact.Global_Mailing_Country__c;
                        
                        
                        node.Name = role.Contact.Name;
                        if (role.Contact.Contact_Status__c == 'Active') {
                            node.IsActive = true;
                        } else {
                            node.IsActive = false;
                        }
                        system.debug(role.Roles);
                        system.debug(role.Contact.Name);
                        if(role.Roles != null && role.Roles.contains('Economic Buyer')){
                            node.IsEconomicBuyer = true;
                        }else{
                            node.IsEconomicBuyer = false;
                        }
                        if(role.Roles != null && role.Roles.contains('IO Psychologist')){
                            node.IsIOPsychologist = true;
                        }else{
                            node.IsIOPsychologist = false;
                        }
                    }
                    
                    
                    /*
//node.JobRole = contactRoleMap.get(node.Id);
node.JobFunction = contactsInHierarchyMap.get(node.Id).Job_Function__c;
node.AdvocacyLevel = contactsInHierarchyMap.get(node.Id).Advocacy_Level__c;
if(contactsInHierarchyMap.get(node.Id).Contact_Status__c == 'Active'){
node.IsActive = true;
} else {
node.IsActive = false;
}
node.Name = contactsInHierarchyMap.get(node.Id).Name;*/
                    if(!contactsLinkedToOpenOpportunity.contains(node.Id) && !contactsLinkedToClosedWonOpportunity.contains(node.Id) && !contactsLinkedToClosedLostOpportunity.contains(node.Id)){
                        node.OpportunityLinkedStatus = 'Not linked to opportunity';
                    }
                    if(!contactsLinkedToOpenOpportunity.contains(node.Id) && !contactsLinkedToClosedWonOpportunity.contains(node.Id) && contactsLinkedToClosedLostOpportunity.contains(node.Id)){
                        node.OpportunityLinkedStatus = 'Linked to Closed Lost Opportunity';
                    }
                    if(contactsLinkedToOpenOpportunity.contains(node.Id) && contactsLinkedToClosedWonOpportunity.contains(node.Id)){
                        node.OpportunityLinkedStatus = 'Linked to Open and Closed Won Opportunity';
                    }
                    if(contactsLinkedToOpenOpportunity.contains(node.Id) && !contactsLinkedToClosedWonOpportunity.contains(node.Id)){
                        node.OpportunityLinkedStatus = 'Linked to Open Opportunity';
                    }
                    if(!contactsLinkedToOpenOpportunity.contains(node.Id) && contactsLinkedToClosedWonOpportunity.contains(node.Id)){
                        node.OpportunityLinkedStatus = 'Linked to Closed Won Opportunity';
                    }
                    
                    if(contactsWithNotes.contains(node.Id)){
                        node.IsNoteAdded = true;
                    }else{
                        node.IsNoteAdded = false;
                    }
                    
                }
            }
            
            
            hierarchyDetails.HierarchyList = flatList;
            hierarchyDetails.TotalPlaceholders = totalPlaceholders;
            hierarchyDetails.AccountName = hierarchyInformation[0].Account__r.Name;
            hierarchyDetails.AccountUrl = URL.getOrgDomainUrl() + '/' + hierarchyInformation[0].Account__c;
            hierarchyDetails.AccountId = hierarchyInformation[0].Account__c;
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return hierarchyDetails;
    }
    
    
    // Method to flatten the hierarchy
    public static List<HierarchyWrapper> flattenHierarchy(HierarchyWrapper RootNode) {
        List<HierarchyWrapper> flatList = new List<HierarchyWrapper>();
        // Helper method to perform the recursion
        processNode(RootNode, flatList, null);
        return flatList;
    }
    
    // Recursive helper method
    private static void processNode(HierarchyWrapper CurrentNode, List<HierarchyWrapper> FlatList, String ReportsTo) {
        if (CurrentNode == null) return;
        
        // Add the current node to the flat list
        CurrentNode.ReportsTo = ReportsTo;
        FlatList.add(CurrentNode);
        
        // Process children recursively
        if (CurrentNode.Children != null) {
            for (HierarchyWrapper child : CurrentNode.Children) {
                processNode(child, FlatList,CurrentNode.Id);
            }
        }
    }
    
    public class HierarchyDetails {
        @AuraEnabled public List<HierarchyWrapper> HierarchyList {get; set;}
        @AuraEnabled public Integer TotalPlaceholders {get; set;}
        @AuraEnabled public String AccountName {get; set;}
        @AuraEnabled public String AccountUrl {get; set;}
        @AuraEnabled public String AccountId {get; set;}
    }
    
    public class HierarchyWrapper {
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public String ReportsTo {get; set;}
        @AuraEnabled public String JobRole {get; set;}
        @AuraEnabled public String JobFunction {get; set;}
        @AuraEnabled public Boolean IsPlaceholder {get; set;}
        @AuraEnabled public Boolean IsActive {get; set;}
        @AuraEnabled public String OpportunityLinkedStatus {get; set;}
        @AuraEnabled public Boolean IsEconomicBuyer {get; set;}
        @AuraEnabled public Boolean IsIOPsychologist {get; set;}
        @AuraEnabled public Boolean IsNoteAdded {get; set;}
        @AuraEnabled public String AdvocacyLevel {get; set;}
        @AuraEnabled public String Persona {get; set;}
        @AuraEnabled public String JobTitle {get; set;}
        @AuraEnabled public String AreaOfInterest {get; set;}
        @AuraEnabled public String City {get; set;}
        @AuraEnabled public String State {get; set;}
        @AuraEnabled public String Country {get; set;}
        @AuraEnabled public List<HierarchyWrapper> Children {get; set;}
        
        // Constructor
        public HierarchyWrapper(String id, String name, String reportsToNode, Boolean isPlaceholder, List<HierarchyWrapper> children) {
            this.id = id;
            this.name = name;
            this.isPlaceholder = isPlaceholder;
            //this.reportsToNode = reportsToNode;
            this.children = children;
        }
        
        public HierarchyWrapper(){
            
        }
    }
    
    @AuraEnabled
    public static void updateHierarchyOnPlaceholderCreation(List<HierarchyWrapper> hierarchyList, Id hierarchyInformationId){
        
        System.debug(hierarchyInformationId);
        System.debug(hierarchyList.size());
        Savepoint sp = Database.setSavepoint();
        try{
            HierarchyWrapper rootNode = new HierarchyWrapper();
            
            Map<String, HierarchyWrapper> hierarchyMap = new Map<String, HierarchyWrapper>();
            //HierarchyWrapper rootNode = null;
            
            // Populate map for quick lookup
            for (HierarchyWrapper node : hierarchyList) {
                hierarchyMap.put(node.Id, node);
            }
            
            // Build hierarchy
            for (HierarchyWrapper node : hierarchyList) {
                if (node.ReportsTo == null) {
                    rootNode = node;
                } else {
                    HierarchyWrapper parentNode = hierarchyMap.get(node.ReportsTo);
                    if (parentNode != null) {
                        parentNode.Children.add(node);
                    }
                }
            }
            
            String jsonHierarchy = JSON.serializePretty(rootNode);
            System.debug(jsonHierarchy);
            
            Hierarchy_Information__c hierarchyInformtionToUpdate = new Hierarchy_Information__c();
            hierarchyInformtionToUpdate.Id = hierarchyInformationId;
            hierarchyInformtionToUpdate.In_Use_Structure__c = jsonHierarchy;
            
            Update hierarchyInformtionToUpdate;
            
        }catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static GetContactWrapper getActiveContactsOfHierarchyAccount(Integer offSetValue, String filterValue, list<Id> currentContactIdsInHierarchy, String accountId){
        list<Contact> contactList = new list<Contact>();
        GetContactWrapper wrapper = new GetContactWrapper();
        String message;
        try{
            String baseQuery = 'SELECT Id, Name, Job_Function__c, Email, Phone, Title, Area_of_Interest__c, ' +
                'Job_Level__c, AccountId, Account.Name, ReportsToId, ReportsTo.Name, Contact_Persona__c, CreatedDate, '+
                'Mailing_City__c, Global_Mailing_Country__c, Mailing_State_County__c '+
                'FROM Contact WHERE Contact_Status__c = \'active\' AND AccountId = :accountId AND AccountId != null ';
            
            if (currentContactIdsInHierarchy != null) {
                baseQuery += 'AND Id NOT IN :currentContactIdsInHierarchy ';
            }
            if (!String.isBlank(filterValue)) {
                filterValue = '%' + filterValue + '%';
                baseQuery += 'AND (Name LIKE :filterValue OR Account.Name LIKE :filterValue) ';
            }
            baseQuery += 'ORDER BY Name LIMIT 10 OFFSET :offSetValue';
            
            contactList = Database.query(baseQuery);
            
            wrapper.contacts = contactList;
            message = '';            
            return wrapper;
        }catch(Exception ex){
            System.debug('Exception 2 ==> '+ ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static GetContactWrapper getActiveContacts(Integer offSetValue, String filterValue, list<Id> currentContactIdsInHierarchy, String accountId, Boolean isNotReplace, String buyingCentreId){
        list<Contact> contactList = new list<Contact>();
        GetContactWrapper wrapper = new GetContactWrapper();
        list<Contact> contactListFromAccount = new list<Contact>();
        list<Contact> contactListFromOtherAccounts = new list<Contact>();
        Boolean fetchOtherAccounts = false;
        String message = '';
        try{
            if (String.isBlank(filterValue)) {
                wrapper = getActiveContactsOfHierarchyAccount(offSetValue, filterValue, currentContactIdsInHierarchy, accountId);
                contactListFromAccount = wrapper.contacts;
                offSetValue = 0;
                contactList.addAll(contactListFromAccount);
                if(contactListFromAccount.size() < 10 && buyingCentreId != null){ 
                    fetchOtherAccounts = true; 
                }
                if(contactListFromAccount.size() == 0){
                   message = 'Contact does not exist or is not accessible.'; 
                }
            }else{
                fetchOtherAccounts = true; 
            }
            if(fetchOtherAccounts){
                String baseQuery = 'SELECT Id, Name, Job_Function__c, Email, Phone, Title, Area_of_Interest__c, ' +
                    'Job_Level__c, AccountId, Account.Name, ReportsToId, ReportsTo.Name, Contact_Persona__c, CreatedDate, ' +
                    'Mailing_City__c, Global_Mailing_Country__c, Mailing_State_County__c '+
                    'FROM Contact WHERE Contact_Status__c = \'active\' AND AccountId != null ';
                
                if(buyingCentreId != null && String.isBlank(filterValue)){
                    baseQuery += 'AND Account.Buying_Centre_Id__c = :buyingCentreId ';
                }
                if (!isNotReplace && currentContactIdsInHierarchy != null) {
                    baseQuery += 'AND Id NOT IN :currentContactIdsInHierarchy ';
                }
                if (!String.isBlank(filterValue)) {
                    filterValue = '%' + filterValue + '%';
                    baseQuery += 'AND (Name LIKE :filterValue OR Account.Name LIKE :filterValue) ';
                }else{
                    baseQuery += 'AND AccountId != :accountId ';
                }
                baseQuery += 'ORDER BY Name, AccountId, Account.Buying_Centre_Id__c LIMIT 10 OFFSET :offSetValue';
                System.debug('baseQuery' + baseQuery);
                contactListFromOtherAccounts = Database.query(baseQuery);
                
                if(isNotReplace && !contactListFromOtherAccounts.isEmpty()){
                    List<Contact> filteredList = new List<Contact>();
                    for (Contact c : contactListFromOtherAccounts) {
                        if (!currentContactIdsInHierarchy.contains(c.Id)) {
                            filteredList.add(c);
                        }
                    }
                    if(filteredList.isEmpty() && (!String.isBlank(filterValue))){
                        contactList.addAll(filteredList);
                        message = 'Contact already present in hierarchy!';
                    }else{
                        contactList.addAll(filteredList);
                        message = '';
                    }
                }else{
                    contactList.addAll(contactListFromOtherAccounts);
                    message = 'Contact does not exist or is not accessible.';
                }
            }
            wrapper.contacts = contactList;
            wrapper.message = message;
            return wrapper;
        }catch(Exception ex){
            System.debug('Exception ==> '+ ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class GetContactWrapper{
        @AuraEnabled public list<Contact> contacts { get; set; }
        @AuraEnabled public String message { get; set; }
    }
    
    @AuraEnabled
    public static void updateHierarchyOnExistingContactSelection(List<ContactWrapper> contactList, String accountId, String hierarchyInformationId, String parentNodeId, list<HierarchyWrapper> allNodes) {
        List<Contact> contactsToUpdate = new List<Contact>();
        List<AccountContactRelation> rolesToInsert = new List<AccountContactRelation>();
        list<Id> contactIdsList = new list<Id>();
        Savepoint sp = Database.setSavepoint();
        for (ContactWrapper wrapper : contactList) {
            if (wrapper != null && wrapper.id != null) {
                // Update Contact record
                Contact contactRecord = new Contact(
                    Id = wrapper.id,
                    Contact_Persona__c = wrapper.persona,
                    AutomationBypassDateTime__c = System.now()
                );
                contactsToUpdate.add(contactRecord);
                contactIdsList.add(contactRecord.Id);
            }
        }
        try { 
            if(!contactsToUpdate.isEmpty())
                UPDATE contactsToUpdate;
            
            List<AccountContactRelation> existingContactRoleListOnOpp = [SELECT Id, Roles, ContactId, Contact.Job_Function__c, Contact.Name, Contact.Contact_Status__c
                                                                         FROM AccountContactRelation 
                                                                         WHERE ContactId IN :contactIdsList AND
                                                                         AccountId = :accountId];
            Map<Id, Id> existingContactRoleIdKeysMap = new Map<Id, Id>();
            
            if(!existingContactRoleListOnOpp.isEmpty()){
                for (AccountContactRelation existingRole : existingContactRoleListOnOpp) {
                    existingContactRoleIdKeysMap.put(existingRole.ContactId, existingRole.Id);
                }
            }
            
            // Create AccountContactRelation record(s)
            for (Integer i = 0; i < contactList.size(); i++) {
                if (existingContactRoleIdKeysMap.get(contactList[i].id) == null) {
                    AccountContactRelation newRole = new AccountContactRelation();
                    newRole.AccountId = accountId;
                    newRole.ContactId = contactList[i].id; 
                    rolesToInsert.add(newRole);
                } 
            }
            if(!rolesToInsert.isEmpty())
                insert rolesToInsert;
            
            updateHierarchyOnPlaceholderCreation(allNodes, hierarchyInformationId);
        } catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    public class ContactWrapper {
        @AuraEnabled public Integer index { get; set; }
        @AuraEnabled public String id { get; set; }
        //@AuraEnabled public String salutation { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String jobFunction { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String advocacyLevel { get; set; }
        @AuraEnabled public String role { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String persona { get; set; }
        @AuraEnabled public String areaOfInterest { get; set; }
        
        public ContactWrapper() {
        }
        // Constructor to initialize the wrapper object
        public ContactWrapper(Integer index, String id, String salutation, String firstName, String lastName, String accountId, String email, String jobFunction, String advocacyLevel, String title, String role, String phone, String persona, String areaOfInterest) {
            this.index = index;
            this.id = id;
            //this.salutation = salutation;
            this.firstName = firstName;
            this.lastName = lastName;
            this.accountId = accountId;
            this.email = email;
            this.jobFunction = jobFunction;
            this.advocacyLevel = advocacyLevel;
            this.title = title;
            this.role = role;
            this.phone = phone;
            this.persona = persona;
            this.areaOfInterest = areaOfInterest;
        }
    }
    
    @AuraEnabled
    public static void createContactRecords(List<ContactWrapper> contactList, String accountId, String hierarchyInformationId, String parentNodeId, list<HierarchyWrapper> allNodes) {
        List<Contact> contactsToInsert = new List<Contact>();
        list<HierarchyWrapper> newNodeList = new list<HierarchyWrapper>();
        Savepoint sp = Database.setSavepoint();
        for (ContactWrapper wrapper : contactList) {
            System.debug('ID '+ wrapper.Id);
            // Create Contact record
            Contact newContact = new Contact(
                //Salutation = wrapper.salutation,
                FirstName = wrapper.firstName,
                LastName = wrapper.lastName,
                Email = wrapper.email,
                Phone = wrapper.phone,
                AccountId = wrapper.accountId,
                Job_Function__c = wrapper.jobFunction,
                Title = wrapper.title,
                Advocacy_Level__c = wrapper.advocacyLevel,
                AutomationBypassDateTime__c = System.now(),
                Contact_Persona__c = wrapper.persona,
                Area_of_Interest__c= wrapper.areaOfInterest
            );
            contactsToInsert.add(newContact);
        }
        
        try {
            if(!contactsToInsert.isEmpty())
                insert contactsToInsert;
            
            Set<Id> newContactIdsList = new Set<Id>();
            for(Contact con : contactsToInsert){
                newContactIdsList.add(con.Id);
            }
            
            for (Integer i = 0; i < contactsToInsert.size(); i++) {
                
                //Update Hierarchy
                HierarchyWrapper newNodeToAdd = new HierarchyWrapper();
                newNodeToAdd.ReportsTo = parentNodeId;
                newNodeToAdd.Name = contactList[i].firstName + ' ' + contactList[i].lastName;
                newNodeToAdd.Persona = contactList[i].persona;
                newNodeToAdd.IsPlaceholder = false;
                newNodeToAdd.Id = contactsToInsert[i].Id;
                
                newNodeList.add(newNodeToAdd);
            }
            for (HierarchyWrapper node : allNodes) {
                node.Children = new List<HierarchyWrapper>();
            }
            allNodes.addAll(newNodeList);
            updateHierarchyOnPlaceholderCreation(allNodes, hierarchyInformationId);
        } catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Hierarchy_Information__c> getListOfRelationships(Id accountId){
        list<Hierarchy_Information__c> hierarchyList = new list<Hierarchy_Information__c>();
        try{
            Id idToUse;
            if(accountId.getSObjectType()==Schema.Account.SObjectType){
                idToUse = accountId;
            }else{
                List<Account_Plan__c> accountPlan = [SELECT Id, Account_Name__c FROM Account_Plan__c WHERE Id = :accountId];
                idToUse = accountPlan[0].Account_Name__c;
            }
            System.debug(idToUse);
            hierarchyList = [SELECT Id, 
                             Account__r.Name, Opportunity__c, 
                             Account__c, Hierarchy_Name__c,
                             CreatedDate, CreatedBy.Name,
                             LastModifiedDate, LastModifiedBy.FirstName,
                             LastModifiedBy.LastName
                             FROM Hierarchy_Information__c 
                             WHERE Account__c =:idToUse];
            return hierarchyList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static void deleteHierarchy(Id hierarchyInformationId){
        List<Hierarchy_Information__c> hierarchyInformationToDelete = [SELECT Id FROM Hierarchy_Information__c WHERE Id = :hierarchyInformationId];
        Delete hierarchyInformationToDelete;
    }
    
    @AuraEnabled
    public static void updateAdvocacyLevelOnContact(String advocacyLevel, List<HierarchyWrapper> hierarchyList, Id hierarchyInformationId, String contactId){
        List<String> listOfroles = new List<String>();
        Savepoint sp = Database.setSavepoint();
        try{
            List<Contact> contactToUpdate = new list<Contact>();
            Contact con = new Contact();
            con.Id = contactId;
            con.Advocacy_Level__c = advocacyLevel; 
            contactToUpdate.add(con);
            
            if (!contactToUpdate.isEmpty())
                UPDATE contactToUpdate; // Update contact
            
            // Update hierarchy
            updateHierarchyOnPlaceholderCreation(hierarchyList, hierarchyInformationId);
        } catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0)); 
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    //replacedId = Id of the newly created contact
    //contactToReplace = New Contact to create
    //contactToDelete = Contact to delete (Contact that was replaced)
    //contactsToUpdate = Existing Contact used to replace
    @AuraEnabled
    public static void updateRelationshipMapOnReplace(List<HierarchyWrapper> hierarchyList, Id hierarchyInformationId, String replacedId, Contact contactToReplace, List<Contact> contactsToUpdate, String contactToDelete){
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            Hierarchy_Information__c hierarchyInformtionToUpdate = [SELECT Id, In_Use_Structure__c, Opportunity__c, Account__c, Influence__c, Conflict__c FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];
            
            if(contactToReplace != null){
                contactToReplace.AutomationBypassDateTime__c = System.now();
                Insert contactToReplace;
            }
            
            HierarchyWrapper rootNode = new HierarchyWrapper();
            Map<String, HierarchyWrapper> hierarchyMap = new Map<String, HierarchyWrapper>();
            
            // Populate map for quick lookup
            for (HierarchyWrapper node : hierarchyList) {
                if(node.Id == replacedId && contactToReplace !=null){
                    node.Id = contactToReplace.Id;
                    node.IsPlaceholder = false;
                }
                if(node.ReportsTo == replacedId && contactToReplace !=null){
                    node.ReportsTo = contactToReplace.Id;
                }
                hierarchyMap.put(node.Id, node);
            }
            
            // Build hierarchy
            for (HierarchyWrapper node : hierarchyList) {
                if (node.ReportsTo == null) {
                    rootNode = node;
                } else {
                    HierarchyWrapper parentNode = hierarchyMap.get(node.ReportsTo);
                    if (parentNode != null) {
                        parentNode.Children.add(node);
                    }
                }
            }
            
            String jsonHierarchy = JSON.serializePretty(rootNode);
            
            hierarchyInformtionToUpdate.In_Use_Structure__c = jsonHierarchy;
            
            List<Contact> updatePersonaOnContact = new List<Contact>();
            Set<Id> contactIdsList = new Set<Id>();
            for(Contact con : contactsToUpdate){
                System.debug('con --> '+ con);
            }
            if(!contactsToUpdate.isEmpty()){
                for(Contact con : contactsToUpdate){
                    Contact newCon = new Contact();
                    newCon.Id = con.Id;
                    newCon.AutomationBypassDateTime__c = System.now();
                    newCon.Contact_Persona__c = con.Contact_Persona__c;
                    contactIdsList.add(newCon.Id);
                    updatePersonaOnContact.add(newCon);
                }
                UPDATE updatePersonaOnContact;
            }
            
            List<AccountContactRelation> existingContactRoleListOnOpp = [SELECT Id, Roles, ContactId, Contact.Job_Function__c, Contact.Name, Contact.Contact_Status__c
                                                                         FROM AccountContactRelation 
                                                                         WHERE ContactId IN :contactIdsList 
                                                                         AND AccountId = :hierarchyInformtionToUpdate.Account__c];
            Map<Id, Id> existingContactRoleIdKeysMap = new Map<Id, Id>();
            
            if(!existingContactRoleListOnOpp.isEmpty()){
                for (AccountContactRelation existingRole : existingContactRoleListOnOpp) {
                    existingContactRoleIdKeysMap.put(existingRole.ContactId, existingRole.Id);
                }
            }
            
            List<AccountContactRelation> rolesToInsert = new List<AccountContactRelation>();
            // Create AccountContactRelation record(s)
            for (Integer i = 0; i < contactsToUpdate.size(); i++) {
                if (existingContactRoleIdKeysMap.get(contactsToUpdate[i].Id) == null) {
                    AccountContactRelation newRole = new AccountContactRelation();
                    newRole.AccountId = hierarchyInformtionToUpdate.Account__c;
                    newRole.ContactId = contactsToUpdate[i].Id; 
                    rolesToInsert.add(newRole);
                } 
            }
            if(!rolesToInsert.isEmpty())
                insert rolesToInsert;
            
            // Delete failed. First exception on row 0 with id 07kQ10000048eE7IAI; first error: INVALID_OPERATION, 
            // A direct relationship can't be deleted. You can modify the relationship by changing the contact's parent account or deleting the contact.
            /*if(contactToDelete != null && contactToDelete.startsWith('003')){
List<AccountContactRelation> contactRolesToDelete = [SELECT Id FROM AccountContactRelation 
WHERE ContactId =:contactToDelete 
AND AccountId = :hierarchyInformtionToUpdate.Account__c];
DELETE contactRolesToDelete;    
}*/
            System.debug(contactToDelete);
            if(hierarchyInformtionToUpdate.Influence__c != null){
                List<InfluenceAndConflictWrapper> influenceList = (List<InfluenceAndConflictWrapper>)JSON.deserialize(hierarchyInformtionToUpdate.Influence__c,List<InfluenceAndConflictWrapper>.Class);
			
            	List<InfluenceAndConflictWrapper> updatedInfluenceList = new List<InfluenceAndConflictWrapper>();
            	for(InfluenceAndConflictWrapper wrap : influenceList){
                	if(wrap.id.contains(contactToDelete) == false){
                    	updatedInfluenceList.add(wrap);
                	}
            	}
            
            	String updatedInfluenceJSON ='';
                if(!updatedInfluenceList.isEmpty()){
					updatedInfluenceJSON = JSON.serialize(updatedInfluenceList);
                }else{
                    updatedInfluenceJSON = null;
                }
            	hierarchyInformtionToUpdate.Influence__c = updatedInfluenceJSON;
            }
            
            if(hierarchyInformtionToUpdate.Conflict__c != null){
                List<InfluenceAndConflictWrapper> conflictList = (List<InfluenceAndConflictWrapper>)JSON.deserialize(hierarchyInformtionToUpdate.Conflict__c,List<InfluenceAndConflictWrapper>.Class);
			
            	List<InfluenceAndConflictWrapper> updatedconflictList = new List<InfluenceAndConflictWrapper>();
            	for(InfluenceAndConflictWrapper wrap : conflictList){
                	if(wrap.id.contains(contactToDelete) == false){
                    	updatedconflictList.add(wrap);
                	}
            	}
            
            	String updatedConflictJSON ='';
                if(!updatedconflictList.isEmpty()){
					updatedConflictJSON = JSON.serialize(updatedconflictList);
                }else{
                    updatedConflictJSON = null;
                }
            	hierarchyInformtionToUpdate.Conflict__c = updatedConflictJSON;
            }  
            
            
            UPDATE hierarchyInformtionToUpdate;
            
        }catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static void updateRelationshipMap(List<HierarchyWrapper> hierarchyList, Id hierarchyInformationId, String contactToDelete){
        
        Savepoint sp = Database.setSavepoint();
        try{
            Hierarchy_Information__c hierarchyInformtionToUpdate = [SELECT Id, In_Use_Structure__c, Opportunity__c, Account__c, Influence__c, Conflict__c FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];

            HierarchyWrapper rootNode = new HierarchyWrapper();
            
            Map<String, HierarchyWrapper> hierarchyMap = new Map<String, HierarchyWrapper>();
            //HierarchyWrapper rootNode = null;
            
            // Populate map for quick lookup
            for (HierarchyWrapper node : hierarchyList) {
                hierarchyMap.put(node.Id, node);
            }
            
            // Build hierarchy
            for (HierarchyWrapper node : hierarchyList) {
                if (node.ReportsTo == null) {
                    rootNode = node;
                } else {
                    HierarchyWrapper parentNode = hierarchyMap.get(node.ReportsTo);
                    if (parentNode != null) {
                        parentNode.Children.add(node);
                    }
                }
            }
            
            String jsonHierarchy = JSON.serializePretty(rootNode);
            System.debug(jsonHierarchy);
            
            hierarchyInformtionToUpdate.In_Use_Structure__c = jsonHierarchy;
            
            if(contactToDelete != null && hierarchyInformtionToUpdate.Influence__c != null){
                List<InfluenceAndConflictWrapper> influenceList = (List<InfluenceAndConflictWrapper>)JSON.deserialize(hierarchyInformtionToUpdate.Influence__c,List<InfluenceAndConflictWrapper>.Class);
			
            	List<InfluenceAndConflictWrapper> updatedInfluenceList = new List<InfluenceAndConflictWrapper>();
            	for(InfluenceAndConflictWrapper wrap : influenceList){
                	if(wrap.id.contains(contactToDelete) == false){
                    	updatedInfluenceList.add(wrap);
                	}
            	}
                  
                String updatedInfluenceJSON ='';
                if(!updatedInfluenceList.isEmpty()){
					updatedInfluenceJSON = JSON.serialize(updatedInfluenceList);
                }else{
                    updatedInfluenceJSON = null;
                }
            	hierarchyInformtionToUpdate.Influence__c = updatedInfluenceJSON;
            }
            
            if(contactToDelete != null && hierarchyInformtionToUpdate.Conflict__c != null){
                List<InfluenceAndConflictWrapper> conflictList = (List<InfluenceAndConflictWrapper>)JSON.deserialize(hierarchyInformtionToUpdate.Conflict__c,List<InfluenceAndConflictWrapper>.Class);
			
            	List<InfluenceAndConflictWrapper> updatedconflictList = new List<InfluenceAndConflictWrapper>();
            	for(InfluenceAndConflictWrapper wrap : conflictList){
                	if(wrap.id.contains(contactToDelete) == false){
                    	updatedconflictList.add(wrap);
                	}
            	}
            	String updatedConflictJSON ='';
                if(!updatedconflictList.isEmpty()){
					updatedConflictJSON = JSON.serialize(updatedconflictList);
                }else{
                    updatedConflictJSON = null;
                }
            	hierarchyInformtionToUpdate.Conflict__c = updatedConflictJSON;
            }       
            
            Update hierarchyInformtionToUpdate;
            
        }catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static void updateEconomicBuyerOrIOPsychologistStatus(Id contactId, Id accountId, String type, String role){
        
        Savepoint sp = Database.setSavepoint();
        try{
            List<AccountContactRelation> contactRole = [SELECT Id, Roles
                                                        FROM AccountContactRelation 
                                                        WHERE ContactId = :contactId AND
                                                        AccountId = :accountId];
            
            String updatedRoles = '';
            List<String> rolesList = new List<String>();
            if(type == 'Add'){
                if(contactRole[0].Roles != null){
                    rolesList = contactRole[0].Roles.split(';');
                }
                rolesList.add(role);
                updatedRoles = String.join(rolesList,';');
            }else{
                rolesList = contactRole[0].Roles.split(';');
                Integer indexOfEconomicBuyerRole = rolesList.indexOf(role);
                rolesList.remove(indexOfEconomicBuyerRole);
                updatedRoles = String.join(rolesList,';');
            }
            
            contactRole[0].Roles = updatedRoles;
            update contactRole[0];
            
        }catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static void insertNote(String content, Id recordId){
        
        Savepoint sp = Database.setSavepoint();
        try{
            String updatedContent = UserInfo.getName() + ' ' + System.Now() + '\n' + content;
            ContentNote newNote = new ContentNote();
            newNote.Title = '**Contact Relationship Map Note**';
            newNote.Content = Blob.valueOf(updatedContent);
            insert newNote;
            Id noteId = newNote.Id;
            // Create a ContentDocumentLink to relate the note to a record
            ContentDocumentLink link = new ContentDocumentLink();
            link.LinkedEntityId = recordId;
            link.ContentDocumentId = noteId;
            link.ShareType = 'V'; // Viewer access
            link.Visibility = 'AllUsers'; // Visible to all users 
            insert link;
            
        }catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static void updateNote(String content, Id recordId){
        
        Savepoint sp = Database.setSavepoint();
        try{
            
           ContentDocumentLink noteContentLink = [SELECT Id, LinkedEntityId,ContentDocumentId FROM ContentDocumentLink 
                                                  WHERE LinkedEntityId = :recordId 
                                                  AND ContentDocument.Title = '**Contact Relationship Map Note**'];
            
            ContentNote contentNote = [SELECT Id, TextPreview, Content FROM ContentNote WHERE Id = :noteContentLink.ContentDocumentId];
            String updatedNote = contentNote.Content.toString() + '\n <br>' + UserInfo.getName() + ' ' + System.Now() + '\n' + content ; 
            ContentNote noteToUpdate = new ContentNote();
            noteToUpdate.Id = noteContentLink.ContentDocumentId;
            noteToUpdate.Title = '**Contact Relationship Map Note**';
            noteToUpdate.Content = Blob.valueOf(updatedNote);
            
            Update noteToUpdate;

            
        }catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static String getNote(Id recordId){
        
        Savepoint sp = Database.setSavepoint();
        try{
            
           List<ContentDocumentLink> noteContentLink = [SELECT Id, LinkedEntityId,ContentDocumentId FROM ContentDocumentLink 
                                                  WHERE LinkedEntityId = :recordId 
                                                  AND ContentDocument.Title = '**Contact Relationship Map Note**'];
            
            if(!noteContentLink.isEmpty()){
                ContentNote contentNote = [SELECT Id, TextPreview, Content FROM ContentNote WHERE Id = :noteContentLink[0].ContentDocumentId];
				return contentNote.Content.toString();
            }else{
                return null;
            }
            

            
        }catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    /*@AuraEnabled(cacheable=true)
    public static ActivityAndAddressWrapper getActivityMetricData(String contactId){
        list<ActivityMetric> activityData = new list<ActivityMetric>();
        list<India_GST__c> addressInfo = new list<India_GST__c>();
        ActivityAndAddressWrapper wrapper = new ActivityAndAddressWrapper();
        
        try{
            addressInfo = [SELECT Id,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Address_Line_4__c,Is_Home_Address__c,
                Global_Country__c,City__c,State_County__c,ZIP_Postal_Code__c FROM India_GST__c 
                WHERE Contact__c  = :contactId AND Is_Home_Address__c = true ORDER By CreatedDate DESC LIMIT 1];
            
            activityData = [Select id,LastActivityDateTime,LastEmailDateTime,LastEmailSentDateTime,LastEmailReceivedDateTime,
                            LastActivityDateLastModDate from ActivityMetric where BaseId = :contactId ORDER By LastActivityDateTime DESC LIMIT 1];
            
            wrapper.activityData = activityData;
            wrapper.addressData = addressInfo;
            return wrapper;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    public class ActivityAndAddressWrapper{
        @AuraEnabled public list<ActivityMetric> activityData { get; set; }
        @AuraEnabled public list<India_GST__c> addressData { get; set; }
    }*/
    
    @AuraEnabled
    public static void renameHierarchy(String hierarchyName, String hierarchyInformationId){
        try{
            Hierarchy_Information__c hierarchyInformation = new Hierarchy_Information__c();
            hierarchyInformation.Id = hierarchyInformationId;
            hierarchyInformation.Hierarchy_Name__c = hierarchyName;
            
            UPDATE hierarchyInformation;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static String updateInfluenceJSON(String influenceJson, String hierarchyInformationId){
        
        Savepoint sp = Database.setSavepoint();
        try{
            Hierarchy_Information__c hierarchyInformtionToUpdate = new Hierarchy_Information__c();
            hierarchyInformtionToUpdate.Id = hierarchyInformationId;
            hierarchyInformtionToUpdate.Influence__c = influenceJson;
            
            Update hierarchyInformtionToUpdate;
            
            return influenceJson;
            
        }catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
        
    }
    
    @AuraEnabled
    public static String updateConflictJSON(String conflictJson, String hierarchyInformationId){
        
        Savepoint sp = Database.setSavepoint();
        try{
            Hierarchy_Information__c hierarchyInformtionToUpdate = new Hierarchy_Information__c();
            hierarchyInformtionToUpdate.Id = hierarchyInformationId;
            hierarchyInformtionToUpdate.Conflict__c = conflictJson;
            
            Update hierarchyInformtionToUpdate;
            
            return conflictJson;
            
        }catch (DMLException e) {
            Database.rollback(sp);
            throw new DMLException(e.getDmlMessage(0));
            
        }catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());  
        }
        
    }
    
    
    @AuraEnabled
    public static list<Hierarchy_Information__c> getInfluenceAndConflictDetails(Id hierarchyInformationId){
        list<Hierarchy_Information__c> hierarchyList = new list<Hierarchy_Information__c>();
        try{
			hierarchyList = [SELECT Id, Opportunity__c, 
                             Account__c, Hierarchy_Name__c,
                             Influence__c, Conflict__c
                             FROM Hierarchy_Information__c 
                             WHERE Id= :hierarchyInformationId];
            return hierarchyList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static String deleteInfluenceConflictLine(Id hierarchyInformationId, String lineIdToDelete, String lineType){
        try{
            String updatedJson;
			Hierarchy_Information__c hierarchyInformtionToUpdate = [SELECT Id, In_Use_Structure__c, Opportunity__c, Account__c, Influence__c, Conflict__c FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];
			if(lineType == 'Influence'){
                List<InfluenceAndConflictWrapper> influenceList = (List<InfluenceAndConflictWrapper>)JSON.deserialize(hierarchyInformtionToUpdate.Influence__c,List<InfluenceAndConflictWrapper>.Class);
			
            	List<InfluenceAndConflictWrapper> updatedInfluenceList = new List<InfluenceAndConflictWrapper>();
            	for(InfluenceAndConflictWrapper wrap : influenceList){
                	if(wrap.id != lineIdToDelete){
                    	updatedInfluenceList.add(wrap);
                	}
            	}
            	String updatedInfluenceJSON;
                if(!updatedInfluenceList.isEmpty()){
					updatedInfluenceJSON = JSON.serialize(updatedInfluenceList);
                }
            	hierarchyInformtionToUpdate.Influence__c = updatedInfluenceJSON;
                updatedJson = updatedInfluenceJSON;
            }
            else{
                List<InfluenceAndConflictWrapper> conflictList = (List<InfluenceAndConflictWrapper>)JSON.deserialize(hierarchyInformtionToUpdate.Conflict__c,List<InfluenceAndConflictWrapper>.Class);
			
            	List<InfluenceAndConflictWrapper> updatedconflictList = new List<InfluenceAndConflictWrapper>();
            	for(InfluenceAndConflictWrapper wrap : conflictList){
                	if(wrap.id != lineIdToDelete){
                    	updatedconflictList.add(wrap);
                	}
            	}
                String updatedConflictJSON;
                if(!updatedconflictList.isEmpty()){
					updatedConflictJSON = JSON.serialize(updatedconflictList);
                }
            	hierarchyInformtionToUpdate.Conflict__c = updatedConflictJSON;
                updatedJson = updatedConflictJSON;
            }       
            
            Update hierarchyInformtionToUpdate;
            
            return updatedJson;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    public class InfluenceAndConflictWrapper {
        
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String source {get; set;}
        @AuraEnabled public String target {get; set;}
    }
}
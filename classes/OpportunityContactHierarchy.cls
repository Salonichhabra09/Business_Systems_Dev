public with sharing class OpportunityContactHierarchy {
    
    @AuraEnabled
    public static void updateHierarchyOnDelete(List<HierarchyWrapper> hierarchyList, Id hierarchyInformationId, List<Contact> contactsToUpdate, Id contactToDelete){
        
        System.debug(hierarchyInformationId);
        System.debug(hierarchyList.size());
        Savepoint sp = Database.setSavepoint();
        try{
            Hierarchy_Information__c hierarchyInformtionToUpdate = [SELECT Id, In_Use_Structure__c, Opportunity__c FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];
  
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
          
            
            if(!contactsToUpdate.isEmpty()){
                for(Contact con : contactsToUpdate){
                    con.AutomationBypassDateTime__c = System.now();
                    System.debug(con.Id);
                }
                Update contactsToUpdate;
            }
            
            if(contactToDelete != null){
                List<OpportunityContactRole> contactRolesToDelete = [SELECT Id FROM OpportunityContactRole WHERE ContactId =:contactToDelete AND OpportunityId = :hierarchyInformtionToUpdate.Opportunity__c];
            	Delete contactRolesToDelete;          
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
    public static void updateHierarchyOnReplace(List<HierarchyWrapper> hierarchyList, 
                                                Id hierarchyInformationId, 
                                                String replacedId, 
                                                Contact contactToReplace, 
                                                List<Contact> contactsToUpdate,
                                                String contactToDelete,
                                               String jobRoleOfContactToReplace){//Change Id to String for placeholder conversion
        
        System.debug(hierarchyInformationId);
        System.debug(hierarchyList.size());
                                                   System.debug('replacedId '+replacedId);
        System.debug('!!contactToReplace' +contactToReplace?.Id + ' ' + contactToReplace?.Name);
		System.debug('!!contactToDelete' +contactToDelete);
        for(Contact con : contactsToUpdate){
             System.debug('!!con' +con.Id + ' ' + con.Name);
       }                                           
		Savepoint sp = Database.setSavepoint();
        try{
            Boolean createBlankRole = true;
            Hierarchy_Information__c hierarchyInformtionToUpdate = [SELECT Id, In_Use_Structure__c, Opportunity__c FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];
			list<OpportunityContactRole> newContactRoleListToInsert = new list<OpportunityContactRole>();
            if(contactToReplace!= null){
                contactToReplace.AutomationBypassDateTime__c = System.now();
                Insert contactToReplace;
                
                System.debug('jobRoleOfContactToReplace '+jobRoleOfContactToReplace);
                if(String.isNotBlank(jobRoleOfContactToReplace)){
                    List<String> rolesToInsertList = jobRoleOfContactToReplace?.split(';');
                    for (String roleToUse : rolesToInsertList) {
                        OpportunityContactRole newContactRole = new OpportunityContactRole();
                        newContactRole.ContactId = contactToReplace.Id;
                        newContactRole.OpportunityId = hierarchyInformtionToUpdate.Opportunity__c;
                        newContactRole.Role = roleToUse.trim();
                        newContactRoleListToInsert.add(newContactRole);
                    }
                }
                
                if(!newContactRoleListToInsert.isEmpty())
                	Insert newContactRoleListToInsert;
            }
            if(contactToReplace == null){
                List<OpportunityContactRole> rolesOnExistingContact = [SELECT Id, Role, ContactId, Contact.Job_Function__c, Contact.Name 
                                                          FROM OpportunityContactRole 
                                                          WHERE OpportunityId = :hierarchyInformtionToUpdate.Opportunity__c 
                                                          AND ContactId = :replacedId];
                if(!rolesOnExistingContact.isEmpty()){
                    createBlankRole = false;
                }
            }
            HierarchyWrapper rootNode = new HierarchyWrapper();
            Map<String, HierarchyWrapper> hierarchyMap = new Map<String, HierarchyWrapper>();
            //HierarchyWrapper rootNode = null;
            System.debug('@@@Node replacedId '+ replacedId);
            // Populate map for quick lookup
            for (HierarchyWrapper node : hierarchyList) {
                System.debug('@@@Node Node Id for Map '+ node.Id);
                System.debug('@@@Node Node ReportsTo for Map '+ node.ReportsTo);
                if(node.Id == replacedId && contactToReplace !=null){
                    contactToReplace.ReportsToId = node.ReportsTo =='rootlevel' || node.ReportsTo.contains('Placeholder') ? null:node.ReportsTo;
                    contactsToUpdate.add(contactToReplace);
                    node.Id = contactToReplace.Id;
                    node.IsPlaceholder = false;// added by aashi for placeholder conversion
                }
                if(node.ReportsTo == replacedId && contactToReplace !=null){
                    if(node.IsPlaceholder==false){
                        Contact con = new Contact();
                    	con.Id = node.Id;
                    	con.ReportsToId = contactToReplace.Id;
                    	contactsToUpdate.add(con);
                    }
                    node.ReportsTo = contactToReplace.Id;
                }
                hierarchyMap.put(node.Id, node);
            }
            for(String key : hierarchyMap.keySet()){
                System.debug('@@@ key '+ key);
                System.debug('@@@ key '+ hierarchyMap.get(key));
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
            System.debug('@@@jsonHierarchy '+jsonHierarchy);
            
            hierarchyInformtionToUpdate.In_Use_Structure__c = jsonHierarchy;
            newContactRoleListToInsert = new list<OpportunityContactRole>();
            if(createBlankRole && replacedId != null && replacedId != 'newIdToReplace'){
      			if(String.isNotBlank(jobRoleOfContactToReplace)){
                    List<String> rolesToInsertList = jobRoleOfContactToReplace?.split(';');
                    for (String roleToUse : rolesToInsertList) {
                        OpportunityContactRole newContactRole = new OpportunityContactRole();
                        newContactRole.ContactId = replacedId;
                        newContactRole.OpportunityId = hierarchyInformtionToUpdate.Opportunity__c;
                        newContactRole.Role = roleToUse.trim();
                        newContactRoleListToInsert.add(newContactRole);
                    }
                }
                if(!newContactRoleListToInsert.isEmpty())
                	Insert newContactRoleListToInsert;
            }
            List<Contact> updateToClearReportsTo = new List<Contact>();
            System.debug(contactsToUpdate);
            if(!contactsToUpdate.isEmpty()){
                for(Contact con : contactsToUpdate){
                    Contact newCon = new Contact();
                    newCon.Id = con.Id;
                    newCon.AutomationBypassDateTime__c = System.now();
                    newCon.ReportsToId = null;
                    updateToClearReportsTo.add(newCon);
                    System.debug(con.Id);
                }
                Update updateToClearReportsTo;
            }
            System.debug(contactsToUpdate);
            if(!contactsToUpdate.isEmpty()){
                for(Contact con : contactsToUpdate){
                    con.AutomationBypassDateTime__c = System.now();
                    System.debug(con.Id);
                }
                Update contactsToUpdate;
            }
            
            if(contactToDelete != null && contactToDelete.startsWith('003')){// added by aashi for placeholder conversion
            	List<OpportunityContactRole> contactRolesToDelete = [SELECT Id FROM OpportunityContactRole WHERE ContactId =:contactToDelete AND OpportunityId = :hierarchyInformtionToUpdate.Opportunity__c];
            	Delete contactRolesToDelete;    
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
    public static void updateHierarchyOnReparent(List<HierarchyWrapper> hierarchyList, Id hierarchyInformationId, Id newReportsToId, Id currentNodeId, Boolean isAddedToTopNode, List<Contact> contactsToUpdate){
        
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
            
            if((newReportsToId != null && currentNodeId !=null) || newReportsToId == null && isAddedToTopNode == true && currentNodeId!=null){
      			Contact contactToUpdate = new Contact();
                contactToUpdate.Id = currentNodeId;
                contactToUpdate.ReportsToId = newReportsToId;
                contactToUpdate.AutomationBypassDateTime__c = System.now();
                contactsToUpdate.add(contactToUpdate);
            }
            
            List<Contact> updateToClearReportsTo = new List<Contact>();
            System.debug(contactsToUpdate);
            if(!contactsToUpdate.isEmpty()){
                for(Contact con : contactsToUpdate){
                    Contact newCon = new Contact();
                    newCon.Id = con.Id;
                    newCon.AutomationBypassDateTime__c = System.now();
                    newCon.ReportsToId = null;
                    updateToClearReportsTo.add(newCon);
                    System.debug(con.Id);
                }
                Update updateToClearReportsTo;
            }
            System.debug(contactsToUpdate);
            if(!contactsToUpdate.isEmpty()){
                for(Contact con : contactsToUpdate){
                    con.AutomationBypassDateTime__c = System.now();
                    System.debug(con.Id);
                }
                Update contactsToUpdate;
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
    
    @AuraEnabled(cacheable=true)
    public static List<Hierarchy_Information__c> getHierarchyInformationOfOpportunity(Id opportunityId){
        
        List<Hierarchy_Information__c> hierarchyInformationOfOpportunity = [SELECT Id, Name, LastModifiedBy.FirstName,LastModifiedBy.LastName,LastModifiedDate, CreatedDate FROM Hierarchy_Information__c WHERE Opportunity__c =:opportunityId];
        
        return hierarchyInformationOfOpportunity;
    }
    
    @AuraEnabled
    public static void deleteHierarchy(Id hierarchyInformationId){
        
        List<Hierarchy_Information__c> hierarchyInformationToDelete = [SELECT Id FROM Hierarchy_Information__c WHERE Id = :hierarchyInformationId];
        
        Delete hierarchyInformationToDelete;
    }
    
    @AuraEnabled
    public static String createHierarchyOnOpportunity(Id opportunityId, String hierarchyType){
        
        String hierarchyInformationId = '';
        try{
            List<Opportunity> opportunityList = [SELECT Id, Account.Name, OpportunityId__c 
                                                 FROM Opportunity 
                                                 WHERE Id =:opportunityId];
            
            List<HierarchyWrapper> hierarchyList = new List<HierarchyWrapper>();
            HierarchyWrapper rootNode = new HierarchyWrapper();
            rootNode.Id = 'rootlevel';
            rootNode.Name = opportunityList[0].OpportunityId__c;
            rootNode.IsPlaceholder = false;
            rootNode.Children = new List<HierarchyWrapper>();
            hierarchyList.add(rootNode);
            
            System.debug(hierarchyType);
            
            if(hierarchyType == 'Default Heirarchy'){
                
                List<OpportunityContactRole> opportunityContactRoleList = [SELECT Id, Role, ContactId, Contact.ReportsToId, Contact.Name 
                                                                           FROM OpportunityContactRole 
                                                                           WHERE OpportunityId =:opportunityId];
                
                Map<Id,String> contactMap = new Map<Id,String>();
                Set<Id> contactIds = new Set<Id>();
                
                for(OpportunityContactRole contactRole : opportunityContactRoleList){
                    if(contactMap.get(contactRole.ContactId)!=null){
                        String combinedRole = contactMap.get(contactRole.ContactId) + ',' + contactRole.Role;
                        contactMap.put(contactRole.ContactId,combinedRole);
                    }else{
                        contactMap.put(contactRole.ContactId,contactRole.Role);
                    }
                }
                
                for(OpportunityContactRole contactRole : opportunityContactRoleList){
                    if(!contactIds.contains(contactRole.ContactId)){
                        HierarchyWrapper hierarchyNode = new HierarchyWrapper();
                        
                        hierarchyNode.Id = contactRole.ContactId;
                        //hierarchyNode.ReportsTo = contactMap.keySet().contains(contactRole.Contact.ReportsToId) ? contactRole.Contact.ReportsToId : 'rootlevel';
                        if(contactMap.keySet().contains(contactRole.Contact.ReportsToId)==true){
                            hierarchyNode.ReportsTo = contactRole.Contact.ReportsToId;
                        }else{
                            hierarchyNode.ReportsTo = 'rootlevel';
                        }
                        hierarchyNode.Name = contactRole.Contact.Name;
                        //hierarchyNode.JobRole = contactMap.get(contactRole.ContactId);
                        hierarchyNode.IsPlaceholder = false;
                        hierarchyNode.Children = new List<HierarchyWrapper>();
                        //hierarchyNode.Children List<HierarchyWrapper>
                        
                        hierarchyList.add(hierarchyNode);
                        contactIds.add(contactRole.ContactId);
                    }
                }    
            }
            
             
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
            hierarchyInformation.Opportunity__c = opportunityId;
            
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
            List<Hierarchy_Information__c> hierarchyInformation = [SELECT Id, In_Use_Structure__c, Opportunity__r.Name, Opportunity__c FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];
            String jsonString = hierarchyInformation[0].In_Use_Structure__c;
            Integer totalPlaceholders = 0;
            /*String jsonString = '{' +
'"id": "1",' +
'"name": "Parent",' +
'"children": [' +
'{' +
'"id": "2",' +
'"name": "Child 1",' +
'"children": [' +
'{' +
'"id": "3",' +
'"name": "Child 1.1"' +
'},' +
'{' +
'"id": "4",' +
'"name": "Child 1.2"' +
'}' +
']' +
'},' +
'{' +
'"id": "5",' +
'"name": "Child 2"' +
'}' +
']' +
'}';*/
            
            HierarchyWrapper rootNode = (HierarchyWrapper) JSON.deserialize(jsonString, HierarchyWrapper.class);
            flatList = flattenHierarchy(rootNode);
            Map<Id,OpportunityContactRole> opportunityContactRoleMap = new Map<Id,OpportunityContactRole>();
            List<OpportunityContactRole> contactRoleList = [SELECT Id, Role, ContactId, Contact.Job_Function__c, Contact.Name, Contact.Contact_Status__c
                                                                           FROM OpportunityContactRole 
                                                                           WHERE OpportunityId =:hierarchyInformation[0].Opportunity__c];
            System.debug('@@@contactRoleList Size '+contactRoleList.size());    
            	
            for(OpportunityContactRole role : contactRoleList){
                opportunityContactRoleMap.put(role.ContactId,role);
            }
            System.debug('@@@opportunityContactRoleMap Size '+opportunityContactRoleMap.size());    
                Map<Id,String> contactRoleMap = new Map<Id,String>();
                
            //for(OpportunityContactRole contactRole : opportunityContactRoleMap.values()){
            for(OpportunityContactRole contactRole : contactRoleList){// Replaced by Aashi
                System.debug('@@@contactRole '+contactRole.Role);  
                System.debug('@@@contactRole Name '+contactRole.Contact.Name); 
                if(contactRole.Role != null){
                    if(contactRoleMap.containsKey(contactRole.ContactId)){// Replaced by Aashi
                        String combinedRole = contactRoleMap.get(contactRole.ContactId) + ',' + contactRole.Role;
                        System.debug('@@@2contactRoleMap '+contactRoleMap.get(contactRole.ContactId));  
                        contactRoleMap.put(contactRole.ContactId,combinedRole);
                        System.debug('@@@3contactRoleMap '+contactRoleMap.get(contactRole.ContactId));  
                    }else{
                        contactRoleMap.put(contactRole.ContactId,contactRole.Role);
                        System.debug('@@@1contactRoleMap '+contactRoleMap.get(contactRole.ContactId));  
                    }
                }
            }
            Set<Id> contactIds = new Set<Id>();
            for (HierarchyWrapper node : flatList) {
                if(node.IsPlaceholder == true){
                    String placeholderNumber = node.Id.substringAfter('Placeholder');
                    if(totalPlaceholders < Integer.valueOf(placeholderNumber)){
                        totalPlaceholders = Integer.valueOf(placeholderNumber);
                    }
                }else if(node.Id != 'rootlevel' && opportunityContactRoleMap.containsKey(node.Id)){
                    node.JobRole = contactRoleMap.get(node.Id);
                    node.JobFunction = opportunityContactRoleMap.get(node.Id).Contact.Job_Function__c;
                    // Set IsActive flag based on the Contact's Contact_Status__c field
                    if(opportunityContactRoleMap.get(node.Id).Contact.Contact_Status__c == 'Active'){
                        node.IsActive = true;
                    } else {
                        node.IsActive = false;
                    }
                    node.Name = opportunityContactRoleMap.get(node.Id).Contact.Name;
                    System.debug(node);
                }
        	}
            System.debug(totalPlaceholders);
            hierarchyDetails.HierarchyList = flatList;
            hierarchyDetails.TotalPlaceholders = totalPlaceholders; //==null?0:totalPlaceholders;
            hierarchyDetails.OpportunityName = hierarchyInformation[0].Opportunity__r.Name;
            hierarchyDetails.OpportunityUrl = URL.getOrgDomainUrl() + '/' + hierarchyInformation[0].Opportunity__c;
                     
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
        @AuraEnabled public String OpportunityName {get; set;}
        @AuraEnabled public String OpportunityUrl {get; set;}
    }
    
    public class HierarchyWrapper {
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public String ReportsTo {get; set;}
        @AuraEnabled public String JobRole {get; set;}
        @AuraEnabled public String JobFunction {get; set;}
        @AuraEnabled public Boolean IsPlaceholder {get; set;}
        @AuraEnabled public Boolean IsActive {get; set;}
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
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunityDetails(String oppName){
        List<Opportunity> opportunityRecord = new List<Opportunity>();
        try{
            opportunityRecord = [SELECT Id, Name, AccountId FROM Opportunity WHERE OpportunityId__c =:oppName];
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return opportunityRecord;
    }
    
    @AuraEnabled
    public static String createContactRoleRecords(list<OpportunityContactRole> contactRoleList){
        String message ;
        try{
            insert contactRoleList; // New contact role is created
            message = 'Success';
        }
        catch(DMLException e){
            message = e.getDmlMessage(0);
        }
        catch(Exception ex){
            message = ex.getMessage();
        }
        return message;
    }
    
    public class GetContactWrapper{
        @AuraEnabled public list<Contact> contacts { get; set; }
        @AuraEnabled public String message { get; set; }
    }
    
    @AuraEnabled
    public static GetContactWrapper getActiveContactsOfHierarchyAccount(Integer offSetValue, String filterValue, list<Id> currentContactIdsInHierarchy, String accountId){
        list<Contact> contactList = new list<Contact>();
        GetContactWrapper wrapper = new GetContactWrapper();
        String message;
        try{
            String baseQuery = 'SELECT Id, Name, Job_Function__c, Email, Phone, Title, ' +
                'Job_Level__c, AccountId, Account.Name, ReportsToId, ReportsTo.Name ' +
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
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static GetContactWrapper getActiveContacts(Integer offSetValue, String filterValue, list<Id> currentContactIdsInHierarchy, String accountId, Boolean isNotReplace){
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
                if(contactListFromAccount.size() < 10){ 
                    fetchOtherAccounts = true; 
                }
            }else{
                fetchOtherAccounts = true; 
            }
            if(fetchOtherAccounts){
                String baseQuery = 'SELECT Id, Name, Job_Function__c, Email, Phone, Title, ' +
                    'Job_Level__c, AccountId, Account.Name, ReportsToId, ReportsTo.Name ' +
                    'FROM Contact WHERE Contact_Status__c = \'active\' AND AccountId != null ';
                
                if (!isNotReplace && currentContactIdsInHierarchy != null) {
                    baseQuery += 'AND Id NOT IN :currentContactIdsInHierarchy ';
                }
                if (!String.isBlank(filterValue)) {
                    filterValue = '%' + filterValue + '%';
                    baseQuery += 'AND (Name LIKE :filterValue OR Account.Name LIKE :filterValue) ';
                }else{
                    baseQuery += 'AND AccountId != :accountId ';
                }
                baseQuery += 'ORDER BY Name LIMIT 10 OFFSET :offSetValue';
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
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createContactRecords(List<ContactWrapper> contactList, String oppId, String hierarchyInformationId, String parentNodeId, list<HierarchyWrapper> allNodes) {
        List<Contact> contactsToInsert = new List<Contact>();
        List<OpportunityContactRole> rolesToInsert = new List<OpportunityContactRole>();
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
                ReportsToId = parentNodeId =='rootlevel' || parentNodeId.contains('Placeholder') ? null:parentNodeId,
                AutomationBypassDateTime__c = System.now()
            );
            contactsToInsert.add(newContact);
        }
        
        try {
            insert contactsToInsert;
            
            for (Integer i = 0; i < contactsToInsert.size(); i++) {
                
                // Create OpportunityContactRole record
                if(contactList[i].role != null && contactList[i].role.contains(';')){
                    for (String roleToUse : contactList[i].role.split(';')) {
                        OpportunityContactRole newRole = new OpportunityContactRole();
                        newRole.OpportunityId = oppId;
                        newRole.ContactId = contactsToInsert[i].Id; 
                        newRole.Role = roleToUse.trim();           
                        rolesToInsert.add(newRole);
                    }
                }
                else{
                    OpportunityContactRole newRole = new OpportunityContactRole(
                        ContactId = contactsToInsert[i].Id,
                        OpportunityId = oppId,
                        Role = contactList[i].role
                    );
                    rolesToInsert.add(newRole); 
                }
                
                //Update Hierarchy
                HierarchyWrapper newNodeToAdd = new HierarchyWrapper();
                newNodeToAdd.ReportsTo = parentNodeId;
                newNodeToAdd.Name = contactList[i].firstName + ' ' + contactList[i].lastName;
                newNodeToAdd.JobRole = contactList[i].role;
                newNodeToAdd.IsPlaceholder = false;
                newNodeToAdd.Id = contactsToInsert[i].Id;
                
                newNodeList.add(newNodeToAdd);
            }
            insert rolesToInsert;
            
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
    
    @AuraEnabled
    public static void updateHierarchyOnExistingContactSelection(List<ContactWrapper> contactList, String oppId, String hierarchyInformationId, String parentNodeId, list<HierarchyWrapper> allNodes) {
        List<Contact> contactsToUpdate = new List<Contact>();
        List<OpportunityContactRole> rolesToInsert = new List<OpportunityContactRole>();
        Map<Id,OpportunityContactRole> opportunityContactRoleMap = new Map<Id,OpportunityContactRole>();
        list<Id> contactIdsList = new list<Id>();
        Savepoint sp = Database.setSavepoint();
        for (ContactWrapper wrapper : contactList) {
            // Update Contact record
            Contact contactRecord = new Contact(
                Id = wrapper.id,
                ReportsToId = parentNodeId =='rootlevel' || parentNodeId.contains('Placeholder') ? null:parentNodeId,
                AutomationBypassDateTime__c = System.now()
            );
            contactsToUpdate.add(contactRecord);
            contactIdsList.add(contactRecord.Id);
        }
        try { 
            UPDATE contactsToUpdate;
            
            List<OpportunityContactRole> existingContactRoleListOnOpp = [SELECT Id, Role, ContactId, Contact.Job_Function__c, Contact.Name, Contact.Contact_Status__c
                                                            FROM OpportunityContactRole 
                                                            WHERE OpportunityId = :oppId
                                                            AND ContactId IN :contactIdsList];
            Set<String> existingContactRoleKeys = new Set<String>();
            for (OpportunityContactRole existingRole : existingContactRoleListOnOpp) {
                existingContactRoleKeys.add(existingRole.ContactId + '-' + existingRole.Role);
            }
            
            // Create OpportunityContactRole record
            for (Integer i = 0; i < contactList.size(); i++) {
                if(contactList[i].role != null && contactList[i].role.contains(';')){
                    for (String roleToUse : contactList[i].role.split(';')) {
                        String newRoleKey = contactList[i].id + '-' + roleToUse.trim();
                        if (!existingContactRoleKeys.contains(newRoleKey)) {
                            OpportunityContactRole newRole = new OpportunityContactRole();
                            newRole.OpportunityId = oppId;
                            newRole.ContactId = contactList[i].id; 
                            newRole.Role = roleToUse.trim();           
                            rolesToInsert.add(newRole);
                            existingContactRoleKeys.add(newRoleKey);
                        } 
                    }
                }
                else{
                    String newRoleKey = contactList[i].id + '-' + contactList[i].role;
                    if (!existingContactRoleKeys.contains(newRoleKey)) {
                        OpportunityContactRole newRole = new OpportunityContactRole(
                            ContactId = contactList[i].id,
                            OpportunityId = oppId,
                            Role = contactList[i].role
                        );
                        rolesToInsert.add(newRole); 
                        existingContactRoleKeys.add(newRoleKey);
                    } 
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
    
    @AuraEnabled
    public static void updateContactRole(String newroleToInsert, String oldroleToDelete, List<HierarchyWrapper> hierarchyList, Id hierarchyInformationId, String contactId){
        List<OpportunityContactRole> rolesToInsert = new List<OpportunityContactRole>();
        List<String> listOfroles = new List<String>();
        Savepoint sp = Database.setSavepoint();
        try{
            Hierarchy_Information__c hierarchyInformtionToUpdate = [SELECT Id, In_Use_Structure__c, Opportunity__c FROM Hierarchy_Information__c WHERE Id =:hierarchyInformationId];
            if(String.isNotBlank(oldRoleToDelete)){
                listOfroles = oldroleToDelete?.split(';');
            }
            //if(!listOfroles.isEmpty()){
            List<OpportunityContactRole> rolesToDelete = [SELECT Id, Role, ContactId, Contact.Job_Function__c, Contact.Name 
                                                          FROM OpportunityContactRole 
                                                          WHERE OpportunityId = :hierarchyInformtionToUpdate.Opportunity__c 
                                                          AND ContactId = :contactId AND (Role IN :listOfroles OR Role = null)];
            if(!rolesToDelete.isEmpty())
                DELETE rolesToDelete; // Deleting contact role
            //}
            if(String.isNotBlank(newRoleToInsert)){
                List<String> rolesToInsertList = newRoleToInsert.split(';');
                for (String roleToUse : rolesToInsertList) {
                    System.debug('roleToUse '+roleToUse);
                    OpportunityContactRole newRole = new OpportunityContactRole();
                    newRole.OpportunityId = hierarchyInformtionToUpdate.Opportunity__c;
                    newRole.ContactId = contactId; 
                    newRole.Role = roleToUse.trim();   
                    rolesToInsert.add(newRole);
                }
            }
            if (!rolesToInsert.isEmpty())
                INSERT rolesToInsert; // New contact role is created
            
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
        
        public ContactWrapper() {
        }
        // Constructor to initialize the wrapper object
        public ContactWrapper(Integer index, String id, String salutation, String firstName, String lastName, String accountId, String email, String jobFunction, String advocacyLevel, String title, String role, String phone) {
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
        }
    }
    
}
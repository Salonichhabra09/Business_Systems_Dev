@isTest
private class TerritoryTriggerManager_Tester {
    
    @testSetup
    static void setup() {
        
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');  
        
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createTriggerActivationCustomSettingRecords('Territory__c', 'Territory_Trigger');
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityLineItem', 'OpportunityLineItem_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        createTriggerActivationCustomSettingRecords('Order', 'Order_Trigger');
        createTriggerActivationCustomSettingRecords('ContentDocument', 'ContentDocument_Trigger');
        createTriggerActivationCustomSettingRecords('ContentDocumentLink', 'ContentDocumentLink_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Rating__c', 'MS_Rating_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Candidate__c', 'Bureau_Candidate_Trigger');
        
        User userRecord = TestDataUtility.getUser('Managed Service Lightning');
        userRecord.MS_LOB__c = 'Talent Management (Dashboards)';
        userRecord.Is_Job_Manager__c = true;
        userRecord.Is_Managed_Service_Manager__c = true;
        INSERT userRecord;
        
        Territory__c territoryRecord = TestDataUtility.getTerritory(userRecord.Id, NULL);
        INSERT territoryRecord;
        
        Account accountRecord = TestDataUtility.getAccount();
        //accountRecord.Territory__c = territoryRecord.Id;
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        // Custom Setting for Auto Job creation
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c();
        cs.Name='Values';
        cs.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        INSERT cs;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, userRecord.Id);
        opportunityRecord.Business_Type__c = 'Renewal';
        opportunityRecord.Pricebook2Id = pricebookId;
        INSERT opportunityRecord;

        Id oppPriceBookId = [SELECT Pricebook2Id FROM Opportunity WHERE Id =: opportunityRecord.Id].Pricebook2Id;
        
        // First Product
        Product2 productRecord = TestDataUtility.getProduct2();
        productRecord.Revenue_Category__c='Managed Services';
        productRecord.Renewable__c = 'No';
        productRecord.MS_Product__c = true;
        productRecord.MS_Type__c = 'Talent Management';
        productRecord.Family = 'Services';
        INSERT productRecord;
        
        PricebookEntry pricebookEntryRecord1 = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord1;
        
        PricebookEntry pricebookEntryRecord = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', oppPriceBookId);
        INSERT pricebookEntryRecord;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Quantity = 5,
            PricebookEntryId = pricebookEntryRecord.Id,
            TotalPrice = 10 * pricebookEntryRecord.UnitPrice
        );
        insert oli;
                
        
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
    
    
    
    @isTest
    static void updateBDMOnTerritoryRecords(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        list<User> userList = [SELECT Id FROM User WHERE ProfileId = :pf.Id AND IsActive = TRUE LIMIT 5];
        
        Territory__c territoryRecord = [SELECT Id,
                                        Business_Development_Manager__c,
                                        Account_Director__c,
                                        Customer_Engagement_Manager__c,
                                        Manager_1__c,
                                        Manager_2__c,
                                        Manager_3__c,
                                        Global_Account_Director__c
                                        FROM Territory__c LIMIT 1];
        Account account = [SELECT Id, Territory__c FROM Account LIMIT 1]; 
        account.Territory__c = territoryRecord.Id;
		//UPDATE account;

        Id currentUserId = UserInfo.getUserId(); 
        territoryRecord.Business_Development_Manager__c = currentUserId;
        
        Test.startTest();
        UPDATE territoryRecord;
        Test.stopTest();
    }
    
    @isTest
    static void updateADOnTerritoryRecords(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        list<User> userList = [SELECT Id FROM User WHERE ProfileId = :pf.Id AND IsActive = TRUE LIMIT 5];
            
        Territory__c territoryRecord = [SELECT Id,
                                        Business_Development_Manager__c,
                                        Account_Director__c,
                                        Customer_Engagement_Manager__c,
                                        Manager_1__c,
                                        Manager_2__c,
                                        Manager_3__c,
                                        Global_Account_Director__c
                                        FROM Territory__c LIMIT 1];
        Account account = [SELECT Id, Territory__c FROM Account LIMIT 1]; 
        account.Territory__c = territoryRecord.Id;
        //UPDATE account;

        Id currentUserId = UserInfo.getUserId();
        territoryRecord.Account_Director__c = currentUserId;
        
        Test.startTest();
        UPDATE territoryRecord;
        Test.stopTest();
    }
    
    @isTest
    static void updateCEMOnTerritoryRecords(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        list<User> userList = [SELECT Id FROM User WHERE ProfileId = :pf.Id AND IsActive = TRUE LIMIT 5];
            
        Territory__c territoryRecord = [SELECT Id,
                                        Business_Development_Manager__c,
                                        Account_Director__c,
                                        Customer_Engagement_Manager__c,
                                        Manager_1__c,
                                        Manager_2__c,
                                        Manager_3__c,
                                        Global_Account_Director__c
                                        FROM Territory__c LIMIT 1];
        
        Account account = [SELECT Id, Territory__c FROM Account LIMIT 1]; 
        account.Territory__c = territoryRecord.Id;
        UPDATE account;

        Id currentUserId = UserInfo.getUserId();
        territoryRecord.Customer_Engagement_Manager__c = currentUserId;
        
        Test.startTest();
        UPDATE territoryRecord;
        Test.stopTest();
    }
    
    @isTest
    static void updateM1OnTerritoryRecords(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        list<User> userList = [SELECT Id FROM User WHERE ProfileId = :pf.Id AND IsActive = TRUE LIMIT 5];
            
        Territory__c territoryRecord = [SELECT Id,
                                        Business_Development_Manager__c,
                                        Account_Director__c,
                                        Customer_Engagement_Manager__c,
                                        Manager_1__c,
                                        Manager_2__c,
                                        Manager_3__c,
                                        Global_Account_Director__c
                                        FROM Territory__c LIMIT 1];
        

        Account account = [SELECT Id, Territory__c FROM Account LIMIT 1]; 
        account.Territory__c = territoryRecord.Id;
        UPDATE account;

        Id currentUserId = UserInfo.getUserId();
        territoryRecord.Manager_1__c = currentUserId;
        
        Test.startTest();
        UPDATE territoryRecord;
        Test.stopTest();
    }
    
    @isTest
    static void updateM2OnTerritoryRecords(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        list<User> userList = [SELECT Id FROM User WHERE ProfileId = :pf.Id AND IsActive = TRUE LIMIT 5];
            
        Territory__c territoryRecord = [SELECT Id,
                                        Business_Development_Manager__c,
                                        Account_Director__c,
                                        Customer_Engagement_Manager__c,
                                        Manager_1__c,
                                        Manager_2__c,
                                        Manager_3__c,
                                        Global_Account_Director__c
                                        FROM Territory__c LIMIT 1];
        
        Account account = [SELECT Id, Territory__c FROM Account LIMIT 1]; 
        account.Territory__c = territoryRecord.Id;
        UPDATE account;

        Id currentUserId = UserInfo.getUserId();
        territoryRecord.Manager_2__c = currentUserId;
        
        Test.startTest();
        UPDATE territoryRecord;
        Test.stopTest();
    }
    
    @isTest
    static void updateM3OnTerritoryRecords(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        list<User> userList = [SELECT Id FROM User WHERE ProfileId = :pf.Id AND IsActive = TRUE LIMIT 5];
            
        Territory__c territoryRecord = [SELECT Id,
                                        Business_Development_Manager__c,
                                        Account_Director__c,
                                        Customer_Engagement_Manager__c,
                                        Manager_1__c,
                                        Manager_2__c,
                                        Manager_3__c,
                                        Global_Account_Director__c
                                        FROM Territory__c LIMIT 1];
        
        Account account = [SELECT Id, Territory__c FROM Account LIMIT 1]; 
        account.Territory__c = territoryRecord.Id;
        UPDATE account;
        
        Id currentUserId = UserInfo.getUserId();
        territoryRecord.Manager_3__c = currentUserId;
        
        Test.startTest();
        UPDATE territoryRecord;
        Test.stopTest();
    }
    
    @isTest
    static void updateGADOnTerritoryRecords(){
        
        Territory__c territoryRecord = [SELECT Id,
                                        Business_Development_Manager__c,
                                        Account_Director__c,
                                        Customer_Engagement_Manager__c,
                                        Manager_1__c,
                                        Manager_2__c,
                                        Manager_3__c,
                                        Global_Account_Director__c
                                        FROM Territory__c LIMIT 1];
        
        Account account = [SELECT Id, Territory__c FROM Account LIMIT 1]; 
        account.Territory__c = territoryRecord.Id;
        UPDATE account;
        
        Id currentUserId = UserInfo.getUserId();
        territoryRecord.Global_Account_Director__c = currentUserId;
        
        Test.startTest();
        UPDATE territoryRecord;
        Test.stopTest();
    }

    @isTest
    static void updateNullOnTerritoryRecords(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        list<User> userList = [SELECT Id FROM User WHERE ProfileId = :pf.Id AND IsActive = TRUE LIMIT 5];
            
        Territory__c territoryRecord = [SELECT Id,
                                        Business_Development_Manager__c,
                                        Account_Director__c,
                                        Customer_Engagement_Manager__c,
                                        Manager_1__c,
                                        Manager_2__c,
                                        Manager_3__c,
                                        Global_Account_Director__c
                                        FROM Territory__c LIMIT 1];
        
        Account account = [SELECT Id, Territory__c FROM Account LIMIT 1]; 
        account.Territory__c = territoryRecord.Id;
        //UPDATE account;
        
        Id currentUserId = UserInfo.getUserId();
        territoryRecord.Business_Development_Manager__c = currentUserId;
        territoryRecord.Account_Director__c = currentUserId;
        territoryRecord.Customer_Engagement_Manager__c = currentUserId;
        territoryRecord.Manager_1__c = currentUserId;
        territoryRecord.Manager_2__c = currentUserId;
        territoryRecord.Manager_3__c = currentUserId;
        UPDATE territoryRecord;
        
        //territoryRecord.Business_Development_Manager__c = NULL;
        //territoryRecord.Account_Director__c = NULL;
        territoryRecord.Customer_Engagement_Manager__c = NULL;
        territoryRecord.Manager_1__c = NULL;
        territoryRecord.Manager_2__c = NULL;
        territoryRecord.Global_Account_Director__c = NULL;
        
        Test.startTest();
        UPDATE territoryRecord;
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteExistingAccountTeams(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        list<User> userList = [SELECT Id FROM User WHERE ProfileId = :pf.Id AND IsActive = TRUE LIMIT 5];
            
        Territory__c territoryRecord = [SELECT Id,
                                        Business_Development_Manager__c,
                                        Account_Director__c,
                                        Customer_Engagement_Manager__c,
                                        Manager_1__c,
                                        Manager_2__c,
                                        Manager_3__c,
                                        Global_Account_Director__c
                                        FROM Territory__c LIMIT 1];
        
        Account account = [SELECT Id, Territory__c FROM Account LIMIT 1]; 
        account.Territory__c = territoryRecord.Id;
        //UPDATE account;
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<Id, Territory__c> territoryMap = new Map<Id, Territory__c>();
        
        accountMap.put(account.Id, account);
        territoryMap.put(territoryRecord.Id, territoryRecord);
    
        Test.startTest();
        AddAccountTeamMember.deleteExistingAccountTeams(new Set<Id>{account.Id});
        AddAccountTeamMember.buildAccountTeamMembers(accountMap, territoryMap);
        Test.stopTest();
        
    }
}
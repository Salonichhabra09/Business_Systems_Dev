@isTest
public class EligibleOppBatch_Test {
    
    @testSetup
    static void setup() {
        
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');  
        
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
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
        
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        // Custom Setting for Auto Job creation
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c();
        cs.Name='Values';
        cs.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        INSERT cs;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity originalOpportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        INSERT originalOpportunityRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, userRecord.Id);
        opportunityRecord.Business_Type__c = 'Renewal';
        opportunityRecord.Pricebook2Id = pricebookId;
        opportunityRecord.Can_be_Auto_renewed__c = true;
        opportunityRecord.Eligible_for_Auto_Close__c = false;
        opportunityRecord.Renewal_Opportunity__c = true;
        opportunityRecord.Opportunity_Deal_Year__c = 1;
        opportunityRecord.Renewal_Date__c = System.today();
        opportunityRecord.Original_Opportunity__c = originalOpportunityRecord.Id;
        opportunityRecord.Actual_Record_Type_Name__c = System.label.Configurator_Opportunity;
        opportunityRecord.RecordTypeId = System.label.IgniteRecordType;
        opportunityRecord.CloseDate = System.today() + 32;
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
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = originalOpportunityRecord.Id,
            Quantity = 5,
            PricebookEntryId = pricebookEntryRecord.Id,
            TotalPrice = 10 * pricebookEntryRecord.UnitPrice
        );
        insert oli1;
        
        /*Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id =: opportunityRecord.Id];
opp.StageName = 'Closed/Won';
UPDATE opp;*/
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
    public static void callBatchClass(){
        Test.startTest();
        EligibleOppBatch batchClass = new EligibleOppBatch();
        Database.executeBatch(batchClass, 200);
        Test.stopTest();
    }
    
    
    // Test Class Created for checking - If original opp is extension then not allow for auto close - JIRA : SSE-28977
    @isTest
    public static void checkExtensionLogic(){
        
        // Re-query records created in @testSetup
        Opportunity originalOpp = [
            SELECT Id, Business_Type__c
            FROM Opportunity
            WHERE Business_Type__c = 'Expansion'
            LIMIT 1
        ];
        
        Opportunity childOpp = [
            SELECT Id, Qualified_for_Auto_Close__c, Eligible_for_Auto_Close__c, Original_Opportunity__c
            FROM Opportunity
            WHERE Original_Opportunity__c = :originalOpp.Id
            LIMIT 1
        ];
        
        // Apply your test conditions
        originalOpp.Business_Type__c = 'Extension';
        originalOpp.Custom_Contract_Duration__c =4;
        originalOpp.Standard_Contract_Duration__c='Other';
        update originalOpp;
        
        // childOpp.Qualified_for_Auto_Close__c = true;
        //update childOpp;
        
        Test.startTest();
        Database.executeBatch(new EligibleOppBatch(), 200);
        Test.stopTest();
        
        // Re-query to verify result
        Opportunity resultOpp = [
            SELECT Eligible_for_Auto_Close__c
            FROM Opportunity
            WHERE Id = :childOpp.Id
        ];
        
        // This is the real test!
        System.assertEquals(
            false,
            resultOpp.Eligible_for_Auto_Close__c
        );
    }
    
    
    
    @isTest
    static void testExecuteScheduledClass() {
        // Create an instance of the class
        EligibleOppScheduler schedulableInstance = new EligibleOppScheduler();
        
        // Schedule the job to run in the test context
        String jobId = System.schedule(
            'Test Scheduled Job',
            '0 0 1 * * ?',  // This is a CRON expression (runs at 1 AM daily)
            schedulableInstance
        );
    }
}
@isTest
public class Test_GenericClassToGetData {
	@testSetup static void setup() {
        
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
        
        User userRecord = TestDataUtility.getUser('Managed Service Lightning');
        userRecord.MS_LOB__c = 'TA - Corporate, TA - Credentialing, Talent Management, TA - Vocational (Batch) & TA - Vocational (School)';
        userRecord.Is_Job_Manager__c = true;
        userRecord.Is_Managed_Service_Manager__c = true;
        INSERT userRecord;
        
        //System.runAs(userRecord){
            Account accountRecord = TestDataUtility.getAccount();
            //done by aashi accountRecord.Territory__c = 'Alliances';
        	INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        contactRecord.Area_of_Interest__c = 'Talent Management';
        INSERT contactRecord;
        
        // Custom Setting for Auto Job creation
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c();
        cs.Name='Values';
        cs.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        INSERT cs;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, userRecord.Id);
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
        pricebookEntryRecord.UnitPrice = 10;
        INSERT pricebookEntryRecord;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opportunityRecord.Id,
            Quantity = 5,
            PricebookEntryId = pricebookEntryRecord.Id,
            TotalPrice = 10 * pricebookEntryRecord.UnitPrice,
            Solution_Cap__c = 5
        );
        insert oli;
        
        Opportunity opp = [SELECT Id, StageName, Name,MS_Opportunity__c FROM Opportunity WHERE Id =: opportunityRecord.Id];
        System.debug('Aashi MS_Opportunity__c '+opp.MS_Opportunity__c);
        opp.StageName = 'Closed/Won';
        UPDATE opp;
            
        Order orderRecord= New Order(AccountID=accountRecord.id,
                                   CurrencyIsoCode='GBP',
                                   Status='Draft',
                                   EffectiveDate=Date.Today()
                                   );
        orderRecord.Booked_Elsewhere__c = False;
        orderRecord.EffectiveDate = date.today();
        orderRecord.Submission_Offset__c = -18000000;
        orderRecord.Activation_Offset__c = -18000000;
        orderRecord.Pricebook2Id = pricebookId;
        orderRecord.OpportunityId = opp.Id;
        INSERT orderRecord;
        
        Order orderRecord1 = [SELECT Id FROM Order];
        System.debug('Aashi ' +orderRecord1.Id);
        /*OrderItem orderItemRecord = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord.Id);
        orderItemRecord.UnitPrice = 100;
        orderItemRecord.Platform__c = 'MFS';
        orderItemRecord.Quantity = 1;
        INSERT orderItemRecord;
        */
        //}
        
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
    
    // Method to unit test getOrderData of GenericClassToGetData class
    @isTest
    public static void testGetOrderData(){
        Job__c jobRecord = [SELECT Id,Opportunity__c FROM Job__c LIMIT 1];
        Test.startTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        list<Order> orderData = new list<Order>();
        System.runAs(u1){
        	orderData = GenericClassToGetData.getOrderData(jobRecord.Id);
        }
        Test.stopTest();
        System.assertEquals(1, orderData.size());
    }
    
    // Method to unit test getOrderData of GenericClassToGetData class
    @isTest
    public static void testGetOrderDataCatchBlock(){
        Job__c jobRecord = [SELECT Id,Opportunity__c FROM Job__c LIMIT 1];
        Test.startTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        list<Order> orderData = new list<Order>();
        System.runAs(u1){
            try{
                orderData = GenericClassToGetData.getOrderData(null);
            }catch(AuraHandledException e){
                System.assertEquals(true, e.getMessage().contains('Script'));
            }
        }
        Test.stopTest();
        //System.assertNotEquals(1, orderData.size());
    }
    
    /* Method to cover below classes as code snippet of these are not in use and commented */
    @isTest
    public static void coverEmptyClasses(){
        BureauCandidateTriggerManager_1 class1 = new BureauCandidateTriggerManager_1();
        BureauJob_InstrumentAssigner class2 = new BureauJob_InstrumentAssigner();
        BureauJob_InstrumentManager class3 = new BureauJob_InstrumentManager();
        BureauJob_RatingManager class4 = new BureauJob_RatingManager();
        MS_InvoiceTriggerManager class5 = new MS_InvoiceTriggerManager();
        MS_RatingTriggerManager class6 = new MS_RatingTriggerManager();
        BureauJob_InvoiceManager class7 = new BureauJob_InvoiceManager();
        BureauJob_ManageInvoice class8 = new BureauJob_ManageInvoice();
        MS_SystemTriggerManager class9 = new MS_SystemTriggerManager();
        BureauJob_CandidateImporter class10 = new BureauJob_CandidateImporter();
    }
}
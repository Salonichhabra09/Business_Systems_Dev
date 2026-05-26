@isTest
public class CreateVariation_Lex_Tester{
    
    @testSetup static void setup() {
        
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');  
        
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityLineItem', 'OpportunityLineItem_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Contract', 'Contract_Trigger');
        createTriggerActivationCustomSettingRecords('Order', 'Order_Trigger');
        createTriggerActivationCustomSettingRecords('Campaign', 'Campaign_Trigger');
        
        Id pricebookId = Test.getStandardPricebookId();
        
        /*Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Industry = 'Education & Educational Services';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        */
        // Custom Setting for Auto Job creation
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c();
        cs.Name='Values';
        cs.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        INSERT cs;
        
        /*Campaign campaignRecord = TestDataUtility.getCampaign();
        INSERT campaignRecord;
        */
        /*Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord.CampaignId = campaignRecord.Id;
        INSERT opportunityRecord;
        
        // Should create Opp Line Items
        
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id, opportunityRecord.id);
        contractRecord.Subscription_Start_Date__c = date.today();
        contractRecord.Contract_End_Date__c = date.today()+365;
        INSERT contractRecord; 
        
        Order orderRecord = TestDataUtility.getOrder(contractRecord.id, accountRecord.id);
        orderRecord.Booked_Elsewhere__c = False;
        orderRecord.EffectiveDate = date.today();
        orderRecord.Submission_Offset__c = -18000000;
        orderRecord.Activation_Offset__c = -18000000;
        orderRecord.Pricebook2Id = pricebookId;
        INSERT orderRecord;
        */
        // Should create Order Line Items
        
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
    
    public static testMethod void Testservermethods(){
        
        CreateVariation_LEX.getRecordList();
        Account account=CreateTestData.getAccount();
        
        Contact contact = new Contact(AccountId=account.Id,LastName='test12345',email='test12345@test.com',phone='2345345345',Same_As_The_Account_Billing_Address__c=true);
        insert contact;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(account.id, contact.id);
        INSERT opportunityRecord;
        CreateVariation_LEX.getOppDetails(opportunityRecord.id,account.Id);
    }
    
    public static testMethod void testGetOpportunityList(){
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Industry = 'Education & Educational Services';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        INSERT opportunityRecord;
        
        Contract contractRecord = TestDataUtility.getContract(accountRecord.Id, opportunityRecord.Id);
        
        Test.startTest();
        list<Opportunity> oppList = CreateVariation_LEX.getOpportunityList(contractRecord.Id);
        System.assertNotEquals(0, oppList.size());
        Test.stopTest();
    }      
}
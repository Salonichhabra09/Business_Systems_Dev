@isTest
public class StaticMethodsTester {
    
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
        createTriggerActivationCustomSettingRecords('Contract_Invoice_Header__c', 'InvoiceHeader_Trigger');
        createTriggerActivationCustomSettingRecords('Contract_Invoice_Line__c', 'ContractInvoiceLine_Trigger');  
        createTriggerActivationCustomSettingRecords('Campaign', 'Campaign_Trigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Invoice__c', 'MS_Invoice_Trigger');
            createTriggerActivationCustomSettingRecords('Task', 'Task_Trigger');
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Industry = 'Education & Educational Services';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        // Custom Setting for Auto Job creation
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c();
        cs.Name='Values';
        cs.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        INSERT cs;
        
        Campaign campaignRecord = TestDataUtility.getCampaign();
        INSERT campaignRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord.CampaignId = campaignRecord.Id;
        INSERT opportunityRecord;
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;

        Contact contact2 = TestDataUtility.getContact(accountRecord.Id);
        contact2.Email = uniqueName + '@testing' + orgId + '.org';
        insert contact2;
        
        Opportunity opp3 = TestDataUtility.getOpportunity(accountRecord.Id, contact2.Id);
        insert opp3;
        OpportunityContactRole ocr2 = new OpportunityContactRole ();
        ocr2.ContactId = contact2.Id;
        ocr2.OpportunityId=opp3.Id;
        ocr2.role='Billing Contact';
        ocr2.IsPrimary=false;
        Insert ocr2; 
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
    static void SendEmailTester(){
		list<Opportunity> oppList = [SELECT Id FROM Opportunity];
        List<Id> oppIds = new List<Id>(new Map<Id, Opportunity>(oppList).keySet());

        Test.startTest();
        EmailTemplate et = [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Renewal_Price_Uplift_Failure_Email_Template'];
        SendMailFromOpportunity.SendEmail(new List<List<String>>{oppIds});
        //SendMailFromOpportunity.SendEmail(new List<List<String>>{new List<String>{opp.Id, opp2.Id,opp3.Id}});
        SendMailFromOpportunity.sendEmailToAdmin(oppList[0].Id, 'Error', et);
        Test.stopTest();
    }
}
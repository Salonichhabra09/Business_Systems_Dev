@IsTest
public class CandidateCreationController_Test {

    @TestSetup
    static void makeData(){

        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');

        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Candidate__c', 'Bureau_Candidate_Trigger');

        AutomaticJobCreation__c autoJobCreation = new AutomaticJobCreation__c();
        autoJobCreation.Name = 'Values';
        autoJobCreation.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        Insert autoJobCreation;
        

        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, UserInfo.getUserId());
        INSERT opportunityRecord;

        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        
        Job__c job = new Job__c();
        job.Opportunity__c = opportunityRecord.Id;
        job.Account__c = accountRecord.Id;
        job.MS_Line_of_Business__c = 'Talent Management';
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.InternalContact__c = UserInfo.getUserId();
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = 'Test';
        job.ShortFall_Manager__c = 1;
        job.Shortfall_Peer__c = 2;
        job.Shortfall_Subordinate__c = 3;
        job.ShortFall_Customer__c = 2;
        job.Shortfall_Client__c = 2;
        job.ShortFall_Other__c = 2;
        job.PurchaseOrderNo__c='rtertr';
        job.Generic_BS_Field_One__c='Bureau Service';
        job.Generic_Field_MS_One__c='Managed Service';
        job.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        job.Is_Redirect_To_Task__c=true;
        job.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        job.System_Used__c ='SHL ONLINE';
        job.RecordTypeId = RecordTypeIdJob1;
        job.Job_Region__c='China';
        insert job;
    }
    
    @IsTest
    static void testCreateCandidateRecords() {

        Job__c jobRecord = [SELECT Id FROM Job__c LIMIT 1];

        Bureau_Candidate__c candidate = new Bureau_Candidate__c();
        candidate.First_Name__c = 'Test';
        candidate.Last_Name__c = 'Candidate 1';
        candidate.Bureau_Job__c = jobRecord.Id;
        candidate.Email__c = 'testemail12345@test.com';
        candidate.Reports_Status__c = 'Unsent';

        List<Bureau_Candidate__c> candidateList = new List<Bureau_Candidate__c>{candidate};
        Test.startTest();

        CandidateCreationController.createCandidateRecords(candidateList);

        Test.stopTest();
    }

    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }

    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
}
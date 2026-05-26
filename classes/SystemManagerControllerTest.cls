@isTest
public class SystemManagerControllerTest {

    @testSetup
    public static void setup() {
        
        createTriggerActivationCustomSettingRecords('System', 'System_Trigger');
        createTriggerActivationCustomSettingRecords('Managed Services System', 'MS_System_Trigger');
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Candidate__c', 'Bureau_Candidate_Trigger');
        createAutomaticJobCreationCustomSettingRecords('Values', 'TA - Corporate,Talent Management,TA - Credentialing');
        
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        INSERT opportunityRecord;
        
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdSystem = Schema.SObjectType.System__c.getRecordTypeInfosByDeveloperName().get('SHL_System').getRecordTypeId();

        Job__c job = new Job__c();
        job.Account__c = accountRecord.Id;
        job.Opportunity__c = opportunityRecord.Id;
        job.MS_Line_of_Business__c = 'Talent Management';
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.InternalContact__c = UserInfo.getUserId();
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = 'CAND';
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
        job.RecordTypeId = RecordTypeIdJob2;
        job.Do_Not_Send_Survey__c = True;
        job.Preferred_Language__c = 'English';
        job.Job_Region__c = 'Non China';
        insert job;
        
        System__c sys = new System__c();
        sys.System_Name__c = 'Test sys';
        sys.System_URL__c = 'www.test.com';
        sys.Account__c = accountRecord.Id;
        sys.RecordTypeId = RecordTypeIdSystem;
        sys.System_Type__c = 'MFS';
        sys.System_Client_ID__c = '1234';
        INSERT sys;
        
       
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    public static void createAutomaticJobCreationCustomSettingRecords(String name, String msLOB){
        AutomaticJobCreation__c recordToInsert = TestDataUtility.getAutomaticJobCreation(name, msLOB);
        INSERT recordToInsert;
    }
    
    @isTest
    public static void getBureauSystemDetailstest() {
        Job__c job = [SELECT Id FROM Job__c];
        Test.startTest();
        SystemManagerController.getBureauSystemDetails(job.Id, 1, 0);
        Test.stopTest();
    }
    
    @isTest
    public static void getAllSystemstest() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        Test.startTest();
        SystemManagerController.getAllSystems(job.Id, 1, 0);
        Test.stopTest();
    }
    
    @isTest
    public static void getPreselectedSystemtest() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        System__c sys = [SELECT Id, Name FROM System__c LIMIT 1];
        List<String> sysName = new List<String>();
        sysName.add(sys.Name);
        Test.startTest();
        SystemManagerController.getPreselectedSystem(sysName,job.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void createBureauSystemtest() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        System__c sys = [SELECT Id,System_URL__c,System_Client_ID__c,Name,System_type__c FROM System__c LIMIT 1];
        String sys1 = '[{"name":"'+sys.Name+'","lang":"English"}]';
        String sys2 = '[{"name":"'+sys.Name+'","projectId":"12345"}]';
        List<System__c> sysName = new List<System__c>();
        sysName.add(sys);
        Test.startTest();
         SystemManagerController.createBureauSystem(sysName,sys1,sys2,job.Id);
         Bureau_System__c systemObj = new Bureau_System__c();
         systemObj.System__c = sys.Id;
         systemObj.Bureau_Job__c = job.Id;
         Insert systemObj;
         SystemManagerController.createBureauSystem(sysName,sys1,sys2,job.Id);
         Test.stopTest();
    }
}
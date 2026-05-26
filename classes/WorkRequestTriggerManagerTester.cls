@isTest
public class WorkRequestTriggerManagerTester {
    
    @testSetup
    static void setup() {
        
        Trigger_Activation__c triggerSetting = new Trigger_Activation__c();
        triggerSetting.Name = 'Account_Trigger';
        triggerSetting.Active__c = true; // or false based on what you want to test
        insert triggerSetting;
        
        Trigger_Activation__c contacttriggerSetting = new Trigger_Activation__c();
        contacttriggerSetting.Name = 'Contact_Trigger';
        contacttriggerSetting.Active__c = true; // or false based on what you want to test
        insert contacttriggerSetting;
        
        Trigger_Activation__c opptriggerSetting = new Trigger_Activation__c();
        opptriggerSetting.Name = 'Opportunity_Trigger';
        opptriggerSetting.Active__c = true; // or false based on what you want to test
        insert opptriggerSetting;
        
        Trigger_Activation__c oppcontriggerSetting = new Trigger_Activation__c();
        oppcontriggerSetting.Name = 'OpportunityContactRoleTrigger';
        oppcontriggerSetting.Active__c = true; // or false based on what you want to test
        insert oppcontriggerSetting;
        
        Trigger_Activation__c jobtriggerSetting = new Trigger_Activation__c();
        jobtriggerSetting.Name = 'Job_Trigger';
        jobtriggerSetting.Active__c = true; // or false based on what you want to test
        insert jobtriggerSetting;
        
        Trigger_Activation__c ContentDocumentLink_TriggerSetting = new Trigger_Activation__c();
        ContentDocumentLink_TriggerSetting.Name = 'ContentDocumentLink_Trigger';
        ContentDocumentLink_TriggerSetting.Active__c = true; // or false based on what you want to test
        insert ContentDocumentLink_TriggerSetting;
        
        Trigger_Activation__c ContentDocument_TriggerSetting = new Trigger_Activation__c();
        ContentDocument_TriggerSetting.Name = 'ContentDocument_Trigger';
        ContentDocument_TriggerSetting.Active__c = true; // or false based on what you want to test
        insert ContentDocument_TriggerSetting;
        
    }
    
    @isTest
    public static void afterInsertTester(){
        Test.startTest();
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Job__c job = new Job__c();
        job.Account__c = accountRecord.Id;
        job.MS_Line_of_Business__c = 'Talent Management';
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.InternalContact__c = UserInfo.getUserId();
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = 'QA01';
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
        job.RecordTypeId = RecordTypeIdJob2;
        job.Do_Not_Send_Survey__c = True;
        job.Preferred_Language__c = 'English';
        job.Job_Region__c = 'Non China';
        insert job;
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        
        ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = '_CandidateWRFImportSheet';
        cv3.PathOnClient = 'TestDocument.csv';
        System.debug('Content Version cv '+cv3);
        insert cv3;
        
        
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(accountRecord.Id, job.Id);
        Work_Request__c submittedRequest = TestDataUtility.getSubmittedWRF(generatedRequest.Id,cv3.Id);
        ContentDocumentLink cdl3 = new ContentDocumentLink();
        cdl3.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv3.id].ContentDocumentId;
        cdl3.LinkedEntityId = submittedRequest.Id;
        cdl3.ShareType = 'V';
        insert cdl3;
        submittedRequest.No_of_Candidate_Created__c = 10;
        update submittedRequest;
        Test.stopTest();
    }
    
}
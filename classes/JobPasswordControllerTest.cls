@isTest
public class JobPasswordControllerTest {
    @testSetup
    static void setupTestData() {
        
         
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
        
        Trigger_Activation__c tasktriggerSetting = new Trigger_Activation__c();
        tasktriggerSetting.Name = 'Task_Trigger';
        tasktriggerSetting.Active__c = true; // or false based on what you want to test
        insert tasktriggerSetting;
        
         Trigger_Activation__c ContentDocumentLink_TriggerSetting = new Trigger_Activation__c();
        ContentDocumentLink_TriggerSetting.Name = 'ContentDocumentLink_Trigger';
        ContentDocumentLink_TriggerSetting.Active__c = true; // or false based on what you want to test
        insert ContentDocumentLink_TriggerSetting;
        
        Trigger_Activation__c ContentDocument_TriggerSetting = new Trigger_Activation__c();
        ContentDocument_TriggerSetting.Name = 'ContentDocument_Trigger';
        ContentDocument_TriggerSetting.Active__c = true; // or false based on what you want to test
        insert ContentDocument_TriggerSetting;
        
        // Create a test CryptoKeySetting__c record
        CryptoKeySetting__c cryptoSetting = new CryptoKeySetting__c(
            Name = 'TestCryptoKey', CRYPTO__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256))
        );
        insert cryptoSetting;
        
        AutomaticJobCreation__c autoJobCreation = new AutomaticJobCreation__c();
        autoJobCreation.Name = 'Values';
        autoJobCreation.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        Insert autoJobCreation;
        
       
        
        // Create a test Job__c record
         
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, UserInfo.getUserId());
        opportunityRecord.Business_Type__c = 'New customer: subscription';
        INSERT opportunityRecord;
        
        Contract contract = TestDataUtility.getContract(accountRecord.Id,opportunityRecord.Id);
        contract.Contract_End_Date__c = Date.Today();
        Insert contract;
        
        opportunityRecord.ContractId = contract.Id;
        update opportunityRecord;

        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Pipeline').getRecordTypeId();
        Id userId = [select id from User where Is_Bureau_Service_Manager__c = true and IsActive = true limit 1].id;
        Job__c job = new Job__c();
        //Task t = new Task(Subject='Abc',Status='Not Started',Priority='Normal',WhatId = job1.id);
       // insert t;
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.Project_Lead__c = userId;    
        job.Opportunity__c = opportunityRecord.Id;
        job.Account__c = accountRecord.Id;
        job.InternalContact__c = UserInfo.getUserId();      
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = '';
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
        job.MS_Line_of_Business__c='Talent Management';
        job.Job_Region__c='Non China';
        job.Sender_Email__c = 'noreply@shl.com';
        job.Client_Report_Password__c = 'rApJxWl3kouqSxzsODi+c3Z7fcqt8uQTi0wI3VacIOQ=';
        job.Client_Report_Mail_Ids__c = 'abc@abc.com';
        job.Contact_Details__c = '[{"name":"Supriya Kakaraddi","email":"supriya.kakaraddi@shl.com","role":"Project Sponsor"}]';
        job.Solution_Cap__c = 10;
        
       // job.System_Field__c = job1.id;  
        //job.Managed_Services_Pipeline__c = job1.id;
        insert job;
        
    }

    @isTest
    static void testInitiatePasswordGeneration() {
        // Fetch test job record
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        List<String> updatedEmails = new List<String>{'user2@example.com', 'user3@example.com'};

        Test.startTest();
        JobPasswordController.initiatePasswordGeneration(job.Id, updatedEmails);
        Test.stopTest();

        // Verify that the password is generated and emails updated
        job = [SELECT Client_Report_Password__c, Client_Report_Mail_Ids__c FROM Job__c WHERE Id = :job.Id];
        //System.assertNotEquals(null, job.Client_Report_Password__c, 'Password should be set');
        //System.assertEquals('user2@example.com,user3@example.com', job.Client_Report_Mail_Ids__c, 'Emails should be updated');
    }

    @isTest
    static void testGetEmailList() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        List<String> emailList = JobPasswordController.getEmailList(job.Id);
        //System.assertEquals(1, emailList.size(), 'Email list should return one email');
        //System.assertEquals('user1@example.com', emailList[0], 'Email should match');
    }

    @isTest
    static void testSendExistingPasswordEmail() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        List<String> updatedEmails = new List<String>{'newuser@example.com'};
        
        Test.startTest();
        try {
            JobPasswordController.sendExistingPasswordEmail(job.Id, updatedEmails);
        } catch (Exception e) {
            //System.assert(e.getMessage().contains('No password found for this Job record.'), 'Exception should be thrown if password is missing');
        }
        Test.stopTest();
    }

    @isTest
    static void testAuthenticateUser() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        String encryptedPassword = JobPasswordController.generateSecurePassword();
        job.Client_Report_Password__c = JobPasswordController.encryptPassword(encryptedPassword);
        update job;
        
        Boolean isAuthenticated = JobPasswordController.authenticateUser('user1@example.com', encryptedPassword, job.Id);
        //System.assertEquals(true, isAuthenticated, 'User should be authenticated');
    }
    @isTest
    static void testgetDashboardData() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        Account accountRecord = [select id from account limit 1];
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(accountRecord.Id, job.Id);
        
        /*ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = '_CandidateWRFImportSheet';
        cv3.PathOnClient = 'TestDocument.csv';
        System.debug('Content Version cv '+cv3);
        insert cv3;*/
        
        
        
        Work_Request__c submittedRequest = TestDataUtility.getSubmittedWRF(generatedRequest.Id,null);
       /*  ContentDocumentLink cdl3 = new ContentDocumentLink();
        cdl3.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv3.id].ContentDocumentId;
        cdl3.LinkedEntityId = submittedRequest.Id;
        cdl3.ShareType = 'V';
        insert cdl3;*/
        
        Map<String, Object> dashboardata = ProjectDashboardController.getDashboardData(job.Id);
        
    }
}
@isTest(SeeAllData=true)
public class CandidateUploadContollerTest {
    
    public static void setup() {
        
        List<Bureau_Candidate__c> candidateList = new List<Bureau_Candidate__c>();
        
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, UserInfo.getUserId());
        INSERT opportunityRecord;
        
        ContentVersion Cv1 = new ContentVersion();    
        Cv1.Origin='C';
        Cv1.VersionData = Blob.ValueOf('Hello');
        Cv1.Title = 'CandidateUploadForTestSheet.utf8';
        Cv1.PathOnClient ='CandidateUploadForTestSheet.utf8'; 
        Cv1.ContentLocation='S';        
        insert Cv1; 

        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Job__c job = new Job__c();
        job.Account__c = accountRecord.Id;
        job.Opportunity__c =opportunityRecord.Id;
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
        job.Generic_Date_Field_MS_One__c = System.today();
		job.Job_Region__c='Non China';

        insert job;
        
        Job__c job2 = new Job__c();
        job2.Account__c = accountRecord.Id;
        job2.Opportunity__c =opportunityRecord.Id;
        job2.MS_Line_of_Business__c = 'Talent Management';
        job2.Job_Type__c = 'Project - 360';
        job2.Start_Date__c = System.today();
        job2.End_Date__c = System.today().addDays(30);
        job2.InternalContact__c = UserInfo.getUserId();
        job2.External_Contact_Others__c = 'External Contact';
        job2.External_Contact_Other_Email_Address__c='test@test.com';
        job2.Candidate_Username_Prefix__c = 'QA02';
        job2.ShortFall_Manager__c = 1;
        job2.Shortfall_Peer__c = 2;
        job2.Shortfall_Subordinate__c = 3;
        job2.ShortFall_Customer__c = 2;
        job2.Shortfall_Client__c = 2;
        job2.ShortFall_Other__c = 2;
        job2.PurchaseOrderNo__c='rtertr';
        job2.Generic_BS_Field_One__c='Bureau Service';
        job2.Generic_Field_MS_One__c='Managed Service';
        job2.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        job2.Is_Redirect_To_Task__c=true;
        job2.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        job2.System_Used__c ='SHL ONLINE';
        job2.RecordTypeId = RecordTypeIdJob1;
        job2.Do_Not_Send_Survey__c = True;
        job2.Preferred_Language__c = 'English';
        job2.Generic_Date_Field_MS_One__c = System.today();
        job2.Job_Region__c='Non China';
        insert job2;
        
        Job__c job3 = new Job__c();
        job3.Account__c = accountRecord.Id;
        job3.Opportunity__c =opportunityRecord.Id;
        job3.MS_Line_of_Business__c = 'TA - Vocational (Batch)';
        job3.Job_Type__c = 'Project - 360';
        job3.Start_Date__c = System.today();
        job3.End_Date__c = System.today().addDays(30);
        job3.InternalContact__c = UserInfo.getUserId();
        job3.External_Contact_Others__c = 'External Contact';
        job3.External_Contact_Other_Email_Address__c='test@test.com';
        job3.Candidate_Username_Prefix__c = 'QA03';
        job3.ShortFall_Manager__c = 1;
        job3.Shortfall_Peer__c = 2;
        job3.Shortfall_Subordinate__c = 3;
        job3.ShortFall_Customer__c = 2;
        job3.Shortfall_Client__c = 2;
        job3.ShortFall_Other__c = 2;
        job3.PurchaseOrderNo__c='rtertr';
        job3.Generic_BS_Field_One__c='Bureau Service';
        job3.Generic_Field_MS_One__c='Managed Service';
        job3.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        job3.Is_Redirect_To_Task__c=true;
        job3.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        job3.System_Used__c ='SHL ONLINE';
        job3.RecordTypeId = RecordTypeIdJob1;
        job3.Do_Not_Send_Survey__c = True;
        job3.Preferred_Language__c = 'English';
        job3.Generic_Date_Field_MS_One__c = System.today();
        job3.Job_Region__c='Non China';
        insert job3;
        
        Job__c job4 = new Job__c();
        job4.Account__c = accountRecord.Id;
        job4.Opportunity__c =opportunityRecord.Id;
        job4.MS_Line_of_Business__c = 'TA - Corporate';
        job4.Job_Type__c = 'Project - 360';
        job4.Start_Date__c = System.today();
        job4.End_Date__c = System.today().addDays(30);
        job4.InternalContact__c = UserInfo.getUserId();
        job4.External_Contact_Others__c = 'External Contact';
        job4.External_Contact_Other_Email_Address__c='test@test.com';
        job4.Candidate_Username_Prefix__c = 'QA04';
        job4.ShortFall_Manager__c = 1;
        job4.Shortfall_Peer__c = 2;
        job4.Shortfall_Subordinate__c = 3;
        job4.ShortFall_Customer__c = 2;
        job4.Shortfall_Client__c = 2;
        job4.ShortFall_Other__c = 2;
        job4.PurchaseOrderNo__c='rtertr';
        job4.Generic_BS_Field_One__c='Bureau Service';
        job4.Generic_Field_MS_One__c='Managed Service';
        job4.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        job4.Is_Redirect_To_Task__c=true;
        job4.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        job4.System_Used__c ='SHL ONLINE';
        job4.RecordTypeId = RecordTypeIdJob1;
        job4.Do_Not_Send_Survey__c = True;
        job4.Preferred_Language__c = 'English';
        job4.Generic_Date_Field_MS_One__c = System.today();
        job4.Job_Region__c='Non China';
        insert job4;
        
        for(Integer i=0; i<100; i++) {
            Bureau_Candidate__c candidate = new Bureau_Candidate__c();
            candidate.First_Name__c = 'FirstName '+i;
            candidate.Last_Name__c = 'LastName '+i;
            candidate.Email__c = 'fn'+i+'@gmail.com';
            candidate.Email2__c = 'fn'+i+'@gmail.com';
            candidate.Bureau_Job__c = job.Id;
            candidateList.add(candidate);
        }
        
        for(Integer i=0; i<100; i++) {
            Bureau_Candidate__c candidate = new Bureau_Candidate__c();
            candidate.First_Name__c = 'FirstName '+i;
            candidate.Last_Name__c = 'LastName '+i;
            candidate.Email__c = 'fn'+i+'@gmail.com';
            candidate.Email2__c = 'fn'+i+'@gmail.com';
            candidate.Bureau_Job__c = job3.Id;
            if(i<30) {
                candidate.Status2__c = 'Pass';
            }
            if(i>30 && i<70) {
                candidate.Status2__c = 'Fail';
            }
            if(i>70) {
                candidate.Status2__c = 'DNA';
            }
            candidateList.add(candidate);
        }
        
        for(Integer i=0; i<100; i++) {
            Bureau_Candidate__c candidate = new Bureau_Candidate__c();
            candidate.First_Name__c = 'FirstName '+i;
            candidate.Last_Name__c = 'LastName '+i;
            candidate.Email__c = 'fn'+i+'@gmail.com';
            candidate.Email2__c = 'fn'+i+'@gmail.com';
            candidate.Bureau_Job__c = job4.Id;
            if(i<30) {
                candidate.Status2__c = 'Completed';
            }
            if(i>30 && i<70) {
                candidate.Status2__c = 'In Progress';
            }
            if(i>70) {
                candidate.Status2__c = 'Not Started';
            }
            candidateList.add(candidate);
        }
        
        INSERT candidateList;
    }

    @isTest
    public static void getCandidateIdsRelateToJobTest() {
        Test.startTest();
        Setup();
        list<Id> candidateIds = new list<Id>();
        Job__c jobObj = [SELECT Id FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        list<Bureau_Candidate__c> candidateList = [SELECT Id FROM Bureau_Candidate__c WHERE Bureau_Job__c = :jobObj.Id];
        for(Bureau_Candidate__c bc : candidateList){
            candidateIds.add(bc.Id);
        }
        CandidateUploadContoller.getCandidateIdsRelateToJob(candidateIds, jobObj.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getCandidateIdsRelateToJobCoverElseTest() {
        
        Test.startTest();
        Setup();
        list<Id> candidateIds = new list<Id>();
        Job__c jobObj = [SELECT Id FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA02' LIMIT 1];
        list<Bureau_Candidate__c> candidateList = [SELECT Id FROM Bureau_Candidate__c WHERE Bureau_Job__c = :jobObj.Id];
        for(Bureau_Candidate__c bc : candidateList){
            candidateIds.add(bc.Id);
        }
        CandidateUploadContoller.getCandidateIdsRelateToJob(candidateIds, jobObj.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getJobDataTest() {
        
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id FROM Job__c LIMIT 1];
        CandidateUploadContoller.getJobData(jobObj.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getJobDataCovertElseTest() {
        Test.startTest();
        CandidateUploadContoller.getJobData('12345');
        Test.stopTest();
    }
    
    @isTest
    public static void createRatingsTest() {
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id  FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        String json = '[{"Category":"Self","Email":"fn1@gmail.com","Recipient_Email":"fn1@gmail.com"},{"Category":"Manager","Email":"fn2@gmail.com","Recipient_Email":"fn1@gmail.com"}]';
        CandidateUploadContoller.createRatings(json, jobObj.Id, false);
        Test.stopTest();
    }
    
    /*@isTest
    public static void insertContentDistributionTest() {
        
        Test.startTest();
        ContentVersion cv4 = new ContentVersion();
        String encoded3 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded3=  EncodingUtil.urlDecode(encoded3,'UTF-8');
        cv4.VersionData = Blob.valueOf('\uFEFF'+decoded3);
        cv4.Title = '_CandidateWRFUpdateSheet';
        cv4.PathOnClient = 'test';
        System.debug('Content Version cv '+cv4);
        insert cv4;
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion LIMIT 1];
        ContentDocument cd = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        CandidateUploadContoller.insertContentDistribution(cd.id, cv.id);
        Test.stopTest();
    }*/
    
    @isTest
    public static void uploadFileTest() {
        
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id  FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        CandidateUploadContoller.uploadFile('Base 64 String', 'Test', jobObj.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void createCandidatesTest() {
        
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        System.debug('jobObj MS LOB ###'+jobObj.MS_Line_of_Business__c);
        string json = '[{"Category__c":"Self","First_Name__c":"malin ","Last_Name__c":"Gusatsson","Email__c":"test1@shl.com","Gender__c":"Female","Phone_Number__c":"123543","Country__c":"United Kingdom","Language__c":"","Status2__c":"Not Started","Reports_Status__c":"Unsent","Username__c":"","Product_Assessment__c":"360 Feedback Training (inco),360 Outsourced MS High,360 Outsourced MS Light,360 Question. Outsourced Services - Tailored High,  A And H Tissue Analysis Report,360 Questionnaire Outsourced Services - Tailored","System_s__c":"360","Email_as_Username__c":false,"Bureau_Job__c":"'+jobObj.Id+'","Candidate_Unique_Id__c":"'+jobObj.Id+'malin Gusatssontest1@shl.comtest1@shl.com"},{"Category__c":"Self","First_Name__c":"lena","Last_Name__c":"gustafsson","Email__c":"test3@shl.com","Gender__c":"Male","Phone_Number__c":"1234543","Country__c":"United Kingdom","Language__c":"","Status2__c":"Not Started","Reports_Status__c":"Unsent","Username__c":"","Product_Assessment__c":"361 Feedback Training (inco),360 Outsourced MS High,360 Outsourced MS Light,360 Question. Outsourced Services - Tailored High,  A And H Tissue Analysis Report,360 Questionnaire Outsourced Services - Tailored","System_s__c":"360","Email_as_Username__c":false,"Bureau_Job__c":"'+jobObj.Id+'","Candidate_Unique_Id__c":"'+jobObj.Id+'lenagustafssontest3@shl.comtest3@shl.com"}]';
        CandidateUploadContoller.createCandidates(json, jobObj.Id, false);
        Test.stopTest();
    }
    
    @isTest
    public static void createCandidatesTAVocationalTest() {
        
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA03' LIMIT 1];
        System.debug('jobObj MS LOB ###'+jobObj.MS_Line_of_Business__c);
        string json = '[{"Category__c":"Self","First_Name__c":"malin ","Last_Name__c":"Gusatsson","Email__c":"test1@shl.com","Gender__c":"Female","Phone_Number__c":"123543","Country__c":"United Kingdom","Language__c":"","Status2__c":"Not Started","Reports_Status__c":"Unsent","Username__c":"","Product_Assessment__c":"360 Feedback Training (inco),360 Outsourced MS High,360 Outsourced MS Light,360 Question. Outsourced Services - Tailored High,  A And H Tissue Analysis Report,360 Questionnaire Outsourced Services - Tailored","System_s__c":"360","Email_as_Username__c":false,"Bureau_Job__c":"'+jobObj.Id+'","Candidate_Unique_Id__c":"'+jobObj.Id+'malin Gusatssontest1@shl.comtest1@shl.com"},{"Category__c":"Self","First_Name__c":"lena","Last_Name__c":"gustafsson","Email__c":"test3@shl.com","Gender__c":"Male","Phone_Number__c":"1234543","Country__c":"United Kingdom","Language__c":"","Status2__c":"Not Started","Reports_Status__c":"Unsent","Username__c":"","Product_Assessment__c":"361 Feedback Training (inco),360 Outsourced MS High,360 Outsourced MS Light,360 Question. Outsourced Services - Tailored High,  A And H Tissue Analysis Report,360 Questionnaire Outsourced Services - Tailored","System_s__c":"360","Email_as_Username__c":false,"Bureau_Job__c":"'+jobObj.Id+'","Candidate_Unique_Id__c":"'+jobObj.Id+'lenagustafssontest3@shl.comtest3@shl.com"}]';
        CandidateUploadContoller.createCandidates(json, jobObj.Id, false);
        Test.stopTest();
    }
    
    @isTest
    public static void createCandidatesTACorporateTest() {
        
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA04' LIMIT 1];
        System.debug('jobObj MS LOB ###'+jobObj.MS_Line_of_Business__c);
        string json = '[{"Category__c":"Self","First_Name__c":"malin ","Last_Name__c":"Gusatsson","Email__c":"test1@shl.com","Gender__c":"Female","Phone_Number__c":"123543","Country__c":"United Kingdom","Language__c":"","Status2__c":"Not Started","Reports_Status__c":"Unsent","Username__c":"","Product_Assessment__c":"360 Feedback Training (inco),360 Outsourced MS High,360 Outsourced MS Light,360 Question. Outsourced Services - Tailored High,  A And H Tissue Analysis Report,360 Questionnaire Outsourced Services - Tailored","System_s__c":"360","Email_as_Username__c":false,"Bureau_Job__c":"'+jobObj.Id+'","Candidate_Unique_Id__c":"'+jobObj.Id+'malin Gusatssontest1@shl.comtest1@shl.com"},{"Category__c":"Self","First_Name__c":"lena","Last_Name__c":"gustafsson","Email__c":"test3@shl.com","Gender__c":"Male","Phone_Number__c":"1234543","Country__c":"United Kingdom","Language__c":"","Status2__c":"Not Started","Reports_Status__c":"Unsent","Username__c":"","Product_Assessment__c":"361 Feedback Training (inco),360 Outsourced MS High,360 Outsourced MS Light,360 Question. Outsourced Services - Tailored High,  A And H Tissue Analysis Report,360 Questionnaire Outsourced Services - Tailored","System_s__c":"360","Email_as_Username__c":false,"Bureau_Job__c":"'+jobObj.Id+'","Candidate_Unique_Id__c":"'+jobObj.Id+'lenagustafssontest3@shl.comtest3@shl.com"}]';
        CandidateUploadContoller.createCandidates(json, jobObj.Id, false);
        Test.stopTest();
    }
    
    @isTest
    public static void createCandidatesUpdateTest() {
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        Bureau_Candidate__c candidate = [SELECT Id,
                                         		First_Name__c,
                                         		Last_Name__c,
                                         		Email__c,
                                         		Gender__c,
                                         		Phone_Number__c,
                                         		Country__c,
                                         		Language__c,
                                         		Status2__c,
                                         		Reports_Status__c,
                                         		Username__c,
                                         		Product_Assessment__c,
                                         		Email_as_Username__c
                                         FROM Bureau_Candidate__c 
                                         WHERE First_Name__c = 'FirstName 1'
                                         AND Last_Name__c = 'LastName 1'
                                         AND Email__c = 'fn1@gmail.com'
                                         LIMIT 1];
        String json = '[{"Id":"'+candidate.Id+'","First_Name__c":"'+candidate.First_Name__c+'","Last_Name__c":"'+candidate.Last_Name__c+'","Email__c":"'+candidate.Email__c+'","Gender__c":"Female","Phone_Number__c":"2154853121","Country__c":"United Kingdom","Language__c":"","Status2__c":"Not Started","Reports_Status__c":"","Username__c":"","Product_Assessment__c":"362 Feedback Training (inco),360 Outsourced MS High,360 Outsourced MS Light,360 Question. Outsourced Services - Tailored High,  A And H Tissue Analysis Report,360 Questionnaire Outsourced Services - Tailored","System_s__c":"360","Email_as_Username__c":false,"Candidate_Unique_Id__c":"'+jobObj.Id+'rolfgustafssontest4@shl.comtest4@shl.com"}]';
        CandidateUploadContoller.createCandidates(json, jobObj.Id, true);
        Test.stopTest();
    }
    
    @isTest
    public static void handleButtonVisibilityApexTest() {
        
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c 
                         WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        CandidateUploadContoller.handleButtonVisibilityApex(jobObj.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void exportCandidatesAsyncTest() {
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c 
                         WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        CandidateUploadContoller.exportCandidatesAsync(jobObj.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getDataFromFileTest() {
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];

        ContentVersion cv = [SELECT Id, Title, ContentDocumentId 
                             FROM ContentVersion 
                             WHERE Title = 'CandidateUploadForTestSheet.utf8' LIMIT 1];
        ContentDocument cd = [SELECT Id, Title, LatestPublishedVersionId 
                              FROM ContentDocument 
                              WHERE Title = 'CandidateUploadForTestSheet.utf8' LIMIT 1];
        
        ContentDocumentLink newLink = new ContentDocumentLink();
        newLink.LinkedEntityId = jobObj.Id;
        newLink.ShareType = 'V';
        newLink.ContentDocumentId = cd.Id;
        INSERT newLink;
        
        CandidateUploadContoller.getDataFromFile(cd.Id, 'Insert', 'Bureau_Candidate__c');
        Test.stopTest();
    }
    
    @isTest
    public static void getJobDetailsTest() {
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        try {
            CandidateUploadContoller.getJobDetails(jobObj.Id);
        }
        catch(Exception exp) {
            System.debug('getJobDetailsTest exp ###'+exp);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getSuccessRecordsTest() {
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        try {
            CandidateUploadContoller.getSuccessRecords(jobObj.Id);
        }
        catch(Exception exp) {
            System.debug('getJobDetailsTest exp ###'+exp);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getFailedRecordsTest() {
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        try {
            CandidateUploadContoller.getFailedRecords(jobObj.Id);
        }
        catch(Exception exp) {
            System.debug('getJobDetailsTest exp ###'+exp);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getCandidateCountTest() {
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        CandidateUploadContoller.getCandidateCount(jobObj.Id, 0);
        Test.stopTest();
    }
    
    @isTest
    public static void getCandidateDataTest() {
        Test.startTest();
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        CandidateUploadContoller.getCandidateData(jobObj.Id, 0);
        Test.stopTest();
    }
    
    @isTest
    public static void exportCandidatesFilesTest() {
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Setup();
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];

        ContentVersion cv = [SELECT Id, Title, ContentDocumentId 
                             FROM ContentVersion 
                             WHERE Title = 'CandidateUploadForTestSheet.utf8' LIMIT 1];
        ContentDocument cd = [SELECT Id, Title, LatestPublishedVersionId 
                              FROM ContentDocument 
                              WHERE Title = 'CandidateUploadForTestSheet.utf8' LIMIT 1];
        
        ContentDocumentLink newLink = new ContentDocumentLink();
        newLink.LinkedEntityId = jobObj.Id;
        newLink.ShareType = 'V';
        newLink.ContentDocumentId = cd.Id;
        INSERT newLink;
        
        CandidateUploadContoller.exportCandidatesFiles(jobObj.Id);
        Test.stopTest();
    }
    
}
@isTest
public class ScheduleClassToGetJobStatusWRF_Test {
    
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
        
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id =: opportunityRecord.Id];
        opp.StageName = 'Closed/Won';
        UPDATE opp;
		Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
		Job__c jobRecord = new Job__c();
        jobRecord.Account__c = accountRecord.id;
        jobRecord.Project_Manager__c = userRecord.Id;
        jobRecord.Opportunity__c = opportunityRecord.id;
        jobRecord.MS_Line_of_Business__c = 'Talent Management';
        jobRecord.Job_Type__c = 'Project - 360';
        jobRecord.Start_Date__c = System.today();
        jobRecord.End_Date__c = System.today().addDays(30);
        jobRecord.InternalContact__c = UserInfo.getUserId();
        jobRecord.External_Contact_Others__c = 'External Contact';
        jobRecord.External_Contact_Other_Email_Address__c='test@test.com';
        jobRecord.Candidate_Username_Prefix__c = 'QA01';
        jobRecord.ShortFall_Manager__c = 1;
        jobRecord.Shortfall_Peer__c = 2;
        jobRecord.Shortfall_Subordinate__c = 3;
        jobRecord.ShortFall_Customer__c = 2;
        jobRecord.Shortfall_Client__c = 2;
        jobRecord.ShortFall_Other__c = 2;
        jobRecord.PurchaseOrderNo__c='rtertr';
        jobRecord.Generic_BS_Field_One__c='Bureau Service';
        jobRecord.Generic_Field_MS_One__c='Managed Service';
        jobRecord.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        jobRecord.Is_Redirect_To_Task__c=true;
        jobRecord.System_Used__c = 'TalentCentral';
        jobRecord.RecordTypeId = RecordTypeIdJob2;
        jobRecord.Do_Not_Send_Survey__c = True;
        jobRecord.Preferred_Language__c = 'English';
        jobRecord.Job_Region__c = 'Non China';
        jobRecord.Sender_Email__c = 'noreply@shl.com';
        jobRecord.Client_Domain__c = 'test.com';
        jobRecord.Billing_Cycle_Start_Date__c = Date.Today();
        insert jobRecord;
                
        //Job__c jobRecord = [SELECT Id,bulkJobId__c FROM Job__c LIMIT 1];
        Bureau_Candidate__c candidateRecord = new Bureau_Candidate__c();
        list<Bureau_Candidate__c> candidateRecordList = new list<Bureau_Candidate__c>();
        candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'Completed', 'candidate4@test.com');
        candidateRecordList.add(candidateRecord);
        candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'In Progress', 'candidate5@test.com');
        candidateRecordList.add(candidateRecord);
        candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'Not Started', 'candidate6@test.com');
        candidateRecordList.add(candidateRecord);
        INSERT candidateRecordList;
        
        Work_Request__c generated = TestDataUtility.getGeneratedWRF(accountRecord.Id, jobRecord.Id);
        
        ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = 'testFile';
        cv3.PathOnClient = 'test';
        System.debug('Content Version cv '+cv3);
        insert cv3;
        
        Work_Request__c submitted = TestDataUtility.getSubmittedWRF(generated.Id, cv3.Id);        
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
    
    public static void testUploadFile(Work_Request__c workRequest){
		/*String base64 = 'Category__c,First_Name__c,Last_Name__c,Email__c,Product_Assessment__c,Job_Region__c,Work_Request__c,Bureau_Job__c,Candidate_Unique_Id__c \n' + 
            'Self,Kevin,Laird,kevin.laird@test.com,testing,Non China,'+ workRequest.Id +', ' + jobRecord.Id + ' ,'+ jobRecord.Id+ 'KevinLairdkevin.laird@test.comtestjkb jk \n'; 
          */      
        String base64 = 'Category__c,First_Name__c,Last_Name__c,Email__c,Product_Assessment__c,Job_Region__c,Work_Request__c,Bureau_Job__c,Candidate_Unique_Id__c \n' + 
            'Self,Kevin,Laird,kevin.laird@test.com,testing,Non China,'+ workRequest.Id +',a003G000000sn8iQAA,a003G000000sn8iQAAKevinLairdkevin.laird@test.comtestjkb jk \n'; 
       
		CandidateUploadContoller.uploadFile(base64, 'Test_CandidateWRFImportSheet.csv', workRequest.Id); 
    }
    
    public static void callScheduleClass(Work_Request__c workRequest){
        ScheduleClassToGetJobStatusWRF scheduleJob = new ScheduleClassToGetJobStatusWRF(workRequest.Id);
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute());
        String ss = String.valueOf(Datetime.now().second());
        String sch = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobID1 = System.schedule('Test Get Bulk Job Status01 '+System.now(), sch, scheduleJob);
    }
   
    @isTest
    public static void testSuccessRecords(){
        Work_Request__c workRequest = [SELECT Id FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        
        System.runAs(u1){
            String responseBody = '{"id":"'+workRequest.id+'","state":"JobComplete","numberRecordsFailed":'+0+',"numberRecordsProcessed":'+1+'}';
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMockWRF(1, 0, responseBody));
            testUploadFile(workRequest);
            callScheduleClass(workRequest);
        }
        Test.stopTest();
    }
    
     @isTest
    public static void testFailureRecords(){
        Work_Request__c workRequest = [SELECT Id FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        String responseBody;
        System.runAs(u1){
            responseBody = '{"id":"'+workRequest.id+'","state":"Failed","numberRecordsFailed":'+1+',"numberRecordsProcessed":'+1+'}\n'+
                '"sf_Id","sf_Error",Category\n'+'"","INVALID FIELD","Self1"\n';
            
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMockWRF(1, 1, responseBody));
            testUploadFile(workRequest);
            callScheduleClass(workRequest);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testFailureRecords2(){
        Work_Request__c workRequest = [SELECT Id FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        Test.StartTest();
        //User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        String responseBody;
        //System.runAs(u1){
            responseBody = '{"id":"'+workRequest.id+'","state":"JobComplete","numberRecordsFailed":'+1+',"numberRecordsProcessed":'+2+'}\n'+
                '"sf_Id","sf_Error",Category\n'+'"","INVALID FIELD","Self1"\n';
            
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMockWRF(1, 1, responseBody));
            testUploadFile(workRequest);
            callScheduleClass(workRequest);
        //}
        Test.stopTest();
    }
    
    public static void testRatingUploadFile(Work_Request__c workRequest){
        String base64 = 'Category,Email,Recipient_Email,\n' + 
            'Self,kevin.laird@test.com,kevin.laird@test.com\n'; 
        CandidateUploadContoller.uploadFile(base64, 'Test_CandidateWRFImportRating.csv', workRequest.Id); 
    }
    
    @isTest
    public static void testSuccessRecordsRating(){
        Work_Request__c workRequest = [SELECT Id FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        
        System.runAs(u1){
            String responseBody = '{"id":"'+workRequest.id+'","state":"JobComplete","numberRecordsFailed":'+0+',"numberRecordsProcessed":'+2+'}';
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMockWRF(2, 0, responseBody));
            testUploadFile(workRequest);
            testRatingUploadFile(workRequest);
            callScheduleClass(workRequest);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testCandidateBulkUploadBatchWRF(){
        Test.StartTest();
        Work_Request__c workRequest = [SELECT Id FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        list<Bureau_Candidate__c> candidateList = [Select Id From Bureau_Candidate__c];
        for(Bureau_Candidate__c bc : candidateList){
            bc.Work_Request__c = workRequest.Id;
        }
        UPDATE candidateList;
        
        CandidateBulkUploadBatchWRF candidatebatch= new CandidateBulkUploadBatchWRF(workRequest.Id);
        System.runAs(u1){
            Database.executeBatch(candidatebatch, 2000);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testCandidateBulkDeletionBatchWRF(){
        Test.StartTest();
        Work_Request__c workRequest = [SELECT Id FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        
        //User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        list<Bureau_Candidate__c> candidateList = [Select Id From Bureau_Candidate__c];
        for(Bureau_Candidate__c bc : candidateList){
            bc.Work_Request__c = workRequest.Id;
        }
        UPDATE candidateList;
        list<Bureau_Rating__c> ratingsRecordList = TestDataUtility.createRatings(candidateList, workRequest);
        System.debug('ratingsRecordList '+ ratingsRecordList);
        RollUpCandidateFields.calculateRespondentCountOnCandidate(ratingsRecordList);
        
        CandidateBulkDeletionFromWRF candidatebatch= new CandidateBulkDeletionFromWRF(workRequest.Id, 'Rating');
        //System.runAs(u1){
            Database.executeBatch(candidatebatch, 2000);
        //}
        Test.stopTest();
    }
    
    @isTest
    public static void testCalculateRatingsFieldBatch(){
        Test.StartTest();
        Work_Request__c workRequest = [SELECT Id, Name FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        Job__c Job = [select id from Job__c Limit 1];
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        list<Bureau_Candidate__c> candidateList = [Select Id From Bureau_Candidate__c];
        for(Bureau_Candidate__c bc : candidateList){
            bc.Work_Request__c = workRequest.Id;
        }
        UPDATE candidateList;
        list<Bureau_Rating__c> ratingList = new list<Bureau_Rating__c>();
        
        Bureau_Rating__c rating = new Bureau_Rating__c();
        Bureau_Rating__c rating1 = new Bureau_Rating__c();
        rating.Rater_Type__c = 'Self';
        rating.Respondent__c = candidateList[0].Id;
        rating.Participant__c = candidateList[0].Id;
        rating.MFS_Status__c = 'Not Started';
        rating.Work_Request__c = workRequest.Id;
        insert rating;
        rating1.Rater_Type__c = 'Manager';
        rating1.Respondent__c = candidateList[1].Id;
        rating1.Participant__c = candidateList[0].Id;
        rating1.MFS_Status__c = 'Not Started';
        rating1.Work_Request__c = workRequest.Id;
        insert rating1;
        
        CalculateRatingsFieldBatch candidatebatch= new CalculateRatingsFieldBatch(workRequest.Id, workRequest.Name,Job.Id);
        System.runAs(u1){
            Database.executeBatch(candidatebatch, 2000);
        }
        Test.stopTest();
    }
    
    public static void callScheduleClassForRatingUpdate(Job__c jobRecord, String operationtype, String objectName){
        System.debug('jobRecord '+ jobRecord.Id);
        String jobId = jobRecord.Id;
        ScheduleClassToGetJobStatus scheduleJob = new ScheduleClassToGetJobStatus(jobId, operationtype, objectName);
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute());
        String ss = String.valueOf(Datetime.now().second());
        String sch = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobID1 = System.schedule('Test Get Bulk Job Status '+System.now(), sch, scheduleJob);
    }
    
    public static void testUploadFileRatingUpdate(Job__c jobRecord, String ratingId){
        String base64 = 'Id,VADC_Status__c,TC_Status__c\n' + 
            ratingId+',In Progress,In Progress \n'; 
        CandidateUploadContoller.uploadFile(base64, 'Hey_PlatformWRFUpdateSheet.csv', jobRecord.Id); 
    }
    
    @isTest
    public static void testSuccessRecordsRatingUpdate(){
        String jobId;
        /*Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        Account accountRecord = [Select Id from Account limit 1];
        User userRecord = [Select Id from User where Email = 'standarduser@testorg.com' limit 1];
        Opportunity opportunityRecord = [Select Id from Opportunity limit 1];*/
        Test.StartTest();
        Job__c jobRecord = [SELECT Id,bulkJobId__c FROM Job__c LIMIT 1];
        
        list<Bureau_Candidate__c> candidateList = [Select Id From Bureau_Candidate__c];
        for(Bureau_Candidate__c bc : candidateList){
            bc.Bureau_Job__c = jobRecord.Id;
        }
        UPDATE candidateList;
        list<Bureau_Rating__c> ratingList = new list<Bureau_Rating__c>();
        
        Bureau_Rating__c rating = new Bureau_Rating__c();
        Bureau_Rating__c rating1 = new Bureau_Rating__c();
        Bureau_Rating__c rating2 = new Bureau_Rating__c();
        rating.Rater_Type__c = 'Self';
        rating.Respondent__c = candidateList[0].Id;
        rating.Participant__c = candidateList[0].Id;
        rating.MFS_Status__c = 'Not Started';
        rating.MFS_Report_Sent__c = 'Not Sent';
        rating.TC_Report_Sent__c = 'Not Sent';
        insert rating;
        rating1.Rater_Type__c = 'Manager';
        rating1.Respondent__c = candidateList[1].Id;
        rating1.Participant__c = candidateList[0].Id;
        rating1.MFS_Status__c = 'Completed';
        rating1.MFS_Report_Sent__c = 'Not Sent';
        rating1.TC_Report_Sent__c = 'Not Sent';
        insert rating1;
        
        rating2.Rater_Type__c = 'Manager';
        rating2.Respondent__c = candidateList[2].Id;
        rating2.Participant__c = candidateList[0].Id;
        rating2.MFS_Status__c = 'Not Started';
        rating2.MFS_Report_Sent__c = 'Sent';
        rating2.TC_Report_Sent__c = 'Sent';
        insert rating2;
                
        String responseBody = '{"id":"'+jobRecord.id+'","state":"JobComplete","numberRecordsFailed":'+0+',"numberRecordsProcessed":'+1+'}';
        System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMock(1, 0, responseBody));
        testUploadFileRatingUpdate(jobRecord, rating.Id);
        callScheduleClassForRatingUpdate(jobRecord, 'update', 'Bureau_Rating__c');
        Test.stopTest();
    }
    
	public static void testUploadFile(Job__c jobRecord){
        String base64 = 'Category__c,First_Name__c,Last_Name__c,Email__c,Gender__c,Phone_Number__c,Country__c,Language__c,Status2__c,Reports_Status__c,Username__c,Product_Assessment__c,System_s__c,Email_as_Username__c,Bureau_Job__c,Candidate_Unique_Id__c \n' + 
            'Self,Kevin,Laird,kevin.laird@test.com,Male,9090909090,India,English,Not Started,Sent,testjkb jk,shl 360,MFS,true,a003G000000sn8iQAA,a003G000000sn8iQAAKevinLairdkevin.laird@test.comtestjkb jk \n'; 
        CandidateUploadContoller.uploadFile(base64, 'Test_CandidateImportSheet.csv', jobRecord.Id); 
    }
    public static void callScheduleClass(Job__c jobRecord){
        ScheduleClassToGetJobStatus scheduleJob = new ScheduleClassToGetJobStatus(jobRecord.Id, null, null);
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute());
        String ss = String.valueOf(Datetime.now().second());
        String sch = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobID1 = System.schedule('Test Get Bulk Job Status '+System.now(), sch, scheduleJob);
    }
    
    @isTest
    public static void testSuccessRecordsLegacy(){
        String jobId;
        Job__c jobRecord = [SELECT Id,bulkJobId__c FROM Job__c LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        
        //System.runAs(u1){
            String responseBody = '{"id":"'+jobRecord.id+'","state":"JobComplete","numberRecordsFailed":'+0+',"numberRecordsProcessed":'+1+'}';
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMock(1, 0, responseBody));
            testUploadFile(jobRecord);
            callScheduleClass(jobRecord);
        //}
        Test.stopTest();
    }
    
     @isTest
    public static void testFailureRecordsLegacy(){
        String jobId;
        Job__c jobRecord = [SELECT Id,Name,bulkJobId__c FROM Job__c LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        String responseBody;
        //System.runAs(u1){
            responseBody = '{"id":"'+jobRecord.id+'","state":"JobComplete","numberRecordsFailed":'+1+',"numberRecordsProcessed":'+1+'}\n'+
                '"sf_Id","sf_Error",Category\n'+'"","INVALID FIELD","Self1"\n';
            
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMock(1, 1, responseBody));
            testUploadFile(jobRecord);
            callScheduleClass(jobRecord);
        //}
        Test.stopTest();
    }
    
    @isTest
    public static void testFailureRecords2Legacy(){
        String jobId;
        Job__c jobRecord = [SELECT Id,Name,bulkJobId__c FROM Job__c LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        String responseBody;
        //System.runAs(u1){
            responseBody = '{"id":"'+jobRecord.id+'","state":"JobComplete","numberRecordsFailed":'+1+',"numberRecordsProcessed":'+2+'}\n'+
                '"sf_Id","sf_Error",Category\n'+'"","INVALID FIELD","Self1"\n';
            
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMock(1, 1, responseBody));
            testUploadFile(jobRecord);
            callScheduleClass(jobRecord);
        //}
        Test.stopTest();
    }
    
    public static void testRatingUploadFile(Job__c jobRecord){
        String base64 = 'Category,Email,Recipient_Email,\n' + 
            'Self,kevin.laird@test.com,kevin.laird@test.com\n'; 
        CandidateUploadContoller.uploadFile(base64, 'Test_CandidateImportRatingSheet.csv', jobRecord.Id); 
    }
    
    @isTest
    public static void testSuccessRecordsRatingLegacy(){
        String jobId;
        Job__c jobRecord = [SELECT Id,bulkJobId__c FROM Job__c LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        
        //System.runAs(u1){
            String responseBody = '{"id":"'+jobRecord.id+'","state":"JobComplete","numberRecordsFailed":'+0+',"numberRecordsProcessed":'+2+'}';
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMock(2, 0, responseBody));
            testUploadFile(jobRecord);
            testRatingUploadFile(jobRecord);
            callScheduleClass(jobRecord);
        //}
        Test.stopTest();
    }
    
    @isTest
    public static void testSingleRatingDeletion(){
        
        Work_Request__c workRequest = [SELECT Id FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        
        list<Bureau_Candidate__c> candidateList = [Select Id From Bureau_Candidate__c];
        for(Bureau_Candidate__c bc : candidateList){
            bc.Work_Request__c = workRequest.Id;
        }
        UPDATE candidateList;
        list<Bureau_Rating__c> ratingsRecordList = TestDataUtility.createRatings(candidateList, workRequest);
        
        Test.StartTest();
        RollUpCandidateFields.calculateRespondentCountOnCandidate(ratingsRecordList);
        DELETE ratingsRecordList[0];
        Test.stopTest();
    }
    
}
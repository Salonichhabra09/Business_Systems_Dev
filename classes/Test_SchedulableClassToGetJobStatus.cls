@isTest
public class Test_SchedulableClassToGetJobStatus {
    
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
        createTriggerActivationCustomSettingRecords('ContentDocument', 'ContentDocument_Trigger');
        createTriggerActivationCustomSettingRecords('ContentDocumentLink', 'ContentDocumentLink_Trigger');
        
        User userRecord = TestDataUtility.getUser('Managed Service Lightning');
        userRecord.MS_LOB__c = 'TA - Corporate, TA - Credentialing, Talent Management, TA - Vocational (Batch) & TA - Vocational (School)';
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
        
        Job__c jobRecord = [SELECT Id,bulkJobId__c FROM Job__c LIMIT 1];
        Bureau_Candidate__c candidateRecord = new Bureau_Candidate__c();
        list<Bureau_Candidate__c> candidateRecordList = new list<Bureau_Candidate__c>();
        candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'Pass', 'candidate1@test.com');
        candidateRecordList.add(candidateRecord);
        candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'Fail', 'candidate2@test.com');
        candidateRecordList.add(candidateRecord);
        candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'DNA', 'candidate3@test.com');
        candidateRecordList.add(candidateRecord);
        candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'Completed', 'candidate4@test.com');
        candidateRecordList.add(candidateRecord);
        candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'In Progress', 'candidate5@test.com');
        candidateRecordList.add(candidateRecord);
        candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'Not Started', 'candidate6@test.com');
        candidateRecordList.add(candidateRecord);
        INSERT candidateRecordList;
        
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
    
    public static void testUploadFile(Job__c jobRecord){
        String base64 = 'Category__c,First_Name__c,Last_Name__c,Email__c,Gender__c,Phone_Number__c,Country__c,Language__c,Status2__c,Reports_Status__c,Username__c,Product_Assessment__c,System_s__c,Email_as_Username__c,Bureau_Job__c,Candidate_Unique_Id__c \n' + 
            'Self,Kevin,Laird,kevin.laird@test.com,Male,9090909090,India,English,Not Started,Sent,testjkb jk,shl 360,MFS,true,a003G000000sn8iQAA,a003G000000sn8iQAAKevinLairdkevin.laird@test.comtestjkb jk \n'; 
        CandidateUploadContoller.uploadFile(base64, 'Test_CandidateImportSheet.csv', jobRecord.Id); 
    }
    
    public static void callScheduleClass(Job__c jobRecord){
        ScheduleClassToGetJobStatus scheduleJob = new ScheduleClassToGetJobStatus(jobRecord.Id);
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute());
        String ss = String.valueOf(Datetime.now().second());
        String sch = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobID1 = System.schedule('Test Get Bulk Job Status '+System.now(), sch, scheduleJob);
    }
    
    @isTest
    public static void testSuccessRecords(){
        String jobId;
        Job__c jobRecord = [SELECT Id,bulkJobId__c FROM Job__c LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        
        System.runAs(u1){
            String responseBody = '{"id":"'+jobRecord.id+'","state":"JobComplete","numberRecordsFailed":'+0+',"numberRecordsProcessed":'+1+'}';
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMock(1, 0, responseBody));
            testUploadFile(jobRecord);
            callScheduleClass(jobRecord);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testFailureRecords(){
        String jobId;
        Job__c jobRecord = [SELECT Id,Name,bulkJobId__c FROM Job__c LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        String responseBody;
        System.runAs(u1){
            responseBody = '{"id":"'+jobRecord.id+'","state":"JobComplete","numberRecordsFailed":'+1+',"numberRecordsProcessed":'+1+'}\n'+
                '"sf_Id","sf_Error",Category\n'+'"","INVALID FIELD","Self1"\n';
            
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMock(1, 1, responseBody));
            testUploadFile(jobRecord);
            callScheduleClass(jobRecord);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testFailureRecords2(){
        String jobId;
        Job__c jobRecord = [SELECT Id,Name,bulkJobId__c FROM Job__c LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        String responseBody;
        System.runAs(u1){
            responseBody = '{"id":"'+jobRecord.id+'","state":"JobComplete","numberRecordsFailed":'+1+',"numberRecordsProcessed":'+2+'}\n'+
                '"sf_Id","sf_Error",Category\n'+'"","INVALID FIELD","Self1"\n';
            
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMock(1, 1, responseBody));
            testUploadFile(jobRecord);
            callScheduleClass(jobRecord);
        }
        Test.stopTest();
    }
    
    public static void testRatingUploadFile(Job__c jobRecord){
        String base64 = 'Category,Email,Recipient_Email,\n' + 
            'Self,kevin.laird@test.com,kevin.laird@test.com\n'; 
        CandidateUploadContoller.uploadFile(base64, 'Test_CandidateImportRatingSheet.csv', jobRecord.Id); 
    }
    
    @isTest
    public static void testSuccessRecordsRating(){
        String jobId;
        Job__c jobRecord = [SELECT Id,bulkJobId__c FROM Job__c LIMIT 1];
        Test.StartTest();
        User u1 = [SELECT id from User WHERE email = 'standarduser@testorg.com' LIMIT 1];
        
        System.runAs(u1){
            String responseBody = '{"id":"'+jobRecord.id+'","state":"JobComplete","numberRecordsFailed":'+0+',"numberRecordsProcessed":'+2+'}';
            System.Test.setMock(HttpCalloutMock.class, new SchedulableClassMock(2, 0, responseBody));
            testUploadFile(jobRecord);
            testRatingUploadFile(jobRecord);
            callScheduleClass(jobRecord);
        }
        Test.stopTest();
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
        manageBureauRatingProgressInsert_Batch class11 = new manageBureauRatingProgressInsert_Batch();
    }
    
}
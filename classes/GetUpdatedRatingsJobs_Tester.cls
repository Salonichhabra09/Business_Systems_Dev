@isTest
public class GetUpdatedRatingsJobs_Tester {

    @testSetup
    static void setup() {
        
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
        jobRecord.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        jobRecord.System_Used__c ='SHL ONLINE';
        jobRecord.RecordTypeId = RecordTypeIdJob2;
        jobRecord.Do_Not_Send_Survey__c = True;
        jobRecord.Preferred_Language__c = 'English';
        jobRecord.Job_Region__c = 'Non China';
        jobRecord.Sender_Email__c = 'noreply@shl.com';
        jobRecord.Client_Domain__c = 'test.com';
        jobRecord.Billing_Cycle_Start_Date__c = Date.Today();
        jobRecord.Candidate_Transfer_Status__c = 'Ready to transfer';
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
    
    
    @isTest
    public static void testGetUpdatedRatingsJobs(){
        
        Work_Request__c workRequest = [SELECT Id FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        
        list<Bureau_Candidate__c> candidateList = [Select Id From Bureau_Candidate__c];
        for(Bureau_Candidate__c bc : candidateList){
            bc.Work_Request__c = workRequest.Id;
        }
        UPDATE candidateList;
        /*Job__c job =[select id,Candidate_Transfer_Status__c from Job__c limit 1];  
        job.Candidate_Transfer_Status__c = 'Ready to transfer';
        update job;*/
        list<Bureau_Rating__c> ratingsRecordList = TestDataUtility.createRatings(candidateList, workRequest);
		       
        Test.StartTest();
        ratingsRecordList[0].Rating_transfer_status__c = 'Transferred';
        update ratingsRecordList[0];
        GetUpdatedRatingsJobs batch = new GetUpdatedRatingsJobs();
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteScheduledClass() {
        // Create an instance of the class
        ScheduleClassToUpdateConvayrStatusOnJob schedulableInstance = new ScheduleClassToUpdateConvayrStatusOnJob();

        // Schedule the job to run in the test context
        String jobId = System.schedule(
            'Test Scheduled Job',
            '0 0 1 * * ?',  // This is a CRON expression (runs at 1 AM daily)
            schedulableInstance
        );

        // Get the scheduled job and assert that it's not null
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, ct);
        System.assertEquals('0 0 1 * * ?', ct.CronExpression);
    }



}
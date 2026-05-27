@isTest
public class RollUpCandidateFieldsTest {

    @isTest
    public static void testCoutFields() {
        Test.startTest();
        Job__c vocationalJob = createJobFun('TA - Vocational (Batch)');
        Job__c corporateJob = createJobFun('TA - Corporate');
        
        List<String> vocationalStatus = new List<String>();
        List<String> corporateStatus = new List<String>();
        
        vocationalStatus.add('Pass');
        vocationalStatus.add('Fail');
        vocationalStatus.add('DNA');
        
        corporateStatus.add('Completed');
        corporateStatus.add('In Progress');
        corporateStatus.add('Not Started');
        
        Map<Id, Bureau_Candidate__c> vocationalMap = createCandidate(vocationalJob.Id, vocationalStatus);
        Map<Id, Bureau_Candidate__c> corporateMap = createCandidate(corporateJob.Id, corporateStatus);
        
        RollUpCandidateFields.calculateCountFields(vocationalMap);
        RollUpCandidateFields.calculateCountFields(corporateMap);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testCoutFieldsPrefilledValues() {
        Test.startTest();
        
        Job__c vocationalJob = createJobFun('TA - Vocational (Batch)');
        vocationalJob.Count_of_Candidates_pass__c = 1;
        vocationalJob.Count_of_Candidates_fail__c = 1;
        vocationalJob.Count_of_Candidates_DNA__c = 1;
        UPDATE vocationalJob;
        
        Job__c corporateJob = createJobFun('TA - Corporate');
        corporateJob.Actual_Count_of_Candidates_PassFail__c = 1;
        corporateJob.Count_of_candidates_invited__c = 1;
        UPDATE corporateJob;
        
        List<String> vocationalStatus = new List<String>();
        List<String> corporateStatus = new List<String>();
        
        vocationalStatus.add('Pass');
        vocationalStatus.add('Fail');
        vocationalStatus.add('DNA');
        
        corporateStatus.add('Completed');
        corporateStatus.add('In Progress');
        corporateStatus.add('Not Started');
        
        Map<Id, Bureau_Candidate__c> vocationalMap = createCandidate(vocationalJob.Id, vocationalStatus);
        
        Map<Id, Bureau_Candidate__c> corporateMap = createCandidate(corporateJob.Id, corporateStatus);
        
        RollUpCandidateFields.calculateCountFields(vocationalMap);
        RollUpCandidateFields.calculateCountFields(corporateMap);
        
        Test.stopTest();
    }
    
    @isTest
    public static void updateCandidateMaxSeqNoOnDeleteTest() {
        Test.startTest();
        
        Job__c vocationalJob = createJobFun('TA - Vocational (Batch)');
        vocationalJob.Candidate_Max_Sequence_No_New__c = 20;
        vocationalJob.Count_of_Candidates_pass__c = 5;
        vocationalJob.Count_of_Candidates_fail__c = 5;
        vocationalJob.Count_of_Candidates_DNA__c = 5;
        UPDATE vocationalJob;
        
        Job__c corporateJob = createJobFun('TA - Corporate');
        corporateJob.Candidate_Max_Sequence_No_New__c = 20;
        corporateJob.Actual_Count_of_Candidates_PassFail__c = 10;
        corporateJob.Count_of_candidates_invited__c = 10;
        UPDATE corporateJob;
        
        List<String> vocationalStatus = new List<String>();
        List<String> corporateStatus = new List<String>();
        
        vocationalStatus.add('Pass');
        vocationalStatus.add('Fail');
        vocationalStatus.add('DNA');
        
        corporateStatus.add('Completed');
        corporateStatus.add('In Progress');
        corporateStatus.add('Not Started');
        
        Map<Id, Bureau_Candidate__c> vocationalMap = createCandidate(vocationalJob.Id, vocationalStatus);
        
        Map<Id, Bureau_Candidate__c> corporateMap = createCandidate(corporateJob.Id, corporateStatus);
        
        RollUpCandidateFields.updateCandidateMaxSeqNoOnDelete(vocationalMap.values());
        RollUpCandidateFields.updateCandidateMaxSeqNoOnDelete(corporateMap.values());
        
        Test.stopTest();
    }
    
    @isTest
    public static void updateCountsOnJobTest() {
        Test.startTest();
        
        Map<Id, Bureau_Candidate__c> candidateMap = new Map<Id, Bureau_Candidate__c>();
        
        Job__c vocationalJob = createJobFun('TA - Vocational (Batch)');
        vocationalJob.Candidate_Max_Sequence_No_New__c = 20;
        vocationalJob.Count_of_Candidates_pass__c = 5;
        vocationalJob.Count_of_Candidates_fail__c = 5;
        vocationalJob.Count_of_Candidates_DNA__c = 5;
        UPDATE vocationalJob;
        
        Job__c corporateJob = createJobFun('TA - Corporate');
        corporateJob.Candidate_Max_Sequence_No_New__c = 20;
        corporateJob.Actual_Count_of_Candidates_PassFail__c = 10;
        corporateJob.Count_of_candidates_invited__c = 10;
        UPDATE corporateJob;
        
        List<String> vocationalStatus = new List<String>();
        List<String> corporateStatus = new List<String>();
        
        vocationalStatus.add('Pass');
        vocationalStatus.add('Fail');
        vocationalStatus.add('DNA');
        
        corporateStatus.add('Completed');
        corporateStatus.add('In Progress');
        corporateStatus.add('Not Started');
        
        Map<Id, Bureau_Candidate__c> oldvocationalMap = createCandidate(vocationalJob.Id, vocationalStatus);
        for(Bureau_Candidate__c candidate : oldvocationalMap.values()) {
            if(candidate.Status2__c == 'Pass') {
                candidate.Status2__c = 'Fail';
            }
            if(candidate.Status2__c == 'Fail') {
                candidate.Status2__c = 'DNA';
            }
            if(candidate.Status2__c == 'DNA') {
                candidate.Status2__c = 'Pass';
            }
            candidateMap.put(candidate.Id, candidate);
        }
       
        Map<Id, Bureau_Candidate__c> oldcorporateMap = createCandidate(corporateJob.Id, corporateStatus);
        for(Bureau_Candidate__c candidate : oldcorporateMap.values()) {
            if(candidate.Status2__c == 'Completed') {
                candidate.Status2__c = 'In Progress';
            }
            if(candidate.Status2__c == 'In Progress') {
                candidate.Status2__c = 'Not Started';
            }
            if(candidate.Status2__c == 'Not Started') {
                candidate.Status2__c = 'Completed';
            }
            candidateMap.put(candidate.Id, candidate);
        }
        
        UPDATE candidateMap.values();
        
        Map<Id, Bureau_Candidate__c> newCandidateVocationalList =  new Map<Id, Bureau_Candidate__c>([SELECT Id,
                                                                                                     Status2__c
                                                                                                     FROM Bureau_Candidate__c
                                                                                                     WHERE Id IN :candidateMap.keySet()]);
        
        
        RollUpCandidateFields.updateCountsOnJob(newCandidateVocationalList, candidateMap);
        
        Test.stopTest();
    }
    
    public static Map<Id, Bureau_Candidate__c> createCandidate(String jobId, List<String> statusList) {
        
        List<Bureau_Candidate__c> candidateList = new List<Bureau_Candidate__c>();
        Map<Id, Bureau_Candidate__c> candidateMap = new Map<Id, Bureau_Candidate__c>();
            for(String status : statusList) {
                Bureau_Candidate__c candidate = new Bureau_Candidate__c();
                candidate.First_Name__c = 'FirstName '+status;
                candidate.Last_Name__c = 'LastName '+status;
                candidate.Email__c = 'fn'+status.replaceAll('\\s+','')+'@gmail.com';
                candidate.Email2__c = 'fn'+status.replaceAll('\\s+','')+'@gmail.com';
                candidate.Bureau_Job__c = jobId;
                candidate.Status2__c = status;
                candidate.Job_Region__c = 'Non China';
                candidateList.add(candidate);
            }
        INSERT candidateList;
        
        for(Bureau_Candidate__c candidate : candidateList) {
            candidateMap.put(candidate.Id, candidate);
        }
        return candidateMap;
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
    public static Job__c createJobFun(String lob) {
        Account accountRecord =[Select Id from Account LIMIT 1];
        Opportunity opportunityRecord = [Select Id from Opportunity LIMIT 1];
        Job__c job = new Job__c();
        job.MS_Line_of_Business__c = lob;
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
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
        job.System_Used__c ='SHL ONLINE';
        job.Do_Not_Send_Survey__c = True;
        job.Preferred_Language__c = 'English';
        job.Job_Region__c = 'Non China';
        job.Opportunity__c = opportunityRecord.Id;
        job.Account__c = accountRecord.Id;
        insert job;
        
        return job;
    }
    
    @testSetup static void setup() {
        
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        //createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');  
        
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
        
    }
    
    @isTest
    public static void updateCountsOnManualCandidateCaretionWRFTest() {
        
        Test.startTest();
        
        Map<Id, Bureau_Candidate__c> candidateMap = new Map<Id, Bureau_Candidate__c>();
        
        Job__c vocationalJob = createJobFun('TA - Vocational (Batch)');
        vocationalJob.Candidate_Max_Sequence_No_New__c = 20;
        vocationalJob.Count_of_Candidates_pass__c = 5;
        vocationalJob.Count_of_Candidates_fail__c = 5;
        vocationalJob.Count_of_Candidates_DNA__c = 5;
        UPDATE vocationalJob;
        
        Job__c corporateJob = createJobFun('Talent Management');
        corporateJob.Candidate_Max_Sequence_No_New__c = 20;
        corporateJob.Actual_Count_of_Candidates_PassFail__c = 10;
        corporateJob.Count_of_candidates_invited__c = 10;
        UPDATE corporateJob;
        
        ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = '_ImportSheet';
        cv3.PathOnClient = 'test';
        System.debug('Content Version cv '+cv3);
        insert cv3;
        
        
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(corporateJob.Account__c, corporateJob.Id);
        Work_Request__c submittedRequest = TestDataUtility.getSubmittedWRF(generatedRequest.Id,cv3.Id);
        Work_Request__c workRequest = [SELECT Id FROM Work_Request__c WHERE Work_Request_Type__c = 'Client Submitted' LIMIT 1];
        
        List<String> vocationalStatus = new List<String>();
        List<String> corporateStatus = new List<String>();
        
        vocationalStatus.add('Pass');
        vocationalStatus.add('Fail');
        vocationalStatus.add('DNA');
        
        corporateStatus.add('Completed');
        corporateStatus.add('In Progress');
        corporateStatus.add('Not Started');
        
        Map<Id, Bureau_Candidate__c> oldvocationalMap = createCandidate(vocationalJob.Id, vocationalStatus);
        for(Bureau_Candidate__c candidate : oldvocationalMap.values()) {
            if(candidate.Status2__c == 'Pass') {
                candidate.Status2__c = 'Fail';
            }
            if(candidate.Status2__c == 'Fail') {
                candidate.Status2__c = 'DNA';
            }
            if(candidate.Status2__c == 'DNA') {
                candidate.Status2__c = 'Pass';
            }
            candidate.Work_Request__c = workRequest.Id;
            candidateMap.put(candidate.Id, candidate);
        }
       
        Map<Id, Bureau_Candidate__c> oldcorporateMap = createCandidate(corporateJob.Id, corporateStatus);
        for(Bureau_Candidate__c candidate : oldcorporateMap.values()) {
            if(candidate.Status2__c == 'Completed') {
                candidate.Status2__c = 'In Progress';
            }
            if(candidate.Status2__c == 'In Progress') {
                candidate.Status2__c = 'Not Started';
            }
            if(candidate.Status2__c == 'Not Started') {
                candidate.Status2__c = 'Completed';
            }
            candidate.Work_Request__c = workRequest.Id;
            candidateMap.put(candidate.Id, candidate);
        }
        
        UPDATE candidateMap.values();
        
        Map<Id, Bureau_Candidate__c> newCandidateVocationalList =  new Map<Id, Bureau_Candidate__c>([SELECT Id,Bureau_Job__c,Work_Request__c,
                                                                                                     Status2__c,Number_of_participants__c,
                                                                                                     Number_of_Product_Assessment__c,
                                                                                                     Number_of_Respondents__c
                                                                                                     FROM Bureau_Candidate__c
                                                                                                     WHERE Id IN :candidateMap.keySet()]);
        
        RollUpCandidateFields.calculateCountFieldsForManualCandidateLinking(newCandidateVocationalList);
        RollUpCandidateFields.updateRollupSummaryFieldsOnJobForManualCandidateLinking(newCandidateVocationalList.values());
        RollUpCandidateFields.deleteRollupSummaryFieldsOnWRF(newCandidateVocationalList.values());
        RollUpCandidateFields.deleteRollupSummaryFieldsOnJob(newCandidateVocationalList.values());
        RollUpCandidateFields.updateRollupSummaryFieldsJobUpdate(newCandidateVocationalList.values(), candidateMap);
        CandidateBulkUploadBatch candidatebatch= new CandidateBulkUploadBatch(corporateJob.Id,'update','Bureau_Rating__c');
      	Database.executeBatch(candidatebatch, 2000);
        Test.stopTest();
    }
}
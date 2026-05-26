@isTest
public class CandidateRatingManager_Test {
    
    @TestSetup
    static void makeData(){

        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');

        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Rating__c', 'MS_Rating_Trigger');
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Rating__c', 'MS_Rating_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Candidate__c', 'Bureau_Candidate_Trigger');

        AutomaticJobCreation__c autoJobCreation = new AutomaticJobCreation__c();
        autoJobCreation.Name = 'Values';
        autoJobCreation.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        Insert autoJobCreation;
        

        Account accountRecord = TestDataUtility.getAccount();
        Insert accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        Insert contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord.Business_Type__c='Expansion';
        Insert opportunityRecord;

        Job__c jobRecord = TestDataUtility.getManualJob(opportunityRecord.Id, null);
        jobRecord.MS_Line_of_Business__c = 'TA - Corporate';
        jobRecord.Job_Region__c = 'Non China';
        Insert jobRecord;

        TestDataUtility.insertProjectManagerUser('TA - Corporate');

        Bureau_Candidate__c candidateParticipantRecord = new Bureau_Candidate__c();
        candidateParticipantRecord.Bureau_Job__c = jobRecord.Id;
        candidateParticipantRecord.First_Name__c = 'Test';
        candidateParticipantRecord.Last_Name__c = 'Candidate 1';
        candidateParticipantRecord.Email__c = 'test1@test.com';
        candidateParticipantRecord.Username__c = 'test1@test.com';
        candidateParticipantRecord.Category__c = 'Self';
        candidateParticipantRecord.Job_Region__c = 'China';
        Insert candidateParticipantRecord;

        Bureau_Candidate__c candidateRespondentRecord = new Bureau_Candidate__c();
        candidateRespondentRecord.Bureau_Job__c = jobRecord.Id;
        candidateRespondentRecord.First_Name__c = 'Test';
        candidateRespondentRecord.Last_Name__c = 'Candidate 2';
        candidateRespondentRecord.Email__c = 'test2@test.com';
        candidateRespondentRecord.Username__c = 'test2@test.com';
        candidateRespondentRecord.Category__c = 'Self';
        candidateRespondentRecord.Job_Region__c = 'China';
        Insert candidateRespondentRecord;

        Bureau_Rating__c ratingRecord = new Bureau_Rating__c();
        ratingRecord.Participant__c = candidateParticipantRecord.Id;
        ratingRecord.Respondent__c = candidateParticipantRecord.Id;
        ratingRecord.Rater_Type__c = 'Self';
        ratingRecord.MFS_Status__c = 'Not Started';
        ratingRecord.TC_Status__c = 'Not Started';
        insert ratingRecord;
    }

    @isTest
    static void test_getRatingData() {
        Job__c jobRecord = [SELECT Id FROM Job__c LIMIT 1];
        User projectManagerUser = [SELECT Id FROM User WHERE MS_LOB__c = 'TA - Corporate' LIMIT 1];
        jobRecord.Project_Manager__c = projectManagerUser.Id;
        jobRecord.Job_Region__c = 'Non China';
        update jobRecord;
        CandidateRatingManager CandidateRatingManagerInstance = new CandidateRatingManager();
        CandidateRatingManager.getRatingData(jobRecord.Id, 0, '');
        CandidateRatingManager.getRatingData(jobRecord.Id, 0, 'Test');
    }
    
    @isTest
    static void test_getRatingDataForReportView() {
        Job__c jobRecord = [SELECT Id FROM Job__c LIMIT 1];
        User projectManagerUser = [SELECT Id FROM User WHERE MS_LOB__c = 'TA - Corporate' LIMIT 1];
        jobRecord.Project_Manager__c = projectManagerUser.Id;
        jobRecord.Job_Region__c = 'Non China';
        update jobRecord;
        CandidateRatingManager CandidateRatingManagerInstance = new CandidateRatingManager();
        CandidateRatingManager.getRatingDataForReportView('Id,Respondent__c','Id', jobRecord.Id, 0,null);
        //CandidateRatingManager.getRatingDataForReportView('Id', jobRecord.Id, 0, 'Test');
    }
    
    @isTest
    static void test_getRatingDataWrf() {
        Job__c jobRecord = [SELECT Id FROM Job__c LIMIT 1];
        User projectManagerUser = [SELECT Id FROM User WHERE MS_LOB__c = 'TA - Corporate' LIMIT 1];
        jobRecord.Project_Manager__c = projectManagerUser.Id;
        jobRecord.Job_Region__c = 'Non China';
        update jobRecord;
        CandidateRatingManager CandidateRatingManagerInstance = new CandidateRatingManager();
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, '', '', '', '');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, 'test', 'Not Started', 'Not Started', 'test');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, 'test', 'Not Started', '', '');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, 'test', '', 'Not Started', '');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, 'test', '', '', '');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, '', 'Not Started', '', '');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, '', '', 'Not Started', '');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, '', '', '', 'test');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, '', 'Not Started', 'Not Started', '');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, 'test', '', '', 'test');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, '', '', 'Not Started', 'test');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, '', 'Not Started', '', 'test');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, '', 'Not Started', 'Not Started', 'test');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, 'test', '', 'Not Started', 'test');
        CandidateRatingManager.getRatingDataWrf('Id', jobRecord.Id, 0, 'test', 'Not Started', '', 'test');
        List<String> fieldNames = new List<String>{'MFS_Status__c'};
        CandidateRatingManager.getPicklistValues('Bureau_Rating__c',fieldNames);
    }

    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        Insert recordToInsert;
    }

    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
}
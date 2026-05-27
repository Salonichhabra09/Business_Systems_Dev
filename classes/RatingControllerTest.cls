@isTest
public class RatingControllerTest {
    public static List<Bureau_Rating__c> ratingsList;
    public static List<Bureau_Rating__c> ratingsList1;
    public static List<Bureau_Candidate__c> bureauCandidateList;

    @testSetup
    static void setupTestData() {
        // Mock Trigger Activation
        Trigger_Activation__c triggerActivation = new Trigger_Activation__c(Name = 'Job_Trigger', Active__c = true);
        insert triggerActivation;

        Trigger_Activation__c triggerActivationrating = new Trigger_Activation__c(Name = 'MS_Rating_Trigger', Active__c = true);
        insert triggerActivationrating;

        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Job__c job = new Job__c(
            Job_Type__c = 'Project - 360',
            Start_Date__c = System.today(),
            End_Date__c = System.today().addDays(30),
            InternalContact__c = UserInfo.getUserId(),
            External_Contact_Others__c = 'External Contact',
            External_Contact_Other_Email_Address__c = 'test@test.com',
            RecordTypeId = RecordTypeIdJob1,
            Job_Region__c = 'Non China'
        );
        insert job;

        bureauCandidateList = new List<Bureau_Candidate__c>();
        Bureau_Candidate__c bureauCandidate = new Bureau_Candidate__c(
            Bureau_Job__c = job.id,
            First_Name__c = 'Ramesh',
            Last_Name__c = 'Dhull',
            Gender__c = 'Male',
            Country__c = 'India',
            Language__c = 'English',
            Email__c = 'abc@gmail.com'
        );
        bureauCandidateList.add(bureauCandidate);
		
		Bureau_Candidate__c bureauCandidate2 = new Bureau_Candidate__c(
            Bureau_Job__c = job.id,
            First_Name__c = 'Ramesh2',
            Last_Name__c = 'Dhull',
            Gender__c = 'Male',
            Country__c = 'India',
            Language__c = 'English',
            Email__c = 'abctest@gmail.com'
        );
        bureauCandidateList.add(bureauCandidate2);

        insert bureauCandidateList;

        ratingsList = new List<Bureau_Rating__c>();
        Bureau_Rating__c rating = new Bureau_Rating__c(
            Active__c = true,
            Participant__c = bureauCandidateList[0].id,
            Respondent__c = bureauCandidateList[0].id,
            Rater_Type__c = 'Self',
            TC_Status__c = 'Completed',
            MFS_Status__c = 'In Progress'
        );
        ratingsList.add(rating);
		
        insert ratingsList;
        
        Bureau_Rating__c rating2 = new Bureau_Rating__c();
        rating2.Active__c = true;
        rating2.Participant__c = bureauCandidateList[0].id;
        rating2.Respondent__c = bureauCandidateList[1].id;
        rating2.Rater_Type__c = 'Manager';
        rating2.TC_Status__c = 'Completed';
        rating2.MFS_Status__c = 'In Progress';
        insert rating2;
    }

    @isTest
    static void testGetRatingDataTCStatus() {
        if (Trigger_Activation__c.getInstance('Job_Trigger').Active__c) {
            List<AggregateResult> results = RatingController.getRatingDataTCStatus('Self', [SELECT Id FROM Job__c LIMIT 1].Id);
            System.assertEquals(1, results.size(), 'Expected 1 result for TC Status');
            System.assertEquals('Completed', results[0].get('TC_Status__c'));
        }
    }

    @isTest
    static void testGetRatingDataMFSStatus() {
        if (Trigger_Activation__c.getInstance('Job_Trigger').Active__c) {
            List<AggregateResult> results = RatingController.getRatingDataMFSStatus('Self', [SELECT Id FROM Job__c LIMIT 1].Id);
            System.assertEquals(1, results.size(), 'Expected 1 result for MFS Status');
            System.assertEquals('In Progress', results[0].get('MFS_Status__c'));
        }
    }

    @isTest
    static void testGetRatingDataSELFStatus() {
        if (Trigger_Activation__c.getInstance('Job_Trigger').Active__c) {
            List<AggregateResult> results = RatingController.getRatingDataSELFStatus('Self', [SELECT Id FROM Job__c LIMIT 1].Id);
            System.assertEquals(1, results.size(), 'Expected 1 result for SELF Status');
            System.assertEquals('In Progress', results[0].get('MFS_Status__c'));
        }
    }
    
    @isTest
    static void testGetDefaultRecordTypeId() {
        String recordTypeId = RatingController.getDefaultRecordTypeId('Job__c');
        System.assertNotEquals(null, recordTypeId, 'Record Type ID should not be null');
    }

    @isTest
    static void testGetPicklistValues() {
        List<String> picklistValues = RatingController.getPicklistValues('Bureau_Rating__c', 'TC_Status__c');
        System.assertNotEquals(0, picklistValues.size(), 'Picklist values should not be empty');
    }
}
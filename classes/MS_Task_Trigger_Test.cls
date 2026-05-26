@isTest
public class MS_Task_Trigger_Test {
    
    @TestSetup
    static void makeData(){
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');

        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createTriggerActivationCustomSettingRecords('MS_Task__c', 'MS_Task_Trigger');
        AutomaticJobCreation__c autoJobCreation = new AutomaticJobCreation__c();
        autoJobCreation.Name = 'Values';
        autoJobCreation.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        Insert autoJobCreation;
        

        Account accountRecord = TestDataUtility.getAccount();
        Insert accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        Insert contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        Insert opportunityRecord;

        Job__c jobRecord = TestDataUtility.getManualJob(opportunityRecord.Id, null);
        jobRecord.MS_Line_of_Business__c = 'TA - Corporate';
        Insert jobRecord;

        TestDataUtility.insertProjectManagerUser('TA - Corporate');
    }

    @isTest
    static void test_MS_Task_Trigger1() {

        Job__c jobRecord = [SELECT Id FROM Job__c LIMIT 1];
        User projectManagerUser = [SELECT Id FROM User WHERE MS_LOB__c = 'TA - Corporate' LIMIT 1];
        jobRecord.Project_Manager__c = projectManagerUser.Id;
        Update jobRecord;

        Id RecordTypeIdTask = Schema.SObjectType.MS_Task__c.getRecordTypeInfosByDeveloperName().get('Talent_Management').getRecordTypeId();

        MS_Task__c msTask = new MS_Task__c();
        msTask.Job__c = jobRecord.Id;
        msTask.Task_Category__c = 'Pre Launch';
        msTask.Task_Type__c = 'Other';
        msTask.Task_Date__c = System.today();
        msTask.Scheduled_Time__c = Time.newInstance(10, 0, 0, 0);
        msTask.Estimated_Time_Required__c = 10;
        msTask.UnScheduled__c = false; 
        msTask.Task_Status__c = 'Not Started';
        msTask.RecordTypeId = RecordTypeIdTask;
        insert msTask;

        // MS_TaskTriggerManager.UpdateTaskManagerPriority(new List<MS_Task__c>{msTask});

        msTask.Task_Status__c = 'Completed';
        msTask.Actual_Time_Taken__c = 100;
        update msTask;
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
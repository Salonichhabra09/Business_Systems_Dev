@isTest
public class TaskManagerController_Test {
    
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
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, UserInfo.getUserId());
        INSERT opportunityRecord;

        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        
        Job__c job = new Job__c();
        job.Opportunity__c = opportunityRecord.Id;
        job.Account__c = accountRecord.Id;
        job.MS_Line_of_Business__c = 'Talent Management';
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.InternalContact__c = UserInfo.getUserId();
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = 'Test';
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
        job.Job_Region__c='China';
        insert job;

        Id RecordTypeIdTask = Schema.SObjectType.MS_Task__c.getRecordTypeInfosByDeveloperName().get('Talent_Management').getRecordTypeId();

        MS_Task__c msTask = new MS_Task__c();
        msTask.RecordTypeId = RecordTypeIdTask;
        msTask.Task_Category__c = 'Pre Launch';
        msTask.Task_Type__c = 'Other';
        msTask.Task_Date__c = System.today();
        msTask.Scheduled_Time__c = Time.newInstance(10, 0, 0, 0);
        msTask.Estimated_Time_Required__c = 10;
        msTask.UnScheduled__c = false; 
        msTask.Task_Status__c = 'Not Started';
        insert msTask;

        TestDataUtility.insertQueue();

    }

    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }

    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }

    @isTest
    static void testGetTaskList() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        TaskManagerController.getTaskList(UserInfo.getUserId(), 'Not Started', job.Id);
        TaskManagerController.getTaskList('Prabhat', null, job.Id);
        TaskManagerController.getTaskList(null, null, job.Id);
    }

    @isTest
    static void testAssignTaskToCurrentUser() {
        Group queueRecord = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'group name' LIMIT 1];
        MS_Task__c msTask = [SELECT Id FROM MS_Task__c LIMIT 1];
        msTask.OwnerId = queueRecord.Id;
        update msTask;
        TaskManagerController.assignTaskToCurrentUser(msTask.Id);
    }

    @isTest
    static void testAssignTaskToCurrentUserException() {
        MS_Task__c msTask = [SELECT Id FROM MS_Task__c LIMIT 1];
        msTask.OwnerId = UserInfo.getUserId();
        update msTask;
        try{
            TaskManagerController.assignTaskToCurrentUser(msTask.Id);
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Script-thrown exception'), 'Unexpected Error');
        }
    }

    @isTest
    static void testCompleteTask() {
        // '2022-11-09T06:26:55.000Z'
        MS_Task__c msTask = [SELECT Id FROM MS_Task__c LIMIT 1];
        TaskManagerController.completeTask(msTask.Id, '2022-11-09T06:26:55.000Z', '2022-11-09T06:28:00.000Z', '2022-11-09T06:28:00.000Z');
        try {
            TaskManagerController.completeTask(msTask.Id, null, null, null);
        } catch(Exception ex) {
            System.assert(ex.getMessage().containsIgnoreCase('Script-thrown exception'), 'Unexpected Error');
        }
    }

    @isTest
    static void testCancelTask() {
        MS_Task__c msTask = [SELECT Id FROM MS_Task__c LIMIT 1];
        TaskManagerController.cancelTask(msTask.Id);
    }

    @isTest
    static void testStartTaskTimer() {
        MS_Task__c msTask = [SELECT Id FROM MS_Task__c LIMIT 1];
        TaskManagerController.startTaskTimer(msTask.Id, '2022-11-09T06:26:55.000Z');
        try {
            TaskManagerController.startTaskTimer(msTask.Id, null);
        } catch(Exception ex) {
            System.assert(ex.getMessage().containsIgnoreCase('Script-thrown exception'), 'Unexpected Error');
        }
    }

    @isTest
    static void testStopTaskTimer() {
        MS_Task__c msTask = [SELECT Id FROM MS_Task__c LIMIT 1];
        TaskManagerController.stopTaskTimer(msTask.Id, '2022-11-09T06:26:55.000Z');
        try {
            TaskManagerController.stopTaskTimer(msTask.Id, null);
        } catch(Exception ex) {
            System.assert(ex.getMessage().containsIgnoreCase('Script-thrown exception'), 'Unexpected Error');
        }
    }

    @isTest
    static void testResumeTaskTimer() {
        MS_Task__c msTask = [SELECT Id FROM MS_Task__c LIMIT 1];
        TaskManagerController.resumeTaskTimer(msTask.Id, '2022-11-09T06:26:55.000Z', '1000');
        try {
            TaskManagerController.resumeTaskTimer(msTask.Id, null, '1000');
        } catch(Exception ex) {
            System.assert(ex.getMessage().containsIgnoreCase('Script-thrown exception'), 'Unexpected Error');
        }
    }

    @isTest
    static void testUpdateTaskPriority() {
        MS_Task__c msTask = [SELECT Id FROM MS_Task__c LIMIT 1];
        TaskManagerController.updateTaskPriority(new List<MS_Task__c> {msTask});
    }

    @isTest
    static void testUpdateTaskRowData() {
        MS_Task__c msTask = [SELECT Id FROM MS_Task__c LIMIT 1];
        msTask.Comments__c = 'Test';
        TaskManagerController.updateTaskRowData(new List<MS_Task__c> {msTask});
    }

    @isTest
    static void testCloneTasks() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        MS_Task__c msTask = [SELECT Id, Task_Category__c, Task_Type__c, Task_Status__c, RecordTypeId FROM MS_Task__c LIMIT 1];
        msTask.Id = null;
        TaskManagerController.cloneTasks(JSON.serialize(new List<MS_Task__c>{msTask}), job.Id);
    }

    @isTest
    static void testCloneTasksException() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        MS_Task__c msTask = [SELECT Id, Task_Category__c, Task_Type__c, Task_Status__c FROM MS_Task__c LIMIT 1];
        msTask.Id = null;
        try {
            TaskManagerController.cloneTasks(JSON.serialize(new List<MS_Task__c>{msTask}), job.Id);
        } catch(Exception ex) {
            System.assert(ex.getMessage().containsIgnoreCase('Insert Failed'), 'Unexpected Error');
        }
    }
}
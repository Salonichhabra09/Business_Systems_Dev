@isTest
public class TaskSearchControllerTester {
	  
    Static  TestMethod void MultiSelectFlowValuesMethods(){ 
        List<string> values = new List<string>();
        values.add('TestValue1');
        values.add('TestValue2');
        MultiSelectFlowValues.CheckValues(values);
    }  
    
    Static  TestMethod void TestTaskSearchCOntrollerMethods(){
        TaskSearchController.returnManagedServiceGroups();
        TaskSearchController.getQueueList();
        List<Id> AssignedToGroups = new List<Id>();
        List<String> TaskStatusList = new List<String>();
        TaskStatusList.add('Not Completed');        
        String StartDate = Datetime.now().format('yyyy-MM-dd');
        String EndDate = Datetime.now().format('yyyy-MM-dd');
        String SelectedOwner;
        List<String> JobNumbers = new List<String>();
        TaskSearchController.returnTasks(AssignedToGroups,TaskStatusList,StartDate,EndDate,SelectedOwner,JobNumbers);
    }
    
    @IsTest(SeeAllData=true)
    Static void BulkMSTaskCreationControllerMethods(){
         Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Industry = 'Agriculture';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
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
        job.Job_Region__c = 'China';
        insert job;
		
        Recordtype TACorporateRecordType = [select id from recordtype where SobjectType = 'MS_Task__c' and DeveloperName= 'TA_Corporate'];
        MS_Task__c msTask = new MS_Task__c();
        msTask.RecordtypeId = TACorporateRecordType.Id;
        msTask.OwnerId = UserInfo.getUserId(); 
        msTask.Task_Category__c = 'Pre Launch';
        msTask.Task_Type__c = 'Scheduling';
        msTask.Scheduled_Time__c = Time.newInstance(10, 0, 0, 0);
        msTask.Estimated_Time_Required__c = 10;
        msTask.UnScheduled__c = false; 
        msTask.Task_Status__c = 'Not Started';
        msTask.Comments__c = 'Testing Comment';

        List<MS_Task__c> msTaskList = new List<MS_Task__c>();
        msTaskList.add(msTask);
        
        BulkMSTaskCreationController.getBureaUserList('TA - Corporate');
        BulkMSTaskCreationController.getBureaUserList('TA - Vocational');
        BulkMSTaskCreationController.getBureaUserList('Talent Management');
        BulkMSTaskCreationController.getBureaUserList('MS Analytics');
        BulkMSTaskCreationController.getQueueList('TA - Corporate');
        BulkMSTaskCreationController.getProjectManager(job.Id);
        BulkMSTaskCreationController.getTaskRecordTypeId('TA - Corporate');
        BulkMSTaskCreationController.insertTasks(msTaskList, job.Id);
    }
    
     public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
}
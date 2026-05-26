@isTest(SeeAllData=True)
public class MsCandidateDataTableController_Test {
    
    static list<string> makeData(){

        Account accountRecord = TestDataUtility.getAccount();
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
        job.Job_Region__c = 'Non China';
        insert job;
        Id RecordTypeIdtask= Schema.SObjectType.MS_Task__c.getRecordTypeInfosByName().get('General MS Task').getRecordTypeId();
        MS_Task__c msTask = new MS_Task__c();
        msTask.Task_Category__c = 'Coaching & Development';
        msTask.Task_Type__c = 'Training';
        msTask.Task_Date__c = System.today();
        msTask.Scheduled_Time__c = Time.newInstance(10, 0, 0, 0);
        msTask.Estimated_Time_Required__c = 10;
        msTask.UnScheduled__c = false; 
        msTask.Task_Status__c = 'Not Started';
        msTask.Systems__c= 'MFS';
        msTask.RecordTypeId = RecordTypeIdtask;
        msTask.Comments__c = 'Test';
        
        insert msTask;
        list<String> ids =new list<String>{job.id,opportunityRecord.id,msTask.id};
        return ids;
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    @isTest
    static void getMSTaskDetailsTest() {
        makeData();
        MsCandidateDataTableController.getMSTaskDetails('');
    }
    
    @isTest
    static void getCandidateDataTest() {
       list<String> jobIds= makeData();
       MsCandidateDataTableController.getCandidateData(jobIds[0],10,'');
       MsCandidateDataTableController.getCandidateData(jobIds[0],10,'Test');
    }
    
    @isTest
    static void getOpportunityLineItemsTest() {
       list<String> jobIds= makeData();
       MsCandidateDataTableController.getOpportunityLineItems(jobIds[1]);
       MsCandidateDataTableController.getNonMSOpportunityLineItems(jobIds[1]);
       MsCandidateDataTableController.getProjectDetails(jobIds[1]);
       MsCandidateDataTableController.getOrderDetails(jobIds[1]);
       MsCandidateDataTableController.handleCandidateComponentVisibility(jobIds[0]);
    }

    @isTest
    static void deleteCandidateRecordTest() {
       list<String> jobIds= makeData();
       Bureau_Candidate__c bureauCandidate = new Bureau_Candidate__c();
       bureauCandidate.Bureau_Job__c = jobIds[0];
       bureauCandidate.Gender__c = 'Male';
       //bureauCandidate.Name = 'Ramesh Dhull';
       bureauCandidate.Country__c = 'India';
       bureauCandidate.First_Name__c = 'Ramesh';
       bureauCandidate.Last_Name__c = 'Dhull';
       bureauCandidate.Language__c = 'English';
       bureauCandidate.Email__c = 'ramesh.dhull@gmail.com';
       bureauCandidate.Reports_Status__c = 'Unsent';
        
       insert bureauCandidate ;
       MsCandidateDataTableController.deleteCandidateRecord(jobIds[0],bureauCandidate.id);
       
    }
    
    @isTest
    static void updateTaskRowDataTest() {
       list<String> jobIds= makeData();
       List<MS_Task__c> mstaskList=[select id , Comments__c from MS_Task__c where id =: jobIds[2]];
       mstaskList[0].Comments__c ='Testupdate';
       MsCandidateDataTableController.updateTaskRowData(mstaskList);
    }
    
    @isTest
    static void deleteCandidateListTest() {
       list<String> jobIds= makeData();
       Bureau_Candidate__c bureauCandidate = new Bureau_Candidate__c();
       bureauCandidate.Bureau_Job__c = jobIds[0];
       bureauCandidate.Gender__c = 'Male';
       //bureauCandidate.Name = 'Ramesh Dhull';
       bureauCandidate.Country__c = 'India';
       bureauCandidate.First_Name__c = 'Ramesh';
       bureauCandidate.Last_Name__c = 'Dhull';
       bureauCandidate.Language__c = 'English';
       bureauCandidate.Email__c = 'ramesh.dhull@gmail.com';
       bureauCandidate.Reports_Status__c = 'Unsent';
        
       insert bureauCandidate ;
       MsCandidateDataTableController.deleteCandidateList(jobIds[0]);
       
    }
    
    @isTest
    static void updateCandidateRecordTest() {
       list<String> jobIds= makeData();
       Bureau_Candidate__c bureauCandidate = new Bureau_Candidate__c();
       bureauCandidate.Bureau_Job__c = jobIds[0];
       bureauCandidate.Gender__c = 'Male';
       //bureauCandidate.Name = 'Ramesh Dhull';
       bureauCandidate.Country__c = 'India';
       bureauCandidate.First_Name__c = 'Ramesh';
       bureauCandidate.Last_Name__c = 'Dhull';
       bureauCandidate.Language__c = 'English';
       bureauCandidate.Email__c = 'ramesh.dhull@gmail.com';
       bureauCandidate.Reports_Status__c = 'Unsent';
        
       insert bureauCandidate ;
       Map<String,String> candidateRec =new Map<String,String>();
       candidateRec.put('First_Name__c','Test');
       candidateRec.put('Last_Name__c', 'last');
       candidateRec.put('Phone_Number__c', '9898989898');
       candidateRec.put('System_s__c', '');
       candidateRec.put('Email__c', 'test@gmail.com');
       candidateRec.put('Gender__c', 'Male');
       candidateRec.put('Country__c', 'India');
       candidateRec.put('Language__c', 'English');
       candidateRec.put('Username__c', '');
       candidateRec.put('Reports_Status__c', '');
       candidateRec.put('Product_Assessment__c', 'shl 360,abcd');
       candidateRec.put('Status2__c', '');
       candidateRec.put('Bureau_Job__c', jobIds[0]);
        
       MsCandidateDataTableController.updateCandidateRecord(jobIds[0],candidateRec,bureauCandidate.id);
       
    }
    
    @isTest
    static void deleteCandidateListBulkTest() {
       list<String> jobIds= makeData();
       list<Bureau_Candidate__c> candlist=new list<Bureau_Candidate__c>();
       for(integer i=0;i<550;i++){
       Bureau_Candidate__c bureauCandidate = new Bureau_Candidate__c();
       bureauCandidate.Bureau_Job__c = jobIds[0];
       bureauCandidate.Gender__c = 'Male';
       //bureauCandidate.Name = 'Ramesh Dhull';
       bureauCandidate.Country__c = 'India';
       bureauCandidate.First_Name__c = 'Ramesh'+i;
       bureauCandidate.Last_Name__c = 'Dhull';
       bureauCandidate.Language__c = 'English';
       bureauCandidate.Email__c = 'ramesh.dhull'+i+'@gmail.com';
       bureauCandidate.Reports_Status__c = 'Unsent';
       candlist.add(bureauCandidate);
       } 
       insert candlist ;
       MsCandidateDataTableController.deleteCandidateList(jobIds[0]);
       
    }
    
    @isTest
    static void uploadCandidateListBulkTest() {
       list<String> jobIds= makeData();
       list<Bureau_Candidate__c> candlist=new list<Bureau_Candidate__c>();
       for(integer i=0;i<550;i++){
       Bureau_Candidate__c bureauCandidate = new Bureau_Candidate__c();
       bureauCandidate.Bureau_Job__c = jobIds[0];
       bureauCandidate.Gender__c = 'Male';
       //bureauCandidate.Name = 'Ramesh Dhull';
       bureauCandidate.Country__c = 'India';
       bureauCandidate.First_Name__c = 'Ramesh'+i;
       bureauCandidate.Last_Name__c = 'Dhull';
       bureauCandidate.Language__c = 'English';
       bureauCandidate.Email__c = 'ramesh.dhull'+i+'@gmail.com';
       bureauCandidate.Reports_Status__c = 'Unsent';
       candlist.add(bureauCandidate);
       } 
       insert candlist ;
       CandidateBulkUploadBatch cdBatch=new CandidateBulkUploadBatch(jobIds[0]);
       Database.executeBatch(cdBatch,600);
       
    }
    
    @isTest
    static void testCloneTasks() {
       list<String> jobIds= makeData();
        MS_Task__c msTask = [SELECT Id, Task_Category__c, Task_Type__c, Task_Status__c, RecordTypeId FROM MS_Task__c LIMIT 1];
        msTask.Id = null;
        msTask.Task_Status__c='Not Started';
        MsCandidateDataTableController.cloneTasks(JSON.serialize(new List<MS_Task__c>{msTask}), jobIds[0]);
    }
    
}
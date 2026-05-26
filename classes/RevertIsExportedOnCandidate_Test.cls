@isTest(seeAllData = true)
public class RevertIsExportedOnCandidate_Test {
    
     @isTest
    public static void updateCandidatesTest(){
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Job__c job = new Job__c();
        job.Account__c = accountRecord.Id;
        job.MS_Line_of_Business__c = 'Talent Management';
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.InternalContact__c = UserInfo.getUserId();
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
        job.RecordTypeId = RecordTypeIdJob2;
        job.Do_Not_Send_Survey__c = True;
        job.Preferred_Language__c = 'English';
        insert job;
        
        Bureau_Candidate__c candidate = new Bureau_Candidate__c();
        candidate.First_Name__c = 'Test';
        candidate.Last_Name__c = 'Candidate 1';
        candidate.Bureau_Job__c = job.Id;
        candidate.Email__c = 'testemail12345@test.com';
        candidate.Reports_Status__c = 'Unsent';
        candidate.isExported__c=true;
        
        RevertIsExportedOnCandidate rvrtExport=new RevertIsExportedOnCandidate(job);
        Database.executeBatch(rvrtExport);
        Test.stopTest();
    }

}
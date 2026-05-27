@isTest(SeeAllData=true)
private class BureauCandidate_AfterDeleteTester
{   
    
    static testMethod void testBureauJob_CandidateManager()
    {
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Pipeline').getRecordTypeId();
        //Job__c job1 = [Select id from Job__c limit 1];
        Job__c job = new Job__c();
        //Task t = new Task(Subject='Abc',Status='Not Started',Priority='Normal',WhatId = job1.id);
       // insert t;
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.Project_Lead__c = UserInfo.getUserId();    
        job.InternalContact__c = UserInfo.getUserId();      
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = '';
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
       // job.System_Field__c = job1.id;  
        //job.Managed_Services_Pipeline__c = job1.id;
        insert job;
               
        Bureau_Candidate__c bureauCandidate = new Bureau_Candidate__c();
        bureauCandidate.Bureau_Job__c = job.id;
        bureauCandidate.Gender__c = 'Male';
        //bureauCandidate.Name = 'Ramesh Dhull';
        bureauCandidate.Country__c = 'India';
        bureauCandidate.First_Name__c = 'Ramesh';
        bureauCandidate.Last_Name__c = 'Dhull';
        bureauCandidate.Language__c = 'English';
        bureauCandidate.Email__c = 'ramesh.dhull@gmail.com';
        bureauCandidate.Reports_Status__c = 'Unsent';
        
        insert bureauCandidate ;
        delete bureauCandidate ;
        
    }


}
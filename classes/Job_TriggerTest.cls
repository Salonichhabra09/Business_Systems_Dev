@isTest(SeeAllData=true)
public class Job_TriggerTest{
 
    static testmethod void testmethod1(){
        
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Name='Test907' + System.now();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        contactRecord.LastName='Test999' + System.now();
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, UserInfo.getUserId());
        INSERT opportunityRecord;

        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Pipeline').getRecordTypeId();
        Id userId = [select id from User where Is_Bureau_Service_Manager__c = true and IsActive = true limit 1].id;
        Job__c job = new Job__c();
        //Task t = new Task(Subject='Abc',Status='Not Started',Priority='Normal',WhatId = job1.id);
       // insert t;
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.Project_Lead__c = userId;    
        job.Opportunity__c = opportunityRecord.Id;
        job.Account__c = accountRecord.Id;
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
        job.MS_Line_of_Business__c='Talent Management';
        job.Job_Region__c='Non China';
       // job.System_Field__c = job1.id;  
        //job.Managed_Services_Pipeline__c = job1.id;
        insert job;
        
        Job__c job1 = new Job__c();
        job1.Job_Type__c = 'Project - 360';
        job1.Start_Date__c = System.today();
        job1.Opportunity__c = opportunityRecord.Id;
        job1.Account__c = accountRecord.Id;
        job1.End_Date__c = System.today().addDays(30);
        job1.Project_Lead__c = userId;    
        job1.InternalContact__c = UserInfo.getUserId();      
        job1.External_Contact_Others__c = 'External Contact';
        job1.External_Contact_Other_Email_Address__c='test@test.com';
        job1.Candidate_Username_Prefix__c = '';
        job1.ShortFall_Manager__c = 1;
        job1.Shortfall_Peer__c = 2;
        job1.Shortfall_Subordinate__c = 3;
        job1.ShortFall_Customer__c = 2;
        job1.Shortfall_Client__c = 2;
        job1.ShortFall_Other__c = 2;
        job1.PurchaseOrderNo__c='rtertr';
        job1.Generic_BS_Field_One__c='Bureau Service';
        job1.Generic_Field_MS_One__c='Managed Service';
        job1.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        job1.Is_Redirect_To_Task__c=true;
        job1.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        job1.System_Used__c ='SHL ONLINE';
        job1.RecordTypeId = RecordTypeIdJob1;    
        job1.System_Field__c = job.id;  
        job1.Managed_Services_Pipeline__c = job.id;
        job1.MS_Line_of_Business__c='Talent Management';
        job1.Parent_Job__c=job.id;
        job1.Total_number_of_change_request__c=1;
        job1.Actual_Count_of_Candidates__c=11;
        job1.Total_task_estimated_time__c=12;
        job1.Total_Case_Estimated_Time__c=13;
        job1.Total_Participants__c=11;
        job1.Total_MS_Value__c=19;
        job1.Job_Region__c='Non China';
        insert job1;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Managed Service Lightning' LIMIT 1];
        User usrRecCps = new user();
        usrRecCps.LastName = 'Test Code1806190';
        usrRecCps.Email = 'test@testCode1806190.com';
        usrRecCps.Alias = 'Tcode';
        usrRecCps.Username = 'test1234444Code1806190@test.com';        
        usrRecCps.LocaleSidKey = 'en_US';
        usrRecCps.TimeZoneSidKey = 'GMT';
        usrRecCps.ProfileId = profileId.Id;
        usrRecCps.LanguageLocaleKey = 'en_US';
        usrRecCps.EmailEncodingKey = 'UTF-8';
        usrRecCps.MS_LOB__c =job.MS_Line_of_Business__c;
        usrRecCps.IsActive=true;
        usrRecCps.Is_Managed_Service_Manager__c=true;
        insert usrRecCps;
        job1.Project_Manager__c = usrRecCps.id;  
        User usrRecmgr= [Select id, Company_BU__c from User where IsActive =True and Is_Bureau_Service_Manager__c = true limit 1];
        job1.Project_Lead__c = usrRecmgr.id;
        job1.Pipeline_Status__c = 'Pipeline - Not Converted';       
        update job1;
        
        MS_ProductTriggerManager msProdMngr = new MS_ProductTriggerManager();
        
    }
    static testmethod void testmethod2(){
        Account account= new Account();     // insert account
        account.Name='Test234' + System.now();
        account.BU__c='India - IN1';
        account.CurrencyIsoCode='GBP'; 
        account.Industry='Legal';
        account.Billing_Address_Line_1__c='test23';
        account.Billing_City__c='test23';
        account.Same_As_The_Billing_Address__c=true;
        account.Billing_Country__c='INDIA';
        account.Billing_State__c='test23';
        account.Billing_ZIP_Postal_Code__c='test23';        
        insert account;
        
        Contact con = new Contact();
        con.AccountId=account.Id;
        con.LastName='test12345';
        con.email='test12345@test.com';
        con.phone='2345345345';
        con.Same_As_The_Account_Billing_Address__c=true;        
        insert con;
      
        Opportunity opportunity= new Opportunity();
        opportunity.OwnerId=UserInfo.getUserId();
        opportunity.Business_Type__c = 'NBB - New Logo';
        opportunity.AccountId=Account.Id;
        opportunity.Primary_Contact__c=con.Id;
        opportunity.name='Test Opportunity';
        //opportunity.Forecast_Category__c = 'Commit';
        opportunity.NVM_Credit_Card_ID__c='';
        opportunity.Unconfirmed_Sun_Order_Number__c='';
        opportunity.CurrencyISOCode='GBP';
        opportunity.StageName=System.Label.Opportunity_Stage_1;
        opportunity.closeDate=System.today();
        opportunity.Talent_Level__c='Leader' ;
        opportunity.Talent_Segment__c= 'Graduate / Apprentice';
        opportunity.Client_Business_Function__c= 'Finance';
        opportunity.Offering__c = 'Training';
        insert opportunity;
        
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Pipeline').getRecordTypeId();
        Job__c job = new Job__c();
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
       // job.Project_Lead__c = UserInfo.getUserId();    
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
        job.RecordTypeId = RecordTypeIdJob2 ;
        job.Opportunity__c = opportunity.id;
        job.MS_Line_of_Business__c='Talent Management';
        job.Job_Region__c='Non China';
        insert job;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Managed Service Lightning' LIMIT 1];
        User usrRecCps = new user();
        usrRecCps.LastName = 'Test Code1806190';
        usrRecCps.Email = 'test@testCode1806190.com';
        usrRecCps.Alias = 'Tcode';
        usrRecCps.Username = 'test1234444Code1806190@test.com';        
        usrRecCps.LocaleSidKey = 'en_US';
        usrRecCps.TimeZoneSidKey = 'GMT';
        usrRecCps.ProfileId = profileId.Id;
        usrRecCps.LanguageLocaleKey = 'en_US';
        usrRecCps.EmailEncodingKey = 'UTF-8';
        usrRecCps.MS_LOB__c =job.MS_Line_of_Business__c;
        usrRecCps.IsActive=true;
        usrRecCps.Is_Managed_Service_Manager__c=true;
        insert usrRecCps;
        
        //User usrRecCps = [Select id, Company_BU__c from User where MS_LOB__c =:job.MS_Line_of_Business__c and IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];
        User usrRecmgr= [Select id, Company_BU__c from User where IsActive =True and Is_Bureau_Service_Manager__c = true limit 1];
        Id RecordTypeIdtask= Schema.SObjectType.MS_Task__c.getRecordTypeInfosByName().get('Talent Management').getRecordTypeId();
        
        MS_Task__c msTask = new MS_Task__c();
        msTask.Task_Category__c = 'Pre Launch';
        msTask.Task_Type__c = 'Other';
        msTask.Task_Date__c = System.today();
        msTask.Scheduled_Time__c = Time.newInstance(10, 0, 0, 0);
        msTask.Estimated_Time_Required__c = 10;
        msTask.UnScheduled__c = false; 
        msTask.Task_Status__c = 'Accepted';
        msTask.OwnerId=usrRecmgr.id;
        msTask.RecordTypeId = RecordTypeIdtask ;
        msTask.Job__c=job.id;
        insert msTask;
		
		Task t = new Task(Subject='Abc',Status='Not Started',Priority='Normal',WhatId = job.id);
        insert t;
        t.OwnerId='00520000000hIsYAAU';
        update t;
        
        job.RecordTypeId = RecordTypeIdJob1 ;
        job.Project_Manager__c = usrRecCps.id;  
        job.Project_Lead__c = usrRecmgr.id;
        // job.Pipeline_Status__c = 'Pipeline - Not Converted';       
        update job;
        
        JobTriggerManager_2.getDifferentRegionJobs(job.Id);
    }
    
}
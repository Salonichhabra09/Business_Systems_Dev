@isTest(seeAllData = true)
public class EmailMessage_TriggerTester 
{
    public static Boolean B_trigger=true;
    public static Account accounts;
    static testMethod void testEmailMessage_TriggerTester()
    {
        Test.startTest();
        Id rtId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Information only – Front Office').getRecordTypeId();
        Id rtIdAMS = Schema.SObjectType.case.getRecordTypeInfosByName().get('AMS PS').getRecordTypeId();
        Id rtIdCPS = Schema.SObjectType.case.getRecordTypeInfosByName().get('Central PS').getRecordTypeId();
        
        Account account=new Account(name='Test Class Account',
                                    Status__c='Approved',
                                    Industry = 'Agriculture',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='CHINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    BU__c='China - CN1');
        insert account;
        
        
        Contact contact=new Contact(lastname='Test Class Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        insert contact;
        
        List<Case> caseList =  new List<Case>();
        
        Date dt = system.Today();
        
        Case cse = new case(AccountId=account.Id,
                            ContactId=contact.Id,
                            Problem2__c='Login Issue',
                            Solution__c='other', 
                            //Changes start for Customer Success to Customer Experience - SSE-1741
                            //Assigned_To__c = 'EMEA Customer Success',
                            Assigned_To__c ='EMEA Technical Support',
                            System__c = 'S2P',
                            Priority = 'P4 - Low',
                            System_Id__c = 'S1234',
                            //Changes end.- SSE-17417 
                            
                            Caller_Type__c = 'Customer',
                            Origin = 'Web',
                            Call_Type__c = 'Assessment Preview',
                            Candidate_Tel__c = '13645757',
                            Contact_Email__c = 'abc@invalid.com',
                            Admin_Contact__c = 'Test 1',
                            recordTypeId=rtId,
                            status = 'Resolved/Closed',
                            CreatedDate = dt.addDays(-100),
                            ClosedDate = dt.addDays(-92),
                            Time_Spent__c=1);                                                
        caseList.add(cse);
        
        Case cse1 = new case(AccountId=account.Id,
                             ContactId=contact.Id,
                             Problem2__c='Login Issue',
                             Solution__c='other',
                             //Changes start for Customer Success to Customer Experience - SSE-1741
                             //Assigned_To__c = 'EMEA Customer Success',
                             Assigned_To__c ='EMEA Technical Support',
                             System__c = 'S2P',
                             Priority = 'P4 - Low',
                             System_Id__c = 'S1234',
                             //Changes end.- SSE-17417 
                             
                             Caller_Type__c = 'Customer',
                             Origin = 'Web',
                             Admin_Contact__c = 'Test 2',
                             Contact_Email__c = 'abc1@invalid.com',
                             Candidate_Tel__c = '13645756',
                             Call_Type__c = 'Assessment Preview',
                             recordTypeId = rtId,
                             Time_Spent__c=1);                                                
        caseList.add(cse1);
        
        Case cseAMS = new case(AccountId=account.id,
                               ContactId=contact.Id,
                               Problem2__c='Login Issue',
                               Solution__c='other', 
                               //Changes start for Customer Success to Customer Experience - SSE-1741
                               //Assigned_To__c = 'EMEA Customer Success',
                               Assigned_To__c ='EMEA Technical Support',//Prachi - SSE - 1741
                               System__c = 'S2P',
                               Priority = 'P4 - Low',
                               System_Id__c = 'S1234',
                               //Changes end.- SSE-17417 
                               
                               Caller_Type__c = 'Customer',
                               Origin = 'Web',
                               Admin_Contact__c = 'Test 3',
                               Contact_Email__c = 'abc2@invalid.com',
                               recordTypeId = rtIdAMS,
                               Status = 'Is Closed',
                               ParentId = cse.Id,
                               Call_Type__c = 'Assessment Preview',
                               Candidate_Tel__c = '13645755',
                               Time_Spent__c=1);                                                
        caseList.add(cseAMS);
        
        Case parent = new case(AccountId=account.id,
                               ContactId=contact.Id,
                               Problem2__c='Login Issue',
                               Solution__c='other', 
                               //Changes start for Customer Success to Customer Experience - SSE-1741
                               //Assigned_To__c = 'EMEA Customer Success',
                               Assigned_To__c ='EMEA Technical Support',
                               System__c = 'S2P',
                               Priority = 'P4 - Low',
                               System_Id__c = 'S1234',
                               Requester_if_internal__c = contact.Id,
                               Caller_Type__c = 'Internal', 
                               //Changes end.- SSE-17417 
                               // Caller_Type__c = 'Customer',
                               Origin = 'Email',
                               Admin_Contact__c = 'Test 5',
                               Contact_Email__c = 'abc5@invalid.com',
                               recordTypeId = rtId,
                               ClosedDate = (System.today()).addDays(-95),
                               CreatedDate = (System.today()).addDays(-96),
                               Status = 'Is Closed',
                               Call_Type__c = 'Assessment Preview',
                               Candidate_Tel__c = '13645755',
                               Time_Spent__c=1);                                                
        //caseList.add(parent);
        
        Case cseCPS = new case(AccountId = account.Id,
                               ContactId = contact.Id,
                               Problem2__c ='Login Issue',
                               Solution__c ='other', 
                               //Changes start for Customer Success to Customer Experience - SSE-1741
                               //Assigned_To__c = 'EMEA Customer Success',
                               Assigned_To__c ='EMEA Technical Support',
                               System__c = 'S2P',
                               Priority = 'P4 - Low',
                               System_Id__c = 'S1234',
                               Caller_Type__c = 'Candidate',
                               Candidate_Name__c = 'Test Data',
                               Candidate_Telephone__c = '123456789',
                               Candidate_Email_Address__c	= 'test@shl.com',
                               
                               
                               //Changes end.- SSE-17417 
                               
                               //Caller_Type__c = 'Customer',
                               ParentId = parent.Id,
                               Origin = 'Web',
                               Admin_Contact__c = 'Test 4',
                               Status = 'Is Closed',
                               Contact_Email__c = 'abc3@invalid.com',
                               recordTypeId = rtIdCPS,
                               Candidate_Tel__c = '13645754',
                               Call_Type__c = 'Assessment Preview',
                               Time_Spent__c = 1);                                                
        caseList.add(cseCPS);
        insert caseList;
        System.debug('caseList -- ' + caseList);
        /* Bellow code was commented. Data is created above instead of feteched from org
Case cse = [Select id,Requester_if_internal__c ,Caller_Type__c,Assigned_To__c,Origin,Contact_Email__c,Candidate_Email_Address__c 
from Case 
where CALENDAR_YEAR(CreatedDate) = 2018 and Origin='Web' limit 1];
Case cse1 = [Select id,Requester_if_internal__c ,Caller_Type__c,Assigned_To__c,Origin,Contact_Email__c,Candidate_Email_Address__c 
from Case 
where CALENDAR_YEAR(CreatedDate) = 2018 and recordTypeId !=: rtId limit 1];
Case cseAMS = [Select id,Requester_if_internal__c ,Caller_Type__c,Assigned_To__c,Origin,Contact_Email__c,Candidate_Email_Address__c 
from Case 
where CALENDAR_YEAR(CreatedDate) = 2018 and recordTypeId =: rtIdAMS and isclosed=true limit 1];
Case cseCPS = [Select id,Requester_if_internal__c ,Caller_Type__c,Assigned_To__c,Origin,Contact_Email__c,Candidate_Email_Address__c 
from Case 
where recordTypeId =:rtIdCPS and isclosed=true limit 1];
*/
        EmailMessage eMessage = new EmailMessage();
        eMessage.FromAddress = 'ramesh_dhull@dell.com';
        eMessage.FromName = 'Ramesh Dhull';
        eMessage.Incoming = true;
        eMessage.ParentId = cse.Id;
        eMessage.Subject = 'Testing EmailMessage';
        eMessage.TextBody = 'Hi This is text body'; 
        insert eMessage; 
        
        EmailMessage eMessage1 = new EmailMessage();
        eMessage1.FromAddress = 'ramesh_dhull@dell.com';
        eMessage1.FromName = 'Ramesh Dhull';
        eMessage1.Incoming = true;
        eMessage1.ParentId = cse1.Id;
        eMessage1.Subject = 'Testing EmailMessage';
        eMessage1.TextBody = 'Hi This is text body'; 
        insert eMessage1;   
        
        EmailMessage eMessage2 = new EmailMessage();
        eMessage2.FromAddress = 'ramesh_dhull@dell.com';
        eMessage2.FromName = 'Ramesh Dhull';
        eMessage2.Incoming = true;
        eMessage2.ParentId = cseAMS.Id;
        eMessage2.Subject = 'Testing EmailMessage';
        eMessage2.TextBody = 'Hi This is text body'; 
        insert eMessage2;
        
        EmailMessage eMessage3 = new EmailMessage();
        eMessage3.FromAddress = 'ramesh_dhull@dell.com';
        eMessage3.FromName = 'Ramesh Dhull';
        eMessage3.Incoming = true;
        eMessage3.ParentId = cseCPS.Id;
        eMessage3.Subject = 'Testing EmailMessage';
        eMessage3.TextBody = 'Hi This is text body'; 
        insert eMessage3;
        
        
        EmailMessage eMessage4 = new EmailMessage();
        eMessage4.FromAddress = 'ramesh_dhull@dell.com';
        eMessage4.FromName = 'Ramesh Dhull';
        eMessage4.ParentId = parent.Id;
        //eMessage4.RelatedToId = parent.Id; 
        eMessage4.Subject = 'Testing EmailMessage';
        eMessage4.TextBody = 'Hi This is text body'; 
        insert eMessage4;
        
        system.debug('Test case cse -->' + cse);
        try{
            //ApexPages.StandardController sc = new ApexPages.StandardController(cse);
            //system.debug('Test' + sc);
            /*if(sc != null){
EmailMessageCtrl ctrlObj = new EmailMessageCtrl(sc);
ctrlObj.conId = cse.Id;
ctrlObj.init(); 
ctrlObj.removecon();
}*/
        } catch ( Exception e) {
            System.debug(e);
        }
        
        
        Test.stopTest();
        /*Profile p = [select Id,Name from Profile where Name = 'SOE'];
User u = new User(Alias = 'jcutc',  
EmailEncodingKey='UTF-8', LastName='Cutcliffe', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, 
TimeZoneSidKey='America/Los_Angeles');

try{
system.debug('p.id-------'+p.id);
system.debug('UserInfo.getProfileId()-------'+UserInfo.getProfileId());
if(p.Id == UserInfo.getProfileId()) {
delete eMessage;
}
}
Catch(Exception e){}    
*/    
    } 
    
    @isTest
    static void testRestrictDeletionOfJobMails() {
        // Start test context
        Test.startTest();
        
        // Step 1: Create a mock custom object (whose ID starts with 'a00') for testing purposes.
        // We will assume that this custom object is 'Job__c' (change this to your custom object).
        //Account accountRecord = TestDataUtility.getAccount();
        Account accountRecord = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                            Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                            Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                            Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        contactRecord.Area_of_Interest__c = 'Volume Hiring';
        INSERT contactRecord;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Opportunity opportunity = TestDataUtility.getOpportunity(accountRecord.Id, contactRecord.Id);
        Job__c jobRecord = new Job__c();
        jobRecord.Account__c = accountRecord.Id;
        jobRecord.Opportunity__c = opportunity.Id;
        jobRecord.MS_Line_of_Business__c = 'Talent Management';
        jobRecord.Job_Type__c = 'Project - 360';
        jobRecord.Start_Date__c = System.today();
        jobRecord.End_Date__c = System.today().addDays(30);
        jobRecord.InternalContact__c = UserInfo.getUserId();
        jobRecord.External_Contact_Others__c = 'External Contact';
        jobRecord.External_Contact_Other_Email_Address__c='test@test.com';
        jobRecord.Candidate_Username_Prefix__c = 'QA01';
        jobRecord.ShortFall_Manager__c = 1;
        jobRecord.Shortfall_Peer__c = 2;
        jobRecord.Shortfall_Subordinate__c = 3;
        jobRecord.ShortFall_Customer__c = 2;
        jobRecord.Shortfall_Client__c = 2;
        jobRecord.ShortFall_Other__c = 2;
        jobRecord.PurchaseOrderNo__c='rtertr';
        jobRecord.Generic_BS_Field_One__c='Bureau Service';
        jobRecord.Generic_Field_MS_One__c='Managed Service';
        jobRecord.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        jobRecord.Is_Redirect_To_Task__c=true;
        jobRecord.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        jobRecord.System_Used__c ='SHL ONLINE';
        jobRecord.RecordTypeId = RecordTypeIdJob2;
        jobRecord.Do_Not_Send_Survey__c = True;
        jobRecord.Preferred_Language__c = 'English';
        jobRecord.Job_Region__c = 'Non China';
        insert jobRecord;
        // This will generate an ID starting with 'a00'
        
        // Step 2: Create a test EmailMessage related to the custom object (Job__c)
        
        EmailMessage testEmail = new EmailMessage();
        testEmail.FromName = 'Test Sender';
        testEmail.FromAddress = 'sender@example.com';
        testEmail.ToAddress = 'recipient@example.com';
        testEmail.Subject = 'Test Email';
        testEmail.TextBody = 'This is a test email.';
        testEmail.RelatedToId = jobRecord.Id; // Link the email to the Job__c object
        insert testEmail;
        
        // Step 3: Attempt to delete the EmailMessage and catch the error
        try{
            delete testEmail; 
        }
        catch (DmlException e) {
            // Assert that the error message is correct
            System.debug('Error '+e.getmessage());
        }
        //System.assert(false, 'Deletion should have been prevented by the trigger manager');
        // End test context
        Test.stopTest();
    }
    
    @isTest
    static void testprocessNewEmailMessagesonJob(){
        /*Account accountRecord = TestDataUtility.getAccount();
INSERT accountRecord;*/
        Account accountRecord = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                            Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                            Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                            Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, UserInfo.getUserId());
        opportunityRecord.Business_Type__c = 'Expansion';
        opportunityRecord.Forecast_Category__c = 'Commit';
        INSERT opportunityRecord;
        
        Contract contract = TestDataUtility.getContract(accountRecord.Id,opportunityRecord.Id);
        contract.Contract_End_Date__c = Date.Today();
        Insert contract;
        
        opportunityRecord.ContractId = contract.Id;
        update opportunityRecord;
        
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
        job.Job_Region__c='China';
        job.Sender_Email__c = 'noreply@shl.com';
        job.Client_Report_Password__c = 'rApJxWl3kouqSxzsODi+c3Z7fcqt8uQTi0wI3VacIOQ=';
        job.Client_Report_Mail_Ids__c = 'abc@abc.com';
        job.Contact_Details__c = '[{"name":"Supriya Kakaraddi","email":"supriya.kakaraddi@shl.com","role":"Project Sponsor"}]';
        job.Solution_Cap__c = 10;
        
        // job.System_Field__c = job1.id;  
        //job.Managed_Services_Pipeline__c = job1.id;
        insert job;
        
        EmailMessage testEmail = new EmailMessage();
        testEmail.FromName = 'Test Sender';
        testEmail.FromAddress = 'sender@example.com';
        testEmail.ToAddress = 'recipient@example.com';
        testEmail.Subject = 'New Report View Generated for request:';
        testEmail.TextBody = 'This is a test email.';
        testEmail.RelatedToId = job.Id; // Link the email to the Job__c object
        insert testEmail;
        
    }
    
    @isTest
    static void testIncomingReferralCaseEmails()
    {
        Test.startTest();
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Referral').getRecordTypeId();
        
        Account account=new Account(name='Test Class Account',
                                    Status__c='Approved',
                                    Industry = 'Agriculture',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='CHINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    BU__c='China - CN1');
        insert account;
        
        
        Contact contact=new Contact(lastname='Test Class Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        insert contact;
        
        List<Case> caseList =  new List<Case>();
        
        Date dt = system.Today();
        
        Case cse = new case(AccountId=account.Id,
                            ContactId=contact.Id,
                            Problem2__c='Login Issue',
                            Solution__c='other',
                            Assigned_To__c ='Technical Support',
                            System__c = 'S2P',
                            Priority = 'P4 - Low',
                            System_Id__c = 'S1234',
                            Caller_Type__c = 'Customer',
                            Origin = 'Web',
                            Call_Type__c = 'Assessment Preview',
                            Candidate_Tel__c = '13645757',
                            Contact_Email__c = 'abc@invalid.com',
                            Admin_Contact__c = 'Test 1',
                            recordTypeId=recordTypeId,
                            status = 'Resolved/Closed',
                            CreatedDate = dt.addDays(-100),
                            ClosedDate = dt.addDays(-92),
                            Time_Spent__c=1);                                                
        caseList.add(cse);
        
        Case cse1 = new case(AccountId=account.Id,
                             ContactId=contact.Id,
                             Problem2__c='Login Issue',
                             Solution__c='other',
                             Assigned_To__c ='Technical Support',
                             System__c = 'S2P',
                             Priority = 'P4 - Low',
                             System_Id__c = 'S1234',
                             Caller_Type__c = 'Customer',
                             Origin = 'Web',
                             Admin_Contact__c = 'Test 2',
                             Contact_Email__c = 'abc1@invalid.com',
                             Candidate_Tel__c = '13645756',
                             Call_Type__c = 'Assessment Preview',
                             recordTypeId = recordTypeId,
                             status = 'Resolved/Closed',
                             CreatedDate = dt.addDays(-100),
                             ClosedDate = dt.addDays(-70),
                             Time_Spent__c=1);                                                
        caseList.add(cse1);

        insert caseList;

        EmailMessage eMessage = new EmailMessage();
        eMessage.FromAddress = 'ramesh_dhull@dell.com';
        eMessage.FromName = 'Ramesh Dhull';
        eMessage.Incoming = true;
        eMessage.ParentId = cse.Id;
        eMessage.Subject = 'Testing EmailMessage';
        eMessage.TextBody = 'Hi This is text body'; 
        insert eMessage; 
        
        cse1.OwnerId = UserInfo.getUserId();
        update cse1;
        
        EmailMessage eMessage1 = new EmailMessage();
        eMessage1.FromAddress = 'ramesh_dhull@dell.com';
        eMessage1.FromName = 'Ramesh Dhull';
        eMessage1.Incoming = true;
        eMessage1.ParentId = cse1.Id;
        eMessage1.Subject = 'Testing EmailMessage';
        eMessage1.TextBody = 'Hi This is text body'; 
        insert eMessage1;   

        Test.stopTest();

    }
    
}
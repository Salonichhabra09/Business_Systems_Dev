@isTest(seeAlldata=true)
public class TaskTriggerManager_Tester {
    @isTest static void taskTriggerManagerTest() {
        Test.startTest();
        List<Task> tasks = new List<Task>();
        
        Task tsk =  new Task();
        
        Account account=new Account(name='Test Class Account',
                                    Status__c='Approved',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='CHINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    BU__c='China - CN1',Industry='Legal');
        insert account;
        
        Contact contact = new Contact(AccountId=account.Id,
                                      LastName='test12345',
                                      email='test12345@test.com',
                                      phone='2345345345',
                                      Same_As_The_Account_Billing_Address__c=true);        
        insert contact;
        
        Contract contract = new Contract(AccountId = account.Id,
                                         Legal_Order_Name__c = 'test',
                                         CurrencyIsoCode = account.CurrencyIsoCode,
                                         S2P_Reference_Required__c = 'New',
                                         Status = 'Draft',
                                         CustomerSignedDate = Date.Today(),
                                         StartDate = Date.Today(),
                                         ContractTerm = 6,
                                         Activated_Date__c=datetime.now(),
                                         Final_Submission_Date_EST__c=datetime.now().addDays(-2), 
                                         Submission_Offset__c = 10, 
                                         Subscription_Start_Date__c = Date.Today(),
                                         Agreement__c = 'Order');
        insert contract;
        
        Opportunity opportunity= new Opportunity(OwnerId=UserInfo.getUserId(),
                                                 Business_Type__c = 'NBB - New Logo',
                                                 AccountId=Account.Id,
                                                 Billing_Contact__c=Contact.Id,
                                                 Primary_Contact__c=Contact.Id,
                                                 NVM_Credit_Card_ID__c='',
                                                 Unconfirmed_Sun_Order_Number__c='',
                                                 CurrencyISOCode='GBP',
                                                 closeDate=System.today(),
                                                 Order_number__c=contract.Id,
                                                 name='Test Opportunity',
                                                 StageName=System.Label.Opportunity_Stage_1);
        insert opportunity;
        
        Id recTypeId = [select id from RecordType Where DeveloperName='Managed_Service_Pipeline' limit 1].get(0).Id;
        Job__c job = new Job__c(Account__c = account.Id, 
                                RecordTypeId = recTypeId, 
                                Opportunity__c = opportunity.Id,MS_Line_of_Business__c='Talent Management',Job_Region__c  = 'China');
        insert job;
        
        Task t = new Task(Subject='Outbound call',
                          Status='Completed',
                          Priority='Normal',
                          WhatId = opportunity.id,
                          Task_Start_Time__c = DateTime.Now(),
                          Task_End_Time__c = DateTime.Now(),
                          Actual_Time_Taken__c = null);
        tasks.add(t);
        
        Task t1 = new Task(Subject='Inbound call',
                           Status='Completed',
                           Priority='Normal',
                           WhatId = opportunity.id);
        tasks.add(t1);
        Task t2 = new Task(Subject='Email: test',
                           Status='Completed',
                           Priority='Normal',
                           WhatId = job.id,
                           Task_Start_Time__c = DateTime.Now(),
                           Task_End_Time__c = DateTime.Now());
        tasks.add(t2);
        
        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=account.Id);
        insert accPlan;
        
        Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                               Strategy_Name__c = 'Test',
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration', 
                                                               Strategy_Status__c = 'In Progress',
                                                               Key_Contact_Sponsor__c=contact.Id);
        insert stgoal;
        
        Task t3 = new Task(Subject='Email: test',
                           Status='In Progress',
                           Priority='Normal',
                           WhatId = stgoal.id,
                           Task_Start_Time__c = DateTime.Now(),
                           Task_End_Time__c = DateTime.Now());
        tasks.add(t3);
        
        insert tasks;
        t1.Subject = 'Email: test';
        update t1;
        delete t2;
        t3.Status = 'Completed';
        update t3;
        Test.stopTest();
        
    }
    @isTest static void UpdateContactTaskTest(){
        
        Account account=new Account(name='Test Class Account',
                                    Status__c='Approved',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='CHINA',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    BU__c='China - CN1',
                                    Industry='Legal');
        insert account;
        
        Contact contact = new Contact(AccountId=account.Id,
                                      LastName='test12345',
                                      email='test12345@test.com',
                                      phone='2345345345',
                                      Same_As_The_Account_Billing_Address__c=true);        
        insert contact;
        
        Lead lead = new Lead();
        lead.Lastname= 'testLead';
        lead.LeadSource = 'Partner';
        lead.company= 'test company';
        lead.Status = 'New';
        lead.Email = 'test99999@test.com';
        lead.Lead_Country__c = 'India';
        insert lead;
        
        Task t3 = new Task(Subject='Email: test',
                           Status='In Progress',
                           Priority='Normal',
                           WhoId = lead.id,
                           Task_Start_Time__c = system.Now(),
                           Task_End_Time__c = system.Now());
        insert t3;
        
        Task t = new Task();
        t.id = t3.id;
        t.WhoId = contact.id;
        
        update t;
        
    }     
}
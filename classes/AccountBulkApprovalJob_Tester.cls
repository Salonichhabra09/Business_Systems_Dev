/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData = true)
private class AccountBulkApprovalJob_Tester {
    public static List<ProjectObject__c> projects = new List<ProjectObject__c>();
     public static list<Project_Deliverables__c> listPD = new list<Project_Deliverables__c>();
    public static ProjectObject__c project = new ProjectObject__c();
    public static Project_Invoice__c invoice = new Project_Invoice__c();
    public static Account account;
public static List<Contact> contacts;

    static testMethod void myUnitTest() {
        List<Account> accounts = [SELECT Id FROM Account where Status__c!='Approved' LIMIT 1];
        String accountIdsCSV = '';
        for(Account account1 : accounts)
      accountIdsCSV += ',\'' + account1.Id + '\'';
    accountIdsCSV = accountIdsCSV.substring(1);
        Account_BulkApprovalJob test_SubmitAccountsforApproval = new Account_BulkApprovalJob(accountIdsCSV, null);       
        /*
        Account_BulkApprovalJob test_SubmitAccountsforApproval = new Account_BulkApprovalJob(null, 'ApprovalAccountIds');       
        */
        Test.startTest();       
          Database.executeBatch(test_SubmitAccountsforApproval);  
        Test.stopTest();
    }
    
    //Insert Project record
    static List<ProjectObject__c> insertProjects()
     {
            //Account a = new Account();
            //Schema.sObjectType t = a.getSObjectType();
            //List<account> a1 = TestDataUtility.getAccount();
            //Get first test account
            account = TestDataUtility.getAccount();
         	account.name = 'ApprovalJobTesterAcc';
         	insert account;
             Contact contact = new Contact(AccountId=account.Id,LastName='test12345',email='test12345@test.com',phone='2345345345',Same_As_The_Account_Billing_Address__c=true);
       // Contact con1 = new Contact(AccountId=account.Id,LastName='test1',email='test@test1.com',phone='3345534534',Same_As_The_Account_Billing_Address__c=true);
        contacts = new List<Contact>();
        contacts.add(contact);
       // contacts.add(con1);
        insert contacts;
        //Contact contact = [SELECT Id,AccountId from Contact where AccountId!=null LIMIT 1]; 
        User usrRec = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];  
        List<String> lbuList = usrRec.Company_BU__c.split('-');
        
       
            Contract contract = new Contract();
            //Account account = [SELECT Id,CurrencyIsoCode from Account where id=:contact.AccountId];
            contract.AccountId = account.Id;   
            contract.CurrencyIsoCode = account.CurrencyIsoCode;
            contract.S2P_Reference_Required__c = 'New';
            contract.Status = 'Draft';
            contract.CustomerSignedDate = Date.Today();
         	contract.Subscription_Start_Date__c = Date.Today();
            contract.StartDate = Date.Today();
            contract.ContractTerm = 6;  
            contract.Legal_Order_Name__c='test';      
            insert contract;
            //Create a new Contract Line     
            /*Contract_Line__c contractLine = new Contract_Line__c();
            contractLine.Contract__c = contract.Id;
            contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
            contractLine.IM_Lookup_Code__c = 'Consulting';
            contractLine.Source_of_PS_Scoping__c = 'E2E Scoping Tool';
            contractLine.PO_number__c = '12312323423';
            //contractLine.Price__c = 5000;
            contractLine.Order_Method__c='T&E';
            contractLine.Invoicing_Schedule__c = 'Special Invoicing Instructions';
         contractLine.Proposition__c = '';
         contractLine.Package__c = '';
            insert contractLine;*/
            list<ProjectObject__c> listproject = new list<ProjectObject__c> ();
         for(Integer i=0;i<1;i++)
        {
            
            project.Project_Name__c = 'project_' + i;
            project.Account__c = contact.AccountId;
            project.Contact__c = contact.Id;
            project.Billing_Contact__c = contact.Id;
            //Added by Ramesh during December release 2013
            project.Project_Manager__c =usrRec.id;
            //project.LBU__c = 'UK1';
            project.LBU__c = lbuList[1].trim();
            project.CurrencyIsoCode = account.CurrencyIsoCode;
            //End Ramesh
            project.Functional_Area__c = 'Sales';
            project.Order_Header_Number__c = contract.id;
           // project.Order_Line_Number__c = contractLine.id;
            project.Total_Actual_Time__c=1;
            project.Scoped_Hours_Effort__c=1;           
            listproject.add(project);
                      
         
        }
        insert listproject ;
      
        for(ProjectObject__c proj:listproject )
        {
           ProjectObject__c proj1 = proj;
         proj1.id = proj.id;
          //proj1.Order_Line_Number__c = contractLine.id;
         // update project;
           projects.add(proj1);
           
            Project_Deliverables__c objPD = new Project_Deliverables__c();
        objPD.PS_Offering__c = 'Outsourced Assessment';
        objPD.Project__c=proj1.id;
        objPD.Number__c=10;
        objPD.Deal_Type__c='Assessment for Selection';
        objPD.Complexity__c= 'Tailored';
        objPD.Additional_Comments__c= 'Test Comments';
        listPD.add(objPD);
        }
          insert listPD;
        update projects;
        return projects;
     }
         
     //insert Project  Invoice
     public static List<Project_Invoice__c> insertInvoices(String projectId)
     {
        List<SelectOption> IMCodes = new List<SelectOption>();
        for(PicklistEntry entry: Project_Invoice__c.IM1_LookupCode__c.getDescribe().getPicklistValues())
            IMCodes.add(new SelectOption(entry.getValue(),entry.getValue()));
        system.debug('Invoice: Insert Started');
        if(projectId==null)
            projectId = [SELECT Id from ProjectObject__c where CurrencyISOCode = 'GBP' and Order_Header_Number__r.CurrencyISOCode ='GBP' LIMIT 1].Id;  
        
        List<Project_Invoice__c> invoices = new List<Project_Invoice__c>();
        
        for(Integer i=0;i<1;i++)
        {
           
            invoice.Project__c = projectId;
          	invoice.Start_Date__c = Date.newInstance(2008,2,2);
            invoice.End_Date__c = Date.newInstance(2008,5,5);
            invoice.IM1_LookupCode__c = IMCodes[0].getValue(); 
            invoice.IM1_Quantity__c = 1; 
            invoice.IM1_UnitPrice__c = 500; 
            invoice.CurrencyISOCode = 'GBP';
            invoice.Status__c ='Draft';
            invoices.add(invoice);
        }
        
        insert invoices;
        system.debug('Invoice: Insert Completed');
        return invoices;
     }
     
    /*static testMethod void timesheettest(){
     //edited by saloni chhabra on 2/24/2015 starts here
    insertProjects();
    Test.startTest();
    //Timesheet_TriggerTester.testBasicMethods(string.valueof(projects[0].id));
    Test.stopTest();
      //Timesheet_TriggerTester.testBasicMethods(string.valueof([select id from ProjectObject__c where Delivery_Hours_Timesheet__c>0 limit 1].id));
      //edited by saloni chhabra on 2/24/2015 ends here 
    }*/
    /*static testMethod void getRelatedInvoiceTest(){
        insertProjects();
        insertInvoices(projects[0].Id);
      //Id projectId = [select id from ProjectObject__c where Delivery_Hours_Timesheet__c>0 limit 1].id;
      //List<ProjectObject__c> ProjectList = [select id,Function_Timesheet__c from ProjectObject__c where Delivery_Hours_Timesheet__c>0 limit 1];
     // ProjectObject__c oldProject = [select id,OwnerId from ProjectObject__c where OwnerId !=: UserInfo.getUserId() limit 1];
      //ProjectObject__c newProject = [select id,OwnerId from ProjectObject__c where OwnerId =: UserInfo.getUserId() limit 1];
      //Project_Invoice__c oldInvoice = [select id,Status__c,Project__c,Start_Date__c,End_Date__c from Project_Invoice__c where Status__c !='Submitted for Processing' limit 1];
      //Project_Invoice__c newInvoice = [select id,Status__c,Project__c,Start_Date__c,End_Date__c from Project_Invoice__c where Status__c ='Submitted for Processing' limit 1];
      //Project_Invoice__c oldInvoice1 = [select id,Status__c,Project__c,Start_Date__c,End_Date__c from Project_Invoice__c where Status__c !='Processed' limit 1];
      //Project_Invoice__c newInvoice1 = [select id,Status__c,Project__c,Start_Date__c,End_Date__c from Project_Invoice__c where Status__c ='Processed' limit 1];
     
     //edited by saloni chhabra on 2/24/2015 starts here
     // List<Timesheet_Line__c> timesheet = new List<Timesheet_Line__c>([select id,Resource__c,CurrencyIsoCode,Time_Cost__c,Hours__c,Project__c,Date_Invoiced__c from Timesheet_Line__c where Project__c=: projectId]);
     Timesheet_Line__c timesheetobj = new Timesheet_Line__c();
      if(projects.size()>0)
      {
          timesheetobj.Project__c = projects[0].id;
          timesheetobj.Function__c = 'SAL';
          timesheetobj.Hours__c = 1;
          timesheetobj.Resource__c = UserInfo.getUserId();
          timesheetobj.Time_Cost__c  = 0;
          timesheetobj.CurrencyIsoCode = projects[0].CurrencyIsoCode;
            timesheetobj.Time_Category__c='Delivery - Other';//Modified by Jai
        timesheetobj.Task_Category__c = 'PS Consulting';//Modified by prabhat
        timesheetobj.Task__c = 'Design';
      }
      List<Timesheet_Line__c> timesheet = new List<Timesheet_Line__c>();
      timesheet.add(timesheetobj);
      Test.startTest();
      if(timesheet.size()>0)
      insert timesheet;
      //Test.stopTest();
     //edited by saloni chhabra on 2/24/2015 ends here 
     
      //Test.startTest();
        //Timesheet_Manager.getRelatedInvoices(timesheet);
        Timesheet_Manager.updateRelatedInvoices(timesheet);
        Timesheet_Manager.updateTimeCostValues(timesheet);
        Timesheet_Manager.updateDataInTimesheets(project,project);
        Timesheet_Manager.updateDataInTimesheets(invoice,invoice);
        invoice.Status__c ='Processed';
        invoice.Sun_Invoice_No__c = 'SUN011Test';
        //update invoice;
        Timesheet_Manager.updateDataInTimesheets(invoice,invoice);
      Test.stopTest();
    }*/
    static testMethod void AccountCurrencyUpdate(){
      Apexpages.standardController sc = new Apexpages.standardController([select id from Account limit 1]);
      AccountCurrencyUpdate acc = new AccountCurrencyUpdate(sc);
      Test.startTest(); 
        acc.editAccountCurrency();
        acc.cancelAccountCurrencyUpdate();
        acc.updateAccountCurrency();
        acc.cancelChange();
        acc.saveAccountCurrency();
      Test.stopTest();
    }
    static testMethod void EmailTemplate_Selection(){
        EmailTemplate_Selection acc = new EmailTemplate_Selection();
        PageReference pg = Page.Course_EmailTemplates;
        pg.getParameters().put('action','Course_sendJoiningInstructions');
        Test.setCurrentPage(pg);
        Test.startTest(); 
        //acc.getIsTemplateExist();
        acc.getItems();
        acc.changeFolder();
        acc.executeAction();
        //pg.getParameters().put('action','Course_SendSurvey');
        Test.stopTest();
    }
    /*static testMethod void Lead_Manager(){
      Apexpages.standardController sc = new Apexpages.standardController([select id,status from Lead where Email != null and IsConverted=false and Reason_for_closure__c!=null and status!='Rejected' and status!='Processed' limit 1]);
      Lead_Manager acc = new Lead_Manager(sc);
      Test.startTest(); 
        acc.getLead();
        acc.saveLead();
        acc.cancelLead();
        
      Test.stopTest();
    }*/
    /*static testMethod void testDatetimeHelper()
    {
        Test.startTest();
          DateTimeHelper.isWeekDay(date.today());
          DateTimeHelper.toNextMonday(datetime.now(), datetime.now().addDays(2));
          DateTimeHelper.toLastFriday(datetime.now(), datetime.now().addDays(3));
        Test.stopTest();
    }*/
    /*static testMethod void OpportunityReportSender_Tester(){
        Test.startTest();
          OpportunityReportSender b = new OpportunityReportSender (); 
          b.GenerateReport();
        Test.stopTest();
    }*/
    /*static testMethod void testBatchClass() 
    {       
        /*List<Account> accounts = [SELECT Id FROM Account LIMIT 1000];
        String accountIdsCSV = '';
        for(Account account : accounts)
            accountIdsCSV += ',\'' + account.Id + '\'';
        accountIdsCSV = accountIdsCSV.substring(1);
        Account_BulkApprovalJob test_SubmitAccountsforApproval = new Account_BulkApprovalJob(accountIdsCSV, null);       */
        
      /*  Account_BulkApprovalJob test_SubmitAccountsforApproval = new Account_BulkApprovalJob(null, 'ApprovalAccountIds');       
        
        Test.startTest();       
        Database.executeBatch(test_SubmitAccountsforApproval, 50);     
        Test.stopTest();
    }*/
}
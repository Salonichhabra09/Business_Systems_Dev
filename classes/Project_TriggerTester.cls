@isTest(seeAllData = true)
@TestVisible
    
private class Project_TriggerTester
{
    static testMethod void testProjectTriggers()
    {
        List<ProjectObject__c> projects;
        List<Expense__c> expenses;
        List<Timesheet_Line__c> timesheets;
        List<Associate__c> associates;
        List<Project_Invoice__c> invoices;
        //Test.startTest();
        projects = insertProjects();
        
       // expenses = Expense_TriggerTester.insertExpenses(projects[0].Id);
         
        //timesheets = Timesheet_TriggerTester.insertTimesheets(projects[0].Id);
        
       // associates = Associate_TriggerTester.insertAssociates(projects[0].Id);
        
       // invoices = ProjectInvoice_TriggerTester.insertInvoices(projects [0].Id);       
        //Test.stopTest();  
        //
        Timesheet_TriggerTester.testTimesheetTriggers();
    }
    static testMethod void testProjectTriggers1A(){
        List<ProjectObject__c> projects;
        List<Timesheet_Line__c> timesheets;
        projects = insertProjects();
        timesheets = Timesheet_TriggerTester.insertTimesheets(projects[0].Id);
        Timesheet_TriggerTester.updateTimesheets(timesheets);
       // Test.startTest();
            List<Timesheet_Line__c> dTimesheets = new List<Timesheet_Line__c>();
            dTimesheets.add(timesheets[0]);
            Timesheet_TriggerTester.deleteTimesheets(dTimesheets);
            timesheets.remove(0);
        //Test.stopTest();  
    }
    static testMethod void testProjectTriggers1()
    {
        //insert new Trigger_Activation__c(Name = 'Project_Trigger', Active__c = true);
        List<ProjectObject__c> projects;
        List<Expense__c> expenses;
        List<Timesheet_Line__c> timesheets;
        List<Associate__c> associates;
        List<Project_Invoice__c> invoices;
        
        projects = insertProjects();
        
        //expenses = Expense_TriggerTester.insertExpenses(projects[0].Id);
        
        associates = Associate_TriggerTester.insertAssociates(projects[0].Id);
         // Test.startTest(); 
        //invoices = ProjectInvoice_TriggerTester.insertInvoices(projects[0].Id);
        
        updateProject(projects);
                
        changeProjectManager(projects, UserInfo.getUserId());
        
        //Expense_TriggerTester.updateExpenses(expenses);
        
        Associate_TriggerTester.updateAssociates(associates);
        //ProjectInvoice_TriggerTester.updateInvoices(invoices);
        
        List<Expense__c> dExpenses = new List<Expense__c>();
        //dExpenses.add(expenses[0]);
        //Expense_TriggerTester.deleteExpenses(dExpenses);
        //expenses.remove(0);
        
        List<Associate__c> dAssociates = new List<Associate__c>();
        dAssociates.add(associates[0]);
        Associate_TriggerTester.deleteAssociates(dAssociates);
        associates.remove(0);
        
        
        /*try
        {
            delete invoices[0];
        }
        catch(System.DmlException e)
        {
            system.debug(e.getMessage());
        }*/
        
        try
        {
            delete projects;
        }
        catch(System.DmlException e)
        {
            system.debug(e.getMessage());
        }
        //Test.stopTest();
    }
    static testMethod void testProjectInvoiceController()
    {
        //insert new Trigger_Activation__c(Name = 'Project_Trigger', Active__c = true);
        List<ProjectObject__c> projects;
        List<Expense__c> expenses;
        List<Timesheet_Line__c> timesheets;
        List<Associate__c> associates;
        List<Project_Invoice__c> invoices;
        
        projects = insertProjects();
         
        //expenses = Expense_TriggerTester.insertExpenses(projects[0].Id);
        timesheets = Timesheet_TriggerTester.insertTimesheets(projects[0].Id);
        associates = Associate_TriggerTester.insertAssociates(projects[0].Id);
        //invoices = ProjectInvoice_TriggerTester.insertInvoices(projects[0].Id);
        //expenses[0].Status__c = 'Submitted for Approval';
       
        //update expenses;
        

        /*Expense_ApprovalView eController = new Expense_ApprovalView();
        eController.invoiceId = invoices[0].Id;
        eController.rechargeable = true;
        eController.getExpenseGroups();
        //eController.approveExpenses();
        eController.rechargeable = false;
        eController.getExpenseGroups();
        //eController.rejectExpenses();
        
        Timesheet_ApprovalView tController = new Timesheet_ApprovalView();
        tController.invoiceId = invoices[0].Id;
        tController.getTimesheetGroups();*/
   
        //tController.approveTimesheets();  edited by saloni chhabra on 2/4/2015
    }
    
   /*  @istest static  void testListViewController()
    {
        List<ProjectObject__c> projects;
        List<Expense__c> expenses;
        List<Timesheet_Line__c> timesheets;
      
        projects = insertProjects();
        
       //expenses = Expense_TriggerTester.insertExpenses(projects[0].Id);
     // timesheets = Timesheet_TriggerTester.insertTimesheets(projects[0].Id);
        
        Expense_ListView_Controller eController = new Expense_ListView_Controller();
        eController.getExpenses();
        eController.projectId = projects[0].Id;
        eController.getExpenses();
        eController.Go();
        //Added at 30-09-2011
        eController.changeApprovalExpensesView();
        eController.getRechargeableExpenseGroup();
        //eController.approveExpenses();
        //eController.rejectExpenses();
      
      /*  Timesheet_ListView_Controller tController = new Timesheet_ListView_Controller();
        tController.getTimesheets();
        tController.projectId = projects[0].Id;
        tController.getTimesheets();
        tController.Go();*/
    //}*/
    
    //added by saloni chhabra on 7/22/2015 to cover Currency_Manager class code coverage
    public  static CurrencyType[] getAllCurrencyTypes()
    {
        CurrencyType[] currencyTypes = [SELECT IsoCode, ConversionRate FROM CurrencyType ORDER BY IsoCode];
        return currencyTypes;
    }
    
    public static CurrencyType getCurrencyType(String currencyIsoCode, CurrencyType[] currencyTypes)
    {  
        CurrencyType resultCurrencyType = new CurrencyType();  
        for(Integer i=0;i<currencyTypes.size();i++)  
        {    
            if(currencyTypes[i].IsoCode == currencyIsoCode)    
            {      
                resultCurrencyType = currencyTypes[i];      
                break;    
            }
        }  
        return resultCurrencyType;
    }
    
    static testMethod void testCurrency_Manager()
    {
        Test.startTest();
        //getAllCurrencyTypes();
        getCurrencyType('INR',getAllCurrencyTypes());
        
        
        Test.stopTest();
    }
    
    static testMethod void testRevenueObjects()
    {           
        List<ProjectObject__c> projects = insertProjects();
        
        List<RevenueScheduleItem__c> revenueScheduleItems = insertRevenueScheduleItems(projects[0]);
        updateRevenueScheduleItems(revenueScheduleItems);
        delete revenueScheduleItems[0];
              
        //List<Project_Invoice__c> invoices = ProjectInvoice_TriggerTester.insertInvoices(projects[0].Id);
        //Project_Manager.getProjectsForInvoices(invoices);
        
        //List<InvoiceRevenueScheduleItem__c> invoiceRevenueScheduleItems = ProjectInvoice_TriggerTester.insertInvoiceRevenueScheduleItems(invoices[0]);
        // Test.startTest(); 
        //ProjectInvoice_TriggerTester.updateInvoiceRevenueScheduleItems(invoiceRevenueScheduleItems);
        //delete invoiceRevenueScheduleItems[0];
        
        //List<InvoiceProductItem__c> invoiceProductItems = ProjectInvoice_TriggerTester.insertInvoiceProductItems(invoices[0]);
        //ProjectInvoice_TriggerTester.updateInvoiceProductItems(invoiceProductItems);
        
        //delete invoiceProductItems[0];
        //Test.stopTest();
    }
    
    static testMethod void testProjectManagerClass()
    {
        List<ProjectObject__c> projects;
        projects = insertProjects();
        Project_Manager.userCanCreateProjects();
        Project_Manager.userCanManageAllProjects();
        Project_Manager.getProjectWithUpdatedAmounts(projects[0],false);
        Project_Manager.populateProjectWithUpdatedAmounts(projects[0],false);
        Map<Id, Boolean> m = Project_Manager.userCanManageProjects(projects);
        
        User user = new User();
        user.Id = Userinfo.getUserId();
        user.PSA_Role__c = 'Project Manager';
       	
        update user;
        
        Project_Manager.userCanManageProjects(projects);
    }
    
    static testMethod void testSpecialMethods()
    {
        
        List<ProjectObject__c> projects;
        List<Expense__c> expenses;
        List<Timesheet_Line__c> timesheets;
        List<Associate__c> associates;
        List<Project_Invoice__c> invoices;
      //  Test.startTest();
        projects = insertProjects();
        
       // expenses = Expense_TriggerTester.insertExpenses(projects[0].Id);
        timesheets = Timesheet_TriggerTester.insertTimesheets(projects[0].Id);
      // associates = Associate_TriggerTester.insertAssociates(projects[0].Id);
      //  invoices = ProjectInvoice_TriggerTester.insertInvoices(projects[0].Id);
        
        //Expense_TriggerTester.testExpsenseControllers();
        //Expense_TriggerTester.testExpenseTriggers();
        Timesheet_TriggerTester.testSpecialMethods(timesheets);
        //ProjectInvoice_TriggerTester.testSpecialMethods(invoices[0].id);
  // test.stoptest();
    }
    @TestVisible
    static List<ProjectObject__c> insertProjects()
     {
        Account ActId =[Select id from Account where Business_Relationship__c='New Logo (Never Traded)' limit 1];
        Contact contact = [SELECT Id,AccountId from Contact where AccountId=:ActId.Id LIMIT 1]; 
        User usrRec = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];  
        List<String> lbuList = usrRec.Company_BU__c.split('-');
        List<ProjectObject__c> projects = new List<ProjectObject__c>();
        Opportunity opp = new Opportunity();
        opp.name = 'test Opp';
        opp.closedate = System.now().date();
        opp.Business_Type__c='Cross-sell: subscription';
        opp.Forecast_Category__c='Commit';
        opp.Stagename='Qualifying';
        opp.accountID = contact.accountId;
        test.starttest();
        insert opp;
        
       
            Contract contract = new Contract();
            Account account = [SELECT Id,CurrencyIsoCode from Account where id=:contact.AccountId];
            contract.AccountId = account.Id;   
            contract.CurrencyIsoCode = account.CurrencyIsoCode;
            contract.S2P_Reference_Required__c = 'New';
            contract.Status = 'Draft';
            contract.CustomerSignedDate = Date.Today();
            contract.StartDate = Date.Today();
            contract.ContractTerm = 6;  
            contract.Legal_Order_Name__c='test';
            contract.Subscription_Start_Date__c = Date.Today();
            insert contract;
            //Create a new Contract Line     
            Contract_Line__c contractLine = new Contract_Line__c();
            contractLine.Contract__c = contract.Id;
            contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
            contractLine.IM_Lookup_Code__c = 'Consulting';
            contractLine.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
            contractLine.PO_number__c = '12312323423';
            //contractLine.Price__c = 5000;
            contractLine.Order_Method__c='T&E';
            contractLine.Invoicing_Schedule__c = 'Special Invoicing Instructions';
            //insert contractLine;
            list<Project_Deliverables__c> listPD = new list<Project_Deliverables__c>();
            list<ProjectObject__c> listproject = new list<ProjectObject__c> ();
         for(Integer i=0;i<1;i++)
        {
            ProjectObject__c project = new ProjectObject__c();
            project.Project_Name__c = 'project_' + i;
            project.Account__c = contact.AccountId;
            project.Contact__c = contact.Id;
            project.Billing_Contact__c = contact.Id;
            project.Opportunity__c = opp.id;
           project.Project_Manager__c =usrRec.id;
            project.LBU__c = lbuList[1].trim();
            project.CurrencyIsoCode = account.CurrencyIsoCode;
            project.Functional_Area__c = 'Consulting & Training';
            project.Order_Header_Number__c = contract.id;
            //project.Order_Line_Number__c = contractLine.id;//Modified by prabhat on 6Aug'19
            project.Total_Actual_Time__c=1;
            project.Scoped_Hours_Effort__c=1;
            project.Additional_Scoped_Days__c = 1;
            project.Current_Scoped_Days_Effort__c = 1;
            project.additional_scoped_comments__c = 'test Comments';
            project.Chargeable__c = 'test';
            project.Reason__c = 'test';
             listproject.add(project);
        }
      
        insert listproject;
        for(ProjectObject__c proj:listproject )
        {
           ProjectObject__c proj1 =new ProjectObject__c (id=proj.id);
          proj1.Order_Line_Number__c = contractLine.id;
           proj1.Project_Cost__c=1234;
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
        
         
        test.stoptest();
   
        return projects;
     }
     
    static void updateProject(List<ProjectObject__c> insertedProjects)
    {
        List<ProjectObject__c> projects = new List<ProjectObject__c>();
        User user = [SELECT Id FROM User WHERE IsActive= :true AND PSA_Role__c!='PSA Lead' Limit 1];
        
        for(ProjectObject__c insertedproject: insertedProjects)
        {
            ProjectObject__c project = new ProjectObject__c(id=insertedproject.id);
            project.OwnerId = UserInfo.getUserId();
            //project.OwnerId = user.Id;
           // project.LBU__c = 'UK5';
            projects.add(project);
        }
    
        update projects;
    }
    
    static void changeProjectManager(List<ProjectObject__c> insertedProjects, String userId)
    {
        List<ProjectObject__c>  projects = new List<ProjectObject__c>();
                
        for(ProjectObject__c insertedproject: insertedProjects)
        {
            ProjectObject__c project = new ProjectObject__c(id=insertedproject.id);
            project.OwnerId = userId;
            projects.add(project);
        }
        
        update projects;
    }
    
     public static List<RevenueScheduleItem__c> insertRevenueScheduleItems(ProjectObject__c project)
     {
        system.debug('insertRevenueScheduleItem: Insert Started');
        List<RevenueScheduleItem__c> items = new List<RevenueScheduleItem__c>();
        for(Integer i=0;i<3;i++)
        {
            RevenueScheduleItem__c item = new RevenueScheduleItem__c();
            item.Project__c = project.Id;
            item.Functional_Area__c = 'PS';
            item.Revenue__c = 100;
            items.add(item);
        }
        
        insert items;
        system.debug('insertRevenueScheduleItem: Insert Completed');
        return items;
     }
     
    public static void updateRevenueScheduleItems(List<RevenueScheduleItem__c> insertedItems)
    {
        system.debug('InvoiceProductItem: Update Started');
        
        for(RevenueScheduleItem__c insertedItem: insertedItems)
            insertedItem.Revenue__c += 10;
        //test.starttest();
        update insertedItems;
        //test.stoptest();
        system.debug('InvoiceProductItem: Update Completed');
    }
    
     static testMethod void testBasicMethods()
    {
        List<ProjectObject__c> projects;
        List<Expense__c> expenses;
        List<Timesheet_Line__c> timesheets;
        List<Associate__c> associates;
        List<Project_Invoice__c> invoices;
        
        projects = insertProjects();
         
        //expenses = Expense_TriggerTester.insertExpenses(projects[0].Id);
        timesheets = Timesheet_TriggerTester.insertTimesheets(projects[0].Id);
        associates = Associate_TriggerTester.insertAssociates(projects[0].Id);
        associates[0].Rechargeable__c  = false;
        update associates; 
        Associate_TriggerTester.testBasicMethods(projects[0].Id);
        //invoices = ProjectInvoice_TriggerTester.insertInvoices(projects[0].Id);
        //expenses[0].Status__c = 'Submitted for Approval';
       
        //update expenses;
        

        /*Expense_ApprovalView eController = new Expense_ApprovalView();
        eController.invoiceId = invoices[0].Id;
        eController.rechargeable = true;
        eController.getExpenseGroups();
        //eController.approveExpenses();
        eController.rechargeable = false;
        eController.getExpenseGroups();
        //eController.rejectExpenses();
        
        Timesheet_ApprovalView tController = new Timesheet_ApprovalView();
        tController.invoiceId = invoices[0].Id;
        tController.getTimesheetGroups(); */
   
        //tController.approveTimesheets();  edited by saloni chhabra on 2/4/2015
    }
    static testMethod void testProject_BeforeUpdateTrigger() {
        Account ActId =[Select id from Account where Business_Relationship__c='New Logo (Never Traded)' limit 1];
        Contact contact = [SELECT Id,AccountId from Contact where AccountId=:ActId.Id LIMIT 1];
        //Contact contact = [SELECT Id,AccountId from Contact where AccountId!=null LIMIT 1]; 
        User usrRec = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];  
        List<String> lbuList = usrRec.Company_BU__c.split('-');
        List<ProjectObject__c> projects = new List<ProjectObject__c>();
        Opportunity opp = new Opportunity();
        opp.name = 'test Opp';
        opp.closedate = System.now().date();
        opp.Business_Type__c='Cross-sell: subscription';
        opp.Forecast_Category__c='Commit';
        opp.Stagename='Qualifying';
        opp.accountID = contact.accountId;
        Opportunity opp2 = new Opportunity();
        opp2.name = 'test Opp2';
        opp2.closedate = System.now().date();
        opp2.Business_Type__c='Cross-sell: subscription';
        opp2.Forecast_Category__c='Commit';
        opp2.Stagename='Qualifying';
        opp2.accountID = contact.accountId;
        
        test.starttest();
        insert opp;
        insert opp2;
       
            Contract contract = new Contract();
            Account account = [SELECT Id,CurrencyIsoCode from Account where id=:contact.AccountId];
            contract.AccountId = account.Id;   
            contract.CurrencyIsoCode = account.CurrencyIsoCode;
            contract.S2P_Reference_Required__c = 'New';
            contract.Status = 'Draft';
            contract.CustomerSignedDate = Date.Today();
            contract.StartDate = Date.Today();
            contract.ContractTerm = 6;  
            contract.Legal_Order_Name__c='test';
            contract.Subscription_Start_Date__c = Date.Today();
            insert contract;
            //Create a new Contract Line     
            Contract_Line__c contractLine = new Contract_Line__c();
            contractLine.Contract__c = contract.Id;
            contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
            contractLine.IM_Lookup_Code__c = 'Consulting';
            contractLine.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
            contractLine.PO_number__c = '12312323423';
            //contractLine.Price__c = 5000;
            contractLine.Order_Method__c='T&E';
            contractLine.Invoicing_Schedule__c = 'Special Invoicing Instructions';
            //insert contractLine;
            list<Project_Deliverables__c> listPD = new list<Project_Deliverables__c>();
            list<ProjectObject__c> listproject = new list<ProjectObject__c> ();
         for(Integer i=0;i<1;i++)
        {
            ProjectObject__c project = new ProjectObject__c();
            //project.RecordTypeId=Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
            
            project.Project_Name__c = 'project_' + i;
            project.Account__c = contact.AccountId;
            project.Contact__c = contact.Id;
            project.Billing_Contact__c = contact.Id;
            project.Opportunity__c = opp.id;
           project.Project_Manager__c =usrRec.id;
            project.LBU__c = lbuList[1].trim();
            project.CurrencyIsoCode = account.CurrencyIsoCode;
            project.Functional_Area__c = 'Consulting & Training';
            project.Order_Header_Number__c = contract.id;
            //project.Order_Line_Number__c = contractLine.id;
            project.Total_Actual_Time__c=1;
            project.Scoped_Hours_Effort__c=1;
            project.Additional_Scoped_Days__c = 1;
            project.Current_Scoped_Days_Effort__c = 1;
            project.additional_scoped_comments__c = 'test Comments';
            project.Chargeable__c = 'test';
            project.Reason__c = 'test';
             listproject.add(project);
        }
      
        insert listproject;
        for(ProjectObject__c proj:listproject)
        {
           ProjectObject__c proj1 =new ProjectObject__c (id=proj.id);
          //proj1.Order_Line_Number__c = contractLine.id;
          proj1.Opportunity__c=opp2.id;
          proj1.Additional_Scoped_Days__c=2;
          proj1.RecordTypeId=Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();  
          proj1.CPS_Project_Manager__c='Barbara Johnston';
          proj1.CS_Lead__c='Alison Hollamby';
          proj1.Technology_Lead__c='Agris Fridvalds';
          proj1.A_O_Lead__c='Andrew Speer';
          proj1.MIT_Lead__c='Avril Peryer';
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
          delete listPD;
        //update projects;
        test.stoptest();
   
    }

}
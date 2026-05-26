@isTest(seeAllData = true)
private class TimesheetTriggerManager_Tester
{
    static testMethod void TimeSheetTester(){
        //ProjectObject__c PsnoProj =[select id,PS_Project_Number__c,Functional_Area__c  from projectobject__c where id=:PsProjLst[0].Id];
        Account ActId =[Select id from Account where Business_Relationship__c='New Logo (Never Traded)' limit 1];
        Contact contact = [SELECT Id,AccountId from Contact where AccountId=:ActId.Id LIMIT 1];  
        User GlobsUser=[select id from user where username like'%globus.development@shlgroup.com%' limit 1];
        
        Opportunity opp = new Opportunity();
        opp.name = 'test Opp';
        opp.closedate = System.now().date();
        opp.Business_Type__c='New customer: subscription';//Modified by Jai
        opp.Forecast_Category__c='Pipeline';//Modified by Jai
        opp.Stagename='Qualifying';
        opp.accountID = contact.accountId;
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
        contract.Subscription_Start_Date__c =Date.today();
        insert contract;
        contract.Opportunity__c=opp.id;
        update contract;
        
        opportunity oppty=[select id,Order_Number__c from opportunity where id=:opp.id ];
        oppty.Order_Number__c=contract.Id;//prabhat
        Update oppty;//prabhat
        
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
        //list<Project_Deliverables__c> listPD = new list<Project_Deliverables__c>();
        list<ProjectObject__c> listproject = new list<ProjectObject__c> ();
        Id PsRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id selectedRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        //ProjectObject__c PsnoProj =[select id,PS_Project_Number__c,Functional_Area__c  from projectobject__c where PS_Project_Number__c!=null limit 1];
        ProjectObject__c PSproject = new ProjectObject__c();
        PSproject.Project_Name__c = 'project_TestPrab';
        Psproject.RecordTypeId=PsRecordTypeId;
        PSproject.Account__c = contact.AccountId;
        PSproject.Contact__c = contact.Id;
        PSproject.Billing_Contact__c = contact.Id;
        PSproject.Opportunity__c = opp.id;
        PSproject.Project_Manager__c =GlobsUser.Id;
        PSproject.LBU__c = 'US5';
        PSproject.CurrencyIsoCode = account.CurrencyIsoCode;
        PSproject.Functional_Area__c = 'Consulting & Training';
        PSproject.Order_Header_Number__c = contract.id;
        //project.Order_Line_Number__c = contractLine.id;
        PSproject.Total_Actual_Time__c=1;
        PSproject.Scoped_Hours_Effort__c=1;
        PSproject.Additional_Scoped_Days__c = 1;
        PSproject.Current_Scoped_Days_Effort__c = 1;
        PSproject.additional_scoped_comments__c = 'test Comments';
        PSproject.Chargeable__c = 'test';
        PSproject.Reason__c = 'test';
        insert PSproject;
        Timesheet_Line__c PStimesheet = new Timesheet_Line__c();
        integer J=1;
        //For PS Project
        List<Timesheet_Line__c> PStimesheetLst = new List<Timesheet_Line__c>();
        PStimesheet.Project__c =PSproject.Id;
        //timesheet.Project__c ='a09D000000vOLau';
        PStimesheet.Resource__c = GlobsUser.Id;
        //timesheet.Billable__c = true;
        PStimesheet.Time_Category__c='Delivery - Other';//Modified by Jai
        PStimesheet.Task_Category__c = 'PS Consulting';//Modified by prabhat
        PStimesheet.Task__c = 'Design';
        PStimesheet.Billable1__c = 'YES';
        //timesheet.Date_Invoiced__c = Date.newInstance(200,4+i,21);
        //timesheet.Billing_Rate__c = 50 + i*10;
        PStimesheet.Hours__c = 1;
        PStimesheet.Function__c = 'CT';
        //timesheet.Timesheet_From_CPS_Project__c=true;
        PStimesheetLst.add(PStimesheet);
        //Test.startTest();
        insert PStimesheetLst;
        system.debug('This is PSTimesheetNew'+PStimesheetLst);
        
        ProjectObject__c project = new ProjectObject__c();
        project.Project_Name__c = 'project_Test';
        project.RecordTypeId=selectedRecordTypeId;
        project.PS_Project_Number__c=PSproject.Id;
        project.Functional_Area__c = 'Consulting & Training';
        project.Account__c = contact.AccountId;
        project.Contact__c = contact.Id;
        project.Billing_Contact__c = contact.Id;
        project.Opportunity__c = opp.id;
        project.Project_Manager__c =GlobsUser.Id;
        project.LBU__c = 'US5';
        project.CurrencyIsoCode = account.CurrencyIsoCode;
        project.SD_C_Lead__c=GlobsUser.Id;
        project.Local_PS_Lead__c=GlobsUser.Id;
        project.Project_Status__c='Initiation';
        project.Signed_SoW__c='Yes';
        //project.Functional_Area__c = 'Consulting & Training';
        project.Order_Header_Number__c = contract.id;
        project.Total_Actual_Time__c=1;
        project.Scoped_Hours_Effort__c=1;
        project.Additional_Scoped_Days__c = 1;
        project.Current_Scoped_Days_Effort__c = null;
        project.additional_scoped_comments__c = 'test Comments';
        project.Chargeable__c = 'test';
        project.Reason__c = 'test';
        project.CPS_Project_Manager__c='Rishi Raj Arora';
        project.Delivered__c=System.today();
        project.Project_Manager__c=GlobsUser.Id;
        insert project;
        system.debug('This is CPSproject'+project);
        system.debug('This is CPSproject recordtype'+project.RecordTypeId);
        system.debug('This is a PSproject'+PSproject);
        system.debug('This is a PSproject'+PSproject.RecordTypeId);
        
        Timesheet_Line__c timesheet = new Timesheet_Line__c();
        integer i=1;
        List<Timesheet_Line__c> timesheetLst = new List<Timesheet_Line__c>();
        timesheet.Project__c =project.Id;
        //timesheet.Project__c ='a09D000000vOLau';
        timesheet.Resource__c = GlobsUser.Id;
        //timesheet.Billable__c = true;
        timesheet.Time_Category__c='Delivery - Other';//Modified by Jai
        timesheet.Task_Category__c = 'PS Consulting';//Modified by prabhat
        timesheet.Task__c = 'Design';
        timesheet.Billable1__c = 'YES';
        //timesheet.Date_Invoiced__c = Date.newInstance(200,4+i,21);
        //timesheet.Billing_Rate__c = 50 + i*10;
        timesheet.Hours__c = 1;
        timesheet.Function__c = 'CT';
        //timesheet.Timesheet_From_CPS_Project__c=true;
        timesheetLst.add(timesheet);
        Test.startTest();
        insert timesheetLst;
        system.debug('This is CPSTimesheet'+timesheetLst);
        
        timesheet.Hours__c = 2;
        update timesheetLst;
        Test.stopTest();
    }

    static testMethod void TimeSheetDelTester2(){
        Id PsRecordTypeId= Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
        User GlobsUser=[select id from user where username like'%globus.development@shlgroup.com%' limit 1];
        //User usrRec = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];
        ProjectObject__c PJ=[Select id from ProjectObject__c where RecordTypeId=: PsRecordTypeId limit 1];
        Timesheet_Line__c timesheet = new Timesheet_Line__c();
        integer i=1;
        List<Timesheet_Line__c> timesheetLst = new List<Timesheet_Line__c>();
        timesheet.Project__c =PJ.Id;//Modified by Jai
        //timesheet.Project__c ='a09D000000vOLau';//Modified by Jai
        timesheet.Resource__c = GlobsUser.Id;
        //timesheet.Billable__c = true;
        timesheet.Time_Category__c='Delivery - Other';//Modified by Jai
        timesheet.Task_Category__c = 'PS Consulting';//Modified by prabhat
        timesheet.Task__c = 'Design';
        timesheet.Billable1__c = 'YES';
        timesheet.Date_Invoiced__c = Date.newInstance(2008,4+i,21);
        //timesheet.Billing_Rate__c = 50 + i*10;
        timesheet.Hours__c = 0;
        timesheet.Function__c = 'CT';
        timesheet.Timesheet_From_CPS_Project__c=true;
        timesheetLst.add(timesheet);
        insert timesheetLst;
        system.debug('This is PS Timesheet'+timesheetLst);
        test.starttest();
        delete timesheetLst;
        test.stoptest();
    }
    
}
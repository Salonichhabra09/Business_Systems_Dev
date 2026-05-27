@isTest
private class Timesheet_Manager_Tester {

    @testSetup
    static void setupTestData() {
        insert new Trigger_Activation__c(Name = 'Account_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Contact_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Opportunity_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Timesheet_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Project_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Job_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'OpportunityContactRoleTrigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'OpportunityLineItem_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'ProjectInvoice_Trigger', Active__c = true);

         AutomaticJobCreation__c autoJobSettings = new AutomaticJobCreation__c(
            Name = 'Values',
            MS_Line_of_Business__c = 'Consulting,Delivery,Support'
        );
        insert autoJobSettings;

        //Account acc = CreateTestData.GetAccount();
        Account ActId=new Account(Industry='Agriculture',name='Test Account',Business_Relationship__c = 'New Logo (Never Traded)',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert ActId;
        //Contact con = CreateTestData.getContact(acc.Id);
        Contact contact = new Contact();
        contact.LastName = 'test'+System.now().date();
        //contact.Same_As_The_Account_Billing_Address__c = true;
        contact.Mailing_Address_Line_1__c = 'India';
        contact.Mailing_City__c = 'India';
        contact.Mailing_ZIP_Postal_Code__c ='122018';
        contact.Mailing_Country__c = 'India';
        contact.accountId = ActId.id;
        insert contact;
        //Opportunity opp = CreateTestData.getOpportunity(acc.Id, con.Id);
        Opportunity opp = new Opportunity();
        opp.name = 'test Opp';
        opp.closedate = System.now().date();
        opp.Business_Type__c='New customer: subscription';
        opp.Forecast_Category__c='Pipeline';
        opp.Stagename='Information Gathering';
        opp.accountID = contact.accountId;
        insert opp;
        
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = contact.Id,
            Role = 'Decision Maker',
            IsPrimary = true
        );
        insert ocr;
        
        Product2 p = new Product2(Name = 'Professional Service Product', isActive = true);
        insert p;
    
        Id standardPBId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = standardPBId, UnitPrice = 100, IsActive = true);
        insert pbe;
    
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            PricebookEntryId = pbe.Id,
            TotalPrice = 100
        );
        insert oli;
        
        
        
        ProjectObject__c project = CreateTestData.getProject(ActId.Id, opp.Id);
        Project_Invoice__c invoice = CreateTestData.getProjectInvoice(project.Id);
        
        
        Invoice_Billing_Detail__c bill = new Invoice_Billing_Detail__c();
        bill.Amount_Unit_Price__c = 1000;
        bill.Quantity__c = 2;
        bill.Invoice_Request__c = invoice.Id;
        
        insert bill;

        Timesheet_Line__c ts = new Timesheet_Line__c(
            Project__c = project.Id,
            Hours__c = 2,
            Billable__c = true,
            Status__c = 'Approved',
            Date_Invoiced__c = Date.today(),
            Resource__c = UserInfo.getUserId(),
            Time_Cost__c = 0,
            CurrencyIsoCode = project.CurrencyIsoCode,
            Time_Category__c = 'Internal Organisation',
            Task__c = 'Admin, Management And Meetings'
        );
        insert ts;
    }

    @isTest
    static void test_getRelatedInvoices() {
        List<Timesheet_Line__c> timesheets = [SELECT Id, Project__c, Date_Invoiced__c FROM Timesheet_Line__c LIMIT 1];
        Test.startTest();
        List<Project_Invoice__c> invoices = Timesheet_Manager.getRelatedInvoices(timesheets);
        Test.stopTest();
        System.assertNotEquals(null, invoices);
    }

    @isTest
    static void test_updateRelatedInvoices() {
        List<Timesheet_Line__c> timesheets = [SELECT Id, Project__c, Date_Invoiced__c FROM Timesheet_Line__c LIMIT 1];
        Test.startTest();
        Timesheet_Manager.updateRelatedInvoices(timesheets);
        Test.stopTest();
    }

    @isTest
    static void test_copyDataFromProject() {
        List<Timesheet_Line__c> timesheets = [SELECT Id, Project__c, Project_Manager__c FROM Timesheet_Line__c LIMIT 1];
        for (Timesheet_Line__c t : timesheets) {
            t.Project_Manager__c = null;
        }
        Test.startTest();
        Timesheet_Manager.copyDataFromProject(timesheets);
        Test.stopTest();
    }

   @isTest
    static void test_updateTimeCostValues() {
        List<Timesheet_Line__c> timesheets = [SELECT Id, Resource__c, Hours__c, CurrencyIsoCode FROM Timesheet_Line__c LIMIT 1];
        Test.startTest();
        Timesheet_Manager.updateTimeCostValues(timesheets);
        Test.stopTest();
    }

    @isTest
    static void test_updateDataInTimesheets_project_change() {
        ProjectObject__c original = [SELECT Id, OwnerId FROM ProjectObject__c LIMIT 1];
        ProjectObject__c updated = original.clone(false, false, false, false);
        insert updated;

        updated.OwnerId = UserInfo.getUserId();
        Test.startTest();
        Timesheet_Manager.updateDataInTimesheets(original, updated);
        Test.stopTest();
    }

    @isTest
    static void test_updateDataInTimesheets_invoice_change() {
        Project_Invoice__c oldInvoice = [SELECT Id, Project__c, Status__c, Start_Date__c, End_Date__c FROM Project_Invoice__c where InvoicingTotal__c !=0 LIMIT 1];
        Project_Invoice__c newInvoice = oldInvoice.clone(false, true, false, false);
        insert newInvoice;
        
        Invoice_Billing_Detail__c bill = new Invoice_Billing_Detail__c();
        bill.Amount_Unit_Price__c = 1000;
        bill.Quantity__c = 2;
        bill.Invoice_Request__c = newInvoice.Id;
        
        insert bill;

        newInvoice.Status__c = 'Processed';
        //update newInvoice;

        Test.startTest();
        Timesheet_Manager.updateDataInTimesheets(oldInvoice, newInvoice);
        Test.stopTest();
    }
}
@istest
public class ProjectInvoice_ManagerTest {
	@istest(seealldata = true)
    public static void ProjectInvoice_ManagerTestMethod(){
        
        Account acc=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con=new Contact(lastname='Test Contact', Accountid=acc.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert con;
        
        list<Product2> prodlist = new list <Product2>();
        Product2 Prod = new Product2(Name = 'test product 1',IsActive=true,Revenue_Category__c='Professional Services',Renewable__c = 'Yes');
        prodlist.add(prod);
        Product2 Prod2 = new Product2(Name = 'test product 2',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes');
        prodlist.add(prod2);
        Product2 Prod3 = new Product2(Name = 'test product 3',IsActive=true,Revenue_Category__c='Training');
        prodlist.add(prod3);
        insert prodlist;
        
        ProjectObject__c project = new ProjectObject__c();
        project.Project_Name__c = 'Test project';
        project.Account__c = acc.id;
        project.Contact__c = con.Id;
        project.Billing_Contact__c = con.Id;
        project.LBU__c = 'UK1';
        project.Functional_Area__c = 'PS Consulting';
        project.Order_Products_Count__c = 2;
        project.Project_Co_ordinator__c = userinfo.getUserId();
        insert project;
        
        ProjectObject__c project2 = new ProjectObject__c();
        project2.Project_Name__c = 'Test project';
        project2.Account__c = acc.id;
        project2.Contact__c = con.Id;
        project2.Billing_Contact__c = con.Id;
        project2.LBU__c = 'UK1';
        project2.Functional_Area__c = 'Sales';
        insert project2;
        
        Project_Invoice__c pinvoice = new Project_Invoice__c();
        pinvoice.Project__c = project.Id;
        pinvoice.Account__c = acc.id;
        pinvoice.Contact_Name__c = con.Id;
       pinvoice.Start_Date__c = Date.newInstance(2011,09,10);
        pinvoice.End_Date__c = Date.newInstance(2011,09,10);
        pinvoice.Sun_Invoice_No__c = '1234';
        pinvoice.Product_IM_Code__c = '1234567890123';
        insert pinvoice;
        
        Project_Invoice__c pinvoice2 = new Project_Invoice__c();
        pinvoice2.Project__c = project.Id;
        pinvoice2.IM1_LookupCode__c = 'abc';
        pinvoice2.IM2_LookupCode__c = 'abc';
        pinvoice2.IM3_LookupCode__c = 'abc';
        pinvoice2.IM4_LookupCode__c = 'abc';
        pinvoice2.IM5_LookupCode__c = 'abc';
        pinvoice2.IM1_Quantity__c = 0;
        pinvoice2.IM2_Quantity__c = 0;
        pinvoice2.IM3_Quantity__c = 0;
        pinvoice2.IM4_Quantity__c = 0;
        pinvoice2.IM5_Quantity__c = 0; 
        pinvoice2.IM1_UnitPrice__c = 100;
        pinvoice2.IM2_UnitPrice__c = 100;
        pinvoice2.IM3_UnitPrice__c = 100;
        pinvoice2.IM4_UnitPrice__c = 100;
        pinvoice2.IM5_UnitPrice__c = 100;
        pinvoice2.Account__c = acc.id;
        pinvoice2.Contact_Name__c = con.Id;
        pinvoice2.Start_Date__c = Date.newInstance(2011,09,10);
        pinvoice2.End_Date__c = Date.newInstance(2011,09,10);
        pinvoice2.Status__c = 'In Progress';
        insert pinvoice2;
        
        Invoice_Billing_Detail__c invoiceBillingDetail1 = new Invoice_Billing_Detail__c();
        invoiceBillingDetail1.Invoice_Request__c = pinvoice.id;
        invoiceBillingDetail1.Expense_Recharge__c = 10;
        invoiceBillingDetail1.Amount_Unit_Price__c = 100;
        invoiceBillingDetail1.Quantity__c = 10;
        invoiceBillingDetail1.Product__c = prodlist[0].id;    
        insert invoiceBillingDetail1;
        
        Invoice_Billing_Detail__c invoiceBillingDetail2 = new Invoice_Billing_Detail__c();
        invoiceBillingDetail2.Invoice_Request__c = pinvoice2.id;
        invoiceBillingDetail2.Expense_Recharge__c = 10;
        invoiceBillingDetail2.Amount_Unit_Price__c = 100;
        invoiceBillingDetail2.Quantity__c = 10;
        invoiceBillingDetail2.Product__c = prodlist[0].id;    
        insert invoiceBillingDetail2;
        
        list<InvoiceProductItem__c> IPIList = new list<InvoiceProductItem__c>();
        IPIList.add(new InvoiceProductItem__c(Invoice_Request__c = pinvoice.id,Product_IM_Code__c = '1234567890123'));
        insert IPIList;
        
        list<InvoiceRevenueScheduleItem__c> IRSList = new list<InvoiceRevenueScheduleItem__c>();
        IRSList.add(new InvoiceRevenueScheduleItem__c(Invoice_Request__c = pinvoice.id));
        insert IRSList;
        
        list<Project_Invoice__c> PIList = new list<Project_Invoice__c>();
        PIList.add(pinvoice);
         test.startTest();
        ProjectInvoice_Manager.getExpensesRelatedToInvoice(pinvoice);
        ProjectInvoice_Manager.getTimesheetsRelatedToInvoice(pinvoice);
        ProjectInvoice_Manager.getExpensesRelatedToInvoice(pinvoice2);
        ProjectInvoice_Manager.getTimesheetsRelatedToInvoice(pinvoice2);
        ProjectInvoice_Manager.copyDataFromProject(pinvoice,project,1);
        ProjectInvoice_Manager.updateDataInInvoices(project2,project);
        ProjectInvoice_Manager.submitInvoice(pinvoice.id);
        ProjectInvoice_Manager.processInvoice(pinvoice.id,'1234');
        ProjectInvoice_Manager.submitInvoice(pinvoice2.id);
        ProjectInvoice_Manager.rejectInvoice(pinvoice2.id,'test');
        ProjectInvoice_Manager.processIMLookupvalues(pinvoice2);
        ProjectInvoice_Manager.updateInvoiceTotalProductAmount(IPIList);
        ProjectInvoice_Manager.signRevenueScheduleItemsOnCreditStatus(PIList);
        ProjectInvoice_Manager.signRevenueScheduleItemsOnCreditStatus(IRSList);
        ProjectInvoice_Manager.signProductItemsOnCreditStatus(PIList);
        test.stopTest();
    }
}
@isTest
public class InvoiceBillingDetailsControllerTest {

@istest(seealldata=true)
    public static void InvoiceBillingDetailsControllerTestMethod(){
        
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
        
        list<PricebookEntry> pbelist = new list<PricebookEntry>();
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod2.id,UnitPrice = 100,IsActive=true);
        pbelist.add(pbe2);
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod3.id,UnitPrice = 100,IsActive=true);
        pbelist.add(pbe3);
        insert pbelist;
        
        ProjectObject__c project = new ProjectObject__c();
        project.Project_Name__c = 'Test project';
        project.Account__c = acc.id;
        project.Contact__c = con.Id;
        project.Billing_Contact__c = con.Id;
        project.LBU__c = 'UK1';
        project.Functional_Area__c = 'PS Consulting';
        project.Order_Products_Count__c = 2;
        insert project;
        string projectname = [select name from ProjectObject__c where id = :project.id].name;
        
        ProjectObject__c project2 = new ProjectObject__c();
        project2.Project_Name__c = 'Test project';
        project2.Account__c = acc.id;
        project2.Contact__c = con.Id;
        project2.Billing_Contact__c = con.Id;
        project2.LBU__c = 'UK1';
        project2.Functional_Area__c = 'PS Consulting';
        project2.Order_Products_Count__c = 2;
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
        
        Contract contract = new Contract();
        contract.AccountId = acc.Id;   
        contract.CurrencyIsoCode = acc.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;  
        contract.Legal_Order_Name__c='test';
        contract.Subscription_Start_Date__c = system.today();
        insert contract;
        
        Order ord = new Order();
    Id orderrt = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Standard Order').getRecordTypeId();

        ord.Accountid = acc.id;
        ord.ContractId = contract.id;
        ord.name = 'test';
       // ord.RecordTypeId = '0127E0000032wq7';
        ord.Status = 'Draft';
        ord.RecordTypeId = orderrt;
        ord.EffectiveDate = system.today();
        ord.CurrencyIsoCode = contract.CurrencyIsoCode;
        ord.Pricebook2Id = '01s2000000000vQAAQ';
        insert ord;
        
        
        
        orderitem op = new orderitem();
        op.quantity = 1;
        op.UnitPrice = 1000;
        op.orderid = ord.id;
        op.PricebookEntryId = pbe2.id;
        op.Project__c = project.id;
        insert op;
        
        orderitem op2 = new orderitem();
        op2.quantity = 1;
        op2.UnitPrice = 1000;
        op2.orderid = ord.id;
        op2.PricebookEntryId = pbe2.id;
        op2.Project__c = project2.id;
        insert op2;
        
        PS_Order_Product__c psop = new PS_Order_Product__c();
        psop.order_product__c = op.id;
        psop.Invoice_Request__c = pinvoice.id;
            insert psop;
        
        PS_Order_Product__c psop2 = new PS_Order_Product__c();
        psop2.order_product__c = op.id;
        psop2.Invoice_Request__c = pinvoice.id;
            insert psop2;
            
        Invoice_Billing_Detail__c invoiceBillingDetail = new Invoice_Billing_Detail__c();
        invoiceBillingDetail.Invoice_Request__c = pinvoice.id;
        invoiceBillingDetail.Product__c = prodlist[0].id;    
        insert invoiceBillingDetail;
        
        PageReference pageRef = Page.InvoiceBillingDetailsOverrirdePage;
            pageRef.getParameters().put('Id', invoiceBillingDetail.id);
            Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(invoiceBillingDetail);  
        InvoiceBillingDetailsOverrirdeController  controller = new InvoiceBillingDetailsOverrirdeController(sc);
    }

}
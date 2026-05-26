/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is test class for UpdateProjectDetailsOnInvHeader.                                                       *
*                                                                                                                                  *
* Date : 03-Oct-2023                                                                                                               *
************************************************************************************************************************************/

@isTest(seealldata=true)
public class UpdateProjectDetailsOnInvoiceTest {
    
    @isTest
    public static void getProjectDataTest1(){
        Test.startTest();
        Account acc = new Account(name= 'Update Project on Inv 0310' ,Status__c='Approved',
                                  CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',
                                  Billing_City__c='Test City',Buying_Centre_Id__c = 'Test1',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con =  CreateTestData.getContact(acc.id);
        Opportunity opp = CreateTestData.getOpportunity(acc.id,con.id);
        Contract contr = CreateTestData.getContract(acc.id,opp.id);
        Order ord = CreateTestData.getOrder(Contr.id,acc.id);
        ord.OpportunityId = opp.id ;
        update ord;
        
        ProjectObject__c proj = CreateTestData.getProject(acc.id,opp.id);
        ProjectObject__c proj1 = CreateTestData.getProject(acc.id,opp.id);
        
        Product2 productRecord2 = new Product2();
        productRecord2.name = 'Test data';
        productRecord2.Revenue_Category__c='Professional Services';
        productRecord2.Renewable__c = 'Yes';
        productRecord2.Status__c = 'Revenue Ready';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry PBE = new PricebookEntry();
        PBE.CurrencyIsoCode='GBP';
        PBE.IsActive=True;
        PBE.Pricebook2Id=pricebookId;
        PBE.UnitPrice =0;
        PBE.Product2Id = productRecord2.id;
        insert PBE;
        
        OrderItem  orderItem = new OrderItem(OrderId = ord.Id, UnitPrice = 10,Quantity = 10,
                                             PricebookEntryId = PBE.id ,Product2Id =productRecord2.id,
                                             Project__c =proj.id );
        insert orderItem;
        
        OrderItem  orderItem2 = new OrderItem(OrderId = ord.Id, UnitPrice = 10,Quantity = 10,
                                              PricebookEntryId = PBE.id ,Product2Id =productRecord2.id,
                                              Project__c =proj1.id );
        insert orderItem2;
        
        
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = con.id;
        invoiceHeader.Account__c = acc.id;
        invoiceHeader.Contract__c = contr.id;
        invoiceHeader.CurrencyIsoCode = 'GBP';
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = 'China - CN1';
        invoiceHeader.Service_End_Date__c  = system.Today();
        invoiceHeader.Service_End_Date__c  = system.Today();
        invoiceHeader.Order__c = ord.id;
        insert invoiceHeader;
        
        
        List<Contract_Invoice_Line__c> contractLineList = new  List<Contract_Invoice_Line__c>();
        Contract_Invoice_Line__c invoiceLine = new Contract_Invoice_Line__c();
        invoiceLine.Invoice_Header_ID__c = invoiceHeader.id;
        invoiceLine.CurrencyIsoCode = 'GBP';
        invoiceLine.Month__c = '201111';
        invoiceLine.Discount_Amount__c = 1;
        invoiceLine.Quantity__c = 10;
        invoiceLine.Price__c=100;
        invoiceLine.Invoice_Line_Total__c=1000;
        invoiceLine.Order_Product_Id__c  = orderItem.id;
        invoiceLine.ProductStream_SystemUse__c = 'Professional Services';
        contractLineList.add(invoiceLine);
        
        Contract_Invoice_Line__c invoiceLine1 = new Contract_Invoice_Line__c();
        invoiceLine1.Invoice_Header_ID__c = invoiceHeader.id;
        invoiceLine1.CurrencyIsoCode = 'GBP';
        invoiceLine1.Month__c = '201111';
        invoiceLine1.Discount_Amount__c = 1;
        invoiceLine1.Quantity__c = 10;
        invoiceLine1.Price__c=100;
        invoiceLine1.Invoice_Line_Total__c=1000;
        invoiceLine1.Order_Product_Id__c  = orderItem2.id;
        invoiceLine1.ProductStream_SystemUse__c = 'Professional Services';
        contractLineList.add(invoiceLine1);
        
        insert contractLineList;
        
        invoiceHeader.Project_Number__c = '';
        update invoiceHeader;
        UpdateProjectDetailsOnInvHeader.getProjectData(invoiceHeader.id);
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void getProjectDataTest2(){
        Test.startTest();
        Account acc = new Account(name= 'Update Project on Inv 0310' ,Status__c='Approved',
                                  CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',
                                  Billing_City__c='Test City',Buying_Centre_Id__c = 'Test1',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con =  CreateTestData.getContact(acc.id);
        Opportunity opp = CreateTestData.getOpportunity(acc.id,con.id);
        Contract contr = CreateTestData.getContract(acc.id,opp.id);
        Order ord = CreateTestData.getOrder(Contr.id,acc.id);
        ord.OpportunityId = opp.id ;
        update ord;
        
        ProjectObject__c proj = CreateTestData.getProject(acc.id,opp.id);
        
        
        Product2 productRecord2 = new Product2();
        productRecord2.name = 'Test data';
        productRecord2.Revenue_Category__c='Professional Services';
        productRecord2.Renewable__c = 'Yes';
        productRecord2.Status__c = 'Revenue Ready';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry PBE = new PricebookEntry();
        PBE.CurrencyIsoCode='GBP';
        PBE.IsActive=True;
        PBE.Pricebook2Id=pricebookId;
        PBE.UnitPrice =0;
        PBE.Product2Id = productRecord2.id;
        insert PBE;
        
        OrderItem  orderItem = new OrderItem(OrderId = ord.Id, UnitPrice = 10,Quantity = 10,
                                             PricebookEntryId = PBE.id ,Product2Id =productRecord2.id,
                                             Project__c =proj.id );
        insert orderItem;
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = con.id;
        invoiceHeader.Account__c = acc.id;
        invoiceHeader.Contract__c = contr.id;
        invoiceHeader.CurrencyIsoCode = 'GBP';
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = 'China - CN1';
        invoiceHeader.Service_End_Date__c  = system.Today();
        invoiceHeader.Service_End_Date__c  = system.Today();
        invoiceHeader.Order__c = ord.id;
        insert invoiceHeader;
        
        
        List<Contract_Invoice_Line__c> contractLineList = new  List<Contract_Invoice_Line__c>();
        Contract_Invoice_Line__c invoiceLine = new Contract_Invoice_Line__c();
        invoiceLine.Invoice_Header_ID__c = invoiceHeader.id;
        invoiceLine.CurrencyIsoCode = 'GBP';
        invoiceLine.Month__c = '201111';
        invoiceLine.Discount_Amount__c = 1;
        invoiceLine.Quantity__c = 10;
        invoiceLine.Price__c=100;
        invoiceLine.Invoice_Line_Total__c=1000;
        invoiceLine.Order_Product_Id__c  = orderItem.id;
        invoiceLine.ProductStream_SystemUse__c = 'Professional Services';
        contractLineList.add(invoiceLine);
        
        insert contractLineList;
        
        invoiceHeader.Project_Number__c = 'ORD-202323' ;
        update invoiceHeader;
        UpdateProjectDetailsOnInvHeader.getProjectData(invoiceHeader.id);
        
        Test.stopTest(); 
        
    }
    
    @isTest
    public static void getProjectDataTest3(){
        Test.startTest();
        Account acc = new Account(name= 'Update Project on Inv 0310' ,Status__c='Approved',
                                  CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',
                                  Billing_City__c='Test City',Buying_Centre_Id__c = 'Test1',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con =  CreateTestData.getContact(acc.id);
        Opportunity opp = CreateTestData.getOpportunity(acc.id,con.id);
        Contract contr = CreateTestData.getContract(acc.id,opp.id);
        Order ord = CreateTestData.getOrder(Contr.id,acc.id);
        ord.OpportunityId = opp.id ;
        update ord;
        
        ProjectObject__c proj = CreateTestData.getProject(acc.id,opp.id);
        ProjectObject__c proj1 = CreateTestData.getProject(acc.id,opp.id);
        
        Product2 productRecord2 = new Product2();
        productRecord2.name = 'Test data';
        productRecord2.Revenue_Category__c='Professional Services';
        productRecord2.Renewable__c = 'Yes';
        productRecord2.Status__c = 'Revenue Ready';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry PBE = new PricebookEntry();
        PBE.CurrencyIsoCode='GBP';
        PBE.IsActive=True;
        PBE.Pricebook2Id=pricebookId;
        PBE.UnitPrice =0;
        PBE.Product2Id = productRecord2.id;
        insert PBE;
        
        OrderItem  orderItem = new OrderItem(OrderId = ord.Id, UnitPrice = 10,Quantity = 10,
                                             PricebookEntryId = PBE.id ,Product2Id =productRecord2.id,
                                             Project__c =proj.id );
        insert orderItem;
        
        OrderItem  orderItem2 = new OrderItem(OrderId = ord.Id, UnitPrice = 10,Quantity = 10,
                                              PricebookEntryId = PBE.id ,Product2Id =productRecord2.id,
                                              Project__c =proj1.id );
        insert orderItem2;
        
        
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = con.id;
        invoiceHeader.Account__c = acc.id;
        invoiceHeader.Contract__c = contr.id;
        invoiceHeader.CurrencyIsoCode = 'GBP';
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = 'China - CN1';
        invoiceHeader.Service_End_Date__c  = system.Today();
        invoiceHeader.Service_End_Date__c  = system.Today();
        invoiceHeader.Order__c = ord.id;
        insert invoiceHeader;
        
        
        List<Contract_Invoice_Line__c> contractLineList = new  List<Contract_Invoice_Line__c>();
        Contract_Invoice_Line__c invoiceLine = new Contract_Invoice_Line__c();
        invoiceLine.Invoice_Header_ID__c = invoiceHeader.id;
        invoiceLine.CurrencyIsoCode = 'GBP';
        invoiceLine.Month__c = '201111';
        invoiceLine.Discount_Amount__c = 1;
        invoiceLine.Quantity__c = 10;
        invoiceLine.Price__c=100;
        invoiceLine.Invoice_Line_Total__c=1000;
        invoiceLine.Order_Product_Id__c  = orderItem.id;
        invoiceLine.ProductStream_SystemUse__c = 'Professional Services';
        contractLineList.add(invoiceLine);
        
        Contract_Invoice_Line__c invoiceLine1 = new Contract_Invoice_Line__c();
        invoiceLine1.Invoice_Header_ID__c = invoiceHeader.id;
        invoiceLine1.CurrencyIsoCode = 'GBP';
        invoiceLine1.Month__c = '201111';
        invoiceLine1.Discount_Amount__c = 1;
        invoiceLine1.Quantity__c = 10;
        invoiceLine1.Price__c=100;
        invoiceLine1.Invoice_Line_Total__c=1000;
        invoiceLine1.Order_Product_Id__c  = orderItem2.id;
        invoiceLine1.ProductStream_SystemUse__c = 'Professional Services';
        contractLineList.add(invoiceLine1);
        
        insert contractLineList;
        
        ProjectObject__c projectObject   = [SELECT Id, name , Project_Status__c from ProjectObject__c where id = :proj.id];
        ProjectObject__c projectObject1   = [SELECT Id, name , Project_Status__c from ProjectObject__c where id = :proj1.id];
        proj.Project_Status__c = 'Cancelled';
        update proj;
        
        invoiceHeader.Project_Number__c = projectObject.name ;        
        update invoiceHeader;
     
        
        UpdateProjectDetailsOnInvHeader.getProjectData(invoiceHeader.id);     
        UpdateProjectDetailsOnInvHeader.updateProjectNumber(projectObject1.name,invoiceHeader.id);  
        Test.stopTest(); 
    }
    
    @isTest
    public static void getProjectDataTest4(){
        Test.startTest();
        Account acc = new Account(name= 'Update Project on Inv 0310' ,Status__c='Approved',
                                  CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',
                                  Billing_City__c='Test City',Buying_Centre_Id__c = 'Test1',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con =  CreateTestData.getContact(acc.id);
        Opportunity opp = CreateTestData.getOpportunity(acc.id,con.id);
        Contract contr = CreateTestData.getContract(acc.id,opp.id);
        Order ord = CreateTestData.getOrder(Contr.id,acc.id);
        ord.OpportunityId = opp.id ;
        update ord;
        
        ProjectObject__c proj = CreateTestData.getProject(acc.id,opp.id);
        ProjectObject__c proj1 = CreateTestData.getProject(acc.id,opp.id);
        
        Product2 productRecord2 = new Product2();
        productRecord2.name = 'Test data';
        productRecord2.Revenue_Category__c='Product subscription';
        productRecord2.Renewable__c = 'Yes';
        productRecord2.Status__c = 'Revenue Ready';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry PBE = new PricebookEntry();
        PBE.CurrencyIsoCode='GBP';
        PBE.IsActive=True;
        PBE.Pricebook2Id=pricebookId;
        PBE.UnitPrice =0;
        PBE.Product2Id = productRecord2.id;
        insert PBE;
        
        OrderItem  orderItem = new OrderItem(OrderId = ord.Id, UnitPrice = 10,Quantity = 10,
                                             PricebookEntryId = PBE.id ,Product2Id =productRecord2.id
                                            );
        insert orderItem;
        

          
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = con.id;
        invoiceHeader.Account__c = acc.id;
        invoiceHeader.Contract__c = contr.id;
        invoiceHeader.CurrencyIsoCode = 'GBP';
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = 'China - CN1';
        invoiceHeader.Service_End_Date__c  = system.Today();
        invoiceHeader.Service_End_Date__c  = system.Today();
        invoiceHeader.Order__c = ord.id;
        insert invoiceHeader;
        
        
        List<Contract_Invoice_Line__c> contractLineList = new  List<Contract_Invoice_Line__c>();
        Contract_Invoice_Line__c invoiceLine = new Contract_Invoice_Line__c();
        invoiceLine.Invoice_Header_ID__c = invoiceHeader.id;
        invoiceLine.CurrencyIsoCode = 'GBP';
        invoiceLine.Month__c = '201111';
        invoiceLine.Discount_Amount__c = 1;
        invoiceLine.Quantity__c = 10;
        invoiceLine.Price__c=100;
        invoiceLine.Invoice_Line_Total__c=1000;
        invoiceLine.Order_Product_Id__c  = orderItem.id;
        invoiceLine.ProductStream_SystemUse__c = 'Product subscription';
        contractLineList.add(invoiceLine);
        
        insert contractLineList;
        
        ProjectObject__c projectObject   = [SELECT Id, name , Project_Status__c from ProjectObject__c where id = :proj.id];
        proj.Project_Status__c = 'Cancelled';
        update proj;
        
        invoiceHeader.Project_Number__c = projectObject.name ;        
        update invoiceHeader;
     
        
        UpdateProjectDetailsOnInvHeader.getProjectData(invoiceHeader.id);        
        Test.stopTest(); 
    }
    
    
}
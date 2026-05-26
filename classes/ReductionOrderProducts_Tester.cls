@istest
public class ReductionOrderProducts_Tester {
	@istest(seealldata=true)
    public static void testMethod1(){
        
        Account acc=new Account(name='Test Account',Industry='Legal',
                                Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con=new Contact(lastname='Test Contact', Accountid=acc.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert con;
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Order' and r.Name='Standard Order' limit 1];
        list<Product2> prodlist = new list <Product2>();
        Product2 Prod = new Product2(Name = 'test product 1',Status__c='Revenue Ready',
                                     IsActive=true,Revenue_Category__c='Professional Services',Renewable__c = 'Yes');
        prodlist.add(prod);
        Product2 Prod2 = new Product2(Name = 'test product 2',Status__c='Revenue Ready',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes');
        prodlist.add(prod2);
        Product2 Prod3 = new Product2(Name = 'test product 3',Status__c='Revenue Ready',IsActive=true,Revenue_Category__c='Training');
        prodlist.add(prod3);
        insert prodlist;
        
        list<PricebookEntry> pbelist = new list<PricebookEntry>();
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod2.id,UnitPrice = 100,IsActive=true);
        pbelist.add(pbe2);
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod3.id,UnitPrice = 100,IsActive=true);
        pbelist.add(pbe3);
        insert pbelist;
                
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
       ord.RecordTypeId = RT.id;
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
        insert op;
        
        List<Orderitem> orditemlist = new List<Orderitem>();
        orderitem op2 = new orderitem();
        op2.quantity = 1;
        op2.UnitPrice = 1000;
        op2.orderid = ord.id;
        op2.PricebookEntryId = pbe2.id;
        insert op2;
        orditemlist.add(op2);
        
        PageReference pageRef = Page.ReductionOrderProducts;
        pageRef.getParameters().put('id', Ord.id);
		pageRef.getParameters().put('Orderid', Ord.id);
		pageRef.getParameters().put('RecordType', RT.id);
		Test.setCurrentPage(pageRef);
        ReductionOrderProducts controller = new ReductionOrderProducts();
        //controller.ProductName = Productname;
        controller.orderItemList = orditemlist;
        controller.wrapOrderItemList.get(0).Orderitemrec = op2;
        controller.wrapOrderItemList.get(0).selected = True;
        controller.AddProducts();
    }
}
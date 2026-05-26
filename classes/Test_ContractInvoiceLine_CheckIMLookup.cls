@isTest(SeeAllData=true)
public class Test_ContractInvoiceLine_CheckIMLookup {
   public static testMethod void testTrigger(){
        Account acc= new Account();     // insert account
        acc.Name='Test234';
        acc.BU__c='India - IN1';
        acc.CurrencyIsoCode='GBP'; 
        acc.Industry='Legal';
        acc.Billing_Address_Line_1__c='test23';
        acc.Billing_City__c='test23';
        acc.Same_As_The_Billing_Address__c=true;
        acc.Billing_Country__c='test23';
        acc.Billing_State__c='test23';
        acc.Billing_ZIP_Postal_Code__c='test23';  
        acc.Business_Relationship__c='New Logo (Never Traded)';   
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'abc';
        con.AccountId = acc.id;
        con.email = 'abc@gmail.com';
        con.phone = '123';
        con.Same_As_The_Account_Billing_Address__c=true;
        insert con;
        
        Opportunity opp= new Opportunity();
        opp.OwnerId=UserInfo.getUserId();
        opp.AccountId=acc.Id;
        opp.Billing_Contact__c=con.Id;
        opp.Primary_Contact__c=con.Id;
        opp.name='Test Opportunity';
        opp.NVM_Credit_Card_ID__c='';
        opp.Unconfirmed_Sun_Order_Number__c='';
        opp.CurrencyISOCode='GBP';
        opp.StageName='Prepare';
        opp.closeDate=System.today();
        //Order_number__c=contract.Id;
        opp.Business_Type__c='NBB - New Logo';
      //  opp.Forecast_Category__c='Commit';
        insert opp;
       
        Pricebook2 PR1 = [Select Id, Name, IsActive From Pricebook2 where name='Configurator Price Book' limit 1];
        Product2 MSProd =[select id from Product2 where IsActive=true and ms_product__c=true limit 1];
        PricebookEntry PE2 =[Select id,IsActive,CurrencyIsoCode from PricebookEntry where IsActive=true and CurrencyIsoCode = 'GBP' 
                             and Pricebook2Id =:PR1.id  and Product2Id=:MSProd.id limit 1];
        Product2 PSProd =[select id from Product2 where IsActive=true and Revenue_Category__c='Professional Services' limit 1];
        PricebookEntry PE3 =[Select id,IsActive,CurrencyIsoCode from PricebookEntry where IsActive=true and CurrencyIsoCode = 'GBP' and Pricebook2Id =:PR1.id  and Product2Id=:PSProd.id limit 1];
        
        OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opp.id,UnitPrice=100,
                                                       CurrencyChange__c = false,Package__c = 'Bespoke',
                                                       RenewableNew__c = 'Ongoing',PricebookEntryId=PE2.id,
                                                       Quantity=1,Start_Date__c= system.today(),
                                                       End_Date__c=system.today()+1,Solution_Cap__c = 1);
            insert LI;
        
        Contract contract = new Contract();
        contract.AccountId = acc.Id;  
        contract.Legal_Order_Name__c = 'test'; 
        contract.CurrencyIsoCode = acc.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;   
        contract.Activated_Date__c=datetime.now();
        contract.Subscription_Start_Date__c = date.today();
        contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract.Submission_Offset__c = 10;
        contract.Agreement__c = 'Order';
        contract.Opportunity__c = opp.id;
        Test.startTest();
        insert contract;
        Test.stopTest();
       
        Order Ord = new Order();
        Ord.AccountId=acc.id;
        Ord.ContractId=contract.id;
        Ord.Order_Year__c = 1;
        Ord.Booked_Elsewhere__c = False;
        Ord.EffectiveDate=date.today();
        Ord.Submission_Offset__c = -18000000;
        //Ord.ActivatedDate =date.today();
        Ord.Activation_Offset__c = -18000000;
        Ord.Status='Draft';
        Ord.Pricebook2Id = PR1.id;
        Ord.Rejection_Reason__c='Rejecting request with a comment.';
        insert Ord;
       
        OrderItem ordItem = new OrderItem();
        ordItem.Quantity = LI.Quantity;
        ordItem.UnitPrice = LI.UnitPrice;
        ordItem.Opportunity_Product_Id__c = LI.id;
        ordItem.Product2Id = MSProd.id;
        ordItem.OrderId = Ord.id;
        ordItem.PricebookEntryId= PE2.id;
        insert ordItem;
         
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();  // New Header
        invoiceHeader.Contract__c = contract.Id;
        invoiceHeader.Order__c = Ord.id;
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.CurrencyIsoCode = contract.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = Date.Today();
        //Contact contact = [Select id,Account.BU__c from Contact where AccountId=:contract.AccountId limit 1];
        invoiceHeader.Billing_Contact__c = con.id;
        invoiceHeader.BU__c = 'India - IN1';
        invoiceHeader.Invoice_Status__c = 'Cross Border';
        insert invoiceHeader;
        
        /*Contract_Line__c contractLine = new Contract_Line__c();  // New Orderline
        contractLine.Contract__c = contract.Id; 
        contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
        contractLine.IM_Lookup_Code__c = 'Consulting';
        contractLine.Usage_Allowance__c = 'Capped';
        contractLine.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
        contractLine.PO_number__c = '12312323423'; 
        contractLine.Platform__c = 'Brainbench'; 
        contractLine.Usage_Cap__c = 123;
        insert contractLine;*/
             
        Contract_Invoice_Line__c invoiceLine = new Contract_Invoice_Line__c ();   // New Invoice Line
       // invoiceLine.Contract_Line_Id__c = contractLine.Id;
       // invoiceLine.CurrencyIsoCode = contractLine.CurrencyIsoCode;
        invoiceLine.Invoice_Header_Id__c = invoiceHeader.Id;
        invoiceLine.Quantity__c = 10;
        invoiceLine.Invoice_Line_Total__c=20;
        invoiceLine.Discount_Amount__c =2;
        invoiceLine.Price__c=200;
        
        invoiceLine.Month__c = '201106';
        insert invoiceLine;
        
        //contractLine.Usage_Allowance__c = 'UnCapped';
        //update contractLine;
        
       // contractLine.Platform__c = 'S2P';
       // contractLine.IM_Lookup_Code__c  = 'Training - Public';
       // update contractLine;
        
        /*contractLine.IM_Lookup_Code__c = 'Development Coach';
        contractLine.Platform__c = '';
        contractLine.Usage_Allowance__c = '';
        update contractLine;*/
        
        }
}
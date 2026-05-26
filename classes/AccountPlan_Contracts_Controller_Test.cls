@isTest(seeAlldata=true)
public class AccountPlan_Contracts_Controller_Test {

    @isTest
    static void testGetAccountContracts() {
        Test.startTest();

        Product2 Product=new Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Product.Revenue_Category__c='Training';
        Product.Status__c='End Of Life';
        Insert Product;
       
        PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = Product.Id, 
            UnitPrice = 1000,
            CurrencyIsoCode='GBP', 
            IsActive = true);
        insert standardPBE;
        
        Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23';   
        insert acc;

        Account_Plan__c accPlan = new Account_Plan__c(
        Account_Name__c = acc.Id  , Account_Plan_Type__c ='Current');
        insert accPlan;
		
        Contract contract = new Contract();
        contract.StartDate = Date.Today();
        contract.Contract_End_Date__c = Date.today().addDays(1);
        contract.ContractTerm = 12;
        contract.AccountId = acc.Id;
        contract.Status = 'Draft';
        contract.Subscription_Start_Date__c = Date.Today();
        insert contract;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.newInstance(2022, 12, 31);
        opp.StageName = 'Closed Won';
        opp.Amount = 1000;
        opp.Opportunity_Deal_Year__c = 1;
        opp.AccountId = acc.Id;
        opp.ContractId = contract.Id;
        insert opp;
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();      
        OpportunityLineItem oli=new OpportunityLineItem(
            RenewableNew__c = 'Ongoing',
            OpportunityId=opp.id,
            PricebookEntryId=standardPBE.Id,
            TotalPrice=100,
            Quantity=1,
            Platform__c='iAssess',
            Solution_Cap__c = 12,
            Usage_Allowance__c='Capped', 
            Usage_Cap_or_Estimation__c=1234,
            Basis_of_Fees__c='Applications',
            List_Price__c=100,
            Proposition__c='Graduate Hiring',
            Package__c='Graduate Advanced');
        olis.add(oli);
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            RenewableNew__c = 'Ongoing',
            OpportunityId=opp.id,
            PricebookEntryId=standardPBE.Id,
            TotalPrice=100,
            Quantity=1,
            Platform__c='iAssess',
            Solution_Cap__c = 12,
            Usage_Allowance__c='Capped', 
            Usage_Cap_or_Estimation__c=1234,
            Basis_of_Fees__c='Applications',
            List_Price__c=100,
            Proposition__c='Graduate Hiring',
            Package__c='Graduate Essential'
        );
        olis.add(oli1);
        insert olis;
        
        List<AccountPlan_Contracts_Controller.ContractsWrapper> result = AccountPlan_Contracts_Controller.getAccountContracts(accPlan.Id);
        Test.stopTest();

        // Verify the result is not null
        System.assertNotEquals(null, result);
    }
    //Added by Prachi SSE-21663
    @isTest
    static void testGetRegionalAccountContracts() {
        Test.startTest();

        Product2 Product=new Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Product.Revenue_Category__c='Training';
        Product.Status__c='End Of Life';
        Insert Product;
       
        PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = Product.Id, 
            UnitPrice = 1000,
            CurrencyIsoCode='GBP', 
            IsActive = true);
        insert standardPBE;
        
        Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23'; 
            acc.Buying_Centre_Id__c = 'Test Id 1';
        insert acc;

        Account_Plan__c accPlan = new Account_Plan__c(
        Account_Name__c = acc.Id  , Account_Plan_Type__c ='Regional' , Buying_Centre_Id__c = 'Test Id 1');
        insert accPlan;
		
        Contract contract = new Contract();
        contract.StartDate = Date.Today();
        contract.Contract_End_Date__c = Date.today().addDays(1);
        contract.ContractTerm = 12;
        contract.AccountId = acc.Id;
        contract.Status = 'Draft';
        contract.Subscription_Start_Date__c = Date.Today();
        insert contract;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.newInstance(2022, 12, 31);
        opp.StageName = 'Closed Won';
        opp.Amount = 1000;
        opp.Opportunity_Deal_Year__c = 1;
        opp.AccountId = acc.Id;
        opp.ContractId = contract.Id;
        insert opp;
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();      
        OpportunityLineItem oli=new OpportunityLineItem(
            RenewableNew__c = 'Ongoing',
            OpportunityId=opp.id,
            PricebookEntryId=standardPBE.Id,
            TotalPrice=100,
            Quantity=1,
            Platform__c='iAssess',
            Solution_Cap__c = 12,
            Usage_Allowance__c='Capped', 
            Usage_Cap_or_Estimation__c=1234,
            Basis_of_Fees__c='Applications',
            List_Price__c=100,
            Proposition__c='Graduate Hiring',
            Package__c='Graduate Advanced');
        olis.add(oli);
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            RenewableNew__c = 'Ongoing',
            OpportunityId=opp.id,
            PricebookEntryId=standardPBE.Id,
            TotalPrice=100,
            Quantity=1,
            Platform__c='iAssess',
            Solution_Cap__c = 12,
            Usage_Allowance__c='Capped', 
            Usage_Cap_or_Estimation__c=1234,
            Basis_of_Fees__c='Applications',
            List_Price__c=100,
            Proposition__c='Graduate Hiring',
            Package__c='Graduate Essential'
        );
        olis.add(oli1);
        insert olis;
        
        List<AccountPlan_Contracts_Controller.ContractsWrapper> result = AccountPlan_Contracts_Controller.getAccountContracts(accPlan.Id);
        Test.stopTest();

        // Verify the result is not null
        System.assertNotEquals(null, result);
    }
    
    //Added by Prachi SSE-21663
    @isTest
    static void testGetGlobalAccountContracts() {
        Test.startTest();

        Product2 Product=new Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Product.Revenue_Category__c='Training';
        Product.Status__c='End Of Life';
        Insert Product;
       
        PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = Product.Id, 
            UnitPrice = 1000,
            CurrencyIsoCode='GBP', 
            IsActive = true);
        insert standardPBE;
        
        Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23'; 
            acc.Buying_Centre_Id__c = 'Test Id 1';
        insert acc;
        
         Account acc1= new Account();
            acc1.Name='Data 123';
            acc1.BU__c='UK - UK1';
            acc1.CurrencyIsoCode='GBP'; 
            acc1.Industry='Agriculture';
            acc1.Billing_Address_Line_1__c='test23';
            acc1.Billing_City__c='test23';
            acc1.Same_As_The_Billing_Address__c=true;
            acc1.Billing_Country__c='test23';
            acc1.Billing_State__c='test23';
            acc1.Billing_ZIP_Postal_Code__c='test23'; 
            acc1.Buying_Centre_Id__c = 'Test Id 1';
            acc1.ParentId = acc.id;
        insert acc1;

        Account_Plan__c accPlan = new Account_Plan__c(
        Account_Name__c = acc.Id  , Account_Plan_Type__c ='Global' );
        insert accPlan;
		
        Contract contract = new Contract();
        contract.StartDate = Date.Today();
        contract.Contract_End_Date__c = Date.today().addDays(1);
        contract.ContractTerm = 12;
        contract.AccountId = acc.Id;
        contract.Status = 'Draft';
        contract.Subscription_Start_Date__c = Date.Today();
        insert contract;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = Date.newInstance(2022, 12, 31);
        opp.StageName = 'Closed Won';
        opp.Amount = 1000;
        opp.Opportunity_Deal_Year__c = 1;
        opp.AccountId = acc.Id;
        opp.ContractId = contract.Id;
        insert opp;
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();      
        OpportunityLineItem oli=new OpportunityLineItem(
            RenewableNew__c = 'Ongoing',
            OpportunityId=opp.id,
            PricebookEntryId=standardPBE.Id,
            TotalPrice=100,
            Quantity=1,
            Platform__c='iAssess',
            Solution_Cap__c = 12,
            Usage_Allowance__c='Capped', 
            Usage_Cap_or_Estimation__c=1234,
            Basis_of_Fees__c='Applications',
            List_Price__c=100,
            Proposition__c='Graduate Hiring',
            Package__c='Graduate Advanced');
        olis.add(oli);
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            RenewableNew__c = 'Ongoing',
            OpportunityId=opp.id,
            PricebookEntryId=standardPBE.Id,
            TotalPrice=100,
            Quantity=1,
            Platform__c='iAssess',
            Solution_Cap__c = 12,
            Usage_Allowance__c='Capped', 
            Usage_Cap_or_Estimation__c=1234,
            Basis_of_Fees__c='Applications',
            List_Price__c=100,
            Proposition__c='Graduate Hiring',
            Package__c='Graduate Essential'
        );
        olis.add(oli1);
        insert olis;
        
        List<AccountPlan_Contracts_Controller.ContractsWrapper> result = AccountPlan_Contracts_Controller.getAccountContracts(accPlan.Id);
        Test.stopTest();

        // Verify the result is not null
        System.assertNotEquals(null, result);
    }
}
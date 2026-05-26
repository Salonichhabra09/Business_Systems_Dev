@isTest(seeAlldata=true)
public class Create_Renewal_OrderProducts_Tester {
    
    @isTest static void create_OrderProducts_Test(){
        Test.startTest();
        
        Create_Renewal_OrderProducts.InputValues input = new  Create_Renewal_OrderProducts.InputValues();
        input.OrderYear = '2';
        
        input.OpportunityLineItemList_Original = new List<OpportunityLineItem>();
        
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2 Product=new Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Product.Revenue_Category__c='Training';
        Product.Status__c = 'Beta';
        Insert Product;
       
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id,
                                                        Product2Id = Product.Id, 
                                                        UnitPrice = 1000,
                                                        CurrencyIsoCode='GBP', 
                                                        IsActive = true);
        insert standardPBE;
        

        //Account account=CreateTestData.getAccount();
        Datetime variable=System.now();
        String Testname='Test Account'+variable;
        Account account=new Account(name=Testname,Status__c='Approved',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                        Billing_Country__c='India',Billing_State__c='Test',Industry= 'Agriculture',
                                        Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert account;
        
        //Contact contact=CreateTestData.getContact(account.id);
        Contact contact=new Contact(lastname='Test Contact',
                                    AccountId=account.Id,
                                    Same_As_The_Account_Billing_Address__c=true,
                                    Mailing_Address_Line_1__c ='test',
                                    Mailing_City__c='test',
                                    Mailing_ZIP_Postal_Code__c ='110094',
                                    Mailing_Country__c='India');
        insert contact;
        
        Opportunity opportunity=new Opportunity(name='Test Opportunity', 
                                                AccountID=account.id,
                                                Offering__c='Enterprise Leadership',
                                                Talent_Level__c='Leader',
                                                Talent_Segment__c='Volume',
                                                Client_Business_Function__c='HR');
        opportunity.ownerid=UserInfo.getUserId();
        opportunity.Billing_Contact__c=contact.id;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=contact.id;
        opportunity.CurrencyIsoCode='GBP';
        opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity.NVM_Credit_Card_ID__c='1234';
        opportunity.Amount=1000;
        opportunity.Variation_Opportunity__c='NO';
        opportunity.Original_Opportunity__c=null;
        opportunity.Annual_Contract_Value__c=1000.00;
        opportunity.StageName='New';   
        opportunity.GCSC__c='Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';
        opportunity.Skip_Validation__c=True;
        opportunity.TM_Phase__c='Mixed';
        opportunity.Package_Level__c='Basic';
        //opportunity.Forecast_Category__c='Forecast';
        opportunity.Business_Type__c='NBB - New Logo';
        opportunity.RecordTypeId=System.label.StandardRecordType;
        opportunity.Skip_Validation__c=True;
        opportunity.Pricebook2Id = standardPB.Id;
        insert opportunity;
        
        OpportunityLineItem originalOLI=new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                        OpportunityId=opportunity.id,
                                                        PricebookEntryId=standardPBE.id,
                                                        TotalPrice=100,
                                                        Quantity=1,
                                                        Platform__c='iAssess',
                                                        Solution_Cap__c = 12,
                                                        Usage_Allowance__c='Capped', 
                                                        Usage_Cap_or_Estimation__c=1234,
                                                        Basis_of_Fees__c='Applications',
                                                        List_Price__c=100,
                                                        Proposition__c='Graduate Hiring',
                                                        Package__c='Graduate Advanced',
                                                        Contract_Year__c = '1',
                                                        Product2Id = Product.Id);
        insert originalOLI;
        
        List<Create_Renewal_OrderProducts.OutputValues> outputsList = new List<Create_Renewal_OrderProducts.OutputValues>();

        List<Create_Renewal_OrderProducts.InputValues> inputList = new List<Create_Renewal_OrderProducts.InputValues>();
        inputList.add(input);
        
        outputsList = Create_Renewal_OrderProducts.create_OrderProducts(inputList);
        
        input.OpportunityLineItemList_Original.add(originalOLI);

        outputsList = Create_Renewal_OrderProducts.create_OrderProducts(inputList);
		input.OrderYear = '1';
        outputsList = Create_Renewal_OrderProducts.create_OrderProducts(inputList);
        
        Test.stopTest();
    }
}
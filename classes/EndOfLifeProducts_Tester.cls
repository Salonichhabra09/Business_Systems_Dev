@isTest(seeAlldata=true)
public class EndOfLifeProducts_Tester {
    @isTest static void existEOFProducts_Test(){
        Test.startTest();
         Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2 Product=new Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Product.Revenue_Category__c='Training';
        Product.Status__c='End Of Life';
        Insert Product;
       
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id,
                                                        Product2Id = Product.Id, 
                                                        UnitPrice = 1000,
                                                        CurrencyIsoCode='GBP', 
                                                        IsActive = true);
        insert standardPBE;
        

       // Account account=CreateTestData.getAccount();
       // Contact contact=CreateTestData.getContact(account.id);
        Datetime variable=System.now();
       	String Testname='Test Account'+variable;
       	Account account=new Account(name=Testname,
                                    Status__c='Approved',
                                    Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',
                                    Billing_Country__c='India',
                                    Billing_State__c='Test',
                                    Billing_ZIP_Postal_Code__c='1100110',
                                    BU__c='China - CN1',
                                    Industry = 'Agriculture');
        insert account;
        
        Contact contact=new Contact(lastname='Test Contact',AccountId=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test'; 
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';         
        contact.Mailing_Country__c='India';
        contact.Area_of_Interest__c = 'Talent Management';
        contact.Title = 'Contact Test';
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
        
        Opportunity opportunity1=new Opportunity(name='Test Opportunity', 
                                                AccountID=account.id,
                                                Offering__c='Enterprise Leadership',
                                                Talent_Level__c='Leader',
                                                Talent_Segment__c='Volume',
                                                Client_Business_Function__c='HR');
        opportunity1.ownerid=UserInfo.getUserId();
        opportunity1.Billing_Contact__c=contact.id;
        opportunity1.Closedate=system.today();
        opportunity1.Primary_Contact__c=contact.id;
        opportunity1.CurrencyIsoCode='GBP';
        opportunity1.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity1.NVM_Credit_Card_ID__c='1234';
        opportunity1.Amount=1000;
        opportunity1.Variation_Opportunity__c='NO';
        opportunity1.Original_Opportunity__c=null;
        opportunity1.Annual_Contract_Value__c=1000.00;
        opportunity1.StageName='New';   
        opportunity1.GCSC__c='Phone';
        opportunity1.OpportunityAmountMappedWithLead__c = 323.34;
        opportunity1.OpportunityTypeMappedWithLead__c = 'New Business';
        opportunity1.Skip_Validation__c=True;
        opportunity1.TM_Phase__c='Mixed';
        opportunity1.Package_Level__c='Basic';
        //opportunity.Forecast_Category__c='Forecast';
        opportunity1.Business_Type__c='Renewal';
        opportunity1.RecordTypeId=System.label.StandardRecordType;
        opportunity1.Skip_Validation__c=True;
        opportunity1.Pricebook2Id = standardPB.Id;
        insert opportunity1;
        
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
                                                        Product2Id = Product.Id);
        insert originalOLI;
        
        OpportunityLineItem originalOLI1=new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                        OpportunityId=opportunity1.id,
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
                                                        Product2Id = Product.Id);
        insert originalOLI1;
		//For Account
        EndOfLifeProducts.existEOFProducts(account.id, 'Account');
        //For Opportunity
        EndOfLifeProducts.existEOFProducts(opportunity.id, 'Opportunity');
        
        EndOfLifeProducts_Invocable.InputValues input = new  EndOfLifeProducts_Invocable.InputValues();
        input.recordId = opportunity.id; 
        input.objectName = '';
        List<EndOfLifeProducts_Invocable.InputValues> inputList = new List<EndOfLifeProducts_Invocable.InputValues>();
        inputList.add(input);
        
        List<EndOfLifeProducts_Invocable.OutputValues> outputList = new List<EndOfLifeProducts_Invocable.OutputValues>();
        outputList = EndOfLifeProducts_Invocable.existEOFProducts(inputList);
        
        Test.stopTest();
    }
}
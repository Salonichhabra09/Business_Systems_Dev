@isTest(seeAlldata=true)
public class Add_PriceBookEntryId_To_OppProd_Tester {
    @isTest static void matchPriceBookId_with_OpportunityProduct_Test(){
        Test.startTest();
        Add_PriceBookEntryId_To_OppProduct.InputValues input = new  Add_PriceBookEntryId_To_OppProduct.InputValues();
        input.CurrencyIsoCode = 'GBP';
        
        input.OpportunityProductList_Original = new List<OpportunityLineItem>();
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Product2 Product=new Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Product.Revenue_Category__c='Training';
        Insert Product;
       
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id,
                                                        Product2Id = Product.Id, 
                                                        UnitPrice = 1000,
                                                        CurrencyIsoCode='GBP', 
                                                        IsActive = true);
        insert standardPBE;
        

        Account account=CreateTestData.getAccount();
        Contact contact=CreateTestData.getContact(account.id);
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
                                                        Product2Id = Product.Id);
        input.OpportunityProductList_Original.add(originalOLI);
        
        input.OpportunityProductList_ToCreate = new List<OpportunityLineItem>();
        OpportunityLineItem newOLI = originalOLI.clone(false,false,false,false);
        input.OpportunityProductList_ToCreate.add(newOLI);
        
        input.PriceBook2Id = standardPB.Id;
        
        List<Add_PriceBookEntryId_To_OppProduct.InputValues> inputList = new List<Add_PriceBookEntryId_To_OppProduct.InputValues>();
        inputList.add(input);
        
        Add_PriceBookEntryId_To_OppProduct.matchPriceBookId_with_OpportunityProduct(inputList);
        System.assert(newOLI.Id != null);
        Test.stopTest();
    }
}
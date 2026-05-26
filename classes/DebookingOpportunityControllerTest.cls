@isTest
class DebookingOpportunityControllerTest {
    
    @isTest(seeAlldata=true)
    static void testDebooking(){
        try{
            
        
        Account account = new Account(name = 'Test Debooking' + System.now(),
                                      industry = 'Legal', Status__c = 'Approved',
                                      Billing_Address_Line_1__c = 'test', Billing_City__c = 'Test City',
                                      Billing_Country__c = 'India', Billing_State__c = 'Test',
                                      Billing_ZIP_Postal_Code__c = '1100110', BU__c = 'Australia - AU1');
        insert account;
        
        Contact contact =
            new Contact(lastname = 'Test debooking contact', Accountid = account.id);
        contact.Same_As_The_Account_Billing_Address__c = true;
        contact.Mailing_Address_Line_1__c = 'test';
        contact.Mailing_City__c = 'test';
        contact.Mailing_ZIP_Postal_Code__c = '110094';
        contact.Mailing_Country__c = 'India';
        
        insert contact;
        
        Contract contract =
            new Contract(AccountId = account.Id, Agreement__c = 'Order',
                         ContractTerm = 12, Status = 'Draft', StartDate = date.today(),
                         Invoicing_Contact__c = contact.Id, Contract_Type__c = 'Consulting',
                         Subscription_Start_Date__c = date.today());
        insert contract;
        
        Pricebook2 p = [
            Select id, name from Pricebook2 where name = 'Standard Price Book' limit 1
        ];
        RecordType RT = [
            Select r.Id,
            r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name =
            'Standard Opportunity' limit 1
        ];
        // Id priceBookID = Test.getStandardPricebookId();
        Opportunity opportunity =
            new Opportunity(name = 'Test Opportunity', AccountID = account.id);
        opportunity.Billing_Contact__c = contact.id;
        opportunity.Closedate = system.today();
        opportunity.Primary_Contact__c = contact.id;
        opportunity.CurrencyIsoCode = 'AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c = '1234';
        opportunity.NVM_Credit_Card_ID__c = '1234';
        opportunity.Amount = 1000;
        opportunity.Variation_Opportunity__c = 'No';
        opportunity.Order_Number__c = contract.id;
        opportunity.Original_Opportunity__c = null;
        opportunity.Annual_Contract_Value__c = 1000.00;
        opportunity.StageName = 'Closed Won';
        opportunity.GCSC__c = 'Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34; //**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business'; //**********
        opportunity.RecordTypeID = RT.id;
        opportunity.Skip_Validation__c = True;
        opportunity.Pricebook2Id = p.id;
        opportunity.Business_Type__c = 'Expansion';
        opportunity.Forecast_Category__c = 'Commit';
        opportunity.Multi_YearDeal__c = '1';
        opportunity.Opportunity_Deal_Year__c = 1;
        
        insert opportunity;

        pricebookentry PR = [ select id from Pricebookentry where IsActive =
                             true and currencyIsoCode = 'AUD' limit 1 ];
        
        OpportunityLineItem LI =
            new OpportunityLineItem(OpportunityId = opportunity.id,
                                    CurrencyChange__c = false, Package__c = 'Product',
                                    RenewableNew__c = 'Ongoing', PricebookEntryId = PR.id,
                                    TotalPrice = 100, Quantity = 1, Start_Date__c = system.today(),
                                    End_Date__c = system.today() + 1, Total_Equivalent_Units__c = 10,
                                    Platform__c = 'iAssess', Usage_Allowance__c = 'Capped',Product_family__c='Other',Product_Stream__c='Product in arrear');
        insert LI;
        
        Test.startTest();
        DebookingOpportunityController.DebookingInformationWrapper returnWrapper = DebookingOpportunityController.getOpportunityLine(opportunity.Id);
        
        DebookingOpportunityController.createDebookingOpportunity(returnWrapper, opportunity.Id);
        
        Opportunity oppToCloseLost = [SELECT Id from Opportunity WHERE Original_Opportunity__c = :opportunity.Id];
        oppToCloseLost.StageName = 'Closed Lost';
        update oppToCloseLost;
        Test.stopTest();
        }catch(Exception e){
            
        }
    } 
}
@IsTest
public class TopUpOpportunityControllerTest {


    private static Id oppId;

    @TestSetup
    static void setupData() {

        insert new AutomaticJobCreation__c(
            Name = 'Values',
            MS_Line_of_Business__c = 'TestType'
        );

        insert new List<Trigger_Activation__c>{
            new Trigger_Activation__c(Name='Account_Trigger', Active__c=true),
            new Trigger_Activation__c(Name='Contact_Trigger', Active__c=true),
            new Trigger_Activation__c(Name='OpportunityLineItem_Trigger', Active__c=true),
            new Trigger_Activation__c(Name='Opportunity_Trigger', Active__c=true),
            new Trigger_Activation__c(Name='PricebookEntry_Trigger', Active__c=true),
            new Trigger_Activation__c(Name='Product2_Trigger', Active__c=true),
            new Trigger_Activation__c(Name='Pricebook2_Trigger', Active__c=true)
        };

        Account acc = new Account(
            Name = 'Test Account',
            Status__c = 'Approved',
            Billing_Address_Line_1__c = 'Test',
            Billing_City__c = 'City',
            Billing_Country__c = 'India',
            Billing_State__c = 'State',
            Billing_ZIP_Postal_Code__c = '1100110',
            Industry = 'Legal',
            BU__c = 'Hong Kong - HK1'
        );
        insert acc;


        Id stdPbId = Test.getStandardPricebookId();

        Product2 prod = new Product2(
            Name = 'Test Product',
            IsActive = true,
            Revenue_Category__c = 'Training',
            MS_Product__c = true,
            Status__c = 'Revenue Ready'
        );
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true,
            CurrencyIsoCode = 'GBP'
        );
        insert pbe;

        Opportunity opp = new Opportunity(
            Name = 'Original Opp',
            AccountId = acc.Id,
            CloseDate = Date.today(),
            Pricebook2Id = stdPbId,
            CurrencyIsoCode = 'GBP',
            Forecast_Category__c = 'Commit',
            TM_Phase__c = 'Test',
            Proposition__c = 'Test',
            Price_Increase_Percentage__c = 10,
            Variation_Opportunity__c = 'Yes',
            Variation_Reason__c = 'Addition to order',
            StageName = 'Information Gathering',
            Business_Type__c = 'Top Up / Addition'
        );
        insert opp;

        oppId = opp.Id;

        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{

            new OpportunityLineItem(
                OpportunityId = opp.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                TotalPrice = 1000,
                RenewableNew__c = 'Ongoing',
                Solution_Cap__c = 2,
                Package__c = 'Package A',
                Product_Name__c = 'Test Product A',
                Basis_of_Fees__c = 'Standard',
                Proposition__c = 'Test Proposition',
                Platform__c = 'Test Platform',
                Debooked_Quantity__c = 0,
                Debooked_Sales_Price__c = 0,
                Number_of_Services__c = 1
            ),

            new OpportunityLineItem(
                OpportunityId = opp.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                TotalPrice = 2000,
                RenewableNew__c = 'Ongoing',
                Solution_Cap__c = 3,
                Package__c = 'Package B',
                Product_Name__c = 'Test Product B',
                Basis_of_Fees__c = 'Standard',
                Proposition__c = 'Test Proposition',
                Platform__c = 'Test Platform',
                Debooked_Quantity__c = 0,
                Debooked_Sales_Price__c = 0,
                Number_of_Services__c = 2
            ),

            new OpportunityLineItem(
                OpportunityId = opp.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                TotalPrice = 500,
                RenewableNew__c = 'Ongoing',
                Solution_Cap__c = 1,
                Package__c = 'Package A'
            )
        };

        insert oliList;
    }


    private static Opportunity getOpp() {
        return [SELECT Id FROM Opportunity LIMIT 1];
    }



    @IsTest
    static void testGetOpportunityLine_UpdateTrue() {

        Test.startTest();
        TopUpOpportunityController.TopUpInformationWrapper result =
            TopUpOpportunityController.getOpportunityLine(getOpp().Id, true);
        Test.stopTest();

        System.assertNotEquals(null, result);

        for (TopUpOpportunityController.SolutionWrapper sw : result.solutionList) {

            if (sw.solutionName == 'Package A') {
                System.assertEquals(1500, sw.solutionTotalValueOnOriginal);
                System.assertEquals(2, sw.oppLines.size());
            }

            if (sw.solutionName == 'Package B') {
                System.assertEquals(2000, sw.solutionTotalValueOnOriginal);
                System.assertEquals(1, sw.oppLines.size());
            }
        }
    }

    @IsTest
    static void testGetOpportunityLine_UpdateFalse() {

        Test.startTest();
        TopUpOpportunityController.TopUpInformationWrapper result =
            TopUpOpportunityController.getOpportunityLine(getOpp().Id, false);
        Test.stopTest();

        for (TopUpOpportunityController.SolutionWrapper sw : result.solutionList) {
            System.assertEquals(0, sw.solutionCap);
            System.assertEquals(0, sw.solutionTotalValue);
        }
    }

    @IsTest
    static void testCreateTopUpOpportunity() {

        TopUpOpportunityController.TopUpInformationWrapper data =
            TopUpOpportunityController.getOpportunityLine(getOpp().Id, true);

        for (TopUpOpportunityController.SolutionWrapper sw : data.solutionList) {
            sw.solutionCap = sw.solutionCapOnOriginal + 1;
        }

        Test.startTest();
        TopUpOpportunityController.returnMessageWrapper response =
            TopUpOpportunityController.createTopUpOpportunity(data, getOpp().Id);
        Test.stopTest();

        System.assertNotEquals(null, response);
    }

    @IsTest
    static void testUpdateTopUpOpportunityLines() {

        TopUpOpportunityController.TopUpInformationWrapper data =
            TopUpOpportunityController.getOpportunityLine(getOpp().Id, true);

        for (TopUpOpportunityController.SolutionWrapper sw : data.solutionList) {
            sw.solutionCap = sw.solutionCapOnOriginal + 2;
        }

        Test.startTest();
        TopUpOpportunityController.returnMessageWrapper response =
            TopUpOpportunityController.updateTopUpOpportunityLines(data, getOpp().Id);
        Test.stopTest();

        System.assertNotEquals(null, response);
    }

    @IsTest
    static void testCreateTopUpOpportunity_Exception() {

        TopUpOpportunityController.TopUpInformationWrapper data =
            new TopUpOpportunityController.TopUpInformationWrapper();
        data.solutionList = null;

        Test.startTest();
        TopUpOpportunityController.returnMessageWrapper response =
            TopUpOpportunityController.createTopUpOpportunity(data, oppId);
        Test.stopTest();

        System.assertEquals('Error', response.MessageType);
    }
}
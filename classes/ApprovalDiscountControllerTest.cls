@IsTest
public class ApprovalDiscountControllerTest {

    static Id oppId;

    @TestSetup
    static void setupData(){

        insert new List<Trigger_Activation__c>{
            new Trigger_Activation__c(Name='Account_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='Task_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='User_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='Opportunity_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='Territory_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='OpportunityLineItem_Trigger',Active__c=true)
        };
            
            insert new AutomaticJobCreation__c(
    Name = 'Values',
    MS_Line_of_Business__c = 'TestMS'
);

            Account acc = new Account(
            Name='Test Account',
            BU__c='UK - UK1',
            CurrencyIsoCode='GBP',
            Industry='Agriculture',
            Billing_Address_Line_1__c='Line1',
            Billing_City__c='City',
            Same_As_The_Billing_Address__c=true,
            Billing_Country__c='INDIA',
            Billing_State__c='State',
            Billing_ZIP_Postal_Code__c='Zip',
            Global_Billing_Country__c='AFGHANISTAN'
            
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Test Opportunity',
           
            AccountId = acc.Id,
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            Amount = 770000
        );
        insert opp;

        oppId = opp.Id;

        Product2 prod = new Product2(
            Name='Test Product',
            Product_Family__c='Product'
        );
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

OpportunityLineItem oli = new OpportunityLineItem(
    OpportunityId = opp.Id,
    PricebookEntryId = pbe.Id,
    Quantity = 1,
    UnitPrice = 80,
    Product_Name__c = 'Test Product',
    Contract_Year__c = '1',
    List_Price__c = 100,
    Discount__c = 20,
    Discount_Value__c = 20,
    Product_Family__c = 'Product'
);
        insert oli;

        Future_Product__c futureProd = new Future_Product__c(
            Opportunity__c = opp.Id,
            Product__c = prod.Id,
            Contract_Year__c = '2',
            ListPrice__c = 200,
            Sales_Price__c = 150,
            Discount__c = 25,
            Discount_Value__c = 50
        );
        insert futureProd;
        

    }



    @IsTest
    static void testGetDiscountRows(){

       Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();

        List<ApprovalDiscountController.ApprovalRowDTO> rows =
            ApprovalDiscountController.getDiscountRows(opp.Id);

        Test.stopTest();

    }


    @IsTest
    static void testGetDiscountRowsNull(){

        Test.startTest();

        List<ApprovalDiscountController.ApprovalRowDTO> rows =
            ApprovalDiscountController.getDiscountRows(null);

        Test.stopTest();

        System.assertEquals(0, rows.size());
    }


    @IsTest
    static void testComparableSorting(){

        ApprovalDiscountController.ApprovalRowDTO row1 =
            new ApprovalDiscountController.ApprovalRowDTO();
        row1.createdDate = System.now();

        ApprovalDiscountController.ApprovalRowDTO row2 =
            new ApprovalDiscountController.ApprovalRowDTO();
        row2.createdDate = System.now().addDays(-1);

        List<ApprovalDiscountController.ApprovalRowDTO> rows =
            new List<ApprovalDiscountController.ApprovalRowDTO>{row2,row1};

        rows.sort();

        System.assertEquals(row1, rows[0]);
    }
}
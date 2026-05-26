@isTest(seeAllData = true)
public class Import_RateCard_Ctr_LIT_test {

    static Opportunity createOpportunity() {
        Datetime variable = System.now();
        String Testname = 'Test Account ' + variable;

        Account account = new Account(
            Name = Testname,
            Status__c = 'Approved',
            Industry = 'Agriculture',
            Billing_Address_Line_1__c = '123 Main',
            Billing_City__c = 'Test City',
            Billing_State__c = 'Test',
            Billing_Country__c = 'Test Country',
            Billing_ZIP_Postal_Code__c = '1100110',
            BU__c = 'Australia - AU1'
        );
        insert account;

        Contact contact = new Contact(
            LastName = 'Test Contact',
            AccountId = account.Id,
            Same_As_The_Account_Billing_Address__c = true,
            Mailing_Address_Line_1__c = '123 Contact St',
            Mailing_City__c = 'Test City',
            Mailing_ZIP_Postal_Code__c = '110094',
            Mailing_Country__c = 'India'
        );
        insert contact;

        Pricebook2 p = [SELECT Id FROM Pricebook2 WHERE Name = 'Configurator Price Book' LIMIT 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Configurator Opportunity' LIMIT 1];

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            Offering__c = 'Enterprise Leadership',
            Talent_Level__c = 'Leader',
            Talent_Segment__c = 'Volume',
            Client_Business_Function__c = 'HR',
            OwnerId = UserInfo.getUserId(),
            Billing_Contact__c = contact.Id,
            Closedate = Date.today(),
            Primary_Contact__c = contact.Id,
            CurrencyIsoCode = 'USD',
            Unconfirmed_Sun_Order_Number__c = '1234',
            NVM_Credit_Card_ID__c = '1234',
            Amount = 1000,
            Variation_Opportunity__c = 'NO',
            Annual_Contract_Value__c = 1000.00,
            StageName = 'New',
            GCSC__c = 'Phone',
            OpportunityAmountMappedWithLead__c = 323.34,
            OpportunityTypeMappedWithLead__c = 'New Business',
            RecordTypeId = rt.Id,
            Skip_Validation__c = true,
            Pricebook2Id = p.Id,
            TM_Phase__c = 'Mixed',
            Package_Level__c = 'Basic',
            Proposition__c = 'Graduate Hiring',
            Forecast_Category__c = 'Commit',
            Business_Type__c = 'Expansion'
        );
        insert opp;

        return opp;
    }

    static testmethod void testReadFileOppLineItems_validData() {
        Opportunity opp = createOpportunity();

        Test.startTest();
        String file = 'PRICEBOOK ENTRY ID,Hiring Need,Talent Level,Package Level,List Price,Total Discount%(The values will be just numbers),Sales Price,Level,Basis of Fees,Usage Cap or Estimation,Volume,Start Date (dd/mm/yyyy),End Date (dd/mm/yyyy),Year 1 : List Price,Year 2 : List Price,Year 3 : List Price,Year 1 : Discount%,Year 2 : Discount%,Year 3 : Discount%,Year 1 : Sales Price,Year 2 : Sales Price,Year 3 : Sales Price,Platform,Usage Allowance,Propositions\n' +
            '01uD000000wTc8W,Talent Acquisition,Vocational,Premium,50486.79,700,46952.72,2,Candidate,225000,13,30/07/2018,30/07/2019,160917,0,0,7,0,0,149652.12,75719.12,77990.35,Brainbench,Uncapped,Graduate Hiring';
        String result = Import_RateCard_Ctr_LIT.ReadFileOppLineItems(opp.Id, file);
        System.debug('Result valid CSV: ' + result);
        Test.stopTest();
    }

    static testmethod void testReadFileOppLineItems_invalidDate() {
        Opportunity opp = createOpportunity();

        Test.startTest();
        String file = 'PRICEBOOK ENTRY ID,Hiring Need,Talent Level,Package Level,List Price,Total Discount%(The values will be just numbers),Sales Price,Level,Basis of Fees,Usage Cap or Estimation,Volume,Start Date (dd/mm/yyyy),End Date (dd/mm/yyyy),Year 1 : List Price,Year 2 : List Price,Year 3 : List Price,Year 1 : Discount%,Year 2 : Discount%,Year 3 : Discount%,Year 1 : Sales Price,Year 2 : Sales Price,Year 3 : Sales Price,Platform,Usage Allowance,Propositions\n' +
            '01uD000000wTc8W,Pre-Hire,Graduate,Premium,50486.79,700,46952.72,2,Candidate,225000,13,30-07-2018,30/07/2019,160917,0,0,7,0,0,149652.12,75719.12,77990.35,Brainbench,Uncapped,';
        String result = Import_RateCard_Ctr_LIT.ReadFileOppLineItems(opp.Id, file);
        System.debug('Result invalid date: ' + result);
        Test.stopTest();
    }

    static testmethod void testReadFileOppLineItems_nullFile() {
        Opportunity opp = createOpportunity();
        Test.startTest();
        String result = Import_RateCard_Ctr_LIT.ReadFileOppLineItems(opp.Id, null);
        System.assert(result.contains('Please Choose Pricebook Items CSV file'), 'Null file should be handled');
        Test.stopTest();
    }

    static testmethod void testReadFileOppLineItems_malformedCSV() {
        Opportunity opp = createOpportunity();
        Test.startTest();
        String file = 'BAD,CSV,DATA\nsome,junk,data';
        String result = Import_RateCard_Ctr_LIT.ReadFileOppLineItems(opp.Id, file);
        System.assert(result.contains('An error has occured'), 'Malformed CSV should be handled');
        Test.stopTest();
    }

    static testmethod void testReadFileDiscountSum_validAndInvalid() {
        Opportunity opp = createOpportunity();

        Test.startTest();
        String file = 'OpportunityId,Discount Type,Level,Name,Discount Percentage,Discount Amount,Discount Applied on (DateFormat:  dd/mm/yyyy),Discount Reason\n' +
                      'ABCD,Deal Length,1,Test2,2,11263,15/07/2019,End of month\n' +
                      opp.Id + ',Deal Length,1,Test2,2,11263,30/07/2018,End of quarter';
        String result = Import_RateCard_Ctr_LIT.ReadFileDiscountSum(opp.Id, file);
        System.debug('DiscountSum result: ' + result);

        List<OpportunityLineItem> deleted = Import_RateCard_Ctr_LIT.DeleteRecordsOppLineItems(opp.Id);
        System.assertNotEquals(null, deleted, 'Should return deleted items');
        Test.stopTest();
    }

    static testmethod void testReadFileDiscountSum_nullFile() {
        Opportunity opp = createOpportunity();
        Test.startTest();
        String result = Import_RateCard_Ctr_LIT.ReadFileDiscountSum(opp.Id, null);
        System.assert(result.contains('Please Choose your Discount Summary CSV'), 'Should detect null input');
        Test.stopTest();
    }

    static testmethod void testReadFileDiscountSum_badNumber() {
        Opportunity opp = createOpportunity();
        String file = 'OpportunityId,Discount Type,Level,Name,Discount Percentage,Discount Amount,Discount Applied on (DateFormat:  dd/mm/yyyy),Discount Reason\n' +
                      opp.Id + ',Deal Length,1,BadDiscount,abc,11263,30/07/2018,Reason';
        Test.startTest();
        String result = Import_RateCard_Ctr_LIT.ReadFileDiscountSum(opp.Id, file);
        System.assert(result.contains('An error has occured while reading the Discount Summary CSV'), 'Bad number format should be handled');
        Test.stopTest();
    }
}
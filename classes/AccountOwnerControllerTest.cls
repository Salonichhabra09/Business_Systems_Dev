@isTest()
class AccountOwnerControllerTest {

    @isTest(seeAlldata=true)
    private static void testAccountOwner(){
        
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
        
        Account acc1= new Account();
        acc1.Name='Gcsc235';
        acc1.BU__c='UK - UK1';
        acc1.CurrencyIsoCode='GBP'; 
        acc1.Industry='Agriculture';
        acc1.Billing_Address_Line_1__c='test23';
        acc1.Billing_City__c='test23';
        acc1.Same_As_The_Billing_Address__c=true;
        acc1.Billing_Country__c='test23';
        acc1.Billing_State__c='test23';
        acc1.Billing_ZIP_Postal_Code__c='test23'; 
        acc1.GCSC_Owned_Account__c = true;
        acc1.GCSC_Account_Owner__c = 'test@test.com';
        insert acc1;
        
        Test.startTest();
        AccountOwnerController.getAccountOwnerDetails(acc.Id);
        AccountOwnerController.getAccountOwnerDetails(acc1.Id);
        Test.stopTest();
        
    }
}
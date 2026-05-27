@isTest(SeeAllData=true)
class MarkInactiveAddressAndTaxControllerTest {

    @isTest
    public static void testMarkInactive(){
        
        Account acc= new Account();
        acc.Name='Test234';
        acc.BU__c='India - IN1';
        acc.CurrencyIsoCode='INR'; 
        acc.Industry='Agriculture';
        acc.Billing_Address_Line_1__c='test23';
        acc.Billing_City__c='test23';
        acc.Same_As_The_Billing_Address__c=true;
        acc.Billing_Country__c='test23';
        acc.Billing_State__c='test23';
        acc.Billing_ZIP_Postal_Code__c='test23'; 
        insert acc;
        
        Id taxRecordTypeId = Schema.SObjectType.India_GST__c.getRecordTypeInfosByName().get('Tax').getRecordTypeId();
        
        India_GST__c addressAndTaxRecord = new India_GST__c(name='07TESTOTESTB123',Account__c=acc.Id);
        addressAndTaxRecord.Address_Line_1__c='Ground Floor, Corporate One';
        addressAndTaxRecord.City__c ='New Delhi'; 
        addressAndTaxRecord.Global_Country__c='INDIA';
        addressAndTaxRecord.State_County__c ='Delhi';
        addressAndTaxRecord.State_Code__c ='07';
        addressAndTaxRecord.ZIP_Postal_Code__c='110076';
        addressAndTaxRecord.Taxpayer_Type__c='EXPWOP';
        addressAndTaxRecord.Type__c = 'GST';
        addressAndTaxRecord.RecordTypeId = taxRecordTypeId;
        
        insert addressAndTaxRecord;
        
        Test.startTest();
        
        MarkInactiveAddressAndTaxController.getAddressAndTaxType(addressAndTaxRecord.Id);
        MarkInactiveAddressAndTaxController.markInactive(addressAndTaxRecord.Id);

        Test.stopTest();

    }
}
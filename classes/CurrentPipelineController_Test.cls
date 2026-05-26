@isTest
public class CurrentPipelineController_Test {
	
    @IsTest(seeAlldata=true)
    static void testStrategies() {
        // Test data setup
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
        acc.Buying_Centre_Id__c = '90';
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',Account_Plan_Type__c='Global');
        insert ap;
        
        Account_Plan__c ap1 = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',Account_Plan_Type__c='Regional',Buying_Centre_Id__c='90');
        insert ap1;

        Contact con = CreateTestData.getContact(acc.Id);
        
        Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id);
        opp.Business_Type__c = 'Renewal';
        
        update opp;
        
        Test.startTest();
   			CurrentPipelineController.getOpenOpportunitiesDetails(ap.Id,'Renewal');
       		CurrentPipelineController.getOpenOpportunitiesDetails(ap1.Id,'New Business/Cross Sell');
        Test.stopTest();
    }
}
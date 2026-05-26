@isTest
public class CustomLookupController_Test {
    
    @isTest(seeAlldata=true)
    static void testCustomLookup() {
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
        
        Contact con = CreateTestData.getContact(acc.Id);
        Contact con1 = CreateTestData.getContact(acc.Id);
        
        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id,Account_Plan_Type__c='Global');
        insert accPlan;
        
        Account_Plan__c accPlan1 = new Account_Plan__c(Account_Name__c=acc.Id,Account_Plan_Type__c='Regional',Buying_Centre_Id__c='90');
        insert accPlan1;
        
        Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id);
        Opportunity opp1 = CreateTestData.getOpportunity(acc.Id,con.Id);
        
        Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                               Strategy_Name__c = 'Test',
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration', 
                                                               Strategy_Status__c = 'In Progress',
                                                               Key_Contact_Sponsor__c=con.Id);
        insert stgoal;
        
        
        Test.startTest();
        	CustomLookupController.getRequiredLookupRecords('Test','Contact','test',accPlan.Id);
        CustomLookupController.getRequiredLookupRecords('Test','Contact','test',accPlan1.Id);
        	CustomLookupController.getRequiredLookupRecords('Test','Account','Industry=\'Agriculture\'',accPlan.Id);
        	CustomLookupController.getRequiredLookupRecords('','Account','',accPlan1.Id);
        CustomLookupController.getRequiredLookupRecords('','ProjectObject__c','','');
        Test.stopTest();
    }
}
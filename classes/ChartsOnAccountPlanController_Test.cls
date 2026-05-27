@isTest
public class ChartsOnAccountPlanController_Test {

    @IsTest(seeAlldata=true)
    static void testGetContactOpportunities() {
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
        acc.Status__c = 'Approved';
        acc.Buying_Centre_Id__c ='90';
        insert acc;

        Contact con = new Contact(AccountId=acc.Id, FirstName='Test', LastName='Contact', Contact_Status__c='Active');
        insert con;

        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name='Test Opportunity', StageName='New', CloseDate=System.today()-700, AccountId=acc.Id,amount=10000,TM_Phase__c='Talent Acquisition',Forecast_Category__c='Pipeline',Business_Type__c = 'Cross-sell: subscription');
        Opportunity opp1 = new Opportunity(Name='Test Opportunity', StageName='New', CloseDate=System.today()-700, AccountId=acc.Id,amount=10000,TM_Phase__c='Talent Management',Forecast_Category__c='Pipeline',Business_Type__c = 'Cross-sell: subscription');

        oppList.add(opp);
        oppList.add(opp1);
        insert oppList;
        
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        opp.StageName = 'Closed/Won';
        opp1.StageName = 'Closed/Won';
        oppListToUpdate.add(opp);
        oppListToUpdate.add(opp1);
        update oppListToUpdate;
        
        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id,Account_Plan_Type__c='Global');
        insert accPlan;
        
        Account_Plan__c accPlan1 = new Account_Plan__c(Account_Name__c=acc.Id,Account_Plan_Type__c='Regional',Buying_Centre_Id__c ='90');
        insert accPlan1;
        
        // Test method call
        Test.startTest();
        ChartsOnAccountPlanController.getOpportunitiesYearWise(accPlan.Id);
        ChartsOnAccountPlanController.getOpportunitiesYearWiseWithCI(accPlan.Id);
        ChartsOnAccountPlanController.getOpportunitiesYearWise(accPlan1.Id);
        ChartsOnAccountPlanController.getOpportunitiesYearWiseWithCI(accPlan1.Id);
        Test.stopTest();
    }
}
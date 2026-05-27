@isTest
public class WhiteSpaceOpportunityController_Test {
	
    @IsTest(seeAlldata=true)
    static void testWhitespace() {
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
        insert acc;

        Contact con = CreateTestData.getContact(acc.Id);

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id , Account_Plan_Type__c = 'Current');
        insert accPlan;
          
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
        
        Strategy_and_Goal__c strat = [SELECT Id, Name FROM Strategy_and_Goal__c WHERE Id =: stgoal.Id];
        Whitespace_Potential_Opportunity__c wsOpp = new Whitespace_Potential_Opportunity__c();
        wsOpp.Account_Plan__c = accPlan.Id;
        wsOpp.Strategy_and_Goals__c = strat.Id;
        wsOpp.Who_do_you_need_to_speak_to__c = con.Id;
        wsOpp.Solution__c = 'Product';
        wsOpp.Potential_Value__c = 10000;
        wsOpp.Any_help_needed__c ='No';
        wsOpp.Next_Step_s__c ='Test';
        
        Insert wsOpp;
        WhiteSpaceOpportunityController.WhiteSpaceOpportunityWrapper wrapper = new WhiteSpaceOpportunityController.WhiteSpaceOpportunityWrapper();
        wrapper.helpNeeded = 'No';
        wrapper.contactId = con.Id;
        wrapper.nextStep = 'Test';
        wrapper.strategy = strat.Id;
        wrapper.potentialValue = 10000;
        wrapper.solution = 'Product';
        wrapper.whiteSpaceOppId = wsOpp.Id;
        // Test method call
        Test.startTest();
   			WhiteSpaceOpportunityController.getWhiteSpaceOpportunitiesDetails(accPlan.Id);
        	WhiteSpaceOpportunityController.getWhiteSpaceOpportunitiesDetails(strat.Id);
        	WhiteSpaceOpportunityController.convertToOpportunity(accPlan.Id,wrapper);
           	WhiteSpaceOpportunityController.getConvertedWhiteSpaceOpportunities(accPlan.Id);
        Test.stopTest();
    }
}
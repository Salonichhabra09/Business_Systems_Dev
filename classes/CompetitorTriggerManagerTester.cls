@isTest(SeeAllData=true)
public class CompetitorTriggerManagerTester {
    
    Static  TestMethod void TestCompetitorTriggerManager(){
        Account account = CreateTestData.getaccount();
        Contact contact = CreateTestData.getcontact(account.Id);
        Opportunity opportunity = CreateTestData.getOpportunity(account.Id,contact.Id);
        Account competitorAccount = new Account(name='Test Account',Status__c='UnApproved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Competitor_Account').getRecordTypeId());
        insert competitorAccount;
        Competitor__c competitor = new Competitor__c(
        Account__c=account.Id,
        Competitor__c=competitorAccount.Id,
        Opportunity__c = opportunity.Id,
        Incumbent_Renewal_Date__c = Date.Today(),
        Auto_create_Displacement_Opportunity__c='Yes');
        
        insert competitor;
        competitor.Auto_create_Displacement_Opportunity__c = 'No';
        Update competitor;
        competitor.Auto_create_Displacement_Opportunity__c = 'Yes';
        Update competitor;
    }

}
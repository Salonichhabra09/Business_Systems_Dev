@isTest
public class CompetitorOnAccountPlanController_Test {
	
    @isTest(seeAlldata=true)
    static void testCompetitor() {
        
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
        Contact contact = CreateTestData.getcontact(acc.Id);
        Opportunity opportunity = CreateTestData.getOpportunity(acc.Id,contact.Id);
        Account competitorAccount = new Account(name='Test Account',Industry='Agriculture',Status__c='UnApproved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Competitor_Account').getRecordTypeId());
        insert competitorAccount;
        Competitor__c competitor = new Competitor__c(
        Account__c=acc.Id,
        Competitor__c=competitorAccount.Id,
        Opportunity__c = opportunity.Id,
        Incumbent_Renewal_Date__c = Date.Today(),
        Auto_create_Displacement_Opportunity__c='Yes');
        
        insert competitor;
        
        Test.startTest();
   			CompetitorOnAccountPlanController.getCompetitorDetails(acc.Id , 'Current');
        Test.stopTest();
    }
    
    //Added by  Prachi SSE-21664
     @isTest(seeAlldata=true)
    static void testCompetitorRegional() {
        
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
        acc.Buying_Centre_Id__c = 'Test Id 1';
        insert acc;
        Contact contact = CreateTestData.getcontact(acc.Id);
        Opportunity opportunity = CreateTestData.getOpportunity(acc.Id,contact.Id);
        Account competitorAccount = new Account(name='Test Account',Industry='Agriculture',Status__c='UnApproved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Competitor_Account').getRecordTypeId());
        insert competitorAccount;
        Competitor__c competitor = new Competitor__c(
        Account__c=acc.Id,
        Competitor__c=competitorAccount.Id,
        Opportunity__c = opportunity.Id,
        Incumbent_Renewal_Date__c = Date.Today(),
        Auto_create_Displacement_Opportunity__c='Yes');
        
        insert competitor;
        
        Test.startTest();
   			CompetitorOnAccountPlanController.getCompetitorDetails(acc.Id , 'Regional');
        Test.stopTest();
    }
    
    //Added by  Prachi SSE-21664
     @isTest(seeAlldata=true)
    static void testCompetitorGlobal() {
        
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
        acc.Buying_Centre_Id__c = 'Test Id 1';
        insert acc;
        Account acc1= new Account();
        acc1.Name='Data 2';
        acc1.BU__c='UK - UK1';
        acc1.CurrencyIsoCode='GBP'; 
        acc1.Industry='Agriculture';
        acc1.Billing_Address_Line_1__c='test23';
        acc1.Billing_City__c='test23';
        acc1.Same_As_The_Billing_Address__c=true;
        acc1.Billing_Country__c='test23';
        acc1.Billing_State__c='test23';
        acc1.Billing_ZIP_Postal_Code__c='test23';
        acc1.Buying_Centre_Id__c = 'Test Id 1';
        acc1.ParentId = acc.id;
        insert acc1;
        
        Contact contact = CreateTestData.getcontact(acc.Id);
        Opportunity opportunity = CreateTestData.getOpportunity(acc.Id,contact.Id);
        Account competitorAccount = new Account(name='Test Account',Industry='Agriculture',Status__c='UnApproved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1',recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Competitor_Account').getRecordTypeId());
        insert competitorAccount;
        Competitor__c competitor = new Competitor__c(
        Account__c=acc.Id,
        Competitor__c=competitorAccount.Id,
        Opportunity__c = opportunity.Id,
        Incumbent_Renewal_Date__c = Date.Today(),
        Auto_create_Displacement_Opportunity__c='Yes');
        
        insert competitor;
        
        Test.startTest();
   			CompetitorOnAccountPlanController.getCompetitorDetails(acc.Id , 'Global');
        Test.stopTest();
    }
}
@isTest(SeeAllData=true)
public class OpportunityAutoCloserDaysControllerTest {
    @isTest
    public static void test_OpportunityAutoCloserDaysController(){
        Datetime variable=System.now();
        String TestAccountname='Test Account'+variable;
        Account account=new Account(name=TestAccountname,Status__c='Approved',Billing_Address_Line_1__c='test2',Billing_City__c='Test City',Billing_Country__c='ARGENTINA',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1', Industry='Legal');
        insert account;    
        Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
        insert contact;
        
        Pricebook2 PR1 = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(account.id, contact.id, UserInfo.getUserId());
        opportunityRecord.Pricebook2Id = PR1.Id;
        INSERT opportunityRecord;  
        OpportunityAutoCloserDaysController.calculateDaysForAutoClose(opportunityRecord.Id);
    }

    @isTest
    static void test_getUsersToChangeAutoCloseDate() {
        UsersToChangeAutoCloseDate__c getUsersToChangeAutoCloseDateSetting = new UsersToChangeAutoCloseDate__c();
        getUsersToChangeAutoCloseDateSetting.Name = 'Test Setting 1';
        getUsersToChangeAutoCloseDateSetting.User_Email__c = UserInfo.getUserEmail();
        insert getUsersToChangeAutoCloseDateSetting;

        OpportunityAutoCloserDaysController.getUsersToChangeAutoCloseDate();
        
    }
    
}
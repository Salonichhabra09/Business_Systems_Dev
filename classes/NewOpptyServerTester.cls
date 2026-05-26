@isTest(seeAllData = true)
public class NewOpptyServerTester{
    
     public static testMethod void Testservermethods(){
     
            NewOpptyServer.getRecordList();
            Account account=CreateTestData.getAccount();
            Contact contact = new Contact(AccountId=account.Id,LastName='test12345',email='test12345@test.com',phone='2345345345',Same_As_The_Account_Billing_Address__c=true);
            
            insert contact;
            
            Opportunity opportunity= new Opportunity(AccountId=Account.Id,Billing_Contact__c=Contact.Id,Business_Type__c='In Arrears',Forecast_Category__c='Commit',Primary_Contact__c=Contact.Id,name='Test Opportunity',NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName='New',closeDate=System.today());
            insert opportunity;
            
            NewOpptyServer.getAccList(account.Id);
            NewOpptyServer.getConList(contact.id);
            NewOpptyServer.getOppList(opportunity.id);
     
     }
}
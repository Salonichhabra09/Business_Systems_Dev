@isTest(SeeAllData=true)
public class RestrictAttachmentdeleteOrder_TestClass
{public static Account account;
public static List<Contact> contacts;
      public static testMethod void testTriggers()
      {
        Contract contract = new Contract();
        
        Account a = new Account();
            //Schema.sObjectType t = a.getSObjectType();
            //List<account> a1 = Test.loadData(t, 'AccountTestData');
            //Get first test account
            account = TestDataUtility.getAccount();
            account.name = 'RestrictAttachmentdeleteOrder_TestClass';
            insert account;
             Contact contact = new Contact(AccountId=account.Id,LastName='test12345',email='test12345@test.com',phone='2345345345',Same_As_The_Account_Billing_Address__c=true);
        contacts = new List<Contact>();
        contacts.add(contact);
        insert contacts;
        contract.AccountId = account.Id;  
        contract.Legal_Order_Name__c = 'test'; 
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;   
        contract.Activated_Date__c=datetime.now();
        contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract.Submission_Offset__c = 10;
        contract.Agreement__c = 'Order';
        contract.Subscription_Start_Date__c = Date.Today();
        insert contract;
        
        Attachment attach = new Attachment();
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob; 
        attach.parentId = contract.id;
        insert attach;
        delete attach;
        
        
}

}
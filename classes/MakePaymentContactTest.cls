@isTest(seeAllData = true)
public class MakePaymentContactTest {
	@isTest static void TestVf_CreateCase(){
    
        Account account=new Account(Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City'
                                    ,Billing_Country__c='USA',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        account.name='Test Account1'+System.now();
        insert account;
        
        Contact con=new Contact(FirstName='abc',lastname='Test Contact1', Accountid=account.id);
        con.Same_As_The_Account_Billing_Address__c=true;
        con.Mailing_Address_Line_1__c ='test';
        con.Mailing_City__c='test';
        con.Mailing_ZIP_Postal_Code__c ='110094';
        con.Mailing_Country__c='India';
        con.Mailing_State_County__c='AB';
        con.email = 'abc@gmail.com';
        insert con;
        
        Test.startTest();
        
        ApexPages.StandardController scn = new ApexPages.standardController(con);
        PageReference pageRef2 = Page.MakePaymentContact; // Add your VF page Name here
        pageRef2.getParameters().put('id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef2);
        MakePaymentContact myPageCon2 = new MakePaymentContact(scn);
        myPageCon2.createCase();
        
        Test.stopTest(); 
        
    }
}
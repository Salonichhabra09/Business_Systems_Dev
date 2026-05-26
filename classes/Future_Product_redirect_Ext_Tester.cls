@isTest(SeeAllData=true)
public class Future_Product_redirect_Ext_Tester{

    static testmethod void Method1(){
         Account account=new Account(name='Test Account0987',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
         insert account;
         
        Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';        
        insert contact;
        
        Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Standard Opportunity' limit 1];
        //Id priceBookID = Test.getStandardPricebookId();
        Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
        opportunity.ownerid=UserInfo.getUserId();
        opportunity.Billing_Contact__c=contact.id;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=contact.id;
        opportunity.CurrencyIsoCode='AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity.NVM_Credit_Card_ID__c='1234';
        opportunity.Amount=1000;
        opportunity.Variation_Opportunity__c='NO';
        //opportunity.Order_Number__c=contract.id;
        opportunity.Original_Opportunity__c=null;
        opportunity.Annual_Contract_Value__c=1000.00;
        opportunity.StageName='Prepare';   
        opportunity.GCSC__c='Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity.RecordTypeID=RT.id;
        opportunity.Skip_Validation__c=True;
        opportunity.Pricebook2Id=p.id;
        opportunity.Business_Type__c='New customer: subscription';
        opportunity.Forecast_Category__c='Forecast';
        
        insert opportunity;
        
        Product2 Product=New Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Insert Product;       
         
        Future_Product__c fup = new Future_Product__c();
        fup.Opportunity__c= opportunity.id;
        fup.Product__c = Product.id;
        insert fup;  
      
        Future_Product_redirect_Ext controller = new Future_Product_redirect_Ext(new ApexPages.StandardController(fup));
        controller.saveAndRedirect();
    }

}
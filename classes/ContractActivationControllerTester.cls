@isTest(SeeAllData=true)
public class ContractActivationControllerTester{

    public static testmethod void ContractActivationTest1(){
       Account acc=new Account(name='Testname',CurrencyIsoCode='GBP',Industry='Consulting',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
       insert acc;
       //Account acc = [Select id from account limit 1];
       Contract c = new Contract();
       c.name = 'test';
       c.status = 'Draft';
       c.Subscription_Start_Date__c = Date.Today();
       c.AccountId = acc.id;
       c.Payment_terms__c = '30 days';
       insert c;
       //c.status = 'Accepted';
       //update c;
       try{
       ContractActivationController.updateContract (c.id);
       }
       catch(Exception e){
       }
           
    }

}
@istest(SeeAllData=true)
/*public class ReductionOrderLEXClassTester {
    static TestMethod void ReductionOrderLEXClassTesterTestMethod(){
     List<Order> ord = new List<Order>();
        for ( Integer count = 0; count < 50; count++){
            ord.add(new Order);
        }
        insert ord;
        Test.startTest();
        
	 ReductionOrderLEXClass.relatedOrderRecord(ord.Id);
        Test.stopTest();
        Order ordr = [Select id from Order LIMIT 1];
        System.assertEquals(Integer.valueOf(ordr.Id),000000000000000);
     
      
    }

}*/


public class ReductionOrderLEXClassTester{
    
     public static testMethod void ReductionOrderLEXClassTesterTestMethod(){
     
           // ReductionOrderLEXClass.relatedOrderRecord();
            Account account=CreateTestData.getAccount();
            
            Contact contact = new Contact(AccountId=account.Id,LastName='test12345',email='test12345@test.com',phone='2345345345',Same_As_The_Account_Billing_Address__c=true);
            insert contact;
              Contract contract = new Contract();
        contract.AccountId = account.Id;   
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;  
        contract.Legal_Order_Name__c='test';
        contract.Subscription_Start_Date__c = system.today();
        insert contract;
            Opportunity opportunity= new Opportunity(AccountId=Account.Id,Billing_Contact__c=Contact.Id,Business_Type__c='New customer: subscription',Forecast_Category__c='Forecast',Primary_Contact__c=Contact.Id,name='Test Opportunity',NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName='New',Variation_Opportunity__c ='No',closeDate=System.today());
            insert opportunity;
         
            Order ord = new Order();
            Id orderrt = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Standard Order').getRecordTypeId();

        ord.Accountid = account.id;
        ord.ContractId = contract.id;
        ord.name = 'test';
        //ord.RecordTypeId = '0127E0000032wq7';
        ord.RecordTypeId = orderrt;
        ord.Status = 'Draft';
        ord.EffectiveDate = system.today();
        ord.CurrencyIsoCode = contract.CurrencyIsoCode;
        ord.Pricebook2Id = '01s2000000000vQAAQ';
        ord.Reduction_Order__c = false;
        ord.Order_Year__c = 1;
         ord.OpportunityId = opportunity.id;
        //ord.Variation_Opportunity__c = 'Yes';
        
        //ord.quantity = 1;
        //ord.UnitPrice = 1000;
        insert ord;
       
          
          
         //ReductionOrderLEXClass.relatedOrderRecord(String.ordId);
     // List <Order> ordr = [Select id from Order where Id =:opportunity.Id];
         ReductionOrderLEXClass.relatedOrderRecord(opportunity.Id);
     }
}
@isTest(SeeAllData=true)
class MSAContractENBA_Test {
    
    @isTest static void testMSA(){
        
        List<Account> accountList = new List<Account>();
        Account acc= new Account();
        acc.Name='Test234';
        acc.BU__c='India - IN1';
        acc.CurrencyIsoCode='GBP'; 
        acc.Industry='Consulting';
        acc.Billing_Address_Line_1__c='test23';
        acc.Billing_City__c='test23';
        acc.Same_As_The_Billing_Address__c=true;
        acc.Billing_Country__c='INDIA';
        acc.Billing_State__c='test23';
        acc.Billing_ZIP_Postal_Code__c='test23';
        acc.SFDC2SUN_SyncStatus__c ='In Sync';   
        acc.Account_Approach__c='Protect';  
        //done by aashi acc.Territory__c ='AMS-GCSC';
        acc.Industry = 'Agriculture';
        accountList.add(acc);
        
        Account acc1= new Account();
        acc1.Name='Test23';
        acc1.BU__c='India - IN1';
        acc1.CurrencyIsoCode='GBP'; 
        acc1.Industry='Consulting';
        acc1.Billing_Address_Line_1__c='test23';
        acc1.Billing_City__c='test23';
        acc1.Same_As_The_Billing_Address__c=true;
        acc1.Billing_Country__c='INDIA';
        acc1.Billing_State__c='test23';
        acc1.Billing_ZIP_Postal_Code__c='test23';
        acc1.SFDC2SUN_SyncStatus__c ='In Sync';   
        acc1.Account_Approach__c='Protect';  
        //done by aashi acc1.Territory__c ='AMS-GCSC';
        acc1.Industry = 'Agriculture';
        accountList.add(acc1);
        
        insert accountList;
        
        Id recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MSA Contract').getRecordTypeId();
        Contract contract = new Contract();
        contract.AccountId = accountList[0].Id; 
        contract.RecordTypeId = recordTypeId;
        contract.Status = 'Active';
        contract.StartDate = Date.Today();
        contract.Contract_End_Date__c = Date.Today() + 1;
        insert contract;
        
        Test.startTest();
        MSAContractENBA.getMSAContract(new List<String>{accountList[0].Id});
        MSAContractENBA.getMSAContract(new List<String>{accountList[1].Id});
        Test.stopTest();
        
    }
}
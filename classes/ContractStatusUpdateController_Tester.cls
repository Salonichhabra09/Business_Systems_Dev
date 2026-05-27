@isTest(seeAllData = true)
public class ContractStatusUpdateController_Tester {
    @isTest static void contractStatusUpdateTest(){
        Test.startTest();
        Datetime variable=System.now();
        String TestAccountname='Test MY Account'+variable; 
        Account account=new Account(name=TestAccountname,Status__c='Approved',CurrencyIsoCode='INR',
                                    //done by aashi Territory__c='Alliances',
                                    Account_Approach__c='Grow',Billing_Address_Line_1__c='test',
                                    Billing_City__c='Test City',Billing_Country__c='CHINA',
                                    Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
        insert account;
        
         
        
            Contract contract = new Contract();
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

        	String Result = ContractStatusUpdateController.contractStatusUpdate(contract.Id);
            System.assertEquals('UPDATED', Result);
        
            Contract contract2 = new Contract();
            contract2.AccountId = account.Id;  
            contract2.Legal_Order_Name__c = 'test'; 
            contract2.CurrencyIsoCode = account.CurrencyIsoCode;
            contract2.S2P_Reference_Required__c = 'New';
            contract2.Status = 'Draft';
            contract2.CustomerSignedDate = Date.Today();
            contract2.StartDate = Date.Today();
            contract2.ContractTerm = 6;   
            contract2.Activated_Date__c=datetime.now();
            contract2.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
            contract2.Submission_Offset__c = 10;
            contract2.Agreement__c = 'Order';
            contract2.Subscription_Start_Date__c = Date.Today();
    
            insert contract2;
            
        	String Result2 = ContractStatusUpdateController.contractStatusUpdate(contract.Id);
            System.assertEquals('NOT UPDATED', Result2);
        
        Test.stopTest();
    }
}
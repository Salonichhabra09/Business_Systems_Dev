@isTest(seeAlldata=true)
public class getAccountIntelligenceDataTester {
    @isTest 
    static void getSystemDetailsTest(){

        test.startTest();
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',Account_Plan_Type__c='Global');
        insert ap;
        
        Id recordTypeId = Schema.SObjectType.System__c.getRecordTypeInfosByName().get('Generic System').getRecordTypeId();
        List<System__c> sysList = new List<System__c>();
        for(integer i=0;i<=5;i++){
        System__c sys = new System__c(System_Name__c = 'Test Data'+i ,
                                      Account__c = acc.id,System_URL__c='https://talentcentral.com.shl',RecordTypeId=recordTypeId);
           sysList.add(sys); 
        }
        insert sysList;
        
        List<Account_Intelligence__c> aiDataList = new List<Account_Intelligence__c>();
        for(integer i=0;i<=5;i++){
            Account_Intelligence__c ai = new Account_Intelligence__c(AccountName__c = acc.id,
                                                                     Account_Intelligence_Type__c ='IT Provider/s',
                                                                     Salesforce_System_ID__c=sysList[i].id,
                                                                     AccountPlan__c = ap.id);
            
           aiDataList.add(ai); 
        }
        insert aiDataList;
        getAccountIntelligenceData.getSystem(sysList[0].Id);
        getAccountIntelligenceData.AccountIntelligenceWrapper aiw = new  getAccountIntelligenceData.AccountIntelligenceWrapper();
        aiw = getAccountIntelligenceData.getSystemDetails(ap.id);     
        test.stopTest();
        
    }

 //Added as part of SSE-21415   
    @isTest
    static void getSystemDetailsOppTest(){
        List<System__c> sysList = new List<System__c>();
        List<Account_Intelligence__c> aiDataList = new List<Account_Intelligence__c>();
         test.startTest();
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft');
        insert ap;
        
        Id recordTypeId = Schema.SObjectType.System__c.getRecordTypeInfosByName().get('Generic System').getRecordTypeId();
        
        
        System__c sys = new System__c(System_Name__c = 'Test Data',
                                      Account__c = acc.id,
                                      System_URL__c='https://talentcentral.com.shl',
                                      RecordTypeId=recordTypeId);
      
        insert sys;
        
        for(integer i=0;i<=25;i++){
            Account_Intelligence__c ai = new Account_Intelligence__c(AccountName__c = acc.id,
                                                                     Account_Intelligence_Type__c ='IT Provider/s',
                                                                     Salesforce_System_ID__c=sys.id,
                                                                     AccountPlan__c = ap.id);
            
         aiDataList.add(ai); 
        }
        insert aiDataList;
        Contact con = CreateTestData.getContact(acc.Id);
        Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id);
        
        getAccountIntelligenceData.AccountIntelligenceOppWrapper aiw = new  getAccountIntelligenceData.AccountIntelligenceOppWrapper();
        aiw = getAccountIntelligenceData.getSystemDetailsOpp(opp.id); 
        
        test.stopTest();
    }
}
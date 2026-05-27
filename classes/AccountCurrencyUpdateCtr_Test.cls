@isTest(seeAllData = true)
public class AccountCurrencyUpdateCtr_Test{
       static testmethod void method1(){
          
          test.startTest();
          map<String,AccountCurrencyVsLBU__c> returnfromMethod1 = AccountCurrencyUpdateCtr.getMyMap();
          map<String,String> returnfromMethod2 = AccountCurrencyUpdateCtr.getCurrencyMap();
          test.stopTest();
          
       }
}
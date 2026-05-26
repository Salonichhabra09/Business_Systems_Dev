@isTest(seeAllData=true) 
public class MilestonePeriod_Tester{
  
  static testMethod void testMilestonePeriod(){
      Milestone_Period__c mp = new Milestone_Period__c();
      mp.Signature_Date__c = Date.today();
      mp.Financial_Period_Date__c = date.today();
      mp.Financial_Period_Closed__c = false;
      mp.name = 'abc';
      mp.BU__c = 'UK1';
      
      insert  mp;
      Milestone_Period__c mp2 = new Milestone_Period__c();
      mp2.Signature_Date__c = Date.today();
      mp2.Financial_Period_Date__c = date.today();
      mp2.Financial_Period_Closed__c = true;
      mp2.name = 'abcd';
      mp2.BU__c = 'UK1';
      insert  mp2;
      
      RevenueAttribution__c ra = new RevenueAttribution__c();
      ra.Consultant__c = UserInfo.getUserId();
      ra.Attribution_Period__c = mp.id;
      ra.Attribution_Days__c = 2;
      ra.CurrencyIsoCode = 'GBP';
      ra.Scoped__c = 'Scoped';
      mp.Financial_Period_Closed__c = true;
      update mp;      
  }
  
}
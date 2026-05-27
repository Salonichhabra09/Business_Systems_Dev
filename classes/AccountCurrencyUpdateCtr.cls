public class AccountCurrencyUpdateCtr{

   @AuraEnabled
    public static map<String,AccountCurrencyVsLBU__c> getMyMap(){
          Map<String,AccountCurrencyVsLBU__c> accountCurrencyVsLBUMap  = AccountCurrencyVsLBU__c.getAll();
          System.debug('MapValues ' + accountCurrencyVsLBUMap);
          return accountCurrencyVsLBUMap;
      }
  
    @AuraEnabled
    public static map<String,String> getCurrencyMap(){
          //List<String> pickListValuesList= new List<String>();
          Map<String,String> CurrencyMap = new Map<String,String>();
          Schema.DescribeFieldResult fieldResult = Account.CurrencyIsoCode.getDescribe();
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          for(Schema.PicklistEntry pickListVal : ple){
          CurrencyMap.put(pickListVal.getLabel(),pickListVal.getValue());
            //pickListValuesList.add(pickListVal.getLabel());
          }     
          return CurrencyMap;
      }
}
public with sharing class NewOpptyServer {
    
    @AuraEnabled(cacheable=true)
    
    public static List<RecordType> getRecordList() {
        
        List<RecordType> L = new List<RecordType>();
        L= [SELECT Id, Name FROM RecordType where SobjectType= 'Opportunity' AND Name!='GCSC Opportunity' AND Name!='Read Only Opportunity'];
        
        return L;
    }    
    
    @AuraEnabled
    
    public static Account getAccList(String recordId) {
        
        Account acc = [Select Id,CurrencyIsoCode,Name, Phone FROM Account Where Id =: recordId];
        
        return acc;
    }
    @AuraEnabled
    public static Contact getConList(String recordId) {
        
        Contact con = [Select AccountId, Account.CurrencyIsoCode, Id FROM Contact Where Id =: recordId];
        
        System.debug('This is contactRN**--->>'+con.Account.CurrencyIsoCode);
        return con;
    }
    
    @AuraEnabled
    public static Opportunity getOppList(String Id) {
        
        Opportunity op = [Select  Id FROM Opportunity Where Id =: Id];
        
        
        return op;
    }
}
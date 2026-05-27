public with sharing class ContractAccountHelper {
    @AuraEnabled(cacheable=true)
    public static Map<Id, String> getAccountNames(List<Id> contractIds) {
        Map<Id, String> contractToAccountName = new Map<Id, String>();
        for (Contract c : [
            SELECT Id, Account.Name 
            FROM Contract 
            WHERE Id IN :contractIds
        ]) {
            if (c.Account != null) {
                contractToAccountName.put(c.Id, c.Account.Name);
            }
        }
        return contractToAccountName;
    }
}
@isTest(SeeAllData=true)
private class Account_Manager_Tester {
    static testMethod void Account_ManagerTest(){
        List<Account> accList = [Select id from Account
                                 where (NOT BU__c like '%UK5%') AND (NOT BU__c like '%DK5%') AND (NOT BU__c like '%SE5%') AND
                                 (NOT BU__c like '%DE1%') AND (NOT BU__c like '%US1%') AND (NOT BU__c like '%BE1%') AND 
                                 (NOT BU__c like '%FR1%') AND (NOT BU__c like '%NL1%') limit 5];
        Set<Id> accountIds = new Set<Id>();
        for(Account acc:accList){
            accountIds.add(acc.id);
        }
        Account_Manager.updateNumberOfContacts(accountIds);
        
            }
 
}
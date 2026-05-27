public with Sharing class CustomLookupController {
    
    public static Date sixMonthsAgo;

    @AuraEnabled(cacheable=true)
    public static List<SObjectWrapper> getRequiredLookupRecords(String itemToSearch, String objectName, String filter, String accountPlanId) {
        String query = null;
        String name ='';
        String queryMode = '';
        
        Account_Plan__c accplan = new Account_Plan__c();
        name = objectName=='Strategy_and_Goal__c'?'Strategy_Name__c':'Name';
        //System.debug(' CustomLookupController ' + objectName);
        if(accountPlanId != ''){
            accplan = [select id , Account_Name__c,Account_Plan_Status__c , Account_Name__r.CurrencyIsoCode,Account_Plan_Type__c,Buying_Centre_Id__c
                                   from Account_Plan__c where id=:accountPlanId];
        }else{
            queryMode = 'System';
        }
        //System.debug(' CustomLookupController ' + queryMode);
        List<Id> accountIdList = new List<Id>();
        if(objectName=='Contact'){
            if(accplan.Account_Plan_Type__c=='Regional'){
            List<Account> accList = [SELECT Id FROM Account WHERE Buying_Centre_Id__c= :accplan.Buying_Centre_Id__c];
            List<Id> accIds = new List<Id>();
            for (Account acc : accList) {
                accIds.add(acc.Id);
            }
            accountIdList = accIds;
        }else if(accplan.Account_Plan_Type__c=='Current'){
            accountIdList.add(accplan.Account_Name__c);
        }else if(accplan.Account_Plan_Type__c=='Global'){
            Set<Id> allAccountIds = new Set<Id>{accplan.Account_Name__c};
                Set<Id> parentIds = new Set<Id>{accplan.Account_Name__c};
                    List<Account> childAccounts = new List<Account>();
            do {
                childAccounts = [SELECT Id FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                parentIds.clear();
                for (Account child : childAccounts){
                    parentIds.add(child.Id);
                    allAccountIds.add(child.Id);
                }
            } while (childAccounts.size() > 0);
            accountIdList = new List<Id>(allAccountIds);
        }
        }
        if(filter != null && filter != ''){
            if(objectName=='Contact'){
                query = 'Select Id,Account_D_Number__c,'+ name +' from '+objectName+' Where '+ name +' Like  \'%' + itemToSearch + '%\' AND '+'AccountId IN :accountIdList'+' LIMIT  5';
            }else{
                query = 'Select Id,'+ name +' from '+objectName+' Where '+ name +' Like  \'%' + itemToSearch + '%\' AND '+filter+' LIMIT  5';
            }
        }
        else {
            if(itemToSearch == null || itemToSearch == ''){
                if(objectName=='ProjectObject__c'){
                    sixMonthsAgo = Date.today().addMonths(-6);
                 	query = 'Select Id, Account__r.Name,'+ name +' from '+objectName+' Where LastViewedDate != NULL' +
               ' AND ((Project_Status__c != \'Closed\' AND Project_Status__c != \'Cancelled\')' + 
               ' OR (Project_Status__c IN (\'Closed\', \'Cancelled\')' + 
               ' AND Project_Closed_Date__c >= :sixMonthsAgo))' + 
               ' ORDER BY LastViewedDate DESC LIMIT 5';
                //System.debug(query);
                }else{
                	query = 'Select Id,'+ name +' from '+objectName+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
                }
            }
            else {
                if(objectName=='ProjectObject__c'){
                    sixMonthsAgo = Date.today().addMonths(-6);
                    query = 'Select Id, Account__r.Name,'+ name +' from '+objectName+' Where ('+ name +' Like  \'%' + itemToSearch + '%\' OR Account__r.Name Like  \'%' + itemToSearch + '%\')'+ 
               ' AND ((Project_Status__c != \'Closed\' AND Project_Status__c != \'Cancelled\')' + 
               ' OR (Project_Status__c IN (\'Closed\', \'Cancelled\')' + 
               ' AND Project_Closed_Date__c >= :sixMonthsAgo ))' + 
               ' LIMIT 5';
                 //System.debug(query);
                }else{
                	query = 'Select Id,'+ name +' from '+objectName+' Where '+ name +' Like  \'%' + itemToSearch + '%\' LIMIT  5';
                }
            }
        }
        //system.debug(query);
        List<sObject> listToProcess = new List<sObject>();
        if(queryMode=='System'){
            QueryInSystemMode queryClassObject = new QueryInSystemMode();
 			listToProcess = queryClassObject.getData(query);
        }else{
            listToProcess = database.query(query);
        }
        List<SObjectWrapper> listToReturn = new List<SObjectWrapper>();
        for (sObject obj : listToProcess) {
            SObjectWrapper wrap = new SObjectWrapper();
            wrap.Id = obj.Id;
            wrap.Name = objectName!='Contact' || (accplan.Account_Plan_Type__c=='Current' && objectName=='Contact')?(String) obj.get(name): (String) obj.get(name)+' - '+ (String)obj.get('Account_D_Number__c');
            if(objectName=='ProjectObject__c'){
                wrap.AccountName = (String)obj.getSobject('Account__r').get(name);
            }
            listToReturn.add(wrap);
        }
        return listToReturn;
    }
    
    public without sharing class QueryInSystemMode{
        
        public List<sObject> getData(String query){
            //system.debug(sixMonthsAgo);
            return database.query(query);
        }
    }

    public class SObjectWrapper{
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String AccountName;
    }
}
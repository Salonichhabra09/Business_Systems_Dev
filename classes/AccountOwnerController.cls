public without sharing class AccountOwnerController {
    
    
    @AuraEnabled(cacheable=true)
    public static AccountDetails getAccountOwnerDetails(Id recordId){
        try {
            AccountDetails detailsToReturn = new AccountDetails();
            List<Account> accountToQuery = [SELECT Id,OwnerId,GCSC_Owned_Account__c,GCSC_Account_Owner__c,Owner.Name,Customer_Connect_Account__c FROM Account WHERE Id =:recordId];
            if(!accountToQuery.isEmpty()){
                UserRecordAccess access = [SELECT RecordId,HasTransferAccess,HasEditAccess FROM UserRecordAccess where UserId =:UserInfo.getUserId() AND RecordId =:recordId];
                
                Boolean hasTransferAccess = access.HasTransferAccess;
                detailsToReturn.hasTransferAccess = hasTransferAccess;
                detailsToReturn.hasEditAccess = access.HasEditAccess;
                detailsToReturn.isGcscAccount = false;
                detailsToReturn.isCustomerConnectAccount = false;
                String userProfile =  [SELECT Id,Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
                detailsToReturn.hasEditAccessOnCustomerConnect = (FeatureManagement.checkPermission('Access_to_Customer_Connect_on_Account_Owner') && access.HasEditAccess) || userProfile=='System Administrator';
	            detailsToReturn.hasEditAccessOnGcscOwned = (FeatureManagement.checkPermission('Access_to_GCSC_Owned_on_Account_Owner') && access.HasEditAccess) || userProfile=='System Administrator';
                if(accountToQuery[0].GCSC_Owned_Account__c){
                    detailsToReturn.ownerDetails = accountToQuery[0].GCSC_Account_Owner__c;
                    detailsToReturn.isGcscAccount = true;
                }else if(accountToQuery[0].Customer_Connect_Account__c){
                    detailsToReturn.ownerDetails = accountToQuery[0].GCSC_Account_Owner__c;
                    detailsToReturn.isCustomerConnectAccount = true;                    
                }else{
                    System.debug(accountToQuery[0].Owner.Name);
                    if(hasTransferAccess){
                        detailsToReturn.ownerDetails = accountToQuery[0].OwnerId;
                    }else{
                        detailsToReturn.ownerDetails = accountToQuery[0].Owner.Name;
                    }
                }
            }
            return detailsToReturn;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class AccountDetails{
        
        @AuraEnabled public String ownerDetails {get;set;}
        @AuraEnabled public Boolean hasTransferAccess {get;set;}
        @AuraEnabled public Boolean hasEditAccess {get;set;}
        @AuraEnabled public Boolean hasEditAccessOnCustomerConnect {get;set;}
        @AuraEnabled public Boolean hasEditAccessOnGcscOwned {get;set;}
        @AuraEnabled public Boolean isGcscAccount {get;set;}
        @AuraEnabled public Boolean isCustomerConnectAccount {get;set;}
    }
}
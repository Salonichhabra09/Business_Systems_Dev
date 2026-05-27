/**
 * @description  Returns account ownership details and edit/transfer access flags for the
 *               Account Owner LWC. Resolves the correct owner display value based on
 *               GCSC/Customer Connect flags and determines access via Permission Sets
 *               and Custom Labels rather than Profile SOQL queries.
 * @dependencies PermissionSet: Access_to_Customer_Connect_on_Account_Owner,
 *                               Access_to_GCSC_Owned_on_Account_Owner
 *               CustomLabel:    SystemAdmins_Profiles
 */
public without sharing class AccountOwnerController {

    /**
     * @description Fetches ownership details and access flags for the given Account record.
     *              Checks UserRecordAccess for transfer/edit rights, then resolves the
     *              correct owner display value based on GCSC/Customer Connect flags.
     *              System Admins (identified via Custom Label) always receive edit access
     *              on GCSC-owned and Customer Connect fields.
     * @param  recordId  Id of the Account record to inspect.
     * @return           AccountDetails wrapper with owner info and access booleans.
     */
    @AuraEnabled(cacheable=true)
    public static AccountDetails getAccountOwnerDetails(Id recordId){
        try {
            AccountDetails detailsToReturn = new AccountDetails();
            List<Account> accountToQuery = [SELECT Id, OwnerId, GCSC_Owned_Account__c, GCSC_Account_Owner__c, Owner.Name, Customer_Connect_Account__c, Name FROM Account WHERE Id = :recordId];
            if(!accountToQuery.isEmpty()){
                UserRecordAccess access = [SELECT RecordId, HasTransferAccess, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];

                Boolean hasTransferAccess = access.HasTransferAccess;
                Boolean isSysAdmin = System.Label.SystemAdmins_Profiles.split(',').contains(UserInfo.getProfileId().substring(0, 15));

                detailsToReturn.hasTransferAccess = hasTransferAccess;
                detailsToReturn.hasEditAccess = access.HasEditAccess;
                detailsToReturn.isGcscAccount = false;
                detailsToReturn.isCustomerConnectAccount = false;
                detailsToReturn.hasEditAccessOnCustomerConnect = (FeatureManagement.checkPermission('Access_to_Customer_Connect_on_Account_Owner') && access.HasEditAccess) || isSysAdmin;
                detailsToReturn.hasEditAccessOnGcscOwned = (FeatureManagement.checkPermission('Access_to_GCSC_Owned_on_Account_Owner') && access.HasEditAccess) || isSysAdmin;

                if(accountToQuery[0].GCSC_Owned_Account__c){
                    detailsToReturn.ownerDetails = accountToQuery[0].GCSC_Account_Owner__c;
                    detailsToReturn.isGcscAccount = true;
                } else if(accountToQuery[0].Customer_Connect_Account__c){
                    detailsToReturn.ownerDetails = accountToQuery[0].GCSC_Account_Owner__c;
                    detailsToReturn.isCustomerConnectAccount = true;
                } else {
                    detailsToReturn.ownerDetails = hasTransferAccess ? accountToQuery[0].OwnerId : accountToQuery[0].Owner.Name;
                }
            }
            return detailsToReturn;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** Wrapper returned to the LWC with owner display value and access control flags. */
    public class AccountDetails {
        @AuraEnabled public String ownerDetails {get;set;}                    // Owner Id (transfer access) or Owner.Name
        @AuraEnabled public Boolean hasTransferAccess {get;set;}              // Can the user change account ownership?
        @AuraEnabled public Boolean hasEditAccess {get;set;}                  // Does the user have edit rights on this record?
        @AuraEnabled public Boolean hasEditAccessOnCustomerConnect {get;set;} // Edit access for the Customer Connect field
        @AuraEnabled public Boolean hasEditAccessOnGcscOwned {get;set;}       // Edit access for the GCSC Owned field
        @AuraEnabled public Boolean isGcscAccount {get;set;}                  // Account is flagged as GCSC-owned
        @AuraEnabled public Boolean isCustomerConnectAccount {get;set;}       // Account is flagged as Customer Connect
    }
}

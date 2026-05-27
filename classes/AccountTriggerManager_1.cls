/**
 * AccountTriggerManager_1
 *
 * PURPOSE
 * -------
 * Handles before-update validations and field-update logic for the Account object.
 * Called from the Account_Trigger trigger on the beforeUpdate context.
 *
 * METHODS AT A GLANCE
 * -------------------
 * beforeAccountValidation         – Permission checks and field sync on account update
 * changeAccRecordType             – Switches Account Record Type based on Status transitions
 * mapsalesTeamRegionAndSuperMD... – Copies region fields from Territory when Territory changes
 * beforeAccountSanction           – Calculates sanction automation date (business-days aware)
 * splitStringBasedOnSeparator     – Invocable method: splits an address string into 4 address lines (used by Flow)
 *
 * KEY DEPENDENCIES
 * ----------------
 * Custom Labels:
 *   - Account_Approvers            : 15-char profile ID allowed to approve/reject accounts
 *   - SystemAdmins_Profiles        : Comma-separated list of System Admin profile IDs (15-char)
 *   - LegalTeam_Profiles           : Profile ID for the Legal Team
 *   - Account_Sanction_Threshold   : Number of business hours before sanction automation runs (24, 48, or 72)
 *
 * Custom Settings:
 *   - AccountCurrencyVsLBU__c      : Maps BU codes to their default ISO currency code
 *   - AccountRecordTypeId__c       : Stores the target Record Type ID used during status transitions
 *
 * Permission Sets:
 *   - OATs                         : Grants OAT team elevated account edit rights
 *   - SOE                          : Grants SOE team rights to edit approved accounts
 *   - Legal_Page_Restrictions      : Grants Legal team rights to approve/reject accounts
 *   - Users_with_Account_edit_permission : Grants additional edit rights on approved accounts
 *
 * Public Groups (queried at runtime):
 *   - Account Owner Changers       : Users allowed to change Account Owner (with BU restriction)
 *   - Ops                          : Users allowed to change Territory on approved accounts
 *   - Territory Changers           : Same Territory-change permission as Ops
 *   - GCSC Users                   : Populated but currently unused in active logic
 *
 * CREATED BY   : Rishabh Kanotra
 * CREATED DATE : 07-06-2019
 * MODIFIED BY  : Prabhat Arora (SSE-8858), Aashi (SSE-17264, SSE-23791),
 *                Jai (SSE-24245, SSE-24406), Prachi (SSE-16905), Virendra Kumar
 */
Global class AccountTriggerManager_1{

    /**
     * beforeAccountValidation
     *
     * Trigger context : Account_Trigger → before update
     *
     * Runs the following checks and field updates in a single pass over the records:
     *
     * 1. ACCOUNT APPROACH RESTRICTION
     *    Prevents non-admin, non-OAT, non-SOE users from changing Account_Approach__c.
     *    Error: "User is not part of Account Owner Changers Group"
     *
     * 2. STATUS APPROVAL RESTRICTION
     *    Only OAT, System Admins, the designated Account Approver profile, and Legal
     *    can set Status__c to 'Approved' or 'Unapproved'.
     *    Error: "Only OAT and System Admins can approve/reject an account record."
     *
     * 3. BILLING-TO-SHIPPING ADDRESS SYNC
     *    When Same_As_The_Billing_Address__c is TRUE and any billing address field
     *    changes (or the checkbox is first checked), all shipping address fields are
     *    overwritten with the corresponding billing values.
     *    Fields synced: Address Lines 1–4, City, State, ZIP, Global/Shipping Country.
     *
     * 4. ACCOUNT OWNER CHANGE RESTRICTION
     *    Non-admin, non-OAT, non-Legal users may only change OwnerId if they are in
     *    the "Account Owner Changers" group AND their Project_BU__c includes the
     *    account's BU__c value.
     *    Errors: "You do not have the necessary permissions to change the owner..."
     *             "Only System Admin, OAT, LegalTeam and Account owner changers can edit..."
     *
     * 5. TERRITORY CHANGE RESTRICTION (Ops-only check)
     *    On an Approved account, only members of Ops, Territory Changers, or Account
     *    Owner Changers groups may change Territory__c.
     *    Error: "Only an Ops Manager can edit the Terriotry field in account"
     *
     * 6. TERRITORY CHANGE RESTRICTION (Admin/OAT/SOE check)
     *    On an Approved account, users outside Ops/Territory Changers AND without
     *    admin/OAT/SOE/easement-permission-set access cannot change Territory__c.
     *    Error: "Only an Administrator, Gatekeeper, OAT and SOE can edit the account..."
     *
     * 7. CURRENCY CHANGE RESTRICTION
     *    Currency can only be changed when Status__c is 'Unapproved', and only by
     *    OAT or System Admins.
     *    Error: "You can only change the currency on an account with a status of 'unapproved'..."
     *
     * 8. IS-CURRENCY-CHANGED FLAG
     *    Sets IsCurrencyChanged__c = true when the account's CurrencyISOCode diverges
     *    from the LBU default defined in AccountCurrencyVsLBU__c custom setting,
     *    provided the transfer status has not also changed in the same transaction.
     *
     * @param oldAccount  List of Account records before the update (trigger.old)
     * @param newAccount  List of Account records after the update (trigger.new)
     * @param oldmap      Map of Account Id → old Account record (trigger.oldMap)
     */
public static void beforeAccountValidation(List<Account> oldAccount, List<Account> newAccount, Map<id,Account> oldmap){
    System.debug('Number of Queries used -- AccountTriggerManager.beforeAccountValidation START ------- ' + Limits.getQueries());
    
    Set<id> usersSet = new Set<id>();
    Set<Id> accChangerset = new Set<Id>();
    Set<Id> setOfGrpMemb = new Set<Id>();
    Set<Id> GCSCSet = new Set<Id>();
    Set<id> newUsers = new Set<id>();
    String AccountApproverlabel= Label.Account_Approvers;
    
    Boolean hasOATsPermission = FeatureManagement.checkPermission('OATs'); // Added by Jai for SSE-24406
    Boolean hasSOEsPermission = FeatureManagement.checkPermission('SOE'); // Added by Jai for SSE-24245
    Boolean hasLegalPermission = FeatureManagement.checkPermission('Legal_Page_Restrictions');
   for(Group gp : [select id,Name,(select id,UserOrGroupId from GroupMembers) 
                   from Group 
                   where Name IN('Ops','GCSC Users','Account Owner Changers','Territory Changers')]) {
        
        for(GroupMember gm : gp.Groupmembers){    
            if(gp.Name=='Ops'){
                setOfGrpMemb.add(gm.UserOrGroupId);
                newUsers.add(gm.UserOrGroupId);
            }else if(gp.Name=='GCSC Users'){
                GCSCSet.add(gm.UserOrGroupId);
            }else if(gp.Name=='Territory Changers'){
                setOfGrpMemb.add(gm.UserOrGroupId);
                newUsers.add(gm.UserOrGroupId);
            }else { //gp.Name=='Account Owner Changers'
                usersSet.add(gm.UserOrGroupId);
                accChangerset.add(gm.UserOrGroupId);
                setOfGrpMemb.add(gm.UserOrGroupId);
            }
        }
    }
    
    String userprofileid=(String)UserInfo.getProfileId().substring(0,15);
    
    set<string> systmadminSet1 = new set<string>();
    systmadminSet1.addall(System.Label.SystemAdmins_Profiles.split(','));
    
    String LegalTeam_Profile = System.Label.LegalTeam_Profiles;

    //Show error when user in not allowed to make changes to account
    if(!usersSet.contains(userInfo.getUserId())){
        if(!(systmadminSet1.contains(userprofileid) || hasSOEsPermission || hasOATsPermission)) {
            for(integer i=0;i<newAccount.size();i++){
                if(newAccount[i].Account_Approach__c != oldMap.get(newAccount[i].ID).Account_Approach__c){
                    newAccount[i].addError('User is not part of Account Owner Changers Group');
                }
            }
        }
    }
    
    User uid = new User();
    if(accChangerset != null && accChangerset.contains(Userinfo.getUserId())){
        uid = [select id,Project_BU__c,UserName from user where id =:Userinfo.getUserId()];
    }
    
    Map<String,AccountCurrencyVsLBU__c> accountCurrencyVsLBUMap = AccountCurrencyVsLBU__c.getAll();
    
    
    List<PermissionSetAssignment> EasementManagers = [Select AssigneeId FROM
                                                      PermissionSetAssignment WHERE 
                                                      PermissionSet.Name = 'Users_with_Account_edit_permission'];
    Set<Id> setUserIds = new Set<Id>();
    for(PermissionSetAssignment varPSA : EasementManagers) {
        setUserIds.add(varPSA.AssigneeId);
    }
    
    for(Integer i=0; i < newAccount.size();i++) {
    
        //Updating the IsCurrencyChanged__c field of account if currency is changed.
        if(newAccount[i].IsCurrencyChanged__c == oldAccount[i].IsCurrencyChanged__c){
           if(accountCurrencyVsLBUMap != null && newAccount[i].BU__c !=null ){
                if( accountCurrencyVsLBUMap.get(newAccount[i].BU__c.split('-')[1].trim())!=null && accountCurrencyVsLBUMap.get(newAccount[i].BU__c.split('-')[1].trim()).Default_Currency__c != newAccount[i].CurrencyISOCode){    
                    if(newAccount[i].SFDC2SUN_TransferStatus__c == oldAccount[i].SFDC2SUN_TransferStatus__c)
                        newAccount[i].IsCurrencyChanged__c = true;
                    
                }
            }
        }
        
        //Showing error if anyone else apart from sys admin or oat try to change status of account to Approved or UnApproved/
        if(newAccount[i].Status__c != oldAccount[i].Status__c &&
           (newAccount[i].Status__c == 'Approved' || newAccount[i].Status__c == 'Unapproved')) {
            if(!(hasOATsPermission || systmadminSet1.contains(userprofileid) || userprofileid == System.Label.Account_Approvers || hasLegalPermission)) {
                newAccount[i].addError('Only OAT and System Admins can approve/reject an account record.');
            }
        }
        
        //check for the  Same as billing Adress checkbox field and Updates copies the Shipping Address Accordingly
        // Added a check if Billing Address is getting updated by Aashi - SSE-17264
        if((newAccount[i].Same_As_The_Billing_Address__c
                && (newAccount[i].Billing_Address_Line_1__c != oldmap.get(newAccount[i].Id).Billing_Address_Line_1__c
                    || newAccount[i].Billing_Address_Line_2__c != oldmap.get(newAccount[i].Id).Billing_Address_Line_2__c
                    || newAccount[i].Billing_Address_Line_3__c != oldmap.get(newAccount[i].Id).Billing_Address_Line_3__c
                    || newAccount[i].Billing_Address_Line_4__c != oldmap.get(newAccount[i].Id).Billing_Address_Line_4__c
                    || newAccount[i].Billing_City__c != oldmap.get(newAccount[i].Id).Billing_City__c
                    || newAccount[i].Billing_State__c != oldmap.get(newAccount[i].Id).Billing_State__c
                    || newAccount[i].Billing_ZIP_Postal_Code__c != oldmap.get(newAccount[i].Id).Billing_ZIP_Postal_Code__c
                    || newAccount[i].Global_Billing_Country__c != oldmap.get(newAccount[i].Id).Global_Billing_Country__c))
               || (newAccount[i].Same_As_The_Billing_Address__c != oldmap.get(newAccount[i].Id).Same_As_The_Billing_Address__c 
                   && newAccount[i].Same_As_The_Billing_Address__c)
              )
            {
              newAccount[i].Shipping_Address_Line_1__c=newAccount[i].Billing_Address_Line_1__c;
              newAccount[i].Shipping_Address_Line_2__c=newAccount[i].Billing_Address_Line_2__c;
              newAccount[i].Shipping_Address_Line_3__c=newAccount[i].Billing_Address_Line_3__c;
              newAccount[i].Shipping_Address_Line_4__c=newAccount[i].Billing_Address_Line_4__c;
              newAccount[i].Shipping_City__c=newAccount[i].Billing_City__c;
              newAccount[i].Global_Shipping_Country__c=newAccount[i].Global_Billing_Country__c;//SSE-16905 - Prachi
              newAccount[i].Shipping_Country__c=newAccount[i].Global_Billing_Country__c;//SSE-16905 - Prachi
              newAccount[i].Shipping_State_County__c=newAccount[i].Billing_State__c;
              newAccount[i].Shipping_ZIP_Postal_Code__c=newAccount[i].Billing_ZIP_Postal_Code__c;
            }
         
        if (newAccount[i].OwnerId != oldmap.get(newAccount[i].ID).OwnerId) {
            if(!systmadminSet1.contains(userprofileid)){
                if(!hasOATsPermission){
                    if(!LegalTeam_Profile.contains(userprofileid)){
                        if(accChangerset != null && accChangerset.contains(Userinfo.getUserId())){
                            if(uid.Project_BU__c != null && !uid.Project_BU__c.Contains(newAccount[i].BU__c)){
                                newAccount[i].adderror('You do not have the necessary permissions to change the owner of this account ');
                            }
                        }else{
                            newAccount[i].adderror('Only System Admin, OAT, LegalTeam and Account owner changers can edit the acccount Owner.');
                        }
                    }
                }
            }
        }
        
        //Show error if account is approved and user is not from (OPS,Territory changers or Account owner changers) & Teritory has been changed 
        if ((newAccount[i].Status__c == 'Approved') && ((!setOfGrpMemb.contains(Userinfo.getUserId())))){
            if(newAccount[i].Territory__c != oldmap.get(newAccount[i].ID).Territory__c){
                newAccount[i].adderror('Only an Ops Manager can edit the Terriotry field in account');
            }
        }
        
        if ((newAccount[i].Status__c == 'Approved') &&
            !newUsers.contains(Userinfo.getUserId()) &&
            !(systmadminSet1.contains(userprofileid) ||
              hasOATsPermission ||
              setUserIds.contains(Userinfo.getUserId()) ||
              hasSOEsPermission)) {
                  
            if(newAccount[i].Territory__c != oldmap.get(newAccount[i].ID).Territory__c){
               newAccount[i].adderror('Only an Administrator, Gatekeeper, OAT and SOE can edit the account as the status is Approved');
            }
        }
        
        if(newAccount[i].CurrencyIsoCode != oldmap.get(newAccount[i].ID).CurrencyIsoCode &&
           newAccount[i].Status__c != ‘Unapproved’){
            if(!hasOATsPermission){
                if(!systmadminSet1.contains(userprofileid)){
                    newAccount[i].adderror(‘You can only change the currency on an account with a status of ‘unapproved’. Please contact the gatekeeper to change this account.’);
                }
            }
        }
       

    }
    
    
    System.debug('Number of Queries used -- AccountTriggerManager.beforeAccountValidation END ------- ' + Limits.getQueries());
}//beforeAccountValidation

    /**
     * changeAccRecordType
     *
     * Trigger context : Account_Trigger → before update
     *
     * Switches the Account Record Type and maintains Old_Record_Type__c based on
     * Status__c transitions. The target Record Type ID is read from the
     * AccountRecordTypeId__c custom setting (key: 'AccountrecordType').
     *
     * Transition rules:
     *
     *   None / Unapproved / Submitted for Approval / Unapproved - Out of Business
     *     → Approved or Archived   : Set RecordTypeId to the configured RT; save old RT in Old_Record_Type__c
     *
     *   Approved → Archived        : Set RecordTypeId to the configured RT
     *
     *   Archived → Approved        : Set RecordTypeId to the configured RT
     *
     *   Approved / Archived
     *     → None / Unapproved / Submitted for Approval / Unapproved - Out of Business
     *                              : Restore RecordTypeId from Old_Record_Type__c
     *
     * @param newAccount  List of Account records after the update (trigger.new)
     * @param oldmap      Map of Account Id → old Account record (trigger.oldMap)
     */
public static void changeAccRecordType(List<Account> newAccount, Map<id,Account> oldmap){
System.debug('Number of Queries used -- AccountTriggerManager.changeAccRecordType START ------- ' + Limits.getQueries());
        for(Account acc: newAccount)
        {
            String str_id='';
            
            // modified by saloni chhabra on 6th jan 2016 as per SSE-1795 replaced Live with Approved and  Dead – Gone out of Business as Unapproved - Out of Business  
                if((acc.Status__c=='Approved' || acc.Status__c=='Archived' )&&(oldmap.get(acc.id).Status__c=='None'||oldmap.get(acc.id).Status__c=='Unapproved'||oldmap.get(acc.id).Status__c=='Submitted for Approval' || oldmap.get(acc.id).Status__c=='Unapproved - Out of Business'))
                {   
                  str_id=AccountRecordTypeId__c.getValues('AccountrecordType').RecordTypeId__c;
                  acc.Old_Record_Type__c =oldmap.get(acc.id).RecordTypeId;
                  acc.RecordTypeID = str_id;// oldmap.get(acc.id).RecordTypeId;
                  system.debug('value is ' +acc.Old_Record_Type__c);
                
                } 
            
            //modified by saloni chhabra on 6th jan 2016 as per SSE-1795 replaced Live with Approved 
                if(acc.Status__c=='Archived' && oldmap.get(acc.id).Status__c=='Approved' )  
                {
                    str_id=AccountRecordTypeId__c.getValues('AccountrecordType').RecordTypeId__c;
                    acc.RecordTypeID = str_id;
                    system.debug('value is1 ' +acc.Old_Record_Type__c);
                }
            
            //modified by saloni chhabra on 6th jan 2016 as per SSE-1795 replaced Live with Approved           

            if(acc.Status__c=='Approved' && oldmap.get(acc.id).Status__c=='Archived' )  
                {
                    str_id=AccountRecordTypeId__c.getValues('AccountrecordType').RecordTypeId__c;
                    acc.RecordTypeID = str_id;
                    system.debug('value is1 ' +acc.Old_Record_Type__c);
                }
            
            
            
             // modified by saloni chhabra on 6th jan 2016 as per SSE-1795 replaced Live with Approved and  Dead – Gone out of Business as Unapproved - Out of Business  
                if((acc.status__c=='None'|| acc.status__c=='Unapproved'||acc.status__c=='Submitted for Approval'||acc.status__c=='Unapproved - Out of Business')&& (oldmap.get(acc.id).Status__c=='Approved'||oldmap.get(acc.id).Status__c=='Archived'))
                {   
                  acc.RecordTypeID=acc.Old_Record_Type__c;
                  system.debug('value is2 ' +acc.Old_Record_Type__c);
                
                }
        

        }  
 System.debug('Number of Queries used -- AccountTriggerManager.changeAccRecordType END ------- ' + Limits.getQueries());
  
}//changeAccRecordType

    /**
     * mapsalesTeamRegionAndsuperMDRegionFromTerritory
     *
     * Trigger context : Account_Trigger → before update (and before insert via oldAccountMap = null)
     *
     * When Territory__c is set or changed on an Account, reads the corresponding
     * Territory__c record and copies three fields back to the Account:
     *
     *   Territory__c.Region__c          → Account.Region_Global__c
     *   Territory__c.Sales_Team_Region__c → Account.Sales_Team_Region__c
     *   Territory__c.Super_MD_Region__c  → Account.Super_MD_Region__c
     *
     * Accounts whose territory ID does not resolve to a Territory__c record
     * (e.g. deleted territory) are silently skipped — no error is thrown.
     *
     * @param newAccount      List of Account records after the update (trigger.new)
     * @param oldAccountMap   Map of Account Id → old Account record (trigger.oldMap); null on insert
     * @param newAccountMap   Map of Account Id → new Account record (trigger.newMap)
     */
    public static void mapsalesTeamRegionAndsuperMDRegionFromTerritory(List<Account> newAccount,Map<Id,Account> oldAccountMap,Map<Id,Account> newAccountMap){
        Map<Id, Id> accountTerritoryMap = new Map<Id, Id>();
        Map<Id, Territory__c> territoryMap = new Map<Id, Territory__c>();
        list<Territory__c> territoryList = new list<Territory__c>();
        
        for(Account acc : newAccount){
            if(oldAccountMap == null || (acc.Territory__c != null && acc.Territory__c != oldAccountMap.get(acc.Id).Territory__c)){
                accountTerritoryMap.put(acc.Id, acc.Territory__c);
            }
        }
        
        if(accountTerritoryMap.size() > 0){
            territoryList = [SELECT Id, Sales_Team_Region__c,Region__c, Super_MD_Region__c, Name FROM Territory__c WHERE Id IN :accountTerritoryMap.values()];
        }
       
        if(territoryList.size() > 0){
            for(Territory__c t : territoryList){
                territoryMap.put(t.Id, t);
            }
            
            for(Account acc : newAccount){
                Id terrId = accountTerritoryMap.get(acc.Id);
                Territory__c terr = terrId != null ? territoryMap.get(terrId) : null;
                if(terr != null){
                    acc.Region_Global__c = terr.Region__c;
                    acc.Sales_Team_Region__c = terr.Sales_Team_Region__c;
                    acc.Super_MD_Region__c = terr.Super_MD_Region__c;
                }
            }
        }
    }
    
    /**
     * beforeAccountSanction
     *
     * Trigger context : Account_Trigger → before update
     *
     * When an Account's Status__c transitions TO 'Rejected - Sanctioned Account',
     * calculates and sets Account_Sanction_Automation_Date__c — the datetime at
     * which the sanction automation job should run.
     *
     * The threshold (in hours) is read from custom label Account_Sanction_Threshold.
     * Supported values: 24, 48, 72. Weekend hours are skipped so the threshold
     * only counts business hours (Monday–Friday).
     *
     * Business-day logic:
     *   - Weekday where weekend padding is NOT needed (early in the week):
     *       automationDate = now + threshold hours
     *   - Weekday where the window crosses the weekend:
     *       automationDate = now + 48h (weekend skip) + threshold hours
     *   - Saturday : automationDate = now + (hours remaining until Monday) + threshold hours
     *   - Sunday   : automationDate = now + (hours remaining until Monday) + threshold hours
     *
     * Which weekdays fall into each bucket depends on the threshold value:
     *   72h threshold → Mon/Tue = no padding; Wed/Thu/Fri = add 48h
     *   48h threshold → Mon/Tue/Wed = no padding; Thu/Fri = add 48h
     *   24h threshold → Mon/Tue/Wed/Thu = no padding; Fri = add 48h
     *
     * @param newAccount  List of Account records after the update (trigger.new)
     * @param oldMap      Map of Account Id → old Account record (trigger.oldMap)
     */
    public static void beforeAccountSanction(List<Account> newAccount, Map<Id,Account> oldMap){
        
        List<Account> accountsToUpdate = new List<Account>();        
        for(Account acc : newAccount){
            if(acc.Status__c == 'Rejected - Sanctioned Account' && oldMap.get(acc.Id).Status__c != 'Rejected - Sanctioned Account'){
                accountsToUpdate.add(acc);
            }
        }
        
        if(!accountsToUpdate.isEmpty()){
            Datetime automationRunDateTime;
            Datetime currentDateTime = System.Now();
            Date dateValue = System.Today();
            System.debug( 'dateValue is ' + dateValue );
            Datetime tempDateTime = ( DateTime )dateValue;
            String dayOfWeek = tempDateTime.formatGMT( 'EEEE' );
            System.debug( 'dayOfWeek is ' + dayOfWeek );
            
            List<String> weekdaysAddNotRequired = new List<String>();
            List<String> weekdaysAddRequired = new List<String>();
            List<String> weekendDays = new List<String>{'Saturday','Sunday'};
                
                if(Integer.valueOf(System.Label.Account_Sanction_Threshold)==72){
                    weekdaysAddNotRequired = new List<String>{'Monday','Tuesday'};
                    weekdaysAddRequired = new List<String>{'Wednesday','Thursday','Friday'};  
                        
                }else if(Integer.valueOf(System.Label.Account_Sanction_Threshold)==48){
                    weekdaysAddNotRequired = new List<String>{'Monday','Tuesday','Wednesday'};
                    weekdaysAddRequired = new List<String>{'Thursday','Friday'};   
                        
                }else if(Integer.valueOf(System.Label.Account_Sanction_Threshold)==24){
                    weekdaysAddNotRequired = new List<String>{'Monday','Tuesday','Wednesday','Thursday'};
                    weekdaysAddRequired = new List<String>{'Friday'};
                }
                
            if(weekdaysAddNotRequired.contains(dayOfWeek)){
                automationRunDateTime = currentDateTime.addHours(Integer.valueOf(System.Label.Account_Sanction_Threshold)); 
            }else if(weekdaysAddRequired.contains(dayOfWeek)){
                automationRunDateTime = currentDateTime.addHours(48 + Integer.valueOf(System.Label.Account_Sanction_Threshold)); 
            }else if(weekendDays.contains(dayOfWeek)){
                Integer weekendRemainingTime;
                
                if(dayOfWeek == 'Saturday'){
                    weekendRemainingTime = 48 - currentDateTime.hour();
                }else{
                    weekendRemainingTime = 24 - currentDateTime.hour();
                }
                Integer totalHoursToAdd = Integer.valueOf(System.Label.Account_Sanction_Threshold) + weekendRemainingTime;
                automationRunDateTime = currentDateTime.addHours(totalHoursToAdd);
            }
            
            for(Account acc : accountsToUpdate){
                acc.Account_Sanction_Automation_Date__c = automationRunDateTime;
            }

        }
        
    }
    /**
     * splitStringBasedOnSeparator
     *
     * Invocable method — callable from Salesforce Flow.
     *
     * Splits each string in the input list by a given separator and maps the
     * resulting tokens to up to four address line fields (AddressLine1–4).
     * Tokens beyond the 4th are ignored.
     *
     * Designed to parse a raw multi-part address string (e.g. from an integration
     * feed) into discrete address line fields before writing to an Account record.
     *
     * Input  (FlowRequest):
     *   separator     – The delimiter character/string to split on (e.g. ",", "|")
     *   stringToSplit – List of raw address strings to process
     *
     * Output (FlowResponse per input string):
     *   splitedString  – Full list of tokens after splitting
     *   AddressLine1   – Token at index 0
     *   AddressLine2   – Token at index 1 (if present)
     *   AddressLine3   – Token at index 2 (if present)
     *   AddressLine4   – Token at index 3 (if present)
     *
     * @param flowParameters  List of FlowRequest objects supplied by Flow
     * @return                List of FlowResponse objects, one per input string
     */
@InvocableMethod
public static list<FlowResponse> splitStringBasedOnSeparator(list<FlowRequest> flowParameters){
    list<FlowResponse> flowResponse = new list<FlowResponse>();
    FlowResponse responseF = new FlowResponse();
    
    Map<Integer, String> fieldMap = new Map<Integer, String>{0=>'AddressLine1', 1=>'AddressLine2', 2=>'AddressLine3', 3=>'AddressLine4'};
    Integer i=0;
    System.debug('Size '+flowParameters[i].stringToSplit.size());
    if(flowParameters[0].stringToSplit.size() > 0){
        for(String text : flowParameters[0].stringToSplit){
            responseF.splitedString = text.split(flowParameters[0].separator);
            flowResponse.add(responseF);
            //i++;
        }
    }
    
    
    
    for(Integer k=0 ; k<flowResponse.size() ; k++){
        if(flowResponse[k].splitedString.size() > 0){
            for(Integer j=0 ; j<flowResponse[k].splitedString.size() ; j++){
                if(j==0){
                    flowResponse[k].AddressLine1 = flowResponse[k].splitedString[j];
                }else if(j==1){
                    flowResponse[k].AddressLine2 = flowResponse[k].splitedString[j];
                }else if(j==2){
                    flowResponse[k].AddressLine3 = flowResponse[k].splitedString[j];
                }else if(j==3){
                    flowResponse[k].AddressLine4 = flowResponse[k].splitedString[j];
                }
            }
        } 
    }
    return flowResponse;
}

    /** Input contract for splitStringBasedOnSeparator — supplied by Flow */
    public class FlowRequest{
        @InvocableVariable(required=true)
        public String separator;        // delimiter used to split the string (e.g. ",")

        @InvocableVariable(required=true)
        public list<String> stringToSplit;  // raw address strings to parse
    }

    /** Output contract for splitStringBasedOnSeparator — returned to Flow */
    public class FlowResponse{
        @InvocableVariable(required=true)
        public list<String> splitedString;  // all tokens from the split

        @InvocableVariable
        public String AddressLine1;     // token[0]

        @InvocableVariable
        public String AddressLine2;     // token[1]

        @InvocableVariable
        public String AddressLine3;     // token[2]

        @InvocableVariable
        public String AddressLine4;     // token[3]
    }

}//TriggerEnd
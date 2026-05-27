public without sharing class AccountPlanTeam_Controller {
    
    @AuraEnabled(cacheable=true)
    public static returnMessageWrapper getCurrentAccountPlanTeamMembers(String recordId, String accPlanName){
        returnMessageWrapper rmw = new returnMessageWrapper();
        List<AccountTeamMemberWrapper> result = new list<AccountTeamMemberWrapper>();
        String plan = '%' + accPlanName + '%';
        system.debug('inside get AT details');
        //Changes Start by Prachi SSE-21906
        
        try{
            Account_Plan__c apData = [Select id ,Account_Name__c , Buying_Centre_Id__c , Account_Plan_Type__c 
                                      from Account_Plan__c WHERE Id =:recordId ];
            List<AccountTeamMember> atmList = new List<AccountTeamMember>();
            Map<id,List<string>> roleMap = new Map<id,List<string>>();
            Map<id,List<string>> finalRoleMap = new Map<id,List<string>>();
            Set<Object[]> alreadySeenWrapper = new Set<Object[]>(); 
            
            if(apData.Account_Plan_Type__c == 'Current'){
                atmList = [
                    SELECT UserId, User.Name, User.Email, Id, TeamMemberRole, AccountId, Account_Plans__c ,Account.Account_Number__c
                    FROM AccountTeamMember
                    WHERE Account_Plans__c LIKE :plan
                    AND AccountId = :apData.Account_Name__c
                ]; 
            }
            else if(apData.Account_Plan_Type__c == 'Regional'){
                atmList = [
                    SELECT UserId, User.Name, User.Email, Id, TeamMemberRole, AccountId, Account_Plans__c ,Account.Account_Number__c
                    FROM AccountTeamMember
                    WHERE Account_Plans__c LIKE :plan
                    AND Account.Buying_Centre_Id__c = :apData.Buying_Centre_Id__c
                ]; 
            }
            else if(apData.Account_Plan_Type__c == 'Global'){
                Set<Id> allAccountIds = new Set<Id>{apData.Account_Name__c};
                    Set<Id> parentIds = new Set<Id>{apData.Account_Name__c};
                        List<Account> childAccounts = new List<Account>();
                do {
                    childAccounts = [SELECT Id FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                    parentIds.clear();
                    for (Account child : childAccounts){
                        parentIds.add(child.Id);
                        allAccountIds.add(child.Id);
                    }
                } while (childAccounts.size() > 0);
                atmList = [
                    SELECT UserId, User.Name, User.Email, Id, TeamMemberRole, AccountId, Account_Plans__c ,Account.Account_Number__c
                    FROM AccountTeamMember
                    WHERE Account_Plans__c LIKE :plan
                    AND AccountId IN :allAccountIds
                ]; 
 }
            
            if(!atmList.isEmpty()){
                for(AccountTeamMember relation : atmList){
                if(roleMap.get(relation.UserId)==null){
                List<String> roles = relation.TeamMemberRole !=null?relation.TeamMemberRole.split(';'):new List<String>();
                roleMap.put(relation.UserId,roles);
                     }
                else{
                List<String> roles = roleMap.get(relation.UserId);
                roles.addAll(relation.TeamMemberRole.split(';'));
                List<String> rolesToUse = new List<String>();
                for (String str : roles) {
                    if(!String.isBlank(str)&&!rolesToUse.contains(str)){
                        rolesToUse.add(str.trim());
                    }
                }
                roleMap.put(relation.UserId,rolesToUse);
            }
                }
                
            }
            
            
            //Changes End by Prachi SSE-21906
            if(!atmList.isEmpty()){
                String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                
                for (AccountTeamMember atm : atmList) {
                    Object[] key = new Object[]{atm.UserId};
                        if(!alreadySeenWrapper.contains(key)){
                            AccountTeamMemberWrapper rec = new AccountTeamMemberWrapper();        
                            rec.userId = atm.UserId;
                            rec.userName = atm.User.Name;
                            rec.userEmail = atm.User.Email;
                            rec.userUrl = sfdcBaseURL + '/' + atm.UserId;
                            rec.id = atm.Id;
                            rec.teamMemberRole = String.join(new List<String>(roleMap.get(atm.UserId)),';');
                            rec.accountId = atm.AccountId;
                            rec.accountPlanId = recordId;
                             rec.accountNumber =  atm.Account.Account_Number__c;
                              alreadySeenWrapper.add(key);          
                            result.add(rec);
                        }  
                    
                }
            }
            rmw.MessageType = 'Success';         
                 rmw.atmwList = result;
           
        }  
        catch(Exception ex){
             rmw.MessageType = 'Error';       
             rmw.Message = ex.getMessage();
             system.debug('inside catch' + ex.getMessage()); 
        }
        system.debug('inside get AT details2 ' + result);
        return rmw;
    }
    
    
    @AuraEnabled
    public static List<AccountTeamMemberWrapper> getAccountTeamMembers(String recordId, String accPlanName){
        List<AccountTeamMemberWrapper> result = new list<AccountTeamMemberWrapper>();
        String planName = '%' + accPlanName + '%';
        
        //Changes Start by Prachi SSE-21906
        Account_Plan__c apData = [Select id ,Account_Name__c , Buying_Centre_Id__c , Account_Plan_Type__c 
                                  from Account_Plan__c WHERE Id =:recordId ];
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        if(apData.Account_Plan_Type__c == 'Current'){
            atmList = [
                SELECT UserId, User.Name, User.Email, Id, TeamMemberRole, AccountId, Account_Plans__c ,
                Account.Account_Number__c
                FROM AccountTeamMember
                WHERE (NOT Account_Plans__c LIKE :planName)
                AND AccountId  = :apData.Account_Name__c
            ];
        }
        else if(apData.Account_Plan_Type__c == 'Regional'){
            atmList = [
                SELECT UserId, User.Name, User.Email, Id, TeamMemberRole, AccountId, Account_Plans__c ,
                Account.Account_Number__c
                FROM AccountTeamMember
                WHERE (NOT Account_Plans__c LIKE :planName)
                AND Account.Buying_Centre_Id__c = :apData.Buying_Centre_Id__c
            ]; 
        }
        else if(apData.Account_Plan_Type__c == 'Global'){
            Set<Id> allAccountIds = new Set<Id>{apData.Account_Name__c};
                Set<Id> parentIds = new Set<Id>{apData.Account_Name__c};
                    List<Account> childAccounts = new List<Account>();
            do {
                childAccounts = [SELECT Id FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                parentIds.clear();
                for (Account child : childAccounts){
                    parentIds.add(child.Id);
                    allAccountIds.add(child.Id);
                }
            } while (childAccounts.size() > 0);
            atmList = [
                SELECT UserId, User.Name, User.Email, Id, TeamMemberRole, AccountId, Account_Plans__c , Account.Account_Number__c
                FROM AccountTeamMember
                WHERE (NOT Account_Plans__c LIKE :planName)
                AND AccountId IN :allAccountIds
            ]; 
        }
        //Changes End by Prachi SSE-21906
        
        
        if(!atmList.isEmpty()){
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            for (AccountTeamMember atm : atmList) {
                AccountTeamMemberWrapper rec = new AccountTeamMemberWrapper();
                rec.userId = atm.UserId;
                rec.userName = atm.User.Name;
                rec.userEmail = atm.User.Email;
                rec.id = atm.Id;
                rec.teamMemberRole = atm.TeamMemberRole;
                rec.accountId = atm.AccountId;
                rec.accountPlanId = recordId;
                rec.userUrl = sfdcBaseURL + '/' + atm.UserId;
                rec.accountNumber =  atm.Account.Account_Number__c;
                result.add(rec);
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static List<AccountTeamMemberWrapper> getAllAccountTeamMembers(String recordId, String accPlanName){
        List<AccountTeamMemberWrapper> result = new list<AccountTeamMemberWrapper>();
        String planName = '%' + accPlanName + '%';
        List<AccountTeamMember> atmList = [
            SELECT UserId, User.Name, User.Email,Id, TeamMemberRole, AccountId, Account_Plans__c 
            FROM AccountTeamMember
            WHERE AccountId IN (SELECT Account_Name__c FROM Account_Plan__c WHERE Id =:recordId)
        ];
        
        if(!atmList.isEmpty()){
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            for (AccountTeamMember atm : atmList) {
                AccountTeamMemberWrapper rec = new AccountTeamMemberWrapper();
                rec.userId = atm.UserId;
                rec.userName = atm.User.Name;
                rec.userEmail = atm.User.Email;
                rec.id = atm.Id;
                rec.teamMemberRole = atm.TeamMemberRole;
                rec.accountId = atm.AccountId;
                rec.accountPlanId = recordId;
                rec.userUrl = sfdcBaseURL + '/' + atm.UserId;
                result.add(rec);
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static string linkAccountTeamMembers(String recordsIds, String accountPlanName){
        try{
        Set<Id> ids = (Set<Id>)JSON.deserialize(recordsIds, Set<Id>.class);
        
        List<AccountTeamMember> atmList = [
            SELECT Id, Account_Plans__c 
            FROM AccountTeamMember
            WHERE Id IN :ids
        ];
        
        for (AccountTeamMember atm : atmList) {
            
            if(atm.Account_Plans__c != '' && atm.Account_Plans__c != null) {
                atm.Account_Plans__c = atm.Account_Plans__c + ','+ accountPlanName;
            } else {
                atm.Account_Plans__c = accountPlanName;
            }
        }
        
        update atmList;
              return 'SUCCESS' ;
        }
        catch(Exception ex){
             return ex.getMessage() ;
        }
      
        
    }
    @AuraEnabled
    public static string saveAccountTeamMembers (String records){
        
        List<AccountTeamMember> newRecords = (List<AccountTeamMember>) JSON.deserialize(records,List<AccountTeamMember>.class);
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        system.debug(newRecords);
        
        upsert newRecords;
        
        return 'SUCCESS';
    }
    
    public class AccountTeamMemberWrapper{
        @AuraEnabled public String userId;
        @AuraEnabled public String userName;
        @AuraEnabled public String userEmail;
        @AuraEnabled public String userUrl;
        @AuraEnabled public String id;
        @AuraEnabled public String teamMemberRole;
        @AuraEnabled public String accountId;
        @AuraEnabled public String accountPlanId;
        @AuraEnabled public String accountNumber;
    }
    
     public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public List<AccountTeamMemberWrapper> atmwList;   
     }
    
    
    // @AuraEnabled
    // public static List<AccountTeamMemberWrapper> getAccountTeamMembers1(String recordId){
    
    //     List<AccountTeamMemberWrapper> result = new list<AccountTeamMemberWrapper>();
    //     Set<Id> usersIds = new Set<Id>();
    
    //     Account_Plan__c accPlan = [
    //         SELECT Account_Name__c, 
    //             (SELECT User__c, Account__c
    //             FROM Account_Plan_Team__r )
    //         FROM Account_Plan__c 
    //         WHERE Id =:recordId
    //     ];
    
    
    //     Account acc = [
    //         SELECT Id, 
    //             (   SELECT UserId, User.Name, Id, TeamMemberRole, AccountId, Account_Plan__c 
    //                 FROM AccountTeamMembers 
    //                 WHERE TeamMemberRole = 'Account Strategy'
    //                 AND UserId NOT IN ( SELECT User__c 
    //                                     FROM AccountPlanTeamMember__c 
    //                                     WHERE Account_Plan__c =: recordId ) 
    //             ) , 
    //             (   SELECT User__c, Account__c 
    //                 FROM Account_Plans_Team__r 
    //                 WHERE Account_Plan__c =: recordId )  
    //         FROM Account 
    //         WHERE Id IN (SELECT Account_Name__c FROM Account_Plan__c Where Id =:recordId)
    //     ];
    
    //             Account acc = [
    //                 SELECT Id, 
    //                     (   SELECT UserId, User.Name, Id, TeamMemberRole, AccountId, Account_Plan__c 
    //                         FROM AccountTeamMembers 
    //                         WHERE TeamMemberRole = 'Account Strategy'
    //                         AND UserId NOT IN ( SELECT User__c 
    //                                             FROM AccountPlanTeamMember__c 
    //                                             WHERE Account_Plan__c =: recordId ) 
    //                     )
    //                 FROM Account 
    //                 WHERE Id IN (SELECT Account_Name__c FROM Account_Plan__c Where Id =:recordId)
    //             ];
    //     List<AccountPlanTeamMember__c> aptmList = acc.Account_Plans_Team__r;
    //             List<AccountTeamMember> accTeamMembers = acc.AccountTeamMembers;
    //     [
    //         SELECT User__c, Account__c
    //         FROM AccountPlanTeamMember__c
    //         WHERE Account_Plan__c =:recordId
    //     ];
    
    //     if(!aptmList.isEmpty()){
    
    //         String AccountId = aptmList[0].Account__c;
    //         for (AccountPlanTeamMember__c aptm : aptmList) {
    //             usersIds.add(aptm.User__c);
    //         }
    //     }
    
    //     List<AccountTeamMember> accTeamMembers = [
    //         SELECT UserId, User.Name, Id, TeamMemberRole, AccountId, Account_Plan__c 
    //         FROM AccountTeamMember 
    //         WHERE AccountId=:accPlan.Account_Name__c 
    //         AND TeamMemberRole = 'Account Strategy'
    //         AND UserId NOT IN: usersIds
    //     ];
    
    //             if(!accTeamMembers.isEmpty()){
    //                 for (AccountTeamMember atm : accTeamMembers) {
    //                     AccountTeamMemberWrapper rec = new AccountTeamMemberWrapper();
    //                     rec.userId = atm.UserId;
    //                     rec.userName = atm.User.Name;
    //                     rec.id = atm.Id;
    //                     rec.teamMemberRole = atm.TeamMemberRole;
    //                     rec.accountId = atm.AccountId;
    //                     rec.accountPlanId = atm.Account_Plan__c;
    //                     result.add(rec);
    //                 }
    //             }
    
    //     return result;
    // }
    
    
}
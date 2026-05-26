public class AddAccountTeamMember implements Queueable{

    private list<TerritoryTriggerManager.AccountTeamWrapper> wrapperList;
    private String operationName;
    private Set<Id> territoryIdSet = new Set<Id>();
    private Set<Id> territoryIdSetWhereOwnerFieldChanges = new Set<Id>();
    private Set<Id> accountIdsSet = new Set<Id>();
    private Set<Id> accountIds = new Set<Id>();
    private Set<Id> accountIdsToQuery = new Set<Id>();
    private Map<Id, Account> accountMap = new Map<Id, Account>();
    //private Map<Id, Territory__c> territoryMap = new Map<Id, Territory__c>();
    private Map<Id, Id> accountIdToTerritoryIdMap = new Map<Id, Id>();
    private Map<String, Boolean> teamMemberDeletionMap = new Map<String, Boolean>();
    private list<AccountTeamMember> teamMembersList = new list<AccountTeamMember>();
    private list<AccountTeamMember> teamToDelete = new list<AccountTeamMember>();
    private Map<String, list<TerritoryTriggerManager.AccountTeamMemberWrapper>> territoryIdToTeamMembersDeletionMap = new Map<String, list<TerritoryTriggerManager.AccountTeamMemberWrapper>>();
    private Map<String, list<TerritoryTriggerManager.AccountTeamMemberWrapper>> territoryIdToTeamMembersMap = new Map<String, list<TerritoryTriggerManager.AccountTeamMemberWrapper>>();
 
    public AddAccountTeamMember(list<TerritoryTriggerManager.AccountTeamWrapper> accountTeamWrapperList, String operationName, Set<Id> accountIds){
        this.wrapperList = accountTeamWrapperList == null ? new list<TerritoryTriggerManager.AccountTeamWrapper>() : accountTeamWrapperList;
        this.operationName = operationName;
        this.accountIds = (accountIds == null) ? new Set<Id>() : accountIds;
    }
    
    public void execute(QueueableContext context) {
        //if (accountIds.isEmpty() && wrapperList != NULL) {
        if (accountIds.isEmpty() && wrapperList != null && !wrapperList.isEmpty()) {
            
            // Iterate over Wrapper list
            for(TerritoryTriggerManager.AccountTeamWrapper wrapper : wrapperList){
                //territoryIdSet.add(wrapper.territoryId);
                if(!wrapper.isOwnerChanged){
                    // Territory Id Set where Account Owner not changed
                    territoryIdSet.add(wrapper.territoryId);
                    // Populate Territory Id to AccountTeamMember Details Map to Add
                    territoryIdToTeamMembersMap.put(wrapper.territoryId, wrapper.accTeamMemberWrapper);
                    // Populate Territory Id to AccountTeamMember Details Map to Delete
                    territoryIdToTeamMembersDeletionMap.put(wrapper.territoryId, wrapper.deleteAccTeamMemberWrapper);   
                }else{
                    // Territory Id Set where Account Owner changed
                    territoryIdSetWhereOwnerFieldChanges.add(wrapper.territoryId);
                }
            }
        
            // Get all the Accounts linked to the Territory present in territoryIdSet
            if(!territoryIdSet.isEmpty()){
                list<Account> accountList = [SELECT Id, Name, OwnerId, Territory__c 
                                            FROM Account 
                                            WHERE Territory__c IN :territoryIdSet
                                            AND Status__c != 'Submitted for Approval'];
                for(Account acc : accountList){
                    // Populate Account Id to Territory Id Map
                    accountIdToTerritoryIdMap.put(acc.Id, acc.Territory__c);
                }
            }
        
            // Get all the Accounts whose owner has been updated and are linked to the Territory present in territoryIdSetWhereOwnerFieldChanges
            if(!territoryIdSetWhereOwnerFieldChanges.isEmpty()){
                list<Account> accountList = [SELECT Id, Name, OwnerId, Territory__c 
                                            FROM Account 
                                            WHERE Territory__c IN :territoryIdSetWhereOwnerFieldChanges];
                for(Account acc : accountList){
                    accountIdsSet.add(acc.Id);
                    accountMap.put(acc.Id, acc);
                }
            } 
            accountIdsToQuery = accountIdsSet;//accountIdToTerritoryIdMap.keySet();
        }else{
            
            accountIdsToQuery = accountIds;
        }
        
        if(operationName == 'Opportunity'){
            
            List<Opportunity> oppToUpdate = new List<Opportunity>();
            list<Opportunity> opportunityList = [SELECT Id, Name, OwnerId, AccountId, Account.OwnerId 
                                                 FROM Opportunity 
                                                 WHERE StageName != 'Closed/Won'
                                                 AND StageName != 'Closed Lost'
                                                 AND AccountId IN :accountIdsToQuery];
            
            
            for (Opportunity opp : opportunityList) {
                if (opp.OwnerId != opp.Account.OwnerId && opp.Account.OwnerId != null) {
                    opp.OwnerId = opp.Account.OwnerId;
                    oppToUpdate.add(opp);
                }
            }
            // Update Opportunity Owner same as their Account Owner
            if (!oppToUpdate.isEmpty()) {
                UPDATE oppToUpdate;
            }
            
            if (!accountIdsSet.isEmpty()) {
                // Delete previous Account Team Members and Add new Account Team Members based on Territory__c configuration
                //AccountTerritoryManagement.syncAccountTeams(accountIdsSet);
                // Chain next job for Account Team Member
                //System.enqueueJob(new AddAccountTeamMember(wrapperList, 'AccountTeamMember', accountIdsSet));   
            }
        }
        
        if(operationName == 'AccountTeamMember'){
            
            if(!accountIdToTerritoryIdMap.isEmpty()){
                for(Id accountId : accountIdToTerritoryIdMap.keySet()){
                    Id territoryId = accountIdToTerritoryIdMap.get(accountId);
                    if (territoryIdToTeamMembersMap.containsKey(territoryId)) {
                        for(TerritoryTriggerManager.AccountTeamMemberWrapper a : territoryIdToTeamMembersMap.get(territoryId)){
                            a.accountId = accountId;
                            addAccountTeamMemberInList(a.accountId, a.userId, a.role);
                        }
                    }
                    if (territoryIdToTeamMembersDeletionMap.containsKey(territoryId)) {
                        for(TerritoryTriggerManager.AccountTeamMemberWrapper a : territoryIdToTeamMembersDeletionMap.get(territoryId)){
                            String key = accountId + '-' + a.userId + '-' + a.role;
                            
                            teamMemberDeletionMap.put(key, true);
                        } 
                    } 
                }

                if(!teamMemberDeletionMap.isEmpty()){
                    for (AccountTeamMember atm : [SELECT Id, AccountId, UserId, TeamMemberRole 
                                                FROM AccountTeamMember 
                                                WHERE AccountId IN :accountIdToTerritoryIdMap.keySet()]){
                                                    String key = atm.AccountId + '-' + atm.UserId + '-' + atm.TeamMemberRole;
                                                    
                                                    if (teamMemberDeletionMap.containsKey(key)) {
                                                        teamToDelete.add(atm);
                                                        
                                                    }
                                                } 
                 }
            
                if(!teamToDelete.isEmpty()){
                    
                    DELETE teamToDelete;
                }
                
                if(!teamMembersList.isEmpty()){
                    
                    INSERT teamMembersList;
                }
            }

            if(!accountIdsSet.isEmpty()){
                deleteExistingAccountTeams(accountIdsSet);

                // Query Territories with user lookup fields
                Map<Id, Territory__c> territoryMap = new Map<Id, Territory__c>(
                    [
                        SELECT Id,
                            Account_Director__c,
                            Business_Development_Manager__c,
                            Customer_Engagement_Manager__c,
                            Global_Account_Director__c,
                            Manager_1__c,
                            Manager_2__c,
                            Manager_3__c
                        FROM Territory__c
                        WHERE Id IN :territoryIdSetWhereOwnerFieldChanges
                    ]
                );
                // Build and insert new Account Team Members
                List<AccountTeamMember> teamMembers = buildAccountTeamMembers(accountMap, territoryMap);

                if (!teamMembers.isEmpty()) {
                    insert teamMembers;
                }
            }
            
            if(!accountIdsSet.isEmpty()){
                // Chain next job for Opportunity Owner Update
                Id jobId = System.enqueueJob(new AddAccountTeamMember(wrapperList, 'Opportunity', null));
                
            }
            /*if(!accountIdsSet.isEmpty()){
                AccountTerritoryManagement.syncAccountTeams(accountIdsSet);
            }*/
        }
        
        
    }
    
    public void addAccountTeamMemberInList(Id accountId, Id userId, String role){
        teamMembersList.add(accountTeamMember(accountId, userId, role));
    }
    
    public static AccountTeamMember accountTeamMember(Id accountId, Id userId, String role){
        AccountTeamMember atm = new AccountTeamMember(
            AccountId = accountId,
            UserId = userId,
            TeamMemberRole = role,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit',
            ContactAccessLevel = 'Edit',
            CaseAccessLevel = 'Edit'
        );
        return atm; 
    }

    /**
     * Deletes all Account Team Members for the given Accounts.
     * Replace-not-diff strategy.
     */
    public static void deleteExistingAccountTeams(Set<Id> accountIds) {

        List<AccountTeamMember> existingMembers = [
            SELECT Id
            FROM AccountTeamMember
            WHERE AccountId IN :accountIds
        ];

        if (!existingMembers.isEmpty()) {
            delete existingMembers;
        }
    }

    /**
     * Builds Account Team Members using Territory user lookups.
     */
    public static List<AccountTeamMember> buildAccountTeamMembers(Map<Id, Account> accountMap, Map<Id, Territory__c> territoryMap) {

        List<AccountTeamMember> teamMembers = new List<AccountTeamMember>();

        for (Account acc : accountMap.values()) {

            Territory__c terr = territoryMap.get(acc.Territory__c);
            if (terr == null) {
                continue;
            }

            List<RoleAssignment> roleAssignments = new List<RoleAssignment>{
                new RoleAssignment('Account Director', terr.Account_Director__c),
                new RoleAssignment('Customer Engagement Manager', terr.Customer_Engagement_Manager__c),
                new RoleAssignment('Business Development Manager', terr.Business_Development_Manager__c),
                new RoleAssignment('Manager 1', terr.Manager_1__c),
                new RoleAssignment('Manager 2', terr.Manager_2__c),
                new RoleAssignment('Manager 3', terr.Manager_3__c),
                new RoleAssignment('Global Account Director', terr.Global_Account_Director__c)
            };

            for (RoleAssignment ra : roleAssignments) {
                    if (ra.userId == null) {
                    continue;
                }

                teamMembers.add(new AccountTeamMember(
                    AccountId = acc.Id,
                    UserId = ra.userId,
                    TeamMemberRole = ra.roleName,
                    AccountAccessLevel = 'Edit',
                    OpportunityAccessLevel = 'Edit',
                    ContactAccessLevel = 'Edit',
                    CaseAccessLevel = 'Edit'
                ));
            }
        }

        return teamMembers;
    }
    
    /*=========================================================================
     * Helper class to represent a Role → User assignment.
     * Allows multiple users to share the same role.
     *=======================================================================*/
    public class RoleAssignment {
        public String roleName;
        public Id userId;

        public RoleAssignment(String roleName, Id userId) {
            this.roleName = roleName;
            this.userId = userId;
        }
    }

    
}
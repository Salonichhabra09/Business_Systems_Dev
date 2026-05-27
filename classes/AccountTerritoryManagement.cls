/**
 * ----------------------------------------------------------------------------------------
 * Class Name     : AccountTerritoryManagement
 * Author         : Prabhat Arora
 * Created Date   : 15-01-2026
 * Purpose        : 
 * This class manages synchronization of Account Team Members based on the
 * Territory assigned to an Account. The Territory object is treated as the
 * source of truth for role-based user assignments (e.g., Account Director,
 * BDM, CEM, etc.).
 *
 * On Account insert or update, when a Territory is added or changed, this class:
 *  - Removes existing Account Team Members for the Account
 *  - Rebuilds the Account Team using user lookups from the related Territory
 *  - Assigns Read/Write access to both the Account and related Opportunities
 *
 * Design Notes :
 *  - Fully bulkified and safe for mass updates and data loads
 *  - Null-safe for optional Territory user fields
 *  - Uses a replace-not-diff strategy to ensure deterministic results
 * ----------------------------------------------------------------------------------------
 */
public class AccountTerritoryManagement {

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

    /**
     * Entry point from Account trigger.
     * Determines which Accounts need Account Team sync.
     */
    public static void handleAfterInsertUpdate(
        List<Account> newList,
        Map<Id, Account> oldMap
    ) {
        if (newList == null || newList.isEmpty()) {
            return;
        }

        Set<Id> accountIdsToProcess = new Set<Id>();

        for (Account acc : newList) {

            // INSERT: Territory present
            if (oldMap == null && acc.Territory__c != null) {
                accountIdsToProcess.add(acc.Id);
            }

            // UPDATE: Territory changed
            if (oldMap != null) {
                Account oldAcc = oldMap.get(acc.Id);

                if (acc.Territory__c != oldAcc.Territory__c) {
                    accountIdsToProcess.add(acc.Id);
                }
            }
        }

        if (!accountIdsToProcess.isEmpty()) {
            syncAccountTeams(accountIdsToProcess);
        }
    }

    /**
     * Main orchestration method.
     * Rebuilds Account Team Members based on Territory users.
     */
        public static void syncAccountTeams(Set<Id> accountIds) {

        // Query all Accounts (including those with Territory removed)
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [
                SELECT Id, Territory__c
                FROM Account
                WHERE Id IN :accountIds
            ]
        );

        if (accountMap.isEmpty()) {
            return;
        }

        // ALWAYS remove existing Account Team Members
        deleteExistingAccountTeams(accountIds);

        // Filter Accounts that still have a Territory
        Map<Id, Account> accountsWithTerritory = new Map<Id, Account>();
        Set<Id> territoryIds = new Set<Id>();

        for (Account acc : accountMap.values()) {
            if (acc.Territory__c != null) {
                accountsWithTerritory.put(acc.Id, acc);
                territoryIds.add(acc.Territory__c);
            }
        }

        // If no Accounts have a Territory, stop after delete
        if (accountsWithTerritory.isEmpty()) {
            return;
        }

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
                WHERE Id IN :territoryIds
            ]
        );
          /* START Changes by Aashi */  
            list<Account> accountsToUpdate = new list<Account>();
            for (Account acc : accountMap.values()) {
                if (acc.Territory__c != null) {
                    accountsWithTerritory.put(acc.Id, acc);
                    Id accountOwnerId = getOwnerFromPriority(territoryMap.get(accountsWithTerritory.get(acc.Id).Territory__c));
                    if(accountOwnerId != null){
                        acc.OwnerId = accountOwnerId;
                        accountsToUpdate.add(acc);
                    }
                }
            }
            if(!accountsToUpdate.isEmpty()){
                UPDATE accountsToUpdate;
            }
        /* END Changes by Aashi */  
            
        // Build and insert new Account Team Members
        List<AccountTeamMember> teamMembers =
            buildAccountTeamMembers(accountsWithTerritory, territoryMap);

            if (!teamMembers.isEmpty()) {
                insert teamMembers;
            }
            
            if (!accountIds.isEmpty()) {
                Id jobId = System.enqueueJob(new AddAccountTeamMember(null, 'Opportunity', accountIds));
                System.debug('Batch jobId -> '+ jobId);
            }
        }

    /**
     * Deletes all Account Team Members for the given Accounts.
     * Replace-not-diff strategy.
     */
    private static void deleteExistingAccountTeams(Set<Id> accountIds) {

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
    
    @TestVisible 
    private static List<AccountTeamMember> buildAccountTeamMembers(
        Map<Id, Account> accountMap,
        Map<Id, Territory__c> territoryMap
    ) {

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
    
    public static Id getOwnerFromPriority(Territory__c t) {
        if (t.Business_Development_Manager__c != null) return t.Business_Development_Manager__c;
        if (t.Account_Director__c != null) return t.Account_Director__c;
        if (t.Customer_Engagement_Manager__c != null) return t.Customer_Engagement_Manager__c;
        if (t.Manager_1__c != null) return t.Manager_1__c;
        if (t.Manager_2__c != null) return t.Manager_2__c;
        if (t.Manager_3__c != null) return t.Manager_3__c;
        return null;
    }
}
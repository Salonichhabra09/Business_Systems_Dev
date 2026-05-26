public class TerritoryTriggerManager {
    
    public static void handleAccountOwnerUpdate(List<Territory__c> TerritoryList, Map<Id,Territory__c> oldTerritoryMap){
        Map<Id, Id> territoryIdToAccountOwnerMap = new Map<Id, Id>();
        list<Account> accountOwnerUpdateList = new list<Account>();
        Id accountOwnerId;
        list<AccountTeamWrapper> wrapperList = new list<AccountTeamWrapper>();
        Map<Id, Boolean> territoryIdToIsOwnerChangedMap = new Map<Id, Boolean>();
        
        // Loop over territory records and get new Account and Opportunity as per Priority
        // Creating a territory Id to Account Owner Map
        for(Territory__c territory : TerritoryList){
            if((oldTerritoryMap == NULL && oldTerritoryMap.containsKey(territory.Id)) || territory.Business_Development_Manager__c != oldTerritoryMap.get(territory.Id).Business_Development_Manager__c
               || territory.Account_Director__c != oldTerritoryMap.get(territory.Id).Account_Director__c
               || territory.Customer_Engagement_Manager__c != oldTerritoryMap.get(territory.Id).Customer_Engagement_Manager__c
               || territory.Manager_1__c != oldTerritoryMap.get(territory.Id).Manager_1__c
               || territory.Manager_2__c != oldTerritoryMap.get(territory.Id).Manager_2__c
               || territory.Manager_3__c != oldTerritoryMap.get(territory.Id).Manager_3__c){
                   accountOwnerId = getOwnerFromPriority(territory);
                   if(accountOwnerId != NULL){
                       territoryIdToAccountOwnerMap.put(territory.Id, accountOwnerId); 
                   }
               }
        }
          
        // Fetch all accounts linked with the territory and create a list of accounts where owner need to be updated
        if(!territoryIdToAccountOwnerMap.isEmpty()){
            list<Account> accountList = [SELECT Id, Name, OwnerId, Territory__c 
                                            FROM Account 
                                            WHERE Territory__c IN :territoryIdToAccountOwnerMap.keySet() 
                                            AND Status__c != 'Submitted for Approval'];
            
            for(Account acc : accountList){
                Id newOwnerId = territoryIdToAccountOwnerMap.get(acc.Territory__c);
                if(acc.OwnerId != NULL && acc.OwnerId != newOwnerId){
                    acc.OwnerId = newOwnerId;
                    accountOwnerUpdateList.add(acc); 
                    if(!territoryIdToIsOwnerChangedMap.containsKey(acc.Territory__c)){
                        territoryIdToIsOwnerChangedMap.put(acc.Territory__c, true);
                    } 
                }else{
                    if(!territoryIdToIsOwnerChangedMap.containsKey(acc.Territory__c)){
                        territoryIdToIsOwnerChangedMap.put(acc.Territory__c, false);
                    }
                }
            }

            // Update Accounts
            if(!accountOwnerUpdateList.isEmpty()){
                UPDATE accountOwnerUpdateList;
            }
        }
        
        for(Territory__c territory : TerritoryList){
            String oldUserId;
            Boolean isOwnerChanged = false;
            Boolean isBDMBlank = true;
            Boolean isADBlank = true;
            Boolean isCEMBlank = true;
            Boolean isManager1Blank = true;
            Boolean isManager2Blank = true;
            Boolean isManager3Blank = true;
            AccountTeamWrapper wrapper = new AccountTeamWrapper();
            list<AccountTeamMemberWrapper> childWrapperList = new list<AccountTeamMemberWrapper>();
            list<AccountTeamMemberWrapper> childWrapperListDeletion = new list<AccountTeamMemberWrapper>();
            if(oldTerritoryMap != null && oldTerritoryMap.containsKey(territory.Id)){
                if(territoryIdToIsOwnerChangedMap.containsKey(territory.Id) && territoryIdToIsOwnerChangedMap.get(territory.Id)){
                    isOwnerChanged = true;
                }else{
                    isOwnerChanged = false;
                    
                    if(territory.Business_Development_Manager__c != oldTerritoryMap.get(territory.Id).Business_Development_Manager__c){
                        if(territory.Business_Development_Manager__c != null){
                            //childWrapperList.add(new AccountTeamMemberWrapper(null, territory.Business_Development_Manager__c, 'Business Development Manager'));
                        }
                        oldUserId = oldTerritoryMap.get(territory.Id).Business_Development_Manager__c;
                        if(territory.Business_Development_Manager__c == null || oldUserId != NULL){
                            childWrapperListDeletion.add(new AccountTeamMemberWrapper(null, oldUserId, 'Business Development Manager'));
                        }
                    }
                    if(territory.Account_Director__c != oldTerritoryMap.get(territory.Id).Account_Director__c){
                        if(territory.Account_Director__c != null){
                            childWrapperList.add(new AccountTeamMemberWrapper(null, territory.Account_Director__c, 'Account Director'));  
                        }
                        oldUserId = oldTerritoryMap.get(territory.Id).Account_Director__c;
                        if(territory.Account_Director__c == null || oldUserId != NULL){
                            childWrapperListDeletion.add(new AccountTeamMemberWrapper(null, oldUserId, 'Account Director'));
                        }
                    }
                    if(territory.Customer_Engagement_Manager__c != oldTerritoryMap.get(territory.Id).Customer_Engagement_Manager__c){
                        if(territory.Customer_Engagement_Manager__c != null){
                            childWrapperList.add(new AccountTeamMemberWrapper(null, territory.Customer_Engagement_Manager__c, 'Customer Engagement Manager'));
                        }
                        oldUserId = oldTerritoryMap.get(territory.Id).Customer_Engagement_Manager__c;
                        if(territory.Customer_Engagement_Manager__c == null || oldUserId != NULL){
                            childWrapperListDeletion.add(new AccountTeamMemberWrapper(null, oldUserId, 'Customer Engagement Manager'));
                        }  
                    }
                    if(territory.Manager_1__c != oldTerritoryMap.get(territory.Id).Manager_1__c){
                        if(territory.Manager_1__c != null){
                            childWrapperList.add(new AccountTeamMemberWrapper(null, territory.Manager_1__c, 'Manager 1'));
                        }
                        oldUserId = oldTerritoryMap.get(territory.Id).Manager_1__c;
                        if(territory.Manager_1__c == null || oldUserId != NULL){
                            childWrapperListDeletion.add(new AccountTeamMemberWrapper(null, oldUserId, 'Manager 1'));
                        }
                    }
                    if(territory.Manager_2__c != oldTerritoryMap.get(territory.Id).Manager_2__c){
                        if(territory.Manager_2__c != null){
                            childWrapperList.add(new AccountTeamMemberWrapper(null, territory.Manager_2__c, 'Manager 2'));   
                        }
                        oldUserId = oldTerritoryMap.get(territory.Id).Manager_2__c;
                        if(territory.Manager_2__c == null || oldUserId != NULL){
                            childWrapperListDeletion.add(new AccountTeamMemberWrapper(null, oldUserId, 'Manager 2'));
                        }
                    }
                    if(territory.Manager_3__c != oldTerritoryMap.get(territory.Id).Manager_3__c){
                        if(territory.Manager_3__c != null){
                            childWrapperList.add(new AccountTeamMemberWrapper(null, territory.Manager_3__c, 'Manager 3'));   
                        }
                        oldUserId = oldTerritoryMap.get(territory.Id).Manager_3__c;
                        if(territory.Manager_3__c == null || oldUserId != NULL){
                            childWrapperListDeletion.add(new AccountTeamMemberWrapper(null, oldUserId, 'Manager 3'));
                        } 
                    }
                    if(territory.Global_Account_Director__c != oldTerritoryMap.get(territory.Id).Global_Account_Director__c){
                        if(territory.Global_Account_Director__c != null){
                            childWrapperList.add(new AccountTeamMemberWrapper(null, territory.Global_Account_Director__c, 'Global Account Director'));   
                        }
                        oldUserId = oldTerritoryMap.get(territory.Id).Global_Account_Director__c;
                        if(territory.Global_Account_Director__c == null || oldUserId != NULL){
                            childWrapperListDeletion.add(new AccountTeamMemberWrapper(null, oldUserId, 'Global Account Director'));
                        } 
                    }
                }

                wrapper.territoryId = territory.Id;
                if(childWrapperList != NULL){
                    wrapper.accTeamMemberWrapper = childWrapperList;
                }
                if(childWrapperListDeletion != NULL){
                    wrapper.deleteAccTeamMemberWrapper = childWrapperListDeletion;
                }
                wrapper.isOwnerChanged = isOwnerChanged;
                wrapperList.add(wrapper);   
            }
        }
        
        if (!wrapperList.isEmpty()) {
            Id jobId = System.enqueueJob(new AddAccountTeamMember(wrapperList, 'AccountTeamMember', null));
        }
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
    
    public class AccountTeamMemberWrapper{
        public Id accountId { get; set; }
        public Id userId { get; set; }
        public String role { get; set; }
        
        // Constructor
        public AccountTeamMemberWrapper(Id accountId, Id userId, String role) {
            this.accountId = accountId;
            this.userId = userId;
            this.role = role;
        }
        
        public AccountTeamMemberWrapper(){}
        
    }
    
    public class AccountTeamWrapper{
        public Id territoryId { get; set; }
        public Boolean isOwnerChanged{ get; set; }
        public list<AccountTeamMemberWrapper> accTeamMemberWrapper{ get; set; }
        public list<AccountTeamMemberWrapper> deleteAccTeamMemberWrapper{ get; set; }
        
        public AccountTeamWrapper(){}
    }
    
    
}
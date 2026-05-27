/***********************************************************************************************************************************
* Created By: Jai Khandelwal                                                                                                       * 
* Description: This class is used to display the Strategy and goals data in Account Plan.Also this class handles the               *        
*              Account and Contact Relationship component present on the Strategy RecordPage                                       *
************************************************************************************************************************************/
public without sharing class StrategyAndGoalController {
    
    @AuraEnabled
    public static returnMessageWrapper getStrategyAndGoalsDetails(Id accountPlanId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        Integer count =0;
        try{
            List<Strategy_and_Goal__c> strategyData = [SELECT Id,Name,Approved__c,Strategy_Name__c,Strategy_Status__c,Strategy_Type__c,
                                                       Short_Long_Term__c,Estimated_Completion_Date__c,Solution_Product_Area__c,
                                                       Key_Contact_Sponsor__c,Key_Contact_Sponsor__r.Contact_Full_Name__c,
                                                       Account_Plan__r.Account_Name__c, InActive__c FROM Strategy_and_Goal__c 
                                                       WHERE Account_Plan__c=:accountPlanId and 
                                                       Strategy_Status__c NOT IN ('Completed - Failed','Completed - Partial Success','Completed - Success', 'Won - Partial Achievement','Won - Achieved Revenue Goals', 'No Opportunity', 'Strategy Expired')  
                                                       AND InActive__c = false
                                                       ORDER BY Approved__c,Estimated_Completion_Date__c];
            List<StrategyAndGoalWrapper> strategyList = new List<StrategyAndGoalWrapper>(); 
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            for (Strategy_and_Goal__c strategy : strategyData) {
                StrategyAndGoalWrapper wrap = new StrategyAndGoalWrapper();
                count=count+1;
                wrap.SNo = count;
                wrap.strategyUrl = sfdcBaseURL+'/'+strategy.Id;
                wrap.strategyId = strategy.Id;
                wrap.strategyName = strategy.Strategy_Name__c;
                if(strategy.Key_Contact_Sponsor__c!=null){
                    wrap.contactName = strategy.Key_Contact_Sponsor__r.Contact_Full_Name__c;
                    wrap.contactId = strategy.Key_Contact_Sponsor__c;
                    wrap.contactUrl = sfdcBaseURL+'/'+strategy.Key_Contact_Sponsor__c;
                }
                wrap.status = strategy.Strategy_Status__c;
                wrap.type = strategy.Strategy_Type__c;
                wrap.estimatedCompletionDate = strategy.Estimated_Completion_Date__c;
                wrap.term = strategy.Short_Long_Term__c;
                wrap.productSolution = strategy.Solution_Product_Area__c;
                wrap.accountId = strategy.Account_Plan__r.Account_Name__c;
                wrap.isApproved = strategy.Approved__c;
                wrap.id =strategy.Id;
                strategyList.add(wrap);
            }
            rmw.MessageType ='Success';
            rmw.Message = 'Strategy Data has been retrived successfully!';
            rmw.strategyList = strategyList;
        }catch (DMLException e) {
            String message = e.getDmlMessage(0);
            rmw.MessageType ='Error';
            rmw.Message = message;   
        } catch(Exception e){
            system.debug(e.getMessage());
            rmw.MessageType ='Error';
            rmw.Message = e.getMessage();  
        }      
        
        return rmw;
    }
    
    //SSE-20678(Account Planning Phase 2) 
    @AuraEnabled
    public static returnMessageWrapper getCompletedStrategyAndGoalsDetails(Id accountPlanId){
        Integer count =0;
        returnMessageWrapper rmw = new returnMessageWrapper();
        try{
            List<Strategy_and_Goal__c> strategyData = [SELECT Id, Name, Approved__c, Strategy_Name__c, Strategy_Status__c, Strategy_Type__c,
                                                   Short_Long_Term__c, Estimated_Completion_Date__c, Solution_Product_Area__c,
                                                   Key_Contact_Sponsor__c, Key_Contact_Sponsor__r.Contact_Full_Name__c,
                                                   Account_Plan__r.Account_Name__c, InActive__c
                                           FROM Strategy_and_Goal__c 
                                           WHERE Account_Plan__c = :accountPlanId 
                                           AND Strategy_Status__c IN ('Completed - Failed','Completed - Partial Success','Completed - Success', 'Won - Partial Achievement','Won - Achieved Revenue Goals', 'No Opportunity', 'Strategy Expired')  
                                           AND CreatedDate >= LAST_N_YEARS:5 
                                           AND InActive__c = false
                                           ORDER BY Approved__c, Estimated_Completion_Date__c];
            List<StrategyAndGoalWrapper> strategyList = new List<StrategyAndGoalWrapper>(); 
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            for (Strategy_and_Goal__c strategy : strategyData) {
                StrategyAndGoalWrapper wrap = new StrategyAndGoalWrapper();
                count=count+1;
                wrap.SNo = count;
                wrap.strategyUrl = sfdcBaseURL+'/'+strategy.Id;
                wrap.strategyId = strategy.Id;
                wrap.strategyName = strategy.Strategy_Name__c;
                if(strategy.Key_Contact_Sponsor__c!=null){
                    wrap.contactName = strategy.Key_Contact_Sponsor__r.Contact_Full_Name__c;
                    wrap.contactId = strategy.Key_Contact_Sponsor__c;
                    wrap.contactUrl = sfdcBaseURL+'/'+strategy.Key_Contact_Sponsor__c;
                }
                wrap.status = strategy.Strategy_Status__c;
                wrap.type = strategy.Strategy_Type__c;
                wrap.estimatedCompletionDate = strategy.Estimated_Completion_Date__c;
                wrap.term = strategy.Short_Long_Term__c;
                wrap.productSolution = strategy.Solution_Product_Area__c;
                wrap.accountId = strategy.Account_Plan__r.Account_Name__c;
                wrap.isApproved = strategy.Approved__c;
                strategyList.add(wrap);
            }
            rmw.MessageType ='Success';
            rmw.Message = 'Strategy Data has been retrived successfully!';
            rmw.strategyList = strategyList;
            
        }catch(DMLException e){
            String message = e.getDmlMessage(0);
            rmw.MessageType ='Error';
            rmw.Message = message;   
        }catch(Exception ex){
            rmw.MessageType ='Error';
            rmw.Message = ex.getMessage(); 
        }
        
        return rmw;
    }
    // Change End SSE-20678 (Account Planning Phase 2) 
    
    //SSE-20075 (Account Planning Phase 2) 
    @AuraEnabled
    public static returnMessageWrapper getActivityDetails(Id strategyId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        try{
            List<ActivitiesWrapper> actwList = new List<ActivitiesWrapper>();
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm(); 
            List<Task> taskList = [SELECT Subject, WhoId,  ActivityDate , Status, Priority, OwnerId ,Who.name,Owner.Name,createdDate
                                   FROM task where whatId=:strategyId and (not status like '%Complete%') order by ActivityDate ]; 
            List<Event> eventList = [SELECT Subject, WhoId,  EndDate , OwnerId , Status__c, Who.name,Owner.Name,createdDate,
                                     StartDateTime  FROM Event where whatId=:strategyId  and   Is_Completed__c=false
                                     and (not Status__c like '%Cancelled%') order by EndDate];
            if(taskList.size()>0){
                for(Task t: taskList){
                    
                    ActivitiesWrapper act = new ActivitiesWrapper();
                    if(t.Subject!= null){
                        act.ActivityName = t.Subject;
                        
                    }
                    else{
                        act.ActivityName = '[No Subject]';
                    }
                    act.ActivityURL = sfdcBaseURL+'/'+t.Id;
                    act.Status = t.Status;
                    act.DueDate = t.ActivityDate;
                    act.taskEvent=true;
                    act.ActivityType ='Task';
                     act.CreatedDate = t.createdDate;
                    if(t.WhoId!= null){
                        act.WhoId = t.Who.name; 
                        act.WhoIdURL = sfdcBaseURL+'/'+t.WhoId; 
                    }
                    act.ActivityId=t.id;
                    act.Owner = t.Owner.Name;
                    actwList.add(act);
                    
                }
            }
            if(eventList.size()>0){
                for(Event e: eventList){
                    ActivitiesWrapper act = new ActivitiesWrapper();
                    act.ActivityId=e.id;
                    if(e.Subject!= null){
                        act.ActivityName = e.Subject;
                        
                    }
                    else{
                        act.ActivityName = '[No Subject]';
                    }
                    act.ActivityURL = sfdcBaseURL+'/'+e.Id;
                    act.Status = e.Status__c;
                    act.DueDate = e.EndDate;
                    //act.WhoId = e.Who.name;
                    act.Owner = e.Owner.Name;
                    act.taskEvent= false;
                    act.ActivityType ='Event';
                    // act.WhoIdURL = sfdcBaseURL+'/'+e.WhoId;
                    if(e.WhoId!= null){
                        act.WhoId = e.Who.name; 
                        act.WhoIdURL = sfdcBaseURL+'/'+e.WhoId; 
                    }
                     act.CreatedDate = e.createdDate;
                    actwList.add(act);
                }
            }
            actwList.sort();//SSE-21114 (Account Planning Phase 3)
            rmw.MessageType ='Success';
            rmw.Message = 'Activity Data has been retrived successfully!';
            rmw.actList = actwList;
            
        }catch(DMLException e){
            String message = e.getDmlMessage(0);
            rmw.MessageType ='Error';
            rmw.Message = message;   
        }catch(Exception ex){
            rmw.MessageType ='Error';
            rmw.Message = ex.getMessage(); 
        }
        
        return rmw;
        
        
        
    }
    // Change End SSE-20075 (Account Planning Phase 2) 
    
    //SSE-21114 (Account Planning Phase 3) 
    @AuraEnabled
    public static returnMessageWrapper getAllActivityDetailsOnAccountPlan(Id accountPlanId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        Integer count=0;
        try{
            List<ActivitiesWrapper> actwList = new List<ActivitiesWrapper>();
            List<ActivitiesWrapper> openActList = new List<ActivitiesWrapper>();
            List<ActivitiesWrapper> completedActList = new List<ActivitiesWrapper>();
            List<ActivitiesWrapper> finalActivityWrapperList = new List<ActivitiesWrapper>();
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm(); 
            
            List<Strategy_and_Goal__c> stratList = [select id,Strategy_Name__c  from Strategy_and_Goal__c 
                                                              where Account_Plan__c = :accountPlanId and CreatedDate>=LAST_N_YEARS:5];
            List<Task> taskList = [SELECT Subject, WhoId,  ActivityDate , Status, Priority, OwnerId ,Who.name,Owner.Name,createdDate,what.id,what.name,whatId
                                   FROM task where whatId  in :stratList and (not Status like '%Cancelled%')
                                   and CreatedDate>=LAST_N_YEARS:5 order by ActivityDate];
            
            List<Event> eventList = [SELECT Subject, WhoId,  EndDate , OwnerId , Status__c, Who.name,Owner.Name,createdDate,Is_Completed__c,what.id,what.name,whatId,
                                     StartDateTime  FROM Event where whatId in :stratList and (not Status__c like '%Cancelled%')
                                     order by EndDate];
            
            if(taskList.size()>0){
                for(Task t: taskList){
                    
                    ActivitiesWrapper act = new ActivitiesWrapper();
                    if(t.Subject!= null){
                        act.ActivityName = t.Subject;
                        
                    }
                    else{
                        act.ActivityName = '[No Subject]';
                    }
                    act.ActivityURL = sfdcBaseURL+'/'+t.Id;
                    act.Status = t.Status;
                    act.DueDate = t.ActivityDate;
                    act.taskEvent=true;
                    act.ActivityType ='Task';
                    if(t.WhoId!= null){
                        act.WhoId = t.Who.name; 
                        act.WhoIdURL = sfdcBaseURL+'/'+t.WhoId; 
                    }
                    
                    act.Owner = t.Owner.Name;
                    act.CreatedDate = t.createdDate;
                    act.strategyURL=sfdcBaseURL+'/'+t.whatId;
                    act.strategyId=t.whatId;
                    for(Strategy_and_Goal__c s:stratList ){
                        if(t.whatId == s.id ){
                             act.strategyName=s.Strategy_Name__c; 
                        } 
                      
                    }
                   
                    actwList.add(act);
                    
                }
            }
            if(eventList.size()>0){
                for(Event e: eventList){
                    ActivitiesWrapper act = new ActivitiesWrapper();
                    if(e.Subject!= null){
                        act.ActivityName = e.Subject;
                        
                    }
                    else{
                        act.ActivityName = '[No Subject]';
                    }
                    act.ActivityURL = sfdcBaseURL+'/'+e.Id;
                    if(e.Is_Completed__c == true){
                         act.Status = 'Completed';
                    }
                    else if(e.Is_Completed__c == false){
                         act.Status = 'Open';
                    }
                   
                    act.DueDate = e.EndDate;
                    //act.WhoId = e.Who.name;
                    act.Owner = e.Owner.Name;
                    act.taskEvent= false;
                    act.ActivityType ='Event';
                    act.CreatedDate = e.createdDate;
                    act.isCompleted=e.Is_Completed__c;
                    // act.WhoIdURL = sfdcBaseURL+'/'+e.WhoId;
                    if(e.WhoId!= null){
                        act.WhoId = e.Who.name; 
                        act.WhoIdURL = sfdcBaseURL+'/'+e.WhoId; 
                    }
                    act.strategyURL=sfdcBaseURL+'/'+e.whatId;
                    act.strategyId=e.whatId;
                     for(Strategy_and_Goal__c s:stratList ){
                        if(e.whatId == s.id ){
                             act.strategyName=s.Strategy_Name__c; 
                        } 
                      
                    }
                    actwList.add(act);
                }
            }
            for(ActivitiesWrapper aw:actwList){
                if(aw.ActivityType == 'Event'){
                    if(!aw.isCompleted){
                        openActList.add(aw);
                    }
                }
                else if(aw.ActivityType == 'Task'){
                    if(!aw.Status.contains('Complete') && !aw.Status.contains('Cancell')){
                        openActList.add(aw);
                    }
                }
            }
            openActList.sort();
            
            for(ActivitiesWrapper aw:actwList){
                 if(aw.ActivityType == 'Event'){
                    if(aw.isCompleted){
                        completedActList.add(aw);
                    }
                }
                else if(aw.ActivityType == 'Task'){
                if(aw.Status.contains('Complete') || aw.Status.contains('Cancell')){
                    completedActList.add(aw);
                }
                }
            }
            completedActList.sort();
            
            for(ActivitiesWrapper aw:openActList){
                count++;
                aw.SNo = count;
                finalActivityWrapperList.add(aw);
                
            }
            
            
            for(ActivitiesWrapper aw:completedActList){
                count++;
                aw.SNo = count;
                finalActivityWrapperList.add(aw);
                
            }
            
            
            
            rmw.MessageType ='Success';
            rmw.Message = 'Activity Data has been retrived successfully!';
            rmw.actList = finalActivityWrapperList;
            
        }catch(DMLException e){
            String message = e.getDmlMessage(0);
            rmw.MessageType ='Error';
            rmw.Message = message;   
        }catch(Exception ex){
            rmw.MessageType ='Error';
            rmw.Message = ex.getMessage(); 
        }
        
        return rmw;
    }
    // Change End SSE-21114 (Account Planning Phase 3)    
    @AuraEnabled
    public static returnMessageWrapper getOpportunityDetails(Id accountId,Id strategyId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        try{
            String accountIdToUse ='';
            //Change start SSE-21662
            List<Strategy_and_Goal__c> strategyData = [Select id,Account_Plan__r.Account_Name__c,Account_Plan__r.Account_Plan_Type__c,Account_Plan__r.Buying_Centre_Id__c FROM Strategy_and_Goal__c WHERE id =:strategyId];
            String accountPlanType = strategyData[0].Account_Plan__r.Account_Plan_Type__c;
            String buyingCentreId = strategyData[0].Account_Plan__r.Buying_Centre_Id__c;
            if(accountId==null){
                accountIdToUse = strategyData[0].Account_Plan__r.Account_Name__c;
            }else{
                accountIdToUse = accountId;
            }
            UserRecordAccess checkAccountAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =:accountIdToUse];
            if(checkAccountAccess.HasEditAccess==true){
                List<Opportunity> oppData = new List<Opportunity>();
            if(accountPlanType=='Regional'){
                List<Account> accList = [SELECT Id FROM Account WHERE Buying_Centre_Id__c= :buyingCentreId];
                List<Id> accIds = new List<Id>();
                for (Account acc : accList) {
                    accIds.add(acc.Id);
                }
                oppData = [SELECT Id,Name,Account.Account_Number__c,OpportunityId__c,Strategy_and_Goals__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems) From Opportunity where AccountId IN :accIds AND StageName NOT IN ('Closed/Won','Closed Lost') AND (Strategy_and_Goals__c=null OR Strategy_and_Goals__c= :strategyId) ORDER BY CloseDate];
            }else if(accountPlanType=='Current'){
                oppData = [SELECT Id,Name,Account.Account_Number__c,OpportunityId__c,Strategy_and_Goals__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems) From Opportunity where AccountId=:accountIdToUse AND StageName NOT IN ('Closed/Won','Closed Lost') AND (Strategy_and_Goals__c=null OR Strategy_and_Goals__c= :strategyId) ORDER BY CloseDate];
            }else if(accountPlanType=='Global'){
                Set<Id> allAccountIds = new Set<Id>{accountIdToUse};
                Set<Id> parentIds = new Set<Id>{accountIdToUse};
                List<Account> childAccounts = new List<Account>();
                do {
                    childAccounts = [SELECT Id FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                    parentIds.clear();
                    for (Account child : childAccounts){
                        parentIds.add(child.Id);
                        allAccountIds.add(child.Id);
                    }
                } while (childAccounts.size() > 0);
                // List<Account> accList = [SELECT Id FROM Account WHERE ParentId= :accountIdToUse];
                // List<Id> accIds = new List<Id>();
                // for (Account acc : accList) {
                //     accIds.add(acc.Id);
                // }
                oppData = [SELECT Id,Name,Account.Account_Number__c,OpportunityId__c,Strategy_and_Goals__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems) From Opportunity where AccountId IN :allAccountIds AND StageName NOT IN ('Closed/Won','Closed Lost') AND (Strategy_and_Goals__c=null OR Strategy_and_Goals__c= :strategyId) ORDER BY CloseDate];
            }
            List<OpportunityWrapper> notLinkedOppList = new List<OpportunityWrapper>(); 
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            for (Opportunity opp : oppData) {
                OpportunityWrapper wrap = new OpportunityWrapper();
                wrap.opportunityName = opp.Name;
                wrap.oppId = opp.Opportunity_ID18__c;
                wrap.amount = opp.Amount;
                wrap.nextStep = opp.NextStep;
                wrap.stageName = opp.StageName;
                wrap.closeDate = opp.CloseDate;
                wrap.contractLength = opp.Multi_YearDeal__c;
                wrap.divisionDetails = opp.Account_LBU__c+'/'+opp.Account.Global_Billing_Country__c+'/'+opp.Client_Business_Function__c;
                if(opp.Strategy_and_Goals__c!=null){
                    wrap.isStrategyLinked = true;
                }
                wrap.dNumber = opp.Account.Account_Number__c;
                notLinkedOppList.add(wrap);
            }
            
            	rmw.MessageType ='Success';
            	rmw.Message = 'Opportunity Data has been retrived successfully!';
            	rmw.oppList = notLinkedOppList;
            }else{
                rmw.MessageType ='NoAccess';
            	rmw.Message = 'You do not have access to link/delink opportunity with this Strategy. Please contact system administrator for further assistance.';
            }
            
        }catch(DMLException e){
            String message = e.getDmlMessage(0);
            rmw.MessageType ='Error';
            rmw.Message = message;   
        }catch(Exception ex){
            rmw.MessageType ='Error';
            rmw.Message = ex.getMessage(); 
        }
        
        return rmw;
    }
    
    @AuraEnabled
    public static returnMessageWrapper linkOrDelinkOpportunities(Id strategyId,List<Id> opportunityIdsToLink,List<Id> opportunityIdsToDelink,Integer totalOpportunitiesLinked){
        returnMessageWrapper rmw = new returnMessageWrapper();
        try{
            List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
            
            for (Id oppId : opportunityIdsToLink) {
                opportunity opp =  new opportunity();
                opp.Id = oppId;
                opp.Strategy_and_Goals__c = strategyId;
                opportunityListToUpdate.add(opp);
            }
            for (Id oppId : opportunityIdsToDelink) {
                opportunity opp =  new opportunity();
                opp.Id = oppId;
                opp.Strategy_and_Goals__c = null;
                opportunityListToUpdate.add(opp);
            }
            
            Strategy_and_Goal__c strategy = new Strategy_and_Goal__c();
            strategy.Id = strategyId;
            strategy.Opportunities_Linked__c = totalOpportunitiesLinked;
            
            update opportunityListToUpdate;
            update strategy;
            rmw.MessageType ='Success';
            rmw.Message = 'Opportunity has been linked/delinked successfully!';
            
        }catch(DMLException e){
            String message = e.getDmlMessage(0);
            rmw.MessageType ='Error';
            rmw.Message = message;   
        }catch(Exception ex){
            rmw.MessageType ='Error';
            rmw.Message = ex.getMessage(); 
        }
        
        return rmw;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static AccConRelationshipDetailsWrapper getStrategyRelationshipDetails(Id strategyId){
        
        List<Strategy_and_Goal__c> strategyData = [SELECT Id,Name,Account_Plan__r.Account_Name__c,
                                                   Account_Plan_Status__c,Account_Contact_Relations__c 
                                                   FROM Strategy_and_Goal__c WHERE Id=:strategyId];
        String strategyName= '%'+strategyData[0].Name+'%';
        Id accountId = strategyData[0].Account_Plan__r.Account_Name__c;
        AccConRelationshipDetailsWrapper wrapperToReturn = new AccConRelationshipDetailsWrapper();
        List<Id> relationshipIds = new List<Id>();
        if(strategyData[0].Account_Contact_Relations__c!=null){
            relationshipIds = strategyData[0].Account_Contact_Relations__c.split(';');
        }
        List<AccountContactRelationshipWrapper> relationshipList = new List<AccountContactRelationshipWrapper>(); 
        List<AccountContactRelation> relationshipData = [Select Id,roles,contactId,contact.name,
                                                         contact.Advocacy_Level__c,//Added by Prachi SSE-20682
                                                         strategies__c FROM AccountContactRelation WHERE Id IN :relationshipIds];
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Map<Id,List<String>> roleMap = new Map<Id,List<String>>();
        for (AccountContactRelation relation : relationshipData) {
            if(roleMap.get(relation.contactId)==null){
                List<String> roles = relation.roles!=null?relation.roles.split(';'):new List<String>();
                roleMap.put(relation.contactId,roles);
            }else{
                List<String> roles = roleMap.get(relation.contactId);
                roles.addAll(relation.roles.split(';'));
                List<String> rolesToUse = new List<String>();
                for (String str : roles) {
                    if(!String.isBlank(str)&&!rolesToUse.contains(str)){
                        rolesToUse.add(str.trim());
                    }
                }
                roleMap.put(relation.contactId,rolesToUse);
            }
        }
        List<Id> contactIds = new List<Id>();
        for (AccountContactRelation relation : relationshipData) {
            if(!contactIds.contains(relation.contactId)){
            AccountContactRelationshipWrapper wrap = new AccountContactRelationshipWrapper();
            wrap.contactName = relation.contact.name;
            wrap.linkToContact = sfdcBaseURL+'/'+relation.contactId;
            wrap.roles = String.join(new List<String>(roleMap.get(relation.contactId)),';');
            wrap.relationshipId = relation.Id;
            wrap.accountId = accountId;
            wrap.strategyName = strategyData[0].Name;
            wrap.AdvocacyLevel = relation.contact.Advocacy_Level__c;//Added By Prachi SSE-20682
            wrap.contactId = relation.contactId;//Added By Prachi SSE-20682
            relationshipList.add(wrap);
            contactIds.add(relation.contactId);
            }
        }
        UserRecordAccess checkRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =:strategyId];
        if(strategyData[0].Account_Plan_Status__c=='In Review' || checkRecordAccess.HasEditAccess==false){
            wrapperToReturn.isAccountPlanUnderReview = true;
        }else{
            wrapperToReturn.isAccountPlanUnderReview = false;
        }
        wrapperToReturn.strategyName = strategyData[0].Name;
        wrapperToReturn.accountId = accountId;
        wrapperToReturn.relationshipData = relationshipList;
        
        Map<String,PicklistWrapper> picklistMap = new Map<String,PicklistWrapper>();
        Map<String,PicklistWrapper> picklistMapSorted = new Map<String,PicklistWrapper>();
        Schema.DescribeFieldResult roles = AccountContactRelation.Roles.getDescribe();
        // Get picklist values from field description
        List<Schema.PicklistEntry> rolesValues = roles.getPicklistValues();
        // Do something with entries
        List<String> rolePicklist = new List<String>();
        List<PicklistWrapper> listRoles = new List<PicklistWrapper>();
        for (Schema.PicklistEntry entry : rolesValues) {
            PicklistWrapper pick = new PicklistWrapper();
            if(entry.isActive()){
                pick.label = entry.getLabel();
                pick.value = entry.getValue();
                listRoles.add(pick);
            }
            picklistMap.put(entry.label,pick);
        }
        rolePicklist.addAll(picklistMap.keySet());
        rolePicklist.sort();
        for (String role : rolePicklist) {
            picklistMapSorted.put(role,picklistMap.get(role));
        }
        wrapperToReturn.rolePicklist = picklistMapSorted.values();
        return wrapperToReturn;
    }
    
    @AuraEnabled
    public static returnMessageWrapper getRelationshipDetails(Id accountId,Id strategyId){
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        try{
            List<Strategy_and_Goal__c> strategyData = [SELECT Id,Name,Account_Plan__r.Account_Name__c,Account_Contact_Relations__c,Account_Plan__r.Account_Plan_Type__c,Account_Plan__r.Buying_Centre_Id__c FROM Strategy_and_Goal__c WHERE Id= :strategyId];
            List<AccountContactRelationshipWrapper> relationshipList = new List<AccountContactRelationshipWrapper>(); 
            List<AccountContactRelation> relationshipData = new List<AccountContactRelation>();
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            String accountPlanType = strategyData[0].Account_Plan__r.Account_Plan_Type__c;
            String buyingCentreId = strategyData[0].Account_Plan__r.Buying_Centre_Id__c;
            if(accountPlanType=='Regional'){
                List<Account> accList = [SELECT Id FROM Account WHERE Buying_Centre_Id__c= :buyingCentreId];
                List<Id> accIds = new List<Id>();
                for (Account acc : accList) {
                    accIds.add(acc.Id);
                }
                relationshipData = [Select Id,roles,contactId,contact.name,Account.Account_Number__c
                                    FROM AccountContactRelation WHERE accountId IN :accIds];
            }else if(accountPlanType=='Current'){
                relationshipData = [Select Id,roles,contactId,contact.name,Account.Account_Number__c FROM AccountContactRelation WHERE accountId=:accountId];
            }else if(accountPlanType=='Global'){
                Set<Id> allAccountIds = new Set<Id>{accountId};
                Set<Id> parentIds = new Set<Id>{accountId};
                List<Account> childAccounts = new List<Account>();
                do {
                    childAccounts = [SELECT Id FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                    parentIds.clear();
                    for (Account child : childAccounts){
                        parentIds.add(child.Id);
                        allAccountIds.add(child.Id);
                    }
                } while (childAccounts.size() > 0);
                // List<Account> accList = [SELECT Id FROM Account WHERE ParentId= :accountIdToUse];
                // List<Id> accIds = new List<Id>();
                // for (Account acc : accList) {
                //     accIds.add(acc.Id);
                // }
                relationshipData = [Select Id,roles,contactId,contact.name,Account.Account_Number__c
                                    FROM AccountContactRelation WHERE accountId IN :allAccountIds];
            }
            for (AccountContactRelation relation : relationshipData) {
                AccountContactRelationshipWrapper wrap = new AccountContactRelationshipWrapper();
                wrap.contactName = relation.contact.name;
                wrap.linkToContact = sfdcBaseURL+'/'+relation.contactId;
                List<String> roleList = new List<String>();
                if(relation.roles!=null){
                    roleList = relation.roles.split(';');
                    roleList.sort();
                }
                String roles = String.join(roleList,';');
                wrap.roles = roles;
                wrap.rolesToUse = roles;
                wrap.relationshipId = relation.Id;
                wrap.Id = relation.Id;
                if(strategyData[0].Account_Contact_Relations__c!=null && strategyData[0].Account_Contact_Relations__c.contains(relation.Id)){
                    wrap.isStrategyLinked = true;
                }
                wrap.dNumber = relation.Account.Account_Number__c;
                relationshipList.add(wrap);
            }
            wrapperToReturn.MessageType = 'Success';
            wrapperToReturn.relationshipList = relationshipList;
        }catch (DMLException e) {
            String message = e.getDmlMessage(0);
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        } catch(Exception e){
            system.debug(e.getMessage());
        }      
        return wrapperToReturn;
    }
    
    @AuraEnabled
    public static returnMessageWrapper addNewRelationshipToStrategy(Id strategyId,Id relationshipId){
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        try{
            List<Strategy_and_Goal__c> strategyData = [SELECT Id,Name,Account_Plan__r.Account_Name__c,Account_Contact_Relations__c FROM Strategy_and_Goal__c WHERE Id= :strategyId];
            String relationshipIds = strategyData[0].Account_Contact_Relations__c;
            if(relationshipIds!=null){
                relationshipIds += ';'+relationshipId;
            }else{
                relationshipIds = relationshipId;
            }
            Strategy_and_Goal__c strategyToUpdate = new Strategy_and_Goal__c();
            strategyToUpdate.Id = strategyId;
            strategyToUpdate.Account_Contact_Relations__c = relationshipIds;
            
            update strategyToUpdate;
            
            wrapperToReturn.MessageType = 'Success';
        }catch (DMLException e) {
            String message = e.getDmlMessage(0);
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        } 
        
        return wrapperToReturn;
    }
    
    @AuraEnabled
    public static returnMessageWrapper addOrRemoveRelationship(Id strategyId,List<Id> selectedRelationships,List<AccountContactRelationshipWrapper> relationshipList){
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        try{
            List<Strategy_and_Goal__c> strategyData = [SELECT Id,Name,Account_Plan__r.Account_Name__c,Account_Contact_Relations__c FROM Strategy_and_Goal__c WHERE Id= :strategyId];
            
            List<AccountContactRelation> relationshipListToUpdate = new List<AccountContactRelation>();
            Strategy_and_Goal__c strategyToUpdate = new Strategy_and_Goal__c();
            List<Id> currentRelationships = new List<Id>();
            if(strategyData[0].Account_Contact_Relations__c!=null){
                currentRelationships = strategyData[0].Account_Contact_Relations__c.split(';');
                currentRelationships.sort();
            }
            if(selectedRelationships!=null){
                selectedRelationships.sort();
            }
            if(currentRelationships!=selectedRelationships && selectedRelationships.size()>0){
                strategyToUpdate.Id = strategyId;
                strategyToUpdate.Account_Contact_Relations__c = String.join(selectedRelationships,';');
                
                update strategyToUpdate;
            }
            if(relationshipList!=null){
                for (AccountContactRelationshipWrapper relation : relationshipList) {
                    if(relation.roles!=relation.rolesToUse){
                        AccountContactRelation temp = new AccountContactRelation();
                        temp.Id = relation.relationshipId;
                        temp.Roles = relation.rolesToUse;
                        relationshipListToUpdate.add(temp);
                    }
                }
            }
            if(relationshipListToUpdate.size()>0){
                update relationshipListToUpdate;
            }
            
            wrapperToReturn.MessageType = 'Success';
        }catch (DMLException e) {
            String message = e.getDmlMessage(0);
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        } 
        return wrapperToReturn;
    }
    
    
    
    public class StrategyAndGoalWrapper{
        
        @AuraEnabled public String strategyName { get; set; }
        @AuraEnabled public Integer SNo { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String strategyUrl { get; set; }
        @AuraEnabled public String strategyId { get; set; }
        @AuraEnabled public Date estimatedCompletionDate { get; set; }
        @AuraEnabled public String contactName { get; set; }
        @AuraEnabled public String contactId { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String contactUrl { get; set; }
        @AuraEnabled public String productSolution { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String term { get; set; }
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public Boolean isApproved {get; set; }
        
    }
    
    public class OpportunityWrapper{
        
        @AuraEnabled public String opportunityName;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Date closeDate;
        @AuraEnabled public String stageName;
        @AuraEnabled public String contractLength;
        @AuraEnabled public String solution;
        @AuraEnabled public String divisionDetails;
        @AuraEnabled public String nextStep;
        @AuraEnabled public String oppId;
        @AuraEnabled public Integer serialNumber;
        @AuraEnabled public String opportunityUrl;
        @AuraEnabled public Boolean isStrategyLinked;
        @AuraEnabled public String dNumber;
    }
    
    public class AccountContactRelationshipWrapper{
        
        @AuraEnabled public String contactName {get; set; }
        @AuraEnabled public String  AdvocacyLevel {get; set;}//Added By Prachi SSE-20682
        @AuraEnabled public String contactId {get; set;}//Added By Prachi SSE-20682
        @AuraEnabled public String relationshipId {get; set; }
        @AuraEnabled public String linkToContact {get; set; }
        @AuraEnabled public String roles {get; set; }
        @AuraEnabled public String accountId {get; set; }
        @AuraEnabled public String strategyName {get; set; }
        @AuraEnabled public Boolean isStrategyLinked {get; set; }
        @AuraEnabled public String rolesToUse {get; set; }
        @AuraEnabled public Id Id {get; set; }
        @AuraEnabled public String dNumber {get; set; }
    }
    
    public class AccConRelationshipDetailsWrapper{
        
        @AuraEnabled public List<AccountContactRelationshipWrapper> relationshipData;
        @AuraEnabled public String accountId;
        @AuraEnabled public String strategyName;
        @AuraEnabled public Boolean isAccountPlanUnderReview;
        @AuraEnabled public List<PicklistWrapper> rolePicklist;
        
    }
    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public List<AccountContactRelationshipWrapper> relationshipList;
        @AuraEnabled public List<OpportunityWrapper> oppList;
        @AuraEnabled public List<StrategyAndGoalWrapper> strategyList;
        @AuraEnabled public List<ActivitiesWrapper> actList;//SSE-20075 (Account Planning Phase 2) 
        
    }
    public class PicklistWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    //SSE-20075 (Account Planning Phase 2)   
    /*  public class ActivitiesWrapper{
@AuraEnabled public String ActivityName { get; set; }
@AuraEnabled public String ActivityURL { get; set; }
@AuraEnabled public String Status { get; set; }
@AuraEnabled public Date   DueDate { get; set; }
@AuraEnabled public String WhoId { get; set; }
@AuraEnabled public String WhoIdURL { get; set; }
@AuraEnabled public String Owner { get; set; }
@AuraEnabled public String ActivityType { get; set; }
@AuraEnabled public Boolean taskEvent { get; set; }
@AuraEnabled public Integer SNo{get; set;}

}*/
    
    public class ActivitiesWrapper implements Comparable {
        
        @AuraEnabled public String ActivityName ;
        @AuraEnabled public String ActivityURL ;
        @AuraEnabled public String Status; 
        @AuraEnabled public Date   DueDate ;
        @AuraEnabled public String WhoId ;
        @AuraEnabled public String WhoIdURL ;
        @AuraEnabled public String Owner ;
        @AuraEnabled public String ActivityType ;
        @AuraEnabled public Boolean taskEvent ;
        @AuraEnabled public Integer SNo;
        @AuraEnabled public String ActivityId;
        @AuraEnabled public DateTime CreatedDate;
        @AuraEnabled public Boolean isCompleted;
        @AuraEnabled public String strategyName;
        @AuraEnabled public String strategyURL;
        @AuraEnabled public String strategyId;
        
        public ActivitiesWrapper(){}
        // Constructor
        public ActivitiesWrapper(String ActivityURL, String Status,String ActivityName,  String ActivityId,Boolean isCompleted,
                                 Date DueDate,String WhoId, String WhoIdURL, String Owner,String ActivityType,Boolean taskEvent,String strategyName,String strategyURL, String strategyId,
                                 Integer SNo,DateTime CreatedDate ) {
                                     ActivityURL = ActivityURL;
                                     Status = Status;
                                     ActivityName = ActivityName;
                                     DueDate = DueDate;
                                     WhoId=WhoId;
                                     WhoIdURL=WhoIdURL;
                                     Owner=Owner;
                                     ActivityType=ActivityType;
                                     taskEvent=taskEvent;
                                     SNo=SNo;
                                     CreatedDate=CreatedDate;
                                     ActivityId=ActivityId;
                                     isCompleted=isCompleted;
                                     strategyURL=strategyURL;
                                     strategyId=strategyId;
                                     strategyName=strategyName;
                                     
                                 }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            ActivitiesWrapper compareToEmp = (ActivitiesWrapper)compareTo;
            if ( CreatedDate == compareToEmp.CreatedDate) return 0;
            if (CreatedDate < compareToEmp.CreatedDate) return 1;
            return -1;        
        }
    }
    // Change End SSE-20075 (Account Planning Phase 2) 
    
    /*
* Retrieves a list of inactive Strategy records for a given Account Plan Id.
* It populates a list of wrapper objects containing the strategy information and returns it.
*
* @param accountPlanId  The Account Plan Id to filter strategies and account contact relations.
* @return A list of returnMessageWrapper objects containing the strategy information and related data.
*/
    @AuraEnabled
    public static returnMessageWrapper getInactiveStrategyAndGoalsDetails(Id accountPlanId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        Integer count = 0;
        try{
            List<Strategy_and_Goal__c> strategyData = [SELECT Id,Name,Approved__c,Strategy_Name__c,Strategy_Status__c,Strategy_Type__c,
                                                       Short_Long_Term__c,Estimated_Completion_Date__c,Solution_Product_Area__c,
                                                       Key_Contact_Sponsor__r.Contact_Full_Name__c,
                                                       Key_Contact_Sponsor__c, InActive__c,
                                                       Account_Plan__r.Account_Name__c 
                                                       FROM Strategy_and_Goal__c 
                                                       WHERE Account_Plan__c =:accountPlanId 
                                                       AND InActive__c = true
                                                       ORDER BY CreatedDate DESC];
            List<StrategyAndGoalWrapper> strategyList = new List<StrategyAndGoalWrapper>(); 
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            for (Strategy_and_Goal__c strategy : strategyData) {
                StrategyAndGoalWrapper wrap = new StrategyAndGoalWrapper();
                count=count+1;
                wrap.SNo = count;
                wrap.strategyUrl = sfdcBaseURL+'/'+strategy.Id;
                wrap.strategyId = strategy.Id;
                wrap.strategyName = strategy.Strategy_Name__c;
                if(strategy?.Key_Contact_Sponsor__c != null){
                    wrap.contactName = strategy?.Key_Contact_Sponsor__r?.Contact_Full_Name__c;
                    wrap.contactId = strategy?.Key_Contact_Sponsor__c;
                    wrap.contactUrl = sfdcBaseURL+'/'+strategy?.Key_Contact_Sponsor__c;
                }
                wrap.status = strategy.Strategy_Status__c;
                wrap.type = strategy.Strategy_Type__c;
                wrap.estimatedCompletionDate = strategy.Estimated_Completion_Date__c;
                wrap.term = strategy.Short_Long_Term__c;
                wrap.productSolution = strategy.Solution_Product_Area__c;
                wrap.accountId = strategy.Account_Plan__r.Account_Name__c;
                wrap.isApproved = strategy.Approved__c;
                wrap.id = strategy.Id;
                strategyList.add(wrap);
            }
            rmw.MessageType ='Success';
            rmw.Message = 'Strategy Data has been retrived successfully!';
            rmw.strategyList = strategyList;
        }catch (DMLException e) {
            String message = e.getDmlMessage(0);
            rmw.MessageType = 'Error';
            rmw.Message = message;   
        } catch(Exception e){
            system.debug(e.getMessage());
            rmw.MessageType = 'Error';
            rmw.Message = e.getMessage();  
        }      
        return rmw;
    }
}
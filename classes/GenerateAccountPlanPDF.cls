/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is used to generate PDF automatically for an account paln its getting used in                            *
*              createAccountPlanPDF LWC Component.                                                                                 *
************************************************************************************************************************************/

public class GenerateAccountPlanPDF {
    
    @AuraEnabled(cacheable=true)
    public static getAccountPlanDataWrapper getDataForPDF(String recordID){
         
        getAccountPlanDataWrapper apdw = new getAccountPlanDataWrapper();
        system.debug('PDF Class --> recordID' +recordID);
        
        
         UserRecordAccess checkRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess 
                                                WHERE UserId =:UserInfo.getUserId() 
                                                AND RecordId =:recordID];
         if(checkRecordAccess != null){
             if(checkRecordAccess.HasEditAccess == true){
                  apdw.AccessLevel = 'Edit' ;
             }
             else{
                 if(checkRecordAccess.HasReadAccess == true){
                     apdw.AccessLevel = 'Read' ; 
                 }
             }
         }
        
             if(apdw.AccessLevel == 'Edit'){
                 
             
        Account_Plan__c accPlanList =  [select id , Account_Name__c,Account_Name__r.name, Account_Name__r.Account_Number__c,Account_Manager__c, 
                                        Sales_Manager__c,Date_for_next_Plan_Review__c,Target_Tier__c
                                        , Date_of_Last_Plan_Review__c, checkPDF__c, Business_Defined_Attribute__c,
                                        Date_Plan_Last_Updated__c, SHL_BU_Region__c, Territory_Type__c, 
                                        Location_of_Global_HQ_Picklist__c, //SSE-21116(Account Plan Phase 3)
                                        RAD_Strategy__c, Segment__c , Website__c, 
                                        Industry__c, Global_FTE_Number__c, Regional_FTE_Number__c, Overview_of_Business__c,
                                        Contact_Relationship_Screenshot__c, Fiscal_Year_End__c,
                                        History_trend_Screenshot__c, Contacts_at_this_Account__c,
                                        Contacts_Created_Last_12_Months__c, Open_Opportunities__c, Open_Cases__c,
                                        Open_Opportunity_Value__c, Cases_Last_12_Months_open_closed__c,
                                        Account_Plan_Name__c, Content_Document_Id__c,Our_Current_Situation_Outlook__c, 
                                        Client_s_Strategy__c, Risk_Exposure__c, Contacts_Created_since_last_review__c,
                                        Relationship_History__c, Summary_of_Current_SHL_Relationship__c,Opportunities_Created_since_last_Review__c,Buying_Centre_Id__c,Account_Plan_Type__c
                                        from Account_Plan__c where id = :recordID];  
        
        /* List<ContentDocumentLink> contentDocumentData = [Select id  , ContentDocument.LatestPublishedVersion.VersionData ,
ContentDocument.LatestPublishedVersion.Title
FROM ContentDocumentLink
WHERE LinkedEntityId  = :recordID and 
(ContentDocument.LatestPublishedVersion.Title like '%HistoryTrendScreenshot%')];
if(contentDocumentData.size() > 0){
for(ContentDocumentLink cdl : contentDocumentData){
if(cdl.ContentDocument.LatestPublishedVersion.Title == 'HistoryTrendScreenshot'){
String base64HistoryImage = EncodingUtil.base64Encode(cdl.ContentDocument.LatestPublishedVersion.VersionData);
historyImage = base64HistoryImage;
}
}
}
else{
historyImage = '';
}*/
        
        List<AccountPlan_Contracts_Controller.ContractsWrapper> acccw = new List<AccountPlan_Contracts_Controller.ContractsWrapper>();
        acccw = AccountPlan_Contracts_Controller.getAccountContracts(recordID);
        
        List<StrategyWrapperForPdf> strategyListOpen = new List<StrategyWrapperForPdf>(); 
        strategyListOpen = getStrategyDetails(recordID);
        
        List<StrategyWrapperForPdf> strategyListCompleted = new List<StrategyWrapperForPdf>(); 
        strategyListCompleted = getCompletedStrategies(recordID);
        
        CurrentPipelineController.CurrentOpportunityDetailsWrapper oppList = new CurrentPipelineController.CurrentOpportunityDetailsWrapper();
        oppList = getNotLinkedOpportunities(recordID);
        
        //List<CompetitorOnAccountPlanController.CompetitorWrapper> compList = new List<CompetitorOnAccountPlanController.CompetitorWrapper>();
        //compList = CompetitorOnAccountPlanController.getCompetitorDetails(accPlanList.Account_Name__c,'Current');
        
        if(accPlanList != null){
            
            apdw.AccountId=accPlanList.Account_Name__c;
            apdw.AccountName=accPlanList.Account_Name__r.name;
            apdw.AccountManager=accPlanList.Account_Manager__c;
            apdw.SalesManager=accPlanList.Sales_Manager__c;
            apdw.BU=accPlanList.SHL_BU_Region__c;
            apdw.TerritoryType=accPlanList.Territory_Type__c;
            apdw.Segment=accPlanList.Segment__c;
            apdw.RADType=accPlanList.RAD_Strategy__c;
            apdw.Website=accPlanList.Website__c;
            apdw.Industry=accPlanList.Industry__c;
            apdw.GlobalFTE=accPlanList.Global_FTE_Number__c;
            apdw.RegionalFTE=accPlanList.Regional_FTE_Number__c;
            apdw.LastUpdated=accPlanList.Date_Plan_Last_Updated__c;
            apdw.LastReviewed=accPlanList.Date_of_Last_Plan_Review__c;
            apdw.LastAccountReviewed=accPlanList.Date_for_next_Plan_Review__c;
            apdw.GlobalHQ=accPlanList.Location_of_Global_HQ_Picklist__c;//SSE-21116(Account Plan Phase 3)
            apdw.SummaryCurrentSHLRelation=accPlanList.Summary_of_Current_SHL_Relationship__c;
            apdw.CurrentSituation=accPlanList.Our_Current_Situation_Outlook__c;
            apdw.ClientStrategy=accPlanList.Client_s_Strategy__c;
            apdw.RiskExposure=accPlanList.Risk_Exposure__c;
            apdw.RelationHistory=accPlanList.Relationship_History__c;
            apdw.Name = accPlanList.Account_Plan_Name__c;
            apdw.ContentDocumentID = accPlanList.Content_Document_Id__c;
            apdw.Contacts = accPlanList.Contacts_at_this_Account__c;
            apdw.Contacts12Month = accPlanList.Contacts_Created_Last_12_Months__c ;
            apdw.Cases = accPlanList.Open_Cases__c;
            apdw.Opportunities = accPlanList.Open_Opportunities__c;
            apdw.OppValue = accPlanList.Open_Opportunity_Value__c;
            apdw.Cases12Months = accPlanList.Cases_Last_12_Months_open_closed__c;
            apdw.BDA = accPlanList.Business_Defined_Attribute__c;
            apdw.buyingCentreId = accPlanList.Buying_Centre_Id__c;
            apdw.accountPlanType = accPlanList.Account_Plan_Type__c;
            apdw.dNumber = accPlanList.Account_Name__r.Account_Number__c;
            //apdw.whiteSpaceWrapper = whitespaceList;
            apdw.strategyWrapperOpen = strategyListOpen;
            apdw.strategyWrapperCompleted = strategyListCompleted;
            apdw.currentOppWrapper = oppList;
            //apdw.systemWrapper = systemList;
            //apdw.competitorWrapper  = compList;  
            apdw.contractWrapper = acccw;
            apdw.checkPDF = accPlanList.checkPDF__c;
            apdw.FiscalYear = accPlanList.Fiscal_Year_End__c;
            apdw.TargetTier = accPlanList.Target_Tier__c;
            apdw.BusinessOverview = accPlanList.Overview_of_Business__c;
            if(accPlanList.Opportunities_Created_since_last_Review__c == null){
                apdw.OppBeforeReview = 0;
            }
            else{
                apdw.OppBeforeReview=accPlanList.Opportunities_Created_since_last_Review__c.intValue();
            }
            if(accPlanList.Contacts_Created_since_last_review__c == null){
                apdw.ContactBeforeReview = 0;
            }
            else{
                apdw.ContactBeforeReview=accPlanList.Contacts_Created_since_last_review__c.intValue();
            }
            
            
            //apdw.HistoryTrend = getImageURL(accPlanList.History_trend_Screenshot__c);
            
        }
             }
        system.debug(apdw);
        return apdw;
    }
    
    @AuraEnabled
    public static returnMessageWrapper saveAccountPlanPDF(String sappdfw_string){
        
        saveAccountPlanPDFWrapper sappdfw = new saveAccountPlanPDFWrapper();
        sappdfw = (saveAccountPlanPDFWrapper) JSON.deserialize(sappdfw_string, saveAccountPlanPDFWrapper.class);
        returnMessageWrapper rmw = new returnMessageWrapper();
        
        String passBlob = sappdfw.pdfBase64String;
        Blob pdfBlob = EncodingUtil.base64Decode(passBlob);
        
        String contentDocumentIdFromAccountPlan = sappdfw.ContentDocumentID;
        if(!String.isBlank(contentDocumentIdFromAccountPlan)){
            List<ContentDocument> cd = [SELECT id FROM ContentDocument WHERE Id=:contentDocumentIdFromAccountPlan];
            if(cd.size()==0){
                contentDocumentIdFromAccountPlan=null;
            }
        }
        //generate and save file
        ContentVersion cv = generateNewFile(pdfBlob ,sappdfw.AccountPlanId, sappdfw.Name, contentDocumentIdFromAccountPlan);
        try{  
            
            if(cv != null){
                
                insert cv; //save file under Opportunity
                
                
            }
            
            List<Account_Plan__c> apList  = [Select id,checkPDF__c from Account_Plan__c 
                                             where id =:sappdfw.AccountPlanId];
            if(contentDocumentIdFromAccountPlan == null){
                List<contentversion> cvlist = [select id, ContentDocumentId from contentversion where id = :cv.id];
                
                
                String cdID = '';
                if(cvlist.size() > 0){
                    
                    for(contentversion c :cvlist ){
                        cdID = c.ContentDocumentId;
                    }
                    
                    ContentDocumentLink cdl =[select id , ShareType from ContentDocumentLink 
                                              where ContentDocumentId=:cdID and LinkedEntityId=:sappdfw.AccountPlanId];
                    
                    if(cdl != null){
                        cdl.ShareType ='I';
                    }
                    update cdl;        
                    
                    for(Account_Plan__c ap: apList){
                        ap.Content_Document_Id__c = cdID;
                        ap.checkPDF__c = false;
                    }
                    
                    
                }
                else{
                    for(Account_Plan__c ap: apList){
                        ap.checkPDF__c = false;
                    }
                }
                
                
                
            }
            else{
                for(Account_Plan__c ap: apList){
                    ap.checkPDF__c = false;
                }
            }
            
            update apList;
            
            rmw.MessageType = 'SUCCESS';
            rmw.Message = 'Account Plan have been saved successfully!';
            rmw.AccountPlanId = '';  
            
            
        } catch (Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
            rmw.AccountPlanId = '';
            
            
        }
        return rmw;
    }
    
    @AuraEnabled
    public static returnMessageWrapper updatecheckPDF(String AccountPlanId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        List<Account_Plan__c> apList  = [Select id,checkPDF__c from Account_Plan__c 
                                         where id =:AccountPlanId];
        for(Account_Plan__c ap: apList){
            ap.checkPDF__c = false;
        }
        try{
            update apList;
            rmw.MessageType = 'SUCCESS';
            rmw.Message = 'Account Plan have been generated successfully!Please check it in related Files';
            rmw.AccountPlanId = '';  
        }catch (Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
            rmw.AccountPlanId = '';}
        
        return rmw;
        
    }
    
    
    public static ContentVersion generateNewFile(Blob pdfBlob, String AccountPlanId , String Name , String cdid){
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = pdfBlob;
        cv.Title = Name;
        cv.PathOnClient = Name + '.pdf';
        cv.SharingPrivacy = 'N' ;
        cv.SharingOption = 'A';
        cv.IsMajorVersion = true;  
        if(cdid != null && cdid != ''){
            Id  ContentDocumentId =  cdid;
            cv.ContentDocumentId = ContentDocumentId;  
        } else{ 
            cv.FirstPublishLocationId = AccountPlanId;
            cv.Description = 'This is an autogenerated PDF for Account Plan.'; //Added by Prachi SSE-21436
        }
        
        return cv;
        
    }
    
    public static List<StrategyWrapperForPdf> getStrategyDetails(Id accountPlanId){
        List<Strategy_and_Goal__c> strategyData = [SELECT Id,Name,Approved__c,Strategy_Name__c,Strategy_Status__c,Strategy_Type__c,
                                                   Short_Long_Term__c,Estimated_Completion_Date__c,Solution_Product_Area__c,Resources_Required__c,
                                                   Key_Contact_Sponsor__c,Key_Contact_Sponsor__r.Contact_Full_Name__c,Key_Milestones__c,Number_of_tasks_completed__c,Number_of_tasks_created__c,
                                                   Account_Plan__r.Account_Name__c,Business_Problem_Addressed__c,Comments_Next_Steps__c,Solution_Goal__c,
                                                   (SELECT Id,Account.Account_Number__c,Account.CurrencyIsoCode,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Renewal_Date__c From Opportunities__r where StageName NOT IN ('Closed/Won','Closed Lost') ORDER BY CloseDate),
                                                   (SELECT Id,Potential_Value_In_USD__c,CurrencyIsoCode,Any_help_needed__c,Next_Step_s__c,Potential_Value__c,Solution__c,Status__c,Name,Who_do_you_need_to_speak_to__c,Who_do_you_need_to_speak_to__r.Contact_Full_Name__c FROM Whitespace_Potential_Opportunities__r WHERE Status__c!='Current Pipeline')
                                                   FROM Strategy_and_Goal__c 
                                                   WHERE Account_Plan__c=:accountPlanId 
                                                   AND Strategy_Status__c NOT IN ('Completed - Failed','Completed - Partial Success','Completed - Success', 'Won - Partial Achievement','Won - Achieved Revenue Goals', 'No Opportunity', 'Strategy Expired') 
                                                   ORDER BY Approved__c,Estimated_Completion_Date__c];
        List<StrategyWrapperForPdf> strategyList = new List<StrategyWrapperForPdf>(); 
        Map<Id,StrategyWrapperForPdf> strategyMap = new Map<Id,StrategyWrapperForPdf>();
        List<Id> strategyIds = new List<Id>();
        
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        for (Strategy_and_Goal__c strategy : strategyData) {
            strategyIds.add(strategy.Id);
            StrategyWrapperForPdf wrap = new StrategyWrapperForPdf();
            wrap.strategyName = strategy.Strategy_Name__c;
            if(strategy.Key_Contact_Sponsor__c!=null){
                wrap.keyContactSponser = strategy.Key_Contact_Sponsor__r.Contact_Full_Name__c;
            }
            wrap.type = strategy.Strategy_Type__c;
            wrap.estimatedCompletionDate = String.valueOf(strategy.Estimated_Completion_Date__c);
            wrap.term = strategy.Short_Long_Term__c;
            wrap.solution = strategy.Solution_Product_Area__c;
            wrap.keyMilestones = strategy.Key_Milestones__c;
            wrap.solutionGoal = strategy.Solution_Goal__c;
            wrap.nextSteps = strategy.Comments_Next_Steps__c;
            wrap.resourcesRequired = strategy.Resources_Required__c;
            wrap.businessProblemAddressed = strategy.Business_Problem_Addressed__c;
            wrap.openActivities = strategy.Number_of_tasks_created__c - strategy.Number_Of_Tasks_Completed__c;
            wrap.closedActivities = strategy.Number_Of_Tasks_Completed__c;
            CurrentPipelineController.CurrentOpportunityDetailsWrapper oppList = new CurrentPipelineController.CurrentOpportunityDetailsWrapper();
            Decimal totalSalesValue = 0;
            List<CurrentPipelineController.CurrentOpportunityWrapper> oppWrapList = new List<CurrentPipelineController.CurrentOpportunityWrapper>();
            for (Opportunity opp : strategy.Opportunities__r) {
                CurrentPipelineController.CurrentOpportunityWrapper oppWrap = new CurrentPipelineController.CurrentOpportunityWrapper();
                oppWrap.opportunityName = opp.OpportunityId__c;
                oppWrap.amountWithCurrency = opp.Amount!=null?opp.Account.CurrencyIsoCode + ' '+opp.Amount:opp.Account.CurrencyIsoCode + ' ' + 0;
                oppWrap.nextStep = opp.NextStep;
                oppWrap.stageName = opp.StageName;
                oppWrap.closeDate = opp.CloseDate;
                oppWrap.contractLength = opp.Multi_YearDeal__c;
                oppWrap.renewalDate = opp.Renewal_Date__c;
                oppWrap.opportunityNickname = opp.Opportunity_Nickname__c;
                oppWrap.dNumber = opp.Account.Account_Number__c;
                oppWrapList.add(oppWrap);
                totalSalesValue += opp.Sales_Price_in_USD__c;
            }
            oppList.currentPipeline = oppWrapList;
            oppList.totalSalesValue = 'USD '+String.valueOf(totalSalesValue);
            wrap.oppList = oppList;
            WhiteSpaceOpportunityController.StrategyAndWhiteSpaceWrapper whitespaceList = new WhiteSpaceOpportunityController.StrategyAndWhiteSpaceWrapper();
            Decimal totalPotentialValue = 0;
            List<WhiteSpaceOpportunityController.WhiteSpaceOpportunityWrapper> wsOppWrapList = new List<WhiteSpaceOpportunityController.WhiteSpaceOpportunityWrapper>();
            for (Whitespace_Potential_Opportunity__c wsOpp : strategy.Whitespace_Potential_Opportunities__r) {
                WhiteSpaceOpportunityController.WhiteSpaceOpportunityWrapper wsOppWrap = new WhiteSpaceOpportunityController.WhiteSpaceOpportunityWrapper();
                wsOppWrap.contactName = wsOpp.Who_do_you_need_to_speak_to__r.Contact_Full_Name__c;
                wsOppWrap.nextStep = wsOpp.Next_Step_s__c;
                wsOppWrap.status = wsOpp.Status__c;
                wsOppWrap.potentialValueWithCurrency = wsOpp.CurrencyIsoCode +' ' +wsOpp.Potential_Value__c;
                wsOppWrap.nextStep = wsOpp.Next_Step_s__c;
                wsOppWrap.solution = wsOpp.Solution__c;
                wsOppWrap.helpNeeded = wsOpp.Any_help_needed__c;
                wsOppWrapList.add(wsOppWrap);
                totalPotentialValue += wsOpp.Potential_Value_In_USD__c;
            }
            whitespaceList.whiteSpaceOppList = wsOppWrapList;
            whitespaceList.totalPotentialValue = 'USD '+String.ValueOf(totalPotentialValue);
            wrap.whitespaceList = whitespaceList;
            wrap.oppList = oppList;
            wrap.activityList = new List<StrategyAndGoalController.ActivitiesWrapper>();
            strategyList.add(wrap);
            strategyMap.put(strategy.Id,wrap);
        }
        
        List<StrategyAndGoalController.ActivitiesWrapper> activityDetails =  getActivityDetails(strategyIds);
        for (StrategyAndGoalController.ActivitiesWrapper act : activityDetails) {
            if(strategyMap.get(act.strategyId)!=null){
                strategyMap.get(act.strategyId).activityList.add(act);
            }
        }
        system.debug(strategyList);
        return strategyList;
    }
    
    public static List<StrategyAndGoalController.ActivitiesWrapper> getActivityDetails(List<Id> strategyIds){
        List<StrategyAndGoalController.ActivitiesWrapper> actwList = new List<StrategyAndGoalController.ActivitiesWrapper>();
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm(); 
        List<Task> taskList = [SELECT Subject,WhatId, WhoId,  ActivityDate , Status, Priority, OwnerId ,Who.name,Owner.Name,createdDate
                               FROM task where whatId IN :strategyIds and (not status like '%Complete%') order by ActivityDate ]; 
        List<Event> eventList = [SELECT Subject,WhatId, WhoId,  EndDate , OwnerId , Status__c, Who.name,Owner.Name,createdDate,
                                 StartDateTime  FROM Event where whatId IN :strategyIds  and   Is_Completed__c=false
                                 and (not Status__c like '%Cancelled%') order by EndDate];
        if(taskList.size()>0){
            for(Task t: taskList){
                
                StrategyAndGoalController.ActivitiesWrapper act = new StrategyAndGoalController.ActivitiesWrapper();
                act.strategyId = t.WhatId;
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
                StrategyAndGoalController.ActivitiesWrapper act = new StrategyAndGoalController.ActivitiesWrapper();
                act.strategyId = e.WhatId;
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
        
        return actwList;
        
    }
    
    public static CurrentPipelineController.CurrentOpportunityDetailsWrapper getNotLinkedOpportunities(Id accountPlanId){
        CurrentPipelineController.CurrentOpportunityDetailsWrapper wrapperToReturn = new CurrentPipelineController.CurrentOpportunityDetailsWrapper();
        Account_Plan__c accplan = [select id , Account_Name__c,Account_Plan_Status__c , Account_Name__r.CurrencyIsoCode,Account_Plan_Type__c,Buying_Centre_Id__c
                                   from Account_Plan__c where id=:accountPlanId];
        
        List<Opportunity> oppData = new List<Opportunity>();
        if(accplan.Account_Plan_Type__c=='Regional'){
            List<Account> accList = [SELECT Id FROM Account WHERE Buying_Centre_Id__c= :accplan.Buying_Centre_Id__c];
            List<Id> accIds = new List<Id>();
            for (Account acc : accList) {
                accIds.add(acc.Id);
            }
            oppData = [SELECT Id,Account.CurrencyIsoCode,Account.Account_Number__c,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems),Renewal_Date__c From Opportunity where AccountId IN :accIds AND StageName NOT IN ('Closed/Won','Closed Lost') AND Strategy_and_Goals__c=null ORDER BY CloseDate];
            
        }else if(accplan.Account_Plan_Type__c=='Current'){
            oppData = [SELECT Id,Account.CurrencyIsoCode,Account.Account_Number__c,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems),Renewal_Date__c From Opportunity where AccountId=:accplan.Account_Name__c AND StageName NOT IN ('Closed/Won','Closed Lost') AND Strategy_and_Goals__c=null ORDER BY CloseDate];
            
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
            oppData = [SELECT Id,Account.CurrencyIsoCode,Account.Account_Number__c,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,Renewal_Date__c From Opportunity where AccountId IN :allAccountIds AND StageName NOT IN ('Closed/Won','Closed Lost') AND Strategy_and_Goals__c=null ORDER BY CloseDate];
            
        }
        List<CurrentPipelineController.CurrentOpportunityWrapper> currentPipeline = new List<CurrentPipelineController.CurrentOpportunityWrapper>(); 
        Integer serialNumber = 1;
        Decimal totalSalesValue = 0;
        Decimal totalSalesValueInUSD = 0;
        String currencyFromAccount = accplan.Account_Name__r.CurrencyIsoCode;
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        for (Opportunity opp : oppData) {
            CurrentPipelineController.CurrentOpportunityWrapper wrap = new CurrentPipelineController.CurrentOpportunityWrapper();
            wrap.opportunityName = opp.OpportunityId__c;
            wrap.amount = opp.Amount;
            wrap.amountWithCurrency = opp.Amount!=null?opp.Account.CurrencyIsoCode + ' '+opp.Amount:opp.Account.CurrencyIsoCode + ' ' + 0;
            wrap.nextStep = opp.NextStep;
            wrap.stageName = opp.StageName;
            wrap.closeDate = opp.CloseDate;
            wrap.contractLength = opp.Multi_YearDeal__c;
            wrap.renewalDate = opp.Renewal_Date__c;
            wrap.opportunityNickname = opp.Opportunity_Nickname__c;
            wrap.dNumber = opp.Account.Account_Number__c;
            currentPipeline.add(wrap);
            totalSalesValue += (opp.Amount!=null)?opp.Amount:0;
            totalSalesValueInUSD += opp.Sales_Price_in_USD__c;
        }
        
        wrapperToReturn.currentPipeline = currentPipeline;
        if(currencyFromAccount=='USD' || accplan.Account_Plan_Type__c=='Global' || accplan.Account_Plan_Type__c=='Regional'){
            wrapperToReturn.totalSalesValue = 'USD '+totalSalesValueInUSD;
        }else{
            wrapperToReturn.totalSalesValue = currencyFromAccount +' '+ totalSalesValue+' ( USD '+totalSalesValueInUSD +' )';
        }
        return wrapperToReturn;
    }
    
    public static List<StrategyWrapperForPdf> getCompletedStrategies(Id accountPlanId){
        List<Strategy_and_Goal__c> strategyData = [SELECT Id,Name,Approved__c,Strategy_Name__c,Strategy_Status__c,Strategy_Type__c,
                                                   Short_Long_Term__c,Estimated_Completion_Date__c,Solution_Product_Area__c,
                                                   Key_Contact_Sponsor__c,Key_Contact_Sponsor__r.Contact_Full_Name__c                   
                                                   FROM Strategy_and_Goal__c 
                                                   WHERE Account_Plan__c=:accountPlanId 
                                                   AND Strategy_Status__c IN ('Completed - Failed','Completed - Partial Success','Completed - Success', 'Won - Partial Achievement','Won - Achieved Revenue Goals', 'No Opportunity', 'Strategy Expired')  
                                           		   AND Estimated_Completion_Date__c = LAST_N_DAYS:365
                                                   ORDER BY Approved__c,Estimated_Completion_Date__c];
        List<StrategyWrapperForPdf> strategyList = new List<StrategyWrapperForPdf>(); 
        
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        for (Strategy_and_Goal__c strategy : strategyData) {
            StrategyWrapperForPdf wrap = new StrategyWrapperForPdf();
            wrap.strategyName = strategy.Strategy_Name__c;
            if(strategy.Key_Contact_Sponsor__c!=null){
                wrap.keyContactSponser = strategy.Key_Contact_Sponsor__r.Contact_Full_Name__c;
            }
            wrap.type = strategy.Strategy_Type__c;
            wrap.estimatedCompletionDate = String.valueOf(strategy.Estimated_Completion_Date__c);
            wrap.term = strategy.Short_Long_Term__c;
            wrap.solution = strategy.Solution_Product_Area__c;
            wrap.status = strategy.Strategy_Status__c;
            strategyList.add(wrap);
        }
        return strategyList;
    }
    
    public class getAccountPlanDataWrapper{
        @AuraEnabled public String AccountId;
        @AuraEnabled public String BDA;
        @AuraEnabled public String AccountName;
        @AuraEnabled public String AccountManager;
        @AuraEnabled public String SalesManager;
        @AuraEnabled public String BU;
        @AuraEnabled public String TerritoryType;
        @AuraEnabled public String Segment;
        @AuraEnabled public String RADType;   
        @AuraEnabled public String Website;
        @AuraEnabled public String Industry;
        @AuraEnabled public Decimal GlobalFTE;
        @AuraEnabled public Decimal RegionalFTE;
        @AuraEnabled public Date LastUpdated;
        @AuraEnabled public Date LastReviewed;
        @AuraEnabled public Date LastAccountReviewed;
        @AuraEnabled public String GlobalHQ;
        @AuraEnabled public String SummaryCurrentSHLRelation;
        @AuraEnabled public String BusinessOverview;
        @AuraEnabled public String RelationHistory;
        @AuraEnabled public String RiskExposure;
        @AuraEnabled public String ClientStrategy;
        @AuraEnabled public String CurrentSituation;  
        @AuraEnabled public String VisionStrategicGoals;
        @AuraEnabled public String Name;
        @AuraEnabled public String ContentDocumentID;
        @AuraEnabled public String LastContacted;
        @AuraEnabled public String SubjectDiscussed; 
        @AuraEnabled public Decimal Contacts;
        @AuraEnabled public Decimal Contacts12Month;
        @AuraEnabled public Decimal Cases;
        @AuraEnabled public Decimal Opportunities;
        @AuraEnabled public Decimal OppValue;
        @AuraEnabled public Decimal Cases12Months;
        @AuraEnabled public String HistoryTrend;
        @AuraEnabled public String ContactRelation;
        @AuraEnabled public String FiscalYear;
        @AuraEnabled public Boolean checkPDF; 
        @AuraEnabled public String TargetTier;
        @AuraEnabled public Integer OppBeforeReview;
        @AuraEnabled public Integer ContactBeforeReview;
        @AuraEnabled public CurrentPipelineController.CurrentOpportunityDetailsWrapper currentOppWrapper; 
        @AuraEnabled public List<AccountPlan_Contracts_Controller.ContractsWrapper> contractWrapper;
        @AuraEnabled public List<StrategyWrapperForPdf> strategyWrapperOpen;
        @AuraEnabled public List<StrategyWrapperForPdf> strategyWrapperCompleted;
        @AuraEnabled public String buyingCentreId;
        @AuraEnabled public String accountPlanType;
        @AuraEnabled public String dNumber;
        @AuraEnabled public String AccessLevel;
        
    }
    
    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public String AccountPlanId;
        @AuraEnabled public String Status;
        
    }
    public class saveAccountPlanPDFWrapper{
        @AuraEnabled public String Name; 
        @AuraEnabled public Id AccountPlanId;
        @AuraEnabled public String pdfBase64String;
        @AuraEnabled public String ContentDocumentID;
        
    }
    
    public class StrategyWrapperForPdf{
        @AuraEnabled public String strategyName; 
        @AuraEnabled public String term;
        @AuraEnabled public String type;
        @AuraEnabled public String estimatedCompletionDate;
        @AuraEnabled public String keyContactSponser;
        @AuraEnabled public String solution;
        @AuraEnabled public String businessProblemAddressed;
        @AuraEnabled public Decimal openActivities;
        @AuraEnabled public Decimal closedActivities;
        @AuraEnabled public String keyMilestones;
        @AuraEnabled public String solutionGoal;
        @AuraEnabled public String nextSteps;
        @AuraEnabled public String status;
        @AuraEnabled public String resourcesRequired;
        @AuraEnabled public CurrentPipelineController.CurrentOpportunityDetailsWrapper oppList;
        @AuraEnabled public WhiteSpaceOpportunityController.StrategyAndWhiteSpaceWrapper whitespaceList;
        @AuraEnabled public List<StrategyAndGoalController.ActivitiesWrapper> activityList;
    }
}
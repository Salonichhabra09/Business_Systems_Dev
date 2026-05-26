public without sharing class WhiteSpaceOpportunityController {
    
    @AuraEnabled(cacheable=true)
    public static returnMessageWrapper getWhiteSpaceOpportunitiesDetails(Id recordId){
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        try{
            StrategyAndWhiteSpaceWrapper detailsWrapper = new StrategyAndWhiteSpaceWrapper();
            List<Strategy_and_Goal__c> strategy = new List<Strategy_and_Goal__c>();
            List<Whitespace_Potential_Opportunity__c> wsOppData = new List<Whitespace_Potential_Opportunity__c>();
            List<Account_Plan__c> accountPlan = new List<Account_Plan__c>();
            String accountId='';
            String currencyFromAccount ='';
            Boolean isAccountPlanUnderReview = false;
            if(recordId.getSObjectType().getDescribe().getName()=='Strategy_and_Goal__c'){
                strategy = [SELECT Id,Account_Plan__c,Account_Plan__r.Account_Name__c,Account_Plan_Status__c,Account_Plan__r.Account_Name__r.CurrencyIsoCode FROM Strategy_and_Goal__c WHERE Id =:recordId];
                accountId = strategy[0].Account_Plan__r.Account_Name__c;
                currencyFromAccount = strategy[0].Account_Plan__r.Account_Name__r.CurrencyIsoCode;
                if(strategy[0].Account_Plan_Status__c=='In Review'){
                    isAccountPlanUnderReview = true;
                }
                wsOppData = [SELECT Id,CurrencyIsoCode,Potential_Value_In_USD__c,Any_help_needed__c,Account_BU__c,Next_Step_s__c,Opportunity__c,Opportunity__r.OpportunityId__c,Potential_Value__c,Solution__c,Status__c,Name,Who_do_you_need_to_speak_to__c,Who_do_you_need_to_speak_to__r.Contact_Full_Name__c,Strategy_and_Goals__c,Strategy_and_Goals__r.Strategy_Name__c FROM Whitespace_Potential_Opportunity__c WHERE Strategy_and_Goals__c=:recordId];
            }else{
                accountPlan = [SELECT id,Account_Name__c,Account_Plan_Status__c,Account_Name__r.CurrencyIsoCode FROM Account_Plan__c WHERE id=:recordId];
                accountId = accountPlan[0].Account_Name__c;
                currencyFromAccount = accountPlan[0].Account_Name__r.CurrencyIsoCode;
                if(accountPlan[0].Account_Plan_Status__c=='In Review'){
                    isAccountPlanUnderReview = true;
                }
                wsOppData = [SELECT Id,CurrencyIsoCode,Potential_Value_In_USD__c,Any_help_needed__c,Account_BU__c,Next_Step_s__c,Opportunity__c,Opportunity__r.OpportunityId__c,Potential_Value__c,Solution__c,Status__c,Name,Who_do_you_need_to_speak_to__c,Who_do_you_need_to_speak_to__r.Contact_Full_Name__c,Strategy_and_Goals__c,Strategy_and_Goals__r.Strategy_Name__c FROM Whitespace_Potential_Opportunity__c WHERE Account_Plan__c=:recordId AND Status__c!='Current Pipeline'];
            }
            List<WhiteSpaceOpportunityWrapper> whiteSpaceOppList = new List<WhiteSpaceOpportunityWrapper>(); 
            Integer serialNumber = 1;
            Decimal totalPotentialValue = 0;
            Decimal totalPotentialValueInUSD = 0;
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            for (Whitespace_Potential_Opportunity__c wsOpp : wsOppData) {
                WhiteSpaceOpportunityWrapper wrap = new WhiteSpaceOpportunityWrapper();
                wrap.strategyUrl = sfdcBaseURL+'/'+wsOpp.Strategy_and_Goals__c;
                wrap.whiteSpaceOppId = wsOpp.Id;
                wrap.strategyName = wsOpp.Strategy_and_Goals__r.Strategy_Name__c;
                wrap.serialNumber = serialNumber;
                if(wsOpp.Opportunity__c!=null){
                    wrap.opportunityName = wsOpp.Opportunity__r.OpportunityId__c;
                    wrap.opportunityUrl = sfdcBaseURL+'/'+wsOpp.Opportunity__c;
                    wrap.opportunityId = wsOpp.Opportunity__c;
                }
                wrap.contactName = wsOpp.Who_do_you_need_to_speak_to__r.Contact_Full_Name__c;
                wrap.contactId = wsOpp.Who_do_you_need_to_speak_to__c;
                wrap.contactUrl = sfdcBaseURL+'/'+wsOpp.Who_do_you_need_to_speak_to__c;
                wrap.nextStep = wsOpp.Next_Step_s__c;
                wrap.status = wsOpp.Status__c;
                wrap.potentialValue = wsOpp.Potential_Value__c;
                wrap.potentialValueWithCurrency = currencyFromAccount +' ' +wsOpp.Potential_Value__c;
                wrap.nextStep = wsOpp.Next_Step_s__c;
                wrap.accountBU = wsOpp.Account_BU__c;
                wrap.solution = wsOpp.Solution__c;
                wrap.helpNeeded = wsOpp.Any_help_needed__c;
                wrap.strategy = wsOpp.Strategy_and_Goals__c;
                wrap.whiteSpaceCurrency = wsOpp.CurrencyIsoCode;
                whiteSpaceOppList.add(wrap);
                serialNumber++;
                totalPotentialValue += (wsOpp.Potential_Value__c!=null)?wsOpp.Potential_Value__c:0;
                totalPotentialValueInUSD += wsOpp.Potential_Value_In_USD__c;
            }
            if(strategy.size()>0){
                detailsWrapper.accountPlanId = strategy[0].Account_Plan__c;
            }
            detailsWrapper.accountId = accountId;
            detailsWrapper.isAccountPlanUnderReview = isAccountPlanUnderReview;
            UserRecordAccess checkRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =:accountId];
            if(checkRecordAccess.HasEditAccess==false){
                detailsWrapper.isAccountPlanUnderReview = true;
            }
            detailsWrapper.currencyFromAccount = currencyFromAccount;
            if(currencyFromAccount=='USD'){
                detailsWrapper.totalPotentialValue = 'USD '+totalPotentialValueInUSD;
            }else{
                detailsWrapper.totalPotentialValue = currencyFromAccount +' '+ totalPotentialValue+' ( USD '+totalPotentialValueInUSD +' )';
            }
            detailsWrapper.whiteSpaceOppList = whiteSpaceOppList;
            wrapperToReturn.detailsWrapper = detailsWrapper;
            wrapperToReturn.MessageType ='Success';
        }catch (DMLException e) {
            String message = e.getDmlMessage(0);
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        }catch (Exception e) {
            String message = e.getMessage();
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        }
        return wrapperToReturn;
    }
    
    @AuraEnabled
    public static returnMessageWrapper getConvertedWhiteSpaceOpportunities(Id recordId){
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        try{
            List<Whitespace_Potential_Opportunity__c> wsOppData = [SELECT Id,CurrencyIsoCode,Any_help_needed__c,Account_BU__c,Next_Step_s__c,
                                                                   Opportunity__c,Opportunity__r.OpportunityId__c,
                                                                   Potential_Value__c,Solution__c,Status__c,Name,
                                                                   Who_do_you_need_to_speak_to__c,Who_do_you_need_to_speak_to__r.Contact_Full_Name__c,
                                                                   Strategy_and_Goals__c,Strategy_and_Goals__r.Strategy_Name__c,Opportunity__r.Amount,Opportunity__r.closeDate,Opportunity__r.stageName,Opportunity__r.Opportunity_Nickname__c,Opportunity__r.Sales_Price_in_USD__c 
                                                                   FROM Whitespace_Potential_Opportunity__c WHERE Account_Plan__c=:recordId AND Status__c='Current Pipeline' AND (Opportunity__r.CloseDate = LAST_N_YEARS:5 OR Opportunity__r.CloseDate = THIS_YEAR) ORDER BY Opportunity__r.CloseDate];
            
            List<Account_Plan__c> accPlan = [Select Id,Account_Name__r.CurrencyIsoCode FROM Account_Plan__c WHERE Id= :recordId];
            String currencyFromAccount = accPlan[0].Account_Name__r.CurrencyIsoCode;
            ConvertedWhiteSpaceDetailsWrapper convertedOppWrapper = new ConvertedWhiteSpaceDetailsWrapper();
            List<WhiteSpaceOpportunityWrapper> whiteSpaceOppList = new List<WhiteSpaceOpportunityWrapper>(); 
            Decimal closedWonSalesValue = 0;
            Decimal openSalesValue = 0;
            Decimal closedWonSalesValueInUSD = 0;
            Decimal openSalesValueInUSD = 0;
            Integer serialNumber = 1;
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            for (Whitespace_Potential_Opportunity__c wsOpp : wsOppData) {
                WhiteSpaceOpportunityWrapper wrap = new WhiteSpaceOpportunityWrapper();
                wrap.strategyUrl = sfdcBaseURL+'/'+wsOpp.Strategy_and_Goals__c;
                wrap.whiteSpaceOppId = wsOpp.Id;
                wrap.strategyName = wsOpp.Strategy_and_Goals__r.Strategy_Name__c;
                wrap.serialNumber = serialNumber;
                if(wsOpp.Opportunity__c!=null){
                    wrap.opportunityName = wsOpp.Opportunity__r.OpportunityId__c;
                    wrap.opportunityUrl = sfdcBaseURL+'/'+wsOpp.Opportunity__c;
                    wrap.opportunityId = wsOpp.Opportunity__c;
                }
                wrap.contactName = wsOpp.Who_do_you_need_to_speak_to__r.Contact_Full_Name__c;
                wrap.contactId = wsOpp.Who_do_you_need_to_speak_to__c;
                wrap.contactUrl = sfdcBaseURL+'/'+wsOpp.Who_do_you_need_to_speak_to__c;
                wrap.nextStep = wsOpp.Next_Step_s__c;
                wrap.status = wsOpp.Status__c;
                wrap.accountBU = wsOpp.Account_BU__c;
                wrap.solution = wsOpp.Solution__c;
                wrap.strategy = wsOpp.Strategy_and_Goals__c;
                wrap.whiteSpaceCurrency = wsOpp.CurrencyIsoCode;
                wrap.closeDate = wsOpp.Opportunity__r.closeDate;
                wrap.salesPrice = wsOpp.Opportunity__r.Amount;
                wrap.salesPriceWithCurrency = currencyFromAccount + ' '+wsOpp.Opportunity__r.Amount;
                wrap.stageName = wsOpp.Opportunity__r.stageName;
                wrap.opportunityNickname = wsOpp.Opportunity__r.Opportunity_Nickname__c;
                if(wsOpp.Opportunity__r.stageName=='Closed/Won'){
                    closedWonSalesValue += (wsOpp.Opportunity__r.Amount!=null)?wsOpp.Opportunity__r.Amount:0;
                    closedWonSalesValueInUSD += wsOpp.Opportunity__r.Sales_Price_in_USD__c;
                }else if(wsOpp.Opportunity__r.stageName!='Closed/Won' || wsOpp.Opportunity__r.stageName!='Closed Lost'){
                    openSalesValue += (wsOpp.Opportunity__r.Amount!=null)?wsOpp.Opportunity__r.Amount:0;
                    openSalesValueInUSD += wsOpp.Opportunity__r.Sales_Price_in_USD__c;
                }
                whiteSpaceOppList.add(wrap);
                serialNumber++;
            }
            Decimal totalSalesValue = closedWonSalesValue + openSalesValue;
            Decimal totalSalesValueInUSD = closedWonSalesValueInUSD + openSalesValueInUSD;
            if(currencyFromAccount=='USD'){
                convertedOppWrapper.closedWonSalesValue = 'USD '+closedWonSalesValueInUSD;
                convertedOppWrapper.openSalesValue = 'USD '+openSalesValueInUSD;
                convertedOppWrapper.totalSalesValue = 'USD '+totalSalesValueInUSD;
            }else{
                convertedOppWrapper.closedWonSalesValue = currencyFromAccount +' '+ closedWonSalesValue+' ( USD '+closedWonSalesValueInUSD +' )';
                convertedOppWrapper.openSalesValue = currencyFromAccount +' '+ openSalesValue+' ( USD '+openSalesValueInUSD +' )';
                convertedOppWrapper.totalSalesValue = currencyFromAccount +' '+ totalSalesValue+' ( USD '+totalSalesValueInUSD +' )';
            }
            convertedOppWrapper.whiteSpaceOppList = whiteSpaceOppList;
            wrapperToReturn.listWrapper = convertedOppWrapper;
            wrapperToReturn.MessageType = 'Success';
        }catch (DMLException e) {
            String message = e.getDmlMessage(0);
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message =message;    
        }
        return wrapperToReturn;
    }
    
    @AuraEnabled
    public static returnMessageWrapper convertToOpportunity(Id accountPlanId,WhiteSpaceOpportunityWrapper wsOpp){
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        try{
            //Id accountId = null;
            //UserRecordAccess checkAccountAccess = new UserRecordAccess();
            //UserRecordAccess checkContactAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =:wsOpp.contactId];
            //If(checkContactAccess.HasReadAccess==true){
               Id accountId = [SELECT Id,AccountId FROM Contact WHERE Id=:wsOpp.contactId].AccountId;
            //}
            //if(accountId!=null){
                //checkAccountAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =:wsOpp.contactId];
            //}
            //if(checkAccountAccess.HasEditAccess==true){
                String description ='';
                if(!String.isBlank(wsOpp.solution) && !String.isBlank(wsOpp.helpNeeded)){
                    description = 'Solution : '+wsOpp.solution +'\n  Any help needed : '+wsOpp.helpNeeded;
                }else if(!String.isBlank(wsOpp.solution) && String.isBlank(wsOpp.helpNeeded)){
                    description = 'Solution : '+wsOpp.solution;
                }else if(String.isBlank(wsOpp.solution) && !String.isBlank(wsOpp.helpNeeded)){
                    description = 'Any help needed : '+wsOpp.helpNeeded;
                }
                Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=accountId);
                opportunity.ownerid=UserInfo.getUserId();
                opportunity.Billing_Contact__c=wsOpp.contactId;
                opportunity.Closedate=system.today();
                opportunity.Primary_Contact__c=wsOpp.contactId;
                opportunity.CurrencyIsoCode=wsOpp.whiteSpaceCurrency;
                opportunity.Amount=wsOpp.potentialValue;
                opportunity.Variation_Opportunity__c='NO';
                opportunity.StageName='New';   
                opportunity.nextStep = wsOpp.nextStep;
                opportunity.Business_Type__c = 'Expansion';
                opportunity.Forecast_Category__c = 'Pipeline';
                opportunity.Strategy_and_Goals__c = wsOpp.strategy;
                
                if(description!=''){
                    opportunity.description = description;
                }
                insert opportunity;
                
                Whitespace_Potential_Opportunity__c ws = new Whitespace_Potential_Opportunity__c();
                ws.Id = wsOpp.whiteSpaceOppId;
                ws.Opportunity__c = opportunity.Id;
                ws.Status__c = 'Current Pipeline';
                update ws;
                
                List<Strategy_and_Goal__c> strategyList = [Select Id,Opportunities_Linked__c from Strategy_and_Goal__c WHERE Id=:wsOpp.strategy];
                Strategy_and_Goal__c strategyToUpdate = new Strategy_and_Goal__c();
                strategyToUpdate.Id = strategyList[0].Id;
                strategyToUpdate.Opportunities_Linked__c = strategyList[0].Opportunities_Linked__c + 1;
                update strategyToUpdate;
                
                wrapperToReturn.MessageType = 'Success';
            //}
            //else{
                //wrapperToReturn.MessageType = 'NoConvertAccess';
            //}
            
            
        }catch (DMLException e) {
            String message = e.getDmlMessage(0);
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message =message;    
        }catch (Exception e) {
            String message = e.getMessage();
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message; 
            system.debug(e.getStackTraceString());
        }
        return wrapperToReturn;
    }
    
    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public StrategyAndWhiteSpaceWrapper detailsWrapper;
        @AuraEnabled public ConvertedWhiteSpaceDetailsWrapper listWrapper;
    }
    
    public class StrategyAndWhiteSpaceWrapper{
        @AuraEnabled public String accountPlanId;
        @AuraEnabled public String accountId;
        @AuraEnabled public Boolean isAccountPlanUnderReview;
        @AuraEnabled public String currencyFromAccount;
        @AuraEnabled public String totalPotentialValue;
        @AuraEnabled public List<WhiteSpaceOpportunityWrapper> whiteSpaceOppList;
    }
    
    public class ConvertedWhiteSpaceDetailsWrapper{
        @AuraEnabled public List<WhiteSpaceOpportunityWrapper> whiteSpaceOppList;
        @AuraEnabled public String closedWonSalesValue;
        @AuraEnabled public String openSalesValue;
        @AuraEnabled public String totalSalesValue;
    }
    
    public class WhiteSpaceOpportunityWrapper{
        
        @AuraEnabled public String opportunityName { get; set; }
        @AuraEnabled public String strategyName { get; set; }
        @AuraEnabled public String strategyUrl { get; set; }
        @AuraEnabled public String whiteSpaceOppId { get; set; }
        @AuraEnabled public Decimal potentialValue { get; set; }
        @AuraEnabled public String potentialValueWithCurrency { get; set; }
        @AuraEnabled public String contactName { get; set; }
        @AuraEnabled public String contactId { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String contactUrl { get; set; }
        @AuraEnabled public String solution { get; set; }
        @AuraEnabled public String accountBU { get; set; }
        @AuraEnabled public String nextStep { get; set; }
        @AuraEnabled public String oppId { get; set; }
        @AuraEnabled public Integer serialNumber { get; set; }
        @AuraEnabled public String opportunityUrl { get; set; }
        @AuraEnabled public String helpNeeded { get; set; }
        @AuraEnabled public String opportunityId { get; set; }
        @AuraEnabled public String strategy { get; set; }
        @AuraEnabled public String whiteSpaceCurrency { get; set; }
        @AuraEnabled public Date closeDate { get; set; }
        @AuraEnabled public Decimal salesPrice { get; set; }
        @AuraEnabled public String salesPriceWithCurrency { get; set; }
        @AuraEnabled public String stageName { get; set; }
        @AuraEnabled public String opportunityNickname { get; set; }
    }
}
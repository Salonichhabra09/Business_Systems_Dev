public without sharing class CurrentPipelineController {
    
    @AuraEnabled(cacheable=true)
    public static CurrentOpportunityDetailsWrapper getOpenOpportunitiesDetails(Id accountPlanId,String businessType){
        
        CurrentOpportunityDetailsWrapper wrapperToReturn = new CurrentOpportunityDetailsWrapper();
        //List<String> businessTypeList;
        // if(businessType=='Renewal'){
        //     businessTypeList = new List<String>{'Renewal'};
        //         }else if(businessType=='New Business/Cross Sell'){
        //             businessTypeList= new List<String>{'New customer: subscription','New customer: non-subscription','Cross-sell: subscription','Existing customer: non-subscription','migration'};
        //                 }//else if(businessType=='Cross Sell'){
                        //     businessTypeList= new List<String>{'Cross-sell: subscription','Existing customer: non-subscription','migration'};
                        //         }
        Account_Plan__c accplan = [select id , Account_Name__c,Account_Plan_Status__c , Account_Name__r.CurrencyIsoCode,Account_Plan_Type__c,Buying_Centre_Id__c
                                   from Account_Plan__c where id=:accountPlanId];
        
        List<Opportunity> oppData = new List<Opportunity>();
        if(accplan.Account_Plan_Type__c=='Regional'){
            List<Account> accList = [SELECT Id FROM Account WHERE Buying_Centre_Id__c= :accplan.Buying_Centre_Id__c];
            List<Id> accIds = new List<Id>();
            for (Account acc : accList) {
                accIds.add(acc.Id);
            }
            if(businessType=='Renewal'){
                oppData = [SELECT Id,Account.CurrencyIsoCode,Account.Account_Number__c,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems),Renewal_Date__c From Opportunity where AccountId IN :accIds AND StageName NOT IN ('Closed/Won','Closed Lost') AND Business_Type__c IN ('Renewal') ORDER BY CloseDate];
            }else{
                oppData = [SELECT Id,Account.CurrencyIsoCode,Account.Account_Number__c,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems),Renewal_Date__c From Opportunity where AccountId IN :accIds AND StageName NOT IN ('Closed/Won','Closed Lost') AND Business_Type__c NOT IN ('Renewal') ORDER BY CloseDate];
            }
            
        }else if(accplan.Account_Plan_Type__c=='Current'){
            if(businessType=='Renewal'){
                oppData = [SELECT Id,Account.CurrencyIsoCode,Account.Account_Number__c,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems),Renewal_Date__c From Opportunity where AccountId=:accplan.Account_Name__c AND StageName NOT IN ('Closed/Won','Closed Lost') AND Business_Type__c IN ('Renewal') ORDER BY CloseDate];
            }else{
                oppData = [SELECT Id,Account.CurrencyIsoCode,Account.Account_Number__c,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems),Renewal_Date__c From Opportunity where AccountId=:accplan.Account_Name__c AND StageName NOT IN ('Closed/Won','Closed Lost') AND Business_Type__c NOT IN ('Renewal') ORDER BY CloseDate];
            }
            
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
            if(businessType=='Renewal'){
                oppData = [SELECT Id,Account.CurrencyIsoCode,Account.Account_Number__c,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems),Renewal_Date__c From Opportunity where AccountId IN :allAccountIds AND StageName NOT IN ('Closed/Won','Closed Lost') AND Business_Type__c IN ('Renewal') ORDER BY CloseDate];
            }else{
                oppData = [SELECT Id,Account.CurrencyIsoCode,Account.Account_Number__c,OpportunityId__c,Opportunity_Nickname__c,Sales_Price_in_USD__c,Opportunity_ID18__c,NextStep,StageName,Multi_YearDeal__c,CloseDate,Amount,Account_LBU__c,Account.Global_Billing_Country__c,Client_Business_Function__c,(Select Id,Package__c from OpportunityLineItems),Renewal_Date__c From Opportunity where AccountId IN :allAccountIds AND StageName NOT IN ('Closed/Won','Closed Lost') AND Business_Type__c NOT IN ('Renewal') ORDER BY CloseDate];
            }            
        }
        List<CurrentOpportunityWrapper> currentPipeline = new List<CurrentOpportunityWrapper>(); 
        Integer serialNumber = 1;
        Decimal totalSalesValue = 0;
        Decimal totalSalesValueInUSD = 0;
        String currencyFromAccount = accplan.Account_Name__r.CurrencyIsoCode;
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        for (Opportunity opp : oppData) {
            CurrentOpportunityWrapper wrap = new CurrentOpportunityWrapper();
            wrap.opportunityUrl = sfdcBaseURL+'/'+opp.Id;
            wrap.serialNumber = serialNumber;
            wrap.opportunityName = opp.OpportunityId__c;
            wrap.oppId = opp.Opportunity_ID18__c;
            wrap.amount = opp.Amount;
            wrap.amountWithCurrency = opp.Amount!=null?opp.Account.CurrencyIsoCode + ' '+opp.Amount:opp.Account.CurrencyIsoCode + ' ' + 0;
            wrap.nextStep = opp.NextStep;
            wrap.stageName = opp.StageName;
            wrap.closeDate = opp.CloseDate;
            wrap.contractLength = opp.Multi_YearDeal__c;
            wrap.accountBU = opp.Account_LBU__c;
            if(opp.OpportunityLineItems.size()>0){
                Set<String> solution = new Set<String>();
                for (OpportunityLineItem lineItem : opp.OpportunityLineItems) {
                    solution.add(lineItem.Package__c);
                }
                wrap.solution = String.join(new List<String>(solution),',');
            }
            wrap.renewalDate = opp.Renewal_Date__c;
            wrap.opportunityNickname = opp.Opportunity_Nickname__c;
            wrap.dNumber = opp.Account.Account_Number__c;
            currentPipeline.add(wrap);
            serialNumber++;
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
    
    public class CurrentOpportunityDetailsWrapper{
        @AuraEnabled public String totalSalesValue;
        @AuraEnabled public List<CurrentOpportunityWrapper> currentPipeline;
    }
    
    public class CurrentOpportunityWrapper{
        
        @AuraEnabled public String opportunityName;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String amountWithCurrency;
        @AuraEnabled public Date closeDate;
        @AuraEnabled public String stageName;
        @AuraEnabled public String contractLength;
        @AuraEnabled public String solution;
        @AuraEnabled public String accountBU;
        @AuraEnabled public String nextStep;
        @AuraEnabled public String oppId;
        @AuraEnabled public Integer serialNumber;
        @AuraEnabled public String opportunityUrl;
        @AuraEnabled public Date renewalDate;
        @AuraEnabled public String opportunityNickname;
        @AuraEnabled public String dNumber;
    }
}
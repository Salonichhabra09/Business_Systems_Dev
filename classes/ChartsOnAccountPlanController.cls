public without sharing class ChartsOnAccountPlanController {
    
    @AuraEnabled(cacheable=true)
    public static ChartDataWrapper getOpportunitiesYearWise(Id accountPlanId){
        ChartDataWrapper wrapperToReturn = new ChartDataWrapper();
        List<CurrencyType> currencyTypeList = [select id,IsoCode,ConversionRate from CurrencyType where isActive = true] ;
        Map<String , Decimal> isoWithRateMap = new Map<String, Decimal>();
        for(CurrencyType c : currencyTypeList) {
            isoWithRateMap.put(c.IsoCode , c.ConversionRate) ;
        }
        Account_Plan__c accplan = [select id , Account_Name__c,Account_Plan_Status__c , Account_Name__r.CurrencyIsoCode,Account_Plan_Type__c,Buying_Centre_Id__c
                                   from Account_Plan__c where id=:accountPlanId];
        
        List<Id> accountIdList = new List<Id>();
        List<Opportunity> oppData = new List<Opportunity>();
        if(accplan.Account_Plan_Type__c=='Regional'){
            List<Account> accList = [SELECT Id FROM Account WHERE Buying_Centre_Id__c= :accplan.Buying_Centre_Id__c];
            List<Id> accIds = new List<Id>();
            for (Account acc : accList) {
                accIds.add(acc.Id);
            }
            accountIdList = accIds;
            oppData = [SELECT amount,CloseDate,currencyIsoCode FROM Opportunity WHERE AccountId IN :accIds AND StageName IN ('Closed/Won') AND amount!=null AND (CloseDate = LAST_N_YEARS:5) ORDER BY CloseDate];            
        }else if(accplan.Account_Plan_Type__c=='Current'){
            accountIdList.add(accplan.Account_Name__c);
            oppData = [SELECT amount,CloseDate,currencyIsoCode FROM Opportunity WHERE AccountId= :accplan.Account_Name__c AND StageName IN ('Closed/Won') AND amount!=null AND (CloseDate = LAST_N_YEARS:5) ORDER BY CloseDate];            
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
            accountIdList = new List<Id>(allAccountIds);
            oppData = [SELECT amount,CloseDate,currencyIsoCode FROM Opportunity WHERE AccountId IN :allAccountIds AND StageName IN ('Closed/Won') AND amount!=null AND (CloseDate = LAST_N_YEARS:5) ORDER BY CloseDate];            
        }
        //List<Opportunity> oppData = [SELECT amount,CloseDate,currencyIsoCode FROM Opportunity WHERE AccountId= :accountPlan[0].Account_Name__c AND StageName IN ('Closed/Won') AND amount!=null AND (CloseDate = LAST_N_YEARS:5) ORDER BY CloseDate];
        Map<Integer,Decimal> amountDataYearWise = new Map<Integer,Decimal>();
        for(Opportunity opportunity : oppData){
            if(amountDataYearWise.get(opportunity.CloseDate.year())!=null){
                amountDataYearWise.put(opportunity.CloseDate.year(),amountDataYearWise.get(opportunity.CloseDate.year())+((opportunity.amount/isoWithRateMap.get(opportunity.CurrencyIsoCode))* isoWithRateMap.get('USD')).setScale(2, RoundingMode.HALF_UP));
            }else{
                amountDataYearWise.put(opportunity.CloseDate.year(),((opportunity.amount/isoWithRateMap.get(opportunity.CurrencyIsoCode)) * isoWithRateMap.get('USD')).setScale(2, RoundingMode.HALF_UP));
            }
        }
        for (Integer key : amountDataYearWise.keySet()) {
            amountDataYearWise.put(key,amountDataYearWise.get(key).setScale(0,RoundingMode.HALF_UP));
        }
        system.debug(amountDataYearWise);
        wrapperToReturn.dataMap = amountDataYearWise;
        wrapperToReturn.accountId = String.join(accountIdList,',');
        return wrapperToReturn;
    }
    
    @AuraEnabled(cacheable=true)
    public static ChartDataWrapper getOpportunitiesYearWiseWithCI(Id accountPlanId){
        ChartDataWrapper wrapperToReturn = new ChartDataWrapper();
        List<CurrencyType> currencyTypeList = [select id,IsoCode,ConversionRate from CurrencyType where isActive = true] ;
        Map<String , Decimal> isoWithRateMap = new Map<String, Decimal>();
        for(CurrencyType c : currencyTypeList) {
            isoWithRateMap.put(c.IsoCode , c.ConversionRate) ;
        }
        Account_Plan__c accplan = [select id , Account_Name__c,Account_Plan_Status__c , Account_Name__r.CurrencyIsoCode,Account_Plan_Type__c,Buying_Centre_Id__c
                                   from Account_Plan__c where id=:accountPlanId];
        
        List<Id> accountIdList = new List<Id>();
        List<Opportunity> oppData = new List<Opportunity>();
        if(accplan.Account_Plan_Type__c=='Regional'){
            List<Account> accList = [SELECT Id FROM Account WHERE Buying_Centre_Id__c= :accplan.Buying_Centre_Id__c];
            List<Id> accIds = new List<Id>();
            for (Account acc : accList) {
                accIds.add(acc.Id);
            }
            accountIdList = accIds;
            oppData = [SELECT amount,CloseDate,currencyIsoCode,TM_Phase__c FROM Opportunity WHERE AccountId IN :accIds AND StageName IN ('Closed/Won') AND amount!=null AND (CloseDate = LAST_N_YEARS:5) AND (TM_Phase__c='Talent Acquisition' OR TM_Phase__c='Talent Management') ORDER BY CloseDate];            
        }else if(accplan.Account_Plan_Type__c=='Current'){
            accountIdList.add(accplan.Account_Name__c);
            oppData = [SELECT amount,CloseDate,currencyIsoCode,TM_Phase__c FROM Opportunity WHERE AccountId= :accplan.Account_Name__c AND StageName IN ('Closed/Won') AND amount!=null AND (CloseDate = LAST_N_YEARS:5) AND (TM_Phase__c='Talent Acquisition' OR TM_Phase__c='Talent Management') ORDER BY CloseDate];            
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
            accountIdList = new List<Id>(allAccountIds);
            oppData = [SELECT amount,CloseDate,currencyIsoCode,TM_Phase__c FROM Opportunity WHERE AccountId IN :allAccountIds AND StageName IN ('Closed/Won') AND amount!=null AND (CloseDate = LAST_N_YEARS:5) AND (TM_Phase__c='Talent Acquisition' OR TM_Phase__c='Talent Management') ORDER BY CloseDate];            
        }    
        
        //List<Opportunity> oppData = [SELECT amount,CloseDate,currencyIsoCode,TM_Phase__c FROM Opportunity WHERE AccountId= :accountPlan[0].Account_Name__c AND StageName IN ('Closed/Won') AND amount!=null AND (CloseDate = LAST_N_YEARS:5) AND (TM_Phase__c='Talent Acquisition' OR TM_Phase__c='Talent Management') ORDER BY CloseDate];
        Map<Integer,Decimal> amountDataTA = new Map<Integer,Decimal>();
        Map<Integer,Decimal> amountDataTM = new Map<Integer,Decimal>();
        Set<Integer> years = new Set<Integer>();
        for(Opportunity opportunity : oppData){
            years.add(opportunity.CloseDate.year());
            if(opportunity.TM_Phase__c=='Talent Acquisition'){
                if(amountDataTA.get(opportunity.CloseDate.year())!=null){
                    amountDataTA.put(opportunity.CloseDate.year(),amountDataTA.get(opportunity.CloseDate.year())+((opportunity.amount/isoWithRateMap.get(opportunity.CurrencyIsoCode))* isoWithRateMap.get('USD')).setScale(2, RoundingMode.HALF_UP));
                }else{
                    amountDataTA.put(opportunity.CloseDate.year(),((opportunity.amount/isoWithRateMap.get(opportunity.CurrencyIsoCode)) * isoWithRateMap.get('USD')).setScale(2, RoundingMode.HALF_UP));
                }
                if(amountDataTM.get(opportunity.CloseDate.year())==null){
                    amountDataTM.put(opportunity.CloseDate.year(),0);
                }
            }else{
                if(amountDataTM.get(opportunity.CloseDate.year())!=null){
                    amountDataTM.put(opportunity.CloseDate.year(),amountDataTM.get(opportunity.CloseDate.year())+((opportunity.amount/isoWithRateMap.get(opportunity.CurrencyIsoCode))* isoWithRateMap.get('USD')).setScale(2, RoundingMode.HALF_UP));
                }else{
                    amountDataTM.put(opportunity.CloseDate.year(),((opportunity.amount/isoWithRateMap.get(opportunity.CurrencyIsoCode)) * isoWithRateMap.get('USD')).setScale(2, RoundingMode.HALF_UP));
                }
                if(amountDataTA.get(opportunity.CloseDate.year())==null){
                    amountDataTA.put(opportunity.CloseDate.year(),0);
                }
            }
            
        }
        
        for (Integer key : amountDataTM.keySet()) {
            amountDataTM.put(key,amountDataTM.get(key).setScale(0,RoundingMode.HALF_UP));
            amountDataTA.put(key,amountDataTA.get(key).setScale(0,RoundingMode.HALF_UP));
        }
        
        wrapperToReturn.dataMap = amountDataTA;
        wrapperToReturn.dataMap1 = amountDataTM;
        wrapperToReturn.accountId = String.join(accountIdList,',');
        return wrapperToReturn;
    }
    
    public class ChartDataWrapper{
        @AuraEnabled public String accountId;
        @AuraEnabled public Map<Integer,Decimal> dataMap;
        @AuraEnabled public Map<Integer,Decimal> dataMap1;
    }
}
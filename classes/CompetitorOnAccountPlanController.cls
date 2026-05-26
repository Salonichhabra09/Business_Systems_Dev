public without sharing class CompetitorOnAccountPlanController {
    //Changes start by Prachi SSE-21664
    /* public static List<CompetitorWrapper> getCompetitorDetails(Id accountId){

List<Competitor__c> compData = [SELECT Id,Name,Competing_Solution_Area__c,Incumbent_Value__c,Account__r.BU__c,
Account__r.Global_Billing_Country__c,Competitor__r.Name,Industry__c,Incumbent_Renewal_Date__c,
Opportunity__c,Opportunity__r.Name,Incumbent_Vendor__c 
FROM Competitor__c WHERE Account__c=:accountId];
List<CompetitorWrapper> wrapperList = new List<CompetitorWrapper>(); 
Integer serialNumber = 1;
String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
for (Competitor__c comp : compData) {
CompetitorWrapper wrap = new CompetitorWrapper();
wrap.competitorUrl = sfdcBaseURL+'/'+comp.Id;
wrap.serialNumber = serialNumber;
wrap.competitorName = comp.Competitor__r.Name;
wrap.id = comp.Id;
wrap.estimatedCustomerSpend = comp.Incumbent_Value__c;
wrap.solution = comp.Competing_Solution_Area__c;
wrap.areaDetails = comp.Account__r.BU__c+'/'+comp.Account__r.Global_Billing_Country__c;
if(comp.Opportunity__c!=null){
wrap.opportunityName = comp.Opportunity__r.Name;
wrap.opportunityUrl = sfdcBaseURL+'/'+comp.Opportunity__c;
}
wrap.industry = comp.Industry__c;
wrap.incumbentVendor = comp.Incumbent_Vendor__c;
wrap.incumbentDate = comp.Incumbent_Renewal_Date__c;
wrapperList.add(wrap);
serialNumber++;
}
return wrapperList;
}

*/
    
    @AuraEnabled(cacheable=true)
    public static List<FinalCompetitorWrapper> getCompetitorDetails(Id accountId, String apType){
        
        List<Competitor__c> compData = new List<Competitor__c>();
        String BuyingCentreId = [Select id , Buying_Centre_Id__c from account where id = :accountId].Buying_Centre_Id__c;
        
        if(apType == 'Current'){ 
            compData = [SELECT Id,Name,Competing_Solution_Area__c,Account__r.Account_Number__c,Account__c,
                        Incumbent_Value__c,Account__r.BU__c,Account__r.Global_Billing_Country__c,
                        Competitor__r.Name,Industry__c,Opportunity__c,Opportunity__r.Name,Incumbent_Value_in_USD__c,
                        Incumbent_Vendor__c,Incumbent_Renewal_Date__c,Competitor__c,CurrencyIsoCode
                        FROM Competitor__c WHERE Account__c=:accountId];
        }
        else if(apType == 'Global') {
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
            
            compData = [SELECT Id,Name,Competing_Solution_Area__c,Account__r.Account_Number__c,Account__c,Competitor__c,
                        Incumbent_Value__c,Account__r.BU__c,Account__r.Global_Billing_Country__c,Incumbent_Value_in_USD__c,
                        Competitor__r.Name,Industry__c,Opportunity__c,Opportunity__r.Name,CurrencyIsoCode,
                        Incumbent_Vendor__c,Incumbent_Renewal_Date__c
                        FROM Competitor__c WHERE Account__c IN :allAccountIds];
        }
        else if(apType == 'Regional'){
            compData = [SELECT Id,Name,Competing_Solution_Area__c,Account__r.Account_Number__c,Account__c,Incumbent_Value_in_USD__c,
                        Incumbent_Value__c,Account__r.BU__c,Account__r.Global_Billing_Country__c,
                        Competitor__r.Name,Industry__c,Opportunity__c,Opportunity__r.Name,
                        Incumbent_Vendor__c,Incumbent_Renewal_Date__c,Competitor__c,CurrencyIsoCode
                        FROM Competitor__c WHERE Account__c IN (Select id from account where Buying_Centre_Id__c =:BuyingCentreId)
                       ];
        }
   
        List<FinalCompetitorWrapper> finalWrapperList = new List<FinalCompetitorWrapper>();
        
        Set<Id> competitorAccountId = new Set<Id>();
       
        
        if(!compData.isEmpty()){
            for (Competitor__c comp : compData) {
                competitorAccountId.add(comp.Competitor__c);
            } 
        }
         
         String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
         Integer MainTableSno = 0;
        if(!competitorAccountId.isEmpty()){
               
            for(Id cmpAcc : competitorAccountId){
                MainTableSno ++;
                FinalCompetitorWrapper fcw = new  FinalCompetitorWrapper();
                List<CompetitorWrapper> wrapperList = new List<CompetitorWrapper>();
                Decimal totalSpend = 0; 
                Integer serialNumber = 0; 
                for (Competitor__c comp : compData) {
                   
                    if(cmpAcc == comp.Competitor__c){ 
                        serialNumber++;
                        if(comp.Incumbent_Value_in_USD__c != null ){
                            totalSpend = totalSpend + comp.Incumbent_Value_in_USD__c;    
                        }
                       
                        CompetitorWrapper wrap = new CompetitorWrapper();
                        fcw.compAccountUrl =  sfdcBaseURL+'/'+comp.Competitor__c;
                        fcw.competitorAccName =  comp.Competitor__r.Name;
                         
                      //  wrap.competitorUrl = sfdcBaseURL+'/'+comp.Id;
                        wrap.serialNumber = serialNumber;
                        wrap.competitorName = comp.Competitor__r.Name;
                        wrap.id = comp.Id;
                        if(comp.Incumbent_Value__c != null ){
                             wrap.estimatedCustomerSpend = comp.CurrencyIsoCode+' ' + comp.Incumbent_Value__c;
                        }
                       
                        wrap.solution = comp.Competing_Solution_Area__c;
                        wrap.incumbentDate = comp.Incumbent_Renewal_Date__c;
                        wrap.areaDetails = comp.Account__r.BU__c+'/'+comp.Account__r.Global_Billing_Country__c;
                        if(comp.Opportunity__c!=null){
                            wrap.opportunityName = comp.Opportunity__r.Name;
                            wrap.opportunityUrl = sfdcBaseURL+'/'+comp.Opportunity__c;
                        }
                        wrap.industry = comp.Industry__c;
                        wrap.incumbentVendor = comp.Incumbent_Vendor__c;  
                         
                         wrapperList.add(wrap);
                             
                        
                    }
                     
                     
                }
                
                fcw.totalEstimatedCustomerSpend ='USD ' + totalSpend +'$';
                fcw.competitorDetails = wrapperList;
                fcw.MainTableSno = MainTableSno;
                finalWrapperList.add(fcw);
                
            }
            
        }
       
        return finalWrapperList;
    }
    
    //Changes end by Prachi SSE-21664
    public class CompetitorWrapper{
        
        @AuraEnabled public String competitorName { get; set; }
        @AuraEnabled public String estimatedCustomerSpend { get; set; }
        @AuraEnabled public String solution { get; set; }
        @AuraEnabled public String areaDetails { get; set; }
        @AuraEnabled public String strategyToContainOrDisplace { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String competitorUrl { get; set; }
        @AuraEnabled public Integer serialNumber { get; set; }
        @AuraEnabled public String opportunityUrl { get; set; }
        @AuraEnabled public String opportunityName { get; set; }
        @AuraEnabled public String industry { get; set; }
        @AuraEnabled public String incumbentVendor { get; set; }
        @AuraEnabled public Date incumbentDate { get; set; }
    }
    //Changes start by Prachi SSE-21664 
    public class FinalCompetitorWrapper{
        @AuraEnabled public String compAccountUrl{get; set; }
        @AuraEnabled public String totalEstimatedCustomerSpend { get; set; }
        @AuraEnabled public String competitorAccName { get; set; }
        @AuraEnabled public List<CompetitorWrapper> competitorDetails { get; set; }
        @AuraEnabled public Integer MainTableSno{ get; set; }
    }
    //Changes end by Prachi SSE-21664  
    
}
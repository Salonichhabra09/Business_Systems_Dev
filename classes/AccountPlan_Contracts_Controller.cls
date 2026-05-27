public without sharing class AccountPlan_Contracts_Controller {
    @AuraEnabled(cacheable=true)
    public static List<ContractsWrapper> getAccountContracts(String recordId){
     //Changes start as part of SSE-21663
        List<Opportunity> recList  = new List<Opportunity>();
        List<Account_Plan__c> accplanList = [Select id,Account_Plan_Type__c,Buying_Centre_Id__c,Account_Name__c
                                             from Account_Plan__c where id =:recordId ]; //Added as part of SSE-21663
        String apType = '';
        String buyingCentreId = '' ;
        String accId = '' ;
        if(!accplanList.isEmpty()){
            apType = accplanList[0].Account_Plan_Type__c;
            buyingCentreId = accplanList[0].Buying_Centre_Id__c;
            accId = accplanList[0].Account_Name__c;
        }
        
        if(apType =='Regional'){
              recList = [SELECT Id, AccountId , ContractId, Multi_YearDeal__c, Amount, Sales_Price_in_USD__c, Contract.Renewal_Date__c, 
                Contract.ContractType__c, Contract.Name, Contract.ContractNumber, Contract.Contract_End_Date__c,
                Renewal_Date__c,account.Account_Number__c,account.name,
                (SELECT Id,  Package__c, Solution__c, Quantity FROM OpportunityLineItems )
                FROM Opportunity
                WHERE Contract.Contract_End_Date__c > TODAY 
                AND Opportunity_Deal_Year__c = 1  
                AND AccountId IN (SELECT id FROM Account WHERE Buying_Centre_Id__c =: buyingCentreId)
                ORDER BY ContractId DESC];

        }
        else if(apType == 'Global'){
            Set<Id> allAccountIds = new Set<Id>{accId};
            Set<Id> parentIds = new Set<Id>{accId};
            List<Account> childAccounts = new List<Account>();
            do {
                childAccounts = [SELECT Id FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                parentIds.clear();
                for (Account child : childAccounts){
                    parentIds.add(child.Id);
                    allAccountIds.add(child.Id);
                }
            } while (childAccounts.size() > 0);
       
                recList = [SELECT Id, AccountId , ContractId, Multi_YearDeal__c, Amount, Sales_Price_in_USD__c, Contract.Renewal_Date__c, 
                Contract.ContractType__c, Contract.Name, Contract.ContractNumber, Contract.Contract_End_Date__c,Renewal_Date__c,
                           account.Account_Number__c,account.name,
                (SELECT Id,  Package__c, Solution__c, Quantity FROM OpportunityLineItems )
                FROM Opportunity
                WHERE Contract.Contract_End_Date__c > TODAY 
                AND Opportunity_Deal_Year__c = 1  
                AND AccountId IN :allAccountIds
                ORDER BY ContractId DESC]; 
        }
        else if(apType =='Current'){
           
       recList = [SELECT Id, AccountId , ContractId, Multi_YearDeal__c, Amount, Sales_Price_in_USD__c, Contract.Renewal_Date__c, 
                Contract.ContractType__c, Contract.Name, Contract.ContractNumber, Contract.Contract_End_Date__c,Renewal_Date__c,
                  account.Account_Number__c,account.name,
                (SELECT Id,  Package__c, Solution__c, Quantity FROM OpportunityLineItems )
                FROM Opportunity
                WHERE Contract.Contract_End_Date__c > TODAY 
                AND Opportunity_Deal_Year__c = 1  
                AND AccountId IN (SELECT Account_Name__c FROM Account_Plan__c WHERE Id =: recordId)
                ORDER BY ContractId DESC];
        }  
        //Changes end as part of SSE-21663
        List<ContractsWrapper> result = new list<ContractsWrapper>();

        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();

        if(!recList.isEmpty()){
                Map<ID, Decimal> contractOppAmmountMap = new Map<ID, Decimal>();
                Map<Id, List<Opportunity>> contractOppMap = new Map<Id, List<Opportunity>>();
                Map<Id, String> contractOppSolutionMap = new Map<Id, String>();
                Map<Id, String> contractRenewalDateMap = new Map<Id, String>();
                Map<Id, String> contractContractTypeMap = new Map<Id, String>(); 
                Map<Id, ContractsWrapper> contractContractWrapMap = new Map<Id, ContractsWrapper>();
                Map<Id, Double> contractOppOLIQuantityMap = new Map<Id, Double>();
                Double totalOLIQuantity = 0;
                String oliSolutions = '';
            for (Opportunity item : recList) {
                totalOLIQuantity = 0;
                oliSolutions = '';
                for (OpportunityLineItem oli : item.OpportunityLineItems) {
                    totalOLIQuantity = totalOLIQuantity + oli.Quantity;
                    system.debug('oli' + oli);
                    if(oliSolutions != ''){
                        if(oli.Package__c != null && oli.Package__c != ''){//Added by Prachi
                          if(!oliSolutions.contains(oli.Package__c)){
                           
                            oliSolutions = oliSolutions +',' + oli.Package__c;
                        }  
                        }
                        
                    } else {
                        if(oli.Package__c != null && oli.Package__c != ''){
                             oliSolutions = oli.Package__c;
                        }
                       
                    }
                }                
                if(contractContractWrapMap.containsKey(item.ContractId)) {
                    contractContractWrapMap.get(item.ContractId).oliSolution = contractOppSolutionMap.get(item.ContractId) + ', ' + oliSolutions;
                    contractContractWrapMap.get(item.ContractId).totalAmmount = contractOppAmmountMap.get(item.ContractId) + item.Sales_Price_in_USD__c;
                    contractContractWrapMap.get(item.ContractId).oliQuantity = contractOppOLIQuantityMap.get(item.ContractId) + totalOLIQuantity;
                } else {
                    ContractsWrapper rec = new ContractsWrapper();
                    /* Commented by Prachi
rec.renewalStartDate = String.valueOf(item.Contract.Renewal_Date__c);*/
                    rec.renewalStartDate = String.valueOf(item.Renewal_Date__c);//Added by Prachi 
                    rec.contractEndDate = String.valueOf(item.Contract.Contract_End_Date__c);
                    rec.contractLength = item.Multi_YearDeal__c;
                    
                    rec.contractType = item.Contract.ContractType__c;
                    rec.id = (String)item.ContractId;
                    rec.oliSolution = oliSolutions;
                    rec.totalAmmount = item.Sales_Price_in_USD__c;
                    rec.oliQuantity = totalOLIQuantity;
                    rec.contractName= item.Contract.Name;
                    rec.url = sfdcBaseURL+'/'+ item.ContractId;
                    rec.contractNumber = item.Contract.ContractNumber;
                    rec.DNumber = item.account.name +' (' +item.account.Account_Number__c +')';
                    contractContractWrapMap.put(item.ContractId, rec);

                }
            }
            result = contractContractWrapMap.values();
        }
        return result;                                      
    }


    public class ContractsWrapper{

        @AuraEnabled public Decimal totalAmmount;
        @AuraEnabled public String renewalStartDate;
        @AuraEnabled public String id;
        @AuraEnabled public String contractType;
        @AuraEnabled public String accountId;
        @AuraEnabled public String oliSolution;
        @AuraEnabled public Double oliQuantity;
        @AuraEnabled public String url;
        @AuraEnabled public String contractName;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String contractEndDate; 
        @AuraEnabled public String contractLength;
        @AuraEnabled public String DNumber;//Changes as part of SSE-21663
    }
}
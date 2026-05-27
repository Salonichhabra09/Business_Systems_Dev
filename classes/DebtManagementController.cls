public without sharing class DebtManagementController {
    
    @AuraEnabled(cacheable=true)
    public static DebtInformationWrapper getDebtInformation(Id recordId, String objectApiName){
        DebtInformationWrapper wrapperToReturn = new DebtInformationWrapper();
        List<Contract_Invoice_Header__c> invoiceHeaderList = new List<Contract_Invoice_Header__c>();
        Map<String,List<Contract_Invoice_Header__c>> opportunityDetailsMap = new Map<String,List<Contract_Invoice_Header__c>>();
        String debtStatus = 'Green';
        Decimal unpaidAmount = 0;
        String currencyCode = '';
        Boolean useOrderInvoices = false;
        
        if(objectApiName == 'Account'){
            
            invoiceHeaderList = [SELECT Id, Name, Unpaid_Amount__c, Payment_Status__c, Debt_Status__c, CurrencyIsoCode, Order__r.Opportunity.OpportunityId__c,Order__r.OpportunityId 
                                 FROM Contract_Invoice_Header__c
                                 WHERE Invoice_Account__c = :recordId AND (Debt_Status__c LIKE '%amber%' OR Debt_Status__c LIKE '%red%')];
            
        }else if(objectApiName == 'Opportunity'){
            
            Opportunity opportunity = [SELECT Id, AccountId 
                                       FROM Opportunity 
                                       WHERE Id = :recordId ];
            
            invoiceHeaderList = [SELECT Id, Name, Unpaid_Amount__c, Payment_Status__c, Debt_Status__c, CurrencyIsoCode 
                                 FROM Contract_Invoice_Header__c
                                 WHERE Invoice_Account__c = :opportunity.AccountId AND (Debt_Status__c LIKE '%amber%' OR Debt_Status__c LIKE '%red%')];
        }else if(objectApiName == 'Order'){
            Order order = [SELECT Id, AccountId 
                                       FROM Order 
                                       WHERE Id = :recordId ];
            
            List<Contract_Invoice_Header__c> orderInvoiceHeaders = [SELECT Id, Name, Unpaid_Amount__c, Payment_Status__c, Debt_Status__c, CurrencyIsoCode 
                                 FROM Contract_Invoice_Header__c
                                 WHERE Order__c = :recordId AND (Debt_Status__c LIKE '%amber%' OR Debt_Status__c LIKE '%red%')];
            
            if(orderInvoiceHeaders.isEmpty()){
               invoiceHeaderList = [SELECT Id, Name, Unpaid_Amount__c, Payment_Status__c, Debt_Status__c, CurrencyIsoCode 
                                 FROM Contract_Invoice_Header__c
                                 WHERE Invoice_Account__c = :order.AccountId AND (Debt_Status__c LIKE '%amber%' OR Debt_Status__c LIKE '%red%')]; 
            }else{
                invoiceHeaderList = orderInvoiceHeaders;
                useOrderInvoices = true;
            }
            
        }
        
        if(!invoiceHeaderList.isEmpty()){
            
            currencyCode = invoiceHeaderList[0].CurrencyIsoCode.subString(0,3);
            
            for(Contract_Invoice_Header__c invoice : invoiceHeaderList){
                
                unpaidAmount += invoice.Unpaid_Amount__c;
                if(objectApiName == 'Account'){
                    if(opportunityDetailsMap.get(invoice.Order__r.Opportunity.OpportunityId__c) == null){
                        List<Contract_Invoice_Header__c> opportunityInvoiceList = new List<Contract_Invoice_Header__c>{invoice};
                            opportunityDetailsMap.put(invoice.Order__r.Opportunity.OpportunityId__c, opportunityInvoiceList);
                    }else{
                        opportunityDetailsMap.get(invoice.Order__r.Opportunity.OpportunityId__c).add(invoice);
                    }
                }
                
                if(invoice.Debt_Status__c.contains('Red')){
                    debtStatus = 'Red';
                }else if(debtStatus != 'Red'){
                    debtStatus = 'Amber';
                }
            }
        }
        wrapperToReturn.debtStatus = debtStatus;
        wrapperToReturn.unpaidAmount = unpaidAmount;
        wrapperToReturn.accountCurrency = currencyCode;
        
        if(objectApiName == 'Account'){
            wrapperToReturn.opportunityDetailsMap = opportunityDetailsMap;  
        }
        String breakLine = objectApiName == 'Order' ? ' ' : '<br>' ;
        String cautionMessage = objectApiName == 'Order' ? '' : 'Please practice caution before raising order form.' ;
        String objectName = useOrderInvoices == true ? 'Order' : 'Account';
        if(debtStatus == 'Red'){
            wrapperToReturn.message = objectName + ' payment overdue for more than 60 days.'+breakLine + cautionMessage;
        }else if(debtStatus == 'Amber'){
            wrapperToReturn.message = objectName + ' payment overdue for more than 45 days.'+breakLine + cautionMessage;
        }else{
            wrapperToReturn.message = 'No pending payments for more than 45 days.'+breakLine+'You’re good to go.';
        }
        
        
        return wrapperToReturn;
    }
    
    public class DebtInformationWrapper{
        
        @AuraEnabled public String debtStatus {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public Decimal unpaidAmount {get;set;}
        @AuraEnabled public String accountCurrency {get;set;}
        @AuraEnabled public Map<String,List<Contract_Invoice_Header__c>> opportunityDetailsMap {get;set;}
    }
    
}
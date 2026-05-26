trigger ContractInvoiceLine_Trigger on Contract_Invoice_Line__c (before update,before insert,after insert) {
 if(Trigger_Activation__c.getInstance('ContractInvoiceLine_Trigger').Active__c){
    if(trigger.isUpdate){
        if(trigger.isBefore){     
            system.debug('-- Prachi Inside Trigger --> Before Update');
            system.debug('-- Prachi Trigger New --> Before Update' + trigger.new);
            ContractInvoiceLine_CheckIMLookupClass.SearchIMLookup(trigger.new, Trigger.oldmap);
        }
    }
    if(Trigger.isInsert){
        if(trigger.isBefore){
            ContractInvoiceLine_CheckIMLookupClass.ChangeCurrencyIsoCode(trigger.new); 
             //Changes Start SSE-17631 - Prachi  
            system.debug('-- Prachi Inside Trigger --> Before Insert');
            system.debug('-- Prachi Trigger New --> BEfore Insert' + trigger.new);
             ContractInvoiceLine_CheckIMLookupClass.SearchIMLookup(trigger.new,null);
              //Changes End SSE-17631 
        }  
    
    }
  }   
}
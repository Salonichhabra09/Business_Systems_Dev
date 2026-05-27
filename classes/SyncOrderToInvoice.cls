Public with sharing class SyncOrderToInvoice{

    public static void SyncDates(list<order> OrderNewList,Map<Id, order>OrdOldMap) {
        System.debug('Number of Queries used -- SyncOrderToInvoice.SyncDates START ------- ' + Limits.getQueries());
        Set<ID> Orderids = new Set<ID>();
        List<Contract_Invoice_Header__c> updateInvoiceList = new List<Contract_Invoice_Header__c>();
        Date newDate ;
        Date oldDate;
        Integer NumberOfDays;
    
        for (Order o: OrderNewList) {      
        	if(o.EffectiveDate!= OrdOldMap.get(o.Id).EffectiveDate) {
                    oldDate = OrdOldMap.get(o.Id).EffectiveDate;
                    newDate = o.EffectiveDate;
                    Orderids.add(o.Id);
                    NumberOfDays = oldDate.daysBetween(newDate);
            }
        }
        System.debug(NumberOfDays);
        system.debug(Orderids);
        
        if(Orderids.size() > 0 ){ //added
            List<Contract_Invoice_Header__c> invoiceHeaderlist = [Select Id, Name, Service_Start_Date__c, Service_End_Date__c, Order__r.Id , Order__r.Contract.Product_Billing_Frequency__c
                                                                  from Contract_Invoice_Header__c 
                                                                  Where Order__r.Id IN :Orderids 
                                                                  And Is_Auto_Created__c = true 
                                                                  order by Service_Start_Date__c asc];
        
            if(invoiceHeaderlist.size() > 0 ) {
                for(Contract_Invoice_Header__c head : invoiceHeaderlist) { 
                    system.debug('head.Service_Start_Date__c'+head.Service_Start_Date__c);   
                    system.debug('Service_End_Date__c' + head.Service_End_Date__c);
                    head.Service_Start_Date__c= head.Service_Start_Date__c.addDays(NumberOfDays) ;
                    head.Service_End_Date__c = head.Service_End_Date__c.addDays(NumberOfDays) ;
                    system.debug( head.Service_Start_Date__c); 
                    system.debug('Service_End_Date__c' + head.Service_End_Date__c);
                    updateInvoiceList.add(head);
                } 
            }
            
            if(updateInvoiceList.size() > 0){ //added
               update  updateInvoiceList; 
            }
        }
        System.debug('Number of Queries used -- SyncOrderToInvoice.SyncDates END ------- ' + Limits.getQueries());
    }
    
    
}
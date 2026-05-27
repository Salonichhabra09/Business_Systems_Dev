public class SFDC2SUNHistoryTriggerManager {
    
    public static void rollupTransactionAmountOnInvoiceHeader(List<SFDC2Sun_Transfer_or_Sync_History__c> transactionRecords){
        
        List<SFDC2Sun_Transfer_or_Sync_History__c> validRecords = new List<SFDC2Sun_Transfer_or_Sync_History__c>();
        List<String> journalNumberList = new List<String>();
        List<Id> invoiceHeaderIds = new List<Id>();
        List<SFDC2Sun_Transfer_or_Sync_History__c> transactionRecordsToDelete = new List<SFDC2Sun_Transfer_or_Sync_History__c>();
        
        for(SFDC2Sun_Transfer_or_Sync_History__c transactionRecord :transactionRecords ){
            if(transactionRecord.Is_Transaction__c == true && transactionRecord.Invoice_Header__c !=null){
                validRecords.add(transactionRecord);
                if(invoiceHeaderIds.contains(transactionRecord.Invoice_Header__c) == false){
                    invoiceHeaderIds.add(transactionRecord.Invoice_Header__c);
                }
                journalNumberList.add(transactionRecord.Journal_Number__c); 
            }
        }
        
        if(!validRecords.isEmpty()){
            Map<String, SFDC2Sun_Transfer_or_Sync_History__c> existingRecordsMap = new Map<String, SFDC2Sun_Transfer_or_Sync_History__c>();
            List<SFDC2Sun_Transfer_or_Sync_History__c> existingRecords = [SELECT Id, Journal_Number__c, Transaction_Date__c, Transaction_Date_String__c
                                                                          FROM SFDC2Sun_Transfer_or_Sync_History__c
                                                                          WHERE Journal_Number__c IN :journalNumberList AND Id NOT IN :validRecords and Is_Transaction__c = true];
            
            for(SFDC2Sun_Transfer_or_Sync_History__c historyRecord : existingRecords){
                if(existingRecordsMap.get(historyRecord.Journal_Number__c) == null){
                    existingRecordsMap.put(historyRecord.Journal_Number__c,historyRecord);
                }
            }
            
            List<Contract_Invoice_Header__c> invoiceHeaderList = [SELECT Id, Invoice_Transaction_Amount__c 
                                                                  FROM Contract_Invoice_Header__c 
                                                                  WHERE Id IN :invoiceHeaderIds];
            
            Map<Id,Decimal> transactionAmountMap = new Map<Id,Decimal>();
            for(Contract_Invoice_Header__c invoice : invoiceHeaderList){
                if(invoice.Invoice_Transaction_Amount__c == null || invoice.Invoice_Transaction_Amount__c == 0){
                    transactionAmountMap.put(invoice.Id,0);
                }else{
                    transactionAmountMap.put(invoice.Id,invoice.Invoice_Transaction_Amount__c);
                }
            }
            
            for(SFDC2Sun_Transfer_or_Sync_History__c transactionRecord :validRecords ){
                if(transactionAmountMap.get(transactionRecord.Invoice_Header__c)!=null){
                    Decimal updatedAmount = 0 ;
                    if(transactionRecord.Transaction_Type__c == 'Debit'){
                        updatedAmount = transactionAmountMap.get(transactionRecord.Invoice_Header__c) + transactionRecord.Transaction_Amount__c;
                    }else if(transactionRecord.Transaction_Type__c == 'Credit'){
                        updatedAmount = transactionAmountMap.get(transactionRecord.Invoice_Header__c) - transactionRecord.Transaction_Amount__c;
                    }
                    transactionAmountMap.put(transactionRecord.Invoice_Header__c,updatedAmount);
                }
                if(transactionRecord.Journal_Number__c !=null && existingRecordsMap.get(transactionRecord.Journal_Number__c)!=null){
                    transactionRecordsToDelete.add(existingRecordsMap.get(transactionRecord.Journal_Number__c));
                }
            }
            
            List<Contract_Invoice_Header__c> invoicesToUpdate = new List<Contract_Invoice_Header__c>();
            for(Id invoiceId : transactionAmountMap.KeySet()){
                
                Contract_Invoice_Header__c invoice = new Contract_Invoice_Header__c();
                invoice.Id = invoiceId;
                invoice.Invoice_Transaction_Amount__c = transactionAmountMap.get(invoiceId);
                
                invoicesToUpdate.add(invoice);
            }
            
            Update invoicesToUpdate;
            if(!transactionRecordsToDelete.isEmpty()){
                Delete transactionRecordsToDelete;
            }
        }
    }
    
    public static void updateTransactionDateOnInsert(List<SFDC2Sun_Transfer_or_Sync_History__c> historyRecords){
        
        for(SFDC2Sun_Transfer_or_Sync_History__c transactionRecord : historyRecords ){
            if(transactionRecord.Is_Transaction__c == true && transactionRecord.Invoice_Header__c !=null && transactionRecord.Transaction_Date_String__c !=null ){
                transactionRecord.Transaction_Date__c = Date.newInstance(
                    Integer.valueOf(transactionRecord.Transaction_Date_String__c.split('/')[2]), // year
                    Integer.valueOf(transactionRecord.Transaction_Date_String__c.split('/')[0]), // month
                    Integer.valueOf(transactionRecord.Transaction_Date_String__c.split('/')[1])  // day
                );
            }
        }
        
    }
    
    public static void updateTransactionAmountOnDelete(List<SFDC2Sun_Transfer_or_Sync_History__c> historyRecords){
        
        List<Id> invoiceHeaderIds = new List<Id>();
        List<SFDC2Sun_Transfer_or_Sync_History__c> validRecords = new List<SFDC2Sun_Transfer_or_Sync_History__c>();
        
        
        for(SFDC2Sun_Transfer_or_Sync_History__c transactionRecord : historyRecords ){
            if(transactionRecord.Is_Transaction__c == true && transactionRecord.Invoice_Header__c !=null){
                if(invoiceHeaderIds.contains(transactionRecord.Invoice_Header__c) == false){
                    invoiceHeaderIds.add(transactionRecord.Invoice_Header__c);
                    validRecords.add(transactionRecord);
                }
            }
        }
        
        if(!invoiceHeaderIds.isEmpty()){
            List<Contract_Invoice_Header__c> invoiceHeaderList = [SELECT Id, Invoice_Transaction_Amount__c 
                                                                  FROM Contract_Invoice_Header__c 
                                                                  WHERE Id IN :invoiceHeaderIds];
            
            Map<Id,Decimal> transactionAmountMap = new Map<Id,Decimal>();
            for(Contract_Invoice_Header__c invoice : invoiceHeaderList){
                if(invoice.Invoice_Transaction_Amount__c == null || invoice.Invoice_Transaction_Amount__c == 0){
                    transactionAmountMap.put(invoice.Id,0);
                }else{
                    transactionAmountMap.put(invoice.Id,invoice.Invoice_Transaction_Amount__c);
                }
            }
            
            for(SFDC2Sun_Transfer_or_Sync_History__c transactionRecord :validRecords ){
                if(transactionAmountMap.get(transactionRecord.Invoice_Header__c)!=null){
                    Decimal updatedAmount = 0 ;
                    if(transactionRecord.Transaction_Type__c == 'Debit'){
                        updatedAmount = transactionAmountMap.get(transactionRecord.Invoice_Header__c) - transactionRecord.Transaction_Amount__c;
                    }else if(transactionRecord.Transaction_Type__c == 'Credit'){
                        updatedAmount = transactionAmountMap.get(transactionRecord.Invoice_Header__c) + transactionRecord.Transaction_Amount__c;
                    }
                    transactionAmountMap.put(transactionRecord.Invoice_Header__c,updatedAmount);
                }
            }
            
            List<Contract_Invoice_Header__c> invoicesToUpdate = new List<Contract_Invoice_Header__c>();
            for(Id invoiceId : transactionAmountMap.KeySet()){
                
                Contract_Invoice_Header__c invoice = new Contract_Invoice_Header__c();
                invoice.Id = invoiceId;
                invoice.Invoice_Transaction_Amount__c = transactionAmountMap.get(invoiceId);
                
                invoicesToUpdate.add(invoice);
            }
            
            Update invoicesToUpdate;
        }
    }
}
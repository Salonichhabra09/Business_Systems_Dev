trigger SFDC2SUN_History_Trigger on SFDC2Sun_Transfer_or_Sync_History__c (before insert, after insert, after delete) {
    
    if(Trigger_Activation__c.getInstance('SFDC2SUN_History_Trigger').Active__c || Test.isRunningTest()){
        If(Trigger.IsInsert){
            If(Trigger.IsBefore){
                SFDC2SUNHistoryTriggerManager.updateTransactionDateOnInsert(Trigger.new);
            }
            If(Trigger.IsAfter){
                SFDC2SUNHistoryTriggerManager.rollupTransactionAmountOnInvoiceHeader(Trigger.new);
            }
        }
        
        If(Trigger.IsDelete){
            If(Trigger.IsAfter){
                SFDC2SUNHistoryTriggerManager.updateTransactionAmountOnDelete(Trigger.old);
            }
        }
    }
}
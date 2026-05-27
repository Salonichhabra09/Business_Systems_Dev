trigger MS_Invoice_Trigger on Bureau_Invoice__c (before insert, before update, after update) {
    /*if(Trigger_Activation__c.getInstance('MS_Invoice_Trigger').Active__c){
        If(Trigger.IsInsert){
            If(Trigger.IsBefore){
                MS_InvoiceTriggerManager.GetCurrencyCreateTask(Trigger.New,Trigger.Old,Trigger.IsInsert,Trigger.IsUpdate);
            }
        }
        If(Trigger.IsUpdate){
            If(Trigger.IsBefore){
                MS_InvoiceTriggerManager.GetCurrencyCreateTask(Trigger.New,Trigger.Old,Trigger.IsInsert,Trigger.IsUpdate);
            }
            If(Trigger.IsAfter){
                MS_InvoiceTriggerManager.UpdateLineItems(Trigger.New);
            }
        }
    }*/
}
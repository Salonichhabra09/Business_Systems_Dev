trigger InvoiceHeader_Trigger on Contract_Invoice_Header__c (before insert,before update,after update,before delete) {
    if(Trigger_Activation__c.getInstance('InvoiceHeader_Trigger').Active__c){     
        if(Trigger.isInsert){
            if(Trigger.isBefore){
                InvoiceHeaderTriggerManager_1.UpdateHeader_CurrencyAccCon(trigger.new);
                InvoiceHeaderTriggerManager_1.mapServiceEndDateForMS(trigger.new);
            }
        }
        if(Trigger.isUpdate){
            if(Trigger.isAfter){
                invoiceHeaderTriggerClass objcls = new invoiceHeaderTriggerClass ();
                if(invoiceHeaderTriggerClass.triggerrun == false){
                    objcls.updateRecentValuesonIR(trigger.new,trigger.oldmap);
                }
            }
            if(Trigger.isBefore){
                invoiceHeaderTriggerClass objCls = new invoiceHeaderTriggerClass ();
                objCls.invoiceStatusValidation(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
                if(UserInfo.getProfileId() != System.label.System_Administrator_Profile_Id)
                    InvoiceHeaderTriggerManager_1.CheckCreditNote(Trigger.new,Trigger.newMap);
                InvoiceHeaderTriggerManager_1.updateServiceEndDateForMS(trigger.new,trigger.oldmap);
                InvoiceHeaderTriggerManager_1.updateInvoiceDateOnPAStreamUpdate(trigger.new);
            }
        }
        if(Trigger.isDelete){
            if(Trigger.isBefore){
                InvoiceHeaderTriggerManager_1.Prevent_Delete_InvoiceHeader(Trigger.old);
            }
        }   
    }
}
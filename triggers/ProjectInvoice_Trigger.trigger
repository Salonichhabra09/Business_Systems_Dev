trigger ProjectInvoice_Trigger on Project_Invoice__c (before insert,before delete, before update, after update) {
    if(Trigger_Activation__c.getInstance('ProjectInvoice_Trigger').Active__c){  
        if(Trigger.isInsert)
        {
            if(Trigger.isBefore)
            {
                ProjectInvoiceTriggerManager.UpdateAccountOwnerAndCurrencyIsoCode(trigger.new);
                for(Integer i=0;i<trigger.new.size();i++)
                {
                    ProjectInvoice_Manager.copyDataFromProject(trigger.new[i]);
                    ProjectInvoice_Manager.populateInvoiceWithUpdatedAmounts(trigger.new[i],true, true, true);
                    ProjectInvoice_Manager.processIMLookupvalues(trigger.new[i]);     
                
                    
                }
            }
        }
        if(Trigger.isUpdate)
        {
            if(Trigger.isBefore)
            {
                ProjectInvoiceTriggerManager.BeforeUpdateTasks(Trigger.new, Trigger.old);
                ProjectInvoice_Manager.validationsonSubmitforApproval(trigger.new, trigger.old);
                ProjectInvoice_Manager.validationsonProcessIR(trigger.new, trigger.old);
                ProjectInvoice_Manager.validationsonRejectingIR(trigger.new, trigger.old);
              
            }
            if(Trigger.isAfter)
            {
                List<Project_Invoice__c> invoices = new List<Project_Invoice__c>();
                for(Integer i=0; i<Trigger.new.size(); i++)
                {
                    if(trigger.new[i].Credit__c != trigger.old[i].Credit__c)
                    {
                        invoices.add(trigger.new[i]);
                    }
                }
                if(invoices.size()>0){
                    ProjectInvoice_Manager.signRevenueScheduleItemsOnCreditStatus(invoices);
                    ProjectInvoice_Manager.signProductItemsOnCreditStatus(invoices);
                }
            }
        }
        if(Trigger.isDelete)
        {
            if(Trigger.isBefore)
            {
                ProjectInvoiceTriggerManager.CheckInvoiceDeletion(trigger.old);
            }
        }
    }
    
}
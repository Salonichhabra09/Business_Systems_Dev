trigger Expense_Trigger on Expense__c (before insert,before update,before delete){
    If(Trigger_Activation__c.getInstance('Expense_Trigger').Active__c){
        If(Trigger.IsInsert){
            ExpenseTriggerManager.copyDataFromProject(trigger.new);
        }
        If(Trigger.IsUpdate){
            if(Trigger.IsBefore){
                ExpenseTriggerManager.RestrictExpenseEdit(trigger.new,trigger.old);
            }
        }
        If(Trigger.IsDelete){
            ExpenseTriggerManager.RestrictExpenseDelete(trigger.old);
        }
    }
}
trigger MS_System_Trigger on Bureau_System__c (after insert) {
    if(Trigger_Activation__c.getInstance('MS_System_Trigger').Active__c){
        If(Trigger.IsInsert){
            If(Trigger.IsAfter){
                // MS_SystemTriggerManager.CreateCandidatelogins(Trigger.New);
            }
        }
    }
}
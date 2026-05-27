trigger Competitor_Trigger on Competitor__c (before update,before insert) {
    if(Trigger_Activation__c.getInstance('Competitor_Trigger').Active__c){
        If(Trigger.IsUpdate)
        {
            If(Trigger.IsBefore)
            {
                Boolean CallCheckAutoCreateDisplacementFieldMethod=false;
                for(Integer i=0;i<Trigger.new.size();i++){
                    if((Trigger.new[i].Auto_create_Displacement_Opportunity__c!=Trigger.old[i].Auto_create_Displacement_Opportunity__c ||
                       Trigger.new[i].Opportunity__c!=Trigger.old[i].Opportunity__c)
                       && Trigger.new[i].Auto_create_Displacement_Opportunity__c=='Yes' && Trigger.new[i].opportunity__c!=null){
                           CallCheckAutoCreateDisplacementFieldMethod=True;
                           break;
                       }
                }
                if(CallCheckAutoCreateDisplacementFieldMethod){
                    CompetitorTriggerManager.CheckAutoCreateDisplacementFieldOnUpdate(Trigger.new,Trigger.old);
                }
            }
        }
        If(Trigger.IsInsert)
        {
            If(Trigger.IsBefore)
            {
                Boolean CallCheckAutoCreateDisplacementFieldMethod=false;
                for(Integer i=0;i<Trigger.new.size();i++){
                    if(Trigger.new[i].Auto_create_Displacement_Opportunity__c=='Yes' && Trigger.new[i].opportunity__c!=null){
                           CallCheckAutoCreateDisplacementFieldMethod=True;
                           break;
                       }
                }
                if(CallCheckAutoCreateDisplacementFieldMethod){
                    CompetitorTriggerManager.CheckAutoCreateDisplacementFieldOnInsert(Trigger.new);
                }
            }
        }
    }
}
trigger Assessment_Trigger on Assessment__c (before insert, before update, after update){
    if(Trigger_Activation__c.getInstance('Assessment_Trigger').Active__c){
        If(Trigger.IsInsert){
            Assessment_Manager.setupAssessmentData(trigger.new);
        }
        If(Trigger.IsUpdate){
            If(Trigger.IsBefore){
                Assessment_Manager.ChkProfCenter(Trigger.New,Trigger.Old);
            }
            If(Trigger.IsAfter){
                //AssessmentBooking_Manager.updateDataInAssessmentBookings(trigger.old,trigger.new);
            }
        }
        
    }
}
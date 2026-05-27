trigger MS_Product_Trigger on Bureau_Product__c (before insert,after insert, after update,before delete) {
    /*if(Trigger_Activation__c.getInstance('MS_Product_Trigger').Active__c){
        If(Trigger.IsInsert){
            If(Trigger.IsBefore){
                //Commented By : Shubham Singh
                //Reason: deprecate Rating Progress
                //Reference: SSE-19314
                //MS_ProductTriggerManager.setcurencyISOCode(Trigger.New);
            }
            If(Trigger.IsAfter){
                //Commented By : Pallavi Jadhav
                //Reason: deprecate Rating Progress
                //Reference: SSE-18140
                //MS_ProductTriggerManager.InsertProgressRating(Trigger.New,Trigger.Old,Trigger.isInsert);
            }
        }
        If(Trigger.IsUpdate){
            //Commented By : Pallavi Jadhav
            //Reason: deprecate Rating Progress
            //Reference: SSE-18140
            //MS_ProductTriggerManager.InsertProgressRating(Trigger.New,Trigger.Old,Trigger.isInsert);
        }
        If(Trigger.IsDelete){
            //Commented By : Shubham Singh
                //Reason: deprecate Rating Progress
                //Reference:SSE-19314
            //MS_ProductTriggerManager.DeleteProgressRating(Trigger.Old);
        }
    }*/  
}
trigger CourseBooking_Trigger on Course_Booking__c (before insert,Before Update) {
    if(Trigger_Activation__c.getInstance('CourseBooking_Trigger').Active__c || Test.isRunningTest()){
        if(Trigger.isInsert)
        {
            if(Trigger.isBefore)
            {
                CourseBookingTriggerManager.updateDeligateAccount(trigger.New);
            }
        }
        if(Trigger.isUpdate)
        {
            if(Trigger.isBefore)
            {
                CourseBookingTriggerManager.updateDeligateAccountBeforeUpdate(trigger.New,trigger.old);
            }
        }
    }
}
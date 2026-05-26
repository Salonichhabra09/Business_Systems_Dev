trigger EmailMessage_beforeDelete on EmailMessage (before delete) {

    if(userinfo.getProfileId()!= System.label.System_Admin_Id_18_Digit || Test.isRunningTest()){
        EmailMessageTriggerManager.restrictDeletionOfJobMails(trigger.old);
    }
    

set<Id> str_set=new set<Id>();
List<PermissionSetAssignment>lst_PermissionSet=[SELECT  AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = '0PSD0000000KNfd'];

for(PermissionSetAssignment ps:lst_PermissionSet){
str_set.add(ps.AssigneeId);
}

for(EmailMessage Em :Trigger.old){
if(!str_set.contains(Userinfo.getUserid())){
if(EmailMessage_TriggerTester.B_trigger==false){
Em.addError('You dont have permission to delete email messages.');
}
}

}


}
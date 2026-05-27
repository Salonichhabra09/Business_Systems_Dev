trigger TopicAssignment_Trigger on TopicAssignment (after delete) {
    if(Trigger.isDelete){
        if(Trigger.isAfter){
            TopicAssignmentManager.deleteTopic(Trigger.old, Trigger.oldMap);
        }
    }
}
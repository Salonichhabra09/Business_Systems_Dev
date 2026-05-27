public class TopicAssignmentManager {
    public static void deleteTopic(list<TopicAssignment> oldList, Map<Id, TopicAssignment> oldMap){
        Set<Id> topicIdList = new Set<Id>();
        list<Topic> topicsToDelete = new list<Topic>();
        list<Topic> topicList = new list<Topic>();
        
        for(TopicAssignment ta : oldList){
            topicIdList.add(ta.TopicId);
        }
        
        if(!topicIdList.isEmpty()){
            topicList = [SELECT Id, (SELECT Id FROM TopicAssignments) FROM Topic WHERE Id IN :topicIdList];
        }
        
        // Loop through each account and check if it has no contacts remaining
        for (Topic topic : topicList) {
            if (topic.TopicAssignments.isEmpty()) {
                topicsToDelete.add(topic);
            }
        }
        
        if(!topicsToDelete.isEmpty()){
            DELETE topicsToDelete;
        }
        
    }
}
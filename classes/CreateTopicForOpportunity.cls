public without sharing class CreateTopicForOpportunity {
	
    public static Topic topicRecordToInsert = new Topic();
    public static TopicAssignment topicAssignmentRecordToInsert = new TopicAssignment();
    public static Boolean doNotCreateTopic = false;
    
    public static Topic insertTopic(String oppName){
        topicRecordToInsert.Name = oppName;
        topicRecordToInsert.Description = 'Original Opportunity Id: ' + oppName + ' has been captured to track all the extension opportunities and would help to create/ sync lines in PH Opportunity based on Original Opportunity';
        System.debug('topicRecordToInsert '+ topicRecordToInsert);
        return topicRecordToInsert;
    }
    
    public static TopicAssignment insertTopicAssignment(String topicId, String entityId){
        doNotCreateTopic = true;
        topicAssignmentRecordToInsert.TopicId = topicId;
        topicAssignmentRecordToInsert.EntityId = entityId;
        System.debug('topicAssignmentRecordToInsert '+ topicAssignmentRecordToInsert);
        
        return topicAssignmentRecordToInsert;
    }
    
    @InvocableMethod
    public static void createTopic(List<InputValues> inputValuesList){
        Topic topicRecord = new Topic();
        list<TopicAssignment> topicAssignmentRecord = new list<TopicAssignment>();
        
        Opportunity opportunityRecord = inputValuesList.get(0).opportunityData;
        if(opportunityRecord != null){
            topicAssignmentRecord = [SELECT Id, TopicId FROM TopicAssignment WHERE EntityId = :opportunityRecord.Original_Opportunity__c];
            if(topicAssignmentRecord.size() > 0){
                // Insert Topic Assignment
                topicAssignmentRecordToInsert = insertTopicAssignment(topicAssignmentRecord[0].TopicId, opportunityRecord.Id);
            }else{
                list<Opportunity> oppList = [SELECT Id, OpportunityId__c FROM Opportunity WHERE Id = :opportunityRecord.Original_Opportunity__c];
                System.debug('oppList '+oppList.size());
                
                String opportunityName = oppList[0].OpportunityId__c;
                // Insert Topic
                topicRecordToInsert = insertTopic(opportunityName);
            }
        }
        
        if(!doNotCreateTopic && topicRecordToInsert != null){
            INSERT topicRecordToInsert;
            // Insert Topic Assignment
            topicAssignmentRecordToInsert = insertTopicAssignment(topicRecordToInsert.Id, opportunityRecord.Id);
        }
        
        if(topicAssignmentRecordToInsert != null){
            INSERT topicAssignmentRecordToInsert;
        }
    }
    
    public class InputValues{
        @invocableVariable
        public Opportunity opportunityData;
        
    }
}
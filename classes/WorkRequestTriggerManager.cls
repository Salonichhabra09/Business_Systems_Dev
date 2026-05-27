public class WorkRequestTriggerManager {
    public static void afterInsert(list<Work_Request__c> workRequestsList){
        list<Work_Request__c> submittedList = new list<Work_Request__c>();
        Map<Id, Id> recordIdToContentDocumentIdMap = new Map<Id, Id>();
        Set<Id> contentDocumentIdsList = new Set<Id>();
        
        for(Work_Request__c wr : workRequestsList){
            System.debug('Candidate_Field_Configuration__c '+wr.Candidate_Field_Configuration__c);
            if((wr.Work_Request_Type__c == 'Client Submitted' ||  wr.Work_Request_Type__c == 'Internal Submission')
               && wr.RecordtypeId == Schema.SObjectType.Work_Request__c.getRecordTypeInfosByName().get('Submitted').getRecordTypeId()
               && wr.Work_Request_Generated__c != null
               && wr.Candidate_Field_Configuration__c != null){
                   submittedList.add(wr); 
                   contentDocumentIdsList.add(wr.Candidate_Field_Configuration__c);
                   recordIdToContentDocumentIdMap.put(wr.Id, wr.Candidate_Field_Configuration__c);
               }
        }
        
        if (!recordIdToContentDocumentIdMap.isEmpty()) {
            list<ContentDocumentLink> contentDocumentLinkToDelete = new list<ContentDocumentLink>();
            list<ContentDocumentLink> contentDocumentLinkToInsert = new list<ContentDocumentLink>();
            
            list<ContentDocumentLink> contentDocumentLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink 
                                                                 WHERE ContentDocumentId IN :contentDocumentIdsList];
            for(ContentDocumentLink cdl : contentDocumentLinkList){
                String linkedEntityId = cdl.LinkedEntityId;
                if(!linkedEntityId.startswith('005')){
                    contentDocumentLinkToDelete.add(cdl);
                }
            }
            
            for(Work_Request__c wr : submittedList){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = wr.Id;
                cdl.ContentDocumentId = recordIdToContentDocumentIdMap.get(wr.Id);
                cdl.Visibility = 'AllUsers';
                cdl.ShareType = 'V';
                contentDocumentLinkToInsert.add(cdl);
            }
            
            try{
                if(!contentDocumentLinkToDelete.isEmpty()){
                    DELETE contentDocumentLinkToDelete;
                } 
            }catch (DmlException e) {
                System.debug('Error deleting ContentDocumentLink records: ' + e.getMessage());
            }        
            
            try{
                if(!contentDocumentLinkToInsert.isEmpty()){
                    INSERT contentDocumentLinkToInsert;
                } 
            }catch (DmlException e) {
                System.debug('Error inserting ContentDocumentLink records: ' + e.getMessage());
            } 
        }
    }
    
    public static void afterUpdate(list<Work_Request__c> workRequestsList, Map<Id, Work_Request__c> oldMap){
        Set<Id> generatedWRFList = new Set<Id>();
        List<Work_Request__c> workRequestToUpdate = new List<Work_Request__c>();
        Map<Id, Decimal> generatedSubmittedSumCandidateMap = new Map<Id, Decimal>();
        Map<Id, Decimal> generatedSubmittedSumParticipantMap = new Map<Id, Decimal>();
        
        for(Work_Request__c wr : workRequestsList){
            if((wr.Work_Request_Type__c == 'Client Submitted' ||  wr.Work_Request_Type__c == 'Internal Submission')
               && wr.RecordtypeId == Schema.SObjectType.Work_Request__c.getRecordTypeInfosByName().get('Submitted').getRecordTypeId()
               && wr.Work_Request_Generated__c != null
               && (wr.No_of_Candidate_Created__c != oldMap.get(wr.Id).No_of_Candidate_Created__c
                   || wr.No_of_Participant_Created__c != oldMap.get(wr.Id).No_of_Participant_Created__c)){
                       generatedWRFList.add(wr.Work_Request_Generated__c);
                   }
               }
               
               if(!generatedWRFList.isEmpty()){
            List<AggregateResult> results = [
                SELECT Work_Request_Generated__c, SUM(No_of_Candidate_Created__c) sumCandidatesCreated,
                SUM(No_of_Participant_Created__c) sumParticipantsCreated
                FROM Work_Request__c
                WHERE Work_Request_Generated__c IN :generatedWRFList
                GROUP BY Work_Request_Generated__c
            ];
            
            for (AggregateResult result : results) {
                generatedSubmittedSumCandidateMap.put((Id)result.get('Work_Request_Generated__c'), (Decimal)result.get('sumCandidatesCreated'));
                generatedSubmittedSumParticipantMap.put((Id)result.get('Work_Request_Generated__c'), (Decimal)result.get('sumParticipantsCreated'));
            }
            
            for (Id wrfId : generatedWRFList) {
                Decimal rollupCandidateCreated = generatedSubmittedSumCandidateMap.containsKey(wrfId) 
                    ? generatedSubmittedSumCandidateMap.get(wrfId) 
                    : 0;
                Decimal rollupParticipantCreated = generatedSubmittedSumParticipantMap.containsKey(wrfId) 
                    ? generatedSubmittedSumParticipantMap.get(wrfId) 
                    : 0;
                workRequestToUpdate.add(new Work_Request__c(Id = wrfId, No_of_Candidate_Created__c = rollupCandidateCreated,
                                                            No_of_Participant_Created__c = rollupParticipantCreated));
            }
            if (!workRequestToUpdate.isEmpty()) {
                update workRequestToUpdate;
            }
        }
    }
}
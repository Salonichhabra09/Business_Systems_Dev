public with sharing class CandidateCreationController {
    
    @AuraEnabled
    public static void createCandidateRecords(List<Bureau_Candidate__c> candidateList){
        try {
            List<Bureau_Candidate__c> candidateListToInsert = new List<Bureau_Candidate__c>();
            Map<Id, Bureau_Candidate__c> candidateToInsertMap;
            Id jobRecordId = candidateList[0].Bureau_Job__c;
            String JobRegion = [select id,Job_Region__c from Job__c where id=:jobRecordId limit 1].Job_Region__c;
            for(Bureau_Candidate__c candidate : candidateList) {
                candidate.Candidate_Unique_Id__c = candidate.Bureau_Job__c + candidate.First_Name__c + candidate.Last_Name__c + candidate.Email__c;
                candidate.Job_Region__c = JobRegion;
                candidateListToInsert.add(candidate);
            }
            insert candidateListToInsert;
            candidateToInsertMap = new Map<Id, Bureau_Candidate__c>(candidateListToInsert);

            RollUpCandidateFields.calculateCountFields(candidateToInsertMap);
            RollUpCandidateFields.updateRollupSummaryFieldsOnJob(candidateListToInsert); //Changed by Shubham Singh
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
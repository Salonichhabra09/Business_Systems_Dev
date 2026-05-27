//Scheduled class to trigger a batch job that updates Job Transfer Status and Candidate Transfer Status on Job records.
//This class is designed to be run on a schedule from Schedule Apex button at 12 PM, 4 PM, 8 PM and 12 AM daily.
//and it initiates the GetUpdatedRatingsJobs batch process.

global class GetUpdatedRatingsJobs implements Database.Batchable<sObject>,Database.Stateful {
    
    public Set<Id> JobIds = new Set<Id>();
            
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime fourHoursAgo = DateTime.now().addHours(-4);
        return Database.getQueryLocator([
            SELECT Id, Participant__r.Bureau_Job__c,Rating_Transfer_Status__c
            FROM Bureau_Rating__c
            WHERE Lastmodifieddate >=:fourHoursAgo
            AND Participant__c != null
            AND (Participant__r.Bureau_Job__r.Candidate_Transfer_Status__c = 'Ready to transfer' OR 
                 Participant__r.Bureau_Job__r.Candidate_Transfer_Status__c = 'Sent to FTP with error')
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Bureau_Rating__c> ratingScope) {
        for(Bureau_Rating__c rating:ratingScope){
            Id jobId = rating.Participant__r.Bureau_Job__c;
            if (jobId == null) continue;
            this.JobIds.add(jobId);
        } 
    }
    
    global void finish(Database.BatchableContext bc) {
        UpdateJobTransferStatusBatch callBatch = new UpdateJobTransferStatusBatch(this.JobIds);
		Database.executeBatch(callBatch, 2000);
    }

}
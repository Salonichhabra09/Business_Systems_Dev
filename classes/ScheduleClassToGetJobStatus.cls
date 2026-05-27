public with sharing class ScheduleClassToGetJobStatus implements Schedulable{
    
    private String jobId;
    private String operationType;
    private String objectName;
    private list<String> jobIds;

    public ScheduleClassToGetJobStatus(String jobId,String operationType, String objectName) {
        this.jobId = jobId;
        this.operationType = operationType;
        this.objectName = objectName;
    }
    
    public void execute(SchedulableContext ctx) {
        System.debug('jobId --> '+ jobId);
            Job__c job = [SELECT Id, Name, Candidate_Max_Sequence_No_New__c, bulkJobId__c FROM Job__c WHERE Id =: jobId];
            System.debug('job --> '+job);
            list<Id> jobIdList = new list<Id>();
            if(job.bulkJobId__c != null){
                String jobbulkId = job.bulkJobId__c;
                List<String> listOfJobIds = jobbulkId.split(',');
                System.debug('listOfJobIds: '+ listOfJobIds);
                //list<Id> jobIdList = new list<Id>();
                for(String a : listOfJobIds){
                    Id job_Id = Id.valueOf(a);
                    System.debug('job_Id: '+ job_Id);
                    jobIdList.add(job_Id);
                }
            }else{
                jobIdList = null;
            }
            System.debug('jobIdList: '+ jobIdList);
            Id jobID1 = System.enqueueJob(new QueueableToGetBulkJobStatus(job, jobIdList, 0, 0, 0, '',operationType,objectName));
            System.abortJob(ctx.getTriggerId());

    }
}
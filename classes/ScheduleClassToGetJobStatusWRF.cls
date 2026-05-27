public with sharing class ScheduleClassToGetJobStatusWRF implements Schedulable{
	private String workRequestId;
    private list<String> jobIds;

    public ScheduleClassToGetJobStatusWRF(String wrfId) {
        this.workRequestId = wrfId;
    }
    
    public void execute(SchedulableContext ctx) {
            Work_Request__c workRequest = [SELECT Id, Name, No_of_Candidate_Created__c, bulkJobId__c, Job__c, Status__c FROM Work_Request__c WHERE Id =: workRequestId];
            System.debug('workRequest --> '+workRequest);
            list<Id> jobIdList = new list<Id>();
            if(workRequest.bulkJobId__c != null){
                String jobbulkId = workRequest.bulkJobId__c;
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
            Id jobID1 = System.enqueueJob(new QueueableToGetBulkJobStatusWRF(workRequest, jobIdList, 0, 0, 0, ''));
            System.abortJob(ctx.getTriggerId());

    }
}
public with sharing class QueueableToGetBulkJobStatus implements Queueable,Database.AllowsCallouts {
    
    private List<Id> jobIds;
    private Integer counter;
    private Integer totalRecordsProcessed;
    private Integer totalRecordsFailed;
    private Job__c job;
    private Id queueableJobId;
    private String errorMessage;
    private String jobName;
    private String operationType;
    private String objectName;
    
    public QueueableToGetBulkJobStatus(Job__c job, List<Id> jobId, Integer counter, Integer totalRecordsProcessed, Integer totalRecordsFailed, String errorMessage,String operationType, String objectName) {
        this.job = job;
        this.jobName = job.Name;
        this.jobIds = jobId;
        this.counter = counter;
        this.totalRecordsProcessed = totalRecordsProcessed;
        this.totalRecordsFailed = totalRecordsFailed;
        this.errorMessage = errorMessage;
        this.operationType = operationType;
        this.objectName = objectName;
    }
    
    public void execute(QueueableContext context) {
        if(jobIds != null){
            Boolean callRatingBatch = false;
            String job_Id = jobIds[counter];
            System.debug('job_Id: '+job_Id);
            Map<String, Integer> countJobMap = new Map<String, Integer>();
            CandidateUploadContoller.JobDetailsWrapper jobStatusWrapper = CandidateUploadContoller.getJobDetails(job_Id);
            System.debug('jobStatusWrapper: '+ jobStatusWrapper);
            if(jobStatusWrapper.state == 'Job has been Completed'){
                counter = counter + 1;
                totalRecordsProcessed = totalRecordsProcessed + jobStatusWrapper.numberOfRecordsProcessed;
                System.debug('totalRecordsProcessed: '+ totalRecordsProcessed);
                totalRecordsFailed = totalRecordsFailed + jobStatusWrapper.numberOfRecordsFailed;
                System.debug('totalRecordsFailed: '+ totalRecordsFailed);
                System.debug('Limits.getQueueableJobs() --> '+Limits.getQueueableJobs());
                if(totalRecordsFailed > 0 && String.isBlank(errorMessage)){
                    System.debug('job_Id: '+job_Id);
                    String failedRecordsList = CandidateUploadContoller.getFailedRecords(job_Id);
                    String firstRow = failedRecordsList.substringBetween('\n');
                    System.debug('Check --> '+firstRow);
                    if(firstRow != null){
                        list<String> lstCSVLines = firstRow.split(',');
                        System.debug('Error --> '+lstCSVLines[1]);
                        errorMessage = lstCSVLines[1];
                    }else{
                        errorMessage = '';
                    }
                }
                if(counter == jobIds.size()){
                    job.bulkJobId__c = null;
                    UPDATE job;
                    System.debug('jobStatusWrapper.state Send Email: '+ jobStatusWrapper.state);
                    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: context.getJobId()];
                    // Send an email to user
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {a.CreatedBy.Email};
                        mail.setToAddresses(toAddresses);
                    System.debug('totalRecordsFailed --> '+totalRecordsFailed);
                    if(totalRecordsProcessed == totalRecordsFailed){
                        callRatingBatch = false;
                        mail.setSubject('Candidate Upload Sheet has been failed.');
                        mail.setHtmlBody('Candidate Upload Sheet has been failed on job number '+ jobName +'.</br> Total Records Processed: '+totalRecordsProcessed+'</br>'+'Total Records Failed: '+totalRecordsFailed+'</br>'+'Failure Reason: '+errorMessage);
                    }else if(totalRecordsFailed > 0){
                        callRatingBatch = false;
                        mail.setSubject('Candidate Upload Sheet has been partially imported.');
                        mail.setHtmlBody('Candidate Upload Sheet has been partially imported on job number '+ jobName +'.</br> Total Records Processed: '+totalRecordsProcessed+'</br>'+'Total Records Failed: '+totalRecordsFailed+'</br>'+'Failure Reason: '+errorMessage+'</br>'+'Please Delete all Candidates/Ratings and try again.');
                    }
                    else{
                        callRatingBatch = true;
                        mail.setSubject('Candidate Upload Sheet has been imported successfully.');
                        mail.setHtmlBody('Candidate Upload Sheet has been imported successfully on job number '+ jobName +'.</br> Total Records Processed: '+totalRecordsProcessed+'</br>'+'Total Records Failed: '+totalRecordsFailed);
                    }
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    if(callRatingBatch == true)
                    {
                        Database.executeBatch(new BATCH_CreateAPINameSheetForRating(job.Id,operationType,objectName), 1);
                    }
                }else{
                    queueableJobId = System.enqueueJob(new QueueableToGetBulkJobStatus(job, jobIds, counter, totalRecordsProcessed, totalRecordsFailed, errorMessage,operationType,objectName));
                }
            }else if(jobStatusWrapper.state == 'Job has been Failed'){
                job.bulkJobId__c = null;
                UPDATE job;

                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: context.getJobId()];
                // Send an email to user
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {a.CreatedBy.Email};
                mail.setToAddresses(toAddresses);
                mail.setSubject('Candidate Upload Sheet has been failed.');
                mail.setHtmlBody('Candidate Upload Sheet has been failed on job number '+ jobName +'.</br>'+'Please Delete all Candidates/Ratings and try again.');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }else{
                System.debug('jobStatusWrapper.state: '+ jobStatusWrapper.state);
                System.debug('jobStatusWrapper.numberOfRecordsProcessed: '+ jobStatusWrapper.numberOfRecordsProcessed);
                System.debug('jobStatusWrapper.numberOfRecordsFailed: '+ jobStatusWrapper.numberOfRecordsFailed);
                queueableJobId = System.enqueueJob(new QueueableToGetBulkJobStatus(job, jobIds, counter, jobStatusWrapper.numberOfRecordsProcessed, jobStatusWrapper.numberOfRecordsFailed, errorMessage,operationType,objectName));
            }
            
            Integer passCandidateCount = 0;
            Integer failCandidateCount = 0;
            Integer dnaCandidateCount = 0;
            Integer totalCandidates = 0;
            Integer InProgressCandidates = 0;
            Integer completedCandidates = 0;
            Integer notStartedCandidates = 0;
            
            List<AggregateResult> aggrrResult = [SELECT Count(Id), Status2__c
                                                FROM Bureau_Candidate__c
                                                WHERE Bureau_Job__c = :job.Id
                                                GROUP By Status2__c];
            
            if(aggrrResult.size()>0) {
                for(AggregateResult aggr : aggrrResult) {
                    totalCandidates = totalCandidates+Integer.valueOf(aggr.get('expr0'));
                    if(aggr.get('Status2__c') == 'Pass') {
                        passCandidateCount = passCandidateCount+Integer.valueOf(aggr.get('expr0'));
                    }
                    if(aggr.get('Status2__c') == 'Fail') {
                        failCandidateCount = failCandidateCount+Integer.valueOf(aggr.get('expr0'));
                    }
                    if(aggr.get('Status2__c') == 'DNA') {
                        dnaCandidateCount = dnaCandidateCount+Integer.valueOf(aggr.get('expr0'));
                    }
                    if(aggr.get('Status2__c') == 'Completed') {
                        completedCandidates = completedCandidates+Integer.valueOf(aggr.get('expr0'));
                    }
                    if(aggr.get('Status2__c') == 'In Progress') {
                        InProgressCandidates = InProgressCandidates+Integer.valueOf(aggr.get('expr0'));
                    }
                    if(aggr.get('Status2__c') == 'Not Started') {
                        notStartedCandidates = notStartedCandidates+Integer.valueOf(aggr.get('expr0'));
                    }
                }
            }
            
            job.Candidate_Max_Sequence_No_New__c = totalCandidates;
            job.Count_of_candidates_invited__c = passCandidateCount+failCandidateCount+dnaCandidateCount+completedCandidates+InProgressCandidates+notStartedCandidates;
            job.Count_of_Candidates_pass__c = passCandidateCount;
            job.Count_of_Candidates_fail__c = failCandidateCount;
            job.Actual_Count_of_Candidates_PassFail__c = passCandidateCount+failCandidateCount+completedCandidates;
            job.Count_of_Candidates_DNA__c = dnaCandidateCount;
            
            try {
                Database.update(job);
            }
            catch(Exception exp) {
                System.debug('Exception ###'+exp.getMessage());
            }
        }else{
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: context.getJobId()];
            // Send an email to user
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Candidate Upload Sheet has been failed.');
            mail.setHtmlBody('Candidate Upload Sheet has been failed on job number '+ jobName +'.</br>'+'Please Delete all Candidates/Ratings and try again.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
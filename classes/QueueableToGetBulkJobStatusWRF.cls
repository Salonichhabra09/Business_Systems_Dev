public class QueueableToGetBulkJobStatusWRF implements Queueable,Database.AllowsCallouts {
    
    private List<Id> jobIds;
    private Integer counter;
    private Integer totalRecordsProcessed;
    private Integer totalRecordsFailed;
    private Work_Request__c workReq;
    private Id queueableJobId;
    private String errorMessage;
    private String wrfName;
    
    public QueueableToGetBulkJobStatusWRF(Work_Request__c wr, List<Id> jobId, Integer counter, Integer totalRecordsProcessed, Integer totalRecordsFailed, String errorMessage) {
        this.workReq = wr;
        this.wrfName = wr.Name;
        this.jobIds = jobId;
        this.counter = counter;
        this.totalRecordsProcessed = totalRecordsProcessed;
        this.totalRecordsFailed = totalRecordsFailed;
        this.errorMessage = errorMessage;
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
                        if(!(lstCSVLines[1].toUpperCase()).contains('DUPLICATE')){
                         	errorMessage = lstCSVLines[1];   
                        }else{
                            errorMessage = '';
                        }
                    }else{
                        errorMessage = '';
                    }
                }
                if(counter == jobIds.size()){
                    workReq.bulkJobId__c = null;
                    UPDATE workReq;
                    System.debug('jobStatusWrapper.state Send Email: '+ jobStatusWrapper.state);
                    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: context.getJobId()];
                    // Send an email to user
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {a.CreatedBy.Email};
                        mail.setToAddresses(toAddresses);
                    System.debug('totalRecordsFailed --> '+totalRecordsFailed);
                    if(!String.isBlank(errorMessage)){
                        callRatingBatch = false;
                    }else{
                        callRatingBatch = true;
                    }
                    if(totalRecordsProcessed == totalRecordsFailed){
                        //callRatingBatch = false;
                        mail.setSubject('Candidate Upload Sheet has been failed.');
                        mail.setHtmlBody('Candidate Upload Sheet has been failed on work request number '+ wrfName +'.</br> Total Records Processed: '+totalRecordsProcessed+'</br>'+'Total Records Failed: '+totalRecordsFailed+'</br>'+'Failure Reason: '+errorMessage + '</br>' +'Please Delete all Candidates/Ratings and try again.');
                    }else if(totalRecordsFailed > 0){
                        //callRatingBatch = false;
                        mail.setSubject('Candidate Upload Sheet has been partially imported.');
                        mail.setHtmlBody('Candidate Upload Sheet has been partially imported on work request number '+ wrfName +'.</br> Total Records Processed: '+totalRecordsProcessed+'</br>'+'Total Records Failed: '+totalRecordsFailed+'</br>'+'Failure Reason: '+errorMessage+'</br>'+'Please Delete all Candidates/Ratings and try again.');
                    }
                    else{
                        callRatingBatch = true;
                        mail.setSubject('Candidate Upload Sheet has been imported successfully.');
                        mail.setHtmlBody('Candidate Upload Sheet has been imported successfully on work request number '+ wrfName +'.</br> Total Records Processed: '+totalRecordsProcessed+'</br>'+'Total Records Failed: '+totalRecordsFailed);
                    }
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    if(callRatingBatch == true)
                        Database.executeBatch(new BATCH_CreateAPINameSheetForRatingWRF(workReq.Id), 1);
                    else
                        Delete [SELECT LinkedEntity.type, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocument.Title LIKE '%CandidateWRFImportRating%' AND LinkedEntityId = :workReq.Id];
                    
                }else{
                    queueableJobId = System.enqueueJob(new QueueableToGetBulkJobStatusWRF(workReq, jobIds, counter, totalRecordsProcessed, totalRecordsFailed, errorMessage));
                }
            }else if(jobStatusWrapper.state == 'Job has been Failed'){
                workReq.bulkJobId__c = null;
                UPDATE workReq;

                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =: context.getJobId()];
                // Send an email to user
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {a.CreatedBy.Email};
                mail.setToAddresses(toAddresses);
                mail.setSubject('Candidate Upload Sheet has been failed.');
                mail.setHtmlBody('Candidate Upload Sheet has been failed on work request number '+ wrfName +'.</br>'+'Please Delete all Candidates/Ratings and try again.');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }else{
                System.debug('jobStatusWrapper.state: '+ jobStatusWrapper.state);
                System.debug('jobStatusWrapper.numberOfRecordsProcessed: '+ jobStatusWrapper.numberOfRecordsProcessed);
                System.debug('jobStatusWrapper.numberOfRecordsFailed: '+ jobStatusWrapper.numberOfRecordsFailed);
                queueableJobId = System.enqueueJob(new QueueableToGetBulkJobStatusWRF(workReq, jobIds, counter, jobStatusWrapper.numberOfRecordsProcessed, jobStatusWrapper.numberOfRecordsFailed, errorMessage));
            }
            
            Integer passCandidateCount = 0;
            Integer failCandidateCount = 0;
            Integer dnaCandidateCount = 0;
            Integer totalCandidates = 0;
            Integer InProgressCandidates = 0;
            Integer completedCandidates = 0;
            Integer notStartedCandidates = 0;
            
            List<AggregateResult> aggrrResult = [SELECT Count(Id)
                                                FROM Bureau_Candidate__c
                                                WHERE Work_Request__c = :workReq.Id];
            List<Job__c> jobRecord = [SELECT Id, Candidate_Max_Sequence_No_New__c FROM Job__c WHERE Id = :workReq.Job__c LIMIT 1];
            
            if(aggrrResult.size()>0) {
                for(AggregateResult aggr : aggrrResult) {
                    totalCandidates = totalCandidates+Integer.valueOf(aggr.get('expr0'));
                }
            }
            
            workReq.No_of_Candidate_Created__c = totalCandidates;
            workReq.Status__c = 'Completed';
            /*System.debug('Count before ' + jobRecord[0].Candidate_Max_Sequence_No_New__c);
            jobRecord[0].Candidate_Max_Sequence_No_New__c = jobRecord[0].Candidate_Max_Sequence_No_New__c ==null ? 0 : jobRecord[0].Candidate_Max_Sequence_No_New__c;
            System.debug('Count before ' + jobRecord[0].Candidate_Max_Sequence_No_New__c);
            jobRecord[0].Candidate_Max_Sequence_No_New__c += totalCandidates;
            System.debug('Count after ' + jobRecord[0].Candidate_Max_Sequence_No_New__c);
            */
            try {
                Database.update(workReq);
                Database.update(jobRecord);
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
            mail.setHtmlBody('Candidate Upload Sheet has been failed on work request number '+ wrfName +'.</br>'+'Please Delete all Candidates/Ratings and try again.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
global class CandidateBulkUploadBatch implements Database.Batchable<sObject>, Database.Stateful {
    private String jobid;
    private String jobName;
    private list<String> errors = new list<String>();
    private String operationType;
    private String objectName;
    public CandidateBulkUploadBatch(String jobid,String operationType, String objectName) {
        this.jobid = jobid;
        this.operationType = operationType;
        this.objectName = objectName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Job__c JobRec = [Select id,Name,Number_of_Assessments__c,Number_of_Respondents_New__c,
                            Number_of_Participants_New__c from Job__c  where id =: jobId];
        JobRec.Number_of_Assessments__c=0;
        JobRec.Number_of_Participants_New__c=0;
        JobRec.Number_of_Respondents_New__c=0; 
        update JobRec;
        jobName = JobRec.Name;
        String query = 'Select id,Bureau_Job__c,Bureau_Job__r.Name from Bureau_Candidate__c where Bureau_Job__c = \''+ this.jobid +'\'';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Bureau_Candidate__c> candidateList) {
      try{  
          RollUpCandidateFields.updateRollupSummaryFieldsOnJob(candidateList); //Changed by Shubham Singh
      }catch(Exception ex){
          errors.add(ex.getMessage());
      }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        String errorBody;
        String subjectBody;
        /*User_Specific_Trigger_Activation__c customSett =User_Specific_Trigger_Activation__c.getInstance(UserInfo.getUserId());
        if(customSett.createddate != null){
            customSett.Candidate_Trigger__c=false;
            update customSett;
        }*/
        
        if(!errors.isEmpty()) {
            subjectBody='Errors Occurred While Candidate Count Calculation';
            errorBody='Calculation failed, some error has occured. Candidate/Rating calculation related to job Number:'+jobName+' is failing because of following errors mentioned below:'+'<br/>';
            errorBody += errors[0] + '<br/>';
            
        }else{
            if(!Test.isRunningTest()){
                String json = RollUpCandidateFields.updateStatusCalculations(jobId);
                Job__c job = new Job__c();job.id = jobId;job.Status_Calculations__c = json;update job;
            }
            
            subjectBody='Candidate Count Calculation Completed Successfully';
            errorBody='The Candidate Count calculation is completed successfully. All calculations related to job Number:'+jobName+' are completed.';
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subjectBody);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(errorBody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
        if(this.operationType=='update' && this.objectName=='Bureau_Rating__c'){
          CalculateRatingsBatchOnPlatformUpdate Ratingbatch= new CalculateRatingsBatchOnPlatformUpdate(this.jobId,this.jobName); 
          Database.executeBatch(Ratingbatch, 2000);
        }
        
    }
}
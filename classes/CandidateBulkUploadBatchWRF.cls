global class CandidateBulkUploadBatchWRF implements Database.Batchable<sObject>, Database.Stateful {
    private String workRequestId;
    private String wrfNumber;
    private list<String> errors = new list<String>();
    public String jobId;
    public CandidateBulkUploadBatchWRF(String wrfId) {
        this.workRequestId = wrfId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Work_Request__c workReq = [SELECT Id, Name, No_of_Candidate_Created__c, bulkJobId__c, Job__c
                                   FROM Work_Request__c WHERE Id =: workRequestId];
        jobId = workReq.Job__c;
        workReq.No_of_Participant_Created__c = 0;
        update workReq;
        wrfNumber = workReq.Name;
        String query = 'Select id,Bureau_Job__c,Bureau_Job__r.Name, Work_Request__c,Number_of_Product_Assessment__c,Number_of_participants__c,Number_of_Respondents__c from Bureau_Candidate__c where Work_Request__c = \''+ this.workRequestId +'\'';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Bureau_Candidate__c> candidateList) {
      try{ 
          Job__c relatedJob = new Job__c();
          Map<Id, Bureau_Candidate__c> candidateMap = new Map<Id, Bureau_Candidate__c>(candidateList);
          Map<Id, Job__c> jobMap = new Map<Id, Job__c>([Select id,Number_of_Assessments__c,Number_of_Participants_New__c,
                                        Number_of_Respondents_New__c,Candidate_Max_Sequence_No_New__c 
                                        FROM Job__c WHERE Id = :candidateList[0].Bureau_Job__c]);
          
          RollUpCandidateFields.updateRollupSummaryFieldsOnWRF(candidateList);
          //RollUpCandidateFields.updateRollupSummaryFieldsOnJob(candidateList);
	      relatedJob = jobMap.get(candidateList[0].Bureau_Job__c);
          for(Bureau_Candidate__c candidateRec : candidateList){
              if(relatedJob != null){
                  if(candidateRec.Number_of_Product_Assessment__c !=null){
                      relatedJob.Number_of_Assessments__c += candidateRec.Number_of_Product_Assessment__c;  
                  }
                  if(candidateRec.Number_of_participants__c !=null){
                      relatedJob.Number_of_Participants_New__c += candidateRec.Number_of_participants__c;  
                  }
                  if(candidateRec.Number_of_Respondents__c !=null){
                      relatedJob.Number_of_Respondents_New__c += candidateRec.Number_of_Respondents__c;
                  }
                  relatedJob.Candidate_Max_Sequence_No_New__c += 1;
              }  
          }
          UPDATE relatedJob;
      }catch(Exception ex){
          errors.add(ex.getMessage());
      }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        String errorBody;
        String subjectBody;
        
        if(!errors.isEmpty()) {
            subjectBody='Errors Occurred While Candidate Count Calculation';
            errorBody='Calculation failed, some error has occured. Candidate/Rating calculation related to work request Number:'+wrfNumber+' is failing because of following errors mentioned below:'+'<br/>';
            errorBody += errors[0] + '<br/>';
            
        }else{
           subjectBody='Candidate Count Calculation Completed Successfully';
           errorBody='The Candidate Count calculation is completed successfully. All calculations related to work request Number:'+wrfNumber+' are completed.';
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subjectBody);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(errorBody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
        
        CalculateRatingsFieldBatch candidatebatch= new CalculateRatingsFieldBatch(this.workRequestId, wrfNumber, jobId);
        Database.executeBatch(candidatebatch, 2000);
    }
}
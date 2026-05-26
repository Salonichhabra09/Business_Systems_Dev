global class CandidateBulkDeletionBatch implements Database.Batchable<sObject>, Database.Stateful {
    private String jobid;
    private String jobName;
    private list<String> errors = new list<String>();
    public CandidateBulkDeletionBatch(String jobid) {
        this.jobid = jobid;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id,Bureau_Job__r.Name from Bureau_Candidate__c where Bureau_Job__c = \''+ this.jobid +'\'';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Bureau_Candidate__c> candidateList) {  
          jobName = candidateList[0].Bureau_Job__r.Name;
          List<Database.DeleteResult> deleteResults = Database.delete(candidateList,false);
          for(Database.DeleteResult sr : deleteResults) {
             if(!sr.isSuccess()){               
               list<Database.Error> err = sr.getErrors();
               errors.add(err[0].getStatusCode() + ': ' + err[0].getMessage());
             }
           }
    }   
     
    global void finish(Database.BatchableContext BC) {
        String errorBody;
        String subjectBody;
        
        if(!errors.isEmpty()) {
            subjectBody='Errors Occurred While Deleting Candidates';
            errorBody='Deletion failed, some error has occured. Candidate deletion related to job Number:'+jobName+' is failing because of following errors mentioned below:'+'<br/>';
            for(String error : errors ){
                errorBody += error + '<br/>';
            }
        }else{
            subjectBody='Candidate Deletion Completed Successfully';
            errorBody='The Candidate deletion process is completed successfully. All Candidates related to job Number:'+jobName+' are deleted.';
            Job__c JobRec = [Select id,Number_of_Assessments__c,Number_of_Respondents_New__c,Number_of_Participants_New__c ,
                                 Candidate_Max_Sequence_No_New__c,Count_of_Candidates_pass__c,Count_of_Candidates_fail__c,
                                 Count_of_Candidates_DNA__c, Actual_Count_of_Candidates_PassFail__c,Count_of_candidates_invited__c
                                 from Job__c where id =: jobId ];
            if(JobRec != null){
               JobRec.Number_of_Assessments__c = 0;
               JobRec.Number_of_Respondents_New__c = 0;
               JobRec.Number_of_Participants_New__c = 0;
               JobRec.Candidate_Max_Sequence_No_New__c = 0;
               JobRec.Count_of_Candidates_pass__c = 0;
               JobRec.Count_of_Candidates_fail__c = 0;
               JobRec.Count_of_Candidates_DNA__c = 0;
               JobRec.Actual_Count_of_Candidates_PassFail__c = 0;
               JobRec.Count_of_candidates_invited__c = 0;
                  
               update JobRec;
            }
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subjectBody);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(errorBody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
        
    }
}
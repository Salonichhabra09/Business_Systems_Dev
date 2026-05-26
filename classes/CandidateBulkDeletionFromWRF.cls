global class CandidateBulkDeletionFromWRF implements Database.Batchable<sObject>, Database.Stateful {
    private String wrfId;
    global String wrfName;
    private String objectName;
    private String jobId;
    private list<String> errors = new list<String>();
    
    public CandidateBulkDeletionFromWRF(String wrfId, String objectName) {
        this.wrfId = wrfId;
        this.objectName = objectName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Work_Request__c workReq = [SELECT Id, Name, No_of_Candidate_Created__c, bulkJobId__c, Job__c
                                   FROM Work_Request__c WHERE Id =: wrfId];
        this.jobId = workReq.Job__c;
        this.wrfName = workReq.Name;
        String query;
        // Deletes all Rating records associated with the current WRF
        // And delete Candidate records only if they are linked to this WRF
        if(this.objectName == 'Candidate'){
            query = 'SELECT Id, Name, Bureau_Job__c,Number_of_Product_Assessment__c,Number_of_participants__c,Number_of_Respondents__c,Status2__c from Bureau_Candidate__c WHERE Number_of_participants__c = 0 AND Respondent_Count__c = 0 AND Bureau_Job__c = \''+ this.jobId +'\'';
            System.debug('query '+ query);
        }else{
            query = 'SELECT Id, Work_Request__c, Rater_Type__c, Participant__c, Respondent__c, Participant__r.Bureau_Job__c, Rating_Transfer_Status__c from Bureau_Rating__c WHERE Work_Request__c = \''+ this.wrfId +'\''; 
            System.debug('query '+ query);
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {  
        List<Bureau_Candidate__c> candidateList = new List<Bureau_Candidate__c>();
        List<Bureau_Rating__c> ratingList = new List<Bureau_Rating__c>();
        for (SObject s : scope) {
            if (s instanceof Bureau_Candidate__c) {
                Bureau_Candidate__c candidate = (Bureau_Candidate__c)s;
                candidateList.add(candidate);
            } else if (s instanceof Bureau_Rating__c) {
                Bureau_Rating__c rating = (Bureau_Rating__c)s;
                ratingList.add(rating);
            }
        }
        
        if (!candidateList.isEmpty()) {
            List<Database.DeleteResult> deleteResults = Database.delete(candidateList,false);
            RollUpCandidateFields.deleteRollupSummaryFieldsOnJob(candidateList);
            RollUpCandidateFields.updateCandidateMaxSeqNoOnDelete(candidateList);
            
            for(Database.DeleteResult sr : deleteResults) {
                if(!sr.isSuccess()){               
                    list<Database.Error> err = sr.getErrors();
                    errors.add(err[0].getStatusCode() + ': ' + err[0].getMessage());
                }
            }
        }
        
        if (!ratingList.isEmpty()) {
            
            //this.wrfName = ratingList[0].Work_Request__c;
            List<Database.DeleteResult> deleteResults = Database.delete(ratingList,false);
            RollUpCandidateFields.calculateRatingsCountOnJob(this.jobId, ratingList);
            RollUpCandidateFields.updateTransferCountonJob(ratingList);
            RollUpCandidateFields.calculateRespondentCountOnCandidate(ratingList);
            
            for(Database.DeleteResult sr : deleteResults) {
                if(!sr.isSuccess()){               
                    list<Database.Error> err = sr.getErrors();
                    errors.add(err[0].getStatusCode() + ': ' + err[0].getMessage());
                }
            }
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        String errorBody;
        String subjectBody;
        if(this.objectName == 'Candidate'){
            if(!errors.isEmpty()) {
                subjectBody='Errors Occurred While Deleting Candidates';
                errorBody='Deletion failed, some error has occured. Candidate deletion related to Work Request Number:'+this.wrfName+' is failing because of following errors mentioned below:'+'<br/>';
                for(String error : errors ){
                    errorBody += error + '<br/>';
                }
            }
            else{
                subjectBody='Candidate Deletion Completed Successfully';
                errorBody='The Candidate deletion process is completed successfully. All Candidates related to Work Request Number:'+this.wrfName+' are deleted.';
                
                Work_Request__c wrfRec = [Select id,No_of_Candidate_Created__c,No_of_Participant_Created__c
                                          from Work_Request__c where Id = :this.wrfId ];
                
                if(wrfRec != null){
                    wrfRec.No_of_Candidate_Created__c = 0;
                    wrfRec.No_of_Participant_Created__c = 0;  
                    wrfRec.Status__c = 'Cancelled';
                    update wrfRec;
                }
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(subjectBody);
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(errorBody);
            Messaging.sendEmail(new Messaging.Email[] { mail });   
        }
        // Chaining the class to delete Candidates as well
        if(this.objectName != 'Candidate'){
            CandidateBulkDeletionFromWRF candidatebatch= new CandidateBulkDeletionFromWRF(this.wrfId, 'Candidate');
            Database.executeBatch(candidatebatch, 2000);
        }
        
    }
}
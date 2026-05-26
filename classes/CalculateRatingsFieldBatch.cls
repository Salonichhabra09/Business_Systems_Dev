global class CalculateRatingsFieldBatch implements Database.Batchable<sObject>, Database.Stateful {
    private String wrfId;
    private String wrfName;
    private list<String> errors = new list<String>();
    public Map<String, String> raterStringMap = new Map<String, String>();
    public String jobId;
    public Map<Id, Integer> respondentCountMap = new Map<Id, Integer>();
    
    public CalculateRatingsFieldBatch(String wrfId, String wrfNumber, String jobId) {
        this.wrfId = wrfId;
        this.wrfName = wrfNumber;
        this.jobId = jobId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //SSE-28262 Updated query to get Ratings linked to current WRf only 
        String query = 'SELECT Id, Rater_String__c, Reminder_1__c, Report_Ready__c, ' +
                   'Participant_Name__c, Respondent_Name__c, Rater_Type__c, MFS_Status__c, ' +
                   'Participant__r.Bureau_Job__c, Participant__r.Email__c, Respondent__r.Email__c, Rating_Transfer_Status__c ' +
                   'FROM Bureau_Rating__c ' +
            	   'WHERE Work_Request__c = \'' + String.escapeSingleQuotes(this.wrfId) + '\' ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Bureau_Rating__c> ratingList) {  
        System.debug('rating list size --> '+ratingList.size());
        if (!ratingList.isEmpty()) {
            List<Bureau_Rating__c> otherRatingList = new List<Bureau_Rating__c>();
            List<Bureau_Rating__c> selfRatingList = new List<Bureau_Rating__c>();
            Map<String, String> participantEmailNameMap = new Map<String, String>();
            
            jobId = ratingList[0].Participant__r.Bureau_Job__c;
            System.debug('Execute jobId '+jobId);
            for(Bureau_Rating__c rating : ratingList){
                participantEmailNameMap.put(rating.Participant__r.Email__c, rating.Participant_Name__c);
            }
            
            for(Bureau_Rating__c rating : ratingList){
                rating.Reminder_1__c ='Eligible';
                if (rating.Rater_Type__c != 'Self') {
                    if (rating.MFS_Status__c != 'Completed') {
                        String respondentEmail = rating.Respondent__r.Email__c.toLowerCase();
                        if (!raterStringMap.containsKey(respondentEmail)) {
                            raterStringMap.put(respondentEmail, participantEmailNameMap.get(rating.Participant__r.Email__c));
                        } else {
                            String oldValue = raterStringMap.get(respondentEmail);
                            if(oldValue == ''){
                                raterStringMap.put(respondentEmail, participantEmailNameMap.get(rating.Participant__r.Email__c));
                            }else{
                                raterStringMap.put(respondentEmail, oldValue + ', ' + participantEmailNameMap.get(rating.Participant__r.Email__c));
                            }
                        }
                    }
                    
                }
                if (rating.Rater_Type__c == 'Self') {
                    selfRatingList.add(rating);
                }
                if(rating.Rater_Type__c != 'Self') {
                    otherRatingList.add(rating);
                }
                
            }
            for(Bureau_Rating__c rating : otherRatingList){
                rating.Rater_String__c = raterStringMap.get(rating.Respondent__r.Email__c.toLowerCase());
            }
            
            if(!selfRatingList.isEmpty()){
                List<Database.SaveResult> ratingResults = Database.update(selfRatingList, false);
                for(Database.SaveResult sr : ratingResults) {
                    if(!sr.isSuccess()){               
                        list<Database.Error> err = sr.getErrors();
                        errors.add(err[0].getStatusCode() + ': ' + err[0].getMessage());
                    }
                }
            }
            if(!otherRatingList.isEmpty()){
                List<Database.SaveResult> ratingResults1 = Database.update(otherRatingList, false);
                for(Database.SaveResult sr : ratingResults1) {
                    if(!sr.isSuccess()){               
                        list<Database.Error> err = sr.getErrors();
                        errors.add(err[0].getStatusCode() + ': ' + err[0].getMessage());
                    }
                }
            }   
            //SSE-28262 Calculates the number of Rating records where the Candidate is listed as the Respondent. 
            //Update Respondent Count field on Candidate.
            RollUpCandidateFields.calculateRespondentCountOnCandidate(ratingList);
            //Calculate Not Transferred Rating Count and Candidate Transfer Status on Job
            RollUpCandidateFields.updateTransferCountonJobOnNewWorkRequest(ratingList);  
            
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        String errorBody;
        String subjectBody;
        
        if(!errors.isEmpty()) {
            subjectBody='Errors Occurred While computing ratings';
            errorBody='Updation failed, some error has occured. Rating updation related to Work Request Number:'+wrfName+' is failing because of following errors mentioned below:'+'<br/>';
            for(String error : errors ){errorBody += error + '<br/>';}
        }else{
            /* Commenting below code as it is added in CandidateBulkUploadBatch and 
             * we are calling CandidateBulkUploadBatch batch class below
		     * to fix Number of Respondent count on job when only a respondent is submitted 
			 * through WRF in case of duplicates in SHL 360/ MFS. (SSE-26836) 
			*/
            /*if(!Test.isRunningTest()){
                String json = RollUpCandidateFields.updateStatusCalculations(jobId);
                Job__c job = new Job__c();job.id = jobId;job.Status_Calculations__c = json;update job;
            }*/
            
            subjectBody='Rating Updation Completed Successfully';
            errorBody='The Rating updation process is completed successfully. All Ratings related to Work Request Number:'+wrfName+' are updated.';
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subjectBody);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(errorBody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
        System.debug('Finish jobId '+jobId);
        /* Added below batch job call to fix Respondent count in case of duplicates for MFS (SSE-26836) */
        CandidateBulkUploadBatch candidatebatch= new CandidateBulkUploadBatch(jobId,'insert','Bureau_Candidate__c');
        Database.executeBatch(candidatebatch, 2000);
    }
}
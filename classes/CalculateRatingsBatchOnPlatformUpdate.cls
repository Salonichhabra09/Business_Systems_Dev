/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-22-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class CalculateRatingsBatchOnPlatformUpdate implements Database.Batchable<sObject>, Database.Stateful {
    private String jobId;
    private String jobName;
    private list<String> errors = new list<String>();
    public Map<String, String> raterStringMap = new Map<String, String>();
    
    public CalculateRatingsBatchOnPlatformUpdate(String jobId, String jobNumber) {
        this.jobId = jobId;
        this.jobName = jobNumber;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Rater_String__c, Reminder_1__c, Report_Ready__c, Participant_Name__c, Respondent_Name__c, Rater_Type__c, MFS_Status__c, Participant__r.Bureau_Job__c,MFS_Report_Sent__c,TC_Report_Sent__c,Overall_Status__c,Participant__r.Email__c, Respondent__r.Email__c from Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = \''+ this.jobId +'\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Bureau_Rating__c> ratingList) {  
        if (!ratingList.isEmpty()) {
            List<Bureau_Rating__c> otherRatingList = new List<Bureau_Rating__c>();
            List<Bureau_Rating__c> selfRatingList = new List<Bureau_Rating__c>();
            Map<String, String> participantEmailNameMap = new Map<String, String>();
            
            jobId = ratingList[0].Participant__r.Bureau_Job__c;
            Map<String,String> reminderMap1 = new Map<String,String>();
            Boolean computeForNonSelf1 = false;
            
            for(Bureau_Rating__c rating : ratingList){
                participantEmailNameMap.put(rating.Participant__r.Email__c, rating.Participant_Name__c);
            }
            
            for(Bureau_Rating__c rating : ratingList){
        
                //rating.Reminder_1__c ='Eligible';
                if (rating.Rater_Type__c == 'Self') {
                        if (rating.MFS_Report_Sent__c == 'Sent' && rating.TC_Report_Sent__c == 'Sent') {
                            computeForNonSelf1 = false;
                            //String participantName = rating.Participant_Name__c.toLowerCase();
                            String participantEmail = rating.Participant__r.Email__c.toLowerCase();
                            reminderMap1.put(participantEmail, 'Not Eligible');
                        }
                        else if (rating.MFS_Report_Sent__c == 'Not Sent' || rating.TC_Report_Sent__c == 'Not Sent') {
                            computeForNonSelf1 = true;
                            //String participantName = rating.Participant_Name__c.toLowerCase();
                            //String respondentName = rating.Respondent_Name__c.toLowerCase();
                            String participantEmail = rating.Participant__r.Email__c.toLowerCase();
                            String respondentEmail = rating.Respondent__r.Email__c.toLowerCase();
                            String key = participantEmail + respondentEmail;
                            if (rating.Overall_Status__c == 'In Progress' || rating.Overall_Status__c == 'Not Started') {
                                reminderMap1.put(key, 'Eligible');
                            }
                            else {
                                reminderMap1.put(key, 'Not Eligible');
                            }
                        }
                    else if(rating.MFS_Report_Sent__c == null && rating.TC_Report_Sent__c == 'Sent'){
                            computeForNonSelf1 = false;
                             String participantEmail = rating.Participant__r.Email__c.toLowerCase();
                            reminderMap1.put(participantEmail, 'Not Eligible');
                        }
                    }
                    if (computeForNonSelf1 && rating.Rater_Type__c != 'Self') {
                        //String participantName = rating.Participant_Name__c.toLowerCase();
                        //String respondentName = rating.Respondent_Name__c.toLowerCase();
                        String participantEmail = rating.Participant__r.Email__c.toLowerCase();
                        String respondentEmail = rating.Respondent__r.Email__c.toLowerCase();
                        String key = participantEmail + respondentEmail;
                        if (rating.Overall_Status__c == 'In Progress' || rating.Overall_Status__c == 'Not Started') {
                            reminderMap1.put(key, 'Eligible');
                        }
                        else {
                            reminderMap1.put(key, 'Not Eligible');
                        }
                    }
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
                    }else if (rating.MFS_Status__c == 'Completed') {
                        String respondentEmail = rating.Respondent__r.Email__c.toLowerCase();
                        if (!raterStringMap.containsKey(respondentEmail)) {
                            raterStringMap.put(respondentEmail, '');
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
            for(Bureau_Rating__c rating : selfRatingList){
                //String participantName = rating.Participant_Name__c.toLowerCase();
                //String respondentName = rating.Respondent_Name__c.toLowerCase();
                String participantEmail = rating.Participant__r.Email__c.toLowerCase();
                String respondentEmail = rating.Respondent__r.Email__c.toLowerCase();
                String key = participantEmail + respondentEmail;
                if (reminderMap1.containsKey(key)) {
                    rating.Reminder_1__c = reminderMap1.get(key);
                } else {
                    rating.Reminder_1__c = reminderMap1.get(participantEmail);
                }
                
            }
            
            for(Bureau_Rating__c rating : otherRatingList){
                rating.Rater_String__c = raterStringMap.get(rating.Respondent__r.Email__c.toLowerCase());
                //String participantName = rating.Participant_Name__c.toLowerCase();
                //String respondentName = rating.Respondent_Name__c.toLowerCase();
                String participantEmail = rating.Participant__r.Email__c.toLowerCase();
                String respondentEmail = rating.Respondent__r.Email__c.toLowerCase();
                String key = participantEmail + respondentEmail;
                if (reminderMap1.containsKey(key)) {
                    rating.Reminder_1__c = reminderMap1.get(key);
                } else {
                    rating.Reminder_1__c = reminderMap1.get(participantEmail);
                }
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
            
            
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        String errorBody;
        String subjectBody;
        
        if(!errors.isEmpty()) {
            subjectBody='Errors Occurred While computing ratings';
            errorBody='Updation failed, some error has occured. Rating updation related to Job Number:'+jobName+' is failing because of following errors mentioned below:'+'<br/>';
            for(String error : errors ){errorBody += error + '<br/>';}
        }else{
            /*if(!Test.isRunningTest()){
                String json = RollUpCandidateFields.updateStatusCalculations(jobId);
                Job__c job = new Job__c();job.id = jobId;job.Status_Calculations__c = json;update job;
            }*/
            
            subjectBody='Rating Updation Completed Successfully';
            errorBody='The Rating updation process is completed successfully. All Ratings related to Job Number:'+jobName+' are updated.';
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subjectBody);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(errorBody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
        
    }

}
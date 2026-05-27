/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-31-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class BATCH_CreateAPINameSheetForRatingWRF implements Database.Batchable<sObject>,Database.Stateful{
    
    public final String csvHeader = 'Rater_Type__c,Participant__c,Respondent__c'+'\n';
    public final String workRequestId;
    private list<String> errors = new list<String>();
    public Integer flag = 0;
    public Map<String, String> raterStringMap = new Map<String, String>();
    
    public BATCH_CreateAPINameSheetForRatingWRF(String wrfId) {
        workRequestId = wrfId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> docIdSet = new Set<Id>();
        List<ContentDocumentLink> docLinkList = [SELECT LinkedEntity.type, ContentDocumentId 
                                                 FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId = :workRequestId];
        for(ContentDocumentLink link : docLinkList) {
            docIdSet.add(link.ContentDocumentId);
        }
        return Database.getQueryLocator([SELECT VersionData, Title, ContentDocumentId
                                         FROM ContentVersion 
                                         WHERE ContentDocumentId IN :docIdSet
                                         AND Title LIKE '%CandidateWRFImportRating%' order by createddate asc]);   
    }
    
    public void execute(Database.BatchableContext BC, List<ContentVersion> versionList) {
        flag = flag + 1;
        System.debug('flagValue ='+flag);
        System.debug('versionList ###'+versionList.size());
        Set<Id> docIdSet = new Set<Id>();
        Set<String> respondantEmailSet = new Set<String>();
        Set<String> recepientEmailSet = new Set<String>();
        List<String> rows = new List<String>();
        Map<String, String> respondantMap = new Map<String, String>();
        Map<String, String> recepientMap = new Map<String, String>();
        Map<String, String> respondantEmailNameMap = new Map<String, String>();
        Map<String, String> participantEmailNameMap = new Map<String, String>();
        Map<String, String> respondantIdNameMap = new Map<String, String>();
        Boolean selfRatingDone = false;
        try{
        for(ContentVersion version : versionList) {
            if((version.Title).contains('CandidateWRFImportRating')) {
                rows = version.VersionData.toString().split('\n');
                docIdSet.add(version.ContentDocumentId);
            }
        }
        System.debug('docIdSet '+docIdSet);
        for(Integer i=1;i<rows.size();i++) {
            System.debug('**getHeapSize**='+Limits.getHeapSize());
            List<String> cols = rows[i].split(',');
            System.debug('**getHeapSize**='+Limits.getHeapSize());
            cols[2] = cols[2].replace('\n','');
            cols[2] = cols[2].replace('\r','');
            cols[2] = cols[2].replace('\r\n','');
            recepientEmailSet.add(cols[2]);
            respondantEmailSet.add(cols[1]);
        }
        List<work_request__c> WRFcategory = [SELECT id,System_Used__c,Job__c, Job__r.System_Used__c, Deadline_Date__c from Work_Request__c where id= :workRequestId ];	
        List<Bureau_Candidate__c> respondantCandidate = [SELECT Id, Email__c 
                                                         FROM Bureau_Candidate__c
                                                         WHERE Email__c IN :respondantEmailSet
                                                         AND Bureau_Job__c =:WRFcategory[0].Job__c];
        List<Bureau_Candidate__c> recepientCandidate = [SELECT Id, Email__c 
                                                        FROM Bureau_Candidate__c
                                                        WHERE Email__c IN :recepientEmailSet
                                                        AND Bureau_Job__c =:WRFcategory[0].Job__c];
        //    String jobIDd = WRFcategory[0].Job__c;
        //Job__c jobbb = [SELECT Id, System_Used__c FROM Job__c WHERE Id = :jobIDd];
        //    System.debug('jobbb '+ jobbb);
        for(Bureau_Candidate__c candidate : respondantCandidate) {
            respondantMap.put(candidate.Email__c, candidate.Id);
        }
        for(Bureau_Candidate__c candidate : recepientCandidate) {
            recepientMap.put(candidate.Email__c, candidate.Id);
        }
        List<Bureau_Rating__c> selfRatingList = new List<Bureau_Rating__c>();
        List<Bureau_Rating__c> otherRatingList = new List<Bureau_Rating__c>();
        
        List<String> newRows = new List<String>();
        for(Integer i=1;i<rows.size();i++){

            List<String> cols = rows[i].split(',');
            cols[2] = cols[2].replace('\n','');
            cols[2] = cols[2].replace('\r','');
            cols[2] = cols[2].replace('\r\n','');

            Bureau_Rating__c rating = new Bureau_Rating__c();
            rating.Rater_Type__c = cols[0];
            rating.Respondent__c = respondantMap.get(cols[1].toLowerCase());
            rating.Participant__c = recepientMap.get(cols[2].toLowerCase());
            rating.Work_Request__c = workRequestId;//Adding Work Request Id in Ratings
			rating.Deadline__c = WRFcategory[0].Deadline_Date__c;
            if(WRFcategory[0]?.Job__r?.System_Used__c?.contains('MFS')){
                rating.MFS_Status__c ='Not Started';
                //rating.Reminder_1__c ='Eligible';
                if(cols[0] == 'Self'){
                    rating.TC_Status__c ='Not Started';
                    rating.TC_Report_Sent__c ='Not Sent';
                    rating.MFS_Report_Sent__c ='Not Sent';
                }
            }
            else{
                rating.TC_Status__c ='Not Started';
                rating.TC_Report_Sent__c ='Not Sent';
            }
            
           if(cols[0]=='Self') {
                selfRatingList.add(rating);
            }
            else {
                otherRatingList.add(rating);
            }
        }
            
        if(selfRatingList.size()>0) {
            Database.Insert(selfRatingList,false);
            selfRatingDone = true;
        }
            
        if(selfRatingDone && otherRatingList.size()>0) {
            Database.Insert(otherRatingList, false);
        }
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id IN :docIdSet];
        DELETE docs;
        }catch(Exception ex){
          errors.add(ex.getMessage());
      }
    }
    
    public void finish(Database.BatchableContext BC){
        String errorBody;
        String subjectBody;
        String wrfName;
        
      Work_Request__c wrfRec=[Select id,name from Work_Request__c where id=: workRequestId];
      wrfName = wrfRec.name;
        if(flag > 0){
            if(!errors.isEmpty()) {
          subjectBody='Errors Occurred While Ratings Creation';
          errorBody='Rating creation failed, some error has occured. Ratings creation related to work request Number:'+wrfName+' is failing because of following errors mentioned below:'+'<br/>';
          errorBody += errors[0] + '<br/>';
      }else{
        subjectBody='Ratings Creation Completed Successfully';
        errorBody='The Ratings creation process is completed successfully. All Ratings related to work request Number:'+wrfName+' are created.';
     }
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setSubject(subjectBody);
      mail.setTargetObjectId(UserInfo.getUserId());
      mail.setSaveAsActivity(false);
      mail.setHtmlBody(errorBody);
      Messaging.sendEmail(new Messaging.Email[] { mail });
      
        }
      CandidateBulkUploadBatchWRF candidatebatch= new CandidateBulkUploadBatchWRF(this.workRequestId);
      Database.executeBatch(candidatebatch, 2000);
    }
}
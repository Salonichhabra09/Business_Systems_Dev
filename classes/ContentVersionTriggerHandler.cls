public class ContentVersionTriggerHandler {
    public static void afterInsert(List<ContentVersion> contentVersionList){
        for(ContentVersion cv : contentVersionList){
            System.debug('cv --> '+ cv.Title);
            if((cv.Title).contains('_CandidateImportSheet')){
                System.debug('cv --> Inside If '+ cv.Title);
                CandidateUploadContoller.getDataFromFile(cv.ContentDocumentId, 'insert','Bureau_Candidate__c');
            }
            if((cv.Title).contains('_CandidateUpdateSheet')){
                System.debug('cv --> Inside If '+ cv.Title);
                CandidateUploadContoller.getDataFromFile(cv.ContentDocumentId, 'update','Bureau_Candidate__c');
            }
            if((cv.Title).contains('_CandidateWRFImportSheet')){
                System.debug('cv --> Inside If '+ cv.Title);
                CustomerRequestController.getDataFromFile(cv.ContentDocumentId, 'insert');
            }
             if((cv.Title).contains('_CandidateWRFUpdateSheet')){
                System.debug('cv --> Inside If '+ cv.Title);
                CandidateUploadContoller.getDataFromFile(cv.ContentDocumentId, 'update','Bureau_Candidate__c');
            }
            if((cv.Title).contains('_PlatformWRFUpdateSheet')){
                System.debug('cv --> Inside If '+ cv.Title);
                CandidateUploadContoller.getDataFromFile(cv.ContentDocumentId, 'update','Bureau_Rating__c');
            }
        }
    }
    
    public static void CancellationFilesOnOpportunity(Map<Id, ContentVersion> contentDocumentMap){
        Set<Id> contentDocId = new Set<Id>();
        Map<Id,Id> oppContentDocMap = new Map<Id,Id>();
        Map<Id,Opportunity> oppsToUpdate = new Map<Id,Opportunity>();
        Boolean containsCancel = false;
        Boolean containsRescind = false;
        List<String> rescindNoticeKeywordsList = System.Label.Opportunity_Rescind_Notice_Keywords.split(',');
        List<String> cancellationNoticeKeywordsList = System.Label.Opportunity_Cancellation_Notice_Keywords.split(',');
            
        for(ContentVersion doc : contentDocumentMap.values()){
            For(String keyword:rescindNoticeKeywordsList){
                if(doc.title.containsIgnoreCase(keyword)){
                    containsRescind = true;
                }
            }
            For(String keyword:cancellationNoticeKeywordsList){
                if(doc.title.containsIgnoreCase(keyword)){
                   containsCancel = true;
                }
            }
            if(containsCancel || containsRescind){
                    contentDocId.add(doc.ContentDocumentId);
                }
        }
        System.debug('Doc Size '+contentDocId.size());
        if(contentDocId.size()>0){
            Map<Id,ContentDocumentLink> conDocLinkMap = new Map<Id,ContentDocumentLink>([SELECT LinkedEntity.type, ContentDocumentId, LinkedEntityId
                                                                                         FROM ContentDocumentLink 
                                                                                         WHERE ContentDocumentId IN :contentDocId]);
            System.debug('Link Size '+conDocLinkMap.values().size());    
            for(ContentDocumentLink link : conDocLinkMap.values()){
                String objectName = String.valueOf(link.LinkedEntityId.getsobjecttype());
                if(objectName == 'Opportunity') {
                    oppContentDocMap.put(link.ContentDocumentId,link.LinkedEntityId);
                }
            }
            System.debug('Opp Size '+oppContentDocMap.values().size());
            if(!oppContentDocMap.isEmpty()){
                Map<Id,Opportunity> linkedOpps = new Map<Id,Opportunity>([Select id,Forecast_Category__c,At_Risk_Reason__c,Business_Type__c,stagename,CloseDate,Auto_Close_Date__c,Eligible_for_Auto_Close__c,CLM_Contract_Status__c from opportunity where id in :oppContentDocMap.values()]);
                List<ContentDocument> contentdocs = new List<ContentDocument>([select id,title from ContentDocument where id in:oppContentDocMap.keyset()]);
                for(ContentDocument contentdoc:contentdocs){
                    System.debug('File Name '+contentdoc.title);
                    for(String keyword:cancellationNoticeKeywordsList)
                    if(containsCancel && !containsRescind
                       && linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Business_Type__c=='Renewal'){
                           linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Forecast_Category__c = 'Renewal at Risk';
                           linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).At_Risk_Reason__c = 'Written Cancellation';
                           linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Cancellation_Notice_Received__c = System.now();
                           oppsToUpdate.put(linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Id,linkedOpps.get(oppContentDocMap.get(contentdoc.Id)));
                       }
                    else if (containsRescind
                             && linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Business_Type__c=='Renewal'){
                                 if (linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).StageName == 'Closed Lost' && linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).CloseDate.addDays(30) >= Date.today()) {
                                        linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).StageName = 'Verbal';
                                        linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Auto_Close_Date__c= null;
                                        linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Eligible_for_Auto_Close__c= False;
                                        linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).CLM_Contract_Status__c= null;
                                        linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Skip_Validation_Auto_Renewal__c=True;
                                        linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).At_Risk_Reason__c = null;
                                        linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Cancellation_Rescind_Notice_Received__c = System.now();
                                    }
                                 else{
                                 linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Forecast_Category__c = 'Pipeline';
                                 linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).At_Risk_Reason__c = null;
                                 linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Cancellation_Rescind_Notice_Received__c = System.now();
                                 }
                                 if(!oppsToUpdate.containsKey(linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Id)){
                                      oppsToUpdate.put(linkedOpps.get(oppContentDocMap.get(contentdoc.Id)).Id,linkedOpps.get(oppContentDocMap.get(contentdoc.Id)));
                                 }
                                
                             }   
                }
                
                if(oppsToUpdate.size()>0){
                    update oppsToUpdate.values();
                }
                
            }
        }
    }
        //Added by Prachi --SSE-21436
    public static void avoidChangeDescription(list<ContentVersion> newCVList, map<Id, ContentVersion> oldMap){
        if(newCVList != null){
            for(ContentVersion cv : newCVList ){
                if(oldMap.get(cv.id).Description == 'This is an autogenerated PDF for Account Plan.' &&
                   oldMap.get(cv.id).Description != cv.Description){
                    cv.addError('This is an auto generated PDF. You can not update its description');
                }
                //Added by Prachi as part of SSE-21596
                 if(oldMap.get(cv.id).Description == 'This is an autogenerated csv for Uploaded Contacts.' &&
                   oldMap.get(cv.id).Description != cv.Description){
                    cv.addError('This is an auto generated CSV. You can not update its description');
                }
                
                if(oldMap.get(cv.id).Description == 'This excel template has been created for account plan export functionality. Must not delete and change without consulting with Salesforce Team.' &&
                   oldMap.get(cv.id).Description != cv.Description){
                    cv.addError('This excel template has been created for account plan export functionality. You do not have access to change the description.');
                }
            }
        }
    }
}
public with sharing class CandidateUploadContoller {
    public CandidateUploadContoller() {
        
    }
    
    @AuraEnabled
    //public static list<Id> getCandidateIdsRelateToJob(String jobId){
    public static Boolean getCandidateIdsRelateToJob(list<Id> candidateIds, String jobId){
        try {
            if(candidateIds == null || candidateIds.isEmpty()) return false;
            list<Bureau_Candidate__c> candidateList = new list<Bureau_Candidate__c>();
            list<Id> candidateIdsList = new list<Id>();
            candidateList = [SELECT Id FROM Bureau_Candidate__c WHERE Bureau_Job__c =: jobId AND Id IN :candidateIds];
            for(Bureau_Candidate__c bCandidate : candidateList){
                candidateIdsList.add(bCandidate.Id);
            }
            /*if(candidateIdsList.size()>0)
                return candidateIdsList;
            else {
                return new list<Id>();
            }*/
            if(candidateIdsList.size() == candidateIds.size())
                return true;
            else {
                return false;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Job__c> getJobData(String recordId){
        try {
            list<Job__c> jobList = new list<Job__c>();
            jobList = [SELECT Id,Name,System_Used__c, MS_Line_of_Business__c, Job_Region__c FROM Job__c WHERE Id =: recordId];
            if(jobList.size()>0){
                return jobList;
            }else {
                return new list<Job__c>();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string insertContentDistribution(String contentDocumentId, String contentVersionId){
        try {
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Test';
            cd.ContentVersionId = contentVersionId;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;
            
            ContentDistribution coi = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId =: contentDocumentId LIMIT 1];
            System.debug('coi --> '+coi);
            String fileUrl;
            fileUrl = coi.DistributionPublicUrl;
            return fileUrl;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        ContentVersion cv = new ContentVersion();
        ContentDocumentLink cdl = new ContentDocumentLink();
        if(!String.isBlank(base64)){
            cv = createContentVersion(base64, fileName);
            if(cv != null){
                cdl = createContentLink(cv.Id, recordId);
            }
        }
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
        
        ContentVersion cv = new ContentVersion();
        String encoded = EncodingUtil.urlEncode(base64, 'UTF-8');
        String decoded =  EncodingUtil.urlDecode(encoded,'UTF-8');
        cv.VersionData = Blob.valueOf('\uFEFF'+decoded);
        cv.Title = filename;
        cv.PathOnClient = filename;
        System.debug('Content Version cv '+cv);
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    /*
* @method createContentLink() [private]
* @desc Creates a content link for a given ContentVersion and record
* 
* @param {String} contentVersionId - Id of the ContentVersion of the file
* @param {String} recordId - Id of the record you want to attach this file to
* 
* @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
*   or null if there was an error inserting the record
*/
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null){
            return null; 
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Bureau_Candidate__c> createCandidates(String candidatesJSON, Id jobId, Boolean isUpdate) {
        
        try{
            List<Bureau_Candidate__c> lstCCToInsert = (List<Bureau_Candidate__c>) JSON.deserialize(candidatesJSON, List<Bureau_Candidate__c>.class);
            List<Bureau_Candidate__c> lstCCToUpdate = new List<Bureau_Candidate__c>();
            if(lstCCToInsert.size()>0){ 
                if(!isUpdate){
                    Set<Id> insertedCandIds =new set<id>();
                    List<Database.Error> errorList =new List<Database.Error>();
                    System.debug('lstCCToInsert Size ###'+lstCCToInsert.size());
                    Database.SaveResult[] srList = Database.insert(lstCCToInsert, false);
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            insertedCandIds.add(sr.getId());
                        }else{
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug('Error Message: ' + err.getMessage());
                                if(!(err.getMessage().toUpperCase()).contains('DUPLICATE')){
                                    throw new DMLException(err.getMessage());
                                }else{
                                    errorList.add(err);
                                }
                            }
                        }
                    }
                    system.debug('test**'+errorList);
                    system.debug('size**'+errorList.size());
                    if(errorList.size() == lstCCToInsert.size()){
                        throw new DMLException('This file has been already imported : '+errorList[0].getMessage());
                    }
                    List<Bureau_Candidate__c> insertedCandList=[Select id,Number_of_Product_Assessment__c,Bureau_Job__c,Number_of_participants__c,
                                                             Number_of_Respondents__c from Bureau_Candidate__c where id in: insertedCandIds];
                    Map<Id, Bureau_Candidate__c> candidateMap = new Map<Id, Bureau_Candidate__c>(insertedCandList);
                    RollUpCandidateFields.calculateCountFields(candidateMap);
                    RollUpCandidateFields.updateRollupSummaryFieldsOnJob(insertedCandList);
                    return lstCCToInsert;
                }else{
                    set<id> candidateIds=new set<id>();
                    for(Integer i=0 ; i<lstCCToInsert.size() ; i++){
                        Bureau_Candidate__c bureauCandidateUpdate = new Bureau_Candidate__c();
                        bureauCandidateUpdate.Id = lstCCToInsert[i].Id;
                        bureauCandidateUpdate.First_Name__c = lstCCToInsert[i].First_Name__c;
                        bureauCandidateUpdate.Last_Name__c = lstCCToInsert[i].Last_Name__c;
                        bureauCandidateUpdate.Email__c = lstCCToInsert[i].Email__c;
                        bureauCandidateUpdate.Country__c = lstCCToInsert[i].Country__c;
                        bureauCandidateUpdate.Language__c = lstCCToInsert[i].Language__c;
                        bureauCandidateUpdate.Gender__c = lstCCToInsert[i].Gender__c;
                        bureauCandidateUpdate.Phone_Number__c = lstCCToInsert[i].Phone_Number__c;
                        bureauCandidateUpdate.Status2__c = lstCCToInsert[i].Status2__c;
                        bureauCandidateUpdate.Reports_Status__c = lstCCToInsert[i].Reports_Status__c;
                        bureauCandidateUpdate.Username__c = lstCCToInsert[i].Username__c;
                        bureauCandidateUpdate.Product_Assessment__c = lstCCToInsert[i].Product_Assessment__c;
                        bureauCandidateUpdate.System_s__c = lstCCToInsert[i].System_s__c;
                        bureauCandidateUpdate.Email_as_Username__c = lstCCToInsert[i].Email_as_Username__c;
                        bureauCandidateUpdate.Candidate_Unique_Id__c = lstCCToInsert[i].Candidate_Unique_Id__c;
                        lstCCToUpdate.add(bureauCandidateUpdate);
                        candidateIds.add(lstCCToInsert[i].Id);
                    }
                    
                    Map<Id, Bureau_Candidate__c> oldCandidateMap = new Map<Id, Bureau_Candidate__c>([Select id,Status2__c,Number_of_Product_Assessment__c,Bureau_Job__c,
                                                                Number_of_participants__c,Number_of_Respondents__c from Bureau_Candidate__c where id in: candidateIds]);
                    if(lstCCToUpdate.size()>0){
                        Database.update(lstCCToUpdate, false); 
                    }
                    List<Bureau_Candidate__c> newCandidateList =[Select id,Number_of_Product_Assessment__c,Status2__c,Bureau_Job__c,
                                                                Number_of_participants__c,Number_of_Respondents__c from Bureau_Candidate__c where id in: candidateIds];
                    
                    Map<Id, Bureau_Candidate__c> candidateMap = new Map<Id, Bureau_Candidate__c>(newCandidateList);        
                    RollUpCandidateFields.updateRollupSummaryFieldsJobUpdate(newCandidateList, oldCandidateMap);
                    RollUpCandidateFields.updateCountsOnJob(candidateMap,oldCandidateMap);
                }
            }
        }catch(Exception e){
            System.debug('Inside Catch Error Message: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }
        return new List<Bureau_Candidate__c>();
    }
    
    //@AuraEnabled
    public static void getDataFromFile(String contentDocumentId, String operationType, String ObjectName){
        List<ResponseWrapper> responseWrapper = new List<ResponseWrapper>();
        try {
            Id contentDocId = Id.valueOf(contentDocumentId);
            System.debug('contentDocId: '+ contentDocId);
            List<Id> fileIdsList = new List<Id>{contentDocId};
                List<BulkDataWrapper> lstWrapper = new List<BulkDataWrapper>();
            BulkDataWrapper wrapper = new BulkDataWrapper();
            wrapper.objectName = ObjectName;
            wrapper.operation = operationType;
            wrapper.fileIdList = fileIdsList;
            System.debug('BulkDataWrapper Wrapper --> '+ wrapper);
            lstWrapper.add(wrapper);
            importBulkdata(fileIdsList, operationType,ObjectName);
            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        }
    
    @future(callout=true)
    public static void importBulkdata(List<Id> fileIdsList, String operationType, String ObjectNameToUse) {
        System.debug('importBulkdata HEap Size --> '+Limits.getHeapSize());
        System.debug('importBulkdata HEap Size --> '+Limits.getLimitHeapSize());
        ResponseWrapper rw = new ResponseWrapper();
        String objectName = ObjectNameToUse;
        String operation = operationType;
        String contentDocumentId = fileIdsList[0];
        String jobRecordId;
        
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId ];
        
        String encoded = EncodingUtil.urlEncode(cv.VersionData.toString(), 'UTF-8');
        System.debug('encoded '+encoded);
        String encodedAdded;
        if(operationType == 'insert'){
            // Change for Rating
            System.debug('encoded substring '+ encoded.substringAfter('Category__c'));
            encodedAdded = 'Category__c'+encoded.substringAfter('Category__c');
        }else{
            System.debug('encoded substring '+ encoded.substringAfter('Id'));
            encodedAdded = 'Id'+encoded.substringAfter('Id');
        }
        
        System.debug('encodedAdded '+encodedAdded);
        String decoded =  EncodingUtil.urlDecode(encodedAdded,'UTF-8');
        System.debug('decoded '+decoded);
        
        list<ContentDocumentLink> contentDocumentLinkList = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: contentDocumentId];
        for(ContentDocumentLink con : contentDocumentLinkList){
            String lineID = con.LinkedEntityId;
            if(lineID.substring(0,3) != '005'){
                jobRecordId = con.LinkedEntityId; 
            }
        }
        Job__c jobRecord = [SELECT Id, bulkJobId__c FROM Job__c WHERE Id =: jobRecordId];
        /* ******************************** */
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/ingest');
        request.setHeader('content-type', 'application/json');
        request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
        
        String typeFile = 'text/csv;charset=UTF-8';
        String body = '{ '+
            '"externalIdFieldName": "Id",'+  
            '"lineEnding": "LF",'+ 
            '"operation": "'+operation+'",'+ 
            '"object": "'+objectName+'",'+ 
            '"contentType": "CSV"'+
            '}';
        request.setBody(body);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        System.debug('resp all --> '+resp.getBody());
        System.debug('resp.getStatusCode() --> '+resp.getStatusCode());
        if(resp.getStatusCode() <= 299) {
            Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
            String jobId = (String)respMap.get('id'); 
            //second request to store data
            HttpRequest request1 = new HttpRequest();
            request1.setMethod('PUT');
            request1.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/ingest/'+jobId+'/batches');
            request1.setHeader('content-type', 'text/csv;charset=UTF-8');
            request1.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());  
            request1.setHeader('Sforce-Enable-Null-For-Empty-Field', 'true');
            System.debug('Heap Size 172 --> '+Limits.getHeapSize());
            request1.setBody(decoded);
            System.debug('Heap Size 174 --> '+Limits.getHeapSize());
            Http h1 = new Http();
            HttpResponse resp1 = h1.send(request1);
            System.debug('resp1.getStatusCode() --> '+resp1.getStatusCode());
            if(resp1.getStatusCode() <= 299) {
                //third request to start processing
                HttpRequest request2 = new HttpRequest();
                request2.setMethod('PATCH');
                request2.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/ingest/'+jobId);
                request2.setHeader('content-type', 'application/json');
                request2.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
                request2.setHeader('Sforce-Enable-Null-For-Empty-Field', 'true');
                
                request2.setBody('{ "state" : "UploadComplete" }');
                Http h2 = new Http();
                HttpResponse resp2 = h2.send(request2);
                System.debug('resp2.getStatusCode() --> '+resp2.getStatusCode());
                System.debug('jobId: '+ jobId);
                if(resp2.getStatusCode() <= 299) {
                    
                    rw.response = jobId;
                    String toAddJobId;
                    if(jobRecord.bulkJobId__c != null){
                        toAddJobId = jobRecord.bulkJobId__c;
                        jobRecord.bulkJobId__c = jobId + ',' + toAddJobId;    
                        System.debug('jobId: '+ jobRecord.bulkJobId__c);
                    }else{
                        System.debug('jobId: '+ jobRecord.bulkJobId__c);
                        jobRecord.bulkJobId__c = jobId;
                    }
                    UPDATE jobRecord;
                } else {
                    rw.response = 'There was an error. Please contact your admin.';
                }
            }
        }
        //}
        //return new List<ResponseWrapper>{rw};
        System.debug('At Method End importBulkdata HEap Size --> '+Limits.getHeapSize());
        System.debug('At Method End importBulkdata HEap Size --> '+Limits.getLimitHeapSize());
    }
    
    @AuraEnabled
    public static void getJobStatus(String jobId,String operationType, String objectName) {
        try {
            ScheduleClassToGetJobStatus scheduleJob = new ScheduleClassToGetJobStatus(jobId,operationType,objectName);
            Datetime scheduledDate =Datetime.now().addMinutes(5);
            String hour = String.valueOf(scheduledDate.hour());
            String min = String.valueOf(scheduledDate.minute());
            String ss = String.valueOf(scheduledDate.second());
            // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String sch = ss + ' ' + min + ' ' + hour + ' * * ?';
            String jobID1 = System.schedule('Get Bulk Job Status '+System.now(), sch, scheduleJob);
        }
        catch(Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    @AuraEnabled
    public static JobDetailsWrapper getJobDetails(String jobId){
        JobDetailsWrapper jobDetail = new JobDetailsWrapper();
        System.debug('jobId --> '+jobId);
        //Check the status of the job
        try {
            HttpRequest request3 = new HttpRequest();
            request3.setMethod('GET');
            request3.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/ingest/'+jobId);
            request3.setHeader('content-type', 'application/json;charset=UTF-8' );
            request3.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
            request3.setTimeout(120000);
            
            Http h3 = new Http();
            HttpResponse resp3 = h3.send(request3);
            System.debug('resp3.getStatusCode() --> '+resp3.getStatusCode());
            if(resp3.getStatusCode() <= 299){
                System.debug('resp3.getBody() --> '+resp3.getBody());
                Map<String, Object> respMap3 = (Map<String, Object>) JSON.deserializeUntyped(resp3.getBody());
                String jobState = (String)respMap3.get('state');
                Integer numberRecordsFailed = (Integer)respMap3.get('numberRecordsFailed'); 
                System.debug('numberRecordsFailed '+numberRecordsFailed);
                Integer numberRecordsProcessed = (Integer)respMap3.get('numberRecordsProcessed'); 
                System.debug('numberRecordsProcessed '+numberRecordsProcessed);
                
                jobDetail.numberOfRecordsFailed = numberRecordsFailed;
                jobDetail.numberOfRecordsProcessed = numberRecordsProcessed;
                jobDetail.state = (jobState == 'JobComplete') ? 'Job has been Completed' : (jobState == 'Failed' || jobState == 'Aborted') ? 'Job has been Failed' : (jobState == 'Open') ? 'Job has been Opened' : 'Job is in Progress';   
            }else{
                jobDetail.state = 'Job has been Failed';
            }
            //}
            System.debug('Wrapper Result --> '+jobDetail);
            return jobDetail;
        }
        catch(Exception exp) {
            System.debug('exp.getMessage() ###'+exp.getMessage());
            throw new AuraHandledException(exp.getMessage());
        }
        }
    
    @AuraEnabled
    public static String getSuccessRecords(String jobId){
        Boolean flag = false;
        HttpResponse resp4;
        try {
            HttpRequest request4 = new HttpRequest();
            request4.setMethod('GET');
            request4.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/ingest/'+jobId+'/successfulResults');
            request4.setHeader('content-type', 'text/csv;charset=UTF-8' );
            request4.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
            request4.setTimeout(120000);
            
            Http h4 = new Http();
            resp4 = h4.send(request4);
            if(resp4.getStatusCode() <= 299) {
                flag = true;
            }
            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        if(flag)
            return resp4.getBody();
        else {
            return 'Error Occurred';
        }
    }
    
    @AuraEnabled
    public static String getFailedRecords(String jobId){
        Boolean flag = false;
        HttpResponse resp5;
        try {
            HttpRequest request5 = new HttpRequest();
            request5.setMethod('GET');
            request5.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/ingest/'+jobId+'/failedResults');
            request5.setHeader('content-type', 'text/csv;charset=UTF-8' );
            request5.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
            System.debug('Heap Size 365 --> '+Limits.getHeapSize());
            Http h5 = new Http();
            resp5 = h5.send(request5);
            if(resp5.getStatusCode() <= 299) 
                flag = true;
            System.debug('Heap Size 368 --> '+Limits.getHeapSize());
            System.debug('Response --> '+resp5.getBody());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        if(flag)
            return resp5.getBody();
        else {
            return 'Error Occurred';
        }
    }
    
    @AuraEnabled
    public static ExportWrapper getCandidateCount(String jobId, Integer offSetValue){
        list<Bureau_Candidate__c> candidateList = new list<Bureau_Candidate__c>();
        Integer candidateCount;
        String message;
        candidateCount = [Select count() FROM Bureau_Candidate__c WHERE Bureau_Job__c =: jobId];
        System.debug('candidateCount -> '+candidateCount);
        ExportWrapper wrapper = new ExportWrapper();
        if(candidateCount == 0){
            candidateList = null;
            message = 'No Data found to Export';
        }else if(candidateCount <= 40000){
            candidateList = getCandidateData(jobId, offSetValue);
            message = 'Export Immediately';
            System.debug('candidateList --> '+candidateList);
        }else{
            candidateList = null;
            message = 'This job has candidates more than 40000 and can not be export Immediately. So a background process has been started and you will be notified by an email once export is completed.';
            exportCandidatesAsync(jobId);
            }
        wrapper.candidateCount = candidateCount;
        wrapper.candidateData = candidateList;
        wrapper.message = message;
        System.debug('wrapper --> '+wrapper);
        return wrapper;
    }
    
    public static list<Bureau_Candidate__c> getCandidateData(String jobId, Integer offSetValue){
        try {
            list<Bureau_Candidate__c> candidateList = new list<Bureau_Candidate__c>();
            candidateList = [SELECT Id,Name,First_Name__c,Last_Name__c,Email__c,Email2__c,Gender__c,Phone_Number__c,Country__c,Language__c,JCF_Name__c,
                             Region__c,Job_Role__c,Job_Level__c,Department__c,Functional_Role__c,Candidate_Personal_Id__c,Talent_Central_ID__c,Session_ID__c,
                             Unique_Link__c,Project_Name__c,Generic_Data_1__c,Generic_Data_2__c,Generic_Data_3__c,Reports_Status__c,Status__c,Status2__c,
                             Username__c,Product_Assessment__c,System_s__c,Bureau_Job__c, Bureau_Job__r.Name, Username_New__c,Email_as_Username__c 
                             FROM Bureau_Candidate__c 
                             WHERE Bureau_Job__c =: jobId AND isExported__c = false ORDER BY CreatedDate DESC LIMIT 40000];
            if(candidateList.size() > 0){
                return candidateList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return new list<Bureau_Candidate__c>();
    }
    
    public static void exportCandidatesFiles(String jobId){
        List<id> ContentDocumentids = new List<id>();
        
        for(ContentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid=:jobId]){
            ContentDocumentids.add(CDLink.ContentDocumentid);  
        }
        list<Messaging.EmailFileAttachment> fileAttachments = new list<Messaging.EmailFileAttachment>();
        for(ContentVersion cversion : [SELECT title, PathOnClient, FileType, VersionData FROM contentversion WHERE ContentDocumentId IN :ContentDocumentids AND title LIKE '%_CandidateFileUpload%']){
            Blob WOCFbody = cversion.VersionData;
            System.debug('body : '+WOCFbody+'-----------'+cversion.title);
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(cversion.title + '.' + cversion.FileType);
            efa.setBody(WOCFbody);
            fileAttachments.add(efa); 
        }
        System.debug('fileAttachments --> '+fileAttachments);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'aashi.aashi@shl.com'};
            String subject = 'Candidate Export for ';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('company details which doesnt have members CSV');
        email.setFileAttachments(fileAttachments);
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        
    }
    
    public static void exportCandidatesAsync(String jobId){
        try {
            Job__c job = [SELECT Id, Name, RecordTypeId, Capture_Content_Version_Ids_For_Export__c FROM Job__c WHERE Id =: jobId];
            ExportCandidateData exportBatch = new ExportCandidateData(job, 0);
            Id batchprocessid = Database.executeBatch(exportBatch, 200);
            System.debug('batchprocessid --> '+batchprocessid);
            System.debug('This job has candidates more than 6000 and can not be export Immediately. So a background process has been started and you will be notified by an email once export is completed.');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Integer handleButtonVisibilityApex(String jobId){
        Integer candidateCount = [Select count() FROM Bureau_Candidate__c WHERE Bureau_Job__c =: jobId];
        return candidateCount;
    }
    
    public class ExportWrapper {
        @AuraEnabled
        public List<Bureau_Candidate__c> candidateData {get; set;}
        @AuraEnabled
        public Integer candidateCount {get; set;}
        @AuraEnabled
        public String message {get; set;}
    }
    
    public class BulkDataWrapper {
        public List<Id> fileIdList;
        public String objectName;
        public String operation;
    }
    
    public class ResponseWrapper {
        public String response;
    }
    
    public class JobDetailsWrapper{
        @AuraEnabled
        public Integer numberOfRecordsFailed;
        @AuraEnabled
        public Integer numberOfRecordsProcessed;
        @AuraEnabled 
        public String state;
        @AuraEnabled
        public String failedRecords;
        @AuraEnabled
        public String successRecords;
    }
    
    public class RatingWrapper {
        public String Category;
        public String Email;
        public String Recipient_Email;
    }
    
    @AuraEnabled
    public static void createRatings(String ratingJSON, String bureauJobId, Boolean isUpdate) {
        System.debug('ratingJSON ####'+ratingJSON);
        System.debug('bureauJobId ####'+bureauJobId);
        Boolean selfRatingDone = false;
        List<Bureau_Rating__c> selfRatingList = new List<Bureau_Rating__c>();
        List<Bureau_Rating__c> otherRatingList = new List<Bureau_Rating__c>();
        Set<String> respondantEmailList = new Set<String>();
        Set<String> recepientEmailList = new Set<String>();
        Map<String, String> respondantMap = new Map<String, String>();
        Map<String, String> recepientMap = new Map<String, String>();
        Map<Id, Bureau_Candidate__c> oldCandidateMap=new Map<Id, Bureau_Candidate__c>();
        List<RatingWrapper> ratingList = (List<RatingWrapper>) JSON.deserialize(ratingJSON, List<RatingWrapper>.class);
        try {
            for(RatingWrapper rw : ratingList) {
                respondantEmailList.add(rw.Email);
                recepientEmailList.add(rw.Recipient_Email);
            }
            System.debug('recepientEmailList ###'+recepientEmailList);
            List<Bureau_Candidate__c> respondantCandidate = [SELECT Id, Email__c                                                             FROM Bureau_Candidate__c
                                                             WHERE Email__c IN :respondantEmailList
                                                             AND Bureau_Job__c = :bureauJobId];
            List<Bureau_Candidate__c> recepientCandidate = [SELECT Id, Email__c 
                                                            FROM Bureau_Candidate__c
                                                            WHERE Email__c IN :recepientEmailList
                                                            AND Bureau_Job__c = :bureauJobId];
            System.debug('recepientCandidate ###'+recepientCandidate);
            for(Bureau_Candidate__c candidate : respondantCandidate) {
                respondantMap.put(candidate.Email__c, candidate.Id);
            }
            for(Bureau_Candidate__c candidate : recepientCandidate) {
                recepientMap.put(candidate.Email__c, candidate.Id);
            }
            for(RatingWrapper rw : ratingList) {
                String recipientEmail = rw.Recipient_Email.toLowerCase();
                String respondantEmail = rw.Email.toLowerCase();
                System.debug('rw.Recipient_Email ###'+recipientEmail);
                System.debug('recepientMap.get(rw.Recipient_Email); ###'+recepientMap.get(recipientEmail));
                Bureau_Rating__c newRating = new Bureau_Rating__c();
                newRating.Rater_Type__c = rw.Category;
                newRating.Participant__c = recepientMap.get(recipientEmail);
                newRating.Respondent__c = respondantMap.get(respondantEmail);
                if(rw.Category == 'Self') {
                    selfRatingList.add(newRating);
                }
                else {
                    otherRatingList.add(newRating);
                }
            }
            if(selfRatingList.size()!=0) {
                oldCandidateMap = new Map<Id, Bureau_Candidate__c>([Select id,Number_of_Product_Assessment__c,Bureau_Job__c,
                                                           Number_of_participants__c,Number_of_Respondents__c from Bureau_Candidate__c where Bureau_Job__c = :bureauJobId]);
                //Database.Insert(selfRatingList,false);
                Database.SaveResult[] srList = Database.insert(selfRatingList, false);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug('Error Message: ' + err.getMessage());
                            if(!(err.getMessage().toUpperCase()).contains('DUPLICATE')){
                                throw new DMLException(err.getMessage());
                            }
                        }
                    }
                }
                selfRatingDone = true;
            }
            if(selfRatingDone && otherRatingList.size()!=0) {
                //Database.Insert(otherRatingList, false);
                Database.SaveResult[] srListOther = Database.insert(otherRatingList, false);
                for (Database.SaveResult sr1 : srListOther) {
                    if (!sr1.isSuccess()) {
                        for(Database.Error err1 : sr1.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug('Error Message: ' + err1.getMessage());
                            if(!(err1.getMessage().toUpperCase()).contains('DUPLICATE')){
                                throw new DMLException(err1.getMessage());
                            }
                        }
                    }
                }
            }
            //Added by Aashi
            List<Bureau_Candidate__c> candidateList = [Select id,Bureau_Job__c,Bureau_Job__r.Name,Number_of_Product_Assessment__c,
                                                           Number_of_participants__c,Number_of_Respondents__c from Bureau_Candidate__c where Bureau_Job__c = :bureauJobId];
            RollUpCandidateFields.updateRollupSummaryFieldsJobUpdate(candidateList,oldCandidateMap);
        }
        catch(Exception exp) {
            System.debug('Exp ###'+exp.getMessage());
            System.debug('Inside Catch Error Message: ' + exp.getMessage());
            throw new AuraHandledException(exp.getMessage()); 
        }
    }
}
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-13-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MasterProgressReportView {
    
    @AuraEnabled(cacheable=true)
    public static List<WRF_Client_Report_View__mdt> getCustomMetadataClientReportView() {
        return [SELECT Label,DeveloperName, Field_Name__c, Is_Selected__c,System_Used__c FROM WRF_Client_Report_View__mdt];
    }
    
    @AuraEnabled(cacheable=true)
    public static string getWRF(string jobId){
        system.debug('-->jobid in class<--'+jobid);
                //List<Work_Request__c> WRFList=  [SELECT Id, Candidate_Field_Configuration__c,Job__c,Job_Id_System_Used__c,Work_Request_Generated__c FROM Work_Request__c where Job__c=:jobId AND (Work_Request_Type__c = 'Client Submitted' OR  Work_Request_Type__c = 'Internal Submission') order by CreatedDate desc limit 1];
        		List<Work_Request__c> WRFList=  [SELECT Id, Candidate_Field_Configuration__c,Job__c,Job_Id_System_Used__c,Work_Request_Generated__c FROM Work_Request__c where Job_Id_System_Used__c = :jobId AND Is_Active__c = true order by CreatedDate desc limit 1];
                system.debug('-->WRFList<--'+WRFList);
                //return WRFList[0].Work_Request_Generated__c;
        if(!WRFList.isEmpty()){
            return WRFList[0].Id;
        }
        else{
            return null;
        }
        		
    }

    @AuraEnabled
    public static string getRecentCRF(id jobrecordId){
        Work_Request__c clientreportWRF = [SELECT id,Candidate_Field_Configuration__c,Job__c,Work_Request_Type__c from Work_Request__c where Job__c=:jobrecordId and Work_Request_Type__c=:'Client Report' ORDER By CreatedDate desc limit 1];
        string  clientreportconfigwrf = clientreportWRF.Candidate_Field_Configuration__c;
        system.debug('-->clientreportconfigwrf<--'+clientreportconfigwrf);
        return clientreportconfigwrf;
        }
    

    @AuraEnabled
    public static string sendEmailClientReport(string selectedfieldsvalue, id jobrecordId, string fieldconfiguration){
        try {
        //Create WR for Client Report
        List<Work_Request__c> requestsToInsert = new List<Work_Request__c>();
        List<Work_Request__c> requestsToupdate = new List<Work_Request__c>();
        Work_Request__c generatedRequest = [select id,Account__c,System_Used__c,Job__c,Job_Id_System_Used__c,Requestor_Name__c,Requestor_Email__c,WRF_Link__c,WRF_Client_Name__c,No_of_WR_submitted__c,No_of_Candidate_Requested__c,No_of_Participant_Requested__c,Candidate_Requested_Backend_Use__c,CreatedDate from Work_Request__c where Job__c=:jobrecordId ORDER By CreatedDate DESC limit 1];
           
            
            system.debug('--fieldconfiguration--'+fieldconfiguration);
            Work_Request__c submittedRequest = new Work_Request__c();
            //submittedRequest.RecordtypeId = System.label.Work_Request_Submitted_RecordType_ID; Change by Priyank for test class issue.
            submittedRequest.RecordtypeId = Schema.SObjectType.Work_Request__c.getRecordTypeInfosByName().get('Submitted').getRecordTypeId();
            submittedRequest.Work_Request_Type__c = 'Client Report';
            submittedRequest.System_Used__c = generatedRequest.System_Used__c;
            submittedRequest.Account__c = generatedRequest.Account__c;
            submittedRequest.WRF_Link__c = generatedRequest.WRF_Link__c;
            submittedRequest.Job__c = jobrecordId;
            submittedRequest.Requestor_Name__c = generatedRequest.Requestor_Name__c;
            submittedRequest.Requestor_Email__c = generatedRequest.Requestor_Email__c;
            submittedRequest.WRF_Client_Name__c = generatedRequest.WRF_Client_Name__c;
            //submittedRequest.Client_Report_View_Link__c = crvLinkgenerate;
            submittedRequest.Candidate_Field_Configuration__c = fieldconfiguration;
            
            // Add to the list
            requestsToInsert.add(submittedRequest);
            system.debug('--submittedRequest--'+submittedRequest);
            // Insert all the new records in a single DML operation
            if (!requestsToInsert.isEmpty()) {
                insert requestsToInsert;
            }

            //string urlendparameters = '&c__wrfId='+requestsToInsert[0].id+'&c__jobId='+jobrecordId+'&c__hideButton=true'+'&c__fromParent=true';
            /*CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
            Blob cryptoKey = EncodingUtil.base64Decode(setting.CRYPTO__c);
            blob encodedCipherText = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(requestsToInsert[0].id));
            string encodedwrfidId = EncodingUtil.base64Encode(encodedCipherText);*/

            // Fetch the encryption key from custom setting
                CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
                Blob cryptoKey = EncodingUtil.base64Decode(setting.CRYPTO__c);

                // Encrypt the record ID with AES256 and managed IV, then encode in Base64
                Blob encodedCipherText = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(requestsToInsert[0].Id));
                String encodedwrfidId = EncodingUtil.base64Encode(encodedCipherText);


                // Use encodedwrfidId for URL or storage
                System.debug('Encoded ID for URL: ' + encodedwrfidId);

            
            string urlendparameters = '&c__wrfId='+encodedwrfidId+'&c__hideButton=true'+'&c__fromParent=true';
            String crvLinkgenerate = System.label.WRFClientReportViewURL + urlendparameters;
            Work_Request__c submittedRequestupdate = new Work_Request__c();
            submittedRequest.Client_Report_View_Link__c = crvLinkgenerate;
            //submittedRequestupdate.id = requestsToInsert[0].id;
            requestsToupdate.add(submittedRequest);
            system.debug('--submittedRequest--'+submittedRequest);
            // Insert all the new records in a single DML operation
            if (!requestsToupdate.isEmpty()) {
                update requestsToupdate;
            }
            system.debug('--crvLinkgenerate--'+crvLinkgenerate);
            return crvLinkgenerate;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
}

    
    
    @AuraEnabled
    public static list<Bureau_Candidate__c> getCandidateDataDynamically(String soqlQueryList, String jobId, Integer offSetValue, String filterValue){
        try {
            List<Bureau_Candidate__c> candidateFields = new List<Bureau_Candidate__c>();
            
            if(String.isBlank(filterValue)){
                String soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Candidate__c WHERE Bureau_Job__c = :jobId ORDER BY Full_Name__c LIMIT 200 OFFSET: offSetValue';
                candidateFields = database.query(soqlQuery);
            } else {
                filterValue = '%'+filterValue+'%';
                String soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Candidate__c WHERE Bureau_Job__c = :jobId AND Full_Name__c like: filterValue ORDER BY Full_Name__c LIMIT 200 OFFSET: offSetValue';
                candidateFields = database.query(soqlQuery);
            }
            return candidateFields;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    //method to decrypt the recordid parameter
    @AuraEnabled
    public static String decodeurlparamater(String recordId){
        try {
            system.debug('--->Original recordId<---' + recordId);
            //recordId = recordId.replace(' ', '+');
            String recordidnospace = recordId;
    //String noSpacesString = recordidnospace.replaceAll('\\s', '');
    String noSpacesString = recordId.replace(' ', '+');
    System.debug('String with no spaces: ' + noSpacesString);

            // Use URL decoding for all encoded characters
           // noSpacesString = EncodingUtil.urlDecode(noSpacesString, 'UTF-8');
            system.debug('--->recordId after URL Decoding<---' + noSpacesString);

            // Fetch the encryption key
            CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
            Blob cryptoKey = EncodingUtil.base64Decode(setting.CRYPTO__c);

            // Decode the Base64 encrypted data
            Blob myBlob = EncodingUtil.base64Decode(noSpacesString);
            
            // Decrypt with AES256
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, myBlob);
            String decodedId = decryptedData.toString();

            system.debug('--->Decoded ID<---' + decodedId);
            return decodedId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled
    public static ExportWrapper getRatingsCount(String jobId, String soqlQueryRatingList, String soqlQueryList, String exportType){
        list<Bureau_Rating__c> ratingsList = new list<Bureau_Rating__c>();
        ExportWrapper wrapper = new ExportWrapper();
        CandidateAndRatingData wr = new CandidateAndRatingData();
        String queryJobId;
        Integer ratingCount;
        String message;
        ratingCount = [Select count() FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =: jobId];
        System.debug('ratingCount -> '+ratingCount);
        if(ratingCount == 0){
            ratingsList = null;
        }else if(ratingCount < 25000){
            if(exportType == 'Rating'){
                ratingsList = getRatingData(jobId, soqlQueryList);   
            }else{
                wr = getMasterViewData(soqlQueryRatingList, soqlQueryList, jobId);
                ratingsList = wr.ratingData;
                wrapper.candidateData = wr.candidateData;
            }
            System.debug('ratingsList --> '+ratingsList);
        }else{
            ratingsList = null;
            queryJobId = CustomerRequestController.createQueryJob(null, jobId, exportType);
        }
        wrapper.ratingCount = ratingCount;
        wrapper.ratingData = ratingsList;
        wrapper.queryJobId = queryJobId;
        System.debug('wrapper --> '+wrapper);
        return wrapper;
    }
    
    @AuraEnabled
    public static CandidateAndRatingData getMasterViewData(String soqlQueryRatingList, String soqlQueryList, String jobId){
        list<Bureau_Rating__c> ratingList = new list<Bureau_Rating__c>();
        List<Bureau_Candidate__c> candidateList = new List<Bureau_Candidate__c>();
        list<Id> candidateIdList = new list<Id>();
        CandidateAndRatingData wrapper = new CandidateAndRatingData();
        /*String soqlQueryRating = 'Select Id,Name,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,' +
                'Respondent__r.Name,Respondent__r.Full_Name__c, Respondent__r.Email__c, Rater_Type__c,'+
                'MFS_Status__c,Insights_Status__c, VADC_Status__c, TC_Status__c, Overall_Status__c, Rater_String__c, Reminder__c,Report_Ready__c, Report_Sent__c,'+ 
                'Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c,MFS_Report_Sent__c,TC_Report_Sent__c FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = \'' + jobId + '\' LIMIT 50000';
        */
        String soqlQueryRating = 'Select ' + soqlQueryRatingList + ' FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = \'' + jobId + '\' LIMIT 50000';
        ratingList = database.query(soqlQueryRating);
        
        for(Bureau_Rating__c r : ratingList){
            candidateIdList.add(r.Respondent__c);
        }
        
        String soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Candidate__c WHERE Id IN :candidateIdList';
        candidateList = database.query(soqlQuery);
        wrapper.ratingData = ratingList;
        wrapper.candidateData = candidateList;
        return wrapper;
    }
    
     
    @AuraEnabled(cacheable=true)
    public static string getRatingDataForReport(String jobId) {
        system.debug('jobidstartswwith'+jobId.startsWith('a00'));
        if(jobId.startsWith('a00')){
            system.debug('--->jobid<--'+jobId);
            list<Job__c> jobRecord = [Select Id, Status_Calculations__c FROM Job__c WHERE Id =: jobId];
            return jobRecord[0].Status_Calculations__c;
        }
        else{
            system.debug('--->WRFid<--'+jobId);
            List<Work_Request__c> Jobrecordid =[Select Job__c from Work_Request__c where id=:jobId];
            list<Job__c> jobRecord = [Select Id, Status_Calculations__c FROM Job__c WHERE Id =: Jobrecordid[0].Job__c];
            return jobRecord[0].Status_Calculations__c;
        }
    }

    @AuraEnabled(cacheable=true)
    public static integer getRatingDataForReporttotalrecords(String jobId) {
        system.debug('jobidstartswwith'+jobId.startsWith('a00'));
        if(jobId.startsWith('a00')){
            system.debug('--->jobid<--'+jobId);
        return [Select Count() from Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =: jobId];
        }
        else{
            system.debug('--->WRFid<--'+jobId);
            List<Work_Request__c> Jobrecordid =[Select Job__c from Work_Request__c where id=:jobId];
            return [Select Count() FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =: Jobrecordid[0].Job__c];
        }
    }
    
    public static list<Bureau_Rating__c> getRatingData(String jobId, String soqlQueryList){
        try {
            list<Bureau_Rating__c> ratingList = new list<Bureau_Rating__c>();
            String soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = \'' + jobId + '\' LIMIT 50000';
			ratingList = database.query(soqlQuery);
            if(ratingList.size() > 0){
                return ratingList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return new list<Bureau_Rating__c>();
    }
    
    public class CandidateAndRatingData{
        @AuraEnabled public list<Bureau_Rating__c> ratingData;
        @AuraEnabled public List<Bureau_Candidate__c> candidateData;
    }
    
    public class ExportWrapper {
        @AuraEnabled
        public List<Bureau_Candidate__c> candidateData {get; set;}
        @AuraEnabled
        public Integer candidateCount {get; set;}
        @AuraEnabled
        public String queryJobId {get; set;}
        @AuraEnabled
        public List<Bureau_Rating__c> ratingData {get; set;}
        @AuraEnabled
        public Integer ratingCount {get; set;}
    }
}
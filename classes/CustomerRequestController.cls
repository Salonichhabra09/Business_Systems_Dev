/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class CustomerRequestController {
    
    public static final String TOKEN_ENDPOINT = URL.getOrgDomainURL().toExternalForm() + '/services/oauth2/token';
   /* @AuraEnabled
    public static string createCustomerRequest(String formDetails,String oppId){
        try {
            
            Work_Request__c req = new Work_Request__c();
            req.Field_Configuration__c = formDetails;
            req.Opportunity__c = oppId;
            
            insert req;
            
            return 'https://shl--findev.sandbox.my.site.com/CRF/s/?recordId=' + req.Id;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } */
    
  /*  @AuraEnabled(cacheable=true)
    public static OppAndJobWrapper getOppAndJobDetails(Id recordId){
        try{
            OppAndJobWrapper wrapper = new OppAndJobWrapper();
            list<Work_Request__c> customerRequestList = [SELECT Id, Opportunity__c FROM Work_Request__c WHERE Id = :recordId];
            list<Job__c> jobList = [SELECT Id FROM Job__c WHERE Opportunity__c = :customerRequestList[0].Opportunity__c];
            wrapper.jobData = jobList[0];
            return wrapper;
            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } */
    
    @AuraEnabled(cacheable=true)
    public static string getCustomerRequest(Id recordId){
        try {
            
            List<Work_Request__c> req = [SELECT Id,Field_Configuration__c FROM Work_Request__c WHERE Id = :recordId];
            
            if(!req.isEmpty()){
                return req[0].Field_Configuration__c;
            }else{
                return '';
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
   /* @AuraEnabled
    public static void createGCSCOpp(String formDetails,String recordId, List<CandidateDetails> candidateDetails ){
        try {
            
            system.debug(candidateDetails);
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(formDetails);
            system.debug(m.get('productNumber'));
            List<Work_Request__c> req = [SELECT Id,Opportunity__c,Opportunity__r.AccountId,Name FROM Work_Request__c WHERE Id = :recordId];
            
            List<Contact> con = [SELECT Id FROM Contact WHERE AccountId =:req[0].Opportunity__r.AccountId LIMIT 1];
            
            Account acc = [SELECT Id, OwnerId, Owner.Name FROM Account WHERE Id =:req[0].Opportunity__r.AccountId];
            
            Opportunity opportunity =  new Opportunity();
            opportunity.AccountId = req[0].Opportunity__r.AccountId;
            opportunity.Name = 'Test';
            opportunity.Billing_Contact__c=con[0].Id;
            opportunity.Closedate=system.today();
            opportunity.Primary_Contact__c=con[0].Id;
            opportunity.Variation_Opportunity__c='NO';
            opportunity.StageName='New';   
            opportunity.Business_Type__c = 'Cross-sell: subscription';
            opportunity.Forecast_Category__c = 'Pipeline';
            opportunity.RecordTypeId = '012D0000000V7opIAC';
            opportunity.Original_Opportunity__c = req[0].Opportunity__c;
            
            insert opportunity;
            
            Opportunity opp = [SELECT Id,OpportunityId__c FROM Opportunity WHERE Id =:opportunity.Id];
            
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toaddresses = new List<String>(); 
            mail.setTargetObjectId(acc.OwnerId);
            
            String oppLink = '<a href="'+ URL.getOrgDomainURL().toExternalForm()+'/'+opp.Id +'">'+opp.OpportunityId__c+'</a>';
            String crfLink = '<a href="'+ URL.getOrgDomainURL().toExternalForm()+'/'+req[0].Id +'">'+req[0].Name +'</a>';
            String subject = 'New GCSC Opportunity';
            mail.setSubject(subject);
            mail.setHtmlBody('Hello, <br/><br/>This is to inform that a new GCSC Opportunity '+oppLink +' has been created for the Customer Request ' + crfLink + '<br><br>Thank You  ');
            OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: 'noreply@shl.com' Limit 1];
            mail.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
            mailList.add(mail);
            mail.saveAsActivity = false;
            
            Messaging.SendEmailResult[] result= Messaging.sendEmail(mailList);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } */
    
   /* @AuraEnabled
    public static list<OpportunityLineItem> getOpportunityProducts(String opportunityId){
        list<OpportunityLineItem> opportunityProductList = new list<OpportunityLineItem>();
        system.debug(opportunityId);
        try{
            opportunityProductList = [SELECT Id,Name,Product_Name__c,Product2Id,Product2.Name,Package__c FROM OpportunityLineItem WHERE OpportunityId = :opportunityId];
            if(opportunityProductList.size() > 0){
                return opportunityProductList;
            }else{
                return new list<OpportunityLineItem>();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } */
    
   /* @AuraEnabled(cacheable=true)
    public static String getAccountLogo(String AccountId){
        Account a = [select Account_Logo__c from Account where id=:AccountId];
        System.debug(a.Account_Logo__c);
        return a.Account_Logo__c;
        
    }*/
    
    @AuraEnabled
    public static String createSubmitRequest(String formDetails,String recordId, String candidateDetails, 
                                             Integer candidateRequestedCount,String RequestorName,
                                             String RequestorEmail, String candidateDataToInsert, 
                                             String candidateRequestType, Integer participantRequestedCount, 
                                             Date deadlineDate){
        try {
            System.debug('Form Details '+formDetails);
            System.debug('Record ID '+recordId);
            Work_Request__c generatedRequest = [select id,Account__c,System_Used__c,Job_Id_System_Used__c,WRF_Link__c,WRF_Client_Name__c,No_of_WR_submitted__c,No_of_Candidate_Requested__c,No_of_Participant_Requested__c,Candidate_Requested_Backend_Use__c from Work_Request__c where id=:recordId limit 1];
            Work_Request__c submittedRequest = new Work_Request__c();
           Job__c relatedJob = [select id,System_Used__c,Project_Manager__c,Sender_Email__c,Billing_Cycle_End_Date__c,opportunity__c,Project_Manager__r.email,Account__r.Is_Repeatable_Business__c,Client_Domain__c,Billing_Frequency__c,recordtypeid,Is_GCSC_Opp__c from job__c where id=:generatedRequest.Job_Id_System_Used__c limit 1];
            List<User> internalsubmitter =[select id, email from user where email =: RequestorEmail];
            if(internalsubmitter.size()>0)
            {
                submittedRequest.OwnerID = internalsubmitter[0].id;
            }
            submittedRequest.Status__c = 'Open';
            submittedRequest.Field_Configuration__c = formDetails;
            submittedRequest.Work_Request_Generated__c = recordId;
            submittedRequest.RecordtypeId = Schema.SObjectType.Work_Request__c.getRecordTypeInfosByName().get('Submitted').getRecordTypeId();
            if(RequestorEmail.contains('shl.com')){
                submittedRequest.Work_Request_Type__c = 'Internal Submission';
            }
            else{
                submittedRequest.Work_Request_Type__c = 'Client Submitted';
            }
            submittedRequest.Link_Generated_Date__c = Date.Today();
            submittedRequest.System_Used__c = generatedRequest.System_Used__c;
            submittedRequest.Account__c = generatedRequest.Account__c;
            submittedRequest.WRF_Link__c = generatedRequest.WRF_Link__c;
           if(relatedJob.Is_GCSC_Opp__c==false || (relatedJob.Is_GCSC_Opp__c==true && relatedJob.Account__r.Is_Repeatable_Business__c==false)
           ||(relatedJob.Is_GCSC_Opp__c==true && relatedJob.Account__r.Is_Repeatable_Business__c==true && Date.Today()<=relatedJob.Billing_Cycle_End_Date__c)){
                    submittedRequest.Job__c = generatedRequest.Job_Id_System_Used__c;
            }
            submittedRequest.Requestor_Name__c = RequestorName;
            submittedRequest.Requestor_Email__c = RequestorEmail;
            submittedRequest.Candidate_Field_Configuration__c = candidateDetails;
            submittedRequest.No_of_Candidate_Requested__c = candidateRequestedCount;
            submittedRequest.No_of_Participant_Requested__c  = participantRequestedCount;
            submittedRequest.Candidate_Requested_Backend_Use__c = candidateRequestedCount;
            submittedRequest.WRF_Client_Name__c = generatedRequest.WRF_Client_Name__c;
            submittedRequest.Candidate_Request_Type_Backend_Use__c = candidateRequestType;
            submittedRequest.Deadline_Date__c = deadlineDate;
            insert submittedRequest;
            generatedRequest.No_of_WR_submitted__c = (generatedRequest.No_of_WR_submitted__c==null?0:(generatedRequest.No_of_WR_submitted__c + 1));
            generatedRequest.No_of_Candidate_Requested__c = (generatedRequest.No_of_Candidate_Requested__c==null?0:generatedRequest.No_of_Candidate_Requested__c)+candidateRequestedCount;
            generatedRequest.No_of_Participant_Requested__c = (generatedRequest.No_of_Participant_Requested__c==null?0:generatedRequest.No_of_Participant_Requested__c)+participantRequestedCount;
            generatedRequest.Candidate_Requested_Backend_Use__c = (generatedRequest.Candidate_Requested_Backend_Use__c==null?0:generatedRequest.Candidate_Requested_Backend_Use__c)+candidateRequestedCount;
            update generatedRequest;
            System.debug('Related Job '+relatedJob);
           if(Date.Today()>relatedJob.Billing_Cycle_End_Date__c && relatedJob.Account__r.Is_Repeatable_Business__c && relatedJob.Is_GCSC_Opp__c==true){
                Opportunity existingOpp = [select id,Name,stagename,accountid,primary_contact__c,billing_contact__c,Business_Type__c,Previous_Record_Type__c,GCSC__c,Unconfirmed_Sun_Order_Number__c,NoOfProducts__c,currencyisocode from opportunity where id=:relatedjob.opportunity__c];
                String existingOppId = existingOpp.Id;
                Opportunity newOpp = new Opportunity();
                //newOpp = existingOpp.clone(false,true,false,false);
                //newOpp.Id=null;
                newOpp.name='testing';
                newOpp.stageName = 'New';
                newOpp.recordtypeId = System.label.GCSCRecordType;
                newOpp.Previous_Record_Type__c = System.label.GCSCRecordType;
                newOpp.Original_Opportunity__c = existingOppId;
                newOpp.CloseDate = Date.Today();
                newOpp.AccountId=existingOpp.accountid;
                newOpp.primary_contact__c = existingOpp.primary_contact__c;
                newOpp.billing_contact__c = existingOpp.billing_contact__c;
                newOpp.Business_Type__c = existingOpp.Business_Type__c;
                newOpp.GCSC__c = existingOpp.GCSC__c;
                newOpp.Unconfirmed_Sun_Order_Number__c = existingOpp.Unconfirmed_Sun_Order_Number__c;
                newOpp.currencyisocode = existingOpp.currencyisocode;
                insert newOpp;
                System.debug('New Opp id '+newOpp.Id);
                System.debug('existingOpp id '+existingOppId);
                furtherSubmittionProcess(relatedJob.Id,submittedRequest.Id,newOpp.Id,generatedRequest.Id);
            }
            CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
            Blob cryptoKey = EncodingUtil.base64Decode(setting.CRYPTO__c);
            blob encodedCipherText = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(submittedRequest.Id));
            string encodedsubmittedId = EncodingUtil.base64Encode(encodedCipherText);
            
            submittedRequest.Client_Submitted_WRF_Preview__c = System.label.WRFLinkURL + encodedsubmittedId;
            update submittedRequest;
            Work_Request__c newReq = [SELECT Id , Name,job__c,job__r.Project_Manager__r.email,Job__r.Name,System_Used__c,Work_Request_Generated__c FROM Work_Request__c WHERE Id =:submittedRequest.Id];
            try{
                if(candidateDataToInsert != null){
                    createManualCandidates(candidateDataToInsert,newReq);
                    //list<Bureau_Candidate__c> candidatesCreatedList = createManualCandidates(candidateDataToInsert,newReq.Id);
                    //createManualRatings(candidatesCreatedList, newReq);
                }
            }catch(Exception ex){
                System.debug('StackTraceString' + ex.getStackTraceString());
                System.debug('Exception in createSubmitRequest '+ex.getMessage());
                throw new DMlException(ex.getMessage());
            }
            // Insert Manual Candidates
            
            if(newReq.Job__r.Name!=null){
                sendEmail(relatedJob,newReq);
            }
            return newReq.Name;
            
        } catch (Exception e) {
            System.debug('StackTraceString' + e.getStackTraceString());
            //return 'error '+ e.getMessage();
            throw new DMlException(e.getMessage());
        }
    } 
    
    @AuraEnabled
    public static string createCustomerRequestFromCustomForm(String formDetails,String accountId, String candidateDetails, String systemSelected,String jobId, String textUnderLogo, String wrfClientName,String Solution, String candidateInstruction){
        try {
            System.debug('formDetails '+ formDetails);
            System.debug('accountId '+ accountId);
            System.debug('candidateDetails '+ candidateDetails);
            System.debug('systemSelected' +systemSelected);
            System.debug('Solution '+solution);
            CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
            Blob cryptoKey = EncodingUtil.base64Decode(setting.CRYPTO__c);
            system.debug('--->keyvalueencode<---'+cryptoKey);
            //Blob cryptoKey = setting.CRYPTO__c;
            //String AccountId = [select id,Account__c from job__c where id=:jobId].Account__c;
            Work_Request__c req = new Work_Request__c();
            if(formDetails !='' && formDetails != null){
                req.Field_Configuration__c = formDetails; 
                req.System_Used__c = systemSelected;
                req.Account__c = accountId;
                req.RecordTypeId = Schema.SObjectType.Work_Request__c.getRecordTypeInfosByName().get('Generated').getRecordTypeId();
                req.Work_Request_Type__c = 'MS Generated';
                req.Link_Generated_Date__c = Date.Today();
                req.Job_Id_System_Used__c = jobId;
                req.Text_Under_Logo__c =textUnderLogo;
                req.WRF_Client_Name__c = wrfClientName;
                req.Candidate_Template_Instructions__c = candidateInstruction;
            if(candidateDetails !='' && candidateDetails != null)
                req.Candidate_Field_Configuration__c = candidateDetails;
            }
            insert req;
            blob encodedCipherText = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(req.Id));
            string encodedId = EncodingUtil.base64Encode(encodedCipherText);
            req.WRF_Link__c = System.label.WRFLinkURL + encodedId;
            update req;
            //return 'https://shl--findev.sandbox.my.site.com/CRF/s/?recordId=' + req.Id;
            //return System.label.WRFLinkURL + req.Id;
            if(solution!=null){
                Id opportunityid = [select opportunity__c from job__C where id=:jobId].opportunity__c;
                AggregateResult result= [select max(Solution_Cap__c) from OpportunityLineItem where opportunityid=:opportunityid and package__c=:Solution group by package__c];
                Job__c linkedjob = new Job__c();
                linkedjob.Id = jobId;
                linkedjob.Solution_Cap__c = (Decimal)result.get('expr0');
                linkedjob.offering_details__c = Solution;
                update linkedjob;
            }
           return System.label.WRFLinkURL + encodedId;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //method to decrypt the recordid parameter
    @AuraEnabled(cacheable=true)
    public static string connectedCallbackApex(string recordId){
        try {
            system.debug('--->recordIdencoded<---'+recordId);
            if(recordId.contains('%20')){
                recordId = recordId.replace('%20', '+');
            }
            if(recordId.contains('%2F')){
                recordId = recordId.replace('%2F', '/');
            }
            system.debug('--->recordIdencodedafter<---'+recordId);
            //recordId = EncodingUtil.urlDecode(recordId, 'UTF-8');
            CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
            Blob cryptoKey = EncodingUtil.base64Decode(setting.CRYPTO__c);
            Blob myBlob = EncodingUtil.base64Decode(recordId);
            blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, myBlob);
            string decodedId = decryptedData.toString();
            system.debug('--->decodedId<---'+decodedId);
            return decodedId;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 

    
     @AuraEnabled
     public static String authenticateContact(String Submittername,String Submitteremail,String recordId){
        Boolean found = false;
        Work_Request__c customerRequestList = [SELECT Id, Job_Id_System_Used__c  FROM Work_Request__c WHERE Id = :recordId];
        list<Job__c> jobList = [SELECT Id, Client_Domain__c, Opportunity__r.Primary_Contact__r.email FROM Job__c WHERE id = :customerRequestList.Job_Id_System_Used__c];
        String contactemail = jobList[0].Opportunity__r.Primary_Contact__r.email ;
        String Domains = jobList[0].Client_Domain__c;
        String submitname = Submittername.trim();
        String submitemail = Submitteremail.trim();
        String emailbefore = null;

        if(submitemail !=''){
            emailbefore = submitemail.substringBefore('@');
        }
        
        system.debug('--->emailbefore<--'+emailbefore);
        List<String> domainlist = new List<String>();
        if(Domains!=null && Domains.contains(',')){ 
            system.debug('--->contains multiple domains<--');           
        domainlist = new List<String>(Domains.split(','));
        }
        else if(Domains !=null){
            system.debug('--->contains single domains<--');  
            domainlist.add(Domains);
        }
        for (Integer i = 0; i < domainlist.size(); i++) {
            domainlist[i] = domainlist[i].replaceFirst('^\\s+', '');
            domainlist[i] = domainlist[i].toLowerCase();
        }
        String billingcontactdomain = contactemail.split('@',2)[1];
        if(domainlist.size()>0 && submitemail != '' && submitemail.contains('@') && emailbefore !=''){
            system.debug('--email not null<--');
            found = domainlist.contains(submitemail.split('@',2)[1].toLowerCase());
        }

        if(submitemail !='' && submitname !='' && emailbefore !='' )
        {
            system.debug('--email and name both not null<--');
            if(found == true)
            {
                return 'Success';
            }
            else if(found == false && submitemail.contains('@'))
            {
                    found = billingcontactdomain.contains(submitemail.split('@',2)[1]);
                    if(found == true)
                    {
                        return 'Success';
                    }
                    return 'NotFound';
            }
            return 'BlankValues';
        }
        else
            return 'BlankValues';
    }
    
    @AuraEnabled
    public static Work_Request__c getRecentCRF(String accountId,string systemused){
        System.debug('CRF '+accountId);
        System.debug('accountId345 ' + systemused);
        Map<String,String> returnValues = new Map<String,String>();
         List<Work_Request__c> crfToUse = new List<Work_Request__c>(); 
         crfToUse = [select Id,Field_Configuration__c,Text_Under_Logo__c,WRF_Client_Name__c from Work_Request__c where Account__c=:accountId and System_Used__c=:systemused AND Work_Request_Type__c = 'MS Generated' order by createddate desc limit 1]; 
        if(crfToUse.size()!=0){
           // returnValues.put('Field_Configuration',crfToUse[0].Field_Configuration__c);
           // returnValues.put('Text_Under_Logo',crfToUse[0].Text_Under_Logo__c);
           // returnValues.put('Client_Name',crfToUse[0].WRF_Client_Name__c);
           // return returnValues;
           return crfToUse[0];
        }
        else{
            crfToUse = [select Id,Field_Configuration__c,Text_Under_Logo__c,WRF_Client_Name__c from Work_Request__c where Name='WR-0000' order by createddate desc limit 1];
            //returnValues.put('Field_Configuration',crfToUse[0].Field_Configuration__c);
            //returnValues.put('Text_Under_Logo',crfToUse[0].Text_Under_Logo__c);
            //returnValues.put('Client_Name',crfToUse[0].WRF_Client_Name__c);
            //return returnValues;
            return crfToUse[0];
        }
    }
    
    @AuraEnabled
    public static Work_Request__c getRecentCRFCandidate(String accountId,string systemused){
        List<Work_Request__c> crfToUse = new List<Work_Request__c>(); 
        crfToUse = [select Id,Candidate_Field_Configuration__c,Candidate_Template_Instructions__c from Work_Request__c where Account__c=:accountId AND System_Used__c=:systemused AND Work_Request_Type__c = 'MS Generated' order by createddate desc limit 1];
        if(crfToUse.size()!=0){
            return crfToUse[0];
        }
        else{
            crfToUse = [select Id,Field_Configuration__c,Candidate_Field_Configuration__c,Candidate_Template_Instructions__c from Work_Request__c where Name='WR-0000' order by createddate desc limit 1];
            return crfToUse[0];
        }
    }
    
    @AuraEnabled
    public static void createFormAttribute(String jsonData){
        list<DataWrapper> convertedData = (list<DataWrapper>)JSON.deserialize(jsonData,list<DataWrapper>.Class); 
        list<Form_Attribute__c> recordsToInsert = new list<Form_Attribute__c>();
        for(DataWrapper wrapper : convertedData){
            Form_Attribute__c fa = new Form_Attribute__c();
            
            if(wrapper.fieldtype == 'dropdown'){
                fa.Data_Type__c = 'DropDown';
            }else{
                fa.Data_Type__c = wrapper.fieldtype.toLowerCase();
            }
            
            fa.Label__c = wrapper.fieldLabel;
            fa.Values__c = wrapper.Values;
            fa.Category__c = 'Candidate Import Template';
            fa.Field_Status__c = 'Requested';
            fa.Object__c = 'Bureau_Candidate__c';
            //String tempVar = wrapper.fieldLabel.replaceAll(' ', '_');  
            String label = wrapper.fieldLabel;
           
            // Step 1: Replace hyphens and dots with underscore
            String apiName = label.replaceAll('[-.]', '_');
            
            // Step 2: Remove all other special characters except underscore and space
            apiName = apiName.replaceAll('[^a-zA-Z0-9_ ]', '');
            
            // Step 3: Replace spaces with underscore
            apiName = apiName.replaceAll('\\s+', '_');
            
            // Step 4: Remove consecutive underscores (optional cleanup)
            apiName = apiName.replaceAll('_+', '_');
            
            // Step 5: Trim leading/trailing underscores
            apiName = apiName.replaceAll('^_+|_+$', '');
            
            // Step 6: Ensure the name starts with a letter
            if (!Pattern.matches('^[a-zA-Z].*', apiName)) {
                apiName = 'F' + apiName;
            }
            
            // Step 7: Truncate to 40 characters max
            if (apiName.length() > 40) {
                apiName = apiName.substring(0, 40);
            }
            
            // Step 8: Append Salesforce custom field suffix
            fa.API_Name__c = apiName + '__c';
            recordsToInsert.add(fa);
        }
        
        if(recordsToInsert.size() > 0){
            INSERT recordsToInsert;
        }
       try {
            FieldCreationScheduler scheduleJob = new FieldCreationScheduler(jsonData);
            Datetime scheduledDate =Datetime.now().addMinutes(1);
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
        //FieldCreationController.fieldDataList(jsonData);
    } 
    
    public class DataWrapper{
        public String fieldLabel;
        public String fieldtype;
        public String Values;
    }
    
    public class CandidateDetails{
        
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
    }
    
    public class OppAndJobWrapper{
        @AuraEnabled public Opportunity oppData;
        @AuraEnabled public Job__c jobData;
    }
    
    @AuraEnabled
public static String relatedFiles(Id evaluatorId){
    String logoId = [select Company_Logo_Id__c from account where id=:evaluatorId].Company_Logo_Id__c;
    List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.VersionData
                FROM ContentDocumentLink
                WHERE contentDocumentId = :logoId
                LIMIT 1];
    System.debug('DATA FROM CD '+contentDocumentLinks);

    String base64Data;
    if(!contentDocumentLinks.isEmpty()) {
        ContentDocumentLink cdl = contentDocumentLinks[0];
        base64Data = 'data:image/' + cdl.ContentDocument.FileExtension + ';charset=utf-8;base64, ';
        base64Data += EncodingUtil.base64Encode(cdl.ContentDocument.LatestPublishedVersion.VersionData);
    } 
    return base64Data;
}
    
    @AuraEnabled(cacheable=true)
public static String relatedFilesWire(String evaluatorId){
    String logoId;
    List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
    if(evaluatorId.startswith('001')){
     logoId = [select Company_Logo_Id__c from account where id=:evaluatorId].Company_Logo_Id__c;   
    }
    else if(evaluatorId.startswith('a00')){
     logoId = [select BannerImage__c from job__c where id=:evaluatorId].BannerImage__c;   
    }
    if(logoId!=null){
    contentDocumentLinks = [SELECT ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.VersionData
                FROM ContentDocumentLink
                WHERE contentDocumentId = :logoId
                LIMIT 1];
    System.debug('DATA FROM CD '+contentDocumentLinks);
    }
    String base64Data;
    if(!contentDocumentLinks.isEmpty()) {
        ContentDocumentLink cdl = contentDocumentLinks[0];
        base64Data = 'data:image/' + cdl.ContentDocument.FileExtension + ';charset=utf-8;base64, ';
        base64Data += EncodingUtil.base64Encode(cdl.ContentDocument.LatestPublishedVersion.VersionData);
        return base64Data;
    }
    else{
        return null;
    }
}
    @AuraEnabled(cacheable=true)
    public static List<Form_Attribute__c> getFormFields(String startExecution){
        return [Select name,label__c,Data_Type__c,Values__c,Category__c,API_Name__c,Field_Status__c,Object__c,Reportable__c from Form_Attribute__c order by label__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static String getAccountId(String WRFId){
        System.debug('Record ID '+WRFId);
        return [select Account__c from Work_Request__c where id=:WRFId].Account__c;
    }
    
    @AuraEnabled
    public static String uploadFile(String fileName,Id recordId) {
        // Decoding the base64Data
       /* base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = recordId;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv; */
        String contentdocumentId = [select contentdocumentId from contentversion where id=:fileName].contentdocumentId;
        Account ac = new Account();
        ac.Id = recordId;
        ac.Company_Logo_Id__c = contentdocumentId;
        Update ac;
        
        return 'File upload successfully!';
    }
    
    @Auraenabled
   public static list<Bureau_System__c> handleCandidateComponentVisibility(String jobId){
       List<Bureau_System__c> systemDetailsList;
       if(String.isNotBlank(jobId)){
        systemDetailsList=[Select Id from Bureau_System__c where Bureau_Job__c =: jobId];
       }   
       
       return systemDetailsList;
   }
    @AuraEnabled
    public static WRFAndJobData getWRFAndJobData(String recordId){
        WRFAndJobData wrapper = new WRFAndJobData();
        
        if(recordId != null){
            Work_Request__c submittedRequest = [SELECT Id,Account__c,System_Used__c,Job__c,WRF_Link__c,WRF_Client_Name__c,Work_Request_Generated__c FROM Work_Request__c WHERE Id = :recordId limit 1];
            Job__c relatedJob = [SELECT Id, Name, MS_Line_of_Business__c, Job_Region__c, System_Used__c FROM Job__c WHERE Id = :submittedRequest.Job__c limit 1];
            list<ContentDocumentLink> contentDocumentLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId,
                                                                 ContentDocument.FileExtension, ContentDocument.FileType, ContentDocument.Title, ContentDocument.LatestPublishedVersionId
                                                                 FROM ContentDocumentLink 
                                                                 WHERE LinkedEntityId = :submittedRequest.Id AND ContentDocument.FileExtension = 'csv' order by ContentDocument.CreatedDate DESC LIMIT 1];
            
            List<Bureau_System__c> systemDetailsList = [Select Id from Bureau_System__c WHERE Bureau_Job__c =: relatedJob.Id];
            
            wrapper.workRequestData = submittedRequest;
            wrapper.jobData = relatedJob;
            if(!contentDocumentLinkList.isEmpty()){
                wrapper.contentDocumentLink = contentDocumentLinkList[0];    
            }
            wrapper.linkedSystem = systemDetailsList;
        }
        return wrapper;
    }
    
    public class WRFAndJobData{
        @AuraEnabled public Work_Request__c workRequestData;
        @AuraEnabled public Job__c jobData;
        @AuraEnabled public ContentDocumentLink contentDocumentLink;
        @AuraEnabled public List<Bureau_System__c> linkedSystem;
    }
    
    public static void createManualCandidates(String candidateDataToInsert,Work_Request__c newReq){
        try{
            List<Bureau_Candidate__c> candidatesCreatedList = new List<Bureau_Candidate__c>();
            //Work_Request__c newReq = [SELECT Id , Name,job__c,job__r.Project_Manager__r.email,Job__r.Name FROM Work_Request__c WHERE Id =:newReqId];
            list<Bureau_Candidate__c> canidateInsertionList = new list<Bureau_Candidate__c>();
            // Parse the JSON string into a List of Maps
            List<Bureau_Candidate__c> jsonData = (List<Bureau_Candidate__c>) JSON.deserialize(candidateDataToInsert, List<Bureau_Candidate__c>.class);
            
            for (Bureau_Candidate__c item : jsonData) {
                Bureau_Candidate__c can = new Bureau_Candidate__c();
                can = item;
                can.Work_Request__c = newReq.Id;
                canidateInsertionList.add(can);
            }
            createCandidateAndRatingRecordsManually(canidateInsertionList, newReq);
            /*
            // Serialize the modified list back to JSON string
            String updatedJsonString = JSON.serialize(canidateInsertionList);
            try {
                candidatesCreatedList = createCandidates(updatedJsonString, newReq.Id, null, false);
                return candidatesCreatedList;
            } catch (DMLException dmlEx) {
                System.debug('DMLException during candidate creation: ' + dmlEx.getMessage());
                // Handle the DMLException or rethrow if needed
                throw new DMLException('Error during candidate creation: ' + dmlEx.getMessage());
            }*/
        } catch(Exception e) {
            System.debug('Exception in createManualCandidates: ' + e.getMessage());
            throw new DMLException(e.getMessage());
                //'An error occurred while creating manual candidates.');
        }
    } 

    
    public static void createCandidateAndRatingRecordsManually(List<Bureau_Candidate__c> candidateListToInsert, Work_Request__c newReq){
        try {
            //List<Bureau_Candidate__c> candidateListToInsert = new List<Bureau_Candidate__c>();
            Map<Id, Bureau_Candidate__c> candidateToInsertMap;
            Map<Id, Bureau_Candidate__c> newMap;
            /*for(Bureau_Candidate__c candidate : candidateList) {
                candidate.Candidate_Unique_Id__c = candidate.Bureau_Job__c + candidate.First_Name__c + candidate.Last_Name__c + candidate.Email__c;
                candidate.Work_Request__c = newReq.Id;
                candidateListToInsert.add(candidate);
            }*/
            insert candidateListToInsert;
            candidateToInsertMap = new Map<Id, Bureau_Candidate__c>(candidateListToInsert);
            //createManualRatings(candidateListToInsert, newReq);
            List<Bureau_Candidate__c> insertedCandList=[Select id,Number_of_Product_Assessment__c,Bureau_Job__c,Work_Request__c,Number_of_participants__c,
                                                             Number_of_Respondents__c from Bureau_Candidate__c where Id IN: candidateToInsertMap.keySet()];
            newMap = new Map<Id, Bureau_Candidate__c>(insertedCandList);
            RollUpCandidateFields.calculateCountFieldsWrf(candidateToInsertMap);
            //RollUpCandidateFields.updateRollupSummaryFieldsOnWRF(candidateListToInsert);
        } catch (Exception e) {
            System.debug('Exception in createCandidateAndRatingRecordsManually '+e.getMessage());
            throw new DMLException(e.getMessage());
        }
    }
    /* Call to create candidates when candidate count in file is less than 1000 */
    @AuraEnabled
    public static List<Bureau_Candidate__c> createCandidates(String candidatesJSON, Id wrfId, Id jobId, Boolean isUpdate) {
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
                    List<Bureau_Candidate__c> insertedCandList=[Select id,Number_of_Product_Assessment__c,Bureau_Job__c,Work_Request__c,Number_of_participants__c,
                                                             Number_of_Respondents__c from Bureau_Candidate__c where id in: insertedCandIds];
                    Map<Id, Bureau_Candidate__c> candidateMap = new Map<Id, Bureau_Candidate__c>(insertedCandList);
                    RollUpCandidateFields.calculateCountFieldsWrf(candidateMap);
                    RollUpCandidateFields.updateRollupSummaryFieldsOnWRF(insertedCandList);
                    RollUpCandidateFields.calculateCountFields(candidateMap);
                    
                    return lstCCToInsert;
                }
            }
        }catch(Exception e){
            System.debug('Inside Catch Error Message: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }
        return new List<Bureau_Candidate__c>();
    }
    
    public static void createManualRatings(List<Bureau_Candidate__c> candidateDataToInsert, Work_Request__c wrfRequest, Date deadline){
        try{
            list<Bureau_Rating__c> ratingInsertionList = new list<Bureau_Rating__c>();
            for (Bureau_Candidate__c item : candidateDataToInsert) {
                Bureau_Rating__c newRating = new Bureau_Rating__c();
                newRating.Rater_Type__c = 'Self';
                newRating.Participant__c = item.Id;
                newRating.Respondent__c = item.Id;
                newRating.TC_Status__c ='Not Started';
                newRating.TC_Report_Sent__c ='Not Sent';
                newRating.Reminder_1__c = 'Eligible';
                newRating.Work_Request__c = wrfRequest.Id;
                newRating.rating_transfer_status__c = 'Not Transferred';
                newRating.Deadline__c = deadline;
                ratingInsertionList.add(newRating);
            }
            
            if(!ratingInsertionList.isEmpty()){
                try {
                    INSERT ratingInsertionList;
                    List<Bureau_Rating__c> ratingsInserted = [SELECT Id, Rater_String__c, Reminder_1__c, Report_Ready__c,
                   Participant_Name__c, Respondent_Name__c, Rater_Type__c, MFS_Status__c,
                   Participant__r.Bureau_Job__c, Participant__r.Email__c, Respondent__r.Email__c, Rating_Transfer_Status__c
                   FROM Bureau_Rating__c WHERE Work_Request__c = :wrfRequest.Id];
                    //Calculate Respondent Count on Candidates
            		RollUpCandidateFields.calculateRespondentCountOnCandidate(ratingsInserted);
                    //Calculate Not Transferred Rating Count and Candidate Transfer Status on Job
                    RollUpCandidateFields.updateTransferCountonJobOnNewWorkRequest(ratingsInserted);  
                }catch(DmlException dmlEx){
                    System.debug('Error inserting ratings: ' + dmlEx.getMessage());
                    throw new DmlException(dmlEx.getMessage());
                }
            }
        } catch (Exception ex) {
            // General exception handling
            System.debug('Unexpected error: ' + ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static void createRatings(String ratingJSON, String bureauJobId, String wrfId, Boolean isUpdate, Date deadline) {
        System.debug('ratingJSON ####'+ratingJSON);
        System.debug('bureauJobId ####'+bureauJobId);
        System.debug('bureauJobId ####'+wrfId);
        Boolean selfRatingDone = false;
        List<Bureau_Rating__c> selfRatingList = new List<Bureau_Rating__c>();
        List<Bureau_Rating__c> otherRatingList = new List<Bureau_Rating__c>();
        Set<String> respondantEmailList = new Set<String>();
        Set<String> recepientEmailList = new Set<String>();
        Map<String, String> respondantMap = new Map<String, String>();
        Map<String, String> recepientMap = new Map<String, String>();
        Map<String, String> respondantEmailNameMap = new Map<String, String>();
        Map<String, String> participantEmailNameMap = new Map<String, String>();
        Map<String, String> respondantIdEmailMap = new Map<String, String>();
        Map<String, String> raterStringMap = new Map<String, String>();
        Map<Id, Bureau_Candidate__c> oldCandidateMap=new Map<Id, Bureau_Candidate__c>();
        List<RatingWrapper> ratingList = (List<RatingWrapper>) JSON.deserialize(ratingJSON, List<RatingWrapper>.class);
        try {
            for(RatingWrapper rw : ratingList) {
                respondantEmailList.add(rw.Email);
                recepientEmailList.add(rw.Recipient_Email);
            }
            System.debug('recepientEmailList ###'+recepientEmailList.size());
            List<Bureau_Candidate__c> respondantCandidate = [SELECT Id, Email__c, Full_Name__c FROM Bureau_Candidate__c
                                                             WHERE Email__c IN :respondantEmailList
                                                             AND Bureau_Job__c = :bureauJobId];
            List<Bureau_Candidate__c> recepientCandidate = [SELECT Id, Email__c, Full_Name__c 
                                                            FROM Bureau_Candidate__c
                                                            WHERE Email__c IN :recepientEmailList
                                                            AND Bureau_Job__c = :bureauJobId];
             List<work_request__c> WRFcategory = [SELECT id,System_Used__c from Work_Request__c where id= :wrfId ]; 
            System.debug('recepientCandidate ###'+recepientCandidate.size());
            System.debug('respondantCandidate ###'+respondantCandidate.size());
            System.debug('WRFcategory[0].System_Used__c'+WRFcategory[0].System_Used__c);
            
            for(Bureau_Candidate__c candidate : respondantCandidate) {
                respondantMap.put(candidate.Email__c, candidate.Id);
                respondantEmailNameMap.put(candidate.Email__c, candidate.Full_Name__c);
            	//respondantIdNameMap.put(candidate.Id, candidate.Full_Name__c);
                respondantIdEmailMap.put(candidate.Id, candidate.Email__c);
            }
            for(Bureau_Candidate__c candidate : recepientCandidate) {
                recepientMap.put(candidate.Email__c, candidate.Id);
                participantEmailNameMap.put(candidate.Email__c, candidate.Full_Name__c);
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
                newRating.Work_Request__c = wrfId;//Adding Work Request Id in Ratings
                newRating.Deadline__c = deadline;
                //newRating.Report_Ready__c ='Not Ready';
                //Added by saloni for default status
                if(WRFcategory[0].System_Used__c.contains('360')){
                    newRating.MFS_Status__c ='Not Started';
                    newRating.Reminder_1__c ='Eligible';
                    if(rw.Category == 'Self'){
                        newRating.TC_Status__c ='Not Started';
                        newRating.TC_Report_Sent__c ='Not Sent';
                        newRating.MFS_Report_Sent__c ='Not Sent';
                    }else{
                        if (newRating.MFS_Status__c != 'Completed') {
                            String respondentName = respondantEmailNameMap.get(respondantEmail).toLowerCase();//row.Respondent__r.Full_Name__c.toLowerCase();
                            if (!raterStringMap.containsKey(respondantEmail)) {
                                raterStringMap.put(respondantEmail, participantEmailNameMap.get(recipientEmail));
                            } else {
                                String oldValue = raterStringMap.get(respondantEmail);
                                raterStringMap.put(respondantEmail, oldValue + ', ' + participantEmailNameMap.get(recipientEmail));
                            }
                        }
                    }
                }
                else{
                    newRating.TC_Status__c ='Not Started';
                    newRating.TC_Report_Sent__c ='Not Sent';
                    newRating.Reminder_1__c ='Eligible';
                }
                
                
                if(rw.Category == 'Self') {
                    selfRatingList.add(newRating);
                }
                else {
                    otherRatingList.add(newRating);
                }
            }
            for(Bureau_Rating__c rating : otherRatingList){
                rating.Rater_String__c = raterStringMap.get(respondantIdEmailMap.get(rating.Respondent__c).toLowerCase());
                System.debug('Rating Data --> '+rating);
            }
            if(selfRatingList.size()!=0) {
                oldCandidateMap = new Map<Id, Bureau_Candidate__c>([Select id,Number_of_Product_Assessment__c,Bureau_Job__c,Work_Request__c,
                                                                    Number_of_participants__c,Number_of_Respondents__c from Bureau_Candidate__c where Work_Request__c = :wrfId]);
                //Database.Insert(selfRatingList,false);
                Database.SaveResult[] srList = Database.insert(selfRatingList, false);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug('Error Message: ' + err.getMessage());
                            if(!(err.getMessage().toUpperCase()).contains('DUPLICATE')){
                                throw new DMLException(err.getMessage());
                            }else{
                                selfRatingDone = true;
                            }
                        }
                    }else{
                        selfRatingDone = true;
                    }
                }
                //selfRatingDone = true;
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
            List<Bureau_Candidate__c> candidateList = [Select id,Bureau_Job__c,Bureau_Job__r.Name,Number_of_Product_Assessment__c,Work_Request__c,
                                                       Number_of_participants__c,Number_of_Respondents__c from Bureau_Candidate__c where Work_Request__c = :wrfId];
            RollUpCandidateFields.updateRollupSummaryFieldsWRFUpdate(candidateList,oldCandidateMap);
            //RollUpCandidateFields.updateRollupSummaryFieldsJobUpdate(candidateList,oldCandidateMap);
            RollUpCandidateFields.updateRollupSummaryFieldsOnJob(candidateList);
            
            List<Bureau_Rating__c> ratingsLinkedToWrf = [Select id,Bureau_Job__c,Respondent__c, Participant__c, Rating_Transfer_Status__c, Participant__r.Bureau_Job__c 
                                                         from Bureau_Rating__c 
                                                         where Work_Request__c = :wrfId];
            //Calculate Respondent Count on Candidates
            RollUpCandidateFields.calculateRespondentCountOnCandidate(ratingsLinkedToWrf);
			RollUpCandidateFields.updateTransferCountonJobOnNewWorkRequest(ratingsLinkedToWrf);            
            
            /* Added below batch job call to fix Respondent count in case of duplicates for MFS (SSE-26836) */
            CandidateBulkUploadBatch candidatebatch= new CandidateBulkUploadBatch(bureauJobId,'insert','Bureau_Candidate__c');
            Database.executeBatch(candidatebatch, 2000);
        }
        catch(Exception exp) {
            System.debug('Exp ###'+exp.getMessage());
            System.debug('Inside Catch Error Message: ' + exp.getMessage());
            throw new AuraHandledException(exp.getMessage()); 
        }
    }
    
    public class RatingWrapper {
        public String Category;
        public String Email;
        public String Recipient_Email;
    }
    
    @AuraEnabled
    public static JobWrapper getJobData(String recordId){
        JobWrapper wrapper = new JobWrapper();
        if(recordId != null){
            Work_Request__c generatedRequest = [SELECT Id,Account__c,System_Used__c,Job__c,WRF_Link__c,WRF_Client_Name__c,Work_Request_Generated__c,Job_Id_System_Used__c FROM Work_Request__c WHERE Id = :recordId limit 1];
            Job__c relatedJob = [SELECT Id, Name, MS_Line_of_Business__c, Job_Region__c, System_Used__c FROM Job__c WHERE Id = :generatedRequest.Job_Id_System_Used__c limit 1];
            
            wrapper.workRequestData = generatedRequest;
            wrapper.jobData = relatedJob;
        }
        return wrapper;
    }
    
    public class JobWrapper{
        @AuraEnabled public Work_Request__c workRequestData;
        @AuraEnabled public Job__c jobData;
    }

    @future
    public static void furtherSubmittionProcess(Id relatedJobId,Id submittedRequestId,Id newOppId,Id GeneratedRequestId){
        Work_Request__c submittedRequest = [SELECT Id , Name,job__c,job__r.Project_Manager__r.email,Job__r.Name FROM Work_Request__c WHERE Id =:submittedRequestId];
        Job__c relatedJob = [select id,
                             System_Used__c,
                             Project_Manager__c,
                             Billing_Cycle_End_Date__c,
                             opportunity__c,
                             Project_Manager__r.email,Account__r.Is_Repeatable_Business__c,
                             Client_Domain__c,
                             Billing_Frequency__c,
                             recordtypeid,
                             Start_Date__c,
                             End_Date__c,
                             Launch_Confirmation_to__c,
                             Report_to__c,
                             Report_Language__c,
                             Progress_Report_to__c,
                             Dependencies__c,
                             Project_Description__c,
                             Do_Not_Send_Survey__c,
                             Sender_Email__c,
                             Sender_Name__c,
                             Survey_Language__c,
                             Survey_Recipient_Email_1__c,
                             Survey_Recipient_Email_2__c,
                             Survey_Recipient_Email_3__c,
                             Survey_Recipient_Name_1__c,
                             Survey_Recipient_Name_2__c,
                             Survey_Recipient_Name_3__c,
                             Generic_Date_Field_MS_One__c from job__c where id=:relatedJobId limit 1];
        Opportunity newOpp = [select id from Opportunity where id=:newOppId];   
        if(Date.Today()>relatedJob.Billing_Cycle_End_Date__c && relatedJob.Account__r.Is_Repeatable_Business__c){
            Opportunity existingOpp = [select id,Name,stagename,accountid,primary_contact__c,billing_contact__c,Business_Type__c,Previous_Record_Type__c,GCSC__c,Unconfirmed_Sun_Order_Number__c,NoOfProducts__c from opportunity where id=:relatedjob.opportunity__c];
            String existingOppId = existingOpp.Id;
            List<OpportunityLineItem> ExistingOLIs = [select id,PricebookEntryId,Contract_Year__c,Quantity,Basis_of_Fees__c,Number_of_Services__c,List_Price__c,UnitPrice,Proposition__c,Package__c,RenewableNew__c,Solution_Cap__c,Usage_Allowance__c,Total_Equivalent_Units__c,Description,Add_On__c,Platform__c from OpportunityLineitem where opportunityid=:existingOppId];
            List<OpportunityLineItem> NewOLIs = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli:ExistingOLIs){
                OpportunityLineItem NewOli = new OpportunityLineItem();
                NewOli = oli;
                NewOli.id=null;
                NewOli.opportunityId = newOpp.Id;
                NewOLIs.add(NewOli);
            }
            insert NewOLIs;
            System.debug('New OLIS '+NewOLIs);
            newOpp.StageName = 'Verbal';
            update newOpp;
            
            Job__c job = new Job__c();
            String jobid;
            Integer counter = 1;
            While(Job.id==null){
                system.debug('Inside While '+counter);
                counter++;
                job = [select id from job__c where opportunity__c=:newOpp.Id];
                jobid = job.id;
            }
            job = relatedJob.clone(false,true,false,false);
                job.Opportunity__c = newOpp.Id;
                job.Id = jobid;
                job.Billing_Cycle_Start_Date__c = relatedJob.Billing_Cycle_End_Date__c.adddays(1);
            	job.WRFs_Submitted__c = 1;
                System.debug('New Job Id is '+Job.Id);
                update job;
                submittedRequest.Job__c = job.Id;
                Work_Request__c generatedRequest = new Work_Request__c();
                generatedRequest.Id = generatedRequestId;
                generatedRequest.Job_Id_System_Used__c = job.Id;
            update submittedRequest;
            update generatedRequest;
            List<Bureau_System__c> linkedSystems = new List<Bureau_System__c>();
            linkedSystems = [select id,Project_Id__c,Bureau_Job__c,System__c from Bureau_System__c where Bureau_Job__c=:relatedjob.Id];
            if(linkedSystems.size()>0){
                List<Bureau_System__c> sysToInsert = new List<Bureau_System__c>();    
                for(Bureau_System__c existingSystem:linkedSystems){
                    Bureau_System__c bureauObj = new Bureau_System__c();
                    bureauObj.Bureau_Job__c = job.Id;
                    bureauObj.System__c = existingSystem.System__c;
                    bureauObj.Project_Id__c = existingSystem.Project_Id__c;
                    sysToInsert.add(bureauObj);
                }
                insert sysToInsert;
            }
        }    
        Work_Request__c newReq = [SELECT Id , Name,job__c,job__r.Project_Manager__r.email,Job__r.Name FROM Work_Request__c WHERE Id =:submittedRequest.Id];
        sendEmail(relatedJob,newReq);
        
        
    }   
        
    public static void getDataFromFile(String contentDocumentId, String operationType){
        List<ResponseWrapper> responseWrapper = new List<ResponseWrapper>();
        try {
            Id contentDocId = Id.valueOf(contentDocumentId);
            System.debug('contentDocId: '+ contentDocId);
            List<Id> fileIdsList = new List<Id>{contentDocId};
            List<BulkDataWrapper> lstWrapper = new List<BulkDataWrapper>();
            BulkDataWrapper wrapper = new BulkDataWrapper();
            wrapper.objectName = 'Bureau_Candidate__c';
            wrapper.operation = operationType;
            wrapper.fileIdList = fileIdsList;
            System.debug('BulkDataWrapper Wrapper --> '+ wrapper);
            lstWrapper.add(wrapper);
            importBulkdata(fileIdsList, operationType);
            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        }
    
    public class BulkDataWrapper {
        public List<Id> fileIdList;
        public String objectName;
        public String operation;
    }
    
    public class ResponseWrapper {
        public String response;
    }
    
    @future(callout=true)
    public static void importBulkdata(List<Id> fileIdsList, String operationType) {
        System.debug('importBulkdata HEap Size --> '+Limits.getHeapSize());
        System.debug('importBulkdata HEap Size --> '+Limits.getLimitHeapSize());
        ResponseWrapper rw = new ResponseWrapper();
        String objectName = 'Bureau_Candidate__c';
        String operation = operationType;
        String contentDocumentId = fileIdsList[0];
        String wrfRecordId;
        
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId ];
        
        String encoded = EncodingUtil.urlEncode(cv.VersionData.toString(), 'UTF-8');
        System.debug('encoded '+encoded);
        String encodedAdded;
        if(operationType == 'insert'){
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
                wrfRecordId = con.LinkedEntityId; 
            }
        }
        Work_Request__c wrfRecord = [SELECT Id, bulkJobId__c FROM Work_Request__c WHERE Id =: wrfRecordId];
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
                
                request2.setBody('{ "state" : "UploadComplete" }');
                Http h2 = new Http();
                HttpResponse resp2 = h2.send(request2);
                System.debug('resp2.getStatusCode() --> '+resp2.getStatusCode());
                System.debug('jobId: '+ jobId);
                if(resp2.getStatusCode() <= 299) {
                    
                    rw.response = jobId;
                    String toAddJobId;
                    if(wrfRecord != null && !String.isBlank(wrfRecord.bulkJobId__c)){
                        toAddJobId = wrfRecord.bulkJobId__c;
                        wrfRecord.bulkJobId__c = jobId + ',' + toAddJobId;    
                        System.debug('jobId: '+ wrfRecord.bulkJobId__c);
                    }else{
                        wrfRecord.bulkJobId__c = jobId;
                    }
                    UPDATE wrfRecord;
                } else {
                    rw.response = 'There was an error. Please contact your admin.';
                }
            }
        }
        
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
        DELETE docs;
        
        System.debug('At Method End importBulkdata HEap Size --> '+Limits.getHeapSize());
        System.debug('At Method End importBulkdata HEap Size --> '+Limits.getLimitHeapSize());
    }
    
    @AuraEnabled
    public static void getJobStatus(String wrfId) {
        try {
            System.debug('try getJobStatus');
            ScheduleClassToGetJobStatusWRF scheduleJob = new ScheduleClassToGetJobStatusWRF(wrfId);
            Datetime scheduledDate = Datetime.now().addMinutes(5);
            String hour = String.valueOf(scheduledDate.hour());
            String min = String.valueOf(scheduledDate.minute());
            String ss = String.valueOf(scheduledDate.second());
            // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String sch = ss + ' ' + min + ' ' + hour + ' * * ?';
            String jobID1 = System.schedule('Get Bulk Job Status WRF '+System.now(), sch, scheduleJob);
        }
        catch(Exception exp) {
            System.debug('Catch getJobStatus '+ exp.getMessage());
            throw new AuraHandledException(exp.getMessage());
        }
    }

    public static void sendEmail(Job__c relatedJob,Work_Request__c newReq){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toaddresses = new List<String>(); 
            //mail.setTargetObjectId(newReq.job__c);
            System.debug('EMAIL IS '+relatedJob.Sender_Email__c);
            //String oppLink = '<a href="'+ URL.getOrgDomainURL().toExternalForm()+'/'+opp.Id +'">'+opp.OpportunityId__c+'</a>';
            String crfLink = '<a href="'+ URL.getOrgDomainURL().toExternalForm()+'/'+newReq.Id +'">'+newReq.Name +'</a>';
            String subject = 'New Customer Request Submitted';
        if(Test.isRunningTest()){
            mail.setToAddresses(new String[] {'test@test.com'});
        }else{
            mail.setToAddresses(new String[] {relatedJob.Sender_Email__c});
        }
            
            mail.setCcAddresses(new String[] {relatedJob.Project_Manager__r.email});
            mail.setSubject(subject);
            String htmlBody = 'Hello, <br/><br/>This is to inform you that a new customer request '+crfLink +' has been created for the job ' +newReq.Job__r.Name + '.<br><br>Thank You  ';
            mail.setHtmlBody(htmlBody);
            OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: 'noreply@shl.com' Limit 1];
            mail.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
            mailList.add(mail);
            mail.saveAsActivity = false;
            Messaging.SendEmailResult[] result= Messaging.sendEmail(mailList);
            
    }
    
    /*@AuraEnabled
    public static void updateCandidatesToLinkJob(String jobId, String wrfId){
        try{
            list<Id> bureauJobIdsList = new list<Id>{jobId};
                updateCandidatesToLinkJobCont(bureauJobIdsList);
        } catch (Exception e) {
            // Log the exception details
            System.debug('Error in updateCandidatesToLinkJob: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }*/
    
    @AuraEnabled
    public static void updateCandidatesToLinkJob(String jobId, String wrfId, Date deadline){
        list<Bureau_Candidate__c> candidateList = new list<Bureau_Candidate__c>();
        list<Bureau_Candidate__c> candidateListToUpdate = new list<Bureau_Candidate__c>();
        list<Bureau_Candidate__c> candidateListAfterUpdate = new list<Bureau_Candidate__c>();
        Set<Id> candidateIds = new Set<Id>();
        Work_Request__c wR = new Work_Request__c();
        Job__c job = new Job__c();
        
        try{
            if(jobId!=null && wrfId!=null){
                wR = [SELECT Id, Product_Assessment__c FROM Work_Request__c WHERE Id = :wrfId LIMIT 1];
                candidateList = [SELECT Id,Work_Request__c,Bureau_Job__c,Number_of_Product_Assessment__c,
                                 Number_of_participants__c,Number_of_Respondents__c,Job_Region__c
                                 FROM Bureau_Candidate__c WHERE Work_Request__c=:wrfId];
                job = [SELECT Id, Job_Region__c FROM Job__c WHERE Id = :jobId LIMIT 1];
            }

            if(!candidateList.isEmpty()){
                for(Bureau_Candidate__c bc : candidateList){
                    bc.Bureau_Job__c = jobId;
                    bc.Product_Assessment__c = wR.Product_Assessment__c;
                    if(String.isBlank(bc.Job_Region__c)){
                        bc.Job_Region__c = job.Job_Region__c;
                    }
                    candidateListToUpdate.add(bc);
                    candidateIds.add(bc.Id);
                }
            }
            
            if(!candidateListToUpdate.isEmpty()){
                try{
                    Map<Id, Bureau_Candidate__c> oldCandidateMap = new Map<Id, Bureau_Candidate__c>(candidateList);
                
                    list<Job__c> jobList = [Select id,Number_of_Assessments__c,Number_of_Participants_New__c,
                                        Number_of_Respondents_New__c,Candidate_Max_Sequence_No_New__c 
                                        FROM Job__c WHERE Id = :jobId];
                
                    UPDATE candidateListToUpdate; 
                    createManualRatings(candidateListToUpdate, wR, deadline);
                    RollUpCandidateFields.updateRollupSummaryFieldsOnWRF(candidateListToUpdate);
                    candidateListAfterUpdate = [SELECT Id,Work_Request__c,Bureau_Job__c,Number_of_Product_Assessment__c,
                                 Number_of_participants__c,Number_of_Respondents__c 
                                 FROM Bureau_Candidate__c WHERE Work_Request__c=:wrfId];  
                    
                    Work_Request__c wrfToUpdate = new Work_Request__c();
                    wrfToUpdate.Id = wrfId;
                    wrfToUpdate.Candidate_Request_Type_Backend_Use__c = 'Manual Created';
                    wrfToUpdate.Status__c = 'Completed';
                    UPDATE wrfToUpdate;
                    
                    jobList[0].Candidate_Max_Sequence_No_New__c += candidateListAfterUpdate.size();
                    jobList[0].Status_Calculations__c = RollUpCandidateFields.updateStatusCalculations(jobList[0].Id);
                    for(Bureau_Candidate__c candidateRec : candidateListAfterUpdate){
                        if(candidateRec.Number_of_Product_Assessment__c !=null){
                            jobList[0].Number_of_Assessments__c += candidateRec.Number_of_Product_Assessment__c;  
                        }
                        if(candidateRec.Number_of_participants__c !=null){
                            jobList[0].Number_of_Participants_New__c += candidateRec.Number_of_participants__c;  
                        }
                        if(candidateRec.Number_of_Respondents__c !=null){
                            jobList[0].Number_of_Respondents_New__c += candidateRec.Number_of_Respondents__c;
                        }
                    }
                    UPDATE jobList;
                    
                }catch(DMLException dmlEx){
                    System.debug('Error '+dmlEx.getmessage());
                    throw dmlEx;
                }
            }    
        }catch (QueryException queryEx) {
            System.debug('Query Error: ' + queryEx.getMessage());
            throw queryEx;
        } catch(Exception e) {
            System.debug('General Error: ' + e.getMessage());
            throw e;
        }
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
    
    @AuraEnabled
    public static ExportWrapper getCandidateCount(String jobId, String soqlQueryList){
        System.debug('soqlQueryList --> '+ soqlQueryList);
        list<Bureau_Candidate__c> candidateList = new list<Bureau_Candidate__c>();
        ExportWrapper wrapper = new ExportWrapper();
        String queryJobId;
        Integer candidateCount;
        String message;
        candidateCount = [Select count() FROM Bureau_Candidate__c WHERE Bureau_Job__c =: jobId];
        System.debug('candidateCount -> '+candidateCount);
        if(candidateCount == 0){
            candidateList = null;
        }else if(candidateCount <= 50000){
            candidateList = getCandidateData(jobId, soqlQueryList);
            System.debug('candidateList --> '+candidateList);
        }else{
            candidateList = null;
            queryJobId = createQueryJob(soqlQueryList, jobId, 'Candidate');
            }
        wrapper.candidateCount = candidateCount;
        wrapper.candidateData = candidateList;
        wrapper.queryJobId = queryJobId;
        System.debug('wrapper --> '+wrapper);
        return wrapper;
    }
    
    public static list<Bureau_Candidate__c> getCandidateData(String jobId, String soqlQueryList){
        try {
            list<Bureau_Candidate__c> candidateList = new list<Bureau_Candidate__c>();
            String soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Candidate__c WHERE Bureau_Job__c = \'' + jobId + '\'';
            System.debug('soqlQuery --> '+soqlQuery);
            candidateList = database.query(soqlQuery);
            if(candidateList.size() > 0){
                return candidateList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return new list<Bureau_Candidate__c>();
    }
    
    @AuraEnabled
    public static ExportWrapper getRatingsCount(String jobId, String soqlQueryList, String exportType){
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
                ratingsList = getRatingData(jobId);   
            }else{
                wr = getMasterViewData(soqlQueryList, jobId);
                ratingsList = wr.ratingData;
                wrapper.candidateData = wr.candidateData;
            }
            System.debug('ratingsList --> '+ratingsList);
        }else{
            ratingsList = null;
            queryJobId = createQueryJob(null, jobId, exportType);
        }
        wrapper.ratingCount = ratingCount;
        wrapper.ratingData = ratingsList;
        wrapper.queryJobId = queryJobId;
        System.debug('wrapper --> '+wrapper);
        return wrapper;
    }
    
    public static list<Bureau_Rating__c> getRatingData(String jobId){
        try {
            list<Bureau_Rating__c> ratingList = new list<Bureau_Rating__c>();
            String soqlQuery = 'Select Id,Name,Participant__r.Work_Request__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,' +
                'Respondent__r.Full_Name__c, Respondent__r.Email__c, Rater_Type__c,'+
                'VADC_Status__c,Insights_Status__c,MFS_Status__c, TC_Status__c, Overall_Status__c, Rater_String__c, Reminder__c,Report_Ready__c, Report_Sent__c,'+ 
                'Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c,MFS_Report_Sent__c,TC_Report_Sent__c,EmailType__c,Sharepoint_File_Path__c,Email_File_Name__c FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = \'' + jobId + '\' LIMIT 50000';
            ratingList = database.query(soqlQuery);
            if(ratingList.size() > 0){
                return ratingList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return new list<Bureau_Rating__c>();
    }

    public static String createQueryJob(String soqlQueryList, String jobId, String exportType) {
        System.debug('jobId '+jobId);
        System.debug('importBulkdata HEap Size --> '+Limits.getHeapSize());
        System.debug('importBulkdata HEap Size --> '+Limits.getLimitHeapSize());
        String objectName;
        String operation = 'query';
        String soqlQuery;
        if(exportType == 'Candidate'){
            objectName = 'Bureau_Candidate__c';
            soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Candidate__c WHERE Bureau_Job__c = \'' + jobId + '\'';   
            System.debug('soqlQuery '+ soqlQuery);
        }else{
            objectName = 'Bureau_Rating__c';
            soqlQuery = 'Select Id,Name,Participant__r.Work_Request__r.Name,Respondent__r.Id,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,' +
                'Respondent__r.Name,Respondent__r.Full_Name__c, Respondent__r.Email__c, Rater_Type__c,Insights_Status__c,VADC_Status__c,'+
                'MFS_Status__c, TC_Status__c, Overall_Status__c, Rater_String__c, Reminder__c,Report_Ready__c, Report_Sent__c,'+ 
                'Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c,MFS_Report_Sent__c,TC_Report_Sent__c,EmailType__c,Sharepoint_File_Path__c,Email_File_Name__c FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = \'' + jobId + '\'';
        }
        System.debug('soqlQuery '+ soqlQuery);
        
        OAuthResponse wrapper = getAccessToken();
        System.debug('Access Token '+ wrapper.access_token);
        /* ******************************** */
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/query');
        request.setHeader('content-type', 'application/json');
        //request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
        request.setHeader('Authorization' ,'Bearer '+wrapper.access_token);
        String body = '{ '+
            '"columnDelimiter": "COMMA",'+  
            '"lineEnding": "CRLF",'+ 
            '"operation": "'+operation+'",'+ 
            '"query": "'+soqlQuery+'",'+ 
            '"contentType": "CSV"'+
            '}';
        request.setBody(body);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        System.debug('resp all --> '+resp.getBody());
        System.debug('resp.getStatusCode() --> '+resp.getStatusCode());
        
        if(resp.getStatusCode() == 200) {
            Map<String, Object> respMap1 = (Map<String, Object>) Json.deserializeUntyped(resp.getBody()); 
            String queryJobId = (String)respMap1.get('id'); 
            return queryJobId;
        }else{
            return 'Error Occurred';
        }
    }
    
    private static String buildIdList(List<Id> idList) {
        List<String> idStringList = new List<String>();
        for (Id candidateId : idList) {
            idStringList.add('\'' + String.escapeSingleQuotes(candidateId) + '\'');
        }
        return String.join(idStringList, ',');
    }
    
    @AuraEnabled
    public static String createQueryJobToGetCandidateDataForMasterView(String soqlQueryList, String jobId) {
        String objectName = 'Bureau_Candidate__c';
        String operation = 'query';
        String soqlQuery;
        soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Candidate__c WHERE Bureau_Job__c = \'' + jobId + '\'';   
        System.debug('soqlQuery '+ soqlQuery);
        
        OAuthResponse wrapper = getAccessToken();
        System.debug('Access Token '+ wrapper.access_token);
        /* ******************************** */
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/query');
        request.setHeader('content-type', 'application/json');
        //request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
        request.setHeader('Authorization' ,'Bearer '+wrapper.access_token);
        String body = '{ '+
            '"columnDelimiter": "COMMA",'+  
            '"lineEnding": "CRLF",'+ 
            '"operation": "'+operation+'",'+ 
            '"query": "'+soqlQuery+'",'+ 
            '"contentType": "CSV"'+
            '}';
        request.setBody(body);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        System.debug('resp all --> '+resp.getBody());
        System.debug('resp.getStatusCode() --> '+resp.getStatusCode());
        
        if(resp.getStatusCode() == 200) {
            Map<String, Object> respMap1 = (Map<String, Object>) Json.deserializeUntyped(resp.getBody()); 
            String queryJobId = (String)respMap1.get('id'); 
            return queryJobId;
        }else{
            return 'Error Occurred';
        }
    }
    
    @AuraEnabled
    public static QueryResponseWrapper getQueryStatus(String queryJobId){
        QueryResponseWrapper rw = new QueryResponseWrapper();
        OAuthResponse wrapper = getAccessToken();
        System.debug('Access Token '+ wrapper.access_token);
        //Second request to get information about query job
        HttpRequest request1 = new HttpRequest();
        request1.setMethod('GET');
        request1.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/query/'+queryJobId);
        //request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
        request1.setHeader('Authorization' ,'Bearer '+wrapper.access_token);

        Http h1 = new Http();
        HttpResponse resp1 = h1.send(request1);
        System.debug('resp1.getStatusCode() --> '+resp1.getStatusCode());
        System.debug('resp1.getBody() --> '+resp1.getBody());
        
        if(resp1.getStatusCode() == 200) {
            Map<String, Object> respMap1 = (Map<String, Object>) JSON.deserializeUntyped(resp1.getBody());
            Integer numberRecordsProcessed = (Integer)respMap1.get('numberRecordsProcessed'); 
            System.debug('numberRecordsProcessed '+ numberRecordsProcessed);
            Integer isPkChunkingSupported = (Integer)respMap1.get('isPkChunkingSupported'); 
            System.debug('isPkChunkingSupported '+ isPkChunkingSupported);
            String state = (String)respMap1.get('state'); 
            System.debug('state '+ state);
            rw.state = state;
            rw.numberOfRecord = '' + numberRecordsProcessed;
        } else{
            rw.response = 'Code ' + resp1.getStatusCode();
        }
        return rw;
    } 
    
    @AuraEnabled
    public static QueryResponseWrapper getQueryData(String queryJobId){
        QueryResponseWrapper rw = new QueryResponseWrapper();
        OAuthResponse wrapper = getAccessToken();
        HttpRequest request2 = new HttpRequest();
        request2.setMethod('GET');
        system.debug( '1454: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        request2.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/query/'+queryJobId+'/results?maxRecords=10000');
        system.debug( '1456: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        request2.setHeader('Accept', 'text/csv;charset=UTF-8');
        //request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
        request2.setHeader('Authorization' ,'Bearer '+wrapper.access_token);
        request2.setHeader('Content-Type', 'text/csv;charset=UTF-8');
        request2.setHeader('Content-Encoding', 'gzip');
        request2.setHeader('Transfer-Encoding', 'chunked');
        Http h2 = new Http();
        system.debug( '1459: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        HttpResponse resp2 = h2.send(request2);
        System.debug('resp2.getStatusCode() --> '+resp2.getStatusCode());
        if(resp2.getStatusCode() == 200) {
            rw.response = resp2.getBody();
            System.debug('resp2.sforce-locator --> '+resp2.getHeader('Sforce-Locator'));
            System.debug('resp2.sforce-numberofrecords --> '+resp2.getHeader('Sforce-NumberOfRecords'));
            System.debug('resp2.getBody() --> '+resp2.getBody());
            rw.locator = resp2.getHeader('Sforce-Locator');
            rw.numberOfRecord = resp2.getHeader('Sforce-NumberOfRecords');
            rw.response = resp2.getBody();
        }else {
            rw.response = 'There was an error. Please contact your admin.';
        }
        return rw;
    }
    
    @AuraEnabled
    public static QueryResponseWrapper getMoreQueryData(String queryJobId, String locator){
        QueryResponseWrapper rw = new QueryResponseWrapper();
        OAuthResponse wrapper = getAccessToken();
        System.debug('Access Token '+ wrapper.access_token);
        HttpRequest request2 = new HttpRequest();
        request2.setMethod('GET');
        request2.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/query/'+queryJobId+'/results?maxRecords=10000&locator='+locator);
        //request2.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v51.0/jobs/query/'+queryJobId+'/results?maxRecords=12000&locator=MTAwMDA6MEdhUHUwMDAwMDF6ZWhWS0FROjA');
        request2.setHeader('Accept', 'text/csv;charset=UTF-8');
        //request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId());
        request2.setHeader('Authorization' ,'Bearer '+wrapper.access_token);
        Http h2 = new Http();
        HttpResponse resp2 = h2.send(request2);
        System.debug('resp2.getStatusCode() --> '+resp2.getStatusCode());
        if(resp2.getStatusCode() == 200) {
            rw.response = resp2.getBody();
            System.debug('resp2.sforce-locator --> '+resp2.getHeader('Sforce-Locator'));
            System.debug('resp2.sforce-numberofrecords --> '+resp2.getHeader('Sforce-NumberOfRecords'));
            System.debug('resp2.getBody() --> '+resp2.getBody());
            rw.locator = resp2.getHeader('Sforce-Locator');
            rw.numberOfRecord = resp2.getHeader('Sforce-NumberOfRecords');
            rw.response = resp2.getBody();
        }else {
            rw.response = 'There was an error. Please contact your admin.';
        }
        return rw;
    } 
    
    public static OAuthResponse getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        Metadata_API_Setting__c setting = Metadata_API_Setting__c.getValues('Metadata');
    
        String CLIENT_ID = setting.Consumer_Key__c;
        String CLIENT_SECRET = setting.Consumer_Secret__c;
        String body = 'grant_type=client_credentials' +
                      '&client_id=' + CLIENT_ID +
                      '&client_secret=' + CLIENT_SECRET;

        req.setBody(body);

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
            System.debug('response '+res.getBody());
            if (res.getStatusCode() == 200) {
                OAuthResponse oauthResponse = (OAuthResponse) JSON.deserialize(res.getBody(), OAuthResponse.class);
                return oauthResponse;
            } else {
                System.debug('Error: ' + res.getStatus());
                System.debug('Response: ' + res.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getListOfSolutions(Id OpportunityId){
        List<AggregateResult> olis = new List<AggregateResult>();
        olis = [select Package__c from opportunitylineitem where opportunityid=:OpportunityId group by Package__c];
        List<String> solutions = new List<String>();
        if(olis.size()>0){
            for(AggregateResult oli:olis){
                solutions.add((String)oli.get('Package__c'));
            } 
        }
        return solutions;
    }
    
    public class OAuthResponse {
        @AuraEnabled public String access_token;
        @AuraEnabled public String instance_url;
        @AuraEnabled public String id;
        @AuraEnabled public String token_type;
        @AuraEnabled public String issued_at;
        @AuraEnabled public String signature;
    }
    
    public class QueryResponseWrapper{
        @AuraEnabled public String response;
        @AuraEnabled public String locator;
        @AuraEnabled public String numberOfRecord;
        @AuraEnabled public String state;
    }
    
    public class CandidateAndRatingData{
        @AuraEnabled public list<Bureau_Rating__c> ratingData;
        @AuraEnabled public List<Bureau_Candidate__c> candidateData;
    }
    
    @AuraEnabled
    public static CandidateAndRatingData getMasterViewData(String soqlQueryList, String jobId){
        list<Bureau_Rating__c> ratingList = new list<Bureau_Rating__c>();
        List<Bureau_Candidate__c> candidateList = new List<Bureau_Candidate__c>();
        list<Id> candidateIdList = new list<Id>();
        CandidateAndRatingData wrapper = new CandidateAndRatingData();
        String soqlQueryRating = 'Select Id,Name,Participant__r.Work_Request__r.Name,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,' +
                'Respondent__r.Name,Respondent__r.Full_Name__c, Respondent__r.Email__c, Rater_Type__c,'+
                'MFS_Status__c,Insights_Status__c, VADC_Status__c, TC_Status__c, Overall_Status__c, Rater_String__c, Reminder__c,Report_Ready__c, Report_Sent__c,'+ 
                'Deadline__c,Comments__c,File_Name__c,Single_Use_Link__c,MFS_Report_Sent__c,TC_Report_Sent__c,EmailType__c,Sharepoint_File_Path__c,Email_File_Name__c FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = \'' + jobId + '\' LIMIT 50000';
        ratingList = database.query(soqlQueryRating);
        /*ratingList = [SELECT Id,Name,Participant__c,Participant__r.Name,Participant__r.Full_Name__c,Participant__r.Email__c,
                      Respondent__c,Respondent__r.Name,Respondent__r.Full_Name__c,Respondent__r.Email__c,Rater_Type__c,Status__c,Participant__r.Reports_Status__c,
                      MFS_Status__c,TC_Status__c,Overall_Status__c,Rater_String__c,Reminder__c
                      FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c = :jobId LIMIT 50000];
        */
        for(Bureau_Rating__c r : ratingList){
            candidateIdList.add(r.Respondent__c);
        }
        
        String soqlQuery = 'Select ' + soqlQueryList + ' FROM Bureau_Candidate__c WHERE Id IN :candidateIdList';
        candidateList = database.query(soqlQuery);
        wrapper.ratingData = ratingList;
        wrapper.candidateData = candidateList;
        return wrapper;
    }
    
    @AuraEnabled
    public static List<Bureau_Candidate__c> updateCandidates(String candidatesJSON,List<String> fieldList) {
        try{
            List<Bureau_Candidate__c> lstCCToInsert = (List<Bureau_Candidate__c>) JSON.deserialize(candidatesJSON, List<Bureau_Candidate__c>.class);
            List<Bureau_Candidate__c> lstCCToUpdate = new List<Bureau_Candidate__c>();
            if(lstCCToInsert.size()>0){ 
                    set<id> candidateIds=new set<id>();
                    System.debug('Field List '+fieldList);
                    for(Integer i=0 ; i<lstCCToInsert.size() ; i++){
                        Bureau_Candidate__c bureauCandidateUpdate = new Bureau_Candidate__c();
                        for(String field:fieldList){
                            bureauCandidateUpdate.put(field,lstCCToInsert[i].get(field));
                        }
                        /*bureauCandidateUpdate.Id = lstCCToInsert[i].Id;
                        bureauCandidateUpdate.First_Name__c = lstCCToInsert[i].First_Name__c;
                        bureauCandidateUpdate.Last_Name__c = lstCCToInsert[i].Last_Name__c;
                        bureauCandidateUpdate.Email__c = lstCCToInsert[i].Email__c;*/
                        lstCCToUpdate.add(bureauCandidateUpdate);
                        candidateIds.add(lstCCToInsert[i].Id);
                    }
                    if(lstCCToUpdate.size()>0){
                        Database.update(lstCCToUpdate, false); 
                        return lstCCToUpdate;
                    }
                }
            
        }catch(Exception e){
            System.debug('Inside Catch Error Message: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }
        return new List<Bureau_Candidate__c>();
    }
    
    @AuraEnabled
    public static List<Bureau_Rating__c> updateRating(String candidatesJSON, String jobId) {
        try{
            // Replace empty strings for Deadline__c with null so Salesforce can deserialize
            candidatesJSON = candidatesJSON.replaceAll('"Deadline__c":"","', '"Deadline__c":null,"');
            
            List<Bureau_Rating__c> lstCCToInsert = (List<Bureau_Rating__c>) JSON.deserialize(candidatesJSON, List<Bureau_Rating__c>.class);
            List<Bureau_Rating__c> lstCCToUpdate = new List<Bureau_Rating__c>();
            Map<String,string> reminderMap = new Map<string,string>();
            System.debug('Size '+lstCCToInsert.size());
            System.debug('lstCCToInsert '+lstCCToInsert);
            if(lstCCToInsert.size()>0){ 
                
                set<id> candidateIds=new set<id>();
                for(Integer i=0 ; i<lstCCToInsert.size() ; i++){
                    Bureau_Rating__c rating = new Bureau_Rating__c();
                    rating.Id = lstCCToInsert[i].Id;
                    rating.MFS_Status__c = lstCCToInsert[i].MFS_Status__c;
                    rating.TC_Status__c = lstCCToInsert[i].TC_Status__c;
                    rating.Report_Ready__c = lstCCToInsert[i].Report_Ready__c;
                    rating.Report_Sent__c = lstCCToInsert[i].Report_Sent__c;
                    rating.Deadline__c = lstCCToInsert[i].Deadline__c;
                    rating.Comments__c = lstCCToInsert[i].Comments__c;
                    rating.File_Name__c = lstCCToInsert[i].File_Name__c;
                    rating.Single_Use_Link__c = lstCCToInsert[i].Single_Use_Link__c;
                    rating.MFS_Report_Sent__c = lstCCToInsert[i].MFS_Report_Sent__c;
                    rating.TC_Report_Sent__c = lstCCToInsert[i].TC_Report_Sent__c;
                    rating.VADC_Status__c = lstCCToInsert[i].VADC_Status__c;
                    rating.Insights_Status__c = lstCCToInsert[i].Insights_Status__c;
                    rating.Rater_String__c = lstCCToInsert[i].Rater_String__c;
                    rating.Reminder_1__c = lstCCToInsert[i].Reminder_1__c;
                    rating.Rater_Type__c = lstCCToInsert[i].Rater_Type__c;
                    rating.Sharepoint_File_Path__c = lstCCToInsert[i].Sharepoint_File_Path__c;
                    rating.Email_File_Name__c = lstCCToInsert[i].Email_File_Name__c;
                    rating.EmailType__c = lstCCToInsert[i].EmailType__c;
                    /*if (lstCCToInsert[i].Rater_Type__c == 'Self') {
//system.debug('--->lstCCToInsert[i].Participant__r.Full_Name__c'+lstCCToInsert[i].Participant__c);
if(lstCCToInsert[i].MFS_Report_Sent__c =='Sent' && lstCCToInsert[i].TC_Report_Sent__c =='Sent')
{
string participantName = lstCCToInsert[i].Participant__r.Full_Name__c;
reminderMap.put(participantName,'Not Eligible');
}
else if(lstCCToInsert[i].MFS_Report_Sent__c =='Not Sent' || lstCCToInsert[i].TC_Report_Sent__c =='Not Sent'){
string participantName = lstCCToInsert[i].Participant__r.Full_Name__c;
if(lstCCToInsert[i].Overall_Status__c =='In Progress' || lstCCToInsert[i].Overall_Status__c =='Not Started'){

reminderMap.put(participantName,'Eligible');
}
else{
reminderMap.put(participantName,'Not Eligible');
}
}
}*/
                    //rating.Reminder_1__c = reminderMap.get(lstCCToInsert[i].Participant__r.Full_Name__c.toLowerCase());
                    System.debug('List to update '+rating);
                    lstCCToUpdate.add(rating);
                }
                if(lstCCToUpdate.size()>0){
                    Database.update(lstCCToUpdate, false); 
                    String json = RollUpCandidateFields.updateStatusCalculations(jobId);
                    Job__c job = new Job__c();
                    job.id = jobId;
                    job.Status_Calculations__c = json;
                    job.Number_of_Assessments__c=0;
                    job.Number_of_Participants_New__c=0;
                    job.Number_of_Respondents_New__c=0; 
                    update job;
                    String query = 'SELECT Id, Bureau_Job__c, Bureau_Job__r.Name FROM Bureau_Candidate__c WHERE Bureau_Job__c = \'' +jobid+ '\'';
                    List<Bureau_Candidate__c> candidateRecords = Database.query(query);
                    RollUpCandidateFields.updateRollupSummaryFieldsOnJob(candidateRecords);
                    return lstCCToUpdate;
                }
               
            }
        }catch(Exception e){
            System.debug('candidatesJSON '+ candidatesJSON);
            System.debug('Inside Catch Error Message: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }
        return new List<Bureau_Rating__c>();
    }
    
    @Auraenabled
    public static String deleteCandidateList(String wrfId){
        try{
            List<Bureau_Candidate__c> candidateList;
            List<Bureau_Rating__c> ratingList;
            Set<Id> candidateIds = new Set<Id>();
            String result;
            
            if(String.isNotBlank(wrfId)){
                
                ratingList = [SELECT Id, Participant__c, Respondent__c, Rater_type__c, Participant__r.Bureau_Job__c, Rating_Transfer_Status__c FROM Bureau_Rating__c WHERE Work_Request__c = :wrfId LIMIT 500];
                
                //No ratings found – Cancel Work Request
                //if(candidateList == null || candidateList.size() == 0){
                if(ratingList == null || ratingList.size() == 0){
                    result = 'There are no candidates available to delete.';
                    Work_Request__c wrfRec = [Select id,No_of_Candidate_Created__c,No_of_Participant_Created__c,Status__c, Job__c
                                              from Work_Request__c where Id = :wrfId LIMIT 1];
                    if(wrfRec != null){
                        wrfRec.Status__c = 'Cancelled';
                        update wrfRec;
                    }
                }
                //For Exactly one rating linked to Work Request - As this will be handled by Rating trigger
                else if(ratingList.size() == 1){
                    System.debug('ratingList for 1');
                    delete ratingList;
                    
                    Id jobId;
                    Work_Request__c wrfRec = [Select id,No_of_Candidate_Created__c,No_of_Participant_Created__c,Status__c, Job__c
                                              from Work_Request__c where Id = :wrfId LIMIT 1];
                    if(wrfRec != null){
                        wrfRec.No_of_Candidate_Created__c = 0;
                        wrfRec.No_of_Participant_Created__c = 0;
                        wrfRec.Status__c = 'Cancelled';
                        update wrfRec;
                    }
                    result='Candidates are deleted successfully';
                }
                //Less than 500 ratings – Perform synchronous deletion
                else if(ratingList.size() < 500){
                    System.debug('ratingList for less than 500');
                    //else if(candidateList.size() < 500){
                    
                    /*for(Bureau_Rating__c rating : ratingList){
                        if(rating.Participant__c != null && rating.Respondent__c != null){
                            candidateIds.add(rating.Participant__c);
                            candidateIds.add(rating.Respondent__c);
                        }
                    }*/
                   
                    if(!ratingList.isEmpty()){
                     	delete ratingList; 
                        //Calculate Respondent Count on Candidates
            			RollUpCandidateFields.calculateRespondentCountOnCandidate(ratingList);
                    }
                    Id jobId;
                    Work_Request__c wrfRec = [Select id,No_of_Candidate_Created__c,No_of_Participant_Created__c,Status__c, Job__c
                                              from Work_Request__c where Id = :wrfId LIMIT 1];
                    if(wrfRec != null)
                    	jobId = wrfRec.Job__c;
                    
                    candidateList = [SELECT id, Bureau_Job__c, Number_of_Product_Assessment__c, 
                                     Number_of_participants__c, Number_of_Respondents__c, Respondent_Count__c,
                                     Status2__c
                                     FROM Bureau_Candidate__c 
                                     WHERE Bureau_Job__c = :jobId
                                     AND Number_of_participants__c = 0 
                                     AND Respondent_Count__c = 0];
                    if(!candidateList.isEmpty())
                    	delete candidateList;
                    
                    if(wrfRec != null){
                        wrfRec.No_of_Candidate_Created__c = 0;
                        wrfRec.No_of_Participant_Created__c = 0;
                        wrfRec.Status__c = 'Cancelled';
                        update wrfRec;
                        
                        // Roll-up field updates
                        if(!candidateList.isEmpty()){
                            RollUpCandidateFields.deleteRollupSummaryFieldsOnJob(candidateList);
                        	RollUpCandidateFields.updateCandidateMaxSeqNoOnDelete(candidateList);
                        }
                        RollUpCandidateFields.calculateRatingsCountOnJob(jobId, ratingList);
                        RollUpCandidateFields.updateTransferCountonJob(ratingList);
                    }
                    result='Candidates are deleted successfully';
                }
                //500+ records – Use batch class for deletion
                else{
                    result='The candidate deletion process is in progress. You will be notified by an email once process is completed.';
                    CandidateBulkDeletionFromWRF candidatebatch= new CandidateBulkDeletionFromWRF(wrfId ,'Rating');
                    Database.executeBatch(candidatebatch,2000);
                }
            }    
            return result;
        }catch(Exception ex){
            throw new AuraHandledException('Error deleteCandidateList: ' + ex.getMessage());
        }
    }
    
     @AuraEnabled(cacheable=true)
    public static String checkButtonVisibility(Id jobId){
        String showButtons = 'true';
        List<Work_Request__c> workrequestsLinkedToJob = new List<Work_Request__c>();
        workrequestsLinkedToJob = [select id from Work_Request__c where Job__c=:jobId or Job_Id_System_Used__c=:jobId];
        if(workrequestsLinkedToJob.size()>0){
            showButtons = 'false';
        }
        System.debug('Inside Apex '+workrequestsLinkedToJob.size());
        System.debug('Inside Apex '+showButtons);
        return showButtons;
    }
    
    @AuraEnabled
    public static String uploadBannerImage(Id jobId, String fileName, String base64Data) {
        if (jobId == null || base64Data == null) {
            throw new AuraHandledException('Invalid parameters.');
        }

        // Convert Base64 to Blob
        Blob fileBlob = EncodingUtil.base64Decode(base64Data);

        // Create ContentVersion record (stores the file in Salesforce)
        ContentVersion content = new ContentVersion();
        content.Title = fileName;
        content.PathOnClient = '/' + fileName;
        content.VersionData = fileBlob;
        content.FirstPublishLocationId = jobId; // Associate with Job__c
        insert content;

        // Fetch ContentDocumentId to store in Job__c
        ContentVersion newVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id LIMIT 1];

        // Update Job__c record with file reference
        Job__c job = [SELECT Id FROM Job__c WHERE Id = :jobId LIMIT 1];
        job.BannerImage__c = newVersion.ContentDocumentId;
        update job;

        return newVersion.ContentDocumentId;
    }
    
}
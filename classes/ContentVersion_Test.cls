@isTest(seeAllData = true)
public class ContentVersion_Test {
    @isTest
    public static void afterInsert(){
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Job__c job = new Job__c();
        job.Account__c = accountRecord.Id;
        job.MS_Line_of_Business__c = 'Talent Management';
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.InternalContact__c = UserInfo.getUserId();
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = 'QA01';
        job.ShortFall_Manager__c = 1;
        job.Shortfall_Peer__c = 2;
        job.Shortfall_Subordinate__c = 3;
        job.ShortFall_Customer__c = 2;
        job.Shortfall_Client__c = 2;
        job.ShortFall_Other__c = 2;
        job.PurchaseOrderNo__c='rtertr';
        job.Generic_BS_Field_One__c='Bureau Service';
        job.Generic_Field_MS_One__c='Managed Service';
        job.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        job.Is_Redirect_To_Task__c=true;
        job.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        job.System_Used__c ='SHL ONLINE';
        job.RecordTypeId = RecordTypeIdJob2;
        job.Do_Not_Send_Survey__c = True;
        job.Preferred_Language__c = 'English';
        job.Job_Region__c = 'Non China';
        insert job;
        
        ContentVersion cv = new ContentVersion();
        String encoded = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded =  EncodingUtil.urlDecode(encoded,'UTF-8');
        cv.VersionData = Blob.valueOf('\uFEFF'+decoded);
        cv.Title = '_CandidateImportSheet';
        cv.PathOnClient = 'test';
        System.debug('Content Version cv '+cv);
        insert cv;
        
       ContentDocumentLink cdl = new ContentDocumentLink();
       cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.id].ContentDocumentId;
       cdl.LinkedEntityId = job.id;
       cdl.ShareType = 'V';
       insert cdl;
        
        ContentVersion cv2 = new ContentVersion();
        String encoded1 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded1=  EncodingUtil.urlDecode(encoded1,'UTF-8');
        cv2.VersionData = Blob.valueOf('\uFEFF'+decoded1);
        cv2.Title = '_CandidateUpdateSheet';
        cv2.PathOnClient = 'test';
        System.debug('Content Version cv '+cv2);
        insert cv2;
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv2.id].ContentDocumentId;
        cdl2.LinkedEntityId = job.id;
        cdl2.ShareType = 'V';
        insert cdl2;
        
        //Work_Request__c submittedRequest = [select id from Work_Request__c where Work_Request_Type__c='Client Submitted' limit 1]; 
        ContentVersion cv4 = new ContentVersion();
        String encoded3 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded3=  EncodingUtil.urlDecode(encoded3,'UTF-8');
        cv4.VersionData = Blob.valueOf('\uFEFF'+decoded3);
        cv4.Title = '_CandidateWRFUpdateSheet';
        cv4.PathOnClient = 'test';
        System.debug('Content Version cv '+cv4);
        insert cv4;
        
        ContentDocumentLink cdl4 = new ContentDocumentLink();
        cdl4.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv4.id].ContentDocumentId;
        cdl4.LinkedEntityId = job.id;
        cdl4.ShareType = 'V';
        insert cdl4;
        
        ContentVersion cv5 = new ContentVersion();
        String encoded4 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded4=  EncodingUtil.urlDecode(encoded4,'UTF-8');
        cv5.VersionData = Blob.valueOf('\uFEFF'+decoded4);
        cv5.Title = '_PlatformWRFUpdateSheet';
        cv5.PathOnClient = 'test';
        System.debug('Content Version cv '+cv5);
        insert cv5;
        
        ContentDocumentLink cdl5 = new ContentDocumentLink();
        cdl5.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv5.id].ContentDocumentId;
        cdl5.LinkedEntityId = job.id;
        cdl5.ShareType = 'V';
        insert cdl5;
        
        Test.stopTest();
        //Work_Request__c generatedRequest = [select id from Work_Request__c where Work_Request_Type__c='MS Generated' limit 1];
        ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = '_CandidateWRFImportSheet';
        cv3.PathOnClient = 'test';
        System.debug('Content Version cv '+cv3);
        insert cv3;
        
       
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(accountRecord.Id, job.Id);
        Work_Request__c submittedRequest = TestDataUtility.getSubmittedWRF(generatedRequest.Id,cv3.Id);
        ContentDocumentLink cdl3 = new ContentDocumentLink();
        cdl3.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv3.id].ContentDocumentId;
        cdl3.LinkedEntityId = submittedRequest.Id;
        cdl3.ShareType = 'V';
        insert cdl3;
        
        
    }
    
    @isTest
    public static void testCancellationFilesOnOpportunity(){
        
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity oppRecord = TestDataUtility.getOpportunity(accountRecord.Id,contactRecord.Id);
        oppRecord.Business_Type__c='Renewal';
        INSERT oppRecord;
        oppRecord.StageName = 'Closed Lost';
        oppRecord.Closed_Lost_Reason__c = 'Budget Limitations';
        Update oppRecord;
        
        List<sobject> objectsToInsert = new List<sobject>();
        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('Testing file');
        cv.Title = 'CancellationFile';
        cv.PathOnClient = 'test';
        insert cv;
        
       ContentDocumentLink cdl = new ContentDocumentLink();
       cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.id].ContentDocumentId;
       cdl.LinkedEntityId = oppRecord.id;
       cdl.ShareType = 'V';
       insert cdl;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.VersionData = Blob.valueOf('Testing File');
        cv2.Title = 'RescindFile';
        cv2.PathOnClient = 'test';
       insert cv2;
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv2.id].ContentDocumentId;
        cdl2.LinkedEntityId = oppRecord.id;
        cdl2.ShareType = 'V';
        insert cdl2;
        
        list<ContentVersion> conVer = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id or Id=:cv2.Id];
        Map<Id,Contentversion> ContentVersionMap = new Map<Id,Contentversion>();
        ContentVersionMap.put(conVer[0].Id, conVer[0]);
        ContentVersionMap.put(conVer[1].Id, conVer[1]);
        Test.startTest();
        ContentVersionTriggerHandler.CancellationFilesOnOpportunity(ContentVersionMap);
        Test.stopTest();
    } 

  //Added by Prachi --SSE-21436  
    @isTest
    public static void testavoidChangeDescription(){
         test.startTest();
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft');
        insert ap;
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.Title = 'Test CV';
        cv.PathOnClient = 'Test CV' + '.pdf';
        cv.SharingPrivacy = 'N' ;
        cv.SharingOption = 'A';
        cv.IsMajorVersion = true;  
        cv.FirstPublishLocationId = ap.id;
        cv.VersionData = Blob.valueOf('Testing File');
        cv.Description = 'This is an autogenerated PDF for Account Plan.';   
        insert cv;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.id = cv.id;
        cv2.Description ='';
        try{
        update cv2;
        }catch(Exception ex){
            system.assert(ex.getMessage().contains('This is an auto generated PDF. You can not update its description'));
        }
         test.stopTest();
    }
    
     //Added by Prachi --SSE-21596 
    @isTest
    public static void testavoidChangeDescriptionForCSV(){
         test.startTest();
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft');
        insert ap;
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.Title = 'Test CV';
        cv.PathOnClient = 'Test CV' + '.csv';
        cv.SharingPrivacy = 'N' ;
        cv.SharingOption = 'A';
        cv.IsMajorVersion = true;  
        cv.FirstPublishLocationId = ap.id;
        cv.VersionData = Blob.valueOf('Testing File');
        cv.Description = 'This is an autogenerated csv for Uploaded Contacts.';   
        insert cv;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.id = cv.id;
        cv2.Description ='';
        try{
        update cv2;
        }catch(Exception ex){
            system.assert(ex.getMessage().contains('This is an auto generated CSV. You can not update its description'));
        }
         test.stopTest();
    }
}
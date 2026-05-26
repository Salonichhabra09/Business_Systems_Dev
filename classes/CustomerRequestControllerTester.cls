@isTest(seeAllData = true)
public class CustomerRequestControllerTester {
    
    
    @isTest
    public static void methodsTester(){
        Metadata_API_Setting__c setting = new Metadata_API_Setting__c();
        setting.Name = 'Metadata';
        setting.Consumer_Key__c = 'test_client_id';
        setting.Consumer_Secret__c = 'test_client_secret';
        //insert setting;

        
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Name = 'account1 crc';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Managed Service Lightning' LIMIT 1];
        User usrRecCps = new user();
        usrRecCps.LastName = 'Test Code1806190';
        usrRecCps.Email = 'test@testCode1806190.com';
        usrRecCps.Alias = 'Tcode';
        usrRecCps.Username = 'test1234444Code1806190@test.com';        
        usrRecCps.LocaleSidKey = 'en_US';
        usrRecCps.TimeZoneSidKey = 'GMT';
        usrRecCps.ProfileId = profileId.Id;
        usrRecCps.LanguageLocaleKey = 'en_US';
        usrRecCps.EmailEncodingKey = 'UTF-8';
        usrRecCps.MS_LOB__c ='Talent Management';
        usrRecCps.IsActive=true;
        usrRecCps.Is_Managed_Service_Manager__c=true;
        insert usrRecCps;
        
        Opportunity opportunity = TestDataUtility.getOpportunity(accountRecord.Id, contactRecord.Id);
        insert opportunity;
        
        Job__c jobRecord = new Job__c();
        jobRecord.Account__c = accountrecord.id;
        jobRecord.Project_Manager__c = usrRecCps.Id;
        jobRecord.Opportunity__c = opportunity.id;
        jobRecord.MS_Line_of_Business__c = 'Talent Management';
        jobRecord.Job_Type__c = 'Project - 360';
        jobRecord.Start_Date__c = System.today();
        jobRecord.End_Date__c = System.today().addDays(30);
        jobRecord.InternalContact__c = UserInfo.getUserId();
        jobRecord.External_Contact_Others__c = 'External Contact';
        jobRecord.External_Contact_Other_Email_Address__c='test@test.com';
        jobRecord.Candidate_Username_Prefix__c = 'QA01';
        jobRecord.ShortFall_Manager__c = 1;
        jobRecord.Shortfall_Peer__c = 2;
        jobRecord.Shortfall_Subordinate__c = 3;
        jobRecord.ShortFall_Customer__c = 2;
        jobRecord.Shortfall_Client__c = 2;
        jobRecord.ShortFall_Other__c = 2;
        jobRecord.PurchaseOrderNo__c='rtertr';
        jobRecord.Generic_BS_Field_One__c='Bureau Service';
        jobRecord.Generic_Field_MS_One__c='Managed Service';
        jobRecord.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        jobRecord.Is_Redirect_To_Task__c=true;
        jobRecord.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        jobRecord.System_Used__c ='SHL ONLINE';
        jobRecord.RecordTypeId = RecordTypeIdJob2;
        jobRecord.Do_Not_Send_Survey__c = True;
        jobRecord.Preferred_Language__c = 'English';
        jobRecord.Job_Region__c = 'Non China';
        jobRecord.Sender_Email__c = 'noreply@shl.com';
        jobRecord.Client_Domain__c = 'test.com';
        jobRecord.Billing_Cycle_Start_Date__c = Date.Today();
        insert jobRecord;
        
        ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = '_CandidateWRFImportSheet';
        cv3.PathOnClient = 'test';
        System.debug('Content Version cv '+cv3);
        insert cv3;
        
        
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(accountRecord.Id, jobRecord.Id);
        Work_Request__c submittedRequest = TestDataUtility.getSubmittedWRF(generatedRequest.Id,cv3.Id);
        ContentDocumentLink cdl3 = new ContentDocumentLink();
        cdl3.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv3.id].ContentDocumentId;
        cdl3.LinkedEntityId = submittedRequest.Id;
        cdl3.ShareType = 'V';
        insert cdl3;
        accountRecord.Company_Logo_Id__c = cdl3.ContentDocumentId;
        update accountRecord;
        //
        String formDetails = '[{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Name","index":1,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Email","index":2,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Launch Date","index":3,"showHelpTextArea":true,"showEditFields":false,"helpText":"Please allow at least 2 full working days","isRequired":true,"showTextFieldArea":false},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Deadline Date","index":4,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Dates","index":5,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Reminder Dates","index":6,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Name(s)","index":7,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Email address(es)","index":8,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Name(s)","index":9,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Email address(es)","index":10,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"dropdown","isnormal":false,"istextarea":false,"isrichtexarea":false,"ispicklist":true,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Assessment Package","index":12,"showTextFieldArea":false,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true},{"fieldtype":"Textarea","isnormal":false,"istextarea":true,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Additional Instructions (If any)","index":11,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false}]';
        String candidateDetails = '[{"Label__c":"Category","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Category__c","fieldLabel":"Category","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":1,"isReporting":true},{"Label__c":"First Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"First_Name__c","fieldLabel":"First Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":2,"isReporting":true},{"Label__c":"Last Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Last_Name__c","fieldLabel":"Last Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":3,"isReporting":true},{"Label__c":"Email","Data_Type__c":"email","Values__c":"undefined","API_Name__c":"Email__c","fieldLabel":"Email","fieldtype":"email","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":4,"isReporting":true}]';
        String recordId = generatedRequest.Id;
        String fileId = cv3.Id;
        Integer candidateRequestedCount = 10;
        String RequestorName = 'Testing firstname';
        String RequestorEmail = 'Testing@test.com';   
        Integer participantRequestedCount = 10;
        String candidateRequestType = 'Manual';
        //String candidateDataToInsert = null;
        String systemSelected = 'TalentCentral+';
        String textUnderLogo = 'Testing';
        String wrfClientName = 'Test Class';
        String Solution = null;
        String candidateInstruction = 'Testing';
        
        string candidateDataToInsert = '[{"Category__c":"Self","First_Name__c":"Record1 ","Last_Name__c":"Record1","Email__c":"record1@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"},{"Category__c":"Manager","First_Name__c":"Record2","Last_Name__c":"Record2","Email__c":"record2@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"}]';
        String RatingJson = '[{"Category":"Self","Email":"record1@test.com","Recipient_Email":"record1@test.com"}]';
        String updateRatingJson = '[{"Category":"Self","Email":"record1@test.com","Recipient_Email":"record1@test.com", "VADC_Status__c":"In Progress", "TC_Status__c":"In Progress", "Insights_Status__c":"In Progress","MFS_status__c":"In Progress" }]';
        Date deadlineDate = Date.today();
        CustomerRequestController.getCustomerRequest(submittedRequest.Id);
        CustomerRequestController.createSubmitRequest(formDetails, recordId, fileId, candidateRequestedCount, RequestorName, RequestorEmail, candidateDataToInsert, candidateRequestType, participantRequestedCount, deadlineDate);
        //CustomerRequestController.createCustomerRequestFromCustomForm(formDetails, accountrecord.Id, candidateDetails, systemSelected, jobRecord.Id, textUnderLogo, wrfClientName, Solution, candidateInstruction);	
        Test.startTest();
        CustomerRequestController.authenticateContact(RequestorName, RequestorEmail, generatedRequest.Id);
        CustomerRequestController.getRecentCRF(accountRecord.Id,'TalentCentral+' );
        CustomerRequestController.getRecentCRF(accountRecord.Id,'');
        CustomerRequestController.getRecentCRFCandidate(accountRecord.Id,'TalentCentral+' );
        CustomerRequestController.getRecentCRFCandidate(accountRecord.Id,'');
        CustomerRequestController.relatedFiles(accountRecord.Id);
        CustomerRequestController.relatedFilesWire(accountRecord.Id);
        CustomerRequestController.getAccountId(generatedRequest.Id);
        //CustomerRequestController.uploadFile(cv3.Id,accountRecord.Id);
        CustomerRequestController.handleCandidateComponentVisibility(jobRecord.Id);
        CustomerRequestController.getWRFAndJobData(submittedRequest.Id);
        CustomerRequestController.getJobData(generatedRequest.Id);
        //aCustomerRequestController.getJobStatus(submittedRequest.Id);
        CustomerRequestController.checkButtonVisibility(jobRecord.Id);
        CustomerRequestController.createCandidates(candidateDataToInsert, submittedRequest.Id, jobRecord.Id,false);
        CustomerRequestController.updateCandidatesToLinkJob(jobRecord.Id, submittedRequest.Id, deadlineDate);
        CustomerRequestController.getCandidateCount(jobRecord.Id,'Id');
        CustomerRequestController.getRatingsCount(jobRecord.Id,'Id','Rating');
        CustomerRequestController.createRatings(RatingJson,jobRecord.Id ,submittedRequest.Id , false, deadlineDate);
        
        
        
        CustomerRequestController.getMasterViewData('Id', jobRecord.Id);
        //CustomerRequestController.updateRating(RatingJson, jobRecord.Id);
        CustomerRequestController.getListOfSolutions(opportunity.Id);
        CustomerRequestController.uploadBannerImage(jobRecord.Id, 'test.png', 'abcd');
        /*List<String> fieldList = new List<String>();
        fieldList.add('Last_Name__c');
        CustomerRequestController.updateCandidates(candidateDataToInsert, fieldList);
        CustomerRequestController.deleteCandidateList(submittedRequest.Id);*/
        Test.stopTest();
    }
    
    @isTest
    public static void methodsTester1(){
        Metadata_API_Setting__c setting = new Metadata_API_Setting__c();
        setting.Name = 'Metadata';
        setting.Consumer_Key__c = 'test_client_id';
        setting.Consumer_Secret__c = 'test_client_secret';
        //insert setting;

        
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Name = 'account2 crc';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Managed Service Lightning' LIMIT 1];
        User usrRecCps = new user();
        usrRecCps.LastName = 'Test Code1806190';
        usrRecCps.Email = 'test@testCode1806190.com';
        usrRecCps.Alias = 'Tcode';
        usrRecCps.Username = 'test1234444Code1806190@test.com';        
        usrRecCps.LocaleSidKey = 'en_US';
        usrRecCps.TimeZoneSidKey = 'GMT';
        usrRecCps.ProfileId = profileId.Id;
        usrRecCps.LanguageLocaleKey = 'en_US';
        usrRecCps.EmailEncodingKey = 'UTF-8';
        usrRecCps.MS_LOB__c ='Talent Management';
        usrRecCps.IsActive=true;
        usrRecCps.Is_Managed_Service_Manager__c=true;
        insert usrRecCps;
        
        Opportunity opportunity = TestDataUtility.getOpportunity(accountRecord.Id, contactRecord.Id);
        insert opportunity;
        
        Job__c jobRecord = new Job__c();
        jobRecord.Account__c = accountrecord.id;
        jobRecord.Project_Manager__c = usrRecCps.Id;
        jobRecord.Opportunity__c = opportunity.id;
        jobRecord.MS_Line_of_Business__c = 'Talent Management';
        jobRecord.Job_Type__c = 'Project - 360';
        jobRecord.Start_Date__c = System.today();
        jobRecord.End_Date__c = System.today().addDays(30);
        jobRecord.InternalContact__c = UserInfo.getUserId();
        jobRecord.External_Contact_Others__c = 'External Contact';
        jobRecord.External_Contact_Other_Email_Address__c='test@test.com';
        jobRecord.Candidate_Username_Prefix__c = 'QA01';
        jobRecord.ShortFall_Manager__c = 1;
        jobRecord.Shortfall_Peer__c = 2;
        jobRecord.Shortfall_Subordinate__c = 3;
        jobRecord.ShortFall_Customer__c = 2;
        jobRecord.Shortfall_Client__c = 2;
        jobRecord.ShortFall_Other__c = 2;
        jobRecord.PurchaseOrderNo__c='rtertr';
        jobRecord.Generic_BS_Field_One__c='Bureau Service';
        jobRecord.Generic_Field_MS_One__c='Managed Service';
        jobRecord.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        jobRecord.Is_Redirect_To_Task__c=true;
        jobRecord.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        jobRecord.System_Used__c ='SHL ONLINE';
        jobRecord.RecordTypeId = RecordTypeIdJob2;
        jobRecord.Do_Not_Send_Survey__c = True;
        jobRecord.Preferred_Language__c = 'English';
        jobRecord.Job_Region__c = 'Non China';
        jobRecord.Sender_Email__c = 'noreply@shl.com';
        jobRecord.Client_Domain__c = 'test.com';
        jobRecord.Billing_Cycle_Start_Date__c = Date.Today();
        insert jobRecord;
        
        ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = '_ImportSheet';
        cv3.PathOnClient = 'test';
        System.debug('Content Version cv '+cv3);
        insert cv3;
        
        
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(accountRecord.Id, jobRecord.Id);
        Work_Request__c submittedRequest = TestDataUtility.getSubmittedWRF(generatedRequest.Id,cv3.Id);
        ContentDocumentLink cdl3 = new ContentDocumentLink();
        String formDetails = '[{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Name","index":1,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Email","index":2,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Launch Date","index":3,"showHelpTextArea":true,"showEditFields":false,"helpText":"Please allow at least 2 full working days","isRequired":true,"showTextFieldArea":false},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Deadline Date","index":4,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Dates","index":5,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Reminder Dates","index":6,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Name(s)","index":7,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Email address(es)","index":8,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Name(s)","index":9,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Email address(es)","index":10,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"dropdown","isnormal":false,"istextarea":false,"isrichtexarea":false,"ispicklist":true,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Assessment Package","index":12,"showTextFieldArea":false,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true},{"fieldtype":"Textarea","isnormal":false,"istextarea":true,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Additional Instructions (If any)","index":11,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false}]';
        String candidateDetails = '[{"Label__c":"Category","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Category__c","fieldLabel":"Category","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":1,"isReporting":true},{"Label__c":"First Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"First_Name__c","fieldLabel":"First Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":2,"isReporting":true},{"Label__c":"Last Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Last_Name__c","fieldLabel":"Last Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":3,"isReporting":true},{"Label__c":"Email","Data_Type__c":"email","Values__c":"undefined","API_Name__c":"Email__c","fieldLabel":"Email","fieldtype":"email","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":4,"isReporting":true}]';
        
        Test.startTest();
        string candidateDataToInsert = '[{"Category__c":"Self","First_Name__c":"Record1 ","Last_Name__c":"Record1","Email__c":"record1@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"},{"Category__c":"Manager","First_Name__c":"Record2","Last_Name__c":"Record2","Email__c":"record2@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"}]';
        String RatingJson = '[{"Category":"Self","Email":"record1@test.com","Recipient_Email":"record1@test.com"}]';
        List<String> fieldList = new List<String>();
        fieldList.add('Last_Name__c');
        CustomerRequestController.updateCandidates(candidateDataToInsert, fieldList);
        CustomerRequestController.updateRating(RatingJson, jobRecord.Id);
        CustomerRequestController.deleteCandidateList(submittedRequest.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void accessTokenTester(){
        Metadata_API_Setting__c setting = new Metadata_API_Setting__c();
        setting.Name = 'Metadata';
        setting.Consumer_Key__c = 'test_client_id';
        setting.Consumer_Secret__c = 'test_client_secret';
        //insert setting;

        
        System.Test.setMock(HttpCalloutMock.class, new HttpCalloutMockAccessToken());
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Name = 'account3 crc';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Managed Service Lightning' LIMIT 1];
        User usrRecCps = new user();
        usrRecCps.LastName = 'Test Code1806190';
        usrRecCps.Email = 'test@testCode1806190.com';
        usrRecCps.Alias = 'Tcode';
        usrRecCps.Username = 'test1234444Code1806190@test.com';        
        usrRecCps.LocaleSidKey = 'en_US';
        usrRecCps.TimeZoneSidKey = 'GMT';
        usrRecCps.ProfileId = profileId.Id;
        usrRecCps.LanguageLocaleKey = 'en_US';
        usrRecCps.EmailEncodingKey = 'UTF-8';
        usrRecCps.MS_LOB__c ='Talent Management';
        usrRecCps.IsActive=true;
        usrRecCps.Is_Managed_Service_Manager__c=true;
        insert usrRecCps;
        
        Opportunity opportunity = TestDataUtility.getOpportunity(accountRecord.Id, contactRecord.Id);
        Job__c jobRecord = new Job__c();
        jobRecord.Account__c = accountrecord.id;
        jobRecord.Project_Manager__c = usrRecCps.Id;
        jobRecord.Opportunity__c = opportunity.id;
        jobRecord.MS_Line_of_Business__c = 'Talent Management';
        jobRecord.Job_Type__c = 'Project - 360';
        jobRecord.Start_Date__c = System.today();
        jobRecord.End_Date__c = System.today().addDays(30);
        jobRecord.InternalContact__c = UserInfo.getUserId();
        jobRecord.External_Contact_Others__c = 'External Contact';
        jobRecord.External_Contact_Other_Email_Address__c='test@test.com';
        jobRecord.Candidate_Username_Prefix__c = 'QA01';
        jobRecord.ShortFall_Manager__c = 1;
        jobRecord.Shortfall_Peer__c = 2;
        jobRecord.Shortfall_Subordinate__c = 3;
        jobRecord.ShortFall_Customer__c = 2;
        jobRecord.Shortfall_Client__c = 2;
        jobRecord.ShortFall_Other__c = 2;
        jobRecord.PurchaseOrderNo__c='rtertr';
        jobRecord.Generic_BS_Field_One__c='Bureau Service';
        jobRecord.Generic_Field_MS_One__c='Managed Service';
        jobRecord.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        jobRecord.Is_Redirect_To_Task__c=true;
        jobRecord.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        jobRecord.System_Used__c ='SHL ONLINE';
        jobRecord.RecordTypeId = RecordTypeIdJob2;
        jobRecord.Do_Not_Send_Survey__c = True;
        jobRecord.Preferred_Language__c = 'English';
        jobRecord.Job_Region__c = 'Non China';
        jobRecord.Sender_Email__c = 'noreply@shl.com';
        jobRecord.Client_Domain__c = 'test.com';
        jobRecord.Billing_Cycle_Start_Date__c = Date.Today();
        insert jobRecord;
        
        ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = '_CandidateWRFImportSheet';
        cv3.PathOnClient = 'test';
        System.debug('Content Version cv '+cv3);
        insert cv3;
        
        
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(accountRecord.Id, jobRecord.Id);
        Work_Request__c submittedRequest = TestDataUtility.getSubmittedWRF(generatedRequest.Id,cv3.Id);
        ContentDocumentLink cdl3 = new ContentDocumentLink();
        cdl3.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv3.id].ContentDocumentId;
        cdl3.LinkedEntityId = submittedRequest.Id;
        cdl3.ShareType = 'V';
        insert cdl3;
        accountRecord.Company_Logo_Id__c = cdl3.ContentDocumentId;
        update accountRecord;
        
        String formDetails = '[{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Name","index":1,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Email","index":2,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Launch Date","index":3,"showHelpTextArea":true,"showEditFields":false,"helpText":"Please allow at least 2 full working days","isRequired":true,"showTextFieldArea":false},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Deadline Date","index":4,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Dates","index":5,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Reminder Dates","index":6,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Name(s)","index":7,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Email address(es)","index":8,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Name(s)","index":9,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Email address(es)","index":10,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"dropdown","isnormal":false,"istextarea":false,"isrichtexarea":false,"ispicklist":true,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Assessment Package","index":12,"showTextFieldArea":false,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true},{"fieldtype":"Textarea","isnormal":false,"istextarea":true,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Additional Instructions (If any)","index":11,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false}]';
        String candidateDetails = '[{"Label__c":"Category","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Category__c","fieldLabel":"Category","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":1,"isReporting":true},{"Label__c":"First Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"First_Name__c","fieldLabel":"First Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":2,"isReporting":true},{"Label__c":"Last Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Last_Name__c","fieldLabel":"Last Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":3,"isReporting":true},{"Label__c":"Email","Data_Type__c":"email","Values__c":"undefined","API_Name__c":"Email__c","fieldLabel":"Email","fieldtype":"email","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":4,"isReporting":true}]';
        String recordId = generatedRequest.Id;
        String fileId = cv3.Id;
        Integer candidateRequestedCount = 10;
        String RequestorName = 'Testing firstname';
        String RequestorEmail = 'Testing@test.com';   
        Integer participantRequestedCount = 10;
        String candidateRequestType = 'Manual';
        //String candidateDataToInsert = null;
        String systemSelected = 'TalentCentral+';
        String textUnderLogo = 'Testing';
        String wrfClientName = 'Test Class';
        String Solution = null;
        String candidateInstruction = 'Testing';
        Test.startTest();
        string candidateDataToInsert = '[{"Category__c":"Self","First_Name__c":"Record1 ","Last_Name__c":"Record1","Email__c":"record1@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"},{"Category__c":"Manager","First_Name__c":"Record2","Last_Name__c":"Record2","Email__c":"record2@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"}]';
        String RatingJson = '[{"Category":"Self","Email":"record1@test.com","Recipient_Email":"record1@test.com"}]';
        CustomerRequestController.createQueryJob('Id', jobRecord.Id, 'Candidate');
        CustomerRequestController.createQueryJob('Id', jobRecord.Id, 'Bureau_Rating__c');
        String queryJobId =  CustomerRequestController.createQueryJobToGetCandidateDataForMasterView('Id',jobRecord.Id);
        CustomerRequestController.getQueryStatus(queryJobId);
        CustomerRequestController.getQueryData(queryJobId);  
        Test.stopTest();
    }
    
    @isTest
    public static void RepetableGCSCTester(){
        Metadata_API_Setting__c setting = new Metadata_API_Setting__c();
        setting.Name = 'Metadata';
        setting.Consumer_Key__c = 'test_client_id';
        setting.Consumer_Secret__c = 'test_client_secret';
        //insert setting;

        
        System.Test.setMock(HttpCalloutMock.class, new CandidateUploadControllerMock());
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Name = 'account4 crc';
        accountRecord.Is_Repeatable_Business__C = true;
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        contactRecord.Email = 'Testing@valid.com';
        INSERT contactRecord;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Managed Service Lightning' LIMIT 1];
        User usrRecCps = new user();
        usrRecCps.LastName = 'Test Code1806190';
        usrRecCps.Email = 'test@testCode1806190.com';
        usrRecCps.Alias = 'Tcode';
        usrRecCps.Username = 'test1234444Code1806190@test.com';        
        usrRecCps.LocaleSidKey = 'en_US';
        usrRecCps.TimeZoneSidKey = 'GMT';
        usrRecCps.ProfileId = profileId.Id;
        usrRecCps.LanguageLocaleKey = 'en_US';
        usrRecCps.EmailEncodingKey = 'UTF-8';
        usrRecCps.MS_LOB__c ='Talent Management';
        usrRecCps.IsActive=true;
        usrRecCps.Is_Managed_Service_Manager__c=true;
        insert usrRecCps;
        
        Opportunity opportunity = TestDataUtility.getOpportunity(accountRecord.Id, contactRecord.Id);
        opportunity.RecordTypeId = System.label.GCSCRecordType;
        insert opportunity;
        Job__c jobRecord = new Job__c();
        jobRecord.Account__c = accountrecord.id;
        jobRecord.Project_Manager__c = usrRecCps.Id;
        jobRecord.Opportunity__c = opportunity.id;
        jobRecord.MS_Line_of_Business__c = 'Talent Management';
        jobRecord.Job_Type__c = 'Project - 360';
        jobRecord.Start_Date__c = System.today();
        jobRecord.End_Date__c = System.today().addDays(30);
        jobRecord.InternalContact__c = UserInfo.getUserId();
        jobRecord.External_Contact_Others__c = 'External Contact';
        jobRecord.External_Contact_Other_Email_Address__c='test@test.com';
        jobRecord.Candidate_Username_Prefix__c = 'QA01';
        jobRecord.ShortFall_Manager__c = 1;
        jobRecord.Shortfall_Peer__c = 2;
        jobRecord.Shortfall_Subordinate__c = 3;
        jobRecord.ShortFall_Customer__c = 2;
        jobRecord.Shortfall_Client__c = 2;
        jobRecord.ShortFall_Other__c = 2;
        jobRecord.PurchaseOrderNo__c='rtertr';
        jobRecord.Generic_BS_Field_One__c='Bureau Service';
        jobRecord.Generic_Field_MS_One__c='Managed Service';
        jobRecord.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        jobRecord.Is_Redirect_To_Task__c=true;
        jobRecord.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        jobRecord.System_Used__c ='SHL ONLINE';
        jobRecord.RecordTypeId = RecordTypeIdJob2;
        jobRecord.Do_Not_Send_Survey__c = True;
        jobRecord.Preferred_Language__c = 'English';
        jobRecord.Job_Region__c = 'Non China';
        jobRecord.Sender_Email__c = 'noreply@shl.com';
        jobRecord.Client_Domain__c = 'test.com';
        jobRecord.Billing_Cycle_Start_Date__c = Date.Today()-45;
        jobRecord.Billing_Cycle_End_Date__c = Date.Today()-1;
        insert jobRecord;
        
        ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = '_CandidateWRFImportSheet';
        cv3.PathOnClient = 'test';
        System.debug('Content Version cv '+cv3);
        insert cv3;
        
        Test.startTest();
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(accountRecord.Id, jobRecord.Id);
        Work_Request__c submittedRequest = TestDataUtility.getSubmittedWRF(generatedRequest.Id,cv3.Id);
        ContentDocumentLink cdl3 = new ContentDocumentLink();
        cdl3.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv3.id].ContentDocumentId;
        cdl3.LinkedEntityId = submittedRequest.Id;
        cdl3.ShareType = 'V';
        insert cdl3;
        accountRecord.Company_Logo_Id__c = cdl3.ContentDocumentId;
        update accountRecord;
        
        String formDetails = '[{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Name","index":1,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Requester Email","index":2,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false,"isMandatory":true},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Launch Date","index":3,"showHelpTextArea":true,"showEditFields":false,"helpText":"Please allow at least 2 full working days","isRequired":true,"showTextFieldArea":false},{"fieldtype":"date","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Deadline Date","index":4,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Dates","index":5,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Reminder Dates","index":6,"showHelpTextArea":true,"showEditFields":false,"helpText":"Date Format - DD/MM/YYYY","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Name(s)","index":7,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Progress Report Recipient Email address(es)","index":8,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Name(s)","index":9,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"text","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Report Recipient Email address(es)","index":10,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false},{"fieldtype":"dropdown","isnormal":false,"istextarea":false,"isrichtexarea":false,"ispicklist":true,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Assessment Package","index":12,"showTextFieldArea":false,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true},{"fieldtype":"Textarea","isnormal":false,"istextarea":true,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"issection":false,"fieldLabel":"Additional Instructions (If any)","index":11,"showHelpTextArea":true,"showEditFields":false,"helpText":"","isRequired":true,"showTextFieldArea":false}]';
        String candidateDetails = '[{"Label__c":"Category","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Category__c","fieldLabel":"Category","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":1,"isReporting":true},{"Label__c":"First Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"First_Name__c","fieldLabel":"First Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":2,"isReporting":true},{"Label__c":"Last Name","Data_Type__c":"text","Values__c":"undefined","API_Name__c":"Last_Name__c","fieldLabel":"Last Name","fieldtype":"text","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":3,"isReporting":true},{"Label__c":"Email","Data_Type__c":"email","Values__c":"undefined","API_Name__c":"Email__c","fieldLabel":"Email","fieldtype":"email","value":"undefined","isnormal":true,"istextarea":false,"isrichtexarea":false,"ispicklist":false,"ischeckboxgroup":false,"isradiogroup":false,"index":4,"isReporting":true}]';
        String recordId = generatedRequest.Id;
        String fileId = cv3.Id;
        Integer candidateRequestedCount = 10;
        String RequestorName = 'Testing firstname';
        String RequestorEmail = 'Testing@test.com';   
        Integer participantRequestedCount = 10;
        String candidateRequestType = 'Manual';
        //String candidateDataToInsert = null;
        String systemSelected = 'TalentCentral+';
        String textUnderLogo = 'Testing';
        String wrfClientName = 'Test Class';
        String Solution = 'Graduate Essential';
        String candidateInstruction = 'Testing';
        
        string candidateDataToInsert = '[{"Category__c":"Self","First_Name__c":"Record1 ","Last_Name__c":"Record1","Email__c":"record1@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"},{"Category__c":"Manager","First_Name__c":"Record2","Last_Name__c":"Record2","Email__c":"record2@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"}]';
        String RatingJson = '[{"Category":"Self","Email":"record1@test.com","Recipient_Email":"record1@test.com"}]';
        
        Pricebook2 PR1 = [Select Id, Name, IsActive From Pricebook2 where name='Configurator Price Book' limit 1];
        Product2 MSProd =[select id from Product2 where IsActive=true and ms_product__c=true limit 1];
        PricebookEntry PE2 =[Select id,IsActive,CurrencyIsoCode from PricebookEntry where IsActive=true and CurrencyIsoCode = 'GBP' and Pricebook2Id =:PR1.id  and Product2Id=:MSProd.id limit 1];
        List<OpportunityLineItem> OLIsToadd = new List<OpportunityLineItem>();
        OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity.id,Platform__c='MFS',Usage_Allowance__c='Uncapped',Total_Equivalent_Units__c=10,CurrencyChange__c = false,Package__c = 'Graduate Essential',RenewableNew__c = 'Ongoing',PricebookEntryId=PE2.id,UnitPrice=100,Quantity=1,Start_Date__c= system.today(),End_Date__c=system.today()+1,Solution_Cap__c = 1);
        OLIsToadd.add(LI);
        insert OLIsToadd;
        Date deadlineDate = Date.today();
        CustomerRequestController.createSubmitRequest(formDetails, recordId, fileId, candidateRequestedCount, RequestorName, RequestorEmail, candidateDataToInsert, candidateRequestType, participantRequestedCount, deadlineDate);
        CustomerRequestController.getListOfSolutions(opportunity.id);
        CustomerRequestController.createCustomerRequestFromCustomForm(formDetails, accountrecord.Id, candidateDetails, systemSelected, jobRecord.Id, textUnderLogo, wrfClientName, Solution, candidateInstruction);	
        
        Test.stopTest();
    }
    
    @isTest
    public static void ratingDeletion(){
        
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Name = 'account5 crc';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Managed Service Lightning' LIMIT 1];
        User usrRecCps = new user();
        usrRecCps.LastName = 'Test Code1806190';
        usrRecCps.Email = 'test@testCode1806190.com';
        usrRecCps.Alias = 'Tcode';
        usrRecCps.Username = 'test1234444Code1806190@test.com';        
        usrRecCps.LocaleSidKey = 'en_US';
        usrRecCps.TimeZoneSidKey = 'GMT';
        usrRecCps.ProfileId = profileId.Id;
        usrRecCps.LanguageLocaleKey = 'en_US';
        usrRecCps.EmailEncodingKey = 'UTF-8';
        usrRecCps.MS_LOB__c ='Talent Management';
        usrRecCps.IsActive=true;
        usrRecCps.Is_Managed_Service_Manager__c=true;
        insert usrRecCps;
        
        Opportunity opportunity = TestDataUtility.getOpportunity(accountRecord.Id, contactRecord.Id);
        insert opportunity;
        
        Job__c jobRecord = new Job__c();
        jobRecord.Account__c = accountrecord.id;
        jobRecord.Project_Manager__c = usrRecCps.Id;
        jobRecord.Opportunity__c = opportunity.id;
        jobRecord.MS_Line_of_Business__c = 'Talent Management';
        jobRecord.Job_Type__c = 'Project - 360';
        jobRecord.Start_Date__c = System.today();
        jobRecord.End_Date__c = System.today().addDays(30);
        jobRecord.InternalContact__c = UserInfo.getUserId();
        jobRecord.External_Contact_Others__c = 'External Contact';
        jobRecord.External_Contact_Other_Email_Address__c='test@test.com';
        jobRecord.Candidate_Username_Prefix__c = 'QA01';
        jobRecord.ShortFall_Manager__c = 1;
        jobRecord.Shortfall_Peer__c = 2;
        jobRecord.Shortfall_Subordinate__c = 3;
        jobRecord.ShortFall_Customer__c = 2;
        jobRecord.Shortfall_Client__c = 2;
        jobRecord.ShortFall_Other__c = 2;
        jobRecord.PurchaseOrderNo__c='rtertr';
        jobRecord.Generic_BS_Field_One__c='Bureau Service';
        jobRecord.Generic_Field_MS_One__c='Managed Service';
        jobRecord.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        jobRecord.Is_Redirect_To_Task__c=true;
        jobRecord.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        jobRecord.System_Used__c ='SHL ONLINE';
        jobRecord.RecordTypeId = RecordTypeIdJob2;
        jobRecord.Do_Not_Send_Survey__c = True;
        jobRecord.Preferred_Language__c = 'English';
        jobRecord.Job_Region__c = 'Non China';
        jobRecord.Sender_Email__c = 'noreply@shl.com';
        jobRecord.Client_Domain__c = 'test.com';
        jobRecord.Billing_Cycle_Start_Date__c = Date.Today();
        insert jobRecord;
        
        ContentVersion cv3 = new ContentVersion();
        String encoded2 = EncodingUtil.urlEncode('Base 64 String', 'UTF-8');
        String decoded2=  EncodingUtil.urlDecode(encoded2,'UTF-8');
        cv3.VersionData = Blob.valueOf('\uFEFF'+decoded2);
        cv3.Title = '_ImportSheet';
        cv3.PathOnClient = 'test';
        System.debug('Content Version cv '+cv3);
        insert cv3;
        
        
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(accountRecord.Id, jobRecord.Id);
        Work_Request__c submittedRequest = TestDataUtility.getSubmittedWRF(generatedRequest.Id,cv3.Id);
        
        string candidateDataToInsert = '[{"Category__c":"Self","First_Name__c":"Record1 ","Last_Name__c":"Record1","Email__c":"record1@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"},{"Category__c":"Manager","First_Name__c":"Record2","Last_Name__c":"Record2","Email__c":"record2@test.com","Product_Assessment__c":"SHL 360","Bureau_Job__c":"'+jobRecord.Id+'","Work_Request__c":"'+submittedRequest.Id+'"}]';
        String RatingJson = '[{"Category":"Self","Email":"record1@test.com","Recipient_Email":"record1@test.com"}]';
        
        CustomerRequestController.createCandidates(candidateDataToInsert, submittedRequest.Id, jobRecord.Id,false);
        Date deadlineDate = Date.today();
        CustomerRequestController.createRatings(RatingJson,jobRecord.Id ,submittedRequest.Id , false, deadlineDate);
        
        Test.startTest();
        CustomerRequestController.deleteCandidateList(submittedRequest.Id);
        Test.stopTest();
    }
    
    
}
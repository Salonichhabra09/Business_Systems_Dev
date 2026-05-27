/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class MasterProgressReportViewTest {
    
    // Test setup method to create required records
    @testSetup
    static void setup() {
        
        Trigger_Activation__c triggerSetting = new Trigger_Activation__c();
        triggerSetting.Name = 'Account_Trigger';
        triggerSetting.Active__c = true; // or false based on what you want to test
        insert triggerSetting;
        
        Trigger_Activation__c contacttriggerSetting = new Trigger_Activation__c();
        contacttriggerSetting.Name = 'Contact_Trigger';
        contacttriggerSetting.Active__c = true; // or false based on what you want to test
        insert contacttriggerSetting;
        
        Trigger_Activation__c opptriggerSetting = new Trigger_Activation__c();
        opptriggerSetting.Name = 'Opportunity_Trigger';
        opptriggerSetting.Active__c = true; // or false based on what you want to test
        insert opptriggerSetting;
        
        Trigger_Activation__c oppcontriggerSetting = new Trigger_Activation__c();
        oppcontriggerSetting.Name = 'OpportunityContactRoleTrigger';
        oppcontriggerSetting.Active__c = true; // or false based on what you want to test
        insert oppcontriggerSetting;
        
        Trigger_Activation__c jobtriggerSetting = new Trigger_Activation__c();
        jobtriggerSetting.Name = 'Job_Trigger';
        jobtriggerSetting.Active__c = true; // or false based on what you want to test
        insert jobtriggerSetting;
        
        // Custom Setting for Auto Job creation
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c();
        cs.Name='Values';
        cs.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        INSERT cs;
        
        //Pricebook2 Master = [Select Id, Name, IsActive From Pricebook2 where Name = 'Configurator Price Book'];
        Product2 Product= new Product2();
        Product.Description='Managed';
        Product.IsActive=True;
        Product.Name='Managed';
        Product.Revenue_Category__c='Training';
        Product.MS_Product__c=true;
        Product.Status__c = 'Revenue Ready';
        Insert Product;
        //PricebookEntry standardPB = new PricebookEntry(Pricebook2Id = '01sD0000000Kh1pIAC',Product2id= Product.id,UnitPrice = 1000,CurrencyIsoCode='GBP', IsActive = true);
        String standardPB ='01s2000000009q8AAA';
        // Create a job record and work request records needed for testing
        Account acc= new Account();
            acc.Name='Test234';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='INDIA';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23';   
            insert acc;
        
        
            Contact contact = new Contact();
            contact.Lastname = 'test';
            contact.AccountId = acc.id;
            contact.Contact_Type__c='Billing Contact';
            contact.Phone='364986324';
            contact.Email='test@test.com';
            contact.Mailing_Address_Line_1__c='test';
            contact.Mailing_City__c='test';
            contact.Mailing_ZIP_Postal_Code__c='ZipCode1';
            contact.Mailing_Country__c='BOLIVIA';
            contact.Same_As_The_Account_Billing_Address__c = true;
            insert contact;
        
            Opportunity opportunity=new Opportunity(name='Test Standard Opportunity', 
            AccountID=acc.id,
            Offering__c='Enterprise Leadership',
            Talent_Level__c='Leader',
            Talent_Segment__c='Volume',
            Client_Business_Function__c='HR');
            opportunity.ownerid=UserInfo.getUserId();
            opportunity.Billing_Contact__c=contact.id;
            opportunity.Closedate=system.today();
            opportunity.Primary_Contact__c=contact.id;
            opportunity.CurrencyIsoCode='GBP';
            opportunity.Unconfirmed_Sun_Order_Number__c='1234';
            opportunity.NVM_Credit_Card_ID__c='1234';
            opportunity.Amount=1000;
            opportunity.Variation_Opportunity__c='NO';
            opportunity.Original_Opportunity__c=null;
            opportunity.Annual_Contract_Value__c=1000.00;
            opportunity.StageName='New';   
            opportunity.GCSC__c='Phone';
            opportunity.OpportunityAmountMappedWithLead__c = 323.34;
            opportunity.OpportunityTypeMappedWithLead__c = 'New Business';
            opportunity.Skip_Validation__c=True;
            opportunity.TM_Phase__c='Mixed';
            opportunity.Package_Level__c='Basic';
            // opportunity.Business_Type__c='Renewal';
            opportunity.RecordTypeId=System.label.GCSCRecordType;
            opportunity.Skip_Validation__c=True;
            opportunity.Eligible_for_Auto_Close__c = false;
            opportunity.Pricebook2Id = standardPB;
            opportunity.Business_Type__c ='Expansion';
            opportunity.Forecast_Category__c = 'Pipeline';
            insert opportunity;
                    

        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Pipeline').getRecordTypeId();
        Id userId = [select id from User where Is_Bureau_Service_Manager__c = true and IsActive = true limit 1].id;
        Job__c job = new Job__c();
        //Task t = new Task(Subject='Abc',Status='Not Started',Priority='Normal',WhatId = job1.id);
       // insert t;
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.Project_Lead__c = userId;    
        job.Opportunity__c = opportunity.Id;
        job.Account__c = acc.Id;
        job.InternalContact__c = UserInfo.getUserId();      
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = '';
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
        job.RecordTypeId = RecordTypeIdJob1;  
        job.MS_Line_of_Business__c='Talent Management';
        job.Job_Region__c='Non China';
        job.Billing_Cycle_Start_Date__c = System.today(); //Mehak Change
       // job.System_Field__c = job1.id;  
        //job.Managed_Services_Pipeline__c = job1.id;
        insert job;
        
        // Set up a custom setting with an encryption key for testing
                
        Work_Request__c wr = new Work_Request__c(
            Job__c = job.Id,
            
            Job_Id_System_Used__c = 'job-system-id',
            Candidate_Field_Configuration__c = 'config-field',
            Work_Request_Type__c = 'Client Submitted'
        );
        insert wr;
        
         Work_Request__c wr2 = new Work_Request__c(
            Job__c = job.Id,
            Job_Id_System_Used__c = 'job-system-id',
            Candidate_Field_Configuration__c = 'config-field',
            Work_Request_Type__c = 'Client Report'
        );
        insert wr2;
        
        
        
        CryptoKeySetting__c setting = new CryptoKeySetting__c();
        setting.SetupOwnerId = UserInfo.getOrganizationId(); // Organization-level setting
        setting.CRYPTO__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256)); // Generate a test key
        insert setting;
        
               
    }
    
    
    @isTest
    static void testDecodeUrlParameter() {
      
        CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
        Blob cryptoKey = EncodingUtil.base64Decode(setting.CRYPTO__c);

        
        String originalRecordId = '001xx000003NGs4AAG'; // Example record ID
        //Blob cryptoKey = EncodingUtil.base64Decode(sampleKey);
        Blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(originalRecordId));
        String encodedRecordId = EncodingUtil.base64Encode(encryptedBlob);

        // Step 3: Call the decodeurlparamater method and verify the result
        Test.startTest();
        String result = MasterProgressReportView.decodeurlparamater(encodedRecordId);
        Test.stopTest();

        // Step 4: Verify that the decoded result matches the original record ID
        System.assertEquals(originalRecordId, result, 'The decrypted record ID should match the original record ID');
    }

    @isTest
    static void testGetWRF() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        String jobSystemId = 'job-system-id';
       
        Test.startTest();
        String wrfId = MasterProgressReportView.getWRF(job.Id);
        Test.stopTest();
        
    }

    @isTest
    static void testGetRecentCRF() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        
        Test.startTest();
        String config = MasterProgressReportView.getRecentCRF(job.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, config, 'Configuration should not be null');
    }

    @isTest
    static void testSendEmailClientReport() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        String selectedFields = 'Test Fields';
        String fieldConfig = 'config-field';
        
        Test.startTest();
        String crvLink = MasterProgressReportView.sendEmailClientReport(selectedFields, job.Id, fieldConfig);
        Test.stopTest();
        
        System.assertNotEquals(null, crvLink, 'Generated link should not be null');
    }

    @isTest
    static void testGetCandidateDataDynamically() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        String soqlQueryList = 'Id';
        Integer offSetValue = 0;
        String filterValue = '';
        
        Test.startTest();
        List<Bureau_Candidate__c> candidates = MasterProgressReportView.getCandidateDataDynamically(soqlQueryList, job.Id, offSetValue, filterValue);
        Test.stopTest();
        
        System.assertNotEquals(null, candidates, 'Candidates list should not be null');
    }

    @isTest
    static void testGetRatingsCount() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        String soqlQueryList = 'Id';
        String soqlQueryRatingList = 'Id';
        String exportType = 'Rating';
        List<Bureau_Candidate__c> candidates = MasterProgressReportView.getCandidateDataDynamically(soqlQueryList, job.Id, 0, '');
        Test.startTest();
        MasterProgressReportView.ExportWrapper wrapper = MasterProgressReportView.getRatingsCount(job.Id, soqlQueryRatingList, soqlQueryList, exportType);
        MasterProgressReportView.CandidateAndRatingData ratingwrapper = MasterProgressReportView.getMasterViewData(soqlQueryRatingList, soqlQueryList, job.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, wrapper, 'ExportWrapper should not be null');
        System.assertNotEquals(null, wrapper.ratingCount, 'Rating count should not be null');
    }

    @isTest
    static void testGetRatingDataForReport() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        
        Test.startTest();
        String ratings = MasterProgressReportView.getRatingDataForReport(job.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetRatingDataForReporttotal() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        
        Test.startTest();
        Integer ratings = MasterProgressReportView.getRatingDataForReporttotalrecords(job.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, ratings, 'Ratings list should not be null');
    }
    
    

    @isTest
    static void testGetRatingData() {
        Job__c job = [SELECT Id FROM Job__c LIMIT 1];
        String soqlQueryList = 'Id';
        
        Test.startTest();
        List<Bureau_Rating__c> ratings = MasterProgressReportView.getRatingData(job.Id, soqlQueryList);
        Test.stopTest();
        
        System.assertNotEquals(null, ratings, 'Rating data list should not be null');
    }
    
    

   @isTest
    static void testGetCustomMetadataClientReportView() {
        // Start test execution
        Test.startTest();
        List<WRF_Client_Report_View__mdt> metadataRecords = MasterProgressReportView.getCustomMetadataClientReportView();
        Test.stopTest();

        // Assertions to validate the response
        //System.assertNotEquals(0, metadataRecords.size(), 'Metadata records should not be empty.');
        
       
        for (WRF_Client_Report_View__mdt record : metadataRecords) {
            System.assertNotEquals(null, record.Label, 'Label should not be null');
            System.assertNotEquals(null, record.DeveloperName, 'DeveloperName should not be null');
        }
    }
    
    @isTest
	static void testGetWRF_NoActiveWRF() {
    // *** ADDED FOR COVERAGE ***
    Job__c job = [SELECT Id FROM Job__c LIMIT 1];

    List<Work_Request__c> wrList = [SELECT Id, Is_Active__c FROM Work_Request__c];
    for (Work_Request__c wr : wrList) {
        wr.Is_Active__c = false;
    }
    update wrList;

    Test.startTest();
    String wrfId = MasterProgressReportView.getWRF(job.Id);
    Test.stopTest();

    System.assertEquals(null, wrfId, 'WRF should be null when no active records exist');
}
    
    @isTest
static void testGetRatingDataForReportTotal_WithWRFId() {
    // *** ADDED FOR COVERAGE ***
    Work_Request__c wr = [SELECT Id FROM Work_Request__c LIMIT 1];

    Test.startTest();
    Integer count =
        MasterProgressReportView.getRatingDataForReporttotalrecords(wr.Id);
    Test.stopTest();

    System.assertNotEquals(null, count);
}

    
    
   @isTest
static void testGetRatingsCount_MasterViewPath() {
    // *** ADDED FOR COVERAGE ***
    Job__c job = [SELECT Id FROM Job__c LIMIT 1];

    Test.startTest();
    MasterProgressReportView.ExportWrapper wrapper =
        MasterProgressReportView.getRatingsCount(
            job.Id,
            'Id',
            'Id',
            'MasterView'
        );
    Test.stopTest();

    System.assertNotEquals(null, wrapper);
}

    
    
   
    
    
    @isTest
static void testGetCandidateDataDynamically_WithFilter() {
    // *** ADDED FOR COVERAGE ***
    Job__c job = [SELECT Id FROM Job__c LIMIT 1];

    Test.startTest();
    List<Bureau_Candidate__c> result =
        MasterProgressReportView.getCandidateDataDynamically(
            'Id',
            job.Id,
            0,
            'Test'
        );
    Test.stopTest();

    System.assertNotEquals(null, result);
}

    
    @isTest
   static void testDecodeUrlParameter_WithSpaces() {
    // *** ADDED FOR COVERAGE ***
    CryptoKeySetting__c setting = CryptoKeySetting__c.getOrgDefaults();
    Blob cryptoKey = EncodingUtil.base64Decode(setting.CRYPTO__c);

    String originalId = '001xx000003NGs4AAG';
    Blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(originalId));
    String encoded = EncodingUtil.base64Encode(encryptedBlob);

    // Intentionally add space
    encoded = encoded.replace('+', ' ');

    Test.startTest();
    String decoded = MasterProgressReportView.decodeurlparamater(encoded);
    Test.stopTest();

    System.assertEquals(originalId, decoded);
}



}
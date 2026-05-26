@IsTest
public class OpportunityPriceUpdateScheduler_Test {

    @IsTest
    static void testSchedulerExecutesBatch() {
        // === Setup trigger activation custom settings (kept same) ===
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityLineItem', 'OpportunityLineItem_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        createTriggerActivationCustomSettingRecords('Order', 'Order_Trigger');
        createTriggerActivationCustomSettingRecords('ContentDocument', 'ContentDocument_Trigger');
        createTriggerActivationCustomSettingRecords('ContentDocumentLink', 'ContentDocumentLink_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Rating__c', 'MS_Rating_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Candidate__c', 'Bureau_Candidate_Trigger');

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        User user = [SELECT Id FROM User WHERE ProfileId = :pf.Id AND IsActive = TRUE LIMIT 1];

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;

        // --- Create Account with BU__c that ends with the code (so RIGHT(...,3) => AU1) ---
        Account account = new Account(
            Name = 'Test Account ' + Datetime.now().getTime(),
            Industry = 'Legal',
            OwnerId = user.Id,
            Status__c = 'Approved',
            Billing_Address_Line_1__c = 'test',
            Billing_City__c = 'Test City',
            Billing_Country__c = 'India',
            Billing_State__c = 'Test',
            Billing_ZIP_Postal_Code__c = '1100110',
            BU__c = 'Australia - AU1' // important: last 3 chars => 'AU1'
        );
        insert account;

        Contact contact = new Contact(
            LastName = 'Test Contact1',
            AccountId = account.Id,
            Same_As_The_Account_Billing_Address__c = true,
            Mailing_Address_Line_1__c = 'test',
            Mailing_City__c = 'test',
            Mailing_ZIP_Postal_Code__c = '110094',
            Mailing_Country__c = 'India',
            OwnerId = user.Id
        );
        insert contact;

        Contract con = new Contract(
            Name = 'Test Contract',
            Multi_Year_Increase_Clause__c = 'Old Standard Inflationary Increase',
            AccountId = account.Id,
            Agreement__c = 'Order',
            ContractTerm = 24,
            Status = 'Draft',
            StartDate = Date.today(),
            Invoicing_Contact__c = contact.Id,
            Contract_Type__c = 'Consulting',
            Subscription_Start_Date__c = Date.today()
        );
        insert con;

        // compute renewal Date
        Date renewalDate = System.today().addDays(50);
        if (renewalDate.year() == 2025) {
            renewalDate = renewalDate.addYears(1);
        }
        String renewalYearString = String.valueOf(renewalDate.year());

        // Insert Price Trend. Note Business_Unit__c should contain '-' so substringAfter works
        Price_Trend__c pt = new Price_Trend__c(
            Business_Unit__c = 'Australia - AU1',
            Applicable_Year__c = renewalYearString,
            Price_Increase_age__c = 10
        );
        insert pt;
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c(
            Name = 'Values',
            MS_Line_of_Business__c = 'Talent Management, Consulting'
        );
        insert cs;

        Opportunity opp = new Opportunity(
            Billing_Contact__c=contact.id,
        	Primary_Contact__c=contact.id,
            //RecordTypeID=RT.id,
            Skip_Validation__c=True,
            //Pricebook2Id=p.id,
            Name = 'Test Opp - Should be Picked',
            StageName = 'New',
            CloseDate = System.today().addDays(30),
            Renewal_Date__c = renewalDate,
            ContractId = con.Id,
            Price_Increase_Percentage__c = null,
            Renewal_Notification_Sent_On__c = null,
            Business_Type__c='Renewal',
            Forecast_Category__c='Commit',
            Multi_YearDeal__c = '2',
            Opportunity_Deal_Year__c = 2,
            AccountId = account.id
        );
        // Assign Account_LBU__c only for testing purpose if allowed (remove if read-only formula)
		//opp.put('Account_LBU__c', 'AU1');
        insert opp;
        
        User userRecord = TestDataUtility.getUser('Managed Service Lightning');
        userRecord.MS_LOB__c = 'Talent Management (Dashboards)';
        userRecord.Is_Job_Manager__c = true;
        userRecord.Is_Managed_Service_Manager__c = true;
        INSERT userRecord;
        
        
        Id RecordTypeIdJob2 = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();
		Job__c jobRecord = new Job__c();
        jobRecord.Account__c = account.id;
        jobRecord.Project_Manager__c = userRecord.Id;
        jobRecord.Opportunity__c = opp.id;
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
        jobRecord.System_Used__c = 'TalentCentral';
        jobRecord.RecordTypeId = RecordTypeIdJob2;
        jobRecord.Do_Not_Send_Survey__c = True;
        jobRecord.Preferred_Language__c = 'English';
        jobRecord.Job_Region__c = 'Non China';
        jobRecord.Sender_Email__c = 'noreply@shl.com';
        jobRecord.Client_Domain__c = 'test.com';
        jobRecord.Billing_Cycle_Start_Date__c = Date.Today();
        insert jobRecord;

        // --- DEBUG / SANITY CHECKS BEFORE RUNNING BATCH ---
        // Re-query records to see formula fields & important values
        Account accQ = [SELECT Id, BU__c FROM Account WHERE Id = :account.Id];
        Opportunity oppQ = [SELECT Id, AccountId, Account_LBU__c, Renewal_Date__c FROM Opportunity WHERE Id = :opp.Id];
        Price_Trend__c ptQ = [SELECT Id, Business_Unit__c, Applicable_Year__c, Price_Increase_age__c FROM Price_Trend__c WHERE Id = :pt.Id];

        // Expected: Account BU__c ends with AU1, Account_LBU__c formula should equal 'AU1'
        System.debug('Account.BU__c = ' + accQ.BU__c);
        System.debug('Opportunity.Account_LBU__c = ' + oppQ.Account_LBU__c);
        System.debug('Opportunity.Renewal year = ' + oppQ.Renewal_Date__c.year());
        System.debug('Price_Trend business unit = ' + ptQ.Business_Unit__c + ', applicable year = ' + ptQ.Applicable_Year__c);

        // Assertions to fail fast and reveal mismatch if any
        System.assertEquals('Australia - AU1', accQ.BU__c, 'Account BU__c must be exactly this for test');
        System.assertEquals('AU1', oppQ.Account_LBU__c, 'Formula Account_LBU__c should be AU1 (RIGHT(...,3))');
        System.assertEquals(
    renewalDate.year(),
    Integer.valueOf(ptQ.Applicable_Year__c),
    'Price_Trend year should match renewal year'
);

        // === Run the batch directly (safer for unit test) ===
        Test.startTest();
            // run batch synchronously
            OppPriceIncreaseOldStdClauseBatch batch = new OppPriceIncreaseOldStdClauseBatch();
            // small batch size to keep it simple
            Database.executeBatch(batch, 50);
        String cronExp = '0 0 0 15 5 ?'; // dummy CRON expression
        OpportunityPriceUpdateScheduler scheduler = new OpportunityPriceUpdateScheduler();
        System.schedule('Test OpportunityPriceUpdateScheduler', cronExp, scheduler);
        Test.stopTest();

        // === Verify the batch updated Opportunity ===
        Opportunity updatedOpp = [SELECT Id, Price_Increase_Percentage__c FROM Opportunity WHERE Id = :opp.Id];
        System.debug('Updated Opp Price_Increase_Percentage__c = ' + updatedOpp.Price_Increase_Percentage__c);
        

        System.assertEquals(
            10,
            updatedOpp.Price_Increase_Percentage__c,
            'Opportunity should be updated with Price_Increase_Percentage__c = 10'
        );
    }

    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
}
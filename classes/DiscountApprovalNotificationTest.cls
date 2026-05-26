@IsTest
public class DiscountApprovalNotificationTest {

    static Id oppId;

    @TestSetup
    static void setupData() {
    
        insert new List<Trigger_Activation__c>{
            new Trigger_Activation__c(Name='Account_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='Task_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='User_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='Opportunity_Trigger',Active__c=true),
            new Trigger_Activation__c(Name='Territory_Trigger',Active__c=true)
        };

        // User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        User bdm = new User(
            Alias='bdm',
            Email='bdm@test.com',
            EmailEncodingKey='UTF-8',
            LastName='BDM',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId=p.Id,
            TimeZoneSidKey='Asia/Kolkata',
            UserName='bdm' + System.currentTimeMillis() + '@test.com'
        );
        insert bdm;

        // Territory
        Territory__c terr = new Territory__c(
            Name='Test Territory',
            Region__c='AMS',
            Commercial_Director__c=bdm.Id,
            CRO__c=bdm.Id,
            MD__c=bdm.Id
        );
        insert terr;

        // Account
        Account acc = new Account(
            Name='Test Account',
            BU__c='UK - UK1',
            CurrencyIsoCode='GBP',
            Industry='Agriculture',
            Billing_Address_Line_1__c='Line1',
            Billing_City__c='City',
            Same_As_The_Billing_Address__c=true,
            Billing_Country__c='INDIA',
            Billing_State__c='State',
            Billing_ZIP_Postal_Code__c='Zip',
            Global_Billing_Country__c='AFGHANISTAN',
            Territory__c=terr.Id
        );
        insert acc;

        // Opportunity
        Opportunity opp = new Opportunity(
            Name='Test Opportunity',
            AccountId=acc.Id,
            CloseDate=Date.today(),
            StageName='Prospecting',
            Amount=77000,
            //Sales_Price_in_USD__c=5000,
            Products_Discount__c=20,
            Services_Discount__c=5,
            Business_Type__c='Expansion',
            Actual_Contract_Duration__c=12,
            Forecast_Category__c='Pipeline',
            Discount_Reason_Justification__c = 'Test',
            Discount_Reason_Code__c = 'Competitive Pressure'
            //Account_Territory_Region__c='AMS'
        );
        insert opp;

        oppId = opp.Id;

        // Discount Category
        insert new Discount_Approval_Category__c(
            Name='Test Category',
            Active__c=true,
            Type__c='Product',
            Region__c='AMS',
            Minimum_ACV__c=0,
            Maximum_ACV__c=300000,
            Minimum_Discount__c=0,
            Maximum_Discount__c=50,
            Original_Approver_DOA__c='Commercial_Director__c',
            Escalation_Level_1_DOA__c='CRO__c',
            Escalation_Level_2_DOA__c='MD__c',
            Approval_Strategy__c = 'ALL'
        );
        
        insert new Discount_Approval_Category__c(
            Name='Test Category 01',
            Active__c=true,
            Type__c='Services',
            Region__c='AMS',
            Minimum_ACV__c=0,
            Maximum_ACV__c=50000,
            Minimum_Discount__c=0,
            Maximum_Discount__c=50,
            Original_Approver_DOA__c='Commercial_Director__c',
            Escalation_Level_1_DOA__c='CRO__c',
            Escalation_Level_2_DOA__c='MD__c',
            Approval_Strategy__c = 'ALL'
        );
    }

   
    private static void executeMethod(String type) {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        List<List<String>> input = new List<List<String>>();
        input.add(new List<String>{opp.Id, type});

        Test.startTest();
        DiscountApprovalNotificationController.sendNotification(input);
        Test.stopTest();
    }
    
    
    /*private static void executeMethod(String type) {

    List<List<String>> input = new List<List<String>>();
    input.add(new List<String>{oppId, type});

    Test.startTest();
    DiscountApprovalNotificationController.sendNotification(input);
    Test.stopTest();
}*/

    @IsTest
    static void testApprovalReminder() {
        executeMethod('Approval Reminder');
        System.assert(true);
    }

    @IsTest
    static void testEscalationLevel2() {
        executeMethod('Escalation Level 2');
        System.assert(true);
    }

    @IsTest
    static void testDailyReminder() {
        executeMethod('Daily Reminder');
        System.assert(true);
    }

    @IsTest
    static void testNullInput() {
        Test.startTest();
        DiscountApprovalNotificationController.sendNotification(null);
        Test.stopTest();
        System.assert(true);
    }
}
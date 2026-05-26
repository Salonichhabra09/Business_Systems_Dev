@isTest
private class Account_TriggerTester
{
    @testSetup
    static void setupData() {
        // Insert non-setup custom settings and reference data
        insert new Field_Value_Setting__c(
            Name = 'Account Record',
            Value__c = '001000000000000AAA' // dummy Account Id format
        );

        insert new AccountMergingPermission__c(
            UserEmail__c = 'judy.short@shl.com',
            Name = 'Judy Short'
        );
        /*insert new Trigger_Activation__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Active__c = true
        );*/
        insert new Trigger_Activation__c(Name = 'User_Trigger', Active__c = true);
        
    }

    static testMethod void testAccountTriggers()
{
    // Prepare user for runAs
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    User testUser = new User(
        Alias = 'testusr',
        Email = 'testuser@example11.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/New_York',
        UserName = 'testuser@example111.com'
    );

    // === 1. Setup DML only ===
    insert testUser; // Setup object

    // === 2. Business logic ===
    Test.startTest();

    System.runAs(testUser) {
        insert new Trigger_Activation__c(Name = 'Account_Trigger', Active__c = true);
        List<Account> accounts = insertaccounts();
        updateaccounts(accounts);
        mergeAccounts(accounts);
    }

    Test.stopTest();
}


    static List<Account> insertaccounts()
    {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 2; i++)
        {
            insert new Trigger_Activation__c(Name = 'Account_Trigger', Active__c = true);
            Account acc = new Account();
            acc.Name = 'Test234' + i;
            acc.BU__c = 'UK - UK1';
            acc.CurrencyIsoCode = 'GBP'; 
            acc.Industry = 'Agriculture';
            acc.Billing_Address_Line_1__c = 'test23';
            acc.Billing_City__c = 'test23';
            acc.Same_As_The_Billing_Address__c = true;
            acc.Billing_Country__c = 'INDIA';
            acc.Billing_State__c = 'test23';
            acc.Billing_ZIP_Postal_Code__c = 'test23';           
            accounts.add(acc);
        }
        insert accounts;
        return accounts;
    }

    static void updateaccounts(List<Account> insertedaccounts)
    {
        List<Account> accountsToUpdate = new List<Account>();
        Integer i = 0;
        for (Account insertedAccount : insertedaccounts)
        {
            Account acc = new Account(Id = insertedAccount.Id);
            if (i > 0) {
                acc.Name = insertedAccount.Name + 'Test';
            }
            acc.Billing_Address_Line_1__c = 'test';        
            acc.Billing_Address_Line_2__c = 'test'; 
            acc.Billing_Address_Line_3__c = 'test';  
            acc.Billing_Address_Line_4__c = 'test';
            acc.Billing_City__c = 'test';
            acc.Billing_Country__c = 'INDIA'; 
            acc.Billing_State__c = 'test';  
            acc.Billing_ZIP_Postal_Code__c = 'test';
            accountsToUpdate.add(acc);
            i++;
        }
        update accountsToUpdate; 
    }

    static void mergeAccounts(List<Account> accounts)
    {
        delete accounts;
        undelete accounts;
    }
}
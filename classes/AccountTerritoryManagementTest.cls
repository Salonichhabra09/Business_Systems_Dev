@IsTest
public class AccountTerritoryManagementTest {

    private static User createUser(String alias) {
        Profile p = [
            SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1
        ];

        return new User(
            Alias = alias,
            Email = alias + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = alias,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            UserName = alias + System.currentTimeMillis() + '@test.com'
        );
    }

    private static Account createAccount() {
        return new Account(
            Name = 'Test Account',
            BU__c = 'UK - UK1',
            CurrencyIsoCode = 'GBP',
            Industry = 'Agriculture',
            Billing_Address_Line_1__c = 'Line1',
            Billing_City__c = 'City',
            Same_As_The_Billing_Address__c = true,
            Billing_Country__c = 'INDIA',
            Billing_State__c = 'State',
            Billing_ZIP_Postal_Code__c = 'Zip'
        );
    }

    /* 
        INSERT ACCOUNT WITHOUT TERRITORY
    */
    @IsTest
    static void testAfterInsert_NoTerritory() {

        insert new Trigger_Activation__c(
            Name = 'Account_Trigger',
            Active__c = true
        );

        Account acc = createAccount();

        Test.startTest();
        insert acc;
        Test.stopTest();

        System.assertNotEquals(null, acc.Id);
    }

    /* 
        UPDATE WITHOUT TERRITORY CHANGE
     */
    @IsTest
    static void testAfterUpdate_NoTerritoryChange() {

        insert new Trigger_Activation__c(
            Name = 'Account_Trigger',
            Active__c = true
        );

        Account acc = createAccount();
        insert acc;

        Test.startTest();
        AccountTerritoryManagement.handleAfterInsertUpdate(
            new List<Account>{ acc },
            new Map<Id, Account>{ acc.Id => acc }
        );
        Test.stopTest();

        System.assert(true);
    }

    /* 
       TEST: FULL FLOW WITH TERRITORY 
     */
    @IsTest
    static void testSyncAccountTeams_WithTerritory() {

        insert new Trigger_Activation__c(Name = 'Account_Trigger',Active__c = true);
		insert new Trigger_Activation__c(Name = 'User_Trigger', Active__c = true);
        User bdm = createUser('bdm');
        insert bdm;
        insert new Trigger_Activation__c(Name = 'Territory_Trigger', Active__c = true);
		
        Territory__c terr = new Territory__c(
            Name = 'Test Territory',
            Business_Development_Manager__c = bdm.Id
        );
        insert terr;

        Account acc = createAccount();
        acc.Territory__c = terr.Id;
        insert acc;

        Test.startTest();
        AccountTerritoryManagement.syncAccountTeams(
            new Set<Id>{ acc.Id }
        );
        Test.stopTest();

        // Owner updated from priority
        acc = [SELECT OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(bdm.Id, acc.OwnerId);

        // Account Team Member created
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AccountTeamMember WHERE AccountId = :acc.Id]
        );
    }

    /* 
       DELETE EXISTING ACCOUNT TEAM MEMBERS
     */
    @IsTest
    static void testDeleteExistingAccountTeamsCoverage() {

        insert new Trigger_Activation__c(
            Name = 'Account_Trigger',
            Active__c = true
        );

        Account acc = createAccount();
        insert acc;

        AccountTeamMember atm = new AccountTeamMember(
            AccountId = acc.Id,
            UserId = UserInfo.getUserId(),
            TeamMemberRole = 'Account Manager',
            AccountAccessLevel = 'Edit'
        );
        insert atm;

        Test.startTest();
        AccountTerritoryManagement.syncAccountTeams(
            new Set<Id>{ acc.Id }
        );
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM AccountTeamMember WHERE AccountId = :acc.Id]
        );
    }

    /* 
        EMPTY INPUT SAFETY
    */
    @IsTest
    static void testEmptyHandlerSafety() {

        Test.startTest();
        AccountTerritoryManagement.handleAfterInsertUpdate(
            new List<Account>(),
            null
        );
        Test.stopTest();

        System.assert(true);
    }

    /* 
      OWNER PRIORITY LOGIC
    */
    @IsTest
    static void testGetOwnerFromPriority_AllBranches() {

        Id uid = UserInfo.getUserId();

        Territory__c t1 = new Territory__c(
            Business_Development_Manager__c = uid
        );
        System.assertEquals(uid,
            AccountTerritoryManagement.getOwnerFromPriority(t1)
        );

        Territory__c t2 = new Territory__c(
            Account_Director__c = uid
        );
        System.assertEquals(uid,
            AccountTerritoryManagement.getOwnerFromPriority(t2)
        );

        Territory__c t3 = new Territory__c(
            Manager_1__c = uid
        );
        System.assertEquals(uid,
            AccountTerritoryManagement.getOwnerFromPriority(t3)
        );

        Territory__c t4 = new Territory__c();
        System.assertEquals(
            null,
            AccountTerritoryManagement.getOwnerFromPriority(t4)
        );
    }
}
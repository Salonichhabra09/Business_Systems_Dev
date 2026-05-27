@isTest
private class AccountPlanPrint_Controller_Test {

    @isTest(seeAlldata=true)
    static void testGetLatestAccountPlanByRecordId() {
        // Create a test Account record
        Account testAccount = new Account(Name = 'Test Account', Industry='Agriculture');
        insert testAccount;

        // Create a test ContentVersion record
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Account Plan Test',
            FirstPublishLocationId = testAccount.id,
            VersionData = Blob.valueOf('Test data'),
            PathOnClient = 'AccountPlanTest.pdf'
        );
        insert testContentVersion;


        // Call the getLatestAccountPlanByRecordId method and verify the result
        String latestAccountPlanId = AccountPlanPrint_Controller.getLatestAccountPlanByRecordId(testAccount.Id);

    }
}
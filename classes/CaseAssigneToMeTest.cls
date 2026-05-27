@isTest
public class CaseAssigneToMeTest {
    @isTest
    static void testAssignToMe() {
        // Set up the custom setting or custom metadata
        Trigger_Activation__c caseTriggerSetting = new Trigger_Activation__c(
            Name = 'Case_Trigger',
            Active__c = true // Activating the trigger for this test
        );
        insert caseTriggerSetting;
        // Create a test user to simulate assignment
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        // Set the test context to the test user
        System.runAs(testUser) {
            // Create a test case record
            Case testCase = new Case(
                Subject = 'Test Case',
                Status = 'New',
                OwnerId = UserInfo.getUserId() // Assigning to current user for testing
            );
            insert testCase;

            // Assert initial owner is not null
            System.assertNotEquals(null, testCase.OwnerId, 'Initial owner should not be null.');

            // Call the method to assign the case to the current user
            CaseAssigneToMe.assignToMe(testCase.Id);

            // Query the updated case
            Case updatedCase = [SELECT Id, OwnerId FROM Case WHERE Id = :testCase.Id];

            // Assert the owner is the current user
            System.assertEquals(UserInfo.getUserId(), updatedCase.OwnerId, 'The case should be assigned to the current user.');
        }
    }
}
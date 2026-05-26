@isTest
public class BulkTaskAccountPlanController_Test {
    
    @isTest(seeAlldata=true)
    static void testBulkTask() {
        Account acc= new Account();
        acc.Name='Test234';
        acc.BU__c='UK - UK1';
        acc.CurrencyIsoCode='GBP'; 
        acc.Industry='Agriculture';
        acc.Billing_Address_Line_1__c='test23';
        acc.Billing_City__c='test23';
        acc.Same_As_The_Billing_Address__c=true;
        acc.Billing_Country__c='test23';
        acc.Billing_State__c='test23';
        acc.Billing_ZIP_Postal_Code__c='test23'; 
        insert acc;
        
        Contact con = CreateTestData.getContact(acc.Id);
        Contact con1 = CreateTestData.getContact(acc.Id);
        
        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id);
        insert accPlan;
        
        Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                               Strategy_Name__c = 'Test',
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration', 
                                                               Strategy_Status__c = 'In Progress');
        insert stgoal;
        List<BulkTaskAccountPlanController.TaskWrapper> taskList = new List<BulkTaskAccountPlanController.TaskWrapper>();
        BulkTaskAccountPlanController.TaskWrapper wrapper = new BulkTaskAccountPlanController.TaskWrapper();
        wrapper.assignedTo = UserInfo.getUserId();
        wrapper.status = 'In Progress';
        wrapper.contact = con.Id;
        wrapper.dueDate = System.today();
        wrapper.comments = 'Test';
        wrapper.subject = 'call';
        taskList.add(wrapper);
        
        Test.startTest();
        BulkTaskAccountPlanController.getPicklistValues(stgoal.Id);
        BulkTaskAccountPlanController.createBulkTasks(accPlan.Id,taskList);
        Test.stopTest();
        
        
    }
}
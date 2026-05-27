@isTest(SeeAllData=true)
class EventProgressOnStrategy_Test {
	
    @isTest
    static void testEventProgress(){
        String Testname='Test Account';
        Account account=new Account(name=Testname,Status__c='approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
        insert account;
        
        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=account.Id);
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
        
        Event event = new Event();
        event.OwnerId = userInfo.getUserId();
        event.StartDateTime = Datetime.Now().addDays(-4);
        event.EndDateTime = event.StartDateTime.addDays(2);
        event.whatId = stgoal.id;  
        event.Is_Completed__c = false;
        insert event;
        
        EventProgressOnStrategy.updateProgressOnStrategy();
    }
}
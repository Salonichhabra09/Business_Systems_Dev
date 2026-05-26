@isTest
Public class testAccount_BulkApprovalJobSchedulable{
    Public static testMethod void accBulkAppJSch(){
        test.startTest();
        Account_BulkApprovalJobSchedulable obj = new Account_BulkApprovalJobSchedulable();
        string schedule ='0 0 23 * * ?';
        system.schedule('Nightly Update', schedule,obj);
        test.stoptest();
     }  
    
    static testMethod void testController() 
    { 
		Account_BulkApprovalPageController controller = new Account_BulkApprovalPageController();
		controller.Execute();
    }

}
public class Account_BulkApprovalPageController 
{
	public PageReference Execute()
    {
    	Account_BulkApprovalJob test_SubmitAccountsforApproval = new Account_BulkApprovalJob(null, 'ApprovalAccountIds');       
        Id batchinstanceid = database.ExecuteBatch(test_SubmitAccountsforApproval,20);
   		return null;
    }
    
}
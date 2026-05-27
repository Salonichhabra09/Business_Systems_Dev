global class Account_BulkApprovalJobSchedulable implements Schedulable
{
    global void Execute(SchedulableContext Sc)
    {
    	Account_BulkApprovalJob job = new Account_BulkApprovalJob(null, 'ApprovalAccountIds');       
        Id batchinstanceid = database.ExecuteBatch(job,50);
    }
}
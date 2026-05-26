public without sharing class callOrderCancellationFlow implements Queueable{
	
    public Order orderRecord;
    public PermissionSetAssignment permissionSetAssignment;
    public Boolean runOnce;
    
    public callOrderCancellationFlow(Order orderData, PermissionSetAssignment psa, Boolean runFlag){
        orderRecord = orderData;
        permissionSetAssignment = psa;
        runOnce = runFlag;
    }
    
    public void execute(QueueableContext context){
        // Mark Order as Cancelled
        update orderRecord;
        if(!Test.isRunningTest()){
            //Remove Permission Set from user
            Id jobID1 = System.enqueueJob(new AssignPermissionSetToUser(orderRecord, permissionSetAssignment, runOnce));
            System.debug('jobID1 '+jobID1);
        }
    }
}
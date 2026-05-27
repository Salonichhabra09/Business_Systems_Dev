public without sharing class AssignPermissionSetToUser implements Queueable{
	
    public Order orderRecord;
    public PermissionSetAssignment psa;
    public Boolean runOnce;
    
    public AssignPermissionSetToUser(Order orderRec, PermissionSetAssignment permSetAssign, Boolean runFlag){
        orderRecord = orderRec;
        psa = permSetAssign;
        runOnce = runFlag;
    }
    
    public void execute(QueueableContext context){
		String myPermissionSetId = System.label.OrderContractViewAllPermissionSet;
        String myAssigneeId = userInfo.getUserId();
		System.debug('psa '+psa);
        if(psa.Id == null){
            //Assign Permission Set to logged in user
            psa.PermissionSetId = myPermissionSetId;
            psa.AssigneeId = myAssigneeId;
            insert psa;
        }else{
            runOnce = true;
            list<PermissionSetAssignment> psaList = [SELECT Id FROM PermissionSetAssignment WHERE Id = :psa.Id];
            if(!psaList.isEmpty()){
                //Revoke Permission set from logged in user
            	delete psa;
            }
        }
        if(!Test.isRunningTest() && !runOnce){
            // Call order cancellation process
            Id jobID2 = System.enqueueJob(new callOrderCancellationFlow(orderRecord, psa, runOnce));
            System.debug('jobID2 '+jobID2);
        }
    }
}
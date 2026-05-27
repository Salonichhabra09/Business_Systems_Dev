public without sharing class callOrderCancellationProcess {
    
    @InvocableMethod
    public static void orderCancellationProcess(List<InputValues> inputValuesList){
        Order orderRecord = inputValuesList.get(0).orderData;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        // Call Permission Set Assignment process
        Id jobID1 = System.enqueueJob(new AssignPermissionSetToUser(orderRecord, psa, false));
        System.debug('jobID1 '+jobID1);
    }
    
    public class InputValues{
        @invocableVariable
        public Order orderData;
        
    }
}
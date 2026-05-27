public class RecallCancelledOrders {
    @InvocableMethod
    public static void recallOrders(list<order> orderlist){
        //Object record id to recall the approval process
        for(order ord : [select id,status from order where Reduction_order__c = true and Original_Order__c = :orderlist.get(0).id]){
            system.debug('gcscreductionorder'+ord);
            if(ord.status == 'In Approval')
                orderlist.add(ord);
        }
        //user u = [select id from user where profile.name = 'System Administrator' limit 1];
        //system.runAs(u){
        for(order ord : orderlist){
            String recordId = ord.id;
            //Get Process Instance Work Items
            ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId AND ProcessInstance.Status = 'Pending']; 
            if(piWorkItems.size() > 0){
                //Create Process Work Item Request
                Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                pwiRequest.setAction('Removed');
                pwiRequest.setWorkItemId(piWorkItems[0].Id);
                Approval.ProcessResult result = Approval.process(pwiRequest);
            }
        }
        //}
    }
}
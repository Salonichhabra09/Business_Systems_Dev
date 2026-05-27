trigger OrderProduct_Trigger on OrderItem (after insert,after update,after delete,after undelete)
{
     if (Trigger_Activation__c.getInstance('OrderProduct_Trigger').Active__c){
    
    List<OrderItem> items        = Trigger.isDelete ? Trigger.old : Trigger.new;
    Map<Id, OrderItem> oldMap    = Trigger.isDelete ? null : Trigger.oldMap;

    OrderItemTriggerHandler.handleOrderItems(items, oldMap);
    }
}
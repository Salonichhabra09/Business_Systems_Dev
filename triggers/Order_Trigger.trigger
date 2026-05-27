trigger Order_Trigger on Order (before insert, before update,after update,before delete){
    if(Trigger_Activation__c.getInstance('Order_Trigger').Active__c){
        if(Trigger.isInsert){
            if(Trigger.isBefore){
                OrderTriggerManager.blankOutBillingFrequenciesForExtension(Trigger.new);
            }
        }
        if(trigger.isupdate){
            
            if(Trigger.isBefore){
            
                OrderTriggerManager.CheckInvHeaderWithOrder(Trigger.new);
                list<order> normalCancelledOrderList = new list<order>();
                list<order> GCSCCancelledOrderList = new list<order>();
                for(order ord:Trigger.new){
                    if(ord.status == 'Cancelled' && ord.RecordTypeId != system.label.GCSC_ORDER_RECORD_TYPE){
                        normalCancelledOrderList.add(ord);
                    }
                    if(ord.status == 'Cancelled' && ord.RecordTypeId == system.label.GCSC_ORDER_RECORD_TYPE){
                        system.debug('orderid'+trigger.new);
                        system.debug('orderid'+trigger.new.size());
                        GCSCCancelledOrderList.add(ord);
                    }
                }
                if(!normalCancelledOrderList.isEmpty()){
                    OrderTriggerManager.RestrictNormalOrderCancellation(normalCancelledOrderList);
                }
                if(!GCSCCancelledOrderList.isEmpty()){
                    OrderTriggerManager.RestrictGCSCOrderCancellation(GCSCCancelledOrderList);
                }
                
                OrderTriggerManager.RejectionReasonRequired(Trigger.new,Trigger.OldMap);
                OrderTriggerManager.UpdateOrderFieldValues(Trigger.new,Trigger.old);
                OrderTriggerManager.bookingdatemandatory(Trigger.new);
            }
            
            if(Trigger.isAfter){
                SyncOrderToInvoice.SyncDates(Trigger.new,Trigger.OldMap);
                OrderCancellationProjectHandler.handle(Trigger.new, Trigger.oldMap);

            
            }
            
            
        }
        if(trigger.isdelete){
            if(trigger.isbefore){
                OrderTriggerManager.restrictDeleteForOATS(trigger.old);
            }    
        }
    }
}
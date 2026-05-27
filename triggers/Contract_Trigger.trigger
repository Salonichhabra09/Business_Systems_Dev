//Created By PANKHURI JAIN to combine all triggers on Account on 06/06/2019

trigger Contract_Trigger on Contract (before update,before delete,after update) {    
    if(Trigger_Activation__c.getInstance('Contract_Trigger').Active__c){
        if(Trigger.isDelete){
            //ContractTriggerManager_1.ValidateUserProfile(trigger.old);
        }
        if(Trigger.isUpdate){
            if(Trigger.isAfter){
                //ContractTriggerManager_1.UpdateRelatedOpportunityStage(trigger.new,trigger.old);
                //ContractTriggerManager_1.UpdateRelatedCase(trigger.new,trigger.old);
                //ContractTriggerManager_1.UpdateRelatedContractLineCurrency(trigger.new,trigger.old);
                //ContractTriggerManager_1.UpdateOrderBookingDate(trigger.new,trigger.old);
                 ContractTriggerManagerNew.ContractValue(trigger.new,trigger.old);

            }
            if(Trigger.isBefore){
                ContractTriggerManagerNew.ContractCancel(trigger.new,trigger.old);
                ContractTriggerManagerNew.ContractActvOpptyVerbal(trigger.new,trigger.old);
                ContractTriggerManagerNew.OrderPdfCsvChecks(trigger.new,trigger.old);
                //ContractTriggerManagerNew.SubscriptionValidations(trigger.new,trigger.old);
               //ContractTriggerManager_2.ValidateRelatedOrderLines(trigger.new);
               //ContractTriggerManager_2.UpdateOrderFieldValues(trigger.new,trigger.old);
               //ContractTriggerManager_2.OrderPdfCsvChecks(trigger.new,trigger.old);
               //ContractTriggerManager_3.RenewalReboostOppCreation(trigger.new,trigger.old);
            }
        }
    }   
}
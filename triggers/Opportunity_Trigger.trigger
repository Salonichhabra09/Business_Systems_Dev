trigger Opportunity_Trigger on Opportunity (before insert, after insert, before update, after update, before delete) {
    if(Trigger_Activation__c.getInstance('Opportunity_Trigger').Active__c){
        if(Trigger.isInsert)
        {
            if(Trigger.isBefore)
            {
                OpportunityTriggerManager.BeforeInsertTasks(trigger.new);
                OpportunityTriggerManager.trackNextStepAndManagerComments(Trigger.new);
                OpportunityTriggerManager.captureTotalExtensionLength(Trigger.new, null, Trigger.newMap);
            }
            if(Trigger.isAfter)
            {
                //OpportunityTriggerManager.DeleteNonRenewalProds(trigger.new);
                OpportunityTriggerManager.CreateOpportunityContactRole(trigger.new);
                //OpportunityTriggerManager.UpdateOriginalOrder(trigger.new);
               // OpportunityTriggerManager.RecordTypecheck(trigger.new,trigger.old);    
               OpportunityTriggerManager.extendOppAccessToOpportunityOwnerManager(Trigger.new, null);  
            }
        }
        if(Trigger.isUpdate)
        {
            if(Trigger.isBefore)
            {
                
                OpportunityTriggerManager.checkEndOfLifeProducts(Trigger.New,Trigger.OldMap,trigger.newMap);  //Added by Joana Martins SSE-16631
                OpportunityTriggerManager.CheckBouncedMailOnPriceIncrease(Trigger.old,Trigger.new); //Added by Priyank Anand
                OpportunityTriggerManager.UpdatePricebookid(trigger.new);
                OpportunityTriggerManager.PreviousRecordTypeUpdate(trigger.oldMap,trigger.newMap); // Added by pankhurifor SSE-12332
                //OpportunityTriggerManager.AllowAccessOnOpportunityFields(trigger.oldMap,trigger.newMap,trigger.new);
                OpportunityTriggerManager.LockOnClosedWon_LostStage(trigger.oldMap,trigger.newMap,trigger.new); // Added by pankhuri for SSE-11575
                //OpportunityTriggerManager.OliFIeldValidation(trigger.oldMap,trigger.newMap,trigger.new);      
                OpportunityTriggerManager.RecordTypecheck(Trigger.New,Trigger.OldMap);   
                //OpportunityTriggerManager.checkAtRiskReason(Trigger.New,Trigger.OldMap);
                OpportunityTriggerManager.trackNextStepAndManagerComments(Trigger.new, trigger.oldMap);
                OpportunityTriggerManager.captureTotalExtensionLength(Trigger.new, trigger.oldMap, Trigger.newMap);
                OpportunityTriggerManager.checkCancellationDocOnCloseLost(Trigger.new,Trigger.OldMap);
                //OpportunityTriggerManager.checkVariationReasonChangedFromDebooking(Trigger.new,Trigger.OldMap);
                OpportunityTriggerManager.totalSolutionCapCalculation(Trigger.old,Trigger.new);
            }
            if(Trigger.isAfter)
            {
                OpportunityTriggerManager.CreateJobs(trigger.new, trigger.oldMap);
                //OpportunityTriggerManager.UpdateProject(trigger.old,trigger.new); //Commented by Priyank for SSE-12329
                //OpportunityTriggerManager.UpdateVariationOrder(trigger.old,trigger.new);
                //OpportunityTriggerManager.UpdateOpportunityContactRole(trigger.oldMap,trigger.newMap,trigger.new);
                OpportunityTriggerManager.SendMailToProjectManager_Coordinator(trigger.old,trigger.new);
                OpportunityTriggerManager.DeleteFutureServices(trigger.oldMap,trigger.newMap,trigger.new);
                OpportunityTriggerManager.CreateFutureServices(trigger.oldMap,trigger.newMap,trigger.new);
                //OpportunityTriggerManager.recordTypeChange(trigger.oldMap,trigger.newMap);
                OpportunityTriggerManager.ValidationLockedStage(trigger.oldMap,trigger.newMap);
                //OpportunityTriggerManager.UpdateOpportunityContactRoleNew(trigger.new,trigger.old);
                OpportunityTriggerManager.UpdateOpportunityContactRoleNew(trigger.oldMap,trigger.newMap,trigger.new);
            //   OpportunityTriggerManager.RecordTypecheck(trigger.new,trigger.old);    
                OpportunityTriggerManager.copyClosedWonOrLostReason(trigger.new,trigger.oldMap,trigger.newMap);  
                OpportunityTriggerManager.extendOppAccessToOpportunityOwnerManager(Trigger.new, trigger.oldMap);
                OpportunityTriggerManager.updateDebookingScopeOnCloseLost(Trigger.new, trigger.oldMap);
            }
        }
        if(Trigger.isDelete)
        {
            if(Trigger.isBefore)
            {
                OpportunityTriggerManager.validateUserOnDeletion(trigger.old);
                OpportunityTriggerManager.OpptyDeleteWithContract(trigger.old);
            }
        }
    }
}
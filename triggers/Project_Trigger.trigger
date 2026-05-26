trigger Project_Trigger on ProjectObject__c (before insert,before update,after update,before delete,after insert){
    If(Trigger_Activation__c.getInstance('Project_Trigger').Active__c){
        If(Trigger.IsInsert){
            //ProjectTriggerManager.GetOrderNumAndOrderLine(Trigger.new);
            //ProjectTriggerManager.PopulateAndUpdateScopedDays(Trigger.new); added to before Insert
            //ProjectTriggerManager.CreateAdditionalScopedDaysRec(Trigger.new); added to after insert
            If(Trigger.IsBefore){
            //ProjectTriggerManager.PopulateFunctionalAreaOnCPS(Trigger.new);
            ProjectTriggerManager.PopulateAndUpdateScopedDays(Trigger.new);
            ProjectTriggerManager.PopulateSurveyLanguageOnInsert(Trigger.new);
            }
            if(Trigger.IsAfter){
            ProjectTriggerManager.CreateAdditionalScopedDaysRec(Trigger.new);
            ProjectTriggerManager.UpdateDescriptionNotesOnInsert(Trigger.new);
            ProjectTriggerManager.UpdateReasonforDeliveryTargetVarianceNotesOnInsert(Trigger.new);
            ProjectTriggerManager.UpdateCommentsNotesOnInsert(Trigger.new);
            ProjectTriggerManager.UpdateReasonsNotesOnInsert(Trigger.new);
            ProjectTriggerManager.ShareWithCoordinatorOnInsert(Trigger.new);
            ProjectTriggerManager.ShareWithCPSGroupMemOnInsert(Trigger.new);
            //ProjectTriggerManager.UpdateOrderLinesonInsert(Trigger.new);
            ProjectTriggerManager.extendOppAccessToProject_PM_Manager(Trigger.new, null);
            }
        }
        If(Trigger.IsUpdate){
            if(Trigger.IsBefore){
                //ProjectTriggerManager.UpdateOrderHeaderAndLine(Trigger.new,Trigger.old);
                ProjectTriggerManager.ValidateAndShowErrors(Trigger.new,Trigger.old,Trigger.Oldmap);
                ProjectTriggerManager.UpdateScopedDaysAndEffort(Trigger.new,Trigger.old);
                ProjectTriggerManager.UpdateProjectMgrAndCordinator(Trigger.new,Trigger.old);
                //ProjectTriggerManager.PopulateFunctionalAreaOnCPSUpdate(Trigger.new,Trigger.old);
                ProjectTriggerManager.PopulateSurveyLanguage(Trigger.new,Trigger.old);
                ProjectTriggerManager.checkMilestones(trigger.newmap,trigger.oldmap);
                ProjectTriggerManager.UpdateDescriptionNotes(Trigger.old,Trigger.new,trigger.newmap);
                ProjectTriggerManager.UpdateReasonforDeliveryTargetVarianceNotes(Trigger.old,Trigger.new,trigger.newmap);
                ProjectTriggerManager.UpdateCommentsNotes(Trigger.old,Trigger.new,trigger.newmap);
                ProjectTriggerManager.UpdateReasonsNotes(Trigger.old,Trigger.new,trigger.newmap);
                ProjectTriggerManager.UpdateProjectStatusOnPMChange(Trigger.new,Trigger.old);
                //ProjectTriggerManager.editValidation(Trigger.new,Trigger.old,Trigger.Oldmap);
            }
            if(Trigger.IsAfter){
                //ProjectTriggerManager.RestrictOrderLineRemoval(Trigger.new,Trigger.old);
                ProjectTriggerManager.UpdateTimesheetAndInvoices(Trigger.new,Trigger.old);
                //ProjectTriggerManager.UpdateOrderLineOnProject(Trigger.new,Trigger.old);
                //ProjectTriggerManager.PopulateFunctionalAreaOnAllCPS(Trigger.new,Trigger.old);
                //ProjectTriggerManager.UpdateOrderLines(Trigger.old,Trigger.new);
                 ProjectTriggerManager.ShareWithCoordinatorOnUpdate(Trigger.new,Trigger.old);
                ProjectTriggerManager.extendOppAccessToProject_PM_Manager(Trigger.new, trigger.oldMap);
            }
        }
        If(Trigger.IsDelete){
            ProjectTriggerManager.RestrictProjectDeletion(Trigger.new,Trigger.old);         
        }
    }
}
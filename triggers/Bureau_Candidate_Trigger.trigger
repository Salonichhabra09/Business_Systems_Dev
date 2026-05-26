//Created By RISHABH KANOTRA to combine all triggers on Bureau_Candidate on 25/07/2019
trigger Bureau_Candidate_Trigger on Bureau_Candidate__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    if(Trigger_Activation__c.getInstance('Bureau_Candidate_Trigger').Active__c) {
           If(Trigger.IsDelete){
               If(Trigger.IsAfter){
                   if(Trigger.old.size()==1){
                       // SSE-28260 While deleting a Candidate:
                       // Method to delete all related Rating records, If the Candidate is a Participant on the current WRF.
                       RollUpCandidateFields.deleteRelatedRatings(Trigger.old);
                   }
               }
           }  
       }//Not_Transferred_Candidate_Count__c, Transferred_Candidate_Count__c
    
    /*if(Trigger_Activation__c.getInstance('Bureau_Candidate_Trigger').Active__c  && 
       User_Specific_Trigger_Activation__c.getInstance(UserInfo.getUserId()).Candidate_Trigger__c == false) {
        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                BureauCandidateTriggerManager_1.beforeBureauCandidateInsert(trigger.new); // Uncommented by Naved for Sequence no logic on candidate.
            } 
            else if (Trigger.isAfter) {
                // cOMMENTED BY AASHI
                //BureauCandidateTriggerManager_1.afterBureauCandidateInsert(trigger.new);
                //Added by Pallavi Jadhav
                RollUpCandidateFields.calculateCountFields(trigger.newMap);
                RollUpCandidateFields.updateRollupSummaryFieldsOnJob(trigger.new); //Changed by Shubham Singh
                //RollUpCandidateFields.numberOfParticipants(trigger.newMap);
                //RollUpCandidateFields.numberOfRespondents(trigger.newMap);
                //RollUpCandidateFields.ratingsCompleted(trigger.newMap);
                //RollUpCandidateFields.ratingsInProgress(trigger.newMap);
                //RollUpCandidateFields.ratingsNotStarted(trigger.newMap);
                //RollUpCandidateFields.selfRating(trigger.newMap);
            }    
        }//Insert
        
        if (Trigger.isUpdate) {
            if (Trigger.isBefore) { 
            } 
            else if (Trigger.isAfter) {
               // BureauCandidateTriggerManager_1.afterBureauCandidateUpdate(trigger.old, trigger.new);
                RollUpCandidateFields.updateRollupSummaryFieldsJobUpdate(trigger.new, trigger.oldmap); //Changed by Shubham Singh
            }    
        }//Update
        
        if (Trigger.isDelete) {
            if (Trigger.isBefore) {
                RollUpCandidateFields.updateRollupSummaryFieldsOnJob(trigger.old); // Changed byShubham Singh
             } 
            else if (Trigger.isAfter) {
                // Commented by Aashi 
                // BureauCandidateTriggerManager_1.afterBureauCandidateDelete(trigger.old);
                RollUpCandidateFields.updateCandidateMaxSeqNoOnDelete(Trigger.old);
            }    
         }//Delete
        
        
        if (Trigger.isUndelete) {
            if (Trigger.isAfter) {
                 RollUpCandidateFields.updateRollupSummaryFieldsOnJob(trigger.new,'insert'); //Changed by Shubham Singh
             }    
            
        }//Undelete
        
    }//Trigger_Activation*/
    
}//end
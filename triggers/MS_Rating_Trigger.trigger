trigger MS_Rating_Trigger on Bureau_Rating__c (after insert,before delete, after delete){
    if(Trigger_Activation__c.getInstance('MS_Rating_Trigger').Active__c){
        If(Trigger.IsInsert){
            If(Trigger.IsAfter){
                //MS_RatingTriggerManager.CreateRatingProgress(Trigger.New);                
            }
        }   
         If(Trigger.IsDelete){
            If(Trigger.IsBefore){
                if(Trigger.old.size()==1){
                    // To calculate Not Transferred Rating Count and Candidate Transfer Status on Job 
                    RollUpCandidateFields.updateTransferCountonJobOnTrigger(Trigger.old);
                    // SSE-28260 To calculate Number of Participant and Respondent on Rating Deletion
                    if(Trigger.old[0].Rater_Type__c != 'Self'){
                        RollUpCandidateFields.calculateRatingsCountOnJobTrigger(Trigger.old);
                    }
                }
            }
        }   
        If(Trigger.IsDelete){
            If(Trigger.IsAfter){
                if(Trigger.old.size()==1){
                    //SSE-28262 To calculate the number of Rating records where the Candidate is listed as the Respondent. 
    				//Update Respondent Count field on Candidate.    
                   RollUpCandidateFields.calculateRespondentCountOnCandidate(Trigger.old); 
                    // SSE-28260 To delete the Candidate record only if it does not appear as a Focci or Rater on any Job
                   RollUpCandidateFields.deleteCandidateIfNoRatingExists(Trigger.old);
                }
            }
        }  
    }
}
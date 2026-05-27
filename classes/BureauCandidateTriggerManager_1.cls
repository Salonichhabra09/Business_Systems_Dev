/**************************************************************************************************************************************
CREATED BY :- RISHABH KANOTRA
CREATED DATE :- 25-07-2019
DESCRIPTION :- This class contains various validations and functionality to modify Bureau_Candidate__c and its fields refered from Bureau_Candidate triggers : before Insert,after Update,after Insert, after Delete
***************************************************************************************************************************************/ 
 
Global class BureauCandidateTriggerManager_1 {
    
    global BureauCandidateTriggerManager_1(){
        
    }
        //Commented class as for MS Lex Migration.
        //1.Delete all such ratings where candidates are Respondents 
      /*  public static void afterBureauCandidateDelete(List<Bureau_Candidate__c> oldCandidate){       
        
            Set<Id> candidateIds = new Set<Id>();
            Set<Id> jobIds = new Set<Id>();
            for(Bureau_Candidate__c candidate: oldCandidate)
            {
                candidateIds.add(candidate.Id);
                if(!jobIds.contains(candidate.Bureau_Job__c))
                jobIds.add(candidate.Bureau_Job__c);
            }    
            
            //Fetch the list of ratings where these candidates are Respondents    
            List<Bureau_Rating__c> ratingsAsRespondent = [SELECT Id FROM Bureau_Rating__c WHERE Rater_Type__c<>'Self' AND Respondent__c IN:candidateIds]; 
            
            //Delete all such ratings where these candidates are Respondents 
            if(ratingsAsRespondent.size()>0)
                delete ratingsAsRespondent;
            
            BureauJob_Manager.refreshRaterTypes(jobIds);
        
        }//afterBureauCandidateDelete
        
        //1.If Rater_Types__c is changed then refresh RaterTypes of Job__c
        public static void afterBureauCandidateUpdate(List<Bureau_Candidate__c> oldCandidate, List<Bureau_Candidate__c> newCandidate){ 
            
            Set<Id> jobIds = new Set<Id>();
            for(Integer i=0; i<newCandidate.size(); i++)
            {
                if(!jobIds.contains(newCandidate[i].Bureau_Job__c))
                {
                    if(newCandidate[i].Rater_Types__c<>oldCandidate[i].Rater_Types__c)
                        jobIds.add(newCandidate[i].Bureau_Job__c);
                }
            }  
            
            if(jobIds.size()>0)
            BureauJob_Manager.refreshRaterTypes(jobIds);
        
        
        }//afterBureauCandidateUpdate
        
        //1.Updating 'Sequence_No__c' of the candidate using 'Candidate_Max_Sequence_No_New__c' field.
        public static void beforeBureauCandidateInsert(List<Bureau_Candidate__c> newCandidate){ 
            // Set<Id> jobIds = new Set<Id>();
            // for(Bureau_Candidate__c candidate: newCandidate)
            // {
            //     if(!jobIds.contains(candidate.Bureau_Job__c))
            //     jobIds.add(candidate.Bureau_Job__c);
            // }

            // List<Job__c> jobsList = [SELECT Id, Candidate_Max_Sequence_No_New__c FROM Job__c WHERE Id IN:jobIds];
            // Map<Id, Decimal> jobsMap = new Map<Id, Decimal>();
            // for(Job__c job: jobsList)
            //     jobsMap.put(job.Id, job.Candidate_Max_Sequence_No_New__c );
            
            // for(Bureau_Candidate__c candidate: newCandidate)
            // {
            //     Decimal maxSequenceNo = jobsMap.get(candidate.Bureau_Job__c);
            //     candidate.Sequence_No__c = maxSequenceNo==null?1:maxSequenceNo + 1;
            //     jobsMap.put(candidate.Bureau_Job__c,candidate.Sequence_No__c);
            // }
            
            Map<Id, Integer> jobIdVsCandidateCount = new Map<Id, Integer>();
            Set<Id> jobIdSet = new Set<Id>();

            for(Bureau_Candidate__c candidate: newCandidate)
            {
                if(String.isNotEmpty(candidate.Bureau_Job__c))
                jobIdSet.add(candidate.Bureau_Job__c);
            }

            for(AggregateResult groupedResults : [SELECT COUNT(Id) Candidate_Count, Bureau_Job__c From Bureau_Candidate__c WHERE Bureau_Job__c IN :jobIdSet GROUP BY Bureau_Job__c]) {
                jobIdVsCandidateCount.put((Id) groupedResults.get('Bureau_Job__c'), (Integer) groupedResults.get('Candidate_Count'));
            }
            
            for(Bureau_Candidate__c candidate: newCandidate)
            {
                Integer maxSequenceNo = jobIdVsCandidateCount.get(candidate.Bureau_Job__c);
                candidate.Sequence_No__c = maxSequenceNo==null?1:maxSequenceNo + 1;
                jobIdVsCandidateCount.put(candidate.Bureau_Job__c,Integer.valueOf(candidate.Sequence_No__c));
            }
         
        }//beforeBureauCandidateInsert
        
        //1.Update 'Bureau_Candidate_Login__c' fields - 1.Bureau_Candidate__c 2.Bureau_System__c 3.Password__c
        //2.Using apex class 'BureauJob_Manager' refresh RaterTypes of Job__c.
        public static void afterBureauCandidateInsert(List<Bureau_Candidate__c> newCandidate){ 
        
            Set<Id> jobIds = new Set<Id>();
            for(Bureau_Candidate__c candidate: newCandidate)
            {
                if(!jobIds.contains(candidate.Bureau_Job__c))
                jobIds.add(candidate.Bureau_Job__c);
            }
            Map<Id,Job__c> jobMap = new Map<Id,Job__c>([SELECT Id,Name,Candidate_Username_Prefix__c,(SELECT Id, Name FROM Bureau_Systems__r) FROM Job__c WHERE Id IN:jobIds]);
            
            List<Bureau_Candidate_Login__c> candidateLogins = new List<Bureau_Candidate_Login__c>();
            for(Bureau_Candidate__c candidate: newCandidate)
            {
                Job__c job = jobMap.get(candidate.Bureau_Job__c);
                List<Bureau_System__c> systemsUsed = job.Bureau_Systems__r;
                for(Bureau_System__c systemUsed: systemsUsed)
                {
                    Bureau_Candidate_Login__c candidateLogin = new Bureau_Candidate_Login__c();
                    candidateLogin.Bureau_Candidate__c = candidate.Id;
                    candidateLogin.Bureau_System__c = systemUsed.Id;
                    candidateLogin.Password__c = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0,8).replace('0','h').replace('1','i').replace('2','j').replace('3','k').replace('4','l').replace('5','m').replace('6','n').replace('7','o').replace('8','p').replace('9','q');        
                    candidateLogins.add(candidateLogin);
                }
            }
            insert candidateLogins;
            
            BureauJob_Manager.refreshRaterTypes(jobIds);
        
        }//afterBureauCandidateInsert */
   
   }//BureauCandidateTriggerManager_1
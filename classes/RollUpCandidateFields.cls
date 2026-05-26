public class RollUpCandidateFields {
    
    public static Boolean skipTrigger = false;
    public static Integer maxSeqCount = 0;
    public static Integer passCount = 0;
    public static Integer failCount = 0;
    public static Integer dnaCount = 0;
    public static Integer completedCount = 0;
    public static Integer inProgressCount = 0;
    public static Integer notStartedCount = 0;
    public static String jobId ='';
    public static String status ='';
    public static String wrfId = '';
    public static String candidateId = '';
    public static Integer respondentCount = 0;
    
    public class wrapperClass {
        List<Job__c> jobList;
        List<AggregateResult> agrrResult;
    }
    
    public static void calculateCountFields(Map<Id,Bureau_Candidate__c> newCandidateMap) {
        System.debug('CalculateCountFields');
        
        Set<Id> jobIdSetForTAVocational = new Set<Id>();
        Set<Id> jobIdSetForTACorporate = new Set<Id>();
        Set<Id> jobIdSet = new Set<Id>();
        
        List<Bureau_Candidate__c> candidateList = [Select Id, Bureau_Job__c, Bureau_Job__r.MS_Line_of_Business__c, 
                                                   Bureau_Job__r.Candidate_Max_Sequence_No_New__c
                                                   FROM Bureau_Candidate__c
                                                   WHERE Id IN :newCandidateMap.keySet()];
        
        for(Bureau_Candidate__c candidate : candidateList) {
            String LOB = candidate.Bureau_Job__r.MS_Line_of_Business__c;
            System.debug('LOB ###'+LOB);
            System.debug('candidate.Bureau_Job__c ###'+candidate.Bureau_Job__c);
            jobIdSet.add(candidate.Bureau_Job__c);
            
            if(LOB.contains('TA - Vocational')) {
                jobIdSetForTAVocational.add(candidate.Bureau_Job__c);
            }
            
            if(LOB.contains('TA - Corporate')) {
                jobIdSetForTACorporate.add(candidate.Bureau_Job__c);
            }
        }
        System.debug('jobIdSet.size() ###'+jobIdSet.size());
        if(jobIdSet.size()>0) {
            wrapperClass obj = queryRecords(newCandidateMap, jobIdSet);
            System.debug('obj.jobList ####'+obj.jobList);
            System.debug('obj.agrrResult ####'+obj.agrrResult);
            calculateMaxSeqNo(obj.jobList, obj.agrrResult);
        }
        
        if(jobIdSetForTAVocational.size()>0) {
            wrapperClass obj = queryRecords(newCandidateMap, jobIdSetForTAVocational);
            calculateCountForTAVocational(obj.jobList, obj.agrrResult);
        }
        
        if(jobIdSetForTACorporate.size()>0) {
            wrapperClass obj = queryRecords(newCandidateMap, jobIdSetForTACorporate);
            calculateCountForTACorporate(obj.jobList, obj.agrrResult);
        }
        
    }
    
    public static wrapperClass queryRecords(Map<Id,Bureau_Candidate__c> newCandidateMap, Set<Id> jobIdSet) {
        
        List<Job__c> jobList = [SELECT Id, Candidate_Max_Sequence_No_New__c,
                                Count_of_Candidates_pass__c, Count_of_Candidates_fail__c,
                                Count_of_Candidates_DNA__c, Actual_Count_of_Candidates_PassFail__c,
                                Count_of_candidates_invited__c
                                FROM 	Job__c
                                WHERE 	Id IN :jobIdSet];
        
        List<AggregateResult> agrr = [SELECT Count(Id), Bureau_Job__c, Status2__c 
                                      FROM Bureau_Candidate__c
                                      WHERE Bureau_Job__c IN :jobIdSet
                                      AND Id IN :newCandidateMap.keySet()
                                      Group By Bureau_Job__c, Status2__c];
        
        wrapperClass obj = new wrapperClass();
        obj.jobList = jobList;
        obj.agrrResult = agrr;
        
        return obj;
    }
    
    public static void calculateMaxSeqNo(List<Job__c> jobList, List<AggregateResult> agrrResult) {
        System.debug('CanculateMazSeqNo');
        Map<String, Integer> maxSeqMap = new Map<String, Integer>();
        List<Job__c> jobListToUpdate = new List<Job__c>();
        for(AggregateResult agrr : agrrResult) {
            jobId = (String)agrr.get('Bureau_Job__c');
            maxSeqCount = (Integer)agrr.get('expr0');
            if(maxSeqMap.get(jobId)!=null) {
                maxSeqMap.put(jobId,maxSeqMap.get(jobId)+maxSeqCount);
            }
            else {
                maxSeqMap.put(jobId,maxSeqCount);
            }
        }
        for(Job__c jobObj : jobList) {
            
            System.debug('countJobMap.get(jobObj.Id) ####'+maxSeqMap.get(jobObj.Id));
            if(jobObj.Candidate_Max_Sequence_No_New__c == null) {
                jobObj.Candidate_Max_Sequence_No_New__c = maxSeqMap.get(jobObj.Id);
            }
            else {
                jobObj.Candidate_Max_Sequence_No_New__c = jobObj.Candidate_Max_Sequence_No_New__c + maxSeqMap.get(jobObj.Id);
            }
            jobListToUpdate.add(jobObj);
        }
        Database.update(jobListToUpdate);
    }
    
    public static void calculateCountForTAVocational(List<Job__c> jobList, List<AggregateResult> agrrResult) {
        System.debug('CalculateTAVocational');
        Map<String, Integer> passMap = new Map<String, Integer>(); 
        Map<String, Integer> failMap = new Map<String, Integer>(); 
        Map<String, Integer> dnaMap = new Map<String, Integer>();
        Map<String, Integer> actualMap = new Map<String, Integer>(); 
        Map<String, Integer> invitedMap = new Map<String, Integer>();
        List<Job__c> jobsToUpdate = new List<Job__c>();
        
        for(AggregateResult agrr : agrrResult) {
            
            jobId = (String)agrr.get('Bureau_Job__c');
            status = (String)agrr.get('Status2__c') ;
            System.debug('status ###'+status);
            if(status == 'Pass') {
                passCount = passCount+(Integer)agrr.get('expr0');
                if(passMap.get(jobId)!=null) {
                    passMap.put(jobId,passMap.get(jobId)+passCount);
                }
                else {
                    passMap.put(jobId,passCount);
                }
                if(actualMap.get(jobId)!=null) {
                    actualMap.put(jobId,actualMap.get(jobId)+passCount);
                }
                else {
                    actualMap.put(jobId,passCount);
                }
                if(invitedMap.get(jobId)!=null) {
                    invitedMap.put(jobId,invitedMap.get(jobId)+passCount);
                }
                else {
                    invitedMap.put(jobId,passCount);
                }
            }
            
            if(status == 'Fail') {
                failCount = failCount+(Integer)agrr.get('expr0');
                if(failMap.get(jobId)!=null) {
                    failMap.put(jobId,failMap.get(jobId)+failCount);
                }
                else {
                    failMap.put(jobId,failCount);
                }
                if(actualMap.get(jobId)!=null) {
                    actualMap.put(jobId,actualMap.get(jobId)+failCount);
                }
                else {
                    actualMap.put(jobId,failCount);
                }
                if(invitedMap.get(jobId)!=null) {
                    invitedMap.put(jobId,invitedMap.get(jobId)+failCount);
                }
                else {
                    invitedMap.put(jobId,failCount);
                }
            }
            
            if(status == 'DNA') {
                dnaCount = dnaCount+(Integer)agrr.get('expr0');
                if(dnaMap.get(jobId)!=null) {
                    dnaMap.put(jobId,dnaMap.get(jobId)+dnaCount);
                }
                else {
                    dnaMap.put(jobId,dnaCount);
                }
                if(invitedMap.get(jobId)!=null) {
                    invitedMap.put(jobId,invitedMap.get(jobId)+dnaCount);
                }
                else {
                    invitedMap.put(jobId,dnaCount);
                }
            }
        }
        
        for(Job__c jobObj : jobList) 
        {
            if(jobObj.Count_of_Candidates_pass__c==null && passMap.size()>0) {
                jobObj.Count_of_Candidates_pass__c = passMap.get(jobObj.Id);
            }
            else {
                if(passMap.size()>0) {
                    jobObj.Count_of_Candidates_pass__c = jobObj.Count_of_Candidates_pass__c+passMap.get(jobObj.Id);
                }
            }
            
            if(jobObj.Count_of_Candidates_fail__c==null && failMap.size()>0) {
                jobObj.Count_of_Candidates_fail__c = failMap.get(jobObj.Id);
            }
            else {
                if(failMap.size()>0) {
                    jobObj.Count_of_Candidates_fail__c = jobObj.Count_of_Candidates_fail__c+failMap.get(jobObj.Id);
                }
            }
            
            if(jobObj.Count_of_Candidates_DNA__c==null && dnaMap.size()>0) {
                jobObj.Count_of_Candidates_DNA__c = dnaMap.get(jobObj.Id);
            }
            else {
                if(dnaMap.size()>0) {
                    jobObj.Count_of_Candidates_DNA__c = jobObj.Count_of_Candidates_DNA__c+dnaMap.get(jobObj.Id);
                }
            }
            
            if(jobObj.Actual_Count_of_Candidates_PassFail__c==null && actualMap.size()>0) {
                jobObj.Actual_Count_of_Candidates_PassFail__c = actualMap.get(jobObj.Id);
            }
            else {
                if(actualMap.size()>0) {
                    jobObj.Actual_Count_of_Candidates_PassFail__c = jobObj.Actual_Count_of_Candidates_PassFail__c+actualMap.get(jobObj.Id);
                }
            }
            
            if(jobObj.Count_of_candidates_invited__c==null && invitedMap.size()>0) {
                jobObj.Count_of_candidates_invited__c = invitedMap.get(jobObj.Id);
            }
            else {
                if(invitedMap.size()>0) {
                    jobObj.Count_of_candidates_invited__c = jobObj.Count_of_candidates_invited__c+invitedMap.get(jobObj.Id);
                }
            }
            
            jobsToUpdate.add(jobObj);
        }
        if(jobsToUpdate.size()>0) {
            Database.update(jobsToUpdate);
        }
    }
    
    public static void calculateCountForTACorporate(List<Job__c> jobList, List<AggregateResult> agrrResult) {
        System.debug('CalculateTACorporate');
        List<Job__c> jobsToUpdate = new List<Job__c>();
        Map<String, Integer> invitedMap = new Map<String, Integer>(); 
        Map<String, Integer> actualMap = new Map<String, Integer>(); 
        
        for(AggregateResult agrr : agrrResult) {
            
            jobId = (String)agrr.get('Bureau_Job__c');
            status = (String)agrr.get('Status2__c') ;
            
            if(status == 'Completed') {
                completedCount = completedCount+(Integer)agrr.get('expr0');
                if(invitedMap.get(jobId)!=null) {
                    invitedMap.put(jobId,invitedMap.get(jobId)+completedCount);
                }
                else {
                    invitedMap.put(jobId,completedCount);
                }
                if(actualMap.get(jobId)!=null) {
                    actualMap.put(jobId,actualMap.get(jobId)+completedCount);
                }
                else {
                    actualMap.put(jobId,completedCount);
                }
            }
            
            if(status == 'In Progress') {
                inProgressCount = inProgressCount+(Integer)agrr.get('expr0');
                if(invitedMap.get(jobId)!=null) {
                    invitedMap.put(jobId,invitedMap.get(jobId)+inProgressCount);
                }
                else {
                    invitedMap.put(jobId,inProgressCount);
                }
            }
            
            if(status == 'Not Started') {
                notStartedCount = notStartedCount+(Integer)agrr.get('expr0');
                if(invitedMap.get(jobId)!=null) {
                    invitedMap.put(jobId,invitedMap.get(jobId)+notStartedCount);
                }
                else {
                    invitedMap.put(jobId,notStartedCount);
                }
            }
        }
        
        for(Job__c jobObj : jobList) 
        {
            if(jobObj.Actual_Count_of_Candidates_PassFail__c==null && actualMap.size()>0) {
                jobObj.Actual_Count_of_Candidates_PassFail__c = actualMap.get(jobObj.Id);
            }
            else {
                if(actualMap.size()>0) {
                    jobObj.Actual_Count_of_Candidates_PassFail__c = jobObj.Actual_Count_of_Candidates_PassFail__c+actualMap.get(jobObj.Id);
                }
            }
            
            if(jobObj.Count_of_candidates_invited__c==null && invitedMap.size()>0) {
                jobObj.Count_of_candidates_invited__c = invitedMap.get(jobObj.Id);
            }
            else {
                if(invitedMap.size()>0) {
                    jobObj.Count_of_candidates_invited__c = jobObj.Count_of_candidates_invited__c+invitedMap.get(jobObj.Id);
                }
            }
            jobsToUpdate.add(jobObj);
        }
        if(jobsToUpdate.size()>0) {
            Database.update(jobsToUpdate);
        }
    }
    

    public static void updateCandidateMaxSeqNoOnDelete(List<Bureau_Candidate__c> candidateList) {
        Set<Id> jobIdSet = new Set<Id>();
        List<Bureau_Candidate__c> passCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> failCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> dnaCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> completedCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> inProgressCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> notStartedCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> actualCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> invitedCandidate = new List<Bureau_Candidate__c>();
        List<Job__c> jobListToUpdate = new List<Job__c>(); 
        for(Bureau_Candidate__c candidate : candidateList) {
            jobIdSet.add(candidate.Bureau_Job__c);
            if(candidate.Status2__c == 'Pass') {
                passCandidate.add(candidate);
                actualCandidate.add(candidate);
                invitedCandidate.add(candidate);
            }
            if(candidate.Status2__c == 'Fail') {
                failCandidate.add(candidate);
                actualCandidate.add(candidate);
                invitedCandidate.add(candidate);
            }
            if(candidate.Status2__c == 'DNA') {
                dnaCandidate.add(candidate);
                actualCandidate.add(candidate);
                invitedCandidate.add(candidate);
            }
            if(candidate.Status2__c == 'Completed') {
                completedCandidate.add(candidate);
                actualCandidate.add(candidate);
                invitedCandidate.add(candidate);
            }
            if(candidate.Status2__c == 'In Progress') {
                inProgressCandidate.add(candidate);
                invitedCandidate.add(candidate);
            }
            if(candidate.Status2__c == 'Not Started') {
                notStartedCandidate.add(candidate);
                invitedCandidate.add(candidate);
            }
        }
        List<Job__c> jobList = [SELECT Id, Candidate_Max_Sequence_No_New__c,
                                		Count_of_Candidates_pass__c,
                                		Count_of_Candidates_fail__c,
                                		Count_of_Candidates_DNA__c, Actual_Count_of_Candidates_PassFail__c,
                                Count_of_candidates_invited__c, 
                                Not_Transferred_Candidate_Count__c, Transferred_Candidate_Count__c
                                FROM 	Job__c
                                WHERE 	Id IN :jobIdSet];
        System.debug('jobList ###'+jobList);
        System.debug('jobList Not_Transferred_Candidate_Count__c ###'+jobList[0].Not_Transferred_Candidate_Count__c);
        
        for(Job__c job : jobList) {
            if(job.Candidate_Max_Sequence_No_New__c>0) {
                Decimal tempMaxSeq = job.Candidate_Max_Sequence_No_New__c - candidateList.size();
                if(tempMaxSeq<0) {
                    job.Candidate_Max_Sequence_No_New__c = 0;
                }
                else {
                    job.Candidate_Max_Sequence_No_New__c = tempMaxSeq;
                }
            }
            if(job.Count_of_Candidates_pass__c != null && job.Count_of_Candidates_pass__c>0) {
                Decimal tempPass = job.Count_of_Candidates_pass__c - passCandidate.size();
                if(tempPass<0) {
                    job.Count_of_Candidates_pass__c = 0;
                }
                else {
                    job.Count_of_Candidates_pass__c = tempPass;
                }
            }
            if(job.Count_of_Candidates_fail__c!=null && job.Count_of_Candidates_fail__c>0) {
                Decimal tempFail = job.Count_of_Candidates_fail__c - failCandidate.size();
                if(tempFail<0) {
                    job.Count_of_Candidates_fail__c = 0;
                }
                else {
                    job.Count_of_Candidates_fail__c = tempFail;
                }
            }
            if(job.Count_of_Candidates_DNA__c!=null && job.Count_of_Candidates_DNA__c>0) {
                Decimal tempDNA = job.Count_of_Candidates_DNA__c - dnaCandidate.size();
                if(tempDNA<0) {
                    job.Count_of_Candidates_DNA__c = 0;
                }
                else {
                    job.Count_of_Candidates_DNA__c = tempDNA;
                }
            }
            if(job.Actual_Count_of_Candidates_PassFail__c!=null && job.Actual_Count_of_Candidates_PassFail__c>0) {
                Decimal tempActual = job.Actual_Count_of_Candidates_PassFail__c - actualCandidate.size();
                if(tempActual<0) {
                    job.Actual_Count_of_Candidates_PassFail__c = 0;
                }
                else {
                    job.Actual_Count_of_Candidates_PassFail__c = tempActual;
                }
            }
            if(job.Count_of_candidates_invited__c!=null && job.Count_of_candidates_invited__c>0) {
                Decimal tempInvited = job.Count_of_candidates_invited__c - invitedCandidate.size();
                if(tempInvited<0) {
                    job.Count_of_candidates_invited__c = 0;
                }
                else {
                    job.Count_of_candidates_invited__c = tempInvited;
                }
            }
            jobListToUpdate.add(job);
        }
        UPDATE jobListToUpdate;
    }
    
    public static void updateCountsOnJob(Map<Id,Bureau_Candidate__c> newCandidateMap, Map<Id,Bureau_Candidate__c> oldCandidateMap) 
    {
        Set<Id> jobIdSet = new Set<Id>();
        List<Bureau_Candidate__c> passCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> failCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> dnaCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> completedCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> inProgressCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> notStartedCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> actualCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> invitedCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> removePassCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> removefailCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> removednaCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> removecompletedCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> removeinProgressCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> removenotStartedCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> removeactualCandidate = new List<Bureau_Candidate__c>();
        List<Bureau_Candidate__c> removeinvitedCandidate = new List<Bureau_Candidate__c>();
        List<Job__c> jobListToUpdate = new List<Job__c>();
        
        for(Bureau_Candidate__c candidate : newCandidateMap.values()) {
            Bureau_Candidate__c oldCandidate = oldCandidateMap.get(candidate.Id);
            if(candidate.Status2__c!=oldCandidate.Status2__c) {
                jobIdSet.add(candidate.Bureau_Job__c);
                if(candidate.Status2__c == 'Pass') {
                    passCandidate.add(candidate);
                }
                if(candidate.Status2__c == 'Fail') {
                    failCandidate.add(candidate);
                }
                if(candidate.Status2__c == 'DNA') {
                    dnaCandidate.add(candidate);
                }
                if(candidate.Status2__c == 'Completed') {
                    completedCandidate.add(candidate);
                }
                if(candidate.Status2__c == 'In Progress') {
                    inProgressCandidate.add(candidate);
                }
                if(candidate.Status2__c == 'Not Started') {
                    notStartedCandidate.add(candidate);
                }
                
                if(oldcandidate.Status2__c == 'Pass') {
                    removePassCandidate.add(candidate);
                }
                if(oldcandidate.Status2__c == 'Fail') {
                    removefailCandidate.add(candidate);
                }
                if(oldcandidate.Status2__c == 'DNA') {
                    removednaCandidate.add(candidate);
                }
                if(oldcandidate.Status2__c == 'Completed') {
                    removecompletedCandidate.add(candidate);
                }
                if(oldcandidate.Status2__c == 'In Progress') {
                    removeinProgressCandidate.add(candidate);
                }
                if(oldcandidate.Status2__c == 'Not Started') {
                    removenotStartedCandidate.add(candidate);
                }
            }
        }
        
        List<Job__c> jobList = [SELECT Id, Candidate_Max_Sequence_No_New__c,
                                		Count_of_Candidates_pass__c,
                                		Count_of_Candidates_fail__c,
                                		Count_of_Candidates_DNA__c, 
                                		Actual_Count_of_Candidates_PassFail__c,
                                		Count_of_candidates_invited__c
                                FROM 	Job__c
                                WHERE 	Id IN :jobIdSet];
        System.debug('jobList ###'+jobList);
        
        for(Job__c job : jobList) {
            if(job.Count_of_Candidates_pass__c != null && job.Count_of_Candidates_pass__c>0 && passCandidate.size()>0) {
                job.Count_of_Candidates_pass__c = job.Count_of_Candidates_pass__c + passCandidate.size();
            }
            if(job.Count_of_Candidates_fail__c!=null && job.Count_of_Candidates_fail__c>0 && failCandidate.size()>0) {
                job.Count_of_Candidates_fail__c = job.Count_of_Candidates_fail__c + failCandidate.size();
            }
            if(job.Count_of_Candidates_DNA__c!=null && job.Count_of_Candidates_DNA__c>0 && dnaCandidate.size()>0) {
                job.Count_of_Candidates_DNA__c = job.Count_of_Candidates_DNA__c + dnaCandidate.size();
            }
            if(job.Count_of_Candidates_pass__c!=null && job.Count_of_Candidates_pass__c>0 && removePassCandidate.size()>0) {
                job.Count_of_Candidates_pass__c = job.Count_of_Candidates_pass__c - removePassCandidate.size();
            }
            if(job.Count_of_Candidates_fail__c!=null && job.Count_of_Candidates_fail__c>0 && removefailCandidate.size()>0) {
                job.Count_of_Candidates_fail__c = job.Count_of_Candidates_fail__c - removefailCandidate.size();
            }
            if(job.Count_of_Candidates_DNA__c!=null && job.Count_of_Candidates_DNA__c>0 && removednaCandidate.size()>0) {
                job.Count_of_Candidates_DNA__c = job.Count_of_Candidates_DNA__c - removednaCandidate.size();
            }
            jobListToUpdate.add(job);
        }
        UPDATE jobListToUpdate;
    }
    
    //Added By Shubham SSE-18102
    //Calculates Number_of_Assessments values on Job
    public static void updateRollupSummaryFieldsJobUpdate(List<Bureau_Candidate__c> candidateList, Map<id,Bureau_Candidate__c> oldMap){
        set<Id> jobIds =new Set<Id>();
        list<Job__c> updatedJobsList =new list<Job__c>(); 
        set<Id> candidateIds =new set<Id>();
        string MSLineofBusiness = 'Talent Management';
        system.debug('candidateList1'+candidateList[0]);
        for(Bureau_Candidate__c candidateRec : candidateList){
           if(candidateRec.Number_of_Product_Assessment__c !=  oldMap.get(candidateRec.id).Number_of_Product_Assessment__c || candidateRec.Bureau_Job__c !=  oldMap.get(candidateRec.id).Bureau_Job__c ||
             candidateRec.Number_of_participants__c !=  oldMap.get(candidateRec.id).Number_of_participants__c ||
             candidateRec.Number_of_Respondents__c !=  oldMap.get(candidateRec.id).Number_of_Respondents__c){  
             jobIds.add(candidateRec.Bureau_Job__c); 
             candidateIds.add(candidateRec.id);
           }
       }
        System.debug('jobIds*'+jobIds);
        System.debug('candidateIds*'+candidateIds);
       if(jobIds.size()>0){  
       for(Job__c JobRec : [Select id,Number_of_Assessments__c,Number_of_Participants_New__c,Number_of_Respondents_New__c,
                            (Select Number_of_Respondents__c,Number_of_Product_Assessment__c,Number_of_participants__c 
                             from Bureau_Candidates__r where id in: candidateIds) from Job__c 
                            where id in: jobIds and MS_Line_of_Business__c =: MSLineofBusiness]){
          System.debug('Assessment Count '+JobRec.Number_of_Assessments__c);
          JobRec.Number_of_Participants_New__c=JobRec.Number_of_Participants_New__c ==null ? 0 : JobRec.Number_of_Participants_New__c;
          JobRec.Number_of_Assessments__c=JobRec.Number_of_Assessments__c ==null ? 0 : JobRec.Number_of_Assessments__c;
          JobRec.Number_of_Respondents_New__c=JobRec.Number_of_Respondents_New__c ==null ? 0 : JobRec.Number_of_Respondents_New__c;
          
          for(Bureau_Candidate__c candidateRec : JobRec.Bureau_Candidates__r){
              System.debug('Number of Assessment of Candidate '+ oldMap.get(candidateRec.id).Number_of_Product_Assessment__c);
             if(oldMap.get(candidateRec.id).Number_of_Product_Assessment__c !=null) 
                JobRec.Number_of_Assessments__c -= oldMap.get(candidateRec.id).Number_of_Product_Assessment__c;  
             if(candidateRec.Number_of_Product_Assessment__c !=null)
                JobRec.Number_of_Assessments__c += candidateRec.Number_of_Product_Assessment__c;
             if(oldMap.get(candidateRec.id).Number_of_participants__c !=null) 
                JobRec.Number_of_Participants_New__c -= oldMap.get(candidateRec.id).Number_of_participants__c;  
             if(candidateRec.Number_of_participants__c !=null)
                JobRec.Number_of_Participants_New__c += candidateRec.Number_of_participants__c;
             if(oldMap.get(candidateRec.id).Number_of_Respondents__c !=null) 
                JobRec.Number_of_Respondents_New__c -= oldMap.get(candidateRec.id).Number_of_Respondents__c;  
             if(candidateRec.Number_of_Respondents__c !=null)
                JobRec.Number_of_Respondents_New__c += candidateRec.Number_of_Respondents__c;
          }
         updatedJobsList.add(JobRec);                     
     }
        if(updatedJobsList.size()>0){
           update updatedJobsList;
        }
      }       
    }
    
    //Added By Shubham SSE-18102
    //Calculates Number_of_Assessments values on Job
    public static void deleteRollupSummaryFieldsOnJob(List<Bureau_Candidate__c> candidateList){
       set<Id> jobIds =new Set<Id>();
       list<Job__c> updatedJobsList =new list<Job__c>(); 
       set<Id> candidateIds =new set<Id>();
       string MSLineofBusiness = 'Talent Management';
       for(Bureau_Candidate__c candidateRec : candidateList){
            jobIds.add(candidateRec.Bureau_Job__c); 
       }
       if(jobIds.size()>0){    
       for(Job__c JobRec : [Select id,Number_of_Assessments__c,Number_of_Respondents_New__c,Number_of_Participants_New__c,Not_Transferred_Candidate_Count__c, Transferred_Candidate_Count__c from Job__c where id in: jobIds and MS_Line_of_Business__c =: MSLineofBusiness ]){
           System.debug('JobRec Not_Transferred_Candidate_Count__c '+ JobRec.Not_Transferred_Candidate_Count__c);
          JobRec.Number_of_Assessments__c=JobRec.Number_of_Assessments__c ==null ? 0 : JobRec.Number_of_Assessments__c;
          JobRec.Number_of_Participants_New__c=JobRec.Number_of_Participants_New__c ==null ? 0 : JobRec.Number_of_Participants_New__c;
          JobRec.Number_of_Respondents_New__c=JobRec.Number_of_Respondents_New__c ==null ? 0 : JobRec.Number_of_Respondents_New__c;
          
          for(Bureau_Candidate__c candidateRec : candidateList){
            if(candidateRec.Number_of_Product_Assessment__c !=null){
                if(JobRec.Number_of_Assessments__c >= candidateRec.Number_of_Product_Assessment__c){
                  JobRec.Number_of_Assessments__c -= candidateRec.Number_of_Product_Assessment__c;  
                }else{
                  JobRec.Number_of_Assessments__c = 0;
                }     
            }
            if(candidateRec.Number_of_participants__c !=null){
                if(JobRec.Number_of_Participants_New__c >= candidateRec.Number_of_participants__c){
                  JobRec.Number_of_Participants_New__c -= candidateRec.Number_of_participants__c;  
                }else{
                  JobRec.Number_of_Participants_New__c = 0;
                }     
            }
            if(candidateRec.Number_of_Respondents__c !=null){
                if(JobRec.Number_of_Respondents_New__c >= candidateRec.Number_of_Respondents__c){
                  JobRec.Number_of_Respondents_New__c -= candidateRec.Number_of_Respondents__c;  
                }else{
                  JobRec.Number_of_Respondents_New__c = 0;
                }     
            }
       }
       updatedJobsList.add(JobRec);                     
   }
      if(updatedJobsList.size()>0){
         update updatedJobsList;
      }
   }
 }
     //Added By Shubham SSE-18102
    //Calculates Number_of_Assessments values on Job
    public static void updateRollupSummaryFieldsOnJob(List<Bureau_Candidate__c> candidateList){
        System.debug('updateRollupSummaryFieldsOnJob');
       set<Id> jobIds =new Set<Id>();
       list<Job__c> updatedJobsList =new list<Job__c>(); 
       set<Id> candidateIds =new set<Id>();
       string MSLineofBusiness = 'Talent Management';
       for(Bureau_Candidate__c candidateRec : candidateList){
            jobIds.add(candidateRec.Bureau_Job__c); 
            candidateIds.add(candidateRec.id);
       }
       if(jobIds.size()>0){    
       for(Job__c JobRec : [Select id,Number_of_Assessments__c,
                            Number_of_Respondents_New__c,
                            Number_of_Participants_New__c,
                            (Select Number_of_Respondents__c,
                             Number_of_Product_Assessment__c,
                             Number_of_participants__c 
                             from Bureau_Candidates__r 
                             where id in: candidateIds) 
                            from Job__c 
                            where id in: jobIds 
                            and MS_Line_of_Business__c =: MSLineofBusiness ])
       {
          JobRec.Number_of_Assessments__c=JobRec.Number_of_Assessments__c ==null ? 0 : JobRec.Number_of_Assessments__c;
          JobRec.Number_of_Participants_New__c=JobRec.Number_of_Participants_New__c ==null ? 0 : JobRec.Number_of_Participants_New__c;
          JobRec.Number_of_Respondents_New__c=JobRec.Number_of_Respondents_New__c ==null ? 0 : JobRec.Number_of_Respondents_New__c;
          JobRec.Status_Calculations__c = updateStatusCalculations(JobRec.Id);
          for(Bureau_Candidate__c candidateRec : JobRec.Bureau_Candidates__r){
            if(candidateRec.Number_of_Product_Assessment__c !=null){
               JobRec.Number_of_Assessments__c += candidateRec.Number_of_Product_Assessment__c;  
            }
            if(candidateRec.Number_of_participants__c !=null){
               JobRec.Number_of_Participants_New__c += candidateRec.Number_of_participants__c;  
            }
            if(candidateRec.Number_of_Respondents__c !=null){
               JobRec.Number_of_Respondents_New__c += candidateRec.Number_of_Respondents__c;
            }
          }
          updatedJobsList.add(JobRec);                     
      }
      if(updatedJobsList.size()>0){
         update updatedJobsList;
      }
   }
 }
    
    /* Methods for counts on WRF */
    
    public static void calculateCountFieldsWrf(Map<Id,Bureau_Candidate__c> newCandidateMap) {
        System.debug('CalculateCountFields');
        
        Set<Id> wrfIdSet = new Set<Id>();
        
        List<Bureau_Candidate__c> candidateList = [Select Id, Work_Request__c
                                                   FROM Bureau_Candidate__c
                                                   WHERE Id IN :newCandidateMap.keySet()];
        
        for(Bureau_Candidate__c candidate : candidateList) {
            System.debug('candidate.Work_Request__c ###'+candidate.Work_Request__c);
            wrfIdSet.add(candidate.Work_Request__c);
        }
        System.debug('wrfIdSet.size() ###'+wrfIdSet.size());
        
        if(wrfIdSet.size()>0) {
            WrapperClassWrf obj = queryRecordsWrf(newCandidateMap, wrfIdSet);
            System.debug('obj.wrfList ####'+obj.wrfList);
            System.debug('obj.agrrResult ####'+obj.agrrResult);
            calculateCountOfCandidatesCreatedOnWrf(obj.wrfList, obj.agrrResult);
        }    
    }
    
    public static void calculateCountOfCandidatesCreatedOnWrf(List<Work_Request__c> wrfList, List<AggregateResult> agrrResult) {
        System.debug('CanculateMazSeqNo');
        Map<String, Integer> maxSeqMap = new Map<String, Integer>();
        List<Work_Request__c> wrfListToUpdate = new List<Work_Request__c>();
        for(AggregateResult agrr : agrrResult) {
            wrfId = (String)agrr.get('Work_Request__c');
            maxSeqCount = (Integer)agrr.get('expr0');
            if(maxSeqMap.get(wrfId)!=null) {
                maxSeqMap.put(wrfId,maxSeqMap.get(wrfId)+maxSeqCount);
            }
            else {
                maxSeqMap.put(wrfId,maxSeqCount);
            }
        }
        for(Work_Request__c wrfObj : wrfList) {
            
            System.debug('countJobMap.get(wrfObj.Id) ####'+maxSeqMap.get(wrfObj.Id));
            if(wrfObj.No_of_Candidate_Created__c == null) {
                wrfObj.No_of_Candidate_Created__c = maxSeqMap.get(wrfObj.Id);
            }
            else {
                wrfObj.No_of_Candidate_Created__c = wrfObj.No_of_Candidate_Created__c + maxSeqMap.get(wrfObj.Id);
            }
            wrfListToUpdate.add(wrfObj);
        }
        Database.update(wrfListToUpdate);
    }
    
    public static WrapperClassWrf queryRecordsWrf(Map<Id,Bureau_Candidate__c> newCandidateMap, Set<Id> wrfIdSet) {
        
        List<Work_Request__c> wrfList = [SELECT Id, No_of_Candidate_Created__c
                                FROM Work_Request__c
                                WHERE Id IN :wrfIdSet];
        
        List<AggregateResult> agrr = [SELECT Count(Id), Work_Request__c 
                                      FROM Bureau_Candidate__c
                                      WHERE Work_Request__c IN :wrfIdSet
                                      AND Id IN :newCandidateMap.keySet()
                                      Group By Work_Request__c];
        
        WrapperClassWrf obj = new WrapperClassWrf();
        obj.wrfList = wrfList;
        obj.agrrResult = agrr;
        return obj;
    }
    
    public class WrapperClassWrf {
        List<Work_Request__c> wrfList;
        List<AggregateResult> agrrResult;
    }
    
    public static void updateRollupSummaryFieldsOnWRF(List<Bureau_Candidate__c> candidateList){
       set<Id> wrfIds =new Set<Id>();
       list<Work_Request__c> updatedWorkReqList =new list<Work_Request__c>(); 
       set<Id> candidateIds =new set<Id>();
       for(Bureau_Candidate__c candidateRec : candidateList){
            wrfIds.add(candidateRec.Work_Request__c); 
            candidateIds.add(candidateRec.id);
       }
       if(wrfIds.size()>0){    
       for(Work_Request__c workReqRec : [Select id,No_of_Participant_Created__c,
                            (Select Number_of_Respondents__c,
                             Number_of_Product_Assessment__c,
                             Number_of_participants__c 
                             from Managed_Services_Candidates__r 
                             where id in: candidateIds) 
                            from Work_Request__c 
                            where id in: wrfIds ])
       {
          workReqRec.No_of_Participant_Created__c = workReqRec.No_of_Participant_Created__c ==null ? 0 : workReqRec.No_of_Participant_Created__c;
          
          for(Bureau_Candidate__c candidateRec : workReqRec.Managed_Services_Candidates__r){
            if(candidateRec.Number_of_participants__c !=null){
               workReqRec.No_of_Participant_Created__c += candidateRec.Number_of_participants__c;  
            }
          }
          updatedWorkReqList.add(workReqRec);                     
      }
      if(updatedWorkReqList.size()>0){
         update updatedWorkReqList;
      }
   }
 }
    
    public static void updateRollupSummaryFieldsWRFUpdate(List<Bureau_Candidate__c> candidateList, Map<id,Bureau_Candidate__c> oldMap){
        set<Id> wrfIds =new Set<Id>();
        list<Work_Request__c> updatedWorkRequestsList =new list<Work_Request__c>(); 
        set<Id> candidateIds =new set<Id>();
        system.debug('candidateList1'+candidateList[0]);
        for(Bureau_Candidate__c candidateRec : candidateList){
            /* Commented below code as we don't need to check below conditions to fix SSE-26836 */
           /*if(candidateRec.Number_of_Product_Assessment__c !=  oldMap.get(candidateRec.id).Number_of_Product_Assessment__c || 
              candidateRec.Bureau_Job__c !=  oldMap.get(candidateRec.id).Bureau_Job__c ||
             candidateRec.Number_of_participants__c !=  oldMap.get(candidateRec.id).Number_of_participants__c ||
             candidateRec.Number_of_Respondents__c !=  oldMap.get(candidateRec.id).Number_of_Respondents__c){  
             wrfIds.add(candidateRec.Work_Request__c); 
             candidateIds.add(candidateRec.id);
           }*/
            wrfIds.add(candidateRec.Work_Request__c); 
            candidateIds.add(candidateRec.id);
       }
        
       if(wrfIds.size()>0){  
       for(Work_Request__c wrfRec : [Select id,No_of_Participant_Created__c,Status__c,(Select Number_of_Respondents__c,
                                     Number_of_Product_Assessment__c,Number_of_participants__c from Managed_Services_Candidates__r
                                     where id in: candidateIds) from Work_Request__c 
                                     where id in: wrfIds]){
          wrfRec.No_of_Participant_Created__c=wrfRec.No_of_Participant_Created__c ==null ? 0 : wrfRec.No_of_Participant_Created__c;
          
          for(Bureau_Candidate__c candidateRec : wrfRec.Managed_Services_Candidates__r){
             if(oldMap.get(candidateRec.id).Number_of_participants__c !=null) 
                wrfRec.No_of_Participant_Created__c -= oldMap.get(candidateRec.id).Number_of_participants__c;  
             if(candidateRec.Number_of_participants__c !=null)
                wrfRec.No_of_Participant_Created__c += candidateRec.Number_of_participants__c;
          }
          wrfRec.Status__c = 'Completed';
         updatedWorkRequestsList.add(wrfRec);                     
     }
        if(updatedWorkRequestsList.size()>0){
           update updatedWorkRequestsList;
        }
      }       
    }
    
    public static void calculateCountFieldsForManualCandidateLinking(Map<Id,Bureau_Candidate__c> newCandidateMap) {
        System.debug('CalculateCountFields');
        
        Set<Id> jobIdSet = new Set<Id>();
        
        List<Bureau_Candidate__c> candidateList = [Select Id, Bureau_Job__c, Bureau_Job__r.MS_Line_of_Business__c, 
                                                   Bureau_Job__r.Candidate_Max_Sequence_No_New__c
                                                   FROM Bureau_Candidate__c
                                                   WHERE Id IN :newCandidateMap.keySet()];
        
        for(Bureau_Candidate__c candidate : candidateList) {
            String LOB = candidate.Bureau_Job__r.MS_Line_of_Business__c;
            System.debug('LOB ###'+LOB);
            System.debug('candidate.Bureau_Job__c ###'+candidate.Bureau_Job__c);
            jobIdSet.add(candidate.Bureau_Job__c);
        }
        System.debug('jobIdSet.size() ###'+jobIdSet.size());
        if(jobIdSet.size()>0) {
            wrapperClass obj = queryRecords(newCandidateMap, jobIdSet);
            System.debug('obj.jobList ####'+obj.jobList);
            System.debug('obj.agrrResult ####'+obj.agrrResult);
            calculateMaxSeqNoManual(obj.jobList, obj.agrrResult);
        }
    }
    
    public static void calculateMaxSeqNoManual(List<Job__c> jobList, List<AggregateResult> agrrResult) {
        System.debug('CanculateMazSeqNo');
        Map<String, Integer> maxSeqMap = new Map<String, Integer>();
        List<Job__c> jobListToUpdate = new List<Job__c>();
        for(AggregateResult agrr : agrrResult) {
            jobId = (String)agrr.get('Bureau_Job__c');
            maxSeqCount = (Integer)agrr.get('expr0');
            if(maxSeqMap.get(jobId)!=null) {
                maxSeqMap.put(jobId,maxSeqMap.get(jobId)+maxSeqCount);
            }
            else {
                maxSeqMap.put(jobId,maxSeqCount);
            }
        }
        for(Job__c jobObj : jobList) {
            System.debug('countJobMap.get(jobObj.Id) ####'+maxSeqMap.get(jobObj.Id));
            jobObj.Candidate_Max_Sequence_No_New__c = maxSeqMap.get(jobObj.Id);
            jobListToUpdate.add(jobObj);
        }
        Database.update(jobListToUpdate);
    }
    
    public static void updateRollupSummaryFieldsOnJobForManualCandidateLinking(List<Bureau_Candidate__c> candidateList){
        System.debug('updateRollupSummaryFieldsOnJob');
       set<Id> jobIds =new Set<Id>();
       list<Job__c> updatedJobsList =new list<Job__c>(); 
       set<Id> candidateIds =new set<Id>();
       string MSLineofBusiness = 'Talent Management';
       for(Bureau_Candidate__c candidateRec : candidateList){
            jobIds.add(candidateRec.Bureau_Job__c); 
            candidateIds.add(candidateRec.id);
       }
       if(jobIds.size()>0){    
       for(Job__c JobRec : [Select id,Number_of_Assessments__c,
                            Number_of_Respondents_New__c,
                            Number_of_Participants_New__c,
                            (Select Number_of_Respondents__c,
                             Number_of_Product_Assessment__c,
                             Number_of_participants__c 
                             from Bureau_Candidates__r 
                             where id in: candidateIds) 
                            from Job__c 
                            where id in: jobIds 
                            and MS_Line_of_Business__c =: MSLineofBusiness ])
       {
          JobRec.Number_of_Assessments__c=0;
          JobRec.Number_of_Participants_New__c=0;
          JobRec.Number_of_Respondents_New__c=0;
          
          for(Bureau_Candidate__c candidateRec : JobRec.Bureau_Candidates__r){
            if(candidateRec.Number_of_Product_Assessment__c !=null){
               JobRec.Number_of_Assessments__c += candidateRec.Number_of_Product_Assessment__c;  
            }
            if(candidateRec.Number_of_participants__c !=null){
               JobRec.Number_of_Participants_New__c += candidateRec.Number_of_participants__c;  
            }
            if(candidateRec.Number_of_Respondents__c !=null){
               JobRec.Number_of_Respondents_New__c += candidateRec.Number_of_Respondents__c;
            }
          }
          updatedJobsList.add(JobRec);                     
      }
      if(updatedJobsList.size()>0){
         update updatedJobsList;
      }
   }
 }
    
    public static void deleteRollupSummaryFieldsOnWRF(List<Bureau_Candidate__c> candidateList){
       set<Id> wrfIds =new Set<Id>();
       list<Work_Request__c> updatedWrfList =new list<Work_Request__c>(); 
       set<Id> candidateIds =new set<Id>();
       for(Bureau_Candidate__c candidateRec : candidateList){
            wrfIds.add(candidateRec.Work_Request__c); 
       }
       if(wrfIds.size()>0){    
       for(Work_Request__c wrfRec : [Select id,Status__c, No_of_Candidate_Created__c, No_of_Participant_Created__c
                                     from Work_Request__c where id in: wrfIds]){
          wrfRec.No_of_Candidate_Created__c = wrfRec.No_of_Candidate_Created__c == null ? 0 : wrfRec.No_of_Candidate_Created__c;
          wrfRec.No_of_Participant_Created__c = wrfRec.No_of_Participant_Created__c == null ? 0 : wrfRec.No_of_Participant_Created__c;
          
          for(Bureau_Candidate__c candidateRec : candidateList){
            if(candidateRec.Number_of_participants__c !=null){
                if(wrfRec.No_of_Participant_Created__c >= candidateRec.Number_of_participants__c){
                  wrfRec.No_of_Participant_Created__c -= candidateRec.Number_of_participants__c;  
                }else{
                  wrfRec.No_of_Participant_Created__c = 0;
                  wrfRec.Status__c = 'Cancelled';
                }     
            }
            if(wrfRec.No_of_Candidate_Created__c > 0) {
                Decimal tempMaxSeq = wrfRec.No_of_Candidate_Created__c - candidateList.size();
                if(tempMaxSeq<0) {
                    wrfRec.No_of_Candidate_Created__c = 0;
                    wrfRec.Status__c = 'Cancelled';
                }
                else {
                    wrfRec.No_of_Candidate_Created__c = tempMaxSeq;
                }
            }
       }
       updatedWrfList.add(wrfRec);                     
   }
      if(updatedWrfList.size()>0){
         update updatedWrfList;
      }
   }
 }
    public class StatusWrapper {
        public Map<String, Integer> MFS_Status { get; set; }
        public Map<String, Integer> Insights_Status { get; set; }
        public Map<String, Integer> VADC_Status { get; set; }
        public Map<String, Integer> TC_Status { get; set; }
    }
    
    public static String updateStatusCalculations(Id jobId){
        Map<String, Integer> mfsStatusMap = new Map<String, Integer>();
        Map<String, Integer> vadcStatusMap = new Map<String, Integer>();
        Map<String, Integer> insightsStatusMap = new Map<String, Integer>();
        Map<String, Integer> tcStatusMap = new Map<String, Integer>();
        
        List<AggregateResult> mfsStatusCount = [SELECT MFS_status__c, COUNT(Id) FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =: jobId GROUP BY MFS_status__c];
        for(AggregateResult ar : mfsStatusCount){
            String Status = (String) ar.get('MFS_status__c');
            Integer count = (Integer) ar.get('expr0');
             if(Status!=null){
            mfsStatusMap.put(Status, count);
             }
        }
        List<AggregateResult> VADCStatusCount = [SELECT VADC_status__c, COUNT(Id) FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =: jobId GROUP BY VADC_status__c];
        for(AggregateResult ar : VADCStatusCount){
            String Status = (String) ar.get('VADC_status__c');
            Integer count = (Integer) ar.get('expr0');
            if(Status!=null){
                vadcStatusMap.put(Status, count);
            }
            
        }
        
        List<AggregateResult> TCtatusCount = [SELECT TC_Status__c, COUNT(Id) FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =: jobId GROUP BY TC_Status__c];
        for(AggregateResult ar : TCtatusCount){
            String Status = (String) ar.get('TC_Status__c');
            Integer count = (Integer) ar.get('expr0');
            if(Status!=null){
                tcStatusMap.put(Status, count);
            }
            
        }
        
        List<AggregateResult> InsightstatusCount = [SELECT Insights_Status__c, COUNT(Id) FROM Bureau_Rating__c WHERE Participant__r.Bureau_Job__c =: jobId GROUP BY Insights_Status__c];
        for(AggregateResult ar : InsightstatusCount){
            String Status = (String) ar.get('Insights_Status__c');
            Integer count = (Integer) ar.get('expr0');
            if(Status!=null){
                insightsStatusMap.put(Status, count);
            }
            
        }  
        StatusWrapper wrapper = new StatusWrapper();
        if(!mfsStatusMap.isEmpty()){
            wrapper.MFS_Status = mfsStatusMap;    
        }
        if(!vadcStatusMap.isEmpty()){
            wrapper.VADC_status = vadcStatusMap;    
        }
        if(!insightsStatusMap.isEmpty()){
            wrapper.Insights_Status = insightsStatusMap;    
        }
        if(!tcStatusMap.isEmpty()){
            wrapper.TC_Status = tcStatusMap;    
        }
        System.debug('json Wrapper '+wrapper);
        String jsonString = JSON.serialize(wrapper);
        System.debug('jsonString '+jsonString);
        return jsonString;
        
    }
    
    // SSE-28260 Calculate Number of Participant and Respondent on Rating Deletion
    public static void calculateRatingsCountOnJob(Id jobId, list<Bureau_Rating__c> ratingList){
        
        if (jobId == null || ratingList == null || ratingList.isEmpty()) return;
        
        Job__c jobRecord = [SELECT id,Number_of_Assessments__c,Number_of_Respondents_New__c,Number_of_Participants_New__c 
                            FROM Job__c 
                            WHERE Id = :jobId
                            LIMIT 1];
        
        Integer participantDecrement = 0;
        Integer respondentDecrement = 0;
        
        for (Bureau_Rating__c rating : ratingList) {
            if (rating.Rater_Type__c == 'Self') {
                participantDecrement++;
            } else {
                respondentDecrement++;
            }
        }
        System.debug('Aashi Before Cal --> '+ jobRecord.Number_of_Participants_New__c);
        jobRecord.Number_of_Participants_New__c = jobRecord.Number_of_Participants_New__c != null ? (jobRecord.Number_of_Participants_New__c- participantDecrement) : 0;
        jobRecord.Number_of_Respondents_New__c = jobRecord.Number_of_Respondents_New__c != null ? (jobRecord.Number_of_Respondents_New__c - respondentDecrement) : 0;
        //jobRecord.Number_of_Assessments__c = jobRecord.Number_of_Product_Assessment__c != null ? (jobRecord.Number_of_Product_Assessment__c - respondentDecrement) : 0;
        System.debug('Aashi After Cal --> '+ jobRecord.Number_of_Participants_New__c);
        UPDATE jobRecord;
    }
    
    // SSE-28260 Calculate Number of Participant and Respondent on Rating Deletion
    public static void calculateRatingsCountOnJobTrigger(list<Bureau_Rating__c> ratingList){
        
        if (ratingList == null || ratingList.isEmpty()) return;
        Id ratingId = ratingList[0].Id;
        list<Bureau_Rating__c> deletedRatings = [SELECT Id, Bureau_Job__c FROM Bureau_Rating__c WHERE Id IN :ratingList];
        Id jobId = deletedRatings[0].Bureau_Job__c;
        Job__c jobRecord = [SELECT id,Number_of_Assessments__c,Number_of_Respondents_New__c,Number_of_Participants_New__c 
                            FROM Job__c 
                            WHERE Id = :jobId
                            LIMIT 1];
        
        Integer participantDecrement = 0;
        Integer respondentDecrement = 0;
        
        for (Bureau_Rating__c rating : ratingList) {
            if (rating.Rater_Type__c == 'Self') {
                participantDecrement++;
            } else {
                respondentDecrement++;
            }
        }
        System.debug('Aashi Before Cal in trigger --> '+ jobRecord.Number_of_Participants_New__c);
        jobRecord.Number_of_Participants_New__c = jobRecord.Number_of_Participants_New__c != null ? (jobRecord.Number_of_Participants_New__c- participantDecrement) : 0;
        jobRecord.Number_of_Respondents_New__c = jobRecord.Number_of_Respondents_New__c != null ? (jobRecord.Number_of_Respondents_New__c - respondentDecrement) : 0;
        //jobRecord.Number_of_Assessments__c = jobRecord.Number_of_Product_Assessment__c != null ? (jobRecord.Number_of_Product_Assessment__c - respondentDecrement) : 0;
        System.debug('Aashi After Cal in trigger --> '+ jobRecord.Number_of_Participants_New__c);
        UPDATE jobRecord;
    }
	
	// Calculate Not Transferred Rating Count and Candidate Transfer Status on Job (This will run for all the ratings linked to Job) 
    public static void updateTransferCountonJob(List<Bureau_Rating__c> ratingScope){
        Map<Id,Integer> JobRatingTransferredCount = new Map<Id,Integer>();
        Map<Id,Integer> JobRatingNotTransferredCount = new Map<Id,Integer>();
        List<Job__c> JobsToUpdate = new List<Job__c>();
        Set<Id> JobIds = new Set<Id>();
        for(Bureau_Rating__c rating:ratingScope){
            if (rating.Rating_Transfer_Status__c == 'Not Transferred') {
                if(JobRatingNotTransferredCount.containskey(rating.Participant__r.Bureau_Job__c)){
                    JobRatingNotTransferredCount.put(rating.Participant__r.Bureau_Job__c,JobRatingNotTransferredCount.get(rating.Participant__r.Bureau_Job__c)+1);
                }
                else{
                    JobRatingNotTransferredCount.put(rating.Participant__r.Bureau_Job__c,1);
                }
            }
            if (rating.Rating_Transfer_Status__c == 'Transferred') {
                if(JobRatingTransferredCount.containskey(rating.Participant__r.Bureau_Job__c)){
                    JobRatingTransferredCount.put(rating.Participant__r.Bureau_Job__c,JobRatingTransferredCount.get(rating.Participant__r.Bureau_Job__c)+1);
                }
                else{
                    JobRatingTransferredCount.put(rating.Participant__r.Bureau_Job__c,1);
                }
            }
        }
        
        For(Id job:JobRatingTransferredCount.keyset()){
            JobIds.add(job);
        }
        For(Id job:JobRatingNotTransferredCount.keyset()){
            JobIds.add(job);
        }
        if(!JobIds.isEmpty()){
            List<Job__c> JobRecords = [select id,Transferred_Candidate_Count__c,Not_Transferred_Candidate_Count__c,Candidate_Transfer_Status__c from Job__C where id in:JobIds];
            for(Job__c job:JobRecords){
                if(JobRatingTransferredCount.get(job.Id) != null && job.Transferred_Candidate_Count__c != null){
                    job.Transferred_Candidate_Count__c = job.Transferred_Candidate_Count__c-JobRatingTransferredCount.get(job.Id);
                }
                if(JobRatingNotTransferredCount.get(job.Id)!=null && job.Not_Transferred_Candidate_Count__c != null){
                    job.Not_Transferred_Candidate_Count__c = job.Not_Transferred_Candidate_Count__c-JobRatingNotTransferredCount.get(job.Id);
                }
               
               if(job.Not_Transferred_Candidate_Count__c != null && job.Not_Transferred_Candidate_Count__c != 0 && job.Transferred_Candidate_Count__c!=null && job.Transferred_Candidate_Count__c!=0){
                    if(job.Candidate_Transfer_Status__c!='Sent to FTP with error')
                        job.Candidate_Transfer_Status__c = 'Sent to FTP with error';
                }
                if((job.Not_Transferred_Candidate_Count__c == null || job.Not_Transferred_Candidate_Count__c == 0) && job.Transferred_Candidate_Count__c!=null && job.Transferred_Candidate_Count__c!=0){
                    if(job.Candidate_Transfer_Status__c!='Sent to FTP')
                        job.Candidate_Transfer_Status__c = 'Sent to FTP';
                }
                JobsToUpdate.add(job);
            }
            update JobsToUpdate;   
        }
    }
    
    // Calculate Not Transferred Rating Count and Candidate Transfer Status on Job (This will run for single rating only)
    public static void updateTransferCountonJobOnTrigger(List<Bureau_Rating__c> ratingScope){
        Map<Id,Integer> JobRatingTransferredCount = new Map<Id,Integer>();
        Map<Id,Integer> JobRatingNotTransferredCount = new Map<Id,Integer>();
        List<Job__c> JobsToUpdate = new List<Job__c>();
        Set<Id> JobIds = new Set<Id>();
        List<Bureau_Rating__c> DeletedRatings = [select id,Rating_Transfer_Status__c,Participant__r.Bureau_Job__c from Bureau_Rating__c where id in:ratingScope];
        for(Bureau_Rating__c rating:DeletedRatings){
            if (rating.Rating_Transfer_Status__c == 'Not Transferred') {
                if(JobRatingNotTransferredCount.containskey(rating.Participant__r.Bureau_Job__c)){
                    JobRatingNotTransferredCount.put(rating.Participant__r.Bureau_Job__c,JobRatingNotTransferredCount.get(rating.Participant__r.Bureau_Job__c)+1);
                }
                else{
                    JobRatingNotTransferredCount.put(rating.Participant__r.Bureau_Job__c,1);
                }
            }
            if (rating.Rating_Transfer_Status__c == 'Transferred') {
                if(JobRatingTransferredCount.containskey(rating.Participant__r.Bureau_Job__c)){
                    JobRatingTransferredCount.put(rating.Participant__r.Bureau_Job__c,JobRatingTransferredCount.get(rating.Participant__r.Bureau_Job__c)+1);
                }
                else{
                    JobRatingTransferredCount.put(rating.Participant__r.Bureau_Job__c,1);
                }
            }
        }
        
        For(Id job:JobRatingTransferredCount.keyset()){
            JobIds.add(job);
        }
        For(Id job:JobRatingNotTransferredCount.keyset()){
            JobIds.add(job);
        }
        
        if(!JobIds.isEmpty()){
            List<Job__c> JobRecords = [select id,Transferred_Candidate_Count__c,Not_Transferred_Candidate_Count__c,Candidate_Transfer_Status__c from Job__C where id in:JobIds];
            for(Job__c job:JobRecords){
                if(JobRatingTransferredCount.get(job.Id) != null && job.Transferred_Candidate_Count__c != null){
                    job.Transferred_Candidate_Count__c = job.Transferred_Candidate_Count__c-JobRatingTransferredCount.get(job.Id);
                }
                if(JobRatingNotTransferredCount.get(job.Id)!=null && job.Not_Transferred_Candidate_Count__c != null){
                    job.Not_Transferred_Candidate_Count__c = job.Not_Transferred_Candidate_Count__c-JobRatingNotTransferredCount.get(job.Id);
                }
              if(job.Not_Transferred_Candidate_Count__c != null && job.Not_Transferred_Candidate_Count__c != 0 && job.Transferred_Candidate_Count__c!=null && job.Transferred_Candidate_Count__c!=0){
                    if(job.Candidate_Transfer_Status__c!='Sent to FTP with error')
                        job.Candidate_Transfer_Status__c = 'Sent to FTP with error';
                }
                if((job.Not_Transferred_Candidate_Count__c == null || job.Not_Transferred_Candidate_Count__c == 0) && job.Transferred_Candidate_Count__c!=null && job.Transferred_Candidate_Count__c!=0){
                    if(job.Candidate_Transfer_Status__c!='Sent to FTP')
                        job.Candidate_Transfer_Status__c = 'Sent to FTP';
                }
                JobsToUpdate.add(job);
            }
            update JobsToUpdate;
        }
        
                
    }
    
    // Calculate Not Transferred Rating Count and Candidate Transfer Status on Job (This will run for ratings created from WRF)
    public static void updateTransferCountonJobOnNewWorkRequest(List<Bureau_Rating__c> ratingScope){
        Map<Id,Integer> JobRatingTransferredCount = new Map<Id,Integer>();
        Map<Id,Integer> JobRatingNotTransferredCount = new Map<Id,Integer>();
        List<Job__c> JobsToUpdate = new List<Job__c>();
        Set<Id> JobIds = new Set<Id>();
        
        for(Bureau_Rating__c rating:ratingScope){
            if (rating.Rating_Transfer_Status__c == 'Not Transferred') {
                if(JobRatingNotTransferredCount.containskey(rating.Participant__r.Bureau_Job__c)){
                    JobRatingNotTransferredCount.put(rating.Participant__r.Bureau_Job__c,JobRatingNotTransferredCount.get(rating.Participant__r.Bureau_Job__c)+1);
                }
                else{
                    JobRatingNotTransferredCount.put(rating.Participant__r.Bureau_Job__c,1);
                }
            }
            if (rating.Rating_Transfer_Status__c == 'Transferred') {
                if(JobRatingTransferredCount.containskey(rating.Participant__r.Bureau_Job__c)){
                    JobRatingTransferredCount.put(rating.Participant__r.Bureau_Job__c,JobRatingTransferredCount.get(rating.Participant__r.Bureau_Job__c)+1);
                }
                else{
                    JobRatingTransferredCount.put(rating.Participant__r.Bureau_Job__c,1);
                }
            }
        }
        
        For(Id job:JobRatingTransferredCount.keyset()){
            JobIds.add(job);
        }
        For(Id job:JobRatingNotTransferredCount.keyset()){
            JobIds.add(job);
        }
        if(!JobIds.isEmpty()){
            List<Job__c> JobRecords = [select id,Transferred_Candidate_Count__c,Not_Transferred_Candidate_Count__c,Candidate_Transfer_Status__c from Job__C where id in:JobIds];
            for(Job__c job:JobRecords){
                if(JobRatingTransferredCount.get(job.Id) != null){
                    if(job.Transferred_Candidate_Count__c == null){
                        job.Transferred_Candidate_Count__c = 0;
                    }
                    job.Transferred_Candidate_Count__c = job.Transferred_Candidate_Count__c+JobRatingTransferredCount.get(job.Id);
                }
                if(JobRatingNotTransferredCount.get(job.Id)!=null){
                    if(job.Not_Transferred_Candidate_Count__c == null){
                        job.Not_Transferred_Candidate_Count__c = 0;
                    }
                    job.Not_Transferred_Candidate_Count__c = job.Not_Transferred_Candidate_Count__c+JobRatingNotTransferredCount.get(job.Id);
                }
                if(job.Not_Transferred_Candidate_Count__c != null && job.Not_Transferred_Candidate_Count__c != 0 && job.Transferred_Candidate_Count__c!=null && job.Transferred_Candidate_Count__c!=0){
                    if(job.Candidate_Transfer_Status__c!='Sent to FTP with error')
                        job.Candidate_Transfer_Status__c = 'Sent to FTP with error';
                }
                if((job.Not_Transferred_Candidate_Count__c == null || job.Not_Transferred_Candidate_Count__c == 0) && job.Transferred_Candidate_Count__c!=null && job.Transferred_Candidate_Count__c!=0){
                    if(job.Candidate_Transfer_Status__c!='Sent to FTP')
                        job.Candidate_Transfer_Status__c = 'Sent to FTP';
                }
       
                JobsToUpdate.add(job);
            }
            update JobsToUpdate;
            
        }
       
        
    }
    
    //SSE-28262 Calculates the number of Rating records where the Candidate is listed as the Respondent. 
    //Update Respondent Count field on Candidate.    
    public static void calculateRespondentCountOnCandidate(list<Bureau_Rating__c> ratingList){
        
        list<Bureau_Candidate__c> candidateListToUpdate = new list<Bureau_Candidate__c>();
        Map<Id, Integer> respondentCountMap = new Map<Id, Integer>();
        Set<Id> candidateIdSet = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();
        
        if (ratingList == null || ratingList.isEmpty()) return;
        
        for(Bureau_Rating__c rating : ratingList){
            candidateIdSet.add(rating.Respondent__c);
        }
        List<AggregateResult> agrrResult = [SELECT count(Id), Respondent__c FROM Bureau_Rating__c WHERE Respondent__c IN :candidateIdSet GROUP BY Respondent__c]; 
        
        if(!agrrResult.isEmpty()){
            for(AggregateResult agrr : agrrResult) {
                candidateId = (Id)agrr.get('Respondent__c');
                respondentCount = (Integer)agrr.get('expr0');
                if(respondentCountMap.get(candidateId)!=null) {
                    respondentCountMap.put(candidateId, respondentCountMap.get(candidateId)+respondentCount);
                }
                else {
                    respondentCountMap.put(candidateId, respondentCount);
                }
            }
        }else{
            if(!candidateIdSet.isEmpty()){
                for(Id candidateId : candidateIdSet){
                    respondentCountMap.put(candidateId, 0);   
                }  
            }
            
        }
        
        if(!respondentCountMap.isEmpty()){
            for (Id candidateId : candidateIdSet) {
                if(respondentCountMap.get(candidateId) != null){
                    Bureau_Candidate__c candidate = new Bureau_Candidate__c(Id=candidateId);
                    candidate.Respondent_Count__c = respondentCountMap.get(candidateId);
                    candidateListToUpdate.add(candidate);
                }else{
                    Bureau_Candidate__c candidate = new Bureau_Candidate__c(Id=candidateId);
                    candidate.Respondent_Count__c = 0;
                    candidateListToUpdate.add(candidate);
                }
            } 
        }
        System.debug('candidateListToUpdate --> '+ candidateListToUpdate[0].Respondent_Count__c);
        if(!candidateListToUpdate.isEmpty())
            UPDATE candidateListToUpdate;
    }
    
    // SSE-28260 Delete the Candidate record only if it does not appear as a Focci or Rater on any Job
    public static void deleteCandidateIfNoRatingExists(list<Bureau_Rating__c> ratingList){
        
        Set<Id> candidateIdSet = new Set<Id>();
        Set<Id> participantIdSet = new Set<Id>();
        if (ratingList == null || ratingList.isEmpty()) return;
        
        for(Bureau_Rating__c rating : ratingList){
            candidateIdSet.add(rating.Respondent__c);
            candidateIdSet.add(rating.Participant__c);
        }
        
        Id jobId = [SELECT Id, Bureau_Job__c FROM Bureau_Candidate__c WHERE Id IN :candidateIdSet][0].Bureau_Job__c;
        
        list<Bureau_Candidate__c> candidateList = [SELECT Id,  Name, Bureau_Job__c,Number_of_Product_Assessment__c,
                                                   Number_of_participants__c,Number_of_Respondents__c,Status2__c,Work_Request__c 
                                                   FROM Bureau_Candidate__c 
                                                   WHERE Bureau_Job__c = :jobId 
                                                   AND Id IN :candidateIdSet 
                                                   AND Respondent_Count__c = 0
                                                  ];
        System.debug('candidateList ==> '+ candidateList);
        if(!candidateList.isEmpty())
            DELETE candidateList;
    }
    
    // SSE-28260 While deleting a Candidate:
    // If the Candidate is a Participant on the current WRF, delete all related Rating records
    // Written to delete raters only
    public static void deleteRelatedRatings(list<Bureau_Candidate__c> candidateList){
        
        Set<Id> candidateIdSet = new Set<Id>();
        if (candidateList == null || candidateList.isEmpty()) return;
        Id jobId = candidateList[0].Bureau_Job__c; 
        list<Bureau_Rating__c> ratingListToBeDeleted = [SELECT Id, Work_Request__c, Rater_Type__c, Participant__c, 
                                                        Respondent__c, Participant__r.Bureau_Job__c, 
                                                        Rating_Transfer_Status__c from Bureau_Rating__c 
                                                        WHERE Participant__c IN :candidateList 
                                                        AND Work_Request__c = :candidateList[0].Work_Request__c];
        System.debug('Aashi ratingListToBeDeleted --> ' + ratingListToBeDeleted);
        if(!candidateList.isEmpty()){
            RollUpCandidateFields.deleteRollupSummaryFieldsOnJob(candidateList);
            //RollUpCandidateFields.deleteRollupSummaryOfAssessmentOnJob(candidateList);
            RollUpCandidateFields.updateCandidateMaxSeqNoOnDelete(candidateList); 
            if(!ratingListToBeDeleted.isEmpty()){
                System.debug('Aashi Inside If');
                RollUpCandidateFields.calculateRatingsCountOnJob(jobId, ratingListToBeDeleted);
                RollUpCandidateFields.updateTransferCountonJobOnTrigger(ratingListToBeDeleted);
                RollUpCandidateFields.calculateRespondentCountOnCandidate(ratingListToBeDeleted);
            } 
        }
    }
    
    // To Calculate Number_of_Assessments on Job
    public static void deleteRollupSummaryOfAssessmentOnJob(List<Bureau_Candidate__c> candidateList){
        set<Id> jobIds =new Set<Id>();
        list<Job__c> updatedJobsList =new list<Job__c>(); 
        set<Id> candidateIds =new set<Id>();
        for(Bureau_Candidate__c candidateRec : candidateList){
            jobIds.add(candidateRec.Bureau_Job__c); 
        }
        if(jobIds.size()>0){    
            for(Job__c JobRec : [Select id,Number_of_Assessments__c,Number_of_Respondents_New__c,Number_of_Participants_New__c,Not_Transferred_Candidate_Count__c, Transferred_Candidate_Count__c from Job__c where id in: jobIds]){
                JobRec.Number_of_Assessments__c=JobRec.Number_of_Assessments__c ==null ? 0 : JobRec.Number_of_Assessments__c;
                
                for(Bureau_Candidate__c candidateRec : candidateList){
                    if(candidateRec.Number_of_Product_Assessment__c !=null){
                        if(JobRec.Number_of_Assessments__c >= candidateRec.Number_of_Product_Assessment__c){
                            JobRec.Number_of_Assessments__c -= candidateRec.Number_of_Product_Assessment__c;  
                        }else{
                            JobRec.Number_of_Assessments__c = 0;
                        }     
                    }
                }
                updatedJobsList.add(JobRec);                     
            }
            if(updatedJobsList.size()>0){
                update updatedJobsList;
            }
        }
    }
}
global class UpdateJobTransferStatusBatch implements Database.Batchable<sObject>,Database.Stateful {
	public Set<Id> JobIds = new Set<Id>();
    public Map<Id,Integer> JobRatingTransferredCount = new Map<Id,Integer>();
    public Map<Id,Integer> JobRatingNotTransferredCount = new Map<Id,Integer>();
    public Map<Id, Job__c> jobMap = new Map<Id, Job__c>();

    public UpdateJobTransferStatusBatch(Set<Id> JobIds){
        this.JobIds = JobIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        //DateTime fourHoursAgo = DateTime.now().addHours(-4);
        /*DateTime fourHoursAgo = DateTime.now().addHours(-4);
        return Database.getQueryLocator([
            SELECT Id, Participant__r.Bureau_Job__c,Rating_Transfer_Status__c
            FROM Bureau_Rating__c
            WHERE Lastmodifieddate >=:fourHoursAgo
            AND Participant__c != null
            AND (Participant__r.Bureau_Job__r.Candidate_Transfer_Status__c = 'Ready to transfer')
        ]);*/
        return Database.getQueryLocator([
            SELECT Id, Participant__r.Bureau_Job__c,Rating_Transfer_Status__c
            FROM Bureau_Rating__c
            WHERE Participant__c != null
            AND Participant__r.Bureau_Job__c IN :this.JobIds
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Bureau_Rating__c> ratingScope) {
        
        /*for(Bureau_Rating__c rating:ratingScope){
            Id jobId = rating.Participant__r.Bureau_Job__c;
            if (jobId == null) continue;
            JobIds.add(jobId);
        }*/ 
        
        /*if(this.jobMap == null){
         	this.jobMap = new Map<Id, Job__c>([SELECT Id, Candidate_Count__c, Transferred_Candidate_Count__c, 
                                          Not_Transferred_Candidate_Count__c, Candidate_Transfer_Status__c
                                          FROM Job__c WHERE Id IN :JobIds]);   
        }else{
            this.jobMap.putAll(new Map<Id, Job__c>([SELECT Id, Candidate_Count__c, Transferred_Candidate_Count__c, 
                                          Not_Transferred_Candidate_Count__c, Candidate_Transfer_Status__c 
                                               FROM Job__c WHERE Id IN :JobIds]));
        }*/
        
        for(Bureau_Rating__c rating:ratingScope){
            if (rating.Rating_Transfer_Status__c == 'Not Transferred') {
                if(this.JobRatingNotTransferredCount.containskey(rating.Participant__r.Bureau_Job__c)){
                    this.JobRatingNotTransferredCount.put(rating.Participant__r.Bureau_Job__c,this.JobRatingNotTransferredCount.get(rating.Participant__r.Bureau_Job__c)+1);
                }
                else{
                    this.JobRatingNotTransferredCount.put(rating.Participant__r.Bureau_Job__c,1);
                }
            }
            else{
                if(this.JobRatingTransferredCount.containskey(rating.Participant__r.Bureau_Job__c)){
                    this.JobRatingTransferredCount.put(rating.Participant__r.Bureau_Job__c,this.JobRatingTransferredCount.get(rating.Participant__r.Bureau_Job__c)+1);
                }
                else{
                    this.JobRatingTransferredCount.put(rating.Participant__r.Bureau_Job__c,1);
                }
            }
        }
        System.debug('TransferredCount '+this.JobRatingTransferredCount);
        System.debug('NotTransferredCount '+this.JobRatingNotTransferredCount);
    }
    
    global void finish(Database.BatchableContext bc) {
        List<Job__c> JobsToUpdate = new List<Job__c>();
        for(Id job:this.JobIds){
            Job__c jobToUpdate = new Job__c(id=job);
            if(this.JobRatingTransferredCount.get(job) != null){
                jobToUpdate.Transferred_Candidate_Count__c = this.JobRatingTransferredCount.get(job);
            }else{
                jobToUpdate.Transferred_Candidate_Count__c = 0;
            }
            if(this.JobRatingNotTransferredCount.get(job)!=null){
                jobToUpdate.Not_Transferred_Candidate_Count__c = this.JobRatingNotTransferredCount.get(job);
            }else{
                jobToUpdate.Not_Transferred_Candidate_Count__c = 0;
            }
            //System.debug('this.jobMap.get(job).Transferred_Candidate_Count__c '+this.jobMap.get(job).Transferred_Candidate_Count__c);
            //System.debug('this.JobRatingTransferredCount.get(job) '+this.JobRatingTransferredCount.get(job));
            /*if(this.jobMap.get(job).Transferred_Candidate_Count__c != null && this.JobRatingTransferredCount.get(job)!=null){
                jobToUpdate.Transferred_Candidate_Count__c = this.jobMap.get(job).Transferred_Candidate_Count__c + this.JobRatingTransferredCount.get(job);
            }else if(this.JobRatingTransferredCount.get(job)!=null){
               jobToUpdate.Transferred_Candidate_Count__c = this.JobRatingTransferredCount.get(job); 
            }
            
            if(jobToUpdate.Transferred_Candidate_Count__c == null){
                jobToUpdate.Transferred_Candidate_Count__c = 0;
            }
            jobToUpdate.Not_Transferred_Candidate_Count__c = this.jobMap.get(job).Candidate_Count__c - jobToUpdate.Transferred_Candidate_Count__c;
            */
            //jobToUpdate.Not_Transferred_Candidate_Count__c = this.JobRatingNotTransferredCount.get(job);
            //jobToUpdate.Transferred_Candidate_Count__c = this.JobRatingTransferredCount.get(job);
            //if(this.JobRatingNotTransferredCount.get(job)!=null && this.JobRatingNotTransferredCount.get(job)!=0){
            if(jobToUpdate.Transferred_Candidate_Count__c != 0 && jobToUpdate.Not_Transferred_Candidate_Count__c != 0){
                jobToUpdate.Candidate_Transfer_Status__c = 'Sent to FTP with error';
            }
            if(jobToUpdate.Not_Transferred_Candidate_Count__c == 0){
                jobToUpdate.Candidate_Transfer_Status__c = 'Sent to FTP';
            }
            JobsToUpdate.add(jobToUpdate);
        }
        update JobsToUpdate;
    }
}
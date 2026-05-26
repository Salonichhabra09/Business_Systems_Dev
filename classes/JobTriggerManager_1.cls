/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 25-07-2019
DESCRIPTION :- This class contains Job trigger related functionalities : before insert, before update (Setting Candidate Username Prefix,Defaulting Job Contact and Internal Contact)
***************************************************************************************************************************************/ 
global class JobTriggerManager_1{
    //Added by Pallavi Jadhav
    //Reason: To reduce SOQL
    static Id Managed_Service_Commenced = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
    static Id Managed_Service_Pipeline = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Pipeline').getRecordTypeId();
    Private static List<RecordType> recordTypeList = [	Select Id,Name,DeveloperName 
                                        from RecordType 
                                        where IsActive= true 
                                        AND SobjectType = 'Job__c' 
                                        AND DeveloperName IN('Managed_Service_Commenced','Project_Job','Bureau_Service','Managed_Service_Pipeline')];
        

// In this method 1) Set Is_Redirect_To_Task__c to True.   
// 2) Also performs functionalities mentioned in below method JobTrigger_BeforeUpdateInsert.
    public static void JobTrigger_BeforeInsert(List<Job__c> JobNewList){
                
        //Added by Pallavi Jadhav
        //Reason: In order to replace below commented logic, to achieve similar behaviour but with no record type SOQL
        Set<Id> accountIdset = new Set<Id>();
        for(integer i=0; i<JobNewList.size(); i++) {
            
                //Added BY Shubham Singh
                //To reset Number fields values on Job cloning
                JobNewList[i].Candidate_Max_Sequence_No_New__c=0;
                JobNewList[i].Count_of_Candidates_DNA__c=0;
                JobNewList[i].Count_of_candidates_invited__c=0;
                JobNewList[i].Count_of_Candidates_fail__c=0;
                JobNewList[i].Count_of_Candidates_pass__c=0;
                JobNewList[i].Number_of_Assessments__c=0;
                JobNewList[i].Number_of_Changes__c=0;
                JobNewList[i].Number_of_Participants_New__c=0;
                JobNewList[i].Number_of_Respondents_New__c=0;
                JobNewList[i].Number_of_Tasks__c=0;
                JobNewList[i].Time_Spent_Task__c=0;
                JobNewList[i].Time_Spent_Case__c=0;
                JobNewList[i].Estimated_Time_Task__c=0;
                JobNewList[i].Actual_Count_of_Candidates_PassFail__c=0;
                JobNewList[i].Time_Spent_Task__c=0;
                JobNewList[i].Total_MS_Value__c=String.isNotBlank(JobNewList[i].Opportunity_MS_Value__c.substringAfter(' '))?Decimal.valueOf(JobNewList[i].Opportunity_MS_Value__c.substringAfter(' ')):0.00;
            
            if(JobNewList[i].RecordTypeId==Managed_Service_Commenced || JobNewList[i].RecordTypeId==Managed_Service_Pipeline)
            {
                
                if(JobNewList[i].RecordTypeId==Managed_Service_Commenced){
                    /* Changes added by Aashi to wipe out Qualtrics data while record cloning */
                    if(JobNewList[i].isClone() == true){
                        JobNewList[i].Survey_Sent_On__c = null;
                        JobNewList[i].Survey_Recipient_Name_1__c = '';
                        JobNewList[i].Survey_Recipient_Name_2__c = '';
                        JobNewList[i].Survey_Recipient_Name_3__c = '';
                        JobNewList[i].Survey_Recipient_Email_1__c = '';
                        JobNewList[i].Survey_Recipient_Email_2__c = '';
                        JobNewList[i].Survey_Recipient_Email_3__c = '';
                        JobNewList[i].Do_Not_Send_Survey__c = false;
                        JobNewList[i].Preferred_Language__c = '';
                    }
                    /* Changes added by Aashi to wipe out Qualtrics data while record cloning */
                    JobNewList[i].Is_Redirect_To_Task__c = true;
                    if(JobNewList[i].Candidate_Username_Prefix__c == null || JobNewList[i].Job_Type__c=='SHL Online'){
                        accountIdset.add(JobNewList[i].Account__c);
                    }
                }
                if(JobNewList[i].RecordTypeId==Managed_Service_Pipeline){
                    accountIdset.add(JobNewList[i].Account__c);
                }
            }
            /*
             Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([Select Id,Name,DeveloperName from RecordType where IsActive= true AND SobjectType = 'Job__c' AND DeveloperName IN('Managed_Service_Commenced','Managed_Service_Pipeline')]);
            if(recordTypeMap.containsKey(JobNewList[i].RecordTypeId)){
                if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){
                    JobNewList[i].Is_Redirect_To_Task__c = true;
                    if(JobNewList[i].Candidate_Username_Prefix__c == null || JobNewList[i].Job_Type__c=='SHL Online'){
                        accountIdset.add(JobNewList[i].Account__c);
                    }
                }
                if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Pipeline'){   // Added by pankhuri on Bug fix
                    accountIdset.add(JobNewList[i].Account__c);
                }
            }*/
        }
        //if(accountIdset.size()!=0){  // change for bug fix SSE- 10294
        JobTrigger_BeforeUpdateInsert(accountIdset,JobNewList);       
        //}
    }
    
// In this method,1)Set Is_Redirect_To_Task__c to True when Record type is changed from Pipeline to Commenced.   
// 2)Also performs functionalities mentioned in below method JobTrigger_BeforeUpdateInsert.
    public static void JobTrigger_BeforeUpdate(List<Job__c> JobNewList, List<Job__c> JobOldList){
        Set<Id> accountIdset = new Set<Id>();
        Set<Id> jobIdSet = new Set<Id>();
        Map<id,Job__c> oldMap=new Map<id,Job__c>(JobOldList);
        
        updateRollupCalculationsOnJobUpdate(jobNewList,oldMap);
        //Added by Pallavi Jadhav
        //Reason: In order to replace below commented logic, to achieve similar behaviour but with no record type SOQL
        for(integer i=0; i<JobNewList.size(); i++){
            if(JobNewList[i].RecordTypeId==Managed_Service_Commenced || JobNewList[i].RecordTypeId==Managed_Service_Pipeline)
            {
                if(JobNewList[i].RecordTypeId==Managed_Service_Commenced){
                    if(JobNewList[i].Candidate_Username_Prefix__c == null || JobNewList[i].Job_Type__c=='SHL Online'){
                        accountIdset.add(JobNewList[i].Account__c);
                    }
                    if(JobNewList[i].RecordTypeId==Managed_Service_Commenced  && JobNewList[i].RecordTypeId==Managed_Service_Pipeline){  
                        JobNewList[i].Is_Redirect_To_Task__c = true;
                    }                                
                } 
                if(JobNewList[i].RecordTypeId==Managed_Service_Pipeline){
                    accountIdset.add(JobNewList[i].Account__c);
                }  
            }

            if(
                String.isNotBlank(JobNewList[i].JobStatus__c) &&
                JobNewList[i].JobStatus__c != JobOldList[i].JobStatus__c &&
                new List<String>{'Closed', 'Cancelled'}.contains(JobNewList[i].JobStatus__c)
            ) {
                jobIdSet.add(JobNewList[i].Id);
            }
        }

        Set<Id> jobWithInProgressTaskSet = new Set<Id>();
        Map<Id, List<MS_Task__c>> jobIdVsTaskToCancelMap = new Map<Id, List<MS_Task__c>>();
        List<MS_Task__c> taskToCancelList = new List<MS_Task__c>();
        for(MS_Task__c msTask : [SELECT Id, Job__c, Task_Status__c FROM MS_Task__c WHERE Job__c IN :jobIdSet AND Task_Status__c IN ('In Progress','Not Started','Accepted')]) {
            if(msTask.Task_Status__c == 'In Progress' && !jobWithInProgressTaskSet.contains(msTask.Job__c)) {
                jobWithInProgressTaskSet.add(msTask.Job__c);
            }

            if(msTask.Task_Status__c == 'In Progress')
            continue;

            if(!jobIdVsTaskToCancelMap.containsKey(msTask.Job__c)) {
                jobIdVsTaskToCancelMap.put(msTask.Job__c, new List<MS_Task__c>{});
            }

            jobIdVsTaskToCancelMap.get(msTask.Job__c).add(new MS_Task__c(Id = msTask.Id, Task_Status__c = 'Cancelled'));
        }

        for(Job__c jobNewRecord : JobNewList) {
            if(jobWithInProgressTaskSet.contains(jobNewRecord.Id)) {
                jobNewRecord.addError('Cannot close or cancel the job when any of the job task is In Progress.');
            }

            if(jobIdSet.contains(jobNewRecord.Id) && !jobWithInProgressTaskSet.contains(jobNewRecord.Id) && jobIdVsTaskToCancelMap.containsKey(jobNewRecord.Id)) {
                taskToCancelList.addAll(jobIdVsTaskToCancelMap.get(jobNewRecord.Id));
            }
        }

        if(!taskToCancelList.isEmpty()) {
            update taskToCancelList;
        }
        
        /*Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([Select Id,Name,DeveloperName from RecordType where IsActive= true AND SobjectType = 'Job__c' AND DeveloperName IN('Managed_Service_Commenced','Managed_Service_Pipeline')]);
        for(integer i=0; i<JobNewList.size(); i++){
            if(recordTypeMap.containsKey(JobNewList[i].RecordTypeId)){
                if(recordTypeMap.g
et(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){
                    if(JobNewList[i].Candidate_Username_Prefix__c == null || JobNewList[i].Job_Type__c=='SHL Online'){
                        accountIdset.add(JobNewList[i].Account__c);
                    }
                    if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'  && recordTypeMap.get(JobOldList[i].RecordTypeId).DeveloperName=='Managed_Service_Pipeline'){  
                        JobNewList[i].Is_Redirect_To_Task__c = true;
                    }                                
                } 
                if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Pipeline'){   // Added by pankhuri on Bug fix
                          accountIdset.add(JobNewList[i].Account__c);
                }  
            }
        }*/  
        //if(accountIdset.size()!=0){   // change for bug fix SSE- 10294
        JobTrigger_BeforeUpdateInsert(accountIdset,JobNewList);  
        //}

        //Check conditions before commencing job
        checkJobBeforeCommence(jobNewList, JobOldList);
    }

// This method is responsible for functions to commonly run for insert and update. 
// 1) Candidate Username Prefix in Job of type Managed_Service_Commenced defaults to the first four letters of the Account Name in Capital Letters.
// 2) Set Job Account with associated Opportunity related account if it was null. (for Commenced and Pipeline both)
// 3) Set Job's Contact with associated Opportunity Billing Contact (for Managed_Service_Commenced)
// 4) Set Internal Contact with associated Opportunity Owner Id. (for Managed_Service_Commenced)
    public static void JobTrigger_BeforeUpdateInsert(Set<id> accountIdset,List<Job__c> JobNewList){
        Set<Id> opportunityIdSet = new Set<Id>();
        for(integer i=0; i<JobNewList.size(); i++){ 
            //Added by Pallavi Jadhav
        //Reason: In order to replace below commented logic, to achieve similar behaviour but with no record type SOQL
            if(JobNewList[i].RecordTypeId==Managed_Service_Commenced || JobNewList[i].RecordTypeId==Managed_Service_Pipeline){                    
                if(JobNewList[i].Opportunity__c != null){
                    opportunityIdSet.add(JobNewList[i].Opportunity__c);
                }
            }
            /*if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Pipeline'  || recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){                    
                if(JobNewList[i].Opportunity__c != null){
                    opportunityIdSet.add(JobNewList[i].Opportunity__c);
                }
            }*/ 
        }
        Map<Id,Opportunity> OpportunityBillingContact = new Map<Id,Opportunity>();
        if(opportunityIdSet.size()>0){
            for(Opportunity opp : [select Id,Name,Billing_Contact__c,AccountId,OwnerId from Opportunity where Id IN: opportunityIdSet]){
                OpportunityBillingContact.put(opp.Id,opp);
            }
        } 
        Map<Id,Account> accountIdName = new Map<Id,Account>();
        if(accountIdset.size()>0 && accountIdset != null){
            for(Account acc : [select Id,Name,OwnerId from Account where Id IN: accountIdset]){
                accountIdName.put(acc.Id,acc);
            }
        }
        String accName;
        
        //Added by Pallavi Jadhav
        //Reason: In order to replace below commented logic, to achieve similar behaviour but with no record type SOQL
          for(integer i=0; i<JobNewList.size(); i++){
              
              if(JobNewList[i].RecordTypeId==Managed_Service_Commenced || JobNewList[i].RecordTypeId==Managed_Service_Pipeline)
              {
                  
                  if(JobNewList[i].RecordTypeId==Managed_Service_Commenced){
                      if(JobNewList[i].Candidate_Username_Prefix__c == null){
                          if(accountIdName.containsKey(JobNewList[i].Account__c)){
                              accName = accountIdName.get(JobNewList[i].Account__c).Name;
                              if(accName.indexOf(' ') != -1){
                                  accName = accName.replace(' ','');
                              }
                              if(accName.length()>4){
                                  accName = accName.substring(0,4);
                              }
                              JobNewList[i].Candidate_Username_Prefix__c = accName.toUpperCase();
                          }
                      }               
                  }
                  
                  if(JobNewList[i].RecordTypeId==Managed_Service_Commenced || JobNewList[i].RecordTypeId==Managed_Service_Pipeline){
                      
                      JobNewList[i].Account__c = OpportunityBillingContact.containsKey(JobNewList[i].Opportunity__c) ? OpportunityBillingContact.get(JobNewList[i].Opportunity__c).AccountId : null;                    
                      
                      if(JobNewList[i].RecordTypeId==Managed_Service_Commenced){ 
                          if(OpportunityBillingContact.containsKey(JobNewList[i].Opportunity__c)){
                              if(JobNewList[i].Contact__c == null){
                                  if(OpportunityBillingContact.get(JobNewList[i].Opportunity__c).Billing_Contact__c !=null){
                                      JobNewList[i].Contact__c = OpportunityBillingContact.get(JobNewList[i].Opportunity__c).Billing_Contact__c;
                                  }
                              }                          
                          }
                      }                   
                      if(JobNewList[i].Opportunity__c != null ){
                          JobNewList[i].InternalContact__c = OpportunityBillingContact.get(JobNewList[i].Opportunity__c).OwnerId;
                      }
                  }
                  
              }
            /*if(recordTypeMap.containsKey(JobNewList[i].RecordTypeId)){
            
              if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){
                if(JobNewList[i].Candidate_Username_Prefix__c == null){
                    if(accountIdName.containsKey(JobNewList[i].Account__c)){
                        accName = accountIdName.get(JobNewList[i].Account__c).Name;
                        if(accName.indexOf(' ') != -1){
                            accName = accName.replace(' ','');
                        }
                        if(accName.length()>4){
                            accName = accName.substring(0,4);
                        }
                        JobNewList[i].Candidate_Username_Prefix__c = accName.toUpperCase();
                    }
                }               
              }
              
              if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Pipeline' || recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){
               
                    JobNewList[i].Account__c = OpportunityBillingContact.containsKey(JobNewList[i].Opportunity__c) ? OpportunityBillingContact.get(JobNewList[i].Opportunity__c).AccountId : null;                    
                    
                    if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){ 
                        if(OpportunityBillingContact.containsKey(JobNewList[i].Opportunity__c)){
                            if(JobNewList[i].Contact__c == null){
                                if(OpportunityBillingContact.get(JobNewList[i].Opportunity__c).Billing_Contact__c !=null){
                                    JobNewList[i].Contact__c = OpportunityBillingContact.get(JobNewList[i].Opportunity__c).Billing_Contact__c;
                                }
                            }                          
                        }
                    }                   
                    if(JobNewList[i].Opportunity__c != null ){
                        JobNewList[i].InternalContact__c = OpportunityBillingContact.get(JobNewList[i].Opportunity__c).OwnerId;
                    }
              }
              
            }*/ // if over
          }   // for over
          
    } // method over
    
    //  This method is responsible for Updating the Task Owner with Project Lead, when Project Lead gets updated (only for Piepline Jobs)
//  If Job status is updated to 'Completed' and Pipeline Status is 'Pipeline - Not Converted', then Set the task status as 'Cancelled' for all the 'Not Started' task if Job status is 'completed'  (only for Piepline Jobs)  
    public static void Job_AfterUpdate(List<Job__c> JobNewList, List<Job__c> JobOldList, Map<id,Job__c> OldMap){
        System.debug('Number of Queries used -- JobTriggerManager_1.Job_AfterUpdate START ------- ' + Limits.getQueries());
        Set<Id> jobIdsSet = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();
       
        /*
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>();
        for(RecordType rt:[Select Id,Name,DeveloperName 
                           from RecordType 
                           where IsActive=true 
                           AND SobjectType = 'Job__c' 
                           and DeveloperName IN('Managed_Service_Pipeline')]){
                               
            recordTypeMap.put(rt.Id,rt);
        }*/
        
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>();
        for(RecordType rt: recordTypeList){
            if(rt.DeveloperName == 'Managed_Service_Pipeline' ){
                recordTypeMap.put(rt.Id,rt);
            }                  
        }
        
        for(Integer i=0;i<JobNewList.size();i++){      
            if(JobNewList[i].Project_Lead__c!=JobOldList[i].Project_Lead__c)
                jobIdsSet.add(JobNewList[i].id);
                
            if(JobNewList[i].JobStatus__c== 'Completed' || JobNewList[i].Pipeline_Status__c=='Pipeline - Not Converted')
                jobIds.add(JobNewList[i].id);                        
        }
        if(jobIdsSet.size()>0){
            //Update the Task Owner in case Project Manager or Project Lead gets changed
            List<Job__c> jobList = [Select id,Project_Lead__c,(Select id,OwnerId 
                                                               from Tasks 
                                                               where Status = 'Not Started') 
                                    from Job__c 
                                    where id in :jobIdsSet];
            if(jobList.size()>0){
                List<Task> taskList = new List<Task>();
                for(Integer i=0;i<jobList.size();i++){
                    for(Integer j=0;j<jobList[i].Tasks.size();j++)
                        jobList[i].Tasks[j].OwnerId = jobList[i].Project_Lead__c;
                    taskList.addAll(jobList[i].Tasks);
                }
                if(taskList.size()>0){
                    update taskList;
                }
            }
        }
        //Set the task status as Cancelled for all the Not Started task if Job status is completed
        if(jobIds.size()>0){
            List<Task> updateTaskList = new List<Task>();
            for(Task tsk : [Select id,Status 
                            from Task 
                            where WhatId IN: jobIds 
                            AND Status = 'Not Started']){
                tsk.Status = 'Cancelled';
                updateTaskList.add(tsk);
            }
            if(updateTaskList.size()>0){
                update updateTaskList;
            }
        }
        System.debug('Number of Queries used -- JobTriggerManager_2.Job_AfterUpdate END ------- ' + Limits.getQueries());
     }

    public static void Job_AfterInsert(List<Job__c> JobNewList){
       	System.debug('Number of Queries used -- JobTriggerManager_1.Job_AfterInsert START ------- ' + Limits.getQueries());
        //List<Bureau_Invoice__c> bureauInvoiceList = new List<Bureau_Invoice__c>();
        List<Task> defaultTask = new List<Task>();
        Map<Id,Set<Job__c>> CloneJobMap = new Map<Id,Set<Job__c>>();
        /*
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>();
        for(RecordType rt:[Select Id,Name,DeveloperName 
                           from RecordType 
                           where IsActive= true 
                           AND SobjectType = 'Job__c' 
                           AND DeveloperName IN('Managed_Service_Commenced','Project_Job','Bureau_Service','Managed_Service_Pipeline')]){
            recordTypeMap.put(rt.Id,rt);
        }*/
        
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>();
        for(RecordType rt: recordTypeList){
        	recordTypeMap.put(rt.Id,rt);               
        }
        
        Map<Id,Id> PipelineCommencedMap = new Map<Id,Id>();
        
        for(Integer i=0; i< JobNewList.size();i++){
            //If Record type if either Project Job or Bureau Service
            if(recordTypeMap.containsKey(JobNewList[i].RecordTypeId)){          
                // Added new condition to create an invoice for the Managed Service Commenced Record Type SSE-106
               // if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Bureau_Service' || recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Project_Job' || recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){    
                /*if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){
                    Bureau_Invoice__c bureauInvoice = new Bureau_Invoice__c();
                    bureauInvoice.Job__c = JobNewList[i].id;
                    bureauInvoice.InvoiceType__c = 'Invoice';               
                    bureauInvoice.InvoiceStatus__c = 'Created';              
                    bureauInvoice.CurrencyIsoCode = JobNewList[i].CurrencyToBeBilled__c;
                    bureauInvoiceList.add(bureauInvoice);
                   
                    System.debug('the first condition is being called');
                }*/
                // SSE-863  The Managed Service Commenced Record Type needs to have both - Invoice and update to the original Job from which is created. Removed the else if part with the above if and created a standalone if condition.
                if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){
                    System.debug('map is forming');
                    PipelineCommencedMap.put(JobNewList[i].Managed_Services_Pipeline__c,JobNewList[i].Id);
                }
                
            }
            //create system in case of cloned job for Managed Commenced Job
           // if(trigger.isInsert){
                //if(JobNewList[i].System_Field__c != null && (recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Bureau_Service' || recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced')){
                 if(JobNewList[i].System_Field__c != null && (recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced')){
                    if(CloneJobMap.containsKey(JobNewList[i].System_Field__c))
                        CloneJobMap.get(JobNewList[i].System_Field__c).add(JobNewList[i]);
                    else{
                        Set<Job__c> newJob=new Set<Job__c>();
                        newJob.add(JobNewList[i]);
                        CloneJobMap.put(JobNewList[i].System_Field__c,newJob);
                    }
                }
            }
       // }
        //Insert System in case of Clone Job
        if(CloneJobMap.size()>0) 
        createBureauSystem(CloneJobMap);
            
        if(PipelineCommencedMap.size()>0){
        System.debug('The if condition works');
            List<Job__c> updatePipelineJObList = new List<Job__c>();
            
            for(Job__c job :[Select id,Pipeline_Status__c,
                             (SELECT Id,Subject,WhatId,OwnerId,ActivityDate,Status,Priority,EstimatedDurationInMinutes__c,UnScheduled__c,Description 
                              FROM Tasks 
                              where Status='Not Started' order by ActivityDate desc) 
                             from Job__c 
                             where Id IN: PipelineCommencedMap.keySet()]){
                                 
                job.Pipeline_Status__c = 'Pipeline - Converted';
                job.Managed_Service_Commenced__c = PipelineCommencedMap.get(job.Id);
                updatePipelineJObList.add(job);
                                 
                for(Task  tsk : job.Tasks){               
                    tsk.whatId = PipelineCommencedMap.get(job.Id);
                    defaultTask.add(tsk);
                }
            }
            //Update status of converted MS Pipeline Job
            if(updatePipelineJObList.size()>0)
                update updatePipelineJObList;
        }
        //Insert default task or migrated MS Pipeline Open Task to MS Commenced Task
        if(defaultTask.size()>0)
            upsert defaultTask;
                   
        //Insert bureau invoice for Commenced Job
        /*if(bureauInvoiceList.size()>0)
            insert bureauInvoiceList;*/
    
       System.debug('Number of Queries used -- JobTriggerManager_1.Job_AfterInsert END ------- ' + Limits.getQueries());
   }

   public static void checkJobBeforeCommence(List<Job__c> newJobList, List<Job__c> oldJobList) {

        Set<Id> jobIdSet = new Set<Id>();
        Set<Id> jobWithOpenPipelineTaskSet = new Set<Id>();
        Set<Id> jobWithInProgressTaskSet = new Set<Id>();
        Id jobPiplelineRecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Pipeline').getRecordTypeId();
        Id jobCommenceRecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName().get('Managed_Service_Commenced').getRecordTypeId();

        for(Integer i = 0; i < newJobList.size(); i++) {
            if(
                newJobList[i].RecordTypeId == jobCommenceRecordTypeId &&
                oldJobList[i].RecordTypeId == jobPiplelineRecordTypeId
            ) {
                jobIdSet.add(newJobList[i].Id);
            }
        }

        for(MS_Task__c msTask : [SELECT Id, Task_Category__c, Task_Status__c, Job__c FROM MS_Task__c WHERE Job__c IN :jobIdSet AND ((Task_Category__c = 'Pipeline' AND Task_Status__c IN ('Not Started', 'In Progress')) OR Task_Status__c = 'In Progress')]) {

            if(!jobWithOpenPipelineTaskSet.contains(msTask.Job__c) && msTask.Task_Category__c == 'Pipeline' && new Set<String>{'Not Started','In Progress'}.contains(msTask.Task_Status__c)) {
                jobWithOpenPipelineTaskSet.add(msTask.Job__c);
            }

            if(!jobWithInProgressTaskSet.contains(msTask.Job__c) && msTask.Task_Status__c == 'In Progress') {
                jobWithInProgressTaskSet.add(msTask.Job__c);
            }
        }

        for(Job__c job : newJobList) {

            if(jobIdSet.contains(job.Id)) {
            
                if(job.Pipeline_Status__c == 'Pipeline - Not Converted') {
                    job.addError('This Pipeline job-card has already been marked as Not Converted . You cannot convert a Pipeline job-card that has been marked Not Converted.');
                }

                if(String.isBlank(job.System_Used__c)) {
                    job.addError('Please provide System Used details!');
                }

                if(job.Pipeline_Status__c == 'Pipeline - Converted') {
                    job.addError('This Pipeline job-card has already been converted to a Project Commenced job-card. You cannot change a converted Pipeline job-card.');
                }

                if(jobWithOpenPipelineTaskSet.contains(job.Id)) {
                    job.addError('You still have open Pipeline category tasks. Please close and comment any Pipeline category tasks and then try again.');
                }

                if(jobWithInProgressTaskSet.contains(job.Id)) {
                    job.addError('You appear to have one or more tasks marked as started (but not completed) on the Task Tab. Please complete any tasks started before proceeding.');
                }
            }
        }
   }
    
    public static void updateRollupCalculationsOnJobUpdate(List<Job__c> jobNewList, Map<id,Job__c> oldMap){
        Set<Id> jobIdSet =new Set<Id>();
        List<Job__c> jobRecs =new List<Job__c>();
        for(Job__c jobRec : jobNewList){ 
          if(jobRec.Number_of_Changes__c !=  oldMap.get(jobRec.id).Number_of_Changes__c || jobRec.Time_Spent_Case__c !=  oldMap.get(jobRec.id).Time_Spent_Case__c|| 
             jobRec.Number_of_Participants_New__c !=  oldMap.get(jobRec.id).Number_of_Participants_New__c || jobRec.Candidate_Max_Sequence_No_New__c !=  oldMap.get(jobRec.id).Candidate_Max_Sequence_No_New__c || 
             jobRec.Estimated_Time_Task__c !=  oldMap.get(jobRec.id).Estimated_Time_Task__c || jobRec.Opportunity_MS_Value__c !=  oldMap.get(jobRec.id).Opportunity_MS_Value__c || jobRec.Time_Spent_Task__c !=  oldMap.get(jobRec.id).Time_Spent_Task__c || jobRec.Actual_Count_of_Candidates__c !=  oldMap.get(jobRec.id).Actual_Count_of_Candidates__c){ 
              jobIdSet.add(jobRec.id); 
              jobRecs.add(jobRec);
          }
        }
        if(jobIdSet.size()>0){
        Map<id,Job__c> JobMap = new Map<id,Job__c>([Select id,Total_number_of_change_request__c,Total_MS_Value__c,Opportunity_Currency__c,Actual_Count_of_Candidates__c,Total_Participants__c,Total_task_estimated_time__c,Total_Case_Estimated_Time__c,Number_of_Changes__c,Candidate_Max_Sequence_No_New__c,Opportunity_MS_Value__c,Time_Spent_Task__c,Time_Spent_Case__c,
                               Total_Time_Spent_All_Jobs__c,Number_of_Participants_New__c,Total_Time_Spent_Task__c,Estimated_Time_Task__c,Opportunity__r.MS_Value_Formula__c,(Select Time_Spent_Case__c,Number_of_Participants_New__c,Opportunity__r.MS_Value_Formula__c,Number_of_Changes__c,Candidate_Max_Sequence_No_New__c,Opportunity_MS_Value__c,Time_Spent_Task__c 
                              ,Total_Time_Spent_Task__c,Estimated_Time_Task__c,Total_number_of_change_request__c,Total_MS_Value__c,Actual_Count_of_Candidates__c,Total_task_estimated_time__c,Total_Case_Estimated_Time__c,Total_Participants__c from Jobs1__r) from Job__c where id in: jobIdSet]);
        for(Job__c parentJob : jobRecs){                      
         parentJob.Total_MS_Value__c=String.isNotBlank(parentJob.Opportunity_MS_Value__c.substringAfter(' '))?Decimal.valueOf(parentJob.Opportunity_MS_Value__c.substringAfter(' ')):0.00;
         parentJob.Total_number_of_change_request__c=parentJob.Number_of_Changes__c !=null?parentJob.Number_of_Changes__c:0;
         parentJob.Actual_Count_of_Candidates__c=parentJob.Candidate_Max_Sequence_No_New__c !=null?parentJob.Candidate_Max_Sequence_No_New__c:0;
         parentJob.Total_Time_Spent_Task__c=parentJob.Time_Spent_Task__c !=null?parentJob.Time_Spent_Task__c:0; 
         parentJob.Total_Case_Estimated_Time__c=parentJob.Time_Spent_Case__c !=null?parentJob.Time_Spent_Case__c:0;
         parentJob.Total_Participants__c=parentJob.Number_of_Participants_New__c !=null?parentJob.Number_of_Participants_New__c:0;
         parentJob.Total_task_estimated_time__c=parentJob.Estimated_Time_Task__c !=null?parentJob.Estimated_Time_Task__c:0;
         	 
         for(Job__c childJob : JobMap.get(parentJob.id).Jobs1__r){
             if(childJob.Total_number_of_change_request__c !=null)
                parentJob.Total_number_of_change_request__c += childJob.Total_number_of_change_request__c;
             if(childJob.Actual_Count_of_Candidates__c !=null)
                parentJob.Actual_Count_of_Candidates__c += childJob.Actual_Count_of_Candidates__c;
             if(childJob.Total_Time_Spent_Task__c !=null)
                parentJob.Total_Time_Spent_Task__c += childJob.Total_Time_Spent_Task__c;
             if(childJob.Total_Case_Estimated_Time__c !=null)
                parentJob.Total_Case_Estimated_Time__c += childJob.Total_Case_Estimated_Time__c;
             if(childJob.Total_Participants__c !=null)
                parentJob.Total_Participants__c += childJob.Total_Participants__c;
             if(childJob.Total_MS_Value__c !=null)
                parentJob.Total_MS_Value__c += childJob.Total_MS_Value__c;
             if(childJob.Total_task_estimated_time__c !=null)
                parentJob.Total_task_estimated_time__c += childJob.Total_task_estimated_time__c;
         }
         parentJob.Total_Time_Spent_All_Jobs__c=parentJob.Total_Case_Estimated_Time__c +  parentJob.Total_Time_Spent_Task__c;   
        }
        }
    }   
    
    // SSE-27814 - Moved the method from ManageJobTask_Controller)
    public static void createBureauSystem(Map<Id,Set<Job__c>> CloneJobMap){
        Map<Id,Job__c> originalJob = new Map<Id,Job__c>([select id, System_Used__c , Account__c,(SELECT Account__c,Bureau_Job__c,Feedback_Provider__c,Id,Is_Client_System__c,Name,Project_Id__c,Report_Language__c,System_Login__c,System_Type__c,System_URL__c,System_Username__c,System__c from Bureau_Systems__r) from Job__c where Id IN: CloneJobMap.keySet()]);
        List<Bureau_System__c> newBureauJobSystems = new List<Bureau_System__c>();
        for(Id ojb:CloneJobMap.keySet()){
            for(Job__c njb : CloneJobMap.get(ojb)){
                //if account does not match then system also will not match
                if(originalJob.get(ojb).Account__c == njb.Account__c){
                    for(Bureau_System__c bs : originalJob.get(ojb).Bureau_Systems__r){
                        Bureau_System__c newBureauSystem = bs.clone(false,true,false,false);
                        newBureauSystem.Bureau_Job__c=njb.Id;
                        newBureauJobSystems.add(newBureauSystem);
                    }
                }
            }
        }
        if(newBureauJobSystems.size()>0){
            insert newBureauJobSystems;
        }
    }
}
/*****************************************************************************
CREATED BY :- Aashi
CREATED DATE :- 13-12-2022
DESCRIPTION :- This class contains functionality to calculate MS_Task count on Job,
               this class is being refered from MS_Task_Trigger, 
               covering After Insert, Update, Delete & UnDelete Events on MS_Task Records. 
STORY# :- SSE-18121 (MS Sprint 3)
******************************************************************************/

public class MS_TaskTriggerManager {
    
    public static void afterInsertDeleteUndelete(list<MS_Task__c> taskList){
        Set<Id> jobIds = new Set<Id>();
        list<Job__c> jobListToUpdate = new list<Job__c>();
        
        for(MS_Task__c msTask : taskList){
            if(msTask.Job__c != NULL){
                jobIds.add(msTask.Job__c);
            }
        }
        if(!jobIds.isEmpty()){
            updateJobRecords(jobIds);
        }
    }
    
    public static void afterUpdate(list<MS_Task__c> newTaskList, Map<Id, MS_Task__c> oldTaskMap){
        Set<Id> jobIds = new Set<Id>();
        list<Job__c> jobListToUpdate = new list<Job__c>();
        
        for(MS_Task__c msTask : newTaskList){
            /*if(msTask.Job__c != NULL){
                 jobIds.add(msTask.Job__c);
            }*/
            if(String.isNotEmpty(msTask.Job__c) && msTask.Job__c != oldTaskMap.get(msTask.Id).Job__c){
                jobIds.add(oldTaskMap.get(msTask.Id).Job__c);
                jobIds.add(msTask.Job__c);
            }
        }
        if(!jobIds.isEmpty()){
            updateJobRecords(jobIds);
        }
    }
    
    public static void updateJobRecords(Set<Id> jobIds){
        list<Job__c> jobListToUpdate = new list<Job__c>();
        for(AggregateResult ar : [SELECT COUNT(Id) countVar, Job__c FROM MS_Task__c where Job__c IN :jobIds GROUP BY Job__c]){
            Id jobId = (Id)ar.get('Job__c');
            Integer count = (INTEGER)ar.get('countVar');
            Job__c jobRecord = new Job__c(Id=jobId);
            jobRecord.Number_of_Tasks__c = count;
            jobListToUpdate.add(jobRecord);
        }
        if(!jobListToUpdate.isEmpty()){
            UPDATE jobListToUpdate;
        }
    }
    
    //Created By Shubham Singh (SSE-18120)
    public static void UpdateTimeFieldsOnJob(list<MS_Task__c> newTaskList, Map<Id, MS_Task__c> oldTaskMap){
        Set<Id> jobIds = new Set<Id>();
        list<Job__c> jobListToUpdate = new list<Job__c>();
        for(MS_Task__c taskRecord : newTaskList){
            if(taskRecord.Task_Status__c =='Completed' ||  oldTaskMap.get(taskRecord.Id).Task_Status__c =='Completed'){
              if(taskRecord.Actual_Time_Taken__c != oldTaskMap.get(taskRecord.Id).Actual_Time_Taken__c || taskRecord.Task_Status__c != oldTaskMap.get(taskRecord.Id).Task_Status__c || taskRecord.Task_Time_Recorded__c != oldTaskMap.get(taskRecord.Id).Task_Time_Recorded__c || taskRecord.Estimated_Time_Required__c != oldTaskMap.get(taskRecord.Id).Estimated_Time_Required__c){
                  jobIds.add(taskRecord.Job__c);
              }
            }
        }
        
        if(jobIds.size()>0){
            for(Job__c job : [select id ,Time_Spent_Task__c,Estimated_Time_Task__c,(select id ,Task_Time_Recorded__c,Actual_Time_Taken__c,
                              Task_Start_Time__c,Task_End_Time__c,Estimated_Time_Required__c  from MS_Tasks__r where Task_Status__c ='Completed') from Job__c where id IN :jobIds])
            {
                Decimal actualTime = 0;
                job.Estimated_Time_Task__c=0;
                for(MS_Task__c tsk : job.MS_Tasks__r) 
                {   if(tsk.Estimated_Time_Required__c != null){
                        job.Estimated_Time_Task__c += tsk.Estimated_Time_Required__c ;
                    }
                    if(tsk.Task_Time_Recorded__c !=null && tsk.Task_Time_Recorded__c !=0){
                        actualTime += tsk.Task_Time_Recorded__c;
                    }
                }
                job.Time_Spent_Task__c = actualTime ;
                jobListToUpdate.add(job);
         }
        }
        if(!jobListToUpdate.isEmpty()){
          UPDATE jobListToUpdate;
        }
    }
    
   /* public static void UpdateTaskManagerPriority(list<MS_Task__c> newTaskList){
        if(newTaskList[0].RecordTypeId!='0123G000001jqjcQAA'){
        String jobRecordId = newTaskList[0].Job__c;
        List<MS_Task__c> LatestMSTask = [SELECT Manager_Priority__c FROM MS_Task__c WHERE Job__c = :jobRecordId ORDER BY Manager_Priority__c Desc LIMIT 1];
        Integer priorityValue=0;
        if(LatestMSTask.size()==0){
            priorityValue=0;
        }
        else{
            priorityValue=(Integer)LatestMSTask[0].Manager_Priority__c+1;
        }
        for(MS_Task__c Task:newTaskList){
            Task.Manager_Priority__c = priorityValue;
            priorityValue = priorityValue+1;
        }
    }
    } */ //Commented By Priyank as this functionality was not needed anymore by business
}
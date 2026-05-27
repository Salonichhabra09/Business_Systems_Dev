/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 26-07-2019
DESCRIPTION :- This class contains Job trigger related functionalities : after update (Updating the Task Owner in Task related to Job,Setting task status to Cancelled for Completed jobs)
***************************************************************************************************************************************/ 

global without sharing class  JobTriggerManager_2{
           
    public static Boolean isFirstTime = true; 
//  This method is responsible for Updating the Task Owner with Project Lead, when Project Lead gets updated (only for Piepline Jobs)
//   If Job status is updated to 'Completed' and Pipeline Status is 'Pipeline - Not Converted', then Set the task status as 'Cancelled' for all the 'Not Started' task if Job status is 'completed'  (only for Piepline Jobs)  
    
    /*public static void Job_AfterUpdate(List<Job__c> JobNewList, List<Job__c> JobOldList, Map<id,Job__c> OldMap){
        Set<Id> jobIdsSet = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();
       
        //Commented by Pallavi
        //Reason: recordTypeMap is not getting used in further code
        /*Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>();
        for(RecordType rt:[Select Id,Name,DeveloperName from RecordType where IsActive=true AND SobjectType = 'Job__c' and DeveloperName IN('Managed_Service_Pipeline')]){
            recordTypeMap.put(rt.Id,rt);
        }
        
        for(Integer i=0;i<JobNewList.size();i++){      
            if(JobNewList[i].Project_Lead__c!=JobOldList[i].Project_Lead__c)
                jobIdsSet.add(JobNewList[i].id);
                
            if(JobNewList[i].JobStatus__c== 'Completed' || JobNewList[i].Pipeline_Status__c=='Pipeline - Not Converted')
                jobIds.add(JobNewList[i].id);                        
        }
        if(jobIdsSet.size()>0){
            //Update the Task Owner in case Project Manager or Project Lead gets changed
            List<Job__c> jobList = [Select id,Project_Lead__c,(Select id,OwnerId from Tasks where Status = 'Not Started') from Job__c where id in :jobIdsSet];
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
            for(Task tsk : [Select id,Status from Task where WhatId IN: jobIds AND Status = 'Not Started']){
                tsk.Status = 'Cancelled';
                updateTaskList.add(tsk);
            }
            if(updateTaskList.size()>0){
                update updateTaskList;
            }
        }       
     }*/
    
    //Added By Shubham SSE-18102
    //Calculates Candidate Count ,No of changes ,Total MS Value ,Overall Time Spent values
    public static void updateRollupCalculationsOnJobUpdate(List<Job__c> jobNewList, Map<id,Job__c> oldMap){
        Set<Id> jobIds =new Set<Id>();
        Set<Id> parentJobIds=new Set<Id>();
        for(Job__c jobRec : jobNewList){
          if(jobRec.Opportunity__r.MS_Value_Formula__c !=  oldMap.get(jobRec.id).Opportunity__r.MS_Value_Formula__c ||
             jobRec.Number_of_Changes__c !=  oldMap.get(jobRec.id).Number_of_Changes__c || jobRec.Time_Spent_Case__c !=  oldMap.get(jobRec.id).Time_Spent_Case__c|| 
             jobRec.Total_Time_Spent_Task__c !=  oldMap.get(jobRec.id).Total_Time_Spent_Task__c || jobRec.Number_of_Participants_New__c !=  oldMap.get(jobRec.id).Number_of_Participants_New__c || jobRec.Candidate_Max_Sequence_No_New__c !=  oldMap.get(jobRec.id).Candidate_Max_Sequence_No_New__c || 
             jobRec.Estimated_Time_Task__c !=  oldMap.get(jobRec.id).Estimated_Time_Task__c || jobRec.Opportunity_MS_Value__c !=  oldMap.get(jobRec.id).Opportunity_MS_Value__c || jobRec.Time_Spent_Task__c !=  oldMap.get(jobRec.id).Time_Spent_Task__c ||
             jobRec.Parent_Job__c !=  oldMap.get(jobRec.id).Parent_Job__c || jobRec.Total_number_of_change_request__c !=  oldMap.get(jobRec.id).Total_number_of_change_request__c
             || jobRec.Actual_Count_of_Candidates__c !=  oldMap.get(jobRec.id).Actual_Count_of_Candidates__c || jobRec.Total_task_estimated_time__c !=  oldMap.get(jobRec.id).Total_task_estimated_time__c
             || jobRec.Total_Case_Estimated_Time__c !=  oldMap.get(jobRec.id).Total_Case_Estimated_Time__c || jobRec.Total_Participants__c !=  oldMap.get(jobRec.id).Total_Participants__c || jobRec.Total_MS_Value__c !=  oldMap.get(jobRec.id).Total_MS_Value__c || jobRec.Opportunity__c !=  oldMap.get(jobRec.id).Opportunity__c){  
             if(jobRec.Parent_Job__c != null){
                jobIds.add(jobRec.Parent_Job__c);    
             }
             if(jobRec.Parent_Job__c !=  oldMap.get(jobRec.id).Parent_Job__c){
                jobIds.add(oldMap.get(jobRec.id).Parent_Job__c);    
             }
             if(jobRec.Opportunity__c !=  oldMap.get(jobRec.id).Opportunity__c){
                parentJobIds.add(jobRec.id);    
             }
          }
       }
       if(parentJobIds.size() >0){
         for(Job__c jobRec: [select id,(select id from Jobs1__r) from Job__c where id in: parentJobIds]){
            for(Job__c childJob: jobRec.Jobs1__r){
              jobIds.add(childJob.id);    
            } 
        }  
       }
       if(jobIds.size()>0)
         updateRollupCalculationsOnJob(jobIds);
    }
    
    //Added By Shubham SSE-18102
    //Calculates Candidate Count ,No of changes ,Total MS Value ,Overall Time Spent values
    public static void updateRollupCalculationsOnJobCreation(List<Job__c> jobNewList){
       Set<Id> jobIds =new Set<Id>();
       for(Job__c jobRec : jobNewList){  
           if(jobRec.Parent_Job__c != null){
             jobIds.add(jobRec.Parent_Job__c);    
           }
           //jobIds.add(jobRec.Id); 
       }
       if(jobIds.size()>0)
         updateRollupCalculationsOnJob(jobIds);
   }
    
    //Added By Shubham SSE-18102
    //Calculates Candidate Count ,No of changes ,Total MS Value ,Overall Time Spent values
    public static void updateRollupCalculationsOnJob(Set<ID> jobIdSet){
     list<Job__c> updatedJobsList =new list<Job__c>();   
     for(Job__c parentJob : [Select id,Total_number_of_change_request__c,Total_MS_Value__c,Opportunity_Currency__c,Actual_Count_of_Candidates__c,Total_Participants__c,Total_task_estimated_time__c,Total_Case_Estimated_Time__c,Number_of_Changes__c,Candidate_Max_Sequence_No_New__c,Opportunity_MS_Value__c,Time_Spent_Task__c,Time_Spent_Case__c,
                          Total_Time_Spent_All_Jobs__c,Number_of_Participants_New__c,Total_Time_Spent_Task__c,Estimated_Time_Task__c,Opportunity__r.MS_Value_Formula__c,(Select Time_Spent_Case__c,Number_of_Participants_New__c,Opportunity__r.MS_Value_Formula__c,Number_of_Changes__c,Candidate_Max_Sequence_No_New__c,Opportunity_MS_Value__c,Time_Spent_Task__c 
                          ,Total_Time_Spent_Task__c,Estimated_Time_Task__c,Total_number_of_change_request__c,Total_MS_Value__c,Actual_Count_of_Candidates__c,Total_task_estimated_time__c,Total_Case_Estimated_Time__c,Total_Participants__c from Jobs1__r) from Job__c where id in: jobIdSet]){
                              
         parentJob.Total_MS_Value__c=String.isNotBlank(parentJob.Opportunity_MS_Value__c.substringAfter(' '))?Decimal.valueOf(parentJob.Opportunity_MS_Value__c.substringAfter(' ')):0.00;
         parentJob.Total_number_of_change_request__c=parentJob.Number_of_Changes__c !=null?parentJob.Number_of_Changes__c:0;
         parentJob.Actual_Count_of_Candidates__c=parentJob.Candidate_Max_Sequence_No_New__c !=null?parentJob.Candidate_Max_Sequence_No_New__c:0;
         parentJob.Total_Time_Spent_Task__c=parentJob.Time_Spent_Task__c !=null?parentJob.Time_Spent_Task__c:0; 
         parentJob.Total_Case_Estimated_Time__c=parentJob.Time_Spent_Case__c !=null?parentJob.Time_Spent_Case__c:0;
         parentJob.Total_Participants__c=parentJob.Number_of_Participants_New__c !=null?parentJob.Number_of_Participants_New__c:0;
         parentJob.Total_task_estimated_time__c=parentJob.Estimated_Time_Task__c !=null?parentJob.Estimated_Time_Task__c:0;
             
         for(Job__c childJob : parentJob.Jobs1__r){
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
         
         updatedJobsList.add(parentJob);                     
     }
        if(updatedJobsList.size()>0){
           update updatedJobsList;
        }
   }
    
    /* 
     * Added by Aashi SSE-18855
	 * Re-assign Accepted tasks to new PM when Project Manager is changed on Job
	*/
    public static void updateTaskOwnerOnProjectManagerChange(list<Job__c> newJobList, Map<Id, Job__c> oldJobMap){
    
    list<MS_Task__c> taskListToUpdate = new list<MS_Task__c>();
    Map<Id, Job__c> jobMap = new Map<Id, Job__c>();

    for(Job__c jobRecord : newJobList){
        if(jobRecord.Project_Manager__c != oldJobMap.get(jobRecord.Id).Project_Manager__c){
            jobMap.put(jobRecord.Id, jobRecord);
        }
    }

    if(jobMap.size() > 0){
        for(MS_Task__c taskRecord : [SELECT Id, Job__c, Task_Status__c, OwnerId FROM MS_Task__c WHERE Job__c IN:jobMap.keySet()]){
            if(taskRecord.OwnerId != NULL && taskRecord.OwnerId == oldJobMap.get(taskRecord.Job__c).Project_Manager__c && taskRecord.Task_Status__c == 'Accepted'){
                taskRecord.OwnerId = jobMap.get(taskRecord.Job__c).Project_Manager__c;
                taskListToUpdate.add(taskRecord);
            }
        }
    }

    if(taskListToUpdate.size() > 0){
        UPDATE taskListToUpdate;
    }
   }
    
    @AuraEnabled
    public static List<Job__c> getDifferentRegionJobs(String parentJobId){
        //String parentJobRegion = [select job_region__c from job__c where id=:parentJobId].job_region__c;
        String regionToDiscard;
        String roleId = System.userInfo.getUserRoleId();
        String usrRole = [select id, name, userRole.name from user 
                                  where userroleid =: roleId limit 1].UserRole.Name;
            system.debug('User Role Name '+usrRole);
        if(usrRole.contains('CN:')){
            regionToDiscard='China';
        }
        else{
            regionToDiscard='Non China';
        }
        
        return [select id,Name,Account__c,Account__r.name,Project_Manager__c,Project_Manager__r.name,Total_Time_Spent__c,
                Total_Time_Spent_All_Jobs__c,job_region__c,Parent_Job__c,
                MS_Line_of_Business__c, Opportunity__c,Client_Domain__c, Sender_Email__c, Contract_End_Date__c, Ext_Template_Folder__c, Generic_Date_Field_MS_One__c
                from job__c where Parent_Job__c=:parentJobId and job_region__c!=:regionToDiscard and job_region__c!='Hong Kong' and job_region__c!='Singapore' order by Name desc ];
    }
    
    public static void RefreshEventAfterUpdate(List<Job__c> JobOldList,List<Job__c> JobNewList){
        List<Job_Refresh_Event__e> refreshEvents = new List<Job_Refresh_Event__e>();
        for(Integer i=0;i<JobOldList.size();i++){
            if(JobOldList[i].Job_transfer_status__c!=JobNewList[i].Job_transfer_status__c || 
               JobOldList[i].Candidate_transfer_status__c!=JobNewList[i].Candidate_transfer_status__c){
                   Job_Refresh_Event__e event = new Job_Refresh_Event__e(
                   JobId__c = JobNewList[i].Id);
                   refreshEvents.add(event);
               }
        }
        if(!refreshEvents.isEmpty()){
            Eventbus.publish(refreshEvents);
        }
        
    } 
}
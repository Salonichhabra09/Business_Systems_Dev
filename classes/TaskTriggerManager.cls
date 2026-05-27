/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND 
CREATED DATE :- 21-08-2019
DESCRIPTION :- This class contains various validations and assignments on fields of different objects which are creating or updating a Job, this class is called in Job_Trigger.
***************************************************************************************************************************************/ 

Global class TaskTriggerManager {
    
    //This method is updating the Opportunity_Stage__c field on the Task object with the stage of related opportunity
    /*public static void UpdateOpportunityStage(List<Task> Tasks){
map<ID,string> oppWhatIdMap = new map<ID,string>();
String whatId;
for(Task tsk : Tasks)
{
whatId = tsk.WhatId;
// Abort if other kind of Task
if(whatId != null && whatId.startsWith('006') && !oppWhatIdMap.keyset().contains(whatId))
{
// put whatId into set
oppWhatIdMap.put(tsk.whatId, null);
}
}
if(oppWhatIdMap.size()!=0){
for(Opportunity parentOpp : [Select Id, StageName from Opportunity where Id IN :oppWhatIdMap.keyset()])
{
oppWhatIdMap.put(parentOpp.Id, parentOpp.StageName);
}
for( Task tsk : Tasks)
{
String whatId1 = tsk.WhatId;
if(whatId1 != null && whatId1.startsWith('006') && oppWhatIdMap.containsKey(whatId1))
{
tsk.Opportunity_Stage__c = oppWhatIdMap.get(tsk.whatId);
}
if((tsk.ActivityDate == null) && (tsk.subject.contains('Outbound call')||tsk.subject.contains('Inbound call'))){
tsk.ActivityDate = system.today();
}
}
}
}*/
    
    //Commented by Shubham Singh (SSE-18120)
    //This method is updating Total_task_actual_time__c and Total_task_estimated_time__c fields on Job.
    /* public static void UpdateTimeFieldsOnJob( set<ID> IdSet){
set<ID> jobIdSet = new set<ID>();
String Jobid;
for(ID id:IdSet){
Jobid=id;
System.debug('This is jobd'+ Jobid);
if(Jobid.substring(0,3)=='a00')
jobIdSet.add(id);
}
List<Job__c> jobsList = new List<Job__c>();
if(jobIdSet.size()>0){
for(Job__c job : [select id , Total_task_actual_time__c , Total_task_estimated_time__c ,(select id , Actual_Time_Taken__c , EstimatedDurationInMinutes__c from Tasks) from Job__c where id IN :jobIdSet])
{
Boolean isEstimatedTimeChanged = false;
Boolean isActualTimeChanged = false;
Decimal estimatedTime = 0;
Decimal actualTime = 0;
for(Task tsk : job.Tasks) 
{
if(tsk.Actual_Time_Taken__c!= null)
actualTime += tsk.Actual_Time_Taken__c;

if(tsk.EstimatedDurationInMinutes__c != null)
estimatedTime  += tsk.EstimatedDurationInMinutes__c ;

}
//if(isActualTimeChanged)
job.Total_task_actual_time__c = actualTime ;
//if(isEstimatedTimeChanged)
job.Total_task_estimated_time__c = estimatedTime ;
jobsList.add(job);
system.debug(job);
}
if(jobsList.size()>0)
update jobsList;
}
}*/
    
    //This method is validating that Task created from Job should not be deleted by any user other than System Admin and Bullseye user
    public static void ValidateTaskDeletion(List<Task> tasks){
        Profile pf= [select id,Name from Profile where id=:userInfo.getProfileId() limit 1];
        for(Task tsk : Tasks){
            String jobId = tsk.WhatId;
            if(jobId != null){
                if(jobId.startsWith('a00')){
                    if(!pf.Name.equalsIgnoreCase('System Administrator') && !pf.Name.equalsIgnoreCase('Bullseye Project (Commercial)')){
                        tsk.addError('You do not have permission to delete this record.');
                    }
                }
            }
        }
    }
    
    //This method is updating Actual_Time_Taken__c and Assigned_To_Name__c  fields on task object depending on different conditions on Insert 
    public static void UpdateActualTimeTakenonInsert(List<Task> tasks){
        Set<Id> userIdsSet = new Set<Id>();
        String whatId;
        for(Task tsk : tasks){
            whatId = tsk.WhatId;
            if(tsk.Task_Start_Time__c != null && tsk.Task_End_Time__c != null){
                tsk.Actual_Time_Taken__c = taskTimeTaken(tsk.Task_Start_Time__c,tsk.Task_End_Time__c);
            }
            
            //if clause was added to prevent to run for task created when an email is sent from apex for Course bookings
            if(whatId != null && !whatId.startsWith('a03')){
                userIdsSet.add(tsk.OwnerId); 
            }
        }
        
        if(userIdsSet.size()>0)
        {
            Map<Id,User> usersMap = new Map<Id,User>([Select id ,Name from User where id in :userIdsSet]);
            for(Task tsk : tasks){
                if(usersMap!=null && usersMap.get(tsk.OwnerId)!=null)
                    tsk.Assigned_To_Name__c = usersMap.get(tsk.OwnerId).Name;
            }
        }
        
    }
    
    //This method is updating Actual_Time_Taken__c and Assigned_To_Name__c  fields on task object depending on different conditions on Update 
    public static void UpdateActualTimeTakenonUpdate(List<Task> tasks,Map<id,Task> TaskOldMap){
        Set<Id> userIdsSet = new Set<Id>();
        Profile pf= [select id,Name from Profile where id=:userInfo.getProfileId() limit 1];
        for(Task tsk : tasks){
            String jobId = tsk.WhatId;
            if(jobId == null){
                jobId = '';
            }         
            if(jobId.startsWith('a00') && (tsk.Status.startsWith('Completed') || TaskOldMap.get(tsk.Id).Status.startsWith('Completed')) && tsk.Subject != null && tsk.Subject.startsWith('Email:')){
                if(!pf.Name.equalsIgnoreCase('System Administrator')){
                    tsk.addError('You do not have permission to edit this record.');
                }
            }else{
                if(tsk.Task_Start_Time__c != null && tsk.Task_End_Time__c != null){
                    if(tsk.Status=='Completed' && tsk.Actual_Time_Taken__c == null){
                        tsk.Actual_Time_Taken__c = taskTimeTaken(tsk.Task_Start_Time__c,tsk.Task_End_Time__c); 
                    }
                }
                if(tsk.OwnerId!= TaskOldMap.get(tsk.id).OwnerId)
                    userIdsSet.add(tsk.OwnerId);
            }
            
        }
        if(userIdsSet.size()>0)
        {
            Map<Id,User> usersMap = new Map<Id,User>([Select id ,Name from User where id in :userIdsSet]);
            for(Task tsk : tasks){
                if(usersMap!=null && usersMap.get(tsk.OwnerId)!=null)
                    tsk.Assigned_To_Name__c = usersMap.get(tsk.OwnerId).Name;
            }
        }
        
    }
    
    public static void UpdateCreateTaskOnStrategy(List<Task> tasks){
        
        List<Task> taskToProcess = new List<Task>();
        Set<Id> strategyIds = new Set<Id>();
        
        for (Task task : tasks) {
            if(task.WhatId!=null && task.WhatId.getSObjectType().getDescribe().getName()=='Strategy_and_Goal__c'){
                taskToProcess.add(task);
                strategyIds.add(task.WhatId);
            }
        }
        
        if(taskToProcess.size()>0){
            List<Strategy_and_Goal__c> strategyList = [SELECT Id,Number_Of_Tasks_Created__c,Number_of_tasks_completed__c FROM Strategy_and_Goal__c WHERE Id IN :strategyIds];
            Map<Id,Integer> strategyMap = new Map<Id,Integer>();
            Map<Id,Integer> completedTaskStrategyMap = new Map<Id,Integer>();
            for (Task task : taskToProcess) {
                if(strategyMap.get(task.WhatId)==null){
                    strategyMap.put(task.whatId,1);
                }else{
                    strategyMap.put(task.whatId,strategyMap.get(task.whatId)+1);
                }
                if(completedTaskStrategyMap.get(task.WhatId)==null && task.Status.contains('Completed')){
                    completedTaskStrategyMap.put(task.whatId,1);
                }else if(completedTaskStrategyMap.get(task.WhatId)!=null && task.Status.contains('Completed')){
                    completedTaskStrategyMap.put(task.whatId,completedTaskStrategyMap.get(task.whatId)+1);
                }
            }
            List<Strategy_and_Goal__c> strategyToUpdate = new List<Strategy_and_Goal__c>();
            for (Strategy_and_Goal__c strategy : strategyList) {
                Strategy_and_Goal__c str = new Strategy_and_Goal__c();
                str.Id = strategy.Id;
                str.Number_Of_Tasks_Created__c = strategy.Number_Of_Tasks_Created__c + strategyMap.get(strategy.Id);
                if(completedTaskStrategyMap.get(strategy.Id)!=null){
                    str.Number_of_tasks_completed__c = strategy.Number_of_tasks_completed__c + completedTaskStrategyMap.get(strategy.Id);
                }
                strategyToUpdate.add(str);
            }
            
            if(strategyToUpdate.size()>0){
                update strategyToUpdate;
            }
        }
        
    }
    
    public static void UpdateCompletedTaskOnStrategy(List<Task> tasks,Map<id,Task> taskOldMap){
        
        List<Task> taskToProcess = new List<Task>();
        Set<Id> strategyIds = new Set<Id>();
        
        for (Task task : tasks) {
            if(task.WhatId!=null && task.WhatId.getSObjectType().getDescribe().getName()=='Strategy_and_Goal__c' && task.status.contains('Completed') && !taskOldMap.get(task.Id).status.contains('Completed')){
                taskToProcess.add(task);
                strategyIds.add(task.WhatId);
            }
        }
        
        if(taskToProcess.size()>0){
            List<Strategy_and_Goal__c> strategyList = [SELECT Id,Number_of_tasks_completed__c FROM Strategy_and_Goal__c WHERE Id IN :strategyIds];
            Map<Id,Integer> strategyMap = new Map<Id,Integer>();
            for (Task task : taskToProcess) {
                if(strategyMap.get(task.WhatId)==null){
                    strategyMap.put(task.whatId,1);
                }else{
                    strategyMap.put(task.whatId,strategyMap.get(task.whatId)+1);
                }
            }
            List<Strategy_and_Goal__c> strategyToUpdate = new List<Strategy_and_Goal__c>();
            for (Strategy_and_Goal__c strategy : strategyList) {
                Strategy_and_Goal__c str = new Strategy_and_Goal__c();
                str.Id = strategy.Id;
                str.Number_of_tasks_completed__c = strategy.Number_of_tasks_completed__c + strategyMap.get(strategy.Id);
                strategyToUpdate.add(str);
            }
            
            if(strategyToUpdate.size()>0){
                update strategyToUpdate;
            }
        }
        
    }
 
    //Added by Prachi SSE-21600
    public static void UpdateContactTask(List<Task> tasks,Map<id,Task> taskOldMap){
        
        List<Contact> contactsToProcess = new List<Contact>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,String> contactSubject = new Map<Id,String>();
        Map<Id,DateTime> contactDate = new Map<Id,DateTime>();
        Map<Id,DateTime> currentContactDateTime = new Map<Id,DateTime>();
        
       
        if(tasks.size() > 0){
            for (Task task : tasks) {
                if(taskOldMap!=null){
                    if(task.WhoId!=null && 
                       task.WhoId.getSObjectType().getDescribe().getName()=='Contact' && 
                       (task.WhoId!=taskOldMap.get(task.Id).whoId)){
                           contactIds.add(task.WhoId);
                           contactSubject.put(task.whoId,task.Subject);
                           contactDate.put(task.whoId,task.CreatedDate);
                       } 
                }else{
                    if(task.WhoId!=null 
                       && task.WhoId.getSObjectType().getDescribe().getName()=='Contact'
                       && (task.Subject != System.label.Renewal_Price_Uplift_Email_Subject 
                           && task.Subject != System.label.Renewal_Price_Uplift_Email_for_MY_Subject	
                           && task.Subject != System.label.Renewal_Price_Uplift_Email_Chinese_Subject
                          )
                      ){
                          contactIds.add(task.WhoId);
                          contactSubject.put(task.whoId,task.Subject);
                          contactDate.put(task.whoId,task.CreatedDate);
                      }
                }
            }
    }
        if(contactIds.size()>0){
            List<Contact> conList = [Select id, Last_Activity_Happen__c from Contact where id in: contactIds];
            for(Contact c : conList){
                
                 currentContactDateTime.put(c.id,c.Last_Activity_Happen__c);
            }
           
            for (Id conId : contactIds) {
                Contact con = new Contact();
                if(currentContactDateTime.get(conId) < contactDate.get(conId) || currentContactDateTime.get(conId) == null){
                con.Id = conId;
                con.AutomationBypassDateTime__c = System.Now();
                con.Last_Activity_Happen__c = contactDate.get(conId);
                con.Subject_Discussed__c = contactSubject.get(conId);
                contactsToProcess.add(con);   
                }
                
            }
        }
        
        update contactsToProcess;
        
        
    }
    
    // SSE-27814 - Moved the method from BureauJob_NewTaskManager)
    public static Integer taskTimeTaken(Datetime startDate, Datetime endDate){
            Integer days = startDate.date().daysBetween(endDate.date());
            Integer hours = endDate.hour()-startDate.hour();
            Integer minutes = endDate.minute()-startDate.minute();
            if(hours<0){
                hours = 0;
            }else if(hours>8){
                hours = 8;
            }
            return days*480+hours*60+minutes;
        }
    
}
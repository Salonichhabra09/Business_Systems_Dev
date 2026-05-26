/**
 * @author: Naved Khan
 * @date: 10 June 2022
 * @description: Controller method for taskManagerComponent LWC component.
 */
public with sharing class TaskManagerController {
    
    /**
     * @author: Naved Khan
     * @date: 10 June 2022
     * @description: method for fetching list of tasks to fetch for the provided job id.
     */
    @AuraEnabled
    public static List<MS_Task__c> getTaskList(String taskOwnerValue, String statusValue, String jobRecordId){
        try {
            String query = 'SELECT ';
            query += 'Id, OwnerId, Owner.Name, RecordTypeId, Task_Category__c, Task_Type__c, Task_Date__c, ';
            query += 'Scheduled_Time__c, Estimated_Time_Required__c, Actual_Time_Taken__c, UnScheduled__c, ';
            query += 'Comments__c, Task_Status__c, LastModifiedBy.Name, LastModifiedDate, Task_Start_Time__c, Task_End_Time__c, ';
            query += 'Timer_Stopped_At__c, Timer_Resumed_At__c, Timer_Offset__c, Original_Time_Taken__c, Task_Completed_On__c,Job_Region__c ';

            String condition = (String.isNotBlank(statusValue)
                ? 'Task_Status__c = \'' + statusValue + '\''
                : '');

            if(String.isNotBlank(taskOwnerValue)) {
                condition += String.isNotBlank(condition) ? +' AND ' : '';
                if(!taskOwnerValue.startsWith('005')) {
                    condition += ' Owner.Name LIKE \'' +
                    '%' +
                    taskOwnerValue +
                    '%\'';
                
                } else {
                    condition += 'OwnerId = ' + '\'' + taskOwnerValue + '\'';
                }
            }

            if(String.isNotBlank(condition)) {
                query += 'FROM MS_Task__c WHERE ' + condition + ' AND Job__c =:jobRecordId ORDER BY Task_Date__c LIMIT 5000';
            } else {
                query += 'FROM MS_Task__c WHERE Job__c =:jobRecordId ORDER BY Task_Date__c LIMIT 5000';
            }

            System.debug('query++'+query);

            return (List<MS_Task__c>) Database.query(query);

            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void assignTaskToCurrentUser(String taskId){
        try {
            MS_Task__c existingTaskRecord = [SELECT Id, OwnerId, Task_Status__c FROM MS_Task__c WHERE Id = :taskId];
            if(String.isNotEmpty(existingTaskRecord.OwnerId) && String.valueOf(existingTaskRecord.OwnerId).startsWith('005') && new List<String>{'In Progress', 'Completed', 'Cancelled'}.contains(existingTaskRecord.Task_Status__c)) {
                String message = 'Task already assigned to owner';
                AuraHandledException customException = new AuraHandledException(message);
                customException.setMessage(message);
                throw customException;
            }
            MS_Task__c taskRecord = new MS_Task__c(Id = taskId, OwnerId = UserInfo.getUserId(), Task_Status__c = 'In Progress', Task_Start_Time__c = System.now());
            update taskRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void completeTask(String taskId, String startTime, String stopTime, String currentTime){
        try {
            String startTimeStr = '"' + startTime + '"';
            DateTime startDateTime = (DateTime) JSON.deserialize(startTimeStr, Datetime.class);

            String stopTimeStr = '"' + stopTime + '"';
            DateTime endDateTime = (DateTime) JSON.deserialize(stopTimeStr, Datetime.class);

            String currentTimeStr = '"' + currentTime + '"';
            DateTime currentDateTime = (DateTime) JSON.deserialize(currentTimeStr, Datetime.class);

            Long totalTimeTaken = ( (endDateTime.getTime() - startDateTime.getTime()) / 1000 );
            MS_Task__c taskRecord = new MS_Task__c(Id = taskId, Task_Status__c = 'Completed', Task_End_Time__c = endDateTime, Timer_Stopped_At__c = endDateTime, Task_Completed_On__c = currentDateTime /*, Actual_Time_Taken__c = totalTimeTaken*/);
            update taskRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void cancelTask(String taskId){
        try {
            MS_Task__c existingTaskRecord = [SELECT Id, OwnerId, Task_Status__c FROM MS_Task__c WHERE Id = :taskId];
            if(new List<String>{'In Progress', 'Completed', 'Cancelled'}.contains(existingTaskRecord.Task_Status__c)) {
                String message = 'Cannot Cancel In Progress, Completed or Cancelled Task.';
                AuraHandledException customException = new AuraHandledException(message);
                customException.setMessage(message);
                throw customException;
            }
            MS_Task__c taskRecord = new MS_Task__c(Id = taskId, Task_Status__c = 'Cancelled');
            update taskRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void startTaskTimer(String taskId, String startDateTimeString){
        try {
            String startTimeStr = '"' + startDateTimeString + '"';
            DateTime startDateTime = (DateTime) JSON.deserialize(startTimeStr, Datetime.class);
            MS_Task__c taskRecord = new MS_Task__c(Id = taskId, Task_Start_Time__c = startDateTime, Task_Status__c = 'In Progress');
            update taskRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void stopTaskTimer(String taskId, String stopDateTimeString){
        try {
            String stopDateTimeStr = '"' + stopDateTimeString + '"';
            DateTime stopDateTime = (DateTime) JSON.deserialize(stopDateTimeStr, Datetime.class);
            MS_Task__c taskRecord = new MS_Task__c(Id = taskId, Timer_Stopped_At__c = stopDateTime);
            update taskRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void resumeTaskTimer(String taskId, String resumeDateTimeString, String timerOffset){
        try {
            String resumeDateTimeStr = '"' + resumeDateTimeString + '"';
            DateTime resumeDateTime = (DateTime) JSON.deserialize(resumeDateTimeStr, Datetime.class);
            MS_Task__c taskRecord = new MS_Task__c(Id = taskId, Timer_Resumed_At__c = resumeDateTime, Timer_Offset__c = Integer.valueOf(timerOffset));
            update taskRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateTaskPriority(List<MS_Task__c> TasksToUpdate){
        try{
            System.debug('List '+TasksToUpdate);
            Set<MS_Task__c> tempSet = new Set<MS_Task__c>();
            tempSet.addAll(TasksToUpdate);
            System.debug('Set '+tempSet);
            List<MS_Task__c> tempList = new List<MS_Task__c>();
            tempList.addAll(tempSet);
            System.debug('List to update '+tempList);
            update tempList;
            return 'Success';
        
        } catch(AuraHandledException ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<MS_Task__c> updateTaskRowData(List<MS_Task__c> taskToUpdateList){
        try {
            Set<Id> taskIdSet = new Set<Id>();
            for (MS_Task__c taskData : taskToUpdateList) {
                taskIdSet.add(taskData.Id);
            }
            Map<Id,MS_Task__c> taskDataMap = new Map<Id,MS_Task__c>([SELECT Id, Comments__c FROM MS_Task__c WHERE Id IN :taskIdSet]);
            for (MS_Task__c taskData : taskToUpdateList) {
                if(String.isEmpty(taskData.Comments__c)) {
                    continue;
                }
                MS_Task__c currentTaskData = taskDataMap.get(taskData.Id);
                String timeStamp = UserInfo.getName() + '\n' + String.valueOf(System.now()) + '\n';
                // String timeStamp = UserInfo.getName() + '\n' + String.valueOf(Datetime.now().format('dd MMM y HH:m:s')) + '\n';
                if(String.isNotBlank(currentTaskData.Comments__c)) {
                    taskData.Comments__c = currentTaskData.Comments__c + '\n\n' +  timeStamp + taskData.Comments__c;
                } else {
                    taskData.Comments__c = timeStamp + taskData.Comments__c;
                }
            }
            try{
                update taskToUpdateList;
            } catch(DmlException ex) {
                AuraHandledException auraException = new AuraHandledException(ex.getDmlMessage(0));
                auraException.setMessage(ex.getDmlMessage(0));
                throw auraException;
            }
            return taskToUpdateList;
        } catch (Exception e) {
            String errorMsg = e.getMessage();
            AuraHandledException auraException = new AuraHandledException(errorMsg);
            auraException.setMessage(errorMsg);
            throw auraException;
        }
    }

    @AuraEnabled
    public static void cloneTasks(String jsonOfListOfTasks, String jobRecordId) {
        try {
            Integer priorityValue=0;
            List<MS_Task__c> listOfTasks = (List<MS_Task__c>) JSON.deserialize(jsonOfListOfTasks, List<MS_Task__c>.class);
            for (MS_Task__c taskData : listOfTasks) {
                if(String.isEmpty(taskData.Comments__c)) {
                    continue;
                }
                String timeStamp = UserInfo.getName() + '\n' + String.valueOf(System.now()) + '\n';
                taskData.Comments__c = timeStamp + taskData.Comments__c;
            }
            insert listOfTasks;
        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException(e.getMessage());
            auraException.setMessage(e.getMessage());
            throw auraException;
        }
    }
    
}
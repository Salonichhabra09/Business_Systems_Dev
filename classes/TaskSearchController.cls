public with sharing class TaskSearchController {
       @AuraEnabled(cacheable=true)
       public static List<Group> returnManagedServiceGroups(){
        try {
            Group maingroup = [SELECT Id,DeveloperName FROM Group where DeveloperName = 'Managed_and_Bureau_Services'];
            List<GroupMember> members = [SELECT Id,UserOrGroupId FROM GroupMember where GroupId =:maingroup.Id];
            List<Id> groupIDs = new List<Id>();
            FOr(GroupMember member:members){
                groupIDs.add(member.UserOrGroupId);
            }
            return [SELECT Id,name FROM Group where Id In :groupIDs];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> getQueueList(){
        try {
           Map<String,String> QueueMap = new Map<String,String>();
            List<MS_Queues__mdt> queues = MS_Queues__mdt.getall().values();
            for(MS_Queues__mdt queue:queues){
                System.debug('LOB Value from setting '+queue.MS_Team__c);
                {
                    QueueMap.put(queue.MasterLabel,queue.Id__c);
                }
            }
            System.debug('Map value '+QueueMap);
            if(QueueMap.isEmpty()){
                return null;
            }
            else{
                return QueueMap;
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<MS_Task__c> returnTasks(List<Id> AssignedToGroups,List<String> TaskStatusList, String StartDate, String EndDate,String SelectedOwner, List<String> JobNumbers){
        List<Job__c> jobsList = new List<Job__c>();
        System.debug('Jobnumbers '+JobNumbers);
        System.debug('Jobnumbers size '+JobNumbers.size());
        System.debug('Jobnumbers is empty '+JobNumbers.isEmpty());
        if(!JobNumbers.isEmpty()){
            jobsList = [select id from Job__c where name IN : JobNumbers order by name];
            if(jobsList.isEmpty()){
                throw new AuraHandledException('Invalid Job Number(s)');
            }
        }
        List<GroupMember> memberslist = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember where GroupId in:AssignedToGroups];
        List<Id> membersId = new List<Id>();
        List<Id> JobIdList = new List<Id>();
        List<String> statusList = new List<String>();
        //String query = 'Select id,Scheduled_Time__c,OwnerId,ActivityDate,What.Name,Description,EstimatedDurationInMinutes__c,Actual_Time_Taken__c,Status,Task_Type__c,Owner.Name,Task_End_Time__c,Task_Start_Time__c from Task where Related_To_Prefix__c = \'a00\' and (NOT Subject Like \'Email:%\')';
        String query = 'Select id,Scheduled_Time__c,OwnerId,Task_Date__c,Job__r.Name,Job__r.Project_Name__c,Job__r.Account__r.Name,Actual_Time_Taken__c,Task_Status__c,Task_Type__c,Owner.Name,Task_End_Time__c,Task_Start_Time__c,Original_Time_Taken__c from MS_Task__c where Job__c!=null';
        if(AssignedToGroups.size()>0){
            query +=' and OwnerId IN :AssignedToGroups';
        }
        for(GroupMember member:memberslist){
            membersId.add(member.UserOrGroupId);
        }
        if(SelectedOwner!=''){
            membersId.add(SelectedOwner);
        }
        if(membersId.size()>0){
            query +=' and OwnerId IN :membersId';
        }
        if(TaskStatusList.size()>0)
        {
            if(!TaskStatusList.contains('All Tasks'))
            {
                for(String status : TaskStatusList)
                {
                    if(status == 'Not Completed')
                    {
                        statusList.add('Not Started');
                        statusList.add('In Progress');
                    }
                    else
                        statusList.add(status);
                }
                query += ' and Task_Status__c in :statusList';
            }
        }
        if(StartDate!='' && StartDate!=null)
            Date convertedStartDate = Date.valueOf(StartDate);
            query += ' and Task_Date__c >= :convertedStartDate';
        if(EndDate!='' && EndDate!=null)
            Date convertedEndDate = Date.valueOf(EndDate);
            query += ' and Task_Date__c <= :convertedEndDate';
        if(JobNumbers.size()>0){
            for(Job__c j : jobsList){
                JobIdList.add(j.id);
            }
            if(jobsList.size()>0){
            query +=' and Job__c IN : JobIdList';
            }
        }
        System.debug('Query '+query);
        query +=' order by Task_Date__c limit 10000';
        System.debug('Query '+query);
        return Database.query(query);
    }

}
public with sharing class BulkMSTaskCreationController {
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getBureaUserList(String lineOfBusiness){
        try {   
            String permissionSetName = '';
            Map<String,String> userMap = new Map<String,String>();
            if(lineOfBusiness=='TA - Corporate'){
                permissionSetName = 'Talent_Assessment_Corp_Managed_Services';
            }
            else if(lineOfBusiness=='TA - Vocational'){
                permissionSetName = 'Talent_Assessment_Vocational_Managed_Services';
            }
            else if(lineOfBusiness=='Talent Management'){
                permissionSetName = 'Talent_Management_Managed_Services';
            }
            else if(lineOfBusiness=='MS Analytics'){
                permissionSetName = 'Talent_Management_Managed_Services'; // need to change in future.
            }
            System.debug('line of business '+lineOfBusiness);
            System.debug('Permission set used '+permissionSetName);
            List<PermissionSetAssignment> permissionSetResults = [SELECT Id, PermissionSetId, PermissionSet.Name,AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = :permissionSetName order by Assignee.Name];
            for(PermissionSetAssignment permissionset:permissionSetResults){
                userMap.put(permissionset.Assignee.Name,permissionset.AssigneeId);
            }
            if(userMap.isEmpty()){
                return null;
            }
            else{
                return userMap;
            }       
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     @AuraEnabled(cacheable=true)
    public static Map<String,String> getQueueList(String lineOfBusiness){
        try {
            System.debug('LOB Value '+lineOfBusiness);
           Map<String,String> QueueMap = new Map<String,String>();
            List<MS_Queues__mdt> queues = MS_Queues__mdt.getall().values();
            for(MS_Queues__mdt queue:queues){
                System.debug('LOB Value from setting '+queue.MS_Team__c);
                if(queue.MS_Team__c==lineOfBusiness){
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
    public static String  getTaskRecordTypeId(String taskRecordTypeName){
        try {
            return [select id,name from recordtype where SobjectType='MS_Task__c'and Name=:taskRecordTypeName limit 1].Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String  getProjectManager(String JobId){
        try {
            return [select id,Project_Manager__c from Job__c where id=:JobId limit 1].Project_Manager__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled
    public static void insertTasks(List<MS_Task__c> ListOfTasks, String jobRecordId) {
        try {
            // Check manager priority latest value.
            // SSE-18926 Commented by Aashi to remove Priority logic
            /*List<MS_Task__c> LatestMSTask = [SELECT Manager_Priority__c FROM MS_Task__c WHERE Job__c = :jobRecordId ORDER BY Manager_Priority__c Desc LIMIT 1];
            Integer priorityValue=0;
            System.debug('Input from LWC '+ListOfTasks);
            //List<MS_Task__c> listOfTasks = (List<MS_Task__c>) JSON.deserialize(jsonOfListOfTasks, List<MS_Task__c>.class);
            if(LatestMSTask.size()==0){
                priorityValue=0;
                //System.debug('Priority value '+LatestMSTask.Manager_Priority__c);
            }
            else{
                priorityValue=(Integer)LatestMSTask[0].Manager_Priority__c+1;
            }*/
            String OwnerIdString;
            String JobRegion = [select id,Job_Region__c from Job__c where id=:jobRecordId limit 1].Job_Region__c;
            for(MS_Task__c task : ListOfTasks) {
                // SSE-18926 Commented by Aashi to remove Priority logic
                //task.Manager_Priority__c = priorityValue;
                task.Job__c = jobRecordId;
                task.Job_Region__c = JobRegion;
                if(task.OwnerId!=null){
                    OwnerIdString = task.OwnerId;
                if(OwnerIdString.startswith('005')){
                    task.Task_Status__c = 'Accepted';
                }
                else{
                    task.Task_Status__c = 'Not Started';
                }
                }
                // SSE-18926 Commented by Aashi to remove Priority logic
                //priorityValue += 1;
                if(String.isNotBlank(task.Comments__c)) {
                    String timeStamp = UserInfo.getName() + '\n' + String.valueOf(System.now()) + '\n';
                    task.Comments__c = timeStamp + task.Comments__c;
                }
            }
            System.debug('Task List '+listOfTasks);
            insert listOfTasks;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


}
public class BulkTaskAccountPlanController {
    
    @AuraEnabled(cacheable=true)
    public static returnMessageWrapper getPicklistValues(Id strategyId){
        
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        try{
            UserRecordAccess checkRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =:strategyId];
            if(checkRecordAccess.HasEditAccess==true){
                Schema.DescribeFieldResult status = Task.Status.getDescribe();
                Schema.DescribeFieldResult subject = Task.Subject.getDescribe();
                // Get picklist values from field description
                List<Schema.PicklistEntry> statusValues = status.getPicklistValues();
                List<Schema.PicklistEntry> subjectValues = subject.getPicklistValues();
                List<List<PicklistWrapper>> listOfPicklist = new List<List<PicklistWrapper>>();
                // Do something with entries
                List<PicklistWrapper> listStatus = new List<PicklistWrapper>();
                List<PicklistWrapper> listSubject = new List<PicklistWrapper>();
                for (Schema.PicklistEntry entry : statusValues) {
                    PicklistWrapper pick = new PicklistWrapper();
                    if(entry.isActive()){
                        pick.label = entry.getLabel();
                        pick.value = entry.getValue();
                        listStatus.add(pick);
                    }
                }
                for (Schema.PicklistEntry entry : subjectValues) {
                    PicklistWrapper pick = new PicklistWrapper();
                    if(entry.isActive()){
                        pick.label = entry.getLabel();
                        pick.value = entry.getValue();
                        listSubject.add(pick);
                    }
                }
                
                listOfPicklist.add(listSubject);
                listOfPicklist.add(listStatus);
                wrapperToReturn.MessageType ='Success';
                wrapperToReturn.picklistValues = listOfPicklist;
            }else{
                wrapperToReturn.MessageType ='NoAccess';
                wrapperToReturn.Message = 'You do not have access to create Tasks on this Strategy. Please contact system administrator for further assistance.';
            }
            
        }catch(Exception e){
            system.debug(e.getMessage());
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = e.getMessage(); 
        } 
        return wrapperToReturn;
        
    }
    
    @AuraEnabled
    public static returnMessageWrapper createBulkTasks(Id accountPlanId,List<TaskWrapper> taskList){
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        try{
            List<Task> taskListToInsert = new List<Task>();
            for (TaskWrapper task : taskList) {
                Task t = new Task();
                t.OwnerId = task.assignedTo;
                t.description = task.comments;
                t.whoId = task.contact;
                t.whatId = accountPlanId;
                t.status = task.status;
                t.subject = task.subject;
                t.ActivityDate = task.dueDate;
                taskListToInsert.add(t);
            }
            
            insert taskListToInsert;
            
            wrapperToReturn.MessageType = 'Success';
            
        }catch (DMLException e) {
            String message = e.getDmlMessage(0);
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        } catch(Exception e){
            system.debug(e.getMessage());
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = e.getMessage(); 
        } 
        return wrapperToReturn;
    }
    
    public class PicklistWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    
    public class TaskWrapper {
        @AuraEnabled public String Id {get; set; }
        @AuraEnabled public String assignedTo { get; set; }
        @AuraEnabled public String contact { get; set; }
        @AuraEnabled public Date dueDate { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String subject { get; set; }
        @AuraEnabled public String comments { get; set; }
    }
    
    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public List<List<PicklistWrapper>> picklistValues;
    }
}
public without sharing class MsCandidateDataTableController {
    
    @AuraEnabled
   public static list<Bureau_Candidate__c> getCandidateData(String jobId, Integer offSetValue,String filterValue){
       if(String.isBlank(filterValue)){
        return [SELECT Id,Name,First_Name__c,Last_Name__c,Email__c,Gender__c,Phone_Number__c,Country__c,Language__c,Status__c,Reports_Status__c,
        Username__c,Username_New__c,Product_Assessment__c,System_s__c,Bureau_Job__c, Bureau_Job__r.Name from Bureau_Candidate__c where Bureau_Job__c=:jobId ORDER BY lastmodifieddate DESC LIMIT 10 OFFSET: offSetValue];
       }else{
        filterValue='%'+filterValue+'%';
        return [SELECT Id,Name,First_Name__c,Last_Name__c,Email__c,Gender__c,Phone_Number__c,Country__c,Language__c,Status__c,Reports_Status__c,
        Username__c,Username_New__c,Product_Assessment__c,System_s__c,Bureau_Job__c, Bureau_Job__r.Name from Bureau_Candidate__c where (Bureau_Job__c=:jobId) AND (Name like: filterValue OR First_Name__c like: filterValue OR Last_Name__c like: filterValue OR Email__c like: filterValue  ) ORDER BY lastmodifieddate DESC LIMIT 10 OFFSET: offSetValue];   
       }
   }
   
    @Auraenabled
   public static list<OpportunityLineItem> getOpportunityLineItems(String oppId){
       return[Select Id,Name,Basis_of_Fees__c,Quantity,Proposition__c,Package__c,Solution_Cap__c,Description,Product2.name from OpportunityLineItem where OpportunityId =: oppId and Ms_product__c=true];
       
   }
   
   @Auraenabled
   public static list<OpportunityLineItem> getNonMSOpportunityLineItems(String oppId){
       return[Select Id,Name,Basis_of_Fees__c,Quantity,Proposition__c,Package__c,Solution_Cap__c,Description,Product2.name from OpportunityLineItem where OpportunityId =: oppId and Ms_product__c=false];
       
   }
   
    @Auraenabled
   public static list<ProjectObject__c> getProjectDetails(String oppId){
       List<ProjectObject__c> projectDetailsList;
       if(String.isNotBlank(oppId))
          projectDetailsList=[Select Id,Name,Project_Manager__c,Project_Manager__r.Name,Project_Status__c,LBU__c from ProjectObject__c where Opportunity__c =: oppId];
       
       return projectDetailsList;
   }

   @Auraenabled
   public static list<Order> getOrderDetails(String oppId){
       List<Order> orderDetailsList;
       if(String.isNotBlank(oppId)){
           orderDetailsList=[Select Id,Status,Opportunity.recordtype.name,Opportunity.Actual_Record_Type_Name__c from Order where OpportunityId =: oppId];
       }   
       
       return orderDetailsList;
   }

   @Auraenabled
   public static list<Bureau_System__c> handleCandidateComponentVisibility(String jobId){
       List<Bureau_System__c> systemDetailsList;
       if(String.isNotBlank(jobId)){
        systemDetailsList=[Select Id from Bureau_System__c where Bureau_Job__c =: jobId];
       }   
       
       return systemDetailsList;
   }
    
   @Auraenabled
    public static String deleteCandidateRecord(String jobId,String candidateId){
        String result;
        List<Bureau_Candidate__c> candidateList = new List<Bureau_Candidate__c>();
        if(candidateId !=null){
          try{
            List<Bureau_Candidate__c> candidateRec = [Select id,Status2__c,Number_of_Respondents__c,Number_of_Product_Assessment__c,
                                                    Number_of_participants__c,Bureau_Job__c, Work_Request__c from Bureau_Candidate__c where id=:candidateId];
            delete candidateRec;
            RollUpCandidateFields.deleteRollupSummaryFieldsOnJob(candidateRec);
            RollUpCandidateFields.updateCandidateMaxSeqNoOnDelete(candidateRec);
              for(Bureau_Candidate__c b : candidateRec){
                  if(b.Work_Request__c != null){
                      candidateList.add(b);
                  }
              }
              if(!candidateList.isEmpty()){
                  RollUpCandidateFields.deleteRollupSummaryFieldsOnWRF(candidateList);
              }
          }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
          }
        }else{
           throw new AuraHandledException('There are no candidates available to delete.'); 
        }
        return result;
    }
    
    @Auraenabled
    public static String updateCandidateRecord(String jobId,Map<String,String> candidateRec,id candidateId){
        String result; 
        if(candidateId !=null){
          Bureau_Candidate__c newCandidateRec =null;
          Map<Id,Bureau_Candidate__c> newCandidateRecMap = new Map<Id,Bureau_Candidate__c>();
          try{
            Map<Id, Bureau_Candidate__c> oldCandidateMap = new Map<Id, Bureau_Candidate__c>([Select id,Status2__c,Number_of_Product_Assessment__c,Bureau_Job__c,
                                                           Number_of_participants__c,Number_of_Respondents__c from Bureau_Candidate__c where id =: candidateId]);
            newCandidateRec= new Bureau_Candidate__c(Id= candidateId , First_Name__c = candidateRec.get('First_Name__c'),
                                                    Last_Name__c=candidateRec.get('Last_Name__c'),Phone_Number__c=candidateRec.get('Phone_Number__c'),
                                                    System_s__c=candidateRec.get('System_s__c'),Email__c=candidateRec.get('Email__c'),
                                                    Gender__c=candidateRec.get('Gender__c'),Country__c=candidateRec.get('Country__c'),
                                                    Language__c=candidateRec.get('Language__c'),Username__c=candidateRec.get('Username__c'),
                                                    Reports_Status__c=candidateRec.get('Reports_Status__c'),Product_Assessment__c=candidateRec.get('Product_Assessment__c'),
                                                    Status2__c=candidateRec.get('Status2__c'),Bureau_Job__c=candidateRec.get('Bureau_Job__c'));
            update newCandidateRec;
            List<Bureau_Candidate__c> newCandidateList =[Select id,Number_of_Product_Assessment__c,Status2__c,Bureau_Job__c,
                                                                Number_of_participants__c,Number_of_Respondents__c from Bureau_Candidate__c where id =: candidateId];
            Map<Id, Bureau_Candidate__c> candidateMap = new Map<Id, Bureau_Candidate__c>(newCandidateList);        
            RollUpCandidateFields.updateRollupSummaryFieldsJobUpdate(newCandidateList, oldCandidateMap);
            RollUpCandidateFields.updateCountsOnJob(candidateMap,oldCandidateMap);
          }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
          }
        }else{
           throw new AuraHandledException('There are no candidates available to update.'); 
        }
        return result;
    }

   @Auraenabled
   public static String deleteCandidateList(String jobId){
       List<Bureau_Candidate__c> candidateList;
       String result; 
   
       if(String.isNotBlank(jobId)){
           candidateList=[select id from Bureau_Candidate__c where Bureau_Job__c=:jobId limit 501];
           if(candidateList == null || candidateList.size() == 0){
                result='There are no candidates available to delete.';
           }else if(candidateList.size() < 500){
                try{
                delete candidateList;
                Job__c JobRec = [Select id,Number_of_Assessments__c,Number_of_Respondents_New__c,Number_of_Participants_New__c ,
                                 Candidate_Max_Sequence_No_New__c,Count_of_Candidates_pass__c,Count_of_Candidates_fail__c,
                                 Count_of_Candidates_DNA__c, Actual_Count_of_Candidates_PassFail__c,Count_of_candidates_invited__c
                                 from Job__c where id =: jobId ];
                if(JobRec != null){
                  JobRec.Number_of_Assessments__c = 0;
                  JobRec.Number_of_Respondents_New__c = 0;
                  JobRec.Number_of_Participants_New__c = 0;
                  JobRec.Candidate_Max_Sequence_No_New__c = 0;
                  JobRec.Count_of_Candidates_pass__c = 0;
                  JobRec.Count_of_Candidates_fail__c = 0;
                  JobRec.Count_of_Candidates_DNA__c = 0;
                  JobRec.Actual_Count_of_Candidates_PassFail__c = 0;
                  JobRec.Count_of_candidates_invited__c = 0;
                  
                  update JobRec;
                }
                result='Candidates are deleted successfully';
                }catch(Exception ex){
                     throw new AuraHandledException(ex.getMessage());
                }
           }else{
                result='The candidate deletion process is in progress. You will be notified by an email once process is completed.';
                CandidateBulkDeletionBatch candidatebatch= new CandidateBulkDeletionBatch(jobId);
                Database.executeBatch(candidatebatch,2000);
           }
       }   
       
       return result;
   }
   
   @Auraenabled
   public static list<MS_Task__c> getMSTaskDetails( String statusValue){
       String recordTypeName='General MS Task';
       String query = 'SELECT ';
           query += 'Id, OwnerId,name, Owner.Name, RecordTypeId,Task_Completed_On__c, Task_Category__c,createddate, Task_Type__c, Task_Date__c, ';
           query += 'Scheduled_Time__c, Estimated_Time_Required__c, Actual_Time_Taken__c,Systems__c, UnScheduled__c, ';
           query += 'Comments__c, Task_Status__c, LastModifiedBy.Name, LastModifiedDate, Task_Start_Time__c, Task_End_Time__c, ';
           query += 'Timer_Stopped_At__c, Timer_Resumed_At__c, Timer_Offset__c,IT_Ticket_Number__c, Original_Time_Taken__c ';

       String condition = (String.isNotBlank(statusValue)
               ? 'Task_Status__c = \'' + statusValue + '\''
               : '');
       condition += String.isNotBlank(condition) ? +' AND ' : '';
       condition += 'OwnerId = ' + '\'' + userinfo.getUserId() + '\'';
       condition += 'AND recordtype.name = ' + '\'' + recordTypeName + '\'';
       query += 'FROM MS_Task__c WHERE ' + condition + ' ORDER BY Task_Date__c desc LIMIT 200';
       
       return (List<MS_Task__c>) Database.query(query);
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
               //String timeStamp = UserInfo.getName() + '\n' + String.valueOf(System.now()) + '\n';
               if(String.isNotBlank(currentTaskData.Comments__c)) {
                   taskData.Comments__c = currentTaskData.Comments__c + '\n\n' + taskData.Comments__c;
               } else {
                   taskData.Comments__c = taskData.Comments__c;
               }
           }
           update taskToUpdateList;
           return taskToUpdateList;
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }

   @AuraEnabled
    public static void cloneTasks(String jsonOfListOfTasks, String jobRecordId) {
        try {
            Integer priorityValue=0;
            List<MS_Task__c> listOfTasks = (List<MS_Task__c>) JSON.deserialize(jsonOfListOfTasks, List<MS_Task__c>.class);
            insert listOfTasks;
        } catch (Exception e) {
            AuraHandledException auraException = new AuraHandledException(e.getMessage());
            auraException.setMessage(e.getMessage());
            throw auraException;
        }
    }

}
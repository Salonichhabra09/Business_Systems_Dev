global with sharing class RevertIsExportedOnCandidate implements Database.Batchable<sObject>, Database.Stateful{

    global final String finalQuery;
    global Job__c job;
    
    global RevertIsExportedOnCandidate(Job__c jb) {
        job = jb;
        String query;
        
        query='SELECT Id,Name,First_Name__c,Last_Name__c,Email__c,Email2__c,Phone_Number__c,JCF_Name__c,Region__c,Job_Role__c,Job_Level__c,Department__c,Functional_Role__c,Candidate_Personal_Id__c,Talent_Central_ID__c,Session_ID__c,Unique_Link__c,Project_Name__c,Generic_Data_1__c,Generic_Data_2__c,Generic_Data_3__c,Country__c,Language__c,Gender__c,Reports_Status__c,isExported__c,';
        query+='(SELECT Id,Bureau_System__c,Username__c,Password__c, URL__c FROM Bureau_Candidate_Logins__r)';
        query+=' FROM Bureau_Candidate__c where Bureau_Job__c=\''+job.Id+'\'';
        query+=' AND isExported__c = true';
        
        finalQuery = query;

    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
      return Database.getQueryLocator(finalQuery);
    }
   
    global void execute(Database.BatchableContext BC,List<Bureau_Candidate__c> scope)
    {
        for(Bureau_Candidate__c s : scope){
            s.isExported__c = false;
        }
        UPDATE scope;
    }

    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        if(a.Status=='Completed')
        {
            job.Capture_Content_Version_Ids_For_Export__c = null;
            UPDATE job;
            System.debug('If Success');
        }else{
            System.debug('Else Error');
        }
    }
}
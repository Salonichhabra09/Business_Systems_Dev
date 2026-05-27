/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 29-07-2019
DESCRIPTION :- This class contains Job trigger related functionalities : after Insert (Creation of Managed Services Invoices for Job,Creating Managed Services System for System type Job records,
Upsert task fields for Not started type tasks related to Pipeline Job, Migrating MS Pipeline Open Task to MS Commenced Task)
***************************************************************************************************************************************/ 

global class JobTriggerManager_3{
   public static void Job_AfterInsert(List<Job__c> JobNewList){    
   List<Bureau_Invoice__c> bureauInvoiceList = new List<Bureau_Invoice__c>();
    List<Task> defaultTask = new List<Task>();
    Map<Id,Set<Job__c>> CloneJobMap = new Map<Id,Set<Job__c>>();
    Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>();
    for(RecordType rt:[Select Id,Name,DeveloperName from RecordType where IsActive= true AND SobjectType = 'Job__c' AND DeveloperName IN('Managed_Service_Commenced','Project_Job','Bureau_Service','Managed_Service_Pipeline')]){
        recordTypeMap.put(rt.Id,rt);
    }
    Map<Id,Id> PipelineCommencedMap = new Map<Id,Id>();
    for(Integer i=0; i< JobNewList.size();i++){
        //If Record type if either Project Job or Bureau Service
        if(recordTypeMap.containsKey(JobNewList[i].RecordTypeId)){          
            // Added new condition to create an invoice for the Managed Service Commenced Record Type SSE-106
           // if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Bureau_Service' || recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Project_Job' || recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){    
            if(recordTypeMap.get(JobNewList[i].RecordTypeId).DeveloperName=='Managed_Service_Commenced'){
                Bureau_Invoice__c bureauInvoice = new Bureau_Invoice__c();
                bureauInvoice.Job__c = JobNewList[i].id;
                bureauInvoice.InvoiceType__c = 'Invoice';               
                bureauInvoice.InvoiceStatus__c = 'Created';              
                bureauInvoice.CurrencyIsoCode = JobNewList[i].CurrencyToBeBilled__c;
                bureauInvoiceList.add(bureauInvoice);
               
                System.debug('the first condition is being called');
            }
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
    ManageJobTask_Controller.createBureauSystem(CloneJobMap);
        
    if(PipelineCommencedMap.size()>0){
    System.debug('The if condition works');
        List<Job__c> updatePipelineJObList = new List<Job__c>();
        for(Job__c job :[Select id,Pipeline_Status__c,(SELECT Id,Subject,WhatId,OwnerId,ActivityDate,Status,Priority,EstimatedDurationInMinutes__c,UnScheduled__c,Description FROM Tasks where Status='Not Started' order by ActivityDate desc) from Job__c where Id IN: PipelineCommencedMap.keySet()]){
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
    if(bureauInvoiceList.size()>0)
        insert bureauInvoiceList;
        
   }
}
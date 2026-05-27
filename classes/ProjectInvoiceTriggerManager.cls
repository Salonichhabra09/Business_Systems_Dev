/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND	
CREATED DATE :- 23-08-2019
DESCRIPTION :- This class contains various validations and assignments on fields of Invoice Request object, this class is called in ProjectInvoice_Trigger.
***************************************************************************************************************************************/ 

Global class ProjectInvoiceTriggerManager {
    
    //This method is throwing error on below conditions
    //1) If status is Processed and user is trying to delete invoice request.
    //2) If PSA_Role is not equal to PSA Lead or Project mangaer and user try to delete record.
    public static void CheckInvoiceDeletion(List<Project_Invoice__c> ProjectInvoices){
        List<ProjectObject__c> projects = Project_Manager.getProjectsForInvoices(ProjectInvoices);
        Map<Id, Boolean> projectAccessMap = Project_Manager.userCanManageProjects(projects);
        for(Integer i=0;i<ProjectInvoices.size();i++)
        {
            if(ProjectInvoices[i].Status__c == 'Processed')
                ProjectInvoices[i].addError('This invoice request has processed status therefore you cannot delete this invoice.'); 
            else
            {
                Boolean userCanDeleteProjectInvoice = projectAccessMap.get(ProjectInvoices[i].Project__c); 
                if(!userCanDeleteProjectInvoice)
                    ProjectInvoices[i].addError('You are not authorised to delete this invoice. Please contact GSD if you believe this to be incorrect.');
            }
        }
    }
    
    //This method is updating Account_Owner__c and CurrencyIsoCode of InvoiceRequest object
    public static void UpdateAccountOwnerAndCurrencyIsoCode(List<Project_Invoice__c> ProjectInvoices){
        List<Id> ProjectIds = new List<Id>();
        Set<Id> accountIdsSet = new Set<Id>();
        for(Integer i=0;i<ProjectInvoices.size();i++)
        {
            ProjectIds.add(ProjectInvoices[i].Project__c);
            accountIdsSet.add(ProjectInvoices[i].Account__c);
        }
        Map<Id,Account> accountMap = new Map<Id,Account>([Select id,CurrencyIsoCode,OwnerId from Account where id in :accountIdsSet]);  
        Map<Id,ProjectObject__c> projectMap = new Map<Id,ProjectObject__c>([SELECT ID,Account__c,Account__r.OwnerId, CurrencyIsoCode, Project_Type__c from ProjectObject__c WHERE id IN:ProjectIds]);
        if(projectMap!=null)
        {
            for(Project_Invoice__c InvoiceRequest:ProjectInvoices)
            {
                if(InvoiceRequest.Account__c != null)
                    InvoiceRequest.Account_Owner__c = accountMap.get(InvoiceRequest.Account__c).OwnerId;
                InvoiceRequest.CurrencyIsoCode = projectMap.get(InvoiceRequest.Project__c).CurrencyIsoCode;
            }
        }
        
    }
    
    //This method is performing below tasks
    //1) If status is changed to 'Submitted For Processing' then set 'Submitted_By__c' to User id.
    //2) if status is 'Processed' and Sun_Invoice_No__c is null then throw error.
    //3) Populate Invoice with updated amounts.
    //4) Process IMLookup Values.
    //5) Update Account_Owner__c of Invoice request object.
    public static void BeforeUpdateTasks(List<Project_Invoice__c> NewProjectInvoices,List<Project_Invoice__c> OldProjectInvoices){
        Set<Id> accountIdsSet = new Set<Id>();
        for(Integer i=0;i<NewProjectInvoices.size();i++)
        {
            if(NewProjectInvoices[i].Account__c!=OldProjectInvoices[i].Account__c)
                accountIdsSet.add(NewProjectInvoices[i].Account__c);
            
            //Swati added below code on 10/16/2013 to update Submitted By field when status is Submitted for Processing
            if(NewProjectInvoices[i].Status__c != OldProjectInvoices[i].Status__c && NewProjectInvoices[i].Status__c == 'Submitted For Processing')
            {
                NewProjectInvoices[i].Submitted_By__c = userInfo.getUserId();
            }
            //Swati added below code on 10/16/2013 to update Submitted By field when status is Submitted for Processing
            
            if(NewProjectInvoices[i].Status__c == 'Processed')
            {
                if (NewProjectInvoices[i].Sun_Invoice_No__c ==null)
                    NewProjectInvoices[i].addError('Please enter SUN Order No to Process this Invoice Request');
                //Swati added below code on 10/16/2013 to update Approved By field when status is Processed         
                NewProjectInvoices[i].Approved_By__c = userInfo.getUserId();
                //Swati added below code on 10/16/2013 to update Approved By field when status is Processed
            }
            
            if ((NewProjectInvoices[i].Start_Date__c != OldProjectInvoices[i].Start_Date__c)  
             //  || (NewProjectInvoices[i].End_Date__c != OldProjectInvoices[i].End_Date__c) 
             || (NewProjectInvoices[i].CurrencyIsoCode != OldProjectInvoices[i].CurrencyIsoCode))
              ProjectInvoice_Manager.populateInvoiceWithUpdatedAmounts(NewProjectInvoices[i], true, true, true);
            
         ProjectInvoice_Manager.processIMLookupvalues(NewProjectInvoices[i]);
        }
        if(accountIdsSet.size()>0)
        {
            Map<Id,Account> accountMap = new Map<Id,Account>([Select id,CurrencyIsoCode,OwnerId from Account where id in :accountIdsSet]);  
            for(Integer i=0;i<trigger.new.size();i++)
            {
                if(NewProjectInvoices[i].Account__c!=OldProjectInvoices[i].Account__c)
                    NewProjectInvoices[i].Account_Owner__c = accountMap.get(NewProjectInvoices[i].Account__c).OwnerId;
            }
        }
        
    }
}
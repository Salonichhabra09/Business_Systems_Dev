global class Timesheet_Manager 
{

    public static Project_Invoice__c[] getRelatedInvoices(Timesheet_Line__c[] timesheets)
    {
        Set<Id> projectIds = new Set<Id>();
        Map<Id, Date> startDates = new Map<Id, Date>();
        Map<Id, Date> endDates = new Map<Id, Date>();
            
        //Loop through the list of timesheets.
        for(Timesheet_Line__c timesheet: timesheets)
        {
            //If the projectIds list does not contain the project of this timesheet 
            if(!projectIds.contains(timesheet.Project__c))
                //Add the project of this timesheet to the projectIds list
                projectIds.add(timesheet.Project__c);
            //If the startDates list does not contain an entry for the project of this timesheet OR the current timesheet's date is less than the startdate entry for this timesheet's project 
            if(!startDates.containsKey(timesheet.Project__c) || timesheet.Date_Invoiced__c < startDates.get(timesheet.Project__c))
                //Add this timesheet's projectId and Date to the startDates list.
                startDates.put(timesheet.Project__c,timesheet.Date_Invoiced__c); 
            //If the endDates list does not contain an entry for the project of this timesheet OR the current timesheet's date is less than the endDate entry for this timesheet's project
            if(!endDates.containsKey(timesheet.Project__c) || timesheet.Date_Invoiced__c > endDates.get(timesheet.Project__c))
                //Add this timesheet's projectId and Date to the endDates list.
                endDates.put(timesheet.Project__c,timesheet.Date_Invoiced__c); 
        }
        
        //Intialize a new list of Invoices related to each of the given timesheets
        List<Project_Invoice__c> relatedInvoices = new List<Project_Invoice__c>();
        //Loop through the above created list of projectIds 
        for(Id projectId: projectids)
        {
            //Fetch the list of invoices related to the current project
            List<Project_Invoice__c> invoices = [SELECT id, Start_Date__c, End_Date__c, Project__c, CurrencyIsoCode FROM Project_Invoice__c 
                                                WHERE Project__c= :projectId AND Status__c= :'In Progress' AND Start_Date__c<= :startDates.get(projectId) AND End_Date__c>= :endDates.get(projectId)];
            //Add the fetched invoces to the related invoices list
            relatedInvoices.addAll(invoices);
        }
        //return the list of invoices related to each of the given timesheets
        return relatedInvoices;
    }

    public static void updateRelatedInvoices(Timesheet_Line__c[] timesheets)
    {
        //Prepare a list of invoices to be updated.
        List<Project_Invoice__c> invoices = new List<Project_Invoice__c>();
        for(Project_Invoice__c relatedInvoice: getRelatedInvoices(timesheets))
            invoices.add(ProjectInvoice_Manager.getInvoiceWithUpdatedAmounts(relatedInvoice, true, false, false));
             
        //If there are any invoice to be updated
        if(invoices.size()>0)
            update invoices;
    }
      
    public static void copyDataFromProject(List<Timesheet_Line__c> timesheets)
    {
        Set<Id> projectIds = new Set<Id>();
        for(Timesheet_Line__c timesheet: timesheets)
            if(!projectIds.contains(timesheet.Project__c))
                    projectIds.add(timesheet.Project__c);
        Map<Id, ProjectObject__c> projectsMap = new Map<Id, ProjectObject__c>([SELECT Id, Project_Manager__c FROM ProjectObject__c WHERE id IN :projectIds]);
        for(Timesheet_Line__c timesheet: timesheets)
           if(timesheet.Project_Manager__c==null){
                if(projectsMap.containsKey(timesheet.Project__c)){
                    if(projectsMap.get(timesheet.Project__c).Project_Manager__c != null){
                        timesheet.Project_Manager__c = projectsMap.get(timesheet.Project__c).Project_Manager__c;
                    }
                }
            }
    } 
    
    public static void updateTimeCostValues(List<Timesheet_Line__c> timesheets)
    {
        //Create a set of all distinct ResourceIds for the inserted records 
        Set<Id> resourceIds = new Set<Id>();
        for(Timesheet_Line__c timesheet: timesheets)
            if(!resourceIds.contains(timesheet.Resource__c))
                resourceIds.add(timesheet.Resource__c);
        //Create a map of all distinct resources for the inserted records 
        Map<Id, User> resourcesMap = new Map<Id, User>([SELECT Id, Time_Rate_Cost__c, DefaultCurrencyIsoCode FROM User WHERE Id in :resourceIds]);
        
        Map<String, Double> currencyMap = new Map<String, Double>();
        for(CurrencyType currencyType: [SELECT IsoCode, ConversionRate FROM CurrencyType])
            currencyMap.put(currencyType.IsoCode, currencyType.ConversionRate);
            
        for(Timesheet_Line__c timesheet: timesheets)
        {
            if(resourcesMap.get(timesheet.Resource__c).Time_Rate_Cost__c == null)
                timesheet.Time_Cost__c = 0;
            else if(timesheet.CurrencyIsoCode != 'GBP')
            {
                Double timesheetCurrencyConversionRate = currencyMap.get(timesheet.CurrencyIsoCode);
                //Double resourceCurrencyConversionRate = currencyMap.get(resourcesMap.get(timesheet.Resource__c).DefaultCurrencyIsoCode);
                timesheet.Time_Cost__c = resourcesMap.get(timesheet.Resource__c).Time_Rate_Cost__c * timesheetCurrencyConversionRate * timesheet.Hours__c;
            }
            else
                timesheet.Time_Cost__c = resourcesMap.get(timesheet.Resource__c).Time_Rate_Cost__c * timesheet.Hours__c;
        }
    }

    public static void updateDataInTimesheets(ProjectObject__c oldProject, ProjectObject__c newProject)
    {
        if(oldProject.OwnerId != newProject.OwnerId)
             updateProjectManagerInTimesheets(newProject.Id,  newProject.OwnerId);
    } 
    
    @future private static void updateProjectManagerInTimesheets(String projectId, String projectManagerId)
    {
        Timesheet_Line__c[] timesheets = [SELECT Id, Project__c FROM Timesheet_Line__c WHERE Project__c = :projectId AND Invoice_Request__c= :null];
        for(Integer i=0;i<timesheets.size();i++)
            timesheets[i].Project_Manager__c = projectManagerId;
        update timesheets;
    } 
    
    public static void updateDataInTimesheets(Project_Invoice__c oldInvoice, Project_Invoice__c newInvoice)
    {
        //if(oldInvoice.Status__c != newInvoice.Status__c)
            //updateStatusInTimesheets(newInvoice.Project__c, newInvoice.Start_Date__c, newInvoice.End_Date__c, newInvoice.Id, newInvoice.Status__c);
    }
    
   /* @future private static void updateStatusInTimesheets(String projectId, Date startDate, Date endDate, String invoiceId, String invoiceStatus)
    {
        List<Timesheet_Line__c> timesheets;
        if(invoiceStatus == 'Submitted for Processing')
        {
            //Update the status of the related expenses
            timesheets = [SELECT id, Invoice_Request__c, Status__c FROM Timesheet_Line__c WHERE Project__c= :projectId AND Billable__c=:true AND Date_Invoiced__c>= :startDate AND Date_Invoiced__c<= :endDate AND (Status__c= :'Approved' OR Status__c= :'Submitted for Approval')];
            for(Timesheet_Line__c timesheet: timesheets)
            {
                timesheet.Status__c = 'Submitted for Processing';
                timesheet.Invoice_Request__c = invoiceId;
            }
        }
        else if (invoiceStatus == 'Processed')
        {
            //Update the status of the related expenses
            timesheets = [SELECT id FROM Timesheet_Line__c WHERE Invoice_Request__c= :invoiceId];
            for(Timesheet_Line__c timesheet: timesheets)
                timesheet.Status__c = 'Processed';
        } 
        else
        {
            //Update the status of the related expenses
            timesheets = [SELECT id FROM Timesheet_Line__c WHERE Invoice_Request__c= :invoiceId];
            for(Timesheet_Line__c timesheet: timesheets)
            {
                timesheet.Status__c = 'Approved';
                timesheet.Invoice_Request__c = null;
            }
        }
        update timesheets;
    }  */
    
           
}
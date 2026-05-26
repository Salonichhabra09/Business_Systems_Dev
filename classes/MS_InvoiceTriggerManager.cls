/*****************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 19-08-2019
DESCRIPTION :- This class contains Methods to Check & controll MS Invoice Functionality as per SHL business process,
this class is being refered from MS_Invoice_Trigger, covering all the Before/After, Insert & Update Events on MS Invoice Records. 
******************************************************************************/

Global class MS_InvoiceTriggerManager {
    
    public MS_InvoiceTriggerManager() {
        
    }
    
    //This Method updates the MS Invoice LineItems on the basis of Invoice Status
    /*Public static void UpdateLineItems(List<bureau_invoice__c> NewInvoiceList){
        List<Bureau_Invoice_Line_Item__c> biList = new List<Bureau_Invoice_Line_Item__c>();
        Set<String>bIds = new Set<String>();
        for(bureau_invoice__c bi:NewInvoiceList){
            if(bi.InvoiceStatus__c=='SOE Complete'){
                bIds.add(bi.id);
            }
        }
        for(Bureau_Invoice_Line_Item__c bil :[select id,name,Units__c,Number_Of_Candidates__c from Bureau_Invoice_Line_Item__c where Bureau_Invoice__r.id IN :bIds AND Units__c=0]){
            bil.Units__c=bil.Number_Of_Candidates__c;
            biList.add(bil);
        }
        update biList;        
    }
    //This method Sets the Currency Iso Code on Invoice creation & creates the Task with the Job during an Update
    Public static void GetCurrencyCreateTask(List<bureau_invoice__c> NewInvoiceList,List<bureau_invoice__c> OldInvoiceList, Boolean IsInsert,Boolean IsUpdate ){
        Set<Id> jobIdsSet = new Set<Id>();
        for(Integer i=0; i< NewInvoiceList.size();i++)  
            jobIdsSet.add(NewInvoiceList[i].Job__c);
        Map<Id,Job__c> jobsMap = new Map<Id,Job__c>([Select id,CurrencyToBeBilled__c,Project_Lead__c from Job__c where id in :jobIdsSet]);
        
        if(IsInsert)
        {
            for(Integer i=0; i< NewInvoiceList.size();i++)  
                NewInvoiceList[i].CurrencyIsoCode = jobsMap.get(NewInvoiceList[i].Job__c).CurrencyToBeBilled__c;
        }
        try{
            if(IsUpdate)
            {
                List<Task> LTask = new List<Task>();
                for(Integer i=0; i< NewInvoiceList.size();i++) 
                {
                    if(NewInvoiceList[i].InvoiceType__c == 'SOE Query' && OldInvoiceList[i].InvoiceType__c != 'SOE Query')
                    {
                        //Date myDate = date.newinstance(Trigger.new[i].CreatedDate.year(), Trigger.new[i].CreatedDate.month(), Trigger.new[i].CreatedDate.day());
                        Task newobj = new Task();
                        newobj.ActivityDate = system.Today();
                        newobj.Description = 'The following Managed Services Invoice record has been updated to SOE Query - please review';
                        newobj.EstimatedDurationInMinutes__c = 5;
                        newobj.OwnerID = jobsMap.get(NewInvoiceList[i].Job__c).Project_Lead__c;
                        newobj.Status = 'Not Started';
                        newobj.Task_Category__c = 'Post Launch';
                        newobj.Task_Type__c = 'Invoice Query';
                        newobj.WhatID = NewInvoiceList[i].Job__c;
                        LTask.add(newobj);
                    }
                    if(LTask.size()>0)
                        insert LTask;
                }
            }
        }
        catch(Exception e)
        {
            for (Bureau_Invoice__c Invoice:NewInvoiceList) {
                Invoice.addError('There was a problem Inserting the Tasks' + e);
            }
        }
        
    }*/
}
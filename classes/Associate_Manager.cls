public class Associate_Manager{
    
    // This method results in adding Associate records in a list when Date Invoice Received, Rechargeable,CurrencyISo code and Total Invoice amount fields are getting updated.
    public static void Associate_AfterUpdateChecks(List<Associate__c> AssociateNewList, List<Associate__c> AssociateOldList){
        List<Associate__c> associates =  new List<Associate__c>();
        for(integer i=0;i<AssociateNewList.size();i++){ 
          if (AssociateNewList[i].Date_Invoiced_Received__c != AssociateOldList[i].Date_Invoiced_Received__c || AssociateNewList[i].Rechargeable__c != AssociateOldList[i].Rechargeable__c
              || AssociateNewList[i].CurrencyIsoCode != AssociateOldList[i].CurrencyIsoCode || AssociateNewList[i].Total_Invoice_Amount__c != AssociateOldList[i].Total_Invoice_Amount__c){
                    associates.add(AssociateOldList[i]);
                    associates.add(AssociateNewList[i]);
              }   
        }
        updateRelatedInvoices(associates);
    }
    
    // To get related invoices of Associates
    public static Project_Invoice__c[] getRelatedInvoices(Associate__c[] associates){
        //Intialize the list of related invoices.
        List<Project_Invoice__c> invoices = new List<Project_Invoice__c>();
        Map<Id,Project_Invoice__c> invoicesMap = new Map<Id,Project_Invoice__c>();     
        //Loop through each of the expenses if it is bulk update of more than one expenses.
        for(Associate__c selectedAssociate: associates){ 
            //Loop through each of the invoices which need to be updated against this associate.
            for(Project_Invoice__c invoice: [SELECT Id, Start_Date__c, End_Date__c, Project__c,CurrencyIsoCode
                                                FROM Project_Invoice__c 
                                                WHERE Project__c= :selectedAssociate.Project__c 
                                                AND Start_Date__c<= :selectedAssociate.Date_Invoiced_Received__c 
                                                AND End_Date__c>= :selectedAssociate.Date_Invoiced_Received__c
                                                AND Status__c= :'In Progress'])
            {
                 if(!invoicesMap.containsKey(invoice.id)){
                    invoicesMap.put(invoice.id, invoice);
                    invoices.add(invoice);
                 }
            }
         }    
        return invoices;
    }
    
    // Method To update related invoices
    public static void updateRelatedInvoices(Associate__c[] associates){
         //Prepare a list of invoices to be updated.
        List<Project_Invoice__c> invoices = new List<Project_Invoice__c>();
        for(Project_Invoice__c relatedInvoice: getRelatedInvoices(associates))
            invoices.add(ProjectInvoice_Manager.getInvoiceWithUpdatedAmounts(relatedInvoice, false, false, true));        
        //If there are any invoice to be updated
        if(invoices.size()>0)
            update invoices;
    }
       
}
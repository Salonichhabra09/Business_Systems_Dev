public class InvoiceBillingDetailsOverrirdeController {
    public Invoice_Billing_Detail__c  invoiceBillingDetail{get;set;}
    public Project_Invoice__c invoice{get;set;}
    public string InvoiceBillingDetailsId {get;set;}
    public InvoiceBillingDetailsOverrirdeController(ApexPages.StandardController controller){
        InvoiceBillingDetailsId =ApexPages.currentPage().getParameters().get('Id');
        invoiceBillingDetail = [select id,Invoice_Request__c from Invoice_Billing_Detail__c where id=:InvoiceBillingDetailsId];
        invoice =[select id,Status__c from Project_Invoice__c where id=:invoiceBillingDetail.Invoice_Request__c];       
    }
}
public class InvoiceBillingDetailsOnIRController {

    public string InvoiceRequestId {get;set;}
    public list<Invoice_Billing_Detail__c> InvoiceDetailsList{get;set;}
    public Project_Invoice__c invoice{get;set;}
    public boolean disablebutton{get;set;}
    public boolean IsSuperUser{get;set;}
    public List<SelectOption> DiscountApprovers
    {
        get
        {
            if(this.DiscountApprovers==null)
            {
                this.DiscountApprovers = new List<SelectOption>();
                this.DiscountApprovers.add(new SelectOption('','--None--'));
                for(User user: [SELECT Id, Name FROM User WHERE Approve_TE_Discounts__c =:true and isactive=:true ORDER BY Name ASC])
                    this.DiscountApprovers.add(new SelectOption(user.Id,user.Name));
            }
            return this.DiscountApprovers;
        }
        set;
    }
    public InvoiceBillingDetailsOnIRController(){
        disablebutton = false;
        IsSuperUser = false;
        InvoiceRequestId=ApexPages.currentPage().getParameters().get('InvoiceRequest');
        invoice = [select id,Discount_Approved_By__c,CurrencyISOCode,Status__c,Project__r.Project_Manager__c,Project__r.Project_Co_ordinator__c,Credit__c from Project_Invoice__c where id=:InvoiceRequestId];
        InvoiceDetailsList = [Select IM_Code__c,Quantity__c,Amount_Unit_Price__c,Discount_Amount__c,Expense_Recharge__c,Product__r.name,Total_Amount__c from Invoice_Billing_Detail__c where Invoice_Request__c=:InvoiceRequestId];
        
        List<ProjectObject__Share> Shrarerecords = [select UserOrGroupId from ProjectObject__Share where ParentId =:invoice.Project__c];
        Id Groupid;
        For(ProjectObject__Share sharingrec:Shrarerecords){
            String usergroupID = sharingrec.UserOrGroupId;
            if(usergroupID.startsWith('00G')) 
                Groupid= usergroupID;
        }
        System.debug('This is Group ID '+Groupid);
        for(GroupMember m : [Select UserOrGroupId From GroupMember Where GroupId =:Groupid]) {
            System.debug('This is group member ID '+m.UserOrGroupId);
            if(m.UserOrGroupId==UserInfo.getUserId()){
                IsSuperUser=True;
                break;
            }
        }
        System.debug('This is logged in user ID '+UserInfo.getUserId());
        System.debug('This is boolean '+IsSuperUser);
        
    }
    
    public PageReference Save(){
        disablebutton = true;
        for(Invoice_Billing_Detail__c invoicebill:InvoiceDetailsList)
        {
         if(invoice.Credit__c==true && invoicebill.Amount_Unit_Price__c>0)
          invoicebill.Amount_Unit_Price__c = 0-invoicebill.Amount_Unit_Price__c;
         else if(invoice.Credit__c==true && invoicebill.Expense_Recharge__c>0)
          invoicebill.Expense_Recharge__c = 0-invoicebill.Expense_Recharge__c;
         else 
          continue;
        }
        update InvoiceDetailsList;
        update invoice;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Invoice Billing Details added successfully.Thank you!'));
        PageReference pg = new PageReference('/'+ApexPages.currentPage().getParameters().get('InvoiceRequest'));
        pg.setRedirect(true);
        return pg; 
    }

}
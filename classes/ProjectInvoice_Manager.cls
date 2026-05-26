global class ProjectInvoice_Manager 
{ 
    WebService static void populateInvoiceWithUpdatedAmounts(Project_Invoice__c selectedInvoice, Boolean includeTimesheets, Boolean includeExpenses, Boolean includeAssociates)
    {
        Project_Invoice__c invoice = getInvoiceWithUpdatedAmounts(selectedInvoice, includeTimesheets, includeExpenses, includeAssociates);
        if(includeTimesheets)
        {
            selectedInvoice.Unapproved_Time_Amount__c = invoice.Unapproved_Time_Amount__c;
            selectedInvoice.Approved_Time_Amount__c = invoice.Approved_Time_Amount__c;
        }
        if(includeExpenses)
        {
            selectedInvoice.Unapproved_Expenses_Amount__c = invoice.Unapproved_Expenses_Amount__c;
            selectedInvoice.Approved_Expenses_Amount__c = invoice.Approved_Expenses_Amount__c;
        }
        if(includeAssociates)
        {
            selectedInvoice.Total_Rechargeable_Associate_Costs__c = invoice.Total_Rechargeable_Associate_Costs__c;
            selectedInvoice.Total_Associate_Costs__c = invoice.Total_Associate_Costs__c;
            selectedInvoice.Total_Associate_Expenses__c = invoice.Total_Associate_Expenses__c;
        }
    }
   
    WebService static Project_Invoice__c getInvoiceWithUpdatedAmounts(Project_Invoice__c selectedInvoice, Boolean includeTimesheets, Boolean includeExpenses, Boolean includeAssociates)
    {
        //Intialize the instance of the invoice that is to be returned by the function
        Project_Invoice__c invoice = new Project_Invoice__c(id=selectedInvoice.id);
        
        Map<String, Double> currencyMap = new Map<String, Double>();
        for(CurrencyType currencyType: [SELECT IsoCode, ConversionRate FROM CurrencyType])
            currencyMap.put(currencyType.IsoCode, currencyType.ConversionRate);
               
        //Find the Invoice CurrencyType
        Double invoiceCurrencyConversionRate = currencyMap.get(selectedInvoice.CurrencyIsoCode);
        
        if(includeTimesheets == true)
        {
            //Reset the Timesheet Amounts
            invoice.Unapproved_Time_Amount__c = 0;
            invoice.Approved_Time_Amount__c = 0;
            
            //Fetch the timesheet entries related to the invoice
            for(Timesheet_Line__c timesheet : [SELECT id, Hours__c, Billing_Rate__c,
                CurrencyIsoCode, Status__c FROM Timesheet_Line__c 
                                                WHERE Project__c= :selectedInvoice.Project__c 
                                                AND Billable__c=:true 
                                                AND Billing_Rate__c<>null
                                               AND Date_Invoiced__c>= :selectedInvoice.Start_Date__c 
                                               // AND Date_Invoiced__c<= :selectedInvoice.End_Date__c 
                                                AND Invoice_Request__c= :null 
                                                AND Status__c IN  ('Approved', 'Submitted for Approval') 
                                                ORDER BY CurrencyIsoCode])
            {
                //Find the Timesheet Currency Conversion Rate
                Double timesheetCurrencyConversionRate = currencyMap.get(timesheet.CurrencyIsoCode);
                
                ///Add the Timesheet Amount in the Invoice Currency
                if(timesheet.Status__c == 'Approved')
                    invoice.Approved_Time_Amount__c += (timesheet.Hours__c/8)*(invoiceCurrencyConversionRate/timesheetCurrencyConversionRate);
                        //timesheet.Billing_Rate__c
                else
                    invoice.Unapproved_Time_Amount__c += (timesheet.Hours__c/8)*timesheet.Billing_Rate__c*(invoiceCurrencyConversionRate/timesheetCurrencyConversionRate);
            
            }
        }
        
        if(includeExpenses == true)
        {
            //Reset the Expense Amounts
            invoice.Unapproved_Expenses_Amount__c = 0;
            invoice.Approved_Expenses_Amount__c = 0;
            
            //Fetch the expense entries related to the invoice
            for(Expense__c expense : [SELECT id, Value__c, CurrencyIsoCode, Status__c FROM Expense__c WHERE Project__c= :selectedInvoice.Project__c AND Date_Incurred__c>= :selectedInvoice.Start_Date__c AND /*Date_Incurred__c<= :selectedInvoice.End_Date__c AND*/ Rechargeable__c= :true AND Invoice_Request__c= :null AND (Status__c= :'Approved' OR Status__c= :'Submitted for Approval') ORDER BY CurrencyIsoCode])
            {
                //Find the Timesheet Currency Conversion Rate
               Double expenseCurrencyConversionRate = currencyMap.get(expense.CurrencyIsoCode);
             
                //Add the Expense Amount in the Invoice Currency
               if(expense.Status__c == 'Approved')
                  invoice.Approved_Expenses_Amount__c += expense.Value__c*invoiceCurrencyConversionRate/expenseCurrencyConversionRate;
               else
                   invoice.Unapproved_Expenses_Amount__c += expense.Value__c*invoiceCurrencyConversionRate/expenseCurrencyConversionRate;
            } 
        }
        
        if(includeAssociates == true)
        {
            invoice.Total_Rechargeable_Associate_Costs__c = 0;
            invoice.Total_Associate_Costs__c = 0;
            invoice.Total_Associate_Expenses__c = 0;
            //to include Associate Costs
           for(Associate__c associate : [SELECT id, Total_Invoice_Amount__c, Rechargeable__c, Expenses__c, CurrencyIsoCode FROM Associate__c WHERE Project__c= :selectedInvoice.Project__c AND Date_Invoiced_Received__c>= :selectedInvoice.Start_Date__c /*AND Date_Invoiced_Received__c<= :selectedInvoice.End_Date__c*/])
            {
                //Find the Associate Currency Conversion Rate
                Double associateCurrencyConversionRate = currencyMap.get(associate.CurrencyIsoCode);
           
                //Add the Associate Amount in the Invoice Currency
               invoice.Total_Associate_Costs__c += associate.Total_Invoice_Amount__c*invoiceCurrencyConversionRate/associateCurrencyConversionRate;
                
               if(associate.Expenses__c != null)
                    invoice.Total_Associate_Expenses__c += associate.Expenses__c*invoiceCurrencyConversionRate/associateCurrencyConversionRate;
                
                if(associate.Rechargeable__c == true)
                   invoice.Total_Rechargeable_Associate_Costs__c += associate.Total_Invoice_Amount__c*invoiceCurrencyConversionRate/associateCurrencyConversionRate;
           } 
        }   
        
        return invoice;
    }


    WebService static Expense__c[] getExpensesRelatedToInvoice(Project_Invoice__c invoice)
    {
        Expense__c[] expenses;
        if(invoice.Status__c == 'In Progress')
            expenses = [SELECT id FROM Expense__c WHERE Project__c= :invoice.Project__c AND Date_Incurred__c>= :invoice.Start_Date__c /*AND Date_Incurred__c<= :invoice.End_Date__c*/ AND Invoice_Request__c= :null];
        else
            expenses = [SELECT id FROM Expense__c WHERE Invoice_Request__c= :invoice.id];
        return expenses;
    } 
    
    WebService static Timesheet_Line__c[] getTimesheetsRelatedToInvoice(Project_Invoice__c invoice)
    {
        Timesheet_Line__c[] timesheets;
        if(invoice.Status__c == 'In Progress')
          timesheets = [SELECT id FROM Timesheet_Line__c WHERE Project__c= :invoice.Project__c //AND Billable__c=:true 
                AND Date_Invoiced__c>= :invoice.Start_Date__c /*AND Date_Invoiced__c<= :invoice.End_Date__c*/ AND Invoice_Request__c= :null];
        else
            timesheets = [SELECT id FROM Timesheet_Line__c WHERE Invoice_Request__c= :invoice.id];
        return timesheets;
    } 
    
    public static void copyDataFromProject(Project_Invoice__c invoice)
    {
        ProjectObject__c project = [SELECT Function_Invoice__c,LBU__c, Project_Cost__c, CurrencyIsoCode, Pricing_Model__c FROM ProjectObject__c WHERE id= :invoice.Project__c]; // Popped out  Opportunity__r.LeadSource from query for Story SSE-12329 by Priyank.
        Double projectToInvoiceConversionRate = Currency_Manager.getCurrencyConversionRate(project.CurrencyIsoCode, invoice.CurrencyIsoCode); 
        invoice.Fixed_Amount__c = (project.Project_Cost__c!=null)?(project.Project_Cost__c*projectToInvoiceConversionRate):0;
        invoice.LBU__c = (project.LBU__c!=null)?project.LBU__c:'';
        invoice.Project_Pricing_Model__c=(project.Pricing_Model__c!=null)?project.Pricing_Model__c:'';
        invoice.Function__c= project.Function_Invoice__c;       
        if(project.LBU__c!=null)
        {
            /* if(project.LBU__c.substring(0,2)=='uk')
                //invoice.SSC_Email__c = project.LBU__c.substring(0,3)+'SOE@shlgroup.com';
                invoice.SSC_Email__c = project.LBU__c.substring(0,3)+'.OAT@shlgroup.com';
            else if(project.LBU__c.substring(0,2)=='IT')
                //invoice.SSC_Email__c = 'ItalySOE@shlgroup.com';
                invoice.SSC_Email__c = 'ItalyOAT@shlgroup.com';
            else if(project.LBU__c =='US5')
                //invoice.SSC_Email__c = 'US5.SOE@shl.com';
                invoice.SSC_Email__c = 'US5.OAT@shl.com';
            else
                //invoice.SSC_Email__c = project.LBU__c.substring(0,2)+'SOE@shlgroup.com';
                invoice.SSC_Email__c = project.LBU__c.substring(0,2)+'.OAT@shlgroup.com'; */
            invoice.SSC_Email__c = project.LBU__c.substring(0,2)+'.OAT@shl.com';
        }
        else
            invoice.SSC_Email__c='';
       // invoice.Lead_Source__c= (project.Opportunity__c!=null)?project.Opportunity__r.LeadSource:'LZZ - No specified source'; // commented by Priyank for SSE-12329
    } 
    
    public static void copyDataFromProject(Project_Invoice__c invoice, ProjectObject__c project,Double projectToInvoiceConversionRate)
    {
        if(project == null)
            project = [SELECT Function_Invoice__c,LBU__c, Project_Cost__c, CurrencyIsoCode, Pricing_Model__c FROM ProjectObject__c WHERE id= :invoice.Project__c]; // Popped out  Opportunity__r.LeadSource from query for Story SSE-12329 by Priyank.
        //Double projectToInvoiceConversionRate = Currency_Manager.getCurrencyConversionRate(project.CurrencyIsoCode, invoice.CurrencyIsoCode); 
        invoice.Fixed_Amount__c = (project.Project_Cost__c!=null)?(project.Project_Cost__c*projectToInvoiceConversionRate):0;
        invoice.LBU__c = (project.LBU__c!=null)?project.LBU__c:'';
        invoice.Project_Pricing_Model__c=(project.Pricing_Model__c!=null)?project.Pricing_Model__c:'';
        invoice.Function__c= project.Function_Invoice__c;       
        if(project.LBU__c!=null)
        {
            /* if(project.LBU__c.substring(0,2)=='uk')
                //invoice.SSC_Email__c = project.LBU__c.substring(0,3)+'SOE@shlgroup.com';
                invoice.SSC_Email__c = project.LBU__c.substring(0,3)+'.OAT@shlgroup.com';
            else if(project.LBU__c.substring(0,2)=='IT')
                //invoice.SSC_Email__c = 'ItalySOE@shlgroup.com';
                invoice.SSC_Email__c = 'ItalyOAT@shlgroup.com';
            else if(project.LBU__c =='US5')
                //invoice.SSC_Email__c = 'US5.SOE@shl.com';
                invoice.SSC_Email__c = 'US5.OAT@shl.com';
            else
                //invoice.SSC_Email__c = project.LBU__c.substring(0,2)+'SOE@shlgroup.com';
                invoice.SSC_Email__c = project.LBU__c.substring(0,2)+'.OAT@shlgroup.com'; */
            invoice.SSC_Email__c = project.LBU__c.substring(0,2)+'.OAT@shl.com';
        }
        else
            invoice.SSC_Email__c='';
       // invoice.Lead_Source__c= (project.Opportunity__c!=null)?project.Opportunity__r.LeadSource:'LZZ - No specified source'; // commented by Priyank for SSE-12329
    } 
    
    public static void updateDataInInvoices(ProjectObject__c oldProject, ProjectObject__c newProject)
    {
        if(oldProject.LBU__c != newProject.LBU__c 
        || oldProject.Project_Cost__c != newProject.Project_Cost__c 
        || oldProject.Pricing_Model__c != newProject.Pricing_Model__c)
       // || oldProject.Opportunity__c != newProject.Opportunity__c  // commented by Priyank for SSE-12329
        /*|| oldProject.Functional_Area__c != newProject.Functional_Area__c)//commented by Vandita for SSE-13772*/
        {  
            Project_Invoice__c[] invoices = [SELECT Id, Project__c, CurrencyIsoCode FROM Project_Invoice__c WHERE Project__c = :newProject.Id];
            ProjectObject__c project = [SELECT Function_Invoice__c,LBU__c, Project_Cost__c, CurrencyIsoCode, Pricing_Model__c FROM ProjectObject__c WHERE id= :newProject.Id]; // Popped out  Opportunity__r.LeadSource from query for Story SSE-12329 by Priyank.
            Map<String, Double> currencyMap = new Map<String, Double>();
            for(CurrencyType currencyType: [SELECT IsoCode, ConversionRate FROM CurrencyType])
                currencyMap.put(currencyType.IsoCode, currencyType.ConversionRate);
            for(Integer i=0;i<invoices.size();i++)
            {
            Double projectToInvoiceConversionRate = currencyMap.get(invoices[i].CurrencyIsoCode)/currencyMap.get(project.CurrencyIsoCode);
                copyDataFromProject(invoices[i],project,projectToInvoiceConversionRate    );
                }
            update invoices; 
        } 
    } 
    
    WebService static Boolean processInvoice(string invoiceId, string sunOrderNo)
    {
        if(sunOrderNo!='')
        {
            Project_Invoice__c invoice = new Project_Invoice__c(id=invoiceId);
            invoice.Sun_Invoice_No__c = sunOrderNo;
            update invoice;
            return approveInvoice(invoiceId);
         }
        return false;
    }

    WebService static Boolean submitInvoice(string invoiceId)
    {
        System.debug('Inside submitInvoice');
        List<Project_Invoice__c>  projectInvoiceList = [Select id,Project__c,Project__r.Order_Products_Count__c
                                                        from Project_Invoice__c where id = :invoiceId];
        if(projectInvoiceList.size()>0 && projectInvoiceList[0].Project__r.Order_Products_Count__c==null)
            return true;
        //Create a process instance for submitting the invoice 
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setComments('Submitting invoice for processing.');
        submitRequest.setObjectId(invoiceId);
        Approval.ProcessResult processResult = Approval.process(submitRequest);
        System.debug('****processResult.isSuccess()******'+processResult.isSuccess());
        return processResult.isSuccess();       
    }
    
    WebService static Boolean approveInvoice(string invoiceId)
    {
        ProcessInstance processInstance = [Select Id FROM ProcessInstance where targetobjectId = :invoiceId AND Status=:'Pending'];
        ProcessInstanceWorkItem workItem = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstanceId = :processInstance.id];
        
        Approval.ProcessWorkitemRequest approvalRequest = new Approval.ProcessWorkitemRequest();
        approvalRequest.setComments('Processing invoice.');
        approvalRequest.setAction('Approve');
        approvalRequest.setWorkitemId(workItem.Id);
        Approval.ProcessResult processResult = Approval.process(approvalRequest);
        System.debug('****processResult.isSuccess()******'+processResult.isSuccess());
        return processResult.isSuccess();
    }
    
    WebService static Boolean rejectInvoice(string invoiceId,string reasonForRejection)
    {
        ProcessInstance processInstance = [Select Id FROM ProcessInstance where targetobjectId = :invoiceId AND Status=:'Pending'];
        ProcessInstanceWorkItem workItem = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstanceId = :processInstance.id];
        
        Approval.ProcessWorkitemRequest approvalRequest = new Approval.ProcessWorkitemRequest();
        approvalRequest.setComments((reasonForRejection!='')?reasonForRejection:'Rejecting Invoice');
      
        approvalRequest.setAction('Reject');
        approvalRequest.setWorkitemId(workItem.Id);
        Approval.ProcessResult processResult = Approval.process(approvalRequest);
        System.debug('****processResult.isSuccess()******'+processResult.isSuccess());
        return processResult.isSuccess();
    }
    
    public static void processIMLookupvalues(Project_Invoice__c invoice)
    {
        Decimal creditAmount = invoice.Credit__c?-1:1;
        if(invoice.IM1_LookupCode__c == null)
        {
            invoice.IM1_UnitPrice__c = null;
            invoice.IM1_Quantity__c = null;
            invoice.IM1_Discount__c = null;
        }
        else 
        {
            if(invoice.IM1_Quantity__c<=0)
                invoice.IM1_Quantity__c = 1;
            invoice.IM1_UnitPrice__c = signAmount(invoice.IM1_UnitPrice__c, invoice.Credit__c);
            invoice.IM1_Discount__c = signAmount(invoice.IM1_Discount__c, invoice.Credit__c);
        }
        
        if(invoice.IM2_LookupCode__c == null)
        {
            invoice.IM2_UnitPrice__c = null;
            invoice.IM2_Quantity__c = null;
            invoice.IM2_Discount__c = null;
        }
        else
        {
            if(invoice.IM2_Quantity__c<=0)
                invoice.IM2_Quantity__c = 1;
            invoice.IM2_UnitPrice__c = signAmount(invoice.IM2_UnitPrice__c, invoice.Credit__c);
            invoice.IM2_Discount__c = signAmount(invoice.IM2_Discount__c, invoice.Credit__c);   
        }
            
        if(invoice.IM3_LookupCode__c == null)
        {
            invoice.IM3_UnitPrice__c = null;
            invoice.IM3_Quantity__c = null;
            invoice.IM3_Discount__c = null;
        }
        else 
        {
            if(invoice.IM3_Quantity__c<=0)
                invoice.IM3_Quantity__c = 1;
            invoice.IM3_UnitPrice__c = signAmount(invoice.IM3_UnitPrice__c, invoice.Credit__c);
            invoice.IM3_Discount__c = signAmount(invoice.IM3_Discount__c, invoice.Credit__c);   
        }
            
        if(invoice.IM4_LookupCode__c == null)
        {
            invoice.IM4_UnitPrice__c = null;
            invoice.IM4_Quantity__c = null;
            invoice.IM4_Discount__c = null;
        }
        else 
        {
            if(invoice.IM4_Quantity__c<=0)
                invoice.IM4_Quantity__c = 1;
            invoice.IM4_UnitPrice__c = signAmount(invoice.IM4_UnitPrice__c, invoice.Credit__c);
            invoice.IM4_Discount__c = signAmount(invoice.IM4_Discount__c, invoice.Credit__c);   
        }
        
        if(invoice.IM5_LookupCode__c == null)
        {
            invoice.IM5_UnitPrice__c = null;
            invoice.IM5_Quantity__c = null;
            invoice.IM5_Discount__c = null;
        }
        else 
        {
            if(invoice.IM5_Quantity__c<=0)
                invoice.IM5_Quantity__c = 1;
            invoice.IM5_UnitPrice__c = signAmount(invoice.IM5_UnitPrice__c, invoice.Credit__c);
            invoice.IM5_Discount__c = signAmount(invoice.IM5_Discount__c, invoice.Credit__c);   
        }
    }
    
    public static void updateInvoiceTotalProductAmount(List<InvoiceProductItem__c> invoiceProductItems)
    {
        List<Project_Invoice__c> invoices = new List<Project_Invoice__c>();
        for(Id invoiceId: getInvoiceIds(invoiceProductItems))
            invoices.add(new Project_Invoice__c(Id=invoiceId, TotalAmount_Product__c=getTotalProductAmount(invoiceId)));
        if(invoices.size()>0)
            update invoices;
    }
    
    public static Set<Id> getInvoiceIds(List<InvoiceProductItem__c> invoiceProductItems)
    {
        Set<Id> invoiceIds = new Set<Id>();
        for(InvoiceProductItem__c invoiceProductItem: invoiceProductItems)
        {
            if(!invoiceIds.contains(invoiceProductItem.Invoice_Request__c))
            invoiceIds.add(invoiceProductItem.Invoice_Request__c);
        }
        return invoiceIds;
    }
    
    public static Set<Id> getInvoiceIds(List<InvoiceRevenueScheduleItem__c> invoiceRevenueScheduleItems)
    {
        Set<Id> invoiceIds = new Set<Id>();
        for(InvoiceRevenueScheduleItem__c invoiceRevenueScheduleItem: invoiceRevenueScheduleItems)
        {
            if(!invoiceIds.contains(invoiceRevenueScheduleItem.Invoice_Request__c))
            invoiceIds.add(invoiceRevenueScheduleItem.Invoice_Request__c);
        }
        return invoiceIds;
    }
            
    public static Decimal getTotalProductAmount(Id invoiceId)
    {
        Decimal totalAmount = 0;
        for(InvoiceProductItem__c invoiceProductItem: [SELECT Id, TotalAmount__c FROM InvoiceProductItem__c WHERE Invoice_Request__c =: invoiceId])
            totalAmount += invoiceProductItem.TotalAmount__c;
        return totalAmount;
    }
    //This method was bulkified by Priyank Anand on 20 Aug 2019.
    public static void signRevenueScheduleItemsOnCreditStatus(List<Project_Invoice__c> invoices)
    {
        List<id> invoiceids = new List<id> ();
        For(Project_Invoice__c invoice : invoices)
            invoiceids.add(invoice.id);
        List<InvoiceRevenueScheduleItem__c> invoiceRevenueScheduleItems = [SELECT Id, Revenue__c FROM InvoiceRevenueScheduleItem__c WHERE Invoice_Request__c in :invoiceids];
        update invoiceRevenueScheduleItems;
    } 
    
    public static void signRevenueScheduleItemsOnCreditStatus(List<InvoiceRevenueScheduleItem__c> invoiceRevenueScheduleItems)
    {
        Map<Id, Project_Invoice__c> invoiceMap = new Map<Id, Project_Invoice__c>([SELECT Id, Credit__c FROM Project_Invoice__c WHERE Id IN: getInvoiceIds(invoiceRevenueScheduleItems)]);
        for(InvoiceRevenueScheduleItem__c invoiceRevenueScheduleItem: invoiceRevenueScheduleItems)
        {
            Boolean invoiceCredit = invoiceMap.get(invoiceRevenueScheduleItem.Invoice_Request__c).Credit__c;
            invoiceRevenueScheduleItem.Revenue__c = signAmount(invoiceRevenueScheduleItem.Revenue__c, invoiceCredit);
        }
    }
    
    //This method was bulkified by Priyank Anand on 20 Aug 2019.    
    public static void signProductItemsOnCreditStatus(List<Project_Invoice__c> invoices)
    {
        List<id> invoiceids = new List<id>();
        For(Project_Invoice__c invoice : invoices)
            invoiceids.add(invoice.id);
        List<InvoiceProductItem__c> invoiceProductItems = [SELECT Id, UnitPrice__c, Discount__c FROM InvoiceProductItem__c WHERE Invoice_Request__c in :invoiceids];
        update invoiceProductItems;
    } 
    
    public static void signProductItemsOnCreditStatus(List<InvoiceProductItem__c> invoiceProductItems)
    {
        Map<Id, Project_Invoice__c> invoiceMap = new Map<Id, Project_Invoice__c>([SELECT Id, Credit__c FROM Project_Invoice__c WHERE Id IN: getInvoiceIds(invoiceProductItems)]);
        for(InvoiceProductItem__c invoiceProductItem: invoiceProductItems)
        {
            Boolean invoiceCredit = invoiceMap.get(invoiceProductItem.Invoice_Request__c).Credit__c;
            invoiceProductItem.UnitPrice__c = signAmount(invoiceProductItem.UnitPrice__c, invoiceCredit);
            invoiceProductItem.Discount__c = signAmount(invoiceProductItem.Discount__c, invoiceCredit);
        }
    }
        
    private static Decimal signAmount(Decimal amount, Boolean isCredit)
    {
        if((isCredit && amount>0) || (!isCredit && amount<0))
            amount *= -1;
        return amount;
    }
    //This Method is added by Vandita Kakkar to include validations for Submit for Approval
    public static void validationsonSubmitforApproval(List<Project_Invoice__c> newInvoice, List<Project_Invoice__c> oldInvoice){
        List<Id> ProjectIds = new List<Id>();
        
        Group gp = [Select id,Name,(Select id,UserOrGroupId from GroupMembers) from Group where Name ='Invoice Request Submitters'];
        GroupMember[] groupmembers = gp.GroupMembers;
        Set<String> gmids = new Set<String>();
        for(GroupMember gm:groupmembers){
            gmids.add(gm.UserOrGroupId);
        }
        for(Integer i=0;i<newInvoice.size();i++){
            ProjectIds.add(newInvoice[i].Project__c);
            
            Map<Id,ProjectObject__c> Projectmap = new Map<Id,ProjectObject__c>([Select Id,Order_Products_Count__c,Project_Manager__c,Project_Co_ordinator__c,CurrencyIsoCode,Order__r.CurrencyIsoCode,Order__c,Order_Header_Number__c from ProjectObject__c where id IN:ProjectIds]);
            for(Project_Invoice__c InvoiceRequest : newInvoice)
            {
                if(newInvoice[i].Status__c != oldInvoice[i].Status__c && newInvoice[i].Status__c == 'Submitted For Processing')
                {
                    if(((UserInfo.getUserId())!= Projectmap.get(newInvoice[i].Project__c).Project_Manager__c && UserInfo.getUserId()!= Projectmap.get(newInvoice[i].Project__c).Project_Co_ordinator__c) && !gmids.contains(Userinfo.getUserId())){
                        newInvoice[i].addError('You are not allowed to submit this invoice for processing as you are not the PM/PC of the project or a member of Invoice Request Submitters group');
                    }
                    if(Projectmap.get(InvoiceRequest.Project__c).Order_Products_Count__c == null)
                    {
                        InvoiceRequest.addError('You are not allowed to submit this invoice for processing because its related project does not have order product linked to.');
                    }
                    if(Projectmap.get(InvoiceRequest.Project__c).CurrencyIsoCode != InvoiceRequest.CurrencyIsoCode)
                    {
                        InvoiceRequest.addError('Invoice Request currency must be same as related Project currency.');
                    }
                    if(InvoiceRequest.Project__r.Order_Header_Number__r.CurrencyIsoCode!=null && InvoiceRequest.Project__r.Order_Header_Number__r.CurrencyIsoCode != InvoiceRequest.Project__r.CurrencyIsoCode)
                    {
                     InvoiceRequest.addError('An invoice request can not be submitted if the currency of the related project and contract are not same.');
                    }
                    if(InvoiceRequest.InvoicingTotal__c ==0)
                    {
                        InvoiceRequest.addError('Invoice with 0.00 invoicing total can not be submitted for processing.');
                    }
                }
            }
        }
    }
       //Method to validate before processing IR
       public static void validationsonProcessIR(List<Project_Invoice__c> newInvoice, List<Project_Invoice__c> oldInvoice)
       {
           List<GroupMember> GP = [Select Id from GroupMember g where ( g.Group.Name='SSC' OR g.Group.Name='OAT') and g.UserOrGroupId=: userinfo.getuserid()];
           for(Integer i = 0;i<newInvoice.size();i++)
           {
                if(newInvoice[i].Status__c!= oldInvoice[i].Status__c && newInvoice[i].Status__c == 'Processed')
                {
                    if(GP.size()>0)
                    {
                       
                        if(oldInvoice[i].Status__c == 'Processed'){
                           newInvoice[i].addError('Sorry! This invoice has already been processed');
                        }
                        
                        else if(oldInvoice[i].Status__c == 'In Progress'){
                           newInvoice[i].addError('Sorry! This invoice has not been yet submitted for processing.');
                        }
                       
                        else if(newInvoice[i].Sun_Invoice_No__c == ' '){
                           newInvoice[i].addError('Please enter the SUN Order No. in order to process this invoice request');
                        }
                       
                   }
                    else{
                        newInvoice[i].addError('Sorry! The invoice request could not be processed as your not part of OAT/SSC group.');  
                    }
               }
               
           }
       }
       //Method to validate before rejecting IR
       public static void validationsonRejectingIR(List<Project_Invoice__c> newInvoice, List<Project_Invoice__c> oldInvoice)
       {
           List<GroupMember> GP = [Select Id from GroupMember g where ( g.Group.Name='SSC' OR g.Group.Name='OAT') and g.UserOrGroupId=: userinfo.getuserid()];
           for(Integer i = 0;i<newInvoice.size();i++)
           {
               if(newInvoice[i].Status__c!= oldInvoice[i].Status__c && newInvoice[i].Status__c == 'In Progress')
                   {
                       if(GP.size()>0)
                       {
                            if(oldInvoice[i].Status__c == 'Processed'){
                               newInvoice[i].addError('Sorry! This invoice has already been processed');
                            }
                            
                            else if(oldInvoice[i].Status__c == 'In Progress'){
                               newInvoice[i].addError('Sorry! This invoice has not been yet submitted for processing.');
                            }
                                               
                       }
                        else{
                            newInvoice[i].addError('Sorry! The invoice request could not be rejected as your not part of OAT/SSC group.');  
                       }
               }
               
           }
       }

}
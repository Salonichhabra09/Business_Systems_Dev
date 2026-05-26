@isTest(seeAllData = true)
@TestVisible
public class ProjectInvoiceTriggerManagerTester {
    
    static testMethod void testBasicMethods()
    {
        
        List<ProjectObject__c> projects= insertProjects();
        List<Project_Invoice__c> invoices;
        List<Project_Invoice__c> ToBeDeletedInvoices = new List<Project_Invoice__c>();
        //invoices= insertInvoices(projects[0].id);
        id projectId = projects[0].id;
        List<SelectOption> IMCodes = new List<SelectOption>();
        for(PicklistEntry entry: Project_Invoice__c.IM1_LookupCode__c.getDescribe().getPicklistValues())
            IMCodes.add(new SelectOption(entry.getValue(),entry.getValue()));
        system.debug('Invoice: Insert Started');
        if(projectId==null)
            projectId = [SELECT Id from ProjectObject__c where CurrencyISOCode = 'GBP' and Order_Header_Number__r.CurrencyISOCode ='GBP' LIMIT 1].Id;  
        Account ActId =[Select id from Account where Business_Relationship__c='New Logo (Never Traded)' limit 1];
        Contact contact = [SELECT Id,AccountId from Contact where AccountId=:ActId.Id LIMIT 1]; 
        invoices = new List<Project_Invoice__c>();
        for(Integer i=0;i<1;i++)
        {
            Project_Invoice__c invoice2 = new Project_Invoice__c();
            invoice2.Project__c = projectId;
            invoice2.Start_Date__c = Date.newInstance(2008,2,2);
            invoice2.End_Date__c = Date.newInstance(2008,5,5);
            invoice2.IM1_LookupCode__c = IMCodes[0].getValue(); 
            invoice2.IM1_Quantity__c = 1; 
            invoice2.IM1_UnitPrice__c = 500; 
            invoice2.CurrencyISOCode = 'GBP';
            invoice2.Credit__c=false;
            invoice2.Account__c=ActId.Id;
            invoice2.Contact_Name__c=contact.id;
            invoices.add(invoice2);
        }
        
        insert invoices;
        
        //invoices2=insertInvoices(projects[0].id);
        //updateInvoices(invoices); 
        Account acc=CreateTestData.GetAccount();
        Contact con=CreateTestData.getContact(acc.id);
        //List<Project_Invoice__c> tempinovices = new List<Project_Invoice__c>();
        for(Project_Invoice__c insertedInvoice: invoices)
        {
            
            //Project_Invoice__c invoice1 = new Project_Invoice__c(id=insertedInvoice.id);
           insertedInvoice.Start_Date__c = Date.today();
            insertedInvoice.Credit__c=true;
            insertedInvoice.Credit_Note_Reason_code__c='SO1 Goods returned';
            insertedInvoice.Account__c=acc.id;
            insertedInvoice.Contact_Name__c=con.id;
            insertedInvoice.End_Date__c=Date.today();
            insertedInvoice.CurrencyIsoCode='GBP';
            //tempinovices.add(invoice1);

        }
        //invoices.addall(tempinovices);
        invoices[0].Sun_Invoice_No__c='1234';
        //invoices[0].Status__c = 'Processed';
        test.startTest();
        update invoices;
       
        List<Project_Invoice__c> invoices2 = [select id from Project_Invoice__c where Status__c='In Progress' limit 1 ];
        //testSpecialMethods(invoices[0].id);
        Project_Invoice__c invoice= invoices[0];
        id invoiceid=invoices[0].id;
        system.debug('Invoice: Submit Started');
        ProjectInvoice_Manager.submitInvoice(invoiceid);
        system.debug('Invoice: Submit Completed');
       
        system.debug('Invoice: Reject Started');
        //ProjectInvoice_Manager.rejectInvoice(invoiceid, 'rejected');
        system.debug('Invoice: Reject Completed');
       
        system.debug('Invoice: ReSubmit Started');
        ProjectInvoice_Manager.submitInvoice(invoiceid);
        system.debug('Invoice: ReSubmit Completed');
        
        system.debug('Invoice: Approve Started');
        //ProjectInvoice_Manager.processInvoice(invoiceid, '2332');
        system.debug('Invoice: Approve Completed');

        
        
        //insertInvoiceProductItems(invoices[0]);
        List<InvoiceProductItem__c> items = new List<InvoiceProductItem__c>();
        for(Integer i=0;i<1;i++)
        {
            InvoiceProductItem__c item = new InvoiceProductItem__c();
            item.Invoice_Request__c = invoice.Id;
            item.Product_IM_Code__c = 'AB0123456789' + i;
            item.Quantity__c = 1;
            item.UnitPrice__c = 100;
            item.Discount__c = 10;
            items.add(item);
        }
        
        insert items;
        
         for(InvoiceProductItem__c insertedItem: items)
            insertedItem.UnitPrice__c += 10;
        update items;
       
        //insertInvoiceRevenueScheduleItems(invoices[0]);
        List<InvoiceRevenueScheduleItem__c> Revenueitems = new List<InvoiceRevenueScheduleItem__c>();
        for(Integer i=0;i<1;i++)
        {
            InvoiceRevenueScheduleItem__c item = new InvoiceRevenueScheduleItem__c();
            item.Invoice_Request__c = invoice.Id;
            item.IM_LookupCode_Reference__c = 'IM1';
            item.Month__c = Date.today().addMonths(i);
            item.Revenue__c = 1;
            Revenueitems.add(item);
        }
        
        insert Revenueitems;
        
        for(InvoiceRevenueScheduleItem__c insertedItem: Revenueitems)
            insertedItem.Revenue__c += 1;
        update Revenueitems;
        
        ProjectInvoice_Manager.getExpensesRelatedToInvoice(invoices[0]);
        ProjectInvoice_Manager.getTimesheetsRelatedToInvoice(invoices[0]);
        //deleteInvoices(invoices2);
        delete invoices2;
        test.stopTest();
    }
    
    static testMethod List<ProjectObject__c> insertProjects()
     {
        Account ActId =CreateTestData.GetAccount1();
        Contact contact = CreateTestData.getContact(ActId.Id); 
        User usrRec = [Select id,Company_BU__c from User where IsActive =True and Company_BU__c !=null and Is_Project_Manager__c = true limit 1];  
        List<String> lbuList = usrRec.Company_BU__c.split('-');
        Opportunity opp=[select id from opportunity where stagename='New' limit 1];
        List<ProjectObject__c> projects = new List<ProjectObject__c>();
            Account account = [SELECT Id,CurrencyIsoCode from Account where id=:contact.AccountId];
            Contract contract =[Select id,CurrencyIsoCode from Contract where CurrencyIsoCode =:account.CurrencyIsoCode limit 1];
            Contract_Line__c contractLine = new Contract_Line__c();
            contractLine.Contract__c = contract.Id;
            contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
            contractLine.IM_Lookup_Code__c = 'Consulting';
            contractLine.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
            contractLine.PO_number__c = '12312323423';
            //contractLine.Price__c = 5000;
            contractLine.Order_Method__c='T&E';
            contractLine.Invoicing_Schedule__c = 'Special Invoicing Instructions';
            contractLine.Proposition__c='Graduate Hiring';
            contractLine.Package__c='Graduate Essential';
            insert contractLine;
            list<Project_Deliverables__c> listPD = new list<Project_Deliverables__c>();
            list<ProjectObject__c> listproject = new list<ProjectObject__c> ();
         for(Integer i=0;i<1;i++)
        {
            ProjectObject__c project = new ProjectObject__c();
            project.Project_Name__c = 'project_' + i;
            project.Account__c = contact.AccountId;
            project.Contact__c = contact.Id;
            project.Billing_Contact__c = contact.Id;
            project.Opportunity__c = opp.id;
           project.Project_Manager__c =usrRec.id;
            project.LBU__c = lbuList[1].trim();
            project.CurrencyIsoCode = account.CurrencyIsoCode;
            project.Functional_Area__c = 'Consulting & Training';
            project.Order_Header_Number__c = contract.id;
            //project.Order_Line_Number__c = contractLine.id;//Modified by prabhat on 6Aug'19
            project.Total_Actual_Time__c=1;
            project.Scoped_Hours_Effort__c=1;
            project.Additional_Scoped_Days__c = 1;
            project.Current_Scoped_Days_Effort__c = 1;
            project.additional_scoped_comments__c = 'test Comments';
            project.Chargeable__c = 'test';
            project.Reason__c = 'test';
             listproject.add(project);
        }
      
        insert listproject;
        for(ProjectObject__c proj:listproject )
        {
           ProjectObject__c proj1 =new ProjectObject__c (id=proj.id);
          proj1.Order_Line_Number__c = contractLine.id;
          projects.add(proj1);
           
            Project_Deliverables__c objPD = new Project_Deliverables__c();
        objPD.PS_Offering__c = 'Outsourced Assessment';
        objPD.Project__c=proj1.id;
        objPD.Number__c=10;
        objPD.Deal_Type__c='Assessment for Selection';
        objPD.Complexity__c= 'Tailored';
        objPD.Additional_Comments__c= 'Test Comments';
        listPD.add(objPD);
        }
          insert listPD;
        update projects;
        return projects;
     }
    
  
}
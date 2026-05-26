//Author:Vimal Singh
//CreatedDate: 30/12/2013
//Purpose: Providing an utility Class which inserts test data for the test methods.

@IsTest(SeeAllData=True)
Public Class CreateTestData{

public static User GetAdminUser(){
            Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='System Administrator' limit 1];
            User usr = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
            return usr;
            }
public static Account GetAccount(){
            Datetime variable=System.now();
            String Testname='Test Account'+variable;
            Account account=new Account(name=Testname,Status__c='Approved',Business_Defined_Attribute__c='Fortune 500',
                                        Billing_Address_Line_1__c='test',Billing_City__c='Test City',CurrencyIsoCode='GBP',
                                        Billing_Country__c='India',Billing_State__c='Test',Industry= 'Agriculture',
                                        Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
            insert account;
            return account;
     }
public static Account GetAccount1(){            
            Account account=new Account(name='ADP',Status__c='Live',Billing_Address_Line_1__c='test',Industry= 'Agriculture',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
            insert account;
            return account;
     }


public Static Lead getLead(){
        Lead tLead = new Lead();
        tLead.Lastname= 'testLead';
        tLead.LeadSource = 'Partner';
        tLead.company= 'test company';
        tLead.Status = 'New';
        tLead.Email = 'test@test.com';
        tLead.Lead_Country__c = 'India';
        //tLead.Same_as_contact_address__c = true;
        
        insert tLead;
        return tLead;
 }

public Static Contact getContact(Id AccountId){
            
            Contact contact=new Contact(lastname='Test Contact',
                                        AccountId=AccountId);
             contact.Same_As_The_Account_Billing_Address__c=true;
             contact.Mailing_Address_Line_1__c ='test'; 
             contact.Mailing_City__c='test';
             contact.Mailing_ZIP_Postal_Code__c ='110094';        
             contact.Mailing_Country__c='INDIA';
             contact.Area_of_Interest__c ='Training';
             contact.Title = 'Test Data';
            insert contact;
            return contact;
 }   
    
public Static India_GST__c getIndiaGST(Id AccountId){
            
            India_GST__c IndiaGst=new India_GST__c(name='07TESTOTESTB123',Account__c=AccountId);IndiaGst.Address_Line_1__c='Ground Floor, Corporate One';IndiaGst.City__c ='New Delhi'; IndiaGst.Country__c='India';IndiaGst.State_County__c ='Delhi';IndiaGst.State_Code__c ='07';IndiaGst.ZIP_Postal_Code__c='110076';IndiaGst.Taxpayer_Type__c='EXPWOP';
            insert IndiaGst;
            return IndiaGst;
 }    
public Static Contract getContract(Id Accountid,Id OpportunityId){
            
            Contract contract = new Contract(Agreement__c='Order',Subscription_Start_Date__c=date.today(),Accountid=Accountid,ContractTerm=12,Status='Draft',StartDate=date.today(),Contract_Type__c='Consulting',Opportunity__c=Opportunityid);
            insert contract;    
            return contract;
}
public Static Order getOrder(Account account,Id ContractId){
            
            Order order = new Order(Contractid=ContractId,Accountid=account.id,Status='Draft',CurrencyIsoCode=account.CurrencyIsoCode,EffectiveDate=date.today());
            insert order;    
            return order;
}
public Static Opportunity getOpportunity(Id AccountId, Id BillingContactId){
            Opportunity opportunity= new Opportunity(OwnerId=UserInfo.getUserId(),AccountId=AccountId,Billing_Contact__c=BillingContactId,
                                                     Primary_Contact__c=BillingContactId,name='Test Opportunity',NVM_Credit_Card_ID__c='',Amount=1000,
                                                     Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName='New',closeDate=System.today(),
                                                     Order_number__c=NULL,Forecast_Category__c='Commit',Business_Type__c='Expansion');
            insert opportunity;
            return opportunity;
 }
 
public Static Pricebook2 getPricebook2(){
            Pricebook2 Pricebook2=new Pricebook2();Pricebook2.Description='Test Description';Pricebook2.IsActive=True;Pricebook2.Name='Test Pricebook';
            Insert Pricebook2;
            return Pricebook2;
     }
 
public Static ProjectObject__c getProject(Id AccountId, Id OpportunityId){
            ProjectObject__c project = new ProjectObject__c();Project.Project_Manager__c='00520000000ihf6';Project.Project_Name__c='Test Project';Project.Account__c=AccountId;Project.Opportunity__c=OpportunityId;Project.Project_Status__c='Pending';Project.Project_Type__c='Consulting and outsourced assessments';Project.LBU__c='AU1';
            insert project;
            return project; 
 
 }
 
 public Static Project_Invoice__c getProjectInvoice(Id ProjectId){
    Project_Invoice__c invoice= new Project_Invoice__c();invoice.Project__c = ProjectId;invoice.Start_Date__c = Date.newInstance(2008,2,2);invoice.End_Date__c = Date.newInstance(2008,5,5);invoice.IM1_Quantity__c = 1;invoice.IM1_UnitPrice__c = 500;invoice.CurrencyISOCode = 'GBP';invoice.Unapproved_Time_Amount__c =100;invoice.Approved_Time_Amount__c =200;
                   
    insert invoice ;
           return invoice ; 
 
 }
  public Static ProjectObject__c getCPSProject(Id parentproject){
     string  cpsprojectrecordid = Schema.SObjectType.ProjectObject__c.getRecordTypeInfosByName().get('CPS Project').getRecordTypeId();
            ProjectObject__c project = new ProjectObject__c();Project.Project_Name__c='Test CPS Project';Project.Project_Status__c='Initiation';Project.Signed_SoW__c='Yes'; Project.Agreed_Delivery_Target__c= System.today(); Project.RecordTypeId = cpsprojectrecordid; Project.PS_Project_Number__c = parentproject;Project.SD_C_Lead__c=UserInfo.getUserId();Project.Local_PS_Lead__c=UserInfo.getUserId();Project.Technology_Lead__c='Edward Butler';
            insert project;
            return project; 
 
 }
 
public Static Product2 getProduct2(){
             Product2 Product2=New Product2();Product2.Description='Test Description'; Product2.IsActive=True; Product2.Name='Test Product';
             Insert Product2;
             return Product2;

}
public Static PricebookEntry  getPricebookEntry(ID Product2Id,String PBECurrency){

            Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
            PricebookEntry PBE=new PricebookEntry();PBE.CurrencyIsoCode=PBECurrency; PBE.IsActive=True;PBE.Pricebook2Id=standard.id; PBE.Product2Id=Product2Id;PBE.UnitPrice=1;
            Insert PBE;
            return PBE;
 
 }
Public Static Attachment getAttachment(Id ParentId){
            
            Attachment attachment=new Attachment(Name='Test PDF', OwnerID=UserInfo.getUserId(), ParentId=ParentId,Body=Blob.toPdf('Test Body'), ContentType='application/pdf');
            insert Attachment;
            return Attachment;

}

Public Static OpportunityLineItem getOpportunityLineItem(Id OpportunityId,Id PricebookEntryId){
            OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=OpportunityId,PricebookEntryId=PricebookEntryId,TotalPrice=0,Quantity=1);
            insert LI;
            return LI;

}
Public Static Expense__c getExpense(Id ProjectID){
            Expense__c Expense=new Expense__c(Project__c=ProjectID,Date_Incurred__c=Date.newInstance(2012,2,2),Rechargeable__c=true,Status__c='Approved',Value__c=1);
            insert Expense;
            return Expense;

}

Public Static Contract_Line__c getOrderLine(ID ContractID){
Contract_Line__c CL=new Contract_Line__c (Contract__c=ContractId,CurrencyIsoCode='GBP', Start_date__c=System.today(), End_date__c=System.today()+5, Order_Method__c='SOE',IM_Lookup_Code__c='Consulting',Source_of_PS_Scoping__c='E2E Scoping Tool',Price__c=10,Proposition__c='Graduate Hiring',Package__c='Graduate Essential');
insert CL;
return CL;
}

Public Static Order getorder(ID Contractid,ID AccountID){
Order order= New Order(AccountID=AccountID,ContractID=Contractid,CurrencyIsoCode='GBP',Status='Draft',EffectiveDate=Date.Today(),Pricebook2Id = '01s2000000000vQAAQ');
insert order;
return order;

}  
}
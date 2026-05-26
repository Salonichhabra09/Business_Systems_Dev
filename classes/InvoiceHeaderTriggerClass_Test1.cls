@isTest
public class InvoiceHeaderTriggerClass_Test1 {
    
    @testSetup
    static void setupData() {
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(valueFV, 'Credit Note IM Codes');
        INSERT fVS;
        
        insert new Trigger_Activation__c(Name = 'ProjectInvoice_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'InvoiceHeader_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Account_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Contact_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Project_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Order_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Opportunity_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'OpportunityContactRoleTrigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'Contract_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'ContractInvoiceLine_Trigger', Active__c = true);
        insert new Trigger_Activation__c(Name = 'User_Trigger', Active__c = true);
        
        AutomaticJobCreation__c autoJobSettings = new AutomaticJobCreation__c(
            Name = 'Values',
            MS_Line_of_Business__c = 'Consulting,Delivery,Support'
        );
        insert autoJobSettings;
        
        Account acc = TestDataUtility.getAccount();
        insert acc;
        
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@example.com',
            AccountId = acc.Id
        );
        insert contact;
        
        ProjectObject__c project = new ProjectObject__c();
        project.Project_Name__c = 'Test project';
        project.Account__c = acc.id;
        project.Contact__c = contact.Id;
        project.Billing_Contact__c = contact.Id;
        project.LBU__c = 'UK1';
        project.Functional_Area__c = 'PS Consulting';
        project.Order_Products_Count__c = 2;
        insert project;
        
        List<Project_Invoice__c> pirList = new List<Project_Invoice__c>{
            new Project_Invoice__c(Status__c = 'Processed', Credit__c=false,Account__c = acc.Id,Project__c = project.Id,Contact_Name__c = contact.Id,Sun_Invoice_No__c ='SO123',Credit_Note_Reason_code__c='NA'),
                new Project_Invoice__c(Status__c = 'Submitted for Processing', Credit__c=true,Account__c = acc.Id,Project__c = project.Id,Contact_Name__c = contact.Id,Sun_Invoice_No__c ='SO123',Credit_Note_Reason_code__c='NA')
                };
                    insert pirList;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(acc.id, contact.id);
        INSERT opportunityRecord;
        
        // Should create Opp Line Items
        
        Contract contractRecord = TestDataUtility.getContract(acc.id, opportunityRecord.id);
        contractRecord.Subscription_Start_Date__c = date.today();
        contractRecord.Contract_End_Date__c = date.today()+365;
        contractRecord.AccountId = acc.id;
        INSERT contractRecord; 
        
        Order orderRecord = TestDataUtility.getOrder(contractRecord.id, acc.id);
        orderRecord.Booked_Elsewhere__c = False;
        orderRecord.EffectiveDate = date.today();
        orderRecord.Submission_Offset__c = -18000000;
        orderRecord.Activation_Offset__c = -18000000;
        orderRecord.opportunityId = opportunityRecord.Id;
        INSERT orderRecord;
        
        // Create a Contract Invoice Header
        List<Contract_Invoice_Header__c> headerList = new List<Contract_Invoice_Header__c>();
        Contract_Invoice_Header__c header = new Contract_Invoice_Header__c(
            Invoice_status__c = 'Draft',
            SunSystems_Order_Reference__c = 'SO123',
            Invoice_Request__c = pirList[1].Id,
            Credit_Note__c = false,
            Account__c = acc.Id,
            Order__c = orderRecord.Id,
            BU__c = 'India - IN1'
        );
        Contract_Invoice_Header__c header1 = new Contract_Invoice_Header__c(
            Invoice_status__c = 'Draft',
            SunSystems_Order_Reference__c = '',
            Invoice_Request__c = pirList[0].Id,
            Credit_Note__c = false,
            Account__c = acc.Id,
            Order__c = orderRecord.Id,
            BU__c = 'India - IN1'
        );
        headerList.add(header);
        headerList.add(header1);
        insert headerList;
        
        // Add Invoice Line
        Contract_Invoice_Line__c invLine = new Contract_Invoice_Line__c(
            //Name = 'Line 1',
            Invoice_Header_ID__c = header.Id,
            SUN_IM_lookup_code__c = 'Multiple Options Available' // Triggers addError logic
        );
        //insert invLine;
    }
    
    @isTest
    static void testUpdateRecentValuesonInvRequest() {
        List<Project_Invoice__c> pirList = [SELECT Id FROM Project_Invoice__c];
        Set<Id> invReqIds = new Set<Id>();
        for(Project_Invoice__c pr : pirList){
            invReqIds.add(pr.Id);
        }
        invoiceHeaderTriggerClass.updateRecentValuesonInvRequest(invReqIds);
    }
    
    @isTest
    static void testUpdateSunInvoiceDates() {
        Contract_Invoice_Header__c header = [SELECT Id, Name FROM Contract_Invoice_Header__c LIMIT 1];
        header.Sun_Invoice_Date__c = '09/02/2025';
        header.Sun_Payment_Due_Date__c = '09/03/2025';
        
        update header;
    }
    
    @isTest
    static void testInvoiceDelete(){
        Contract_Invoice_Header__c header = [SELECT Id, Name FROM Contract_Invoice_Header__c LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator Password Immune' LIMIT 1];
        
        User user = new User(
            Alias = 'stduser',
            Email='stduser@test.com',
            Username='stduser@test.com.myorg',
            ProfileId = p.Id,
            LastName='Test',
            TimeZoneSidKey='Asia/Kolkata',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        insert user;
        
        System.runAs(user) {             
            Delete header;
        }
    }
}
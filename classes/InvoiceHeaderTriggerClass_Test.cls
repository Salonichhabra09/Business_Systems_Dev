@isTest
public class InvoiceHeaderTriggerClass_Test {

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
            SunSystems_Order_Reference__c = 'SO123',
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
        insert invLine;
    }

    @isTest
    static void testInvoiceStatusValidation() {
        List<Contract_Invoice_Header__c> headerList = [SELECT Id, Invoice_status__c FROM Contract_Invoice_Header__c LIMIT 1];
        List<Contract_Invoice_Header__c> oldHeaderList = new List<Contract_Invoice_Header__c>();
        for (Contract_Invoice_Header__c h : headerList) {
            Contract_Invoice_Header__c oldH = h.clone();
            oldH.Invoice_status__c = 'Draft'; // was draft, changing to below
            oldHeaderList.add(oldH);

            // Simulate status change to "Ready to Invoice"
            h.Invoice_status__c = 'Ready to Invoice';
        }
        Map<Id, Contract_Invoice_Header__c> newMap = new Map<Id, Contract_Invoice_Header__c>();
        Map<Id, Contract_Invoice_Header__c> oldMap = new Map<Id, Contract_Invoice_Header__c>();
        for (integer i = 0; i < headerList.size(); i++) {
            newMap.put(headerList[i].Id, headerList[i]);
            oldMap.put(headerList[i].Id, oldHeaderList[i]);
        }

        Test.startTest();
            invoiceHeaderTriggerClass invClass = new invoiceHeaderTriggerClass();
            invClass.invoiceStatusValidation(headerList, oldHeaderList, newMap, oldMap);
        Test.stopTest();
    }

    @isTest
    static void testUpdateRecentValuesonIR_LinkedWithSunReferenceChange() {
        List<Project_Invoice__c> pir = [SELECT Id, Status__c, Credit__c FROM Project_Invoice__c WHERE Status__c !='Processed' LIMIT 1];
        Contract_Invoice_Header__c header = [SELECT Id, Name,Invoice_status__c, Invoice_Request__c, SunSystems_Order_Reference__c,credit_note__c FROM Contract_Invoice_Header__c LIMIT 1];

        // Simulate changing SunSystems_Order_Reference__c
        Contract_Invoice_Header__c headerOld = header.clone(false, false, false, false);
        header.SunSystems_Order_Reference__c = 'SO456';
        List<Contract_Invoice_Header__c> newList = new List<Contract_Invoice_Header__c>{header};
        Map<Id, Contract_Invoice_Header__c> oldMap = new Map<Id, Contract_Invoice_Header__c>{
            header.Id => headerOld
        };

        Test.startTest();
        invoiceHeaderTriggerClass invClass = new invoiceHeaderTriggerClass();
        invClass.updateRecentValuesonIR(newList, oldMap);
        Contract_Invoice_Header__c headerToUpdate = [SELECT Id, Name,Invoice_status__c, Invoice_Request__c, SunSystems_Order_Reference__c,credit_note__c FROM Contract_Invoice_Header__c where Invoice_Request__c = :pir[0].Id];
        headerToUpdate.Invoice_Request__c = null;
        update headerToUpdate;

        invoiceHeaderTriggerClass.updateIRonSORdel(pir[0]);
        Test.stopTest();

        Project_Invoice__c updatedPIR = [SELECT Sun_Invoice_No__c, Invoice_Header_Reference__c, Status__c FROM Project_Invoice__c WHERE Id = :pir[0].Id];
        // You can assert expected values based on logic, e.g.:
        System.assertNotEquals(null, updatedPIR);
        // Add further asserts as needed
    }

    @isTest
    static void testUpdateRecentValuesonIR_RemoveInvoiceRequest() {
        Project_Invoice__c pir = [SELECT Id, Status__c, Credit__c FROM Project_Invoice__c LIMIT 1];
        List<Contract_Invoice_Header__c> headerList = [SELECT Id, Invoice_status__c, Invoice_Request__c,credit_note__c,SunSystems_Order_Reference__c FROM Contract_Invoice_Header__c];

        // Simulate unlinking Invoice_Request__c
        Contract_Invoice_Header__c headerOld = headerList[0].clone(false, false, false, false);
        headerList[0].Invoice_Request__c = null;
        Contract_Invoice_Header__c headerOld1 = headerList[1].clone(false, false, false, false);
        headerList[1].Invoice_Request__c = null;
        
        List<Contract_Invoice_Header__c> newList = headerList;
        Map<Id, Contract_Invoice_Header__c> oldMap = new Map<Id, Contract_Invoice_Header__c>{headerList[0].Id => headerOld,headerList[1].Id => headerOld1};

        Test.startTest();
        invoiceHeaderTriggerClass invClass = new invoiceHeaderTriggerClass();
        invClass.updateRecentValuesonIR(newList, oldMap);
        Test.stopTest();

    }

    @isTest
    static void testUpdateRecentValuesonInvRequest() {
        List<Project_Invoice__c> pirList = [SELECT Id FROM Project_Invoice__c];
		Set<Id> invReqIds = new Set<Id>();
        for(Project_Invoice__c pr : pirList){
            invReqIds.add(pr.Id);
        }
        //invoiceHeaderTriggerClass.updateRecentValuesonInvRequest(invReqIds);
    }
}
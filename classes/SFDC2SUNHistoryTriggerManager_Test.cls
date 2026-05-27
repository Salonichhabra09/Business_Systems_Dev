@isTest
public class SFDC2SUNHistoryTriggerManager_Test {

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
        insert new Trigger_Activation__c(Name = 'SFDC2SUN_History_Trigger', Active__c = true);
        
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
            Credit_Note__c = false,
            Invoice_Account__c = acc.Id,
            Order__c = orderRecord.Id,
            BU__c = 'India - IN1',
            Invoice_Gross_Amount__c = 200,
            Payment_Due_Date__c = date.today() - 50
        );
         Contract_Invoice_Header__c header1 = new Contract_Invoice_Header__c(
            Invoice_status__c = 'Draft',
            SunSystems_Order_Reference__c = 'SO123',
            Credit_Note__c = false,
            Invoice_Account__c = acc.Id,
            Order__c = orderRecord.Id,
            BU__c = 'India - IN1',
            Invoice_Gross_Amount__c = 200,
            Payment_Due_Date__c = date.today() - 90
        );
        headerList.add(header);
        headerList.add(header1);
        insert headerList;
    }
    
    @isTest
    static void testTransactionDetails() {
        Contract_Invoice_Header__c invoiceHeader = [SELECT Id FROM Contract_Invoice_Header__c LIMIT 1];
        List<SFDC2Sun_Transfer_or_Sync_History__c> transactionRecords = new List<SFDC2Sun_Transfer_or_Sync_History__c>();  
        SFDC2Sun_Transfer_or_Sync_History__c debitTransactionRecord = new SFDC2Sun_Transfer_or_Sync_History__c();
        SFDC2Sun_Transfer_or_Sync_History__c creditTransactionRecord = new SFDC2Sun_Transfer_or_Sync_History__c();
        
        debitTransactionRecord.Invoice_Header__c = invoiceHeader.Id;
        debitTransactionRecord.Is_Transaction__c = true;
        debitTransactionRecord.Transaction_Amount__c = 200;
        debitTransactionRecord.Transaction_Type__c = 'Debit';
		debitTransactionRecord.Transaction_Date_String__c = '02/02/2025';
        
        creditTransactionRecord.Invoice_Header__c = invoiceHeader.Id;
        creditTransactionRecord.Is_Transaction__c = true;
        creditTransactionRecord.Transaction_Amount__c = 200;
        creditTransactionRecord.Transaction_Type__c = 'Debit';
        creditTransactionRecord.Transaction_Date_String__c = '02/02/2025';
        
        transactionRecords.add(debitTransactionRecord);
        transactionRecords.add(creditTransactionRecord);
        
        Insert transactionRecords;
        
        Delete transactionRecords[0];
    }

}
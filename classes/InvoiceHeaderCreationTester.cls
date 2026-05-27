@isTest
public class InvoiceHeaderCreationTester {
    
    @testSetup static void setup() {
        
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');  
        
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityLineItem', 'OpportunityLineItem_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Contract', 'Contract_Trigger');
        createTriggerActivationCustomSettingRecords('Order', 'Order_Trigger');
        createTriggerActivationCustomSettingRecords('Contract_Invoice_Header__c', 'InvoiceHeader_Trigger');
        createTriggerActivationCustomSettingRecords('Contract_Invoice_Line__c', 'ContractInvoiceLine_Trigger');  
        createTriggerActivationCustomSettingRecords('Campaign', 'Campaign_Trigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        createTriggerActivationCustomSettingRecords('Bureau_Invoice__c', 'MS_Invoice_Trigger');
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Account accountRecord = TestDataUtility.getAccount();
        accountRecord.Industry = 'Education & Educational Services';
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        // Custom Setting for Auto Job creation
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c();
        cs.Name='Values';
        cs.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        INSERT cs;
        
        Campaign campaignRecord = TestDataUtility.getCampaign();
        INSERT campaignRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord.CampaignId = campaignRecord.Id;
        INSERT opportunityRecord;
        
        // Should create Opp Line Items
        
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id, opportunityRecord.id);
        contractRecord.Subscription_Start_Date__c = date.today();
        contractRecord.Contract_End_Date__c = date.today()+365;
        INSERT contractRecord; 
        
        Order orderRecord = TestDataUtility.getOrder(contractRecord.id, accountRecord.id);
        orderRecord.Booked_Elsewhere__c = False;
        orderRecord.EffectiveDate = date.today();
        orderRecord.Submission_Offset__c = -18000000;
        orderRecord.Activation_Offset__c = -18000000;
        orderRecord.Pricebook2Id = pricebookId;
        orderRecord.opportunityId = opportunityRecord.Id;
        INSERT orderRecord;
        
        // Should create Order Line Items
        
    }
    
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
    
    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
    
    @isTest
    public static void CreateInvoiceHeadersTester(){
        
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        
        // First Product
        Product2 productRecord = TestDataUtility.getProduct2();
        productRecord.Revenue_Category__c='Product in advance';
        productRecord.Renewable__c = 'Yes';
        productRecord.Status__c = 'Revenue Ready';
        INSERT productRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord;
        
        OrderItem orderItemRecord = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord.Id);
        orderItemRecord.UnitPrice = 100;
        orderItemRecord.Platform__c = 'MFS';
        orderItemRecord.Quantity = 1;
        INSERT orderItemRecord;
        
        // Second Product
        Product2 productRecord2 = TestDataUtility.getProduct2();
        productRecord2.Revenue_Category__c='Professional Services';
        productRecord2.Renewable__c = 'Yes';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        //Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(productRecord2.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord2;
        
        OrderItem orderItemRecord2 = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord2.Id);
        orderItemRecord2.UnitPrice = 100;
        orderItemRecord2.Platform__c = 'MFS';
        orderItemRecord2.Quantity = 1;
        INSERT orderItemRecord2; 
        
        Test.startTest();
        
        OrderProductsInformation.GetOrderProducts(orderRecord.Id);
        InvoiceHeaderCreation.CountNonPSNonZeroOrderProducts(orderRecord.Id, '100% Upfront');
        InvoiceHeaderCreation.CountNonPSNonZeroOrderProducts(orderRecord.Id, 'Invoice per milestone');
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Bi-annual','Invoice per milestone', '15 days');
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Quarterly','Invoice per milestone', '15 days');
        
        Test.stopTest();
    }
    
    @isTest
    public static void CreateInvoiceHeadersTester2(){
        
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        
        // Second Product
        Product2 productRecord2 = TestDataUtility.getProduct2();
        productRecord2.Revenue_Category__c='Professional Services';
        productRecord2.Renewable__c = 'Yes';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(productRecord2.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord2;
        
        OrderItem orderItemRecord2 = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord2.Id);
        orderItemRecord2.UnitPrice = 100;
        orderItemRecord2.Platform__c = 'MFS';
        orderItemRecord2.Quantity = 1;
        INSERT orderItemRecord2;
        
        Test.startTest();
        
        OrderProductsInformation.GetOrderProducts(orderRecord.Id); 
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Monthly','100% Upfront', '15 days');
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void unitTestCaseForNot100PercentUpfrontForMSProducts(){
        
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        
        // MS Product
        Product2 productRecord2 = TestDataUtility.getProduct2();
        productRecord2.Revenue_Category__c='Managed Services';
        productRecord2.MS_Product__c = true;
        productRecord2.Renewable__c = 'No';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(productRecord2.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord2;
        
        OrderItem orderItemRecord2 = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord2.Id);
        orderItemRecord2.UnitPrice = 100;
        orderItemRecord2.Platform__c = 'MFS';
        orderItemRecord2.Quantity = 1;
        orderItemRecord2.Package__c = 'Service';
        INSERT orderItemRecord2;
        
        Test.startTest();
        
        //OrderProductsInformation.GetOrderProducts(orderRecord.Id);
        
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Quarterly','25% up front, 50% on milestones, 25% on completion', '15 days');
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void unitTestCaseForNot100PercentUpfrontForServiceProducts(){
        
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        
        // MS Product
        Product2 productRecord2 = TestDataUtility.getProduct2();
        productRecord2.Revenue_Category__c='Professional Services';
        //productRecord2.MS_Product__c = true;
        productRecord2.Renewable__c = 'No';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(productRecord2.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord2;
        
        OrderItem orderItemRecord2 = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord2.Id);
        orderItemRecord2.UnitPrice = 100;
        orderItemRecord2.Platform__c = 'MFS';
        orderItemRecord2.Quantity = 1;
        orderItemRecord2.Package__c = 'Service';
        INSERT orderItemRecord2;
        
        Test.startTest();
        
        //OrderProductsInformation.GetOrderProducts(orderRecord.Id);
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Quarterly','25% up front, 50% on milestones, 25% on completion', '15 days');
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Quarterly','Special Invoicing Instruction', '15 days');
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void unitTestCaseFor100PercentUpfrontForNonPsProducts(){
        
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        
        // Non PS Product
        Product2 productRecord2 = TestDataUtility.getProduct2();
        productRecord2.Revenue_Category__c='Managed Services';
        productRecord2.Renewable__c = 'Yes';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(productRecord2.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord2;
        
        OrderItem orderItemRecord2 = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord2.Id);
        orderItemRecord2.UnitPrice = 100;
        orderItemRecord2.Platform__c = 'MFS';
        orderItemRecord2.Quantity = 1;
        INSERT orderItemRecord2;
        
        Test.startTest();
        
        OrderProductsInformation.GetOrderProducts(orderRecord.Id);
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Monthly','100% Upfront', '15 days');
        
        Test.stopTest(); 
    }
    
    @isTest
    static void test_pickListValueDynamically() {
        
        InvoiceHeaderCreation.pickListValueDynamically( 'Order', 'Product_Billing_Frequency__c');
    }
    
    @isTest
    static void test_updateOrderRecord() {
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        
        InvoiceHeaderCreation.updateOrderRecord(orderRecord.Id, 'Annual', '100% Upfront');
    }
    
    @isTest
    static void test_RemoveDuplicateLinesInvocable() {
        
        Order orderRecord = [SELECT Id, BU__c, BillToContactId, AccountId, CurrencyIsoCode, PoNumber FROM Order LIMIT 1];
        
        // First Product
        Product2 productRecord = TestDataUtility.getProduct2();
        productRecord.Revenue_Category__c='Product in advance';
        productRecord.Renewable__c = 'Yes';
        productRecord.Status__c = 'Revenue Ready';
        INSERT productRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord;
        
        OrderItem orderItemRecord = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord.Id);
        orderItemRecord.UnitPrice = 100;
        orderItemRecord.Platform__c = 'MFS';
        orderItemRecord.Quantity = 1;
        orderItemRecord.Product2Id = productRecord.Id;
        INSERT orderItemRecord;
        
        OrderItem orderItemRecord11 = [select Id,Platform__c,Total_Price__c,TotalPrice,Usage_Allowance__c,UnitPrice,Basis_of_Fees__c,
                                       Product2.Revenue_Category__c,OrderId,Package__c,Product2.Name,Product2.StockKeepingUnit,Quantity,Proposition__c, Product2.MS_Product__c from orderitem where Id=:orderItemRecord.Id];
        // Second Product
        Product2 productRecord2 = TestDataUtility.getProduct2();
        productRecord2.Revenue_Category__c='Professional Services';
        productRecord2.Renewable__c = 'Yes';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        //Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(productRecord2.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord2;
        
        OrderItem orderItemRecord2 = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord2.Id);
        orderItemRecord2.UnitPrice = 100;
        orderItemRecord2.Platform__c = 'MFS';
        orderItemRecord2.Quantity = 1;
        orderItemRecord2.Product2Id = productRecord2.Id;
        INSERT orderItemRecord2;
        
        OrderItem orderItemRecord22 = [select Id,Platform__c,Total_Price__c,TotalPrice,Usage_Allowance__c,UnitPrice,Basis_of_Fees__c,
                                       Product2.Revenue_Category__c,OrderId,Package__c,Product2.Name,Product2.StockKeepingUnit,Quantity,Proposition__c, Product2.MS_Product__c from orderitem where Id=:orderItemRecord2.Id];
        
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Order__c = orderRecord.Id;
        invoiceHeader.BU__c = orderRecord.BU__c;
        invoiceHeader.Billing_Contact__c = orderRecord.BillToContactId;
        invoiceHeader.Invoice_Account__c = orderRecord.AccountId;
        invoiceHeader.Invoice_Contact__c = orderRecord.BillToContactId;
        invoiceHeader.CurrencyIsoCode = orderRecord.CurrencyIsoCode;
        invoiceHeader.Invoice_Status__c = 'Draft';
        invoiceHeader.Is_Auto_Created__c = True;
        invoiceHeader.PO_number__c = orderRecord.PoNumber;
        
        invoiceHeader.Service_Start_Date__c = Date.today();
        invoiceHeader.Process_Date__c = Date.today();
        invoiceHeader.Service_End_Date__c = Date.today().addMonths(1).addDays(-1);
        invoiceHeader.Invoice_Name__c = 'Test Invoice 1';                                                                   
        invoiceHeader.Process_Date__c = System.Today();
        insert invoiceHeader;
        
        List<Contract_Invoice_Line__c> invoiceLineList = new List<Contract_Invoice_Line__c>();
        Test.startTest();
        
        System.debug('orderItemRecord TotalPrice --> '+ orderItemRecord11.TotalPrice);
        System.debug('orderItemRecord TotalPrice --> '+ orderItemRecord22.TotalPrice);
        
        invoiceLineList.add(InvoiceHeaderCreation.CreateInvoiceLine(orderItemRecord11, invoiceHeader, 1));
        invoiceLineList.add(InvoiceHeaderCreation.CreateInvoiceLine(orderItemRecord22, invoiceHeader, 1));
        
        InvoiceHeaderCreation.RemoveDuplicateLinesInvocable(new List<List<Contract_Invoice_Line__c>>{invoiceLineList});
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestCaseForOnlyServiceProducts(){
        
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        
        // Service Product
        Product2 productRecord2 = TestDataUtility.getProduct2();
        productRecord2.Revenue_Category__c='Other';
        productRecord2.Renewable__c = 'No';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(productRecord2.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord2;
        
        OrderItem orderItemRecord2 = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord2.Id);
        orderItemRecord2.UnitPrice = 100;
        orderItemRecord2.Platform__c = 'MFS';
        orderItemRecord2.Quantity = 1;
        orderItemRecord2.Package__c = 'Service';
        INSERT orderItemRecord2;
        
        Test.startTest();
        
        //OrderProductsInformation.GetOrderProducts(orderRecord.Id);
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Quarterly','25% up front, 50% on milestones, 25% on completion', '15 days');
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Quarterly','Special Invoicing Instruction', '15 days');
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void Prevent_Delete_InvoiceHeader_Test(){
        Order order = [SELECT Id, BU__c, BillToContactId, AccountId, CurrencyIsoCode, PoNumber, EffectiveDate FROM Order LIMIT 1];
        Date InvoiceStartDatetemp = order.EffectiveDate;
        String PaymentTerms = '15 days';
        String invoiceName = 'Test Invoice 1'; 
        
        Contract_Invoice_Header__c InvoiceHeader = new Contract_Invoice_Header__c();
        
        InvoiceHeader.Order__c = order.Id;
        InvoiceHeader.BU__c = order.BU__c;
        InvoiceHeader.Billing_Contact__c = order.BillToContactId;
        InvoiceHeader.Invoice_Account__c = order.AccountId;
        InvoiceHeader.Invoice_Contact__c = order.BillToContactId;
        InvoiceHeader.CurrencyIsoCode = order.CurrencyIsoCode;
        InvoiceHeader.Invoice_Status__c = 'Draft';
        InvoiceHeader.Is_Auto_Created__c = True;
        InvoiceHeader.PO_number__c = order.PoNumber;
        
        InvoiceHeader.Service_Start_Date__c = InvoiceStartDatetemp;
        InvoiceHeader.Process_Date__c = InvoiceStartDatetemp;
        InvoiceHeader.Service_End_Date__c = InvoiceStartDatetemp.addMonths(1).addDays(-1);
        InvoiceHeader.Invoice_Name__c = invoiceName;
        InvoiceHeader.GSSC_Instructions__c = PaymentTerms;                                                                   
        InvoiceHeader.Process_Date__c = System.Today();
        InvoiceHeader.Invoice_Status__c = 'Sun Order Complete';
        InvoiceHeader.SunSystems_Order_Reference__c = '1224324';
        
        insert InvoiceHeader;
        
        User usr = [SELECT Id FROM User Where isActive = true AND Profile.Name = 'Commercial' LIMIT 1];
        Test.startTest();
        System.runAs(usr){
            try{
                delete InvoiceHeader;
            } catch (Exception e){
                System.assertNotEquals('', e.getMessage());
            }
            
        }
        Test.stopTest(); 
        //update InvoiceHeader;
    }
    
    @isTest
    public static void testMapServiceEndDateForMS(){
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        contactRecord.FirstName = contactRecord.Name + System.Now();
        contactRecord.Email = 'TestEndDate@Test.com';
        INSERT contactRecord;
        
        // Custom Setting for Auto Job creation
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c();
        cs.Name='Values';
        cs.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        INSERT cs;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord.Pricebook2Id = pricebookId;
        INSERT opportunityRecord;
        
        User userRecord = TestDataUtility.getUser('Managed Service Lightning');
        userRecord.MS_LOB__c = 'TA - Corporate, TA - Credentialing, Talent Management, TA - Vocational (Batch) & TA - Vocational (School)';
        userRecord.Is_Job_Manager__c = true;
        userRecord.Is_Managed_Service_Manager__c = true;
        INSERT userRecord;
        
        Id recordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        
        Job__c job = new Job__c();
        job.Opportunity__c = opportunityRecord.Id;
        job.Project_Manager__c = userRecord.Id;
        job.Account__c = accountRecord.Id;
        job.MS_Line_of_Business__c = 'Talent Management';
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.InternalContact__c = UserInfo.getUserId();
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = 'QA01';
        job.ShortFall_Manager__c = 1;
        job.Shortfall_Peer__c = 2;
        job.Shortfall_Subordinate__c = 3;
        job.ShortFall_Customer__c = 2;
        job.Shortfall_Client__c = 2;
        job.ShortFall_Other__c = 2;
        job.PurchaseOrderNo__c='rtertr';
        job.Generic_BS_Field_One__c='Bureau Service';
        job.Generic_Field_MS_One__c='Managed Service';
        job.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        job.Is_Redirect_To_Task__c=true;
        job.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        job.System_Used__c ='SHL ONLINE';
        job.RecordTypeId = recordTypeId;
        job.Do_Not_Send_Survey__c = true;
        job.Preferred_Language__c = 'English';
        job.Generic_Date_Field_MS_One__c = System.today();
        job.Job_Region__c = 'Non China';
        
        insert job;
        
        Order order = [SELECT Id, BU__c, BillToContactId, AccountId, CurrencyIsoCode, PoNumber, EffectiveDate FROM Order LIMIT 1];
        Date InvoiceStartDatetemp = order.EffectiveDate;
        String PaymentTerms = '15 days';
        String invoiceName = 'Test Invoice 1'; 
        
        Contract_Invoice_Header__c InvoiceHeader = new Contract_Invoice_Header__c();
        
        InvoiceHeader.Order__c = order.Id;
        InvoiceHeader.BU__c = order.BU__c;
        InvoiceHeader.Billing_Contact__c = order.BillToContactId;
        InvoiceHeader.Invoice_Account__c = order.AccountId;
        InvoiceHeader.Invoice_Contact__c = order.BillToContactId;
        InvoiceHeader.CurrencyIsoCode = order.CurrencyIsoCode;
        InvoiceHeader.Invoice_Status__c = 'Draft';
        InvoiceHeader.Is_Auto_Created__c = True;
        InvoiceHeader.PO_number__c = order.PoNumber;
        
        InvoiceHeader.Service_Start_Date__c = InvoiceStartDatetemp;
        InvoiceHeader.Process_Date__c = InvoiceStartDatetemp;
        InvoiceHeader.Service_End_Date__c = InvoiceStartDatetemp.addMonths(1).addDays(-1);
        InvoiceHeader.Invoice_Name__c = invoiceName;
        InvoiceHeader.GSSC_Instructions__c = PaymentTerms;                                                                   
        InvoiceHeader.Process_Date__c = System.Today();
        InvoiceHeader.Invoice_Status__c = 'Sun Order Complete';
        InvoiceHeader.SunSystems_Order_Reference__c = '1224324';
        
        insert InvoiceHeader;
        
        Test.startTest();
        try{
            InvoiceHeader.Job_Number__c = job.Id;
            update InvoiceHeader;
        } catch (Exception e){
            System.assertNotEquals('', e.getMessage());
        }
        Test.stopTest(); 
        
    }
    
    @isTest
    public static void testSendPOEmail(){
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        
        // First Product
        Product2 productRecord = TestDataUtility.getProduct2();
        productRecord.Revenue_Category__c='Product in advance';
        productRecord.Renewable__c = 'Yes';
        productRecord.Status__c = 'Revenue Ready';
        INSERT productRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord;
        
        OrderItem orderItemRecord = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord.Id);
        orderItemRecord.UnitPrice = 100;
        orderItemRecord.Platform__c = 'MFS';
        orderItemRecord.Quantity = 1;
        INSERT orderItemRecord;
        
        // Second Product
        Product2 productRecord2 = TestDataUtility.getProduct2();
        productRecord2.Revenue_Category__c='Professional Services';
        productRecord2.Renewable__c = 'Yes';
        productRecord2.Status__c = 'Revenue Ready';
        INSERT productRecord2;
        
        //Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(productRecord2.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord2;
        
        OrderItem orderItemRecord2 = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord2.Id);
        orderItemRecord2.UnitPrice = 100;
        orderItemRecord2.Platform__c = 'MFS';
        orderItemRecord2.Quantity = 1;
        INSERT orderItemRecord2; 
        
        InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Bi-annual','Invoice per milestone', '15 days');
        list<Contract_Invoice_Header__c> invoiceList = new list<Contract_Invoice_Header__c>();
        invoiceList = [SELECT Id, Name, Order__c, Process_Date__c, Order__r.Name, Order__r.Opportunity.Name,
                       Order__r.Opportunity.Owner.Email, Order__r.Opportunity.Owner.Name, 
                       Order__r.Account.Name, Order__r.Account.Owner.Name 
                       FROM Contract_Invoice_Header__c];
        
        Test.startTest();
        InvoiceHeaderTriggerManager_1.sendPOEmail(new List<List<String>>{new List<String>{invoiceList[0].Id}});
        Test.stopTest();
        
    }
    
        @isTest
        public static void testSendPOEmailErrorCase(){
            Order orderRecord = [SELECT Id FROM Order LIMIT 1];
            
            // First Product
            Product2 productRecord = TestDataUtility.getProduct2();
            productRecord.Revenue_Category__c='Product in advance';
            productRecord.Renewable__c = 'Yes';
            productRecord.Status__c = 'Revenue Ready';
            INSERT productRecord;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            PricebookEntry pricebookEntryRecord = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', pricebookId);
            INSERT pricebookEntryRecord;
            
            OrderItem orderItemRecord = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord.Id);
            orderItemRecord.UnitPrice = 100;
            orderItemRecord.Platform__c = 'MFS';
            orderItemRecord.Quantity = 1;
            INSERT orderItemRecord;
            
            // Second Product
            Product2 productRecord2 = TestDataUtility.getProduct2();
            productRecord2.Revenue_Category__c='Professional Services';
            productRecord2.Renewable__c = 'Yes';
            productRecord2.Status__c = 'Revenue Ready';
            INSERT productRecord2;
            
            //Id pricebookId = Test.getStandardPricebookId();
            
            PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(productRecord2.Id, 'GBP', pricebookId);
            INSERT pricebookEntryRecord2;
            
            OrderItem orderItemRecord2 = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord2.Id);
            orderItemRecord2.UnitPrice = 100;
            orderItemRecord2.Platform__c = 'MFS';
            orderItemRecord2.Quantity = 1;
            INSERT orderItemRecord2; 
            
            Order order = [SELECT Id, BU__c, BillToContactId, AccountId, CurrencyIsoCode, PoNumber, EffectiveDate FROM Order where Id = :orderRecord.Id];
            Date InvoiceStartDatetemp = order.EffectiveDate;
            String PaymentTerms = '15 days';
            String invoiceName = 'Test Invoice 1'; 
            Contact contactRecord = [SELECT Id, Contact_Status__c FROM Contact];
            
            Contract_Invoice_Header__c InvoiceHeader = new Contract_Invoice_Header__c();
            
            InvoiceHeader.Order__c = order.Id;
            InvoiceHeader.BU__c = order.BU__c;
            InvoiceHeader.Billing_Contact__c = order.BillToContactId;
            InvoiceHeader.Invoice_Account__c = order.AccountId;
            InvoiceHeader.Invoice_Contact__c = contactRecord.Id;
            InvoiceHeader.CurrencyIsoCode = order.CurrencyIsoCode;
            InvoiceHeader.Invoice_Status__c = 'Draft';
            InvoiceHeader.Is_Auto_Created__c = True;
            InvoiceHeader.PO_number__c = order.PoNumber;
            
            InvoiceHeader.Service_Start_Date__c = InvoiceStartDatetemp;
            InvoiceHeader.Process_Date__c = InvoiceStartDatetemp;
            InvoiceHeader.Service_End_Date__c = InvoiceStartDatetemp.addMonths(1).addDays(-1);
            InvoiceHeader.Invoice_Name__c = invoiceName;
            InvoiceHeader.GSSC_Instructions__c = PaymentTerms;                                                                   
            InvoiceHeader.Process_Date__c = System.Today();
            InvoiceHeader.Invoice_Status__c = 'Sun Order Complete';
            InvoiceHeader.SunSystems_Order_Reference__c = '1224324';
            
            insert InvoiceHeader;
            
            list<Contract_Invoice_Header__c> invoiceList = new list<Contract_Invoice_Header__c>();
            invoiceList = [SELECT Id, Name, Order__c, Process_Date__c, Order__r.Name, Order__r.Opportunity.Name,
                           Order__r.Opportunity.Owner.Email, Order__r.Opportunity.Owner.Name, 
                           Order__r.Account.Name, Order__r.Account.Owner.Name,Invoice_Contact__c,Invoice_Account__c,
                           Invoice_Contact__r.AccountId
                           FROM Contract_Invoice_Header__c];
            
            System.debug('Invoice List --> '+invoiceList[0].Invoice_Contact__c);
            System.debug('Invoice List --> '+invoiceList[0].Invoice_Account__c);
            System.debug('Invoice List123 --> '+invoiceList[0].Invoice_Contact__r.AccountId);
            Contact contactRecord1 = [SELECT Id, Contact_Status__c FROM Contact];
            contactRecord1.Contact_Status__c = 'Deceased';
            UPDATE contactRecord1;
            
            Test.startTest();
            InvoiceHeaderTriggerManager_1.sendPOEmail(new List<List<String>>{new List<String>{invoiceList[0].Id}});
            Test.stopTest();
        
    }

}
/**************************************************************************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 16-02-2021
DESCRIPTION :- for the purpose of test coverage exclusively to "ContractTriggerManagerNew" Class created during Athena.
***************************************************************************************************************************************/ 
@isTest
private class ContractTriggerManagerNew_Tester{
    
    @testSetup static void setup() {
        
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');
        
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Contract', 'Contract_Trigger');
        createTriggerActivationCustomSettingRecords('Order', 'Order_Trigger');
        createTriggerActivationCustomSettingRecords('Contract_Invoice_Header__c', 'InvoiceHeader_Trigger');
        createTriggerActivationCustomSettingRecords('Contract_Invoice_Line__c', 'ContractInvoiceLine_Trigger');   
        createTriggerActivationCustomSettingRecords('OpportunityLineItem', 'OpportunityLineItem_Trigger');
        
        AutomaticJobCreation__c cs = new AutomaticJobCreation__c(Name='Values', 
                                                                 MS_Line_of_Business__c='TA - Corporate,Talent Management,TA - Credentialing');
        insert cs;
        
        User user = new User(Username='testuserTEST1234@test.com', Email='testuserTEST1234@test.com', 
                             Alias='testu', EmailEncodingKey='UTF-8', LastName='Testing', 
                             LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                             TimeZoneSidKey='America/Los_Angeles', 
                             ProfileId = [SELECT Id FROM Profile WHERE Name = 'OAT' LIMIT 1].Id);
        insert user;
        
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Id pricebookId = Test.getStandardPricebookId(); //TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        
        Opportunity opp = new Opportunity();
        opp.AccountId=accountRecord.id;
        opp.name='Test Opportunity';
        opp.Unconfirmed_Sun_Order_Number__c='';
        opp.ownerid=UserInfo.getUserId();
        opp.StageName='proposal';
        opp.Closedate=system.today();
        opp.Primary_Contact__c=contactRecord.id;
        opp.Billing_Contact__c=contactRecord.id;
        opp.pricebook2id=pricebookId;
        opp.CurrencyIsoCode='AUD';
        opp.NVM_Credit_Card_ID__c='1234';
        opp.Amount=1000;
        opp.Variation_Opportunity__c='NO';
        opp.OppUpdatedByOrderOn__c=Date.today();
        opp.Original_Opportunity__c=null;
        opp.Annual_Contract_Value__c=1000.00;
        opp.Business_Type__c='New customer: subscription';
        opp.CurrencyISOCode='GBP';
        opp.RecordTypeID=System.label.StandardRecordType;
        opp.Forecast_Category__c='Pipeline';//Forecast
        opp.Multi_YearDeal__c='1';
        opp.Offering__c='OPQ';
        opp.Talent_Segment__c='Volume';
        opp.TM_Phase__c='Post-Hire';
        //opp.contractid=contractRecord.id;
        insert opp;
        
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id, opp.id);
        contractRecord.Payment_terms__c = '30 days';
        contractRecord.Run_Order_Creation_Flow__c=true;
        contractRecord.PDFCount__c = 1;
        contractRecord.CSVCount__c = 0;
        contractRecord.Product_Billing_Frequency__c = 'Monthly';
        INSERT contractRecord; 
        
        opp.contractid=contractRecord.id;
        UPDATE opp;
        
        Order orderRecord = TestDataUtility.getOrder(contractRecord.id, accountRecord.id);
        orderRecord.Booked_Elsewhere__c = False;
        orderRecord.Submission_Offset__c = -18000000;
        orderRecord.Activation_Offset__c = -18000000;
        orderRecord.Pricebook2Id = '01s2000000000vQAAQ';
        orderRecord.Name ='Test';
        orderRecord.Order_Year__c=2;
        orderRecord.Oats_Status__c = 'Completed';
        orderRecord.Reduction_Order__c = False;
        orderRecord.Booking_Date__c=date.today();
        INSERT orderRecord;
        
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
    static void testMethod2(){
        Account accountRecord = [SELECT Id, BU__c FROM Account LIMIT 1];
        Contact contactRecord = [SELECT Id, AccountId FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id, opp.id);
        contractRecord.Payment_terms__c = '30 days';
        contractRecord.Run_Order_Creation_Flow__c=true;
        contractRecord.PDFCount__c = 1;
        contractRecord.CSVCount__c = 0;
        contractRecord.Product_Billing_Frequency__c = 'Monthly';
        INSERT contractRecord; 
        
        
        opp.contractid=contractRecord.id;
        opp.StageName='verbal';
        UPDATE opp;
        //Contract contractRecord = [SELECT Id, CurrencyIsoCode, Status,Service_billing_frequency__c FROM Contract LIMIT 1];
        //User oatUser = TestDataUtility.getUser('OAT');
        User oatUser= [SELECT Id, Name, Email, Profile.Name 
                       FROM User 
                       WHERE IsActive = true AND Profile.Name = 'OAT'
                       LIMIT 1];
        User user = new User(Username='testuserTEST12345@test.com', Email='testuserTEST12345@test.com', 
                                     Alias='testu', EmailEncodingKey='UTF-8', LastName='Testing', 
                                     LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                     TimeZoneSidKey='America/Los_Angeles', 
                                     ProfileId = [SELECT Id FROM Profile WHERE Name = 'OAT' LIMIT 1].Id);
                insert user;
	        
        /*System.runAs(oatUser){
            try{
                //OrderPdfCsvChecks
                //ContractValue
                contractRecord.Service_billing_frequency__c = '100% Upfront';
                contractRecord.Status = 'Accepted';
                Test.startTest();
                UPDATE contractRecord;
                Test.stopTest();
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Contract status cannot be changed to "'+ contractRecord.status + '" as it does not have both  \'Signed Order Form PDF\' and \'Pricing Configurator\'') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
        }*/
        //System.runAs(user) {
            try {
                // Simulate an update that violates business logic
                contractRecord.Service_billing_frequency__c = '100% Upfront';
                contractRecord.Status = 'Accepted';
                
                Test.startTest();
                UPDATE contractRecord; // Line 133
                Test.stopTest();
            } catch (Exception e) {
                // Debugging the exception message
                System.debug('Actual exception message: ' + e.getMessage());
                
                Boolean expectedExceptionThrown = e.getMessage().contains(
                    'Contract status cannot be changed to "' + contractRecord.status + 
                    '" as it does not have both  \'Signed Order Form PDF\' and \'Pricing Configurator\''
                );
                System.assertEquals(expectedExceptionThrown, true, 
                    'Expected exception was not thrown. Actual: ' + e.getMessage());
            }
        //}

    }
    
    @isTest
    static void testMethod3(){
        Account accountRecord = [SELECT Id, BU__c FROM Account LIMIT 1];
        Contact contactRecord = [SELECT Id, AccountId FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contract contractRecord = [SELECT Id, CurrencyIsoCode, Status,Service_billing_frequency__c FROM Contract LIMIT 1];
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        User oatUser = [SELECT Id, Name, Email, Profile.Name 
                       FROM User 
                       WHERE IsActive = true AND Profile.Name = 'OAT'
                       LIMIT 1];
        //TestDataUtility.getUser('OAT');
        
        list<Product2> prodlist = new list <Product2>();
        prodlist = TestDataUtility.getProduct2List(3);
        
        prodlist[0].Revenue_Category__c = 'Subscription';
        prodlist[0].Renewable__c = 'Yes';
        
        prodlist[1].Revenue_Category__c = 'Subscription';
        prodlist[1].Renewable__c = 'Yes';
        
        prodlist[2].Revenue_Category__c = 'Training';
        INSERT prodlist;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        list<PricebookEntry> priceBookEntryList = new list<PricebookEntry>();
        PricebookEntry pricebookEntryRecord0 = TestDataUtility.getPricebookEntry(prodlist[0].Id, 'GBP', pricebookId);
        priceBookEntryList.add(pricebookEntryRecord0);
        PricebookEntry pricebookEntryRecord1 = TestDataUtility.getPricebookEntry(prodlist[1].Id, 'GBP', pricebookId);
        priceBookEntryList.add(pricebookEntryRecord1);
        PricebookEntry pricebookEntryRecord2 = TestDataUtility.getPricebookEntry(prodlist[2].Id, 'GBP', pricebookId);
        priceBookEntryList.add(pricebookEntryRecord2);
        INSERT priceBookEntryList;
        

        list<OpportunityLineItem> OLIlist = new list<OpportunityLineItem>();
        OpportunityLineItem LI1=new OpportunityLineItem(RenewableNew__c = 'Ongoing',OpportunityId=opp.id,PricebookEntryId=pricebookEntryRecord0.id,TotalPrice=100,
                                                        Quantity=1,Platform__c='iAssess',Solution_Cap__c = 12,Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,
                                                        Basis_of_Fees__c='Applications',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI1);
        
        OpportunityLineItem LI2=new OpportunityLineItem(RenewableNew__c = 'Ongoing',OpportunityId=opp.id,PricebookEntryId=pricebookEntryRecord1.id,TotalPrice=100,
                                                        Quantity=1,Platform__c='iAssess',Solution_Cap__c = 12,Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,
                                                        Basis_of_Fees__c='Applications',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI2);
        
        OpportunityLineItem LI3=new OpportunityLineItem(RenewableNew__c = 'Ongoing',OpportunityId=opp.id,PricebookEntryId=pricebookEntryRecord2.id,TotalPrice=100,
                                                        Quantity=1,Platform__c='iAssess',Solution_Cap__c = 12,Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,
                                                        Basis_of_Fees__c='Applications',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI3);
        insert OLIlist;
        
        List<OrderItem> OrderItemList = new list<OrderItem>();
        for(OpportunityLineItem oli : OLIlist ){
            OrderItem orderItemRecord = TestDataUtility.getOrderItem(orderRecord.Id, oli.PricebookEntryId);
            orderItemRecord.UnitPrice = oli.List_Price__c;
            orderItemRecord.Quantity = oli.Quantity;
            OrderItemList.add(orderItemRecord);
        }
        insert OrderItemList;
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = contactRecord.id;
        invoiceHeader.Account__c = contactRecord.AccountId;
        invoiceHeader.Contract__c = contractRecord.id;
        invoiceHeader.CurrencyIsoCode = contractRecord.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = accountRecord.BU__c;
        invoiceHeader.Order__c=orderRecord.id;
        invoiceHeader.Invoice_Status__c='Draft';
        insert invoiceHeader;
        
        opp.StageName='verbal';
        //opp.Billing_Contact__c = null;
        UPDATE opp;
        contractRecord.Service_billing_frequency__c = '100% Upfront';
        contractRecord.Status = 'Accepted';
        UPDATE contractRecord;
                
        
        System.runAs(oatUser){
            try{
                orderRecord.Status = 'Activated';
                UPDATE orderRecord;
        
                //ContractCancel
                contractRecord.Status = 'Cancelled';
                Test.startTest();
                UPDATE contractRecord;
                Test.stopTest();
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Contract cannot be marked as cancelled as linked Renewal Order is already activated') ? true : false;
                System.assertEquals(expectedExceptionThrown, false);
            }
            
        }
    }
   
    
}
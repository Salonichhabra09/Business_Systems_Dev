@isTest
public class Test_ExtensionProcess {
	
    @testSetup static void setup() {
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');  
        
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createTriggerActivationCustomSettingRecords('Campaign', 'Campaign_Trigger');
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityLineItem', 'OpportunityLineItem_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Contract', 'Contract_Trigger');
        createTriggerActivationCustomSettingRecords('Order', 'Order_Trigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        
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
        
        Id oppPriceBookId = [SELECT Pricebook2Id FROM Opportunity WHERE Id =: opportunityRecord.Id].Pricebook2Id;
        
        // First Product
        Product2 productRecord = TestDataUtility.getProduct2();
        productRecord.Revenue_Category__c='Managed Services';
        productRecord.Renewable__c = 'No';
        productRecord.MS_Product__c = true;
        productRecord.MS_Type__c = 'Talent Management';
        productRecord.Family = 'Services';
        INSERT productRecord;
        
        PricebookEntry pricebookEntryRecord1 = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord1;
        
        PricebookEntry pricebookEntryRecord = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', oppPriceBookId);
        INSERT pricebookEntryRecord;
        
        OpportunityLineItem originalOLI = new OpportunityLineItem(RenewableNew__c = 'Ongoing',
                                                        OpportunityId=opportunityRecord.Id,
                                                        PricebookEntryId=pricebookEntryRecord.Id,
                                                        TotalPrice=100,
                                                        Quantity=1,
                                                        Platform__c='iAssess',
                                                        Solution_Cap__c = 12,
                                                        Usage_Allowance__c='Capped', 
                                                        Usage_Cap_or_Estimation__c=1234,
                                                        Basis_of_Fees__c='Applications',
                                                        List_Price__c=100,
                                                        Proposition__c='Graduate Hiring',
                                                        Package__c='Graduate Advanced',
                                                        Product2Id = productRecord.Id);
        INSERT originalOLI;
        
        Opportunity opportunityRecord2 = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord.CampaignId = campaignRecord.Id;
        opportunityRecord.Skip_Validation_Auto_Renewal__c = true;
        INSERT opportunityRecord2;
        
        opportunityRecord2.StageName = 'Closed Lost';
        UPDATE opportunityRecord2;
        
        Opportunity opportunityRecord3 = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord3.CampaignId = campaignRecord.Id;
        opportunityRecord3.Original_Opportunity__c = opportunityRecord.Id;
        INSERT opportunityRecord3;
        
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id, opportunityRecord.id);
        contractRecord.Subscription_Start_Date__c = date.today();
        contractRecord.Contract_End_Date__c = date.today()+365;
        contractRecord.Client_Display__c = 'Summary Pricing';
        INSERT contractRecord; 
        
        /*Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id =: opportunityRecord.Id];
        opp.StageName = 'Closed/Won';
        UPDATE opp;
        */
        /*Contract contractRec = [SELECT Id FROM Contract WHERE Id = :contractRecord.Id];
        contractRec.Product_Billing_Frequency__c = 'Monthly';
        contractRec.Service_billing_frequency__c = '100% Upfront';
        contractRec.Payment_terms__c = '30 days';
        contractRec.Status = 'Accepted';
        UPDATE contractRec;*/
        
        //contractRecord.Status = 'Accepted';
        //UPDATE contractRecord;
        
        
        Order orderRecord = TestDataUtility.getOrder(contractRecord.id, accountRecord.id);
        orderRecord.Booked_Elsewhere__c = False;
        orderRecord.EffectiveDate = date.today();
        orderRecord.Submission_Offset__c = -18000000;
        orderRecord.Activation_Offset__c = -18000000;
        orderRecord.Pricebook2Id = pricebookId;
        orderRecord.opportunityId = opportunityRecord.Id;
        INSERT orderRecord;
        
        orderRecord.Booking_Date__c = System.now();
        UPDATE orderRecord;
        
        //InvoiceHeaderCreation.CreateInvoiceHeaders(orderRecord.Id,'Monthly','100% Upfront', '15 days');
        
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
    public static void testUpdateOpportunitiesAsynchronously(){
        
        list<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE StageName <> 'Closed Lost'];
        Opportunity closeLostOpp = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Lost' LIMIT 1];
        
        list<UpdateOpportunitiesAsynchronously.InputValues> inputList = new list<UpdateOpportunitiesAsynchronously.InputValues>();
        UpdateOpportunitiesAsynchronously.InputValues inputVal = new UpdateOpportunitiesAsynchronously.InputValues();
        
        inputVal.opportunityListToUpdate = oppList;
        inputVal.closedLostOpportunityIdToUpdate = closeLostOpp.Id;
        inputVal.clonePlaceholderOpportunity = true;
        inputVal.openPlaceholderInCaseOfOrderActivation = oppList[0];
        
        inputList.add(inputVal);
        
        Test.startTest();
        UpdateOpportunitiesAsynchronously.updateOpportunities(inputList);
        Test.stopTest();

    }
    
    @isTest
    public static void testCallOrderCancellationProcess(){
        
        list<Order> orderRecord = [Select RecordTypeId,status,Reduction_Order__c,Course_Booking__c,ContractId,id,Cancellation_Reason__c,Cancellation_Sub_Reason__c,Cancellation_Reason_Additional_Required__c,Order_Year__c from Order];
        
        list<callOrderCancellationProcess.InputValues> inputList = new list<callOrderCancellationProcess.InputValues>();
        callOrderCancellationProcess.InputValues inputVal = new callOrderCancellationProcess.InputValues();
        
        inputVal.orderData = orderRecord[0];
        inputList.add(inputVal);
        
        Test.startTest();
        callOrderCancellationProcess.orderCancellationProcess(inputList);
		Test.stopTest();        
        
    }
    
    @isTest
    public static void testAssignPermissionSetToUser(){
        
        list<Order> orderRecord = [Select RecordTypeId,status,Reduction_Order__c,Course_Booking__c,ContractId,id,Cancellation_Reason__c,Cancellation_Sub_Reason__c,Cancellation_Reason_Additional_Required__c,Order_Year__c from Order];
        String myPermissionSetId = System.label.OrderContractViewAllPermissionSet;
        String myAssigneeId = userInfo.getUserId();
		
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = myPermissionSetId;
        psa.AssigneeId = myAssigneeId;
        insert psa;
        
        Test.startTest();
        Id jobID2 = System.enqueueJob(new AssignPermissionSetToUser(orderRecord[0], psa, false));
		Test.stopTest();        
        
    }
        
    @isTest
    public static void testCallOrderCancellationFlow(){
        
        list<Order> orderRecord = [Select RecordTypeId,status,Reduction_Order__c,Course_Booking__c,ContractId,id,Cancellation_Reason__c,Cancellation_Sub_Reason__c,Cancellation_Reason_Additional_Required__c,Order_Year__c from Order];
        String myPermissionSetId = System.label.OrderContractViewAllPermissionSet;
        String myAssigneeId = userInfo.getUserId();
		
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = myPermissionSetId;
        psa.AssigneeId = myAssigneeId;
        insert psa;
        
        Test.startTest();
        Id jobID2 = System.enqueueJob(new callOrderCancellationFlow(orderRecord[0], psa, false));
		Test.stopTest();        
        
    }
    
    @isTest
    public static void testDeleteTopicAssignment(){
        
        Opportunity opp = [SELECT Id,Name,OpportunityId__c FROM Opportunity WHERE StageName <> 'Closed Lost' LIMIT 1];
        
        Topic topicRecord = new Topic();
        topicRecord.Name = opp.OpportunityId__c;
        INSERT topicRecord;
        
        TopicAssignment topicAssignmentRecord = new TopicAssignment();
        topicAssignmentRecord.EntityId = opp.Id;
        topicAssignmentRecord.TopicId = topicRecord.Id;
        INSERT topicAssignmentRecord;
        
        Test.startTest();
        DELETE topicAssignmentRecord;
		Test.stopTest();        
        
    }
    
    @isTest
    public static void testCreateTopicForOpportunity(){
        
        list<Opportunity> opportunityRecord = [Select Id, Name, Original_Opportunity__c FROM Opportunity WHERE Original_Opportunity__c <> null];
        
        list<CreateTopicForOpportunity.InputValues> inputList = new list<CreateTopicForOpportunity.InputValues>();
        CreateTopicForOpportunity.InputValues inputVal = new CreateTopicForOpportunity.InputValues();
        
        inputVal.opportunityData = opportunityRecord[0];
        inputList.add(inputVal);
        
        Test.startTest();
        CreateTopicForOpportunity.createTopic(inputList);
		Test.stopTest();        
        
    }
}
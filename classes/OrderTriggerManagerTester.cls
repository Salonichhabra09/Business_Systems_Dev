@isTest (seealldata=true)
public class OrderTriggerManagerTester {
    
    static testmethod void testCreateRejection(){
        // Reject the submitted request, providing a comment.
        
        Test.startTest(); 
        Id testWorkItemId = CreateAndSubmitOrder();
        Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
        testRej.setComments('Rejecting request with a comment.');
        testRej.setAction  ('Reject');
        testRej.setWorkitemId(testWorkItemId);
        
        
        // Process the rejection
        try{
            Approval.ProcessResult testRejResult =  Approval.process(testRej);
        } Catch(Exception e){
        }
        Test.stopTest();
        
        // Verify the rejection results
        //System.assert(testRejResult.isSuccess(), 'Rejections that include comments should be permitted');
        //System.assertEquals('Rejected', testRejResult.getInstanceStatus(), 
        //'Rejections that include comments should be successful and instance status should be Rejected');
    }
    
    private static Id CreateAndSubmitOrder()
    {
        // Create a Order record and then submit it for approval.
        Account Act = TestDataUtility.getAccount();
        Act.Industry = 'Agriculture';
        INSERT Act;
        Contact Cont=CreateTestData.getContact(Act.id);
        Opportunity Opty=CreateTestData.getOpportunity(Act.id,Cont.id);
        
        
        Contract Contr=CreateTestData.getContract(Act.id,Opty.id);
        Order Ord=new order();
        Ord.AccountId=Act.id;
        Ord.ContractId=Contr.id;
        Ord.Order_Year__c = 1;
        Ord.Booked_Elsewhere__c = False;
        Ord.EffectiveDate=date.today();
        Ord.Submission_Offset__c = -18000000;
        //Ord.ActivatedDate =date.today();
        Ord.Activation_Offset__c = -18000000;
        Ord.Status='Draft';
        Ord.Pricebook2Id = '01s2000000000vQAAQ';
        Ord.Rejection_Reason__c='Rejecting request with a comment.';
        insert Ord;
        BillToContactChangeController.updateBillToContact(ord.id,cont.id); 
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = cont.id;
        invoiceHeader.Account__c = cont.AccountId;
        invoiceHeader.Contract__c = Contr.id;
        invoiceHeader.CurrencyIsoCode = Contr.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = Act.BU__c;
        invoiceHeader.Order__c=Ord.id;
        invoiceHeader.Invoice_Status__c='Sun Order Complete';
        insert invoiceHeader;
        try{
            Ord.Status ='Activated';
            
            update Ord;
        }
        Catch(Exception e){
        }
        try{
            Ord.Status = 'Cancelled';
            
            update Ord;
        }
        Catch(Exception e){
            
        }
        
        Product2 Prod = new Product2(Name = 'test product 1',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes',Status__c = 'Revenue Ready');
        insert prod;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod.id,UnitPrice = 100,IsActive=true);
        insert pbe1;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = Ord.id;
        oi.Quantity = 1;
        oi.UnitPrice = 100;
        oi.PricebookEntryId = pbe1.id;
        oi.Platform__c = 'MFS';
        insert oi;
        
        OrderItem oi2 = new OrderItem();
        oi2.OrderId = Ord.id;
        oi2.Quantity = 1;
        oi2.UnitPrice = 100;
        oi2.PricebookEntryId = pbe1.id;
        oi2.Platform__c = 'MFS';
        oi2.Package__c = 'Graduate Essential';
        oi2.Proposition__c = 'Graduate Hiring';
        oi2.Renewable__c = 'One-off';
        insert oi2;
        
        OrderTriggerManager.getOrder(Ord.id);
        OrderTriggerManager.ChkOrderProd(Ord.Id);
        
        
        Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
        testReq.setObjectId(Ord.Id);
        Approval.ProcessResult reqResult = Approval.process(testReq);
        
        System.assert(reqResult.isSuccess(),'Unable to submit new invoice statement record for approval');
        
        return reqResult.getNewWorkitemIds()[0];
    }
    static testmethod void CreateGCSCOrder()
    {
        // Create a Order record and then submit it for approval.
        Account Act = TestDataUtility.getAccount();
        Act.Industry = 'Agriculture';
        INSERT Act;
        Contact Cont=CreateTestData.getContact(Act.id);
        Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=Act.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire'); //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR' // SSE-10872
        opportunity2.ownerid=UserInfo.getUserId();
        opportunity2.StageName='Verbal';
        opportunity2.Billing_Contact__c=Cont.id;
        opportunity2.Closedate=system.today();
        opportunity2.Primary_Contact__c=Cont.id;
        //opportunity2.pricebook2id=PR2.id;
        opportunity2.CurrencyIsoCode='AUD';
        //opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity2.NVM_Credit_Card_ID__c='1234';
        opportunity2.Amount=1000;
        
        opportunity2.Variation_Opportunity__c='NO';
        opportunity2.OppUpdatedByOrderOn__c=Date.today();
        opportunity2.Original_Opportunity__c=null;
        opportunity2.Annual_Contract_Value__c=1000.00;
        opportunity2.Business_Type__c='Renewal';
        opportunity2.CurrencyISOCode='GBP';
        opportunity2.GCSC__c='Phone';        
        opportunity2.RecordTypeID=System.label.GCSCRecordType;
        opportunity2.Forecast_Category__c='Pipeline'; 
        opportunity2.Offering__c = 'OPQ' ;   
        insert opportunity2;
        
        
        
        //Contract Contr=CreateTestData.getContract(Act.id,Opty.id);
        Order Ord=new order();
        Ord.AccountId=Act.id;
        //Ord.ContractId=Contr.id;
        Ord.OpportunityId = opportunity2.id;
        Ord.Order_Year__c = 1;
        Ord.Booked_Elsewhere__c = False;
        ord.RecordTypeId = '0124G000000Bj14QAC';
        Ord.EffectiveDate=date.today();
        Ord.Submission_Offset__c = -18000000;
        //Ord.ActivatedDate =date.today();
        Ord.Activation_Offset__c = -18000000;
        Ord.Status='Draft';
        Ord.Pricebook2Id = '01s2000000000vQAAQ';
        Ord.Rejection_Reason__c='Rejecting request with a comment.';
        insert Ord;
        
        Order Ord2=new order();
        Ord2.AccountId=Act.id;
        //Ord.ContractId=Contr.id;
        Ord2.OpportunityId = opportunity2.id;
        Ord2.Order_Year__c = 1;
        Ord2.Booked_Elsewhere__c = False;
        ord2.RecordTypeId = '0124G000000Bj14QAC';
        Ord2.EffectiveDate=date.today();
        Ord2.Submission_Offset__c = -18000000;
        //Ord.ActivatedDate =date.today();
        Ord2.Activation_Offset__c = -18000000;
        Ord2.Status='Draft';
        Ord2.Pricebook2Id = '01s2000000000vQAAQ';
        Ord2.Rejection_Reason__c='Rejecting request with a comment.';
        Ord2.Reduction_Order__c=True;
        Ord2.Original_Order__c=Ord.id;
        insert Ord2;
        
        
        
        Product2 Prod = new Product2(Name = 'test product 1',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes',Status__c = 'Revenue Ready');
        insert prod;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod.id,UnitPrice = 100,IsActive=true);
        insert pbe1;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = Ord.id;
        oi.Quantity = 1;
        oi.UnitPrice = 100;
        oi.PricebookEntryId = pbe1.id;
        oi.Platform__c = 'MFS';
        insert oi;
        
        OrderItem oi2 = new OrderItem();
        oi2.OrderId = Ord.id;
        oi2.Quantity = 1;
        oi2.UnitPrice = 100;
        oi2.PricebookEntryId = pbe1.id;
        oi2.Platform__c = 'MFS';
        oi2.Package__c = 'Graduate Essential';
        oi2.Proposition__c = 'Graduate Hiring';
        oi2.Renewable__c = 'One-off';
        insert oi2;
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = cont.id;
        invoiceHeader.Account__c = cont.AccountId;
        //invoiceHeader.Contract__c = Contr.id;
        invoiceHeader.CurrencyIsoCode = opportunity2.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = Act.BU__c;
        invoiceHeader.Order__c=Ord.id;
        invoiceHeader.Invoice_Status__c='Sun Order Complete';
        insert invoiceHeader;
        try{
            Ord.Status ='Activated';
            
            update Ord;
        }
        Catch(Exception e){
        }
        try{
            Ord.Status = 'Cancelled';
            
            update Ord;
        }
        Catch(Exception e){
            
        }
    }
    
    static testmethod void CancelGCSCOrder()
    {
     Account Act = TestDataUtility.getAccount();
        Act.Industry = 'Agriculture';
        INSERT Act;
        Contact Cont=CreateTestData.getContact(Act.id);
        Opportunity Opty=CreateTestData.getOpportunity(Act.id,Cont.id);
        
        
        Contract Contr=CreateTestData.getContract(Act.id,Opty.id);
        Order Ord=new order();
        Ord.AccountId=Act.id;
        Ord.ContractId=Contr.id;
        Ord.Order_Year__c = 1;
        Ord.Booked_Elsewhere__c = False;
        Ord.EffectiveDate=date.today();
        Ord.Submission_Offset__c = -18000000;
        //Ord.ActivatedDate =date.today();
        Ord.Activation_Offset__c = -18000000;
        Ord.Status='Draft';
        Ord.Pricebook2Id = '01s2000000000vQAAQ';
        Ord.Rejection_Reason__c='Rejecting request with a comment.';
        insert Ord;
        
        
        Product2 Prod = new Product2(Name = 'test product 1',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes',Status__c = 'Revenue Ready');
        insert prod;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod.id,UnitPrice = 100,IsActive=true);
        insert pbe1;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = Ord.id;
        oi.Quantity = 1;
        oi.UnitPrice = 100;
        oi.PricebookEntryId = pbe1.id;
        oi.Platform__c = 'MFS';
        insert oi;
        
        OrderItem oi2 = new OrderItem();
        oi2.OrderId = Ord.id;
        oi2.Quantity = 1;
        oi2.UnitPrice = 100;
        oi2.PricebookEntryId = pbe1.id;
        oi2.Platform__c = 'MFS';
        oi2.Package__c = 'Graduate Essential';
        oi2.Proposition__c = 'Graduate Hiring';
        oi2.Renewable__c = 'One-off';
        insert oi2;
     
        Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
        testReq.setObjectId(Ord.Id);
        Approval.ProcessResult reqResult = Approval.process(testReq);
        
        
        
        
        //ord.status = 'cancelled';
        //update ord;
        RecallCancelledOrders.recallOrders(new list<order>{ord});
        
        
    }
 /*       static testmethod void CreateGCSCReductionOrder()
    {
        // Create a Order record and then submit it for approval.
        Account Act=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert Act;
        Contact Cont=CreateTestData.getContact(Act.id);
        Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=Act.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire'); //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR' // SSE-10872
        opportunity2.ownerid=UserInfo.getUserId();
        opportunity2.StageName='Verbal';
        opportunity2.Billing_Contact__c=Cont.id;
        opportunity2.Closedate=system.today();
        opportunity2.Primary_Contact__c=Cont.id;
        //opportunity2.pricebook2id=PR2.id;
        opportunity2.CurrencyIsoCode='AUD';
        //opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity2.NVM_Credit_Card_ID__c='1234';
        opportunity2.Amount=1000;
        
        opportunity2.Variation_Opportunity__c='NO';
        opportunity2.OppUpdatedByOrderOn__c=Date.today();
        opportunity2.Original_Opportunity__c=null;
        opportunity2.Annual_Contract_Value__c=1000.00;
        opportunity2.Business_Type__c='New customer: subscription';
        opportunity2.CurrencyISOCode='GBP';
        opportunity2.GCSC__c='Phone';        
        opportunity2.RecordTypeID=System.label.GCSCRecordType;
        opportunity2.Forecast_Category__c='Forecast'; 
        opportunity2.Offering__c = 'OPQ' ;   
        insert opportunity2;
        
        
        
        //Contract Contr=CreateTestData.getContract(Act.id,Opty.id);
        Order Ord=new order();
        Ord.AccountId=Act.id;
        //Ord.ContractId=Contr.id;
        Ord.OpportunityId = opportunity2.id;
        Ord.Order_Year__c = 1;
        Ord.Booked_Elsewhere__c = False;
        ord.RecordTypeId = '0124G000000Bj14QAC';
        Ord.EffectiveDate=date.today();
        Ord.Submission_Offset__c = -18000000;
        //Ord.ActivatedDate =date.today();
        Ord.Activation_Offset__c = -18000000;
        Ord.Status='Draft';
        Ord.Pricebook2Id = '01s2000000000vQAAQ';
        Ord.Rejection_Reason__c='Rejecting request with a comment.';
        Ord.Reduction_Order__c=True;
        insert Ord;
        
        Product2 Prod = new Product2(Name = 'test product 1',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes');
        insert prod;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod.id,UnitPrice = 100,IsActive=true);
        insert pbe1;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = Ord.id;
        oi.Quantity = 1;
        oi.UnitPrice = 100;
        oi.PricebookEntryId = pbe1.id;
        oi.Platform__c = 'MFS';
        insert oi;
        
        OrderItem oi2 = new OrderItem();
        oi2.OrderId = Ord.id;
        oi2.Quantity = 1;
        oi2.UnitPrice = 100;
        oi2.PricebookEntryId = pbe1.id;
        oi2.Platform__c = 'MFS';
        oi2.Package__c = 'Graduate Essential';
        oi2.Proposition__c = 'Graduate Hiring';
        oi2.Renewable__c = 'One-off';
        insert oi2;
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = cont.id;
        invoiceHeader.Account__c = cont.AccountId;
        //invoiceHeader.Contract__c = Contr.id;
        invoiceHeader.CurrencyIsoCode = opportunity2.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = Act.BU__c;
        invoiceHeader.Order__c=Ord.id;
        invoiceHeader.Invoice_Status__c='Sun Order Complete';
        insert invoiceHeader;
        try{
            Ord.Status ='Activated';
            
            update Ord;
        }
        Catch(Exception e){
        }
        try{
            Ord.Status = 'Cancelled';
            
            update Ord;
        }
        Catch(Exception e){
            
        }
        
        
        
        
    } */
    
    @isTest
    public static void blankOutBillingFrequenciesForExtension()
    {
        Account Act = TestDataUtility.getAccount();
        Act.Industry = 'Agriculture';
        INSERT Act;
        Contact Cont=CreateTestData.getContact(Act.id);
        
        Opportunity Opty = TestDataUtility.getOpportunity(Act.id, Cont.id);
        Opty.Business_Type__c = 'Extension';
        Opty.Custom_Contract_Duration__c = 2;
        Opty.Standard_Contract_Duration__c = 'Other';
        INSERT Opty;
        
        Contract contractRecord = TestDataUtility.getContract(Act.id, Opty.id);
        contractRecord.Subscription_Start_Date__c = date.today();
        contractRecord.Contract_End_Date__c = date.today()+365;
        contractRecord.Client_Display__c = 'Summary Pricing';
        INSERT contractRecord; 
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Order orderRecord = TestDataUtility.getOrder(contractRecord.id, Act.id);
        orderRecord.Booked_Elsewhere__c = False;
        orderRecord.EffectiveDate = date.today();
        orderRecord.Submission_Offset__c = -18000000;
        orderRecord.Activation_Offset__c = -18000000;
        orderRecord.Pricebook2Id = pricebookId;
        orderRecord.opportunityId = Opty.Id;
        
        Test.startTest();
        INSERT orderRecord;
        Test.stopTest();
        
    }
    
    @isTest
    public static void restrictDeleteForOATS()
    {
        Account Act = TestDataUtility.getAccount();
        Act.Industry = 'Agriculture';
        INSERT Act;
        Contact Cont=CreateTestData.getContact(Act.id);
        
        Opportunity Opty = TestDataUtility.getOpportunity(Act.id, Cont.id);
        Opty.Business_Type__c = 'Extension';
        Opty.Custom_Contract_Duration__c = 2;
        Opty.Standard_Contract_Duration__c = 'Other';
        INSERT Opty;
        
        Contract contractRecord = TestDataUtility.getContract(Act.id, Opty.id);
        contractRecord.Subscription_Start_Date__c = date.today();
        contractRecord.Contract_End_Date__c = date.today()+365;
        contractRecord.Client_Display__c = 'Summary Pricing';
        INSERT contractRecord; 
        
        Id pricebookId = Test.getStandardPricebookId();
        User userRecord = TestDataUtility.getUser('OAT');
        
        User usr = [SELECT Id FROM User Where isActive = true AND Profile.Name = 'Finance' LIMIT 1];
        Order orderRecord = TestDataUtility.getOrder(contractRecord.id, Act.id);
        orderRecord.Booked_Elsewhere__c = False;
        orderRecord.EffectiveDate = date.today();
        orderRecord.Submission_Offset__c = -18000000;
        orderRecord.Activation_Offset__c = -18000000;
        orderRecord.Pricebook2Id = pricebookId;
        orderRecord.opportunityId = Opty.Id;
        INSERT orderRecord;	
        
        Test.startTest();
        DELETE orderRecord;
        Test.stopTest();
        
    }
}
@isTest
public class GetRejectedOrdersTestClass {

 @isTest(seealldata=true)
    static void TestgetOrders()
    {
       /*Account account=new Account(currencyisocode = 'AUD',name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert account;
      Contact contact = CreateTestData.getContact(account.id);
      Opportunity opportunity=CreateTestData.getOpportunity(account.id,contact.id);
      Contract contract= CreateTestData.getContract(account.id,opportunity.id);
      Order order = CreateTestData.getOrder(contract.id,account.id);
      order.oats_status__c = 'Rejected';
      order.Rejection_Reason__c = 'Reject for Test';
      update order; */
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Commercial' limit 1];
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
       Account Act=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert Act;
        Contact Cont=CreateTestData.getContact(Act.id);
        Opportunity Opty=CreateTestData.getOpportunity(Act.id,Cont.id);
        Opty.pricebook2id='01s2000000000vQAAQ';
        Opty.StageName='New';
        opty.Offering__c='OPQ';
        opty.Skip_Validation__c =True;
        update opty;
        Contract Contr=CreateTestData.getContract(Act.id,Opty.id);
        Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
        Order Ord=new order();
        Ord.AccountId=Act.id;
        Ord.ContractId=Contr.id;
        Ord.EffectiveDate=date.today();
        Ord.Status='Draft';
        Ord.Oats_Status__c='Rejected';
        ord.Opportunityid = Opty.id;
        ord.OwnerId = user.id;
        Ord.Rejection_Reason__c='Rejecting request with a comment.';
        Ord.Order_Year__c =1;
        Ord.Pricebook2Id = pbook.id;
        Ord.Rejection_Reason__c='Rejecting request with a comment.';
        System.runAs(user){
        insert Ord;
        }
        /*list<Product2> prodlist = new list <Product2>();
        Product2 Prod = new Product2(Name = 'test product 1',IsActive=true,Revenue_Category__c='Subscription',Renewable__c = 'Yes');
        prodlist.add(prod);
        insert prodlist;
        
        list<PricebookEntry> pbelist = new list<PricebookEntry>();
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = '01s2000000000vQAAQ',Product2Id = prod.id,UnitPrice = 100,IsActive=true);
        pbelist.add(pbe1);
        insert pbelist;
        
        list<OpportunityLineItem> OLIlist = new list<OpportunityLineItem>();
        OpportunityLineItem LI1=new OpportunityLineItem(Solution_Cap__c = 1,RenewableNew__c = 'Ongoing',OpportunityId=Opty.id,PricebookEntryId=pbe1.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Graduate Advanced');
        OLIlist.add(LI1);
                insert OLIlist;
        
        List<OrderItem> OrderItemList = new list<OrderItem>();
        Set<id> orderitemid = new Set<id>();
        for(OpportunityLineItem oli : OLIlist ){
            OrderItem oi = new OrderItem();
            oi.OrderId = Ord.id;
            oi.Quantity = oli.Quantity;
            oi.UnitPrice = oli.List_Price__c;
            oi.PricebookEntryId = oli.PricebookEntryId;
            oi.Platform__c = 'MFS';
            OrderItemList.add(oi);
        }
               
        insert OrderItemList;
       
        update Ord;*/
         Boolean UserIsValid = GetRejectedOrders.UserVerification(Opty.id);
         List<Order> rejectedorders= GetRejectedOrders.getOrders(Opty.id);
         Boolean checkopp = GetRejectedOrders.UpdateAllowClosed(Opty.id);
        System.runAs(user){
            UserIsValid = GetRejectedOrders.UserVerification(Opty.id);
        }    
              
        Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
        testReq.setObjectId(Ord.Id);
        Approval.ProcessResult reqResult = Approval.process(testReq);
        
        System.assert(reqResult.isSuccess(),'Unable to submit new invoice statement record for approval');
        
     
      Test.startTest(); 
        Id rejectedorderid = reqResult.getNewWorkitemIds()[0];
        Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
        testRej.setComments('Rejecting request with a comment.');
        testRej.setAction  ('Reject');
        testRej.setWorkitemId(rejectedorderid);
         
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
       
        /*Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = cont.id;
        invoiceHeader.Account__c = cont.AccountId;
        invoiceHeader.Contract__c = Contr.id;
        invoiceHeader.CurrencyIsoCode = Contr.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = Act.BU__c;
        invoiceHeader.Order__c=Ord.id;
        invoiceHeader.Invoice_Status__c='Draft';
        insert invoiceHeader;
        try{
            Ord.Status ='Activated';
            update Ord;
            }
        Catch(Exception e){
        }   
        
        OrderTriggerManager.getOrder(Ord.id); */
         Account Act=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert Act;
        Contact Cont=CreateTestData.getContact(Act.id);
        Opportunity Opty=CreateTestData.getOpportunity(Act.id,Cont.id);
        Contract Contr=CreateTestData.getContract(Act.id,Opty.id);
        Order Ord=new order();
        Ord.AccountId=Act.id;
        Ord.ContractId=Contr.id;
        Ord.EffectiveDate=date.today();
        Ord.Status='Draft';
        //Ord.Rejection_Reason__c='Rejecting request with a comment.';
        Ord.Order_Year__c =1;
        insert Ord;
        Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
        testReq.setObjectId(Ord.Id);
        Approval.ProcessResult reqResult = Approval.process(testReq);
        
        System.assert(reqResult.isSuccess(),'Unable to submit new invoice statement record for approval');
        
         List<Order> rejectedorders= GetRejectedOrders.getOrders(Opty.id);
      Boolean checkopp = GetRejectedOrders.UpdateAllowClosed(Opty.id);
      
      //Boolean checkcontract = GetRejectedOrders.UpdateAllowClosed(Contr.id);
        
        return reqResult.getNewWorkitemIds()[0];
    }
      
      
      
    
}
@isTest(seeAllData=true)
public class CloseOpportunitiesOnAccountSanctionTest {

    
    @isTest
    static void testSanction(){
        Account Act = TestDataUtility.getAccount();
        Act.Industry = 'Agriculture';
        INSERT Act;
        Contact Cont=CreateTestData.getContact(Act.id);
        Opportunity OptyOpen=CreateTestData.getOpportunity(Act.id,Cont.id);
        Opportunity Opty=CreateTestData.getOpportunity(Act.id,Cont.id);
        
        Opty.StageName = 'Closed/Won';
        
        update Opty;
        
        
        Contract Contr=CreateTestData.getContract(Act.id,Opty.id);
        Order Ord=new order();
        Ord.OpportunityId = Opty.Id;
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
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
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
        
        test.startTest();
        
        List<CloseOpportunitiesOnAccountSanction.InputParameters> inpList = new List<CloseOpportunitiesOnAccountSanction.InputParameters>();
        CloseOpportunitiesOnAccountSanction.InputParameters inp = new CloseOpportunitiesOnAccountSanction.InputParameters();
                
        inp.accountId = Act.Id;
        inpList.add(inp);

        
        CloseOpportunitiesOnAccountSanction.closeLostRelatedOpportunities(inpList);
        AccountSanctionNotificationController.sendNotification(new List<Id>{Act.Id});
        
        test.stopTest();
        
    }
}
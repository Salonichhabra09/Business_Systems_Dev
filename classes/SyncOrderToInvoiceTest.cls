@isTest
public class SyncOrderToInvoiceTest{

 @isTest(seealldata=true)    
static void TestSyncingofDates(){
    
    Account Act=new Account(name='Test Account',Industry = 'Agriculture', Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert Act;
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
            Ord.Activation_Offset__c = -18000000;
            Ord.Status='Draft';
            Ord.Pricebook2Id = '01s2000000000vQAAQ';
            Ord.Rejection_Reason__c='Rejecting request with a comment.';
        insert Ord;
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
            invoiceHeader.Billing_Contact__c = cont.id;
            invoiceHeader.Account__c = Act.Id;
            invoiceHeader.Contract__c = Contr.id;
            invoiceHeader.CurrencyIsoCode = Contr.CurrencyIsoCode;
            invoiceHeader.Service_Start_Date__c = System.today();
            invoiceHeader.PO_number__c = '12312323423';
            invoiceHeader.BU__c = Act.BU__c;
            invoiceHeader.Order__c=Ord.id;
            invoiceHeader.Invoice_Status__c='Draft';
            invoiceHeader.Is_Auto_Created__c=true;
            invoiceHeader.Service_Start_Date__c= System.today();
            invoiceHeader.Service_End_Date__c = System.today()+20;
        insert invoiceHeader;
        
        Ord.EffectiveDate=date.today()+3;
        update Ord;    
    
    }
}
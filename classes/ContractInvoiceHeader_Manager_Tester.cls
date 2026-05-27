@istest(seealldata=true)
public class ContractInvoiceHeader_Manager_Tester {

    public static testmethod void testContractInvoiceHeader_Manager()
    {
        test.startTest();
        Contact contact = [Select id ,AccountId,Account.CurrencyIsoCode , BU__c from Contact where AccountId!=null limit 1];
        //Contract contract = [Select id from Contract where AccountId = :contact.AccountId limit 1];
        Opportunity opp =  CreateTestData.getOpportunity(contact.AccountId , contact.id);
        Contract contract = new Contract();
        contract.AccountId = contact.AccountId;
        contract.CurrencyIsoCode = contact.Account.CurrencyIsoCode;
        contract.Status = 'Draft';
        contract.CustomerSignedDate = System.today();
        contract.StartDate = System.today();
        contract.ContractTerm = 5;
        contract.Legal_Order_Name__c='test';
        contract.S2P_Reference_Required__c = 'New';
        contract.Invoicing_Contact__c = contact.id;
        contract.Opportunity__c = opp.id;
        insert contract;
        system.debug('contract.BU_From_Account__c' + contract.BU_From_Account__c);
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();
        invoiceHeader.Billing_Contact__c = contact.id;
        invoiceHeader.Account__c = contact.AccountId;
        invoiceHeader.Contract__c = contract.id;
        invoiceHeader.CurrencyIsoCode = contract.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = System.today();
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.BU__c = contact.BU__c;
        insert invoiceHeader;
        //List<Contract_Invoice_Header__c> invoiceHeaderList = [Select id,Contract__r.id from Contract_Invoice_Header__c where limit 1];
        List<Contract_Line__c> contractLine = [Select id from Contract_Line__c limit 1];
        Contract_Invoice_Line__c invoiceLine = new Contract_Invoice_Line__c();
        invoiceLine.Invoice_Header_ID__c = invoiceHeader.id;
        invoiceLine.CurrencyIsoCode = invoiceHeader.CurrencyIsoCode;
        invoiceLine.Contract_Line_ID__c = contractLine[0].id;
        invoiceLine.Month__c = '201111';
        invoiceLine.Discount_Amount__c = 1;
        invoiceLine.Quantity__c = 10;
        invoiceLine.Price__c=100;
        invoiceLine.Invoice_Line_Total__c=1000;
        insert invoiceLine;
        ContractInvoiceHeader_Manager.superClone(invoiceHeader.id);
        test.stopTest();
    }
}
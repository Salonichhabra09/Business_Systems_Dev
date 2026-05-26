@istest
public class ReductionOrderCreationOpptyClsTest {
    @istest(seealldata = true)
    public static void ReductionOrderCreationOpptyClsTestMethod(){
        Account acc=new Account(currencyisocode = 'AUD',name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con=new Contact(lastname='Test Contact', Accountid=acc.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert con;
        
        Contract contract = new Contract();
        contract.AccountId = acc.Id;   
        contract.CurrencyIsoCode = acc.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;  
        contract.Legal_Order_Name__c='test';
        contract.Subscription_Start_Date__c = system.today();
        insert contract;
        string contractnumber = [select ContractNumber from contract where id = :contract.id].ContractNumber;
        
        Opportunity opp=new Opportunity(name='Test Opportunity', AccountID=acc.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire');
        opp.ownerid=UserInfo.getUserId();
        opp.StageName='Draft';
        opp.Billing_Contact__c=con.id;
        opp.Closedate=system.today();
        opp.Primary_Contact__c=con.id;
        opp.pricebook2id='01s2000000000vQAAQ';
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
        opp.Forecast_Category__c='Forecast';
        opp.Multi_YearDeal__c='3';
        opp.ContractId = contract.id;
        insert opp;
        
        Order ord = new Order();
                  Id orderrt = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Standard Order').getRecordTypeId();

        ord.Accountid = acc.id;
        ord.ContractId = contract.id;
        ord.name = 'test';
        //ord.RecordTypeId = '0127E0000032wq7';
        ord.Status = 'Draft';
        ord.RecordTypeId = orderrt;
        ord.EffectiveDate = system.today();
        ord.CurrencyIsoCode = contract.CurrencyIsoCode;
        ord.Pricebook2Id = '01s2000000000vQAAQ';
        ord.Reduction_Order__c = false;
        //ord.quantity = 1;
        //ord.UnitPrice = 1000;
        insert ord;
        
        PageReference pageRef = Page.ReductionOrderCreationOpportunity;
            //pageRef.getParameters().put('Project', project.id);
            //pageRef.getParameters().put('Contract', contractnumber);
            Test.setCurrentPage(pageRef);
            //apexpage.standardcontroller std = new apexpages.StandardController(opp);
            ReductionOrderCreationOpptyCls controller = new ReductionOrderCreationOpptyCls(new ApexPages.StandardController(opp));
            controller.getCloseWindow();
    }
}
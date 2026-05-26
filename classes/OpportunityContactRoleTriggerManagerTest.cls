@isTest
public class OpportunityContactRoleTriggerManagerTest {
    @istest(seealldata=true)
    public static void TestOpportunityContactRoleTriggerManager(){
        Account account = createtestdata.GetAccount();
        Contact contact = createtestdata.getContact(account.Id);
        Opportunity opp = createtestdata.getOpportunity(account.Id, contact.Id);
     OpportunityContactRole ocr = new OpportunityContactRole ();
                ocr.ContactId = contact.Id;
                ocr.OpportunityId=opp.Id;
                ocr.role='Decision Maker / Billing Contact';
                ocr.IsPrimary=false;
                Insert ocr;
        ocr.role = 'Billing Contact';
        ocr.IsPrimary=true;
        update ocr;
        try{
           delete ocr; 
        }
        catch(Exception e){
            
        }
        
    }
    @istest(seealldata=true)
    public static void TestOpptyTriggers(){
        Test.startTest();
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='OAT' limit 1];
        
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
        User Adminuser = [Select id from user where ProfileId = '00e20000000gzoS' AND isActive=true limit 1];
        Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert account;
        
        Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
        
        insert contact;
        Contact contact2 = Createtestdata.getContact(account.id);
        Contact contact3 = Createtestdata.getContact(account.id);
        Contract contract2=new Contract(Subscription_Start_Date__c=system.today(),name='Original Contract', Legal_Order_Name__c='test', CurrencyISOCode=account.CurrencyISOCode, AccountID=account.id);
        insert contract2;
        Opportunity opportunity2=new Opportunity(name='Test Opportunity', AccountID=account.id,Talent_Segment__c='Volume', TM_Phase__c='Post-Hire'); //,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Client_Business_Function__c='HR' // SSE-10872
        opportunity2.ownerid=UserInfo.getUserId();
        opportunity2.StageName='Verbal';
        opportunity2.Billing_Contact__c=contact2.id;
        opportunity2.Closedate=system.today();
        opportunity2.Primary_Contact__c=contact.id;
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
        
        
        Opportunity opp=new Opportunity();
        opp.name = 'test';
        opp.StageName = 'new';
        opp.Business_Type__c = 'New customer: subscription';
        opp.Forecast_Category__c = 'Forecast';
        opp.CloseDate = system.today();
        insert opp;
        opportunity opp2 = new opportunity();
        opp2.id = opp.id;
        opp2.Primary_Contact__c=contact2.id;
        opp2.Billing_Contact__c = contact3.Id;
        opp2.Offering__c = 'OPQ';
        opp2.StageName = 'Closed/Won';
        update opp2;  
        opp2.Billing_Contact__c = contact.Id;
        opp2.Primary_Contact__c=contact3.id;
        update opp2;
    test.stopTest();
    }
}
@isTest(seeAllData = true)
public class Import_RateCard_Ctr_Test {
    static String str ='OpportunityId,Discount Type,Level,Name,Discount Percentage,Discount Amount,Discount Applied on (DateFormat:  dd/mm/yyyy),Reason for the Discretionary Discount\n ABCD,Deal Length,1,Test2,2,11263,30/07/2018,End of month;End of quarter\n ABCD,Deal Length,1,Test2,2,11263,30/07-2018,End of month;End of quarter';
    //static String Id=[SELECT Id FROM PricebookEntry where  Pricebook2.Name = 'Ignite price book' limit 1].Id;
    public static String str2;
    public static String[] csvFileLines;
    public static Blob csvFileBody;
    public static String opptyName;
    public static String opptyId;
    public static String opptyStageName;
    public static String oppCurrency;
    public static set<string> HiringNeeds = new set<string>();
    
    static testmethod void testReadFileDiscountSum(){
        Datetime variable=System.now();
         String Testname='Test Account'+variable;
        Account account=new Account(name=Testname,Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry = 'Agriculture');
        insert account;
        
        Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
        insert contact;
        
        Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Standard Opportunity' limit 1];
        Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
        opportunity.ownerid=UserInfo.getUserId();
        opportunity.Billing_Contact__c=contact.id;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=contact.id;
        opportunity.CurrencyIsoCode='AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity.NVM_Credit_Card_ID__c='1234';
        opportunity.Amount=1000;
        opportunity.Variation_Opportunity__c='NO';
        opportunity.Original_Opportunity__c=null;
        opportunity.Annual_Contract_Value__c=1000.00;
        opportunity.StageName='New';   
        opportunity.GCSC__c='Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity.RecordTypeID=RT.id;
        opportunity.Skip_Validation__c=True;
        opportunity.Pricebook2Id=p.id;
        opportunity.TM_Phase__c='Mixed';
        opportunity.Package_Level__c='Basic';
        opportunity.Business_Type__c='Expansion';
        opportunity.Forecast_Category__c='Commit';
        
        insert opportunity;
        
        Test.startTest();
        PageReference pageRef = Page.ImportRateCard_VF; // Add your VF page Name here
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('oppId',String.valueOf(opportunity.id));
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n');
        Import_RateCard_Ctr importData = new Import_RateCard_Ctr();        
        importData.contentFile1 = csvFileBody;
        importData.ReadFileDiscountSum();
        Test.stopTest();
    } 
    
    static testmethod void testReadFileOppLineItems()
    {
        
        str2='PRICEBOOK ENTRY ID,Hiring Need,Talent Level,Package Level,List Price,Total Discount%(The values will be just numbers),Sales Price,Level,Basis of Fees,Usage Cap or Estimation,Volume,Start Date (dd/mm/yyyy),End Date (dd/mm/yyyy),Year 1 : List Price,Year 2 : List Price,Year 3 : List Price,Year 1 : Discount%,Year 2 : Discount%,Year 3 : Discount%,Year 1 : Sales Price,Year 2 : Sales Price,Year 3 : Sales Price\n 01u8E00000N9y8tQAB,Pre-Hire,Graduate,Premium,50486.79,700,46952.72,2,Candidate,225000,13,30/07/2018,30/07/2019,160917,0,0,7,0,0,149652.12,75719.12,77990.35\n 01u8E00000N9y8tQAB,Pre-Hire,Graduate,Premium,50486.79,700,46952.72,2,Candidate,225000,13,30/07/2018,30/07-2019,160917,0,0,7,0,0,149652.12,75719.12,77990.35';
         Datetime variable=System.now();
         String Testname='Test Account'+variable;
        Account account=new Account(name=Testname,Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry = 'Agriculture');
        insert account;
        
        Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
        insert contact;
        
        Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Standard Opportunity' limit 1];
        Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
        opportunity.ownerid=UserInfo.getUserId();
        opportunity.Billing_Contact__c=contact.id;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=contact.id;
        opportunity.CurrencyIsoCode='AED';
        opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity.NVM_Credit_Card_ID__c='1234';
        opportunity.Amount=1000;
        opportunity.Variation_Opportunity__c='NO';
        opportunity.Original_Opportunity__c=null;
        opportunity.Annual_Contract_Value__c=1000.00;
        opportunity.StageName='New';   
        opportunity.GCSC__c='Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity.RecordTypeID=RT.id;
        opportunity.Skip_Validation__c=True;
        opportunity.Pricebook2Id=p.id;
        opportunity.TM_Phase__c='Mixed';
        opportunity.Package_Level__c='Basic';
        opportunity.Business_Type__c='Expansion';
        opportunity.Forecast_Category__c='Commit';
        
        insert opportunity;
        
        Test.startTest();
        PageReference pageRef = Page.ImportRateCard_VF; // Add your VF page Name here
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('oppId',String.valueOf(opportunity.id));
        csvFileBody = Blob.valueOf(str2);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n');
        Import_RateCard_Ctr importData = new Import_RateCard_Ctr();        
        importData.contentFile = csvFileBody;
        importData.ReadFileOppLineItems();
        importData.UpdateOppClientNeeds();
        Test.stopTest();   
    }
    
    static testmethod void testRemainingMethods()
    {    Datetime variable=System.now();
         String Testname='Test Account'+variable;
        Account account=new Account(name=Testname,Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1', Industry = 'Agriculture');
     insert account;
     
     Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
     contact.Same_As_The_Account_Billing_Address__c=true;
     contact.Mailing_Address_Line_1__c ='test';
     contact.Mailing_City__c='test';
     contact.Mailing_ZIP_Postal_Code__c ='110094';
     contact.Mailing_Country__c='India';
     
     insert contact;
     
     Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
     RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Standard Opportunity' limit 1];
     Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
     opportunity.ownerid=UserInfo.getUserId();
     opportunity.Billing_Contact__c=contact.id;
     opportunity.Closedate=system.today();
     opportunity.Primary_Contact__c=contact.id;
     opportunity.CurrencyIsoCode='AUD';
     opportunity.Unconfirmed_Sun_Order_Number__c='1234';
     opportunity.NVM_Credit_Card_ID__c='1234';
     opportunity.Amount=1000;
     opportunity.Variation_Opportunity__c='NO';
     opportunity.Original_Opportunity__c=null;
     opportunity.Annual_Contract_Value__c=1000.00;
     opportunity.StageName='New';   
     opportunity.GCSC__c='Phone';
     opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
     opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
     opportunity.RecordTypeID=RT.id;
     opportunity.Skip_Validation__c=True;
     opportunity.Pricebook2Id=p.id;
     opportunity.TM_Phase__c='Mixed';
     opportunity.Package_Level__c='Basic';
     opportunity.Business_Type__c='Expansion';
     opportunity.Forecast_Category__c='Commit';
     //opportunity.Proposition__c='Graduate Hiring';
        
     insert opportunity;
     
     Test.startTest();
     str2='PRICEBOOK ENTRY ID,Hiring Need,Talent Level,Package Level,List Price,Total Discount%(The values will be just numbers),Sales Price,Level,Basis of Fees,Usage Cap or Estimation,Volume,Start Date (dd/mm/yyyy),End Date (dd/mm/yyyy),Year 1 : List Price,Year 2 : List Price,Year 3 : List Price,Year 1 : Discount%,Year 2 : Discount%,Year 3 : Discount%,Year 1 : Sales Price,Year 2 : Sales Price,Year 3 : Sales Price,Platform,Usage Allowance,Proposition\n 01u8E00000N9y8tQAB,Pre-Hire,Graduate,Premium,50486.79,700,46952.72,2,Candidate,225000,13,30/07/2018,30/07/2019,160917,0,0,7,0,0,149652.12,75719.12,77990.35,Brainbench,Uncapped,Graduate Hiring';
     PageReference pageRef = Page.ImportRateCard_VF; // Add your VF page Name here
     Test.setCurrentPage(pageRef);
     pageRef.getParameters().put('oppId',String.valueOf(opportunity.id));
     Import_RateCard_Ctr importData = new Import_RateCard_Ctr();
     csvFileBody = Blob.valueOf(str2);
     String inCharset='ISO 8859-1';
     Import_RateCard_Ctr.blobToString(csvFileBody,inCharset);
     String csvAsString = csvFileBody.toString();
     csvFileLines = csvAsString.split('\n');
     importData.contentFile = csvFileBody;
     importData.ReadFileOppLineItems();
     //importData.SaveRateCardAttachment();
     importData.UpdateOppClientNeeds();
     importData.DeleteRecordsOppLineItems();
     importData.DeleteRecordsDiscountSum();
     importData.cancel();
     
     Test.stopTest();
    }    
}
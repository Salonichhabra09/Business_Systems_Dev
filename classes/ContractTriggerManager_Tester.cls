@isTest(SeeAllData=true)

public class ContractTriggerManager_Tester{

    public static Contract getNewContract(){       
        Account account= new Account();     // insert account
        account.Name='Test234';
        account.BU__c='India - IN1';
        account.CurrencyIsoCode='GBP'; 
        account.Industry='Consulting';
        account.Billing_Address_Line_1__c='test23';
        account.Billing_City__c='test23';
        account.Same_As_The_Billing_Address__c=true;
        account.Billing_Country__c='test23';
        account.Billing_State__c='test23';
        account.Billing_ZIP_Postal_Code__c='test23';        
        insert account;
        
        Contact con = new Contact();
        con.AccountId=account.Id;
        con.LastName='test12345';
        con.email='test12345@test.com';
        con.phone='2345345345';
        con.Same_As_The_Account_Billing_Address__c=true;        
        insert con;
      
        Opportunity opportunity= new Opportunity();
        opportunity.OwnerId=UserInfo.getUserId();
        opportunity.Business_Type__c = 'NBB - New Logo';
        opportunity.AccountId=Account.Id;
        opportunity.Primary_Contact__c=con.Id;
        opportunity.name='Test Opportunity';
        opportunity.Forecast_Category__c = 'Forecast';
        opportunity.NVM_Credit_Card_ID__c='';
        opportunity.Unconfirmed_Sun_Order_Number__c='';
        opportunity.CurrencyISOCode='GBP';
        opportunity.StageName=System.Label.Opportunity_Stage_1;
        opportunity.closeDate=System.today();
        opportunity.Talent_Segment__c= 'Graduate / Apprentice';
 
        insert opportunity;
        
        Contract contract = new Contract();
        contract.AccountId = account.Id;  
        contract.Legal_Order_Name__c = 'test'; 
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;          
        contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract.Submission_Offset__c = 10;
        contract.Agreement__c = 'Order';       
        contract.Opportunity__c = opportunity.id; 
        insert contract;
        
        Case case1 = new case(AccountId=Account.id,ContactId=Con.Id,Problem2__c='Login Issue',Solution__c='other',Order__c = contract.id);  
        insert case1;
                 
        return contract;       
    } 
    public static testmethod void Contract_BeforeDelete (){
        Contract contract=getNewContract(); 
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        User u = new user();
        u.LastName = 'Test Code1806190';
        u.Email = 'test@testCode1806190.com';
        u.Alias = 'Tcode';
        u.Username = 'test1234444Code1806190@test.com';        
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileId = profileId.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
              
        system.runAs(u){
           try{
            test.starttest();
            delete contract;
             test.stoptest();
           }
           catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;            
            System.AssertEquals(expectedExceptionThrown, true);
           } 
        }
    } 
     public static testmethod void Contract_StatusUpdate1 (){
        Contract contract=getNewContract(); 
        contract.Status = 'Booked elsewhere complete';
        test.starttest();
            update contract;
        test.stoptest();           
    } 
    public static testmethod void StatusContract_Update2 (){
        Contract contract=getNewContract();         
        contract.Status = 'Order - Cancelled';
        contract.Activated_Date__c = datetime.now();
        contract.ActivatedDate = datetime.now();      
        contract.CurrencyIsoCode = 'INR';
        contract.Last_Possible_Submission_Date_Daylight__c = datetime.now()-120;
        
        Contract_Line__c contractLine = new Contract_Line__c();
        contractLine.Contract__c = contract.Id;     
        contractLine.IM_Lookup_Code__c = 'Consulting';
        contractLine.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
        contractLine.PO_number__c = '12312323423';      
        insert contractLine;
        test.starttest();
            update contract;
        test.stoptest();           
    } 
    public static testmethod void Contract_StatusUpdate3 (){
        Contract contract=getNewContract(); 
        contract.Status = 'Rejected';
        test.starttest();
            update contract;
        test.stoptest();           
    } 
    public static testmethod void Contract_StatusUpdate4 (){
        Contract contract=getNewContract(); 
        Contract_Line__c contractLine = new Contract_Line__c();
        contractLine.Contract__c = contract.Id;     
        contractLine.IM_Lookup_Code__c = 'Consulting';
        contractLine.Source_of_PS_Scoping__c= 'E2E Scoping Tool';
        contractLine.PO_number__c = '12312323423';      
        insert contractLine;
        
       /* Opportunity opp = [Select id,CurrencyIsoCode from Opportunity where id =: contract.Opportunity__c];
        opp.CurrencyIsoCode = 'INR';
        update opp;
        */
        
        contract.Status = 'Queried';
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Commercial' LIMIT 1];
        User u = new user();
        u.LastName = 'Test Code1806190';
        u.Email = 'test@testCode1806190.com';
        u.Alias = 'Tcode';
        u.Username = 'test1234444Code1806190@test.com';        
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileId = profileId.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        
        system.runAs(u){
           try{
            test.starttest();
              update contract;
              contract.Booked_Elsewhere__c = false;
              contract.Opportunity__r.RecordTypeId = System.Label.IgniteRecordType;
              update contract;
            test.stoptest();
           }
           catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;            
            System.AssertEquals(expectedExceptionThrown, true);
           } 
        }
                   
    } 
    
    
}
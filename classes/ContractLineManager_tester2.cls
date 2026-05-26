@isTest(SeeAllData=true)
public class ContractLineManager_tester2 {
    public static Account account;
    public static List<Contact> contacts;
    public static Contract getNewContract()
    {
        Contract contract = new Contract();
        Account a = new Account();
        Schema.sObjectType t = a.getSObjectType();
        List<account> a1 = Test.loadData(t, 'AccountTestData');
        //Get first test account
        account = (Account)a1[2];
        Contact contact = new Contact(AccountId=account.Id,LastName='test12345',email='test12345@test.com',phone='2345345345',Same_As_The_Account_Billing_Address__c=true);
        contacts = new List<Contact>();
        contacts.add(contact);
        insert contacts;
        Opportunity opportunity= new Opportunity(OwnerId=UserInfo.getUserId(),Business_Type__c = 'NBB - New Logo',
                                                 AccountId=Account.Id,Billing_Contact__c=Contact.Id,Primary_Contact__c=Contact.Id,
                                                 name='Test Opportunity',Forecast_Category__c = 'Forecast', NVM_Credit_Card_ID__c='',
                                                 Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP', Renewal_Date__c=Date.today(),
                                                 StageName=System.Label.Opportunity_Stage_1,closeDate=System.today(),
                                                 Order_number__c=contract.Id,Talent_Level__c='Leader' , 
                                                 Talent_Segment__c= 'Graduate / Apprentice' , Client_Business_Function__c= 'Finance');
       	insert opportunity;
        contract.AccountId = account.Id;  
        contract.Legal_Order_Name__c = 'test'; 
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
       	contract.Renewal_Date__c = Date.Today();
        contract.ContractTerm = 6;   
        contract.Activated_Date__c=datetime.now();
        contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract.Submission_Offset__c = 10;
        contract.Agreement__c = 'Order';
        contract.Renewal_Opportunity__c=opportunity.id;
        contract.Days_remaining_from_annual_subscription__c = 5;
        
        insert contract;
        
        
        opportunity opportunity1=[select Business_Type__c,Renewal_Opportunity__c from opportunity where id=:opportunity.id];
        opportunity1.Business_Type__c = 'Renewal';
        opportunity1.Renewal_Opportunity__c = true;
      	update opportunity1;
        contract.Opportunity__c = opportunity.id;
        contract.Renewal_Date__c = Date.Today();
        contract.Status = 'Draft';
        update contract;

        return contract; 
    } 
    
     
    public static testmethod void ContractLineManager1()
    {
        
        //Boolean IMLookupcheck;
        Contract contract=getNewContract(); 
        contract.Status = 'Complete';
        
        update contract;
        //Create a new Contract Line     
        Contract_Line__c contractLine = new Contract_Line__c();
        contractLine.Contract__c = contract.Id;
        contractLine.Price__c  = 0.00;
        contractLine.Running_Total__c = 0.00; 
     //   contractLine.Duration_days__c = 10;
        
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='OAT' limit 1];
        User usr = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
        //Test.startTest();
        Test.startTest();
        System.RunAs(usr)
        {
            contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
            contractLine.PO_number__c = '12312323423';
            contractLine.End_Date__c = System.today()+1;
            contractLine.Start_Date__c = System.today();
            contractLine.Platform__c = 'MFS';
            contractLine.Order_Method__c='RI';
            contractLine.IM_Lookup_Code__c = '360 Subscription';
            insert contractLine;
             contractLine.End_Date__c = System.today()+1;
            // contractLine.IM_Lookup_Code__c = 'Product Subscription';
             update contractLine;
            Delete contractLine;
            unDelete contractLine;
        }
        Test.stopTest();
    }
    
        public static Contract getNewContract2()
    {
        Contract contract = new Contract();
        Account a = new Account();
        Schema.sObjectType t = a.getSObjectType();
        List<account> a1 = Test.loadData(t, 'AccountTestData');
        //Get first test account
        account = (Account)a1[2];
        Contact contact = new Contact(AccountId=account.Id,LastName='test12345',email='test12345@test.com',phone='2345345345',Same_As_The_Account_Billing_Address__c=true);
        contacts = new List<Contact>();
        contacts.add(contact);
        insert contacts;
        Opportunity opportunity= new Opportunity(OwnerId=UserInfo.getUserId(),Business_Type__c = 'NBB - New Logo',
                                                 AccountId=Account.Id,Billing_Contact__c=Contact.Id,Primary_Contact__c=Contact.Id,
                                                 name='Test Opportunity',Forecast_Category__c = 'Forecast', NVM_Credit_Card_ID__c='',
                                                 Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP', Renewal_Date__c=Date.today(),
                                                 StageName=System.Label.Opportunity_Stage_1,closeDate=System.today(),
                                                 Order_number__c=contract.Id,Talent_Level__c='Leader' , 
                                                 Talent_Segment__c= 'Graduate / Apprentice' , Client_Business_Function__c= 'Finance');
       	insert opportunity;
        contract.AccountId = account.Id;  
        contract.Legal_Order_Name__c = 'test'; 
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
       	contract.Renewal_Date__c = Date.Today();
        contract.ContractTerm = 6;   
        contract.Activated_Date__c=datetime.now();
        contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract.Submission_Offset__c = 10;
        contract.Agreement__c = 'Order';
        contract.Renewal_Opportunity__c=opportunity.id;
        contract.Days_remaining_from_annual_subscription__c = 0;
        
        insert contract;
        
        
        opportunity opportunity1=[select Business_Type__c,Renewal_Opportunity__c from opportunity where id=:opportunity.id];
        opportunity1.Business_Type__c = 'Renewal';
        opportunity1.Renewal_Opportunity__c = true;
      	update opportunity1;
        contract.Opportunity__c = opportunity.id;
        contract.Renewal_Date__c = Date.Today();
        contract.Status = 'Draft';
        update contract;

        return contract; 
    } 
    
     
    public static testmethod void ContractLineManager3()
    {
        
        //Boolean IMLookupcheck;
        Contract contract=getNewContract(); 
        contract.Status = 'Complete';
        
        update contract;
        //Create a new Contract Line     
        Contract_Line__c contractLine = new Contract_Line__c();
        contractLine.Contract__c = contract.Id;
        contractLine.Price__c  = 0.00;
        contractLine.Running_Total__c = 0.00; 
     //   contractLine.Duration_days__c = 10;
        
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='OAT' limit 1];
        User usr = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
        //Test.startTest();
        Test.startTest();
        System.RunAs(usr)
        {
            contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
            contractLine.PO_number__c = '12312323423';
            contractLine.End_Date__c = System.today()+1;
            contractLine.Start_Date__c = System.today();
            contractLine.Platform__c = 'MFS';
            contractLine.Order_Method__c='RI';
            contractLine.IM_Lookup_Code__c = '360 Platform Set up';
            insert contractLine;
             contractLine.End_Date__c = System.today()+1;
            // contractLine.IM_Lookup_Code__c = 'Product Subscription';
             update contractLine; 
        }
        Test.stopTest();
    }
    
     
}
@isTest(SeeAllData=true)
public class ContractLineManager_tester1 {
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
        
        contract.AccountId = account.Id;  
        contract.Legal_Order_Name__c = 'test'; 
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;   
        contract.Activated_Date__c=datetime.now();
        contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract.Submission_Offset__c = 10;
        contract.Agreement__c = 'Order';
        
        insert contract;
        Opportunity opportunity= new Opportunity(OwnerId=UserInfo.getUserId(),Business_Type__c = 'NBB - New Logo',AccountId=Account.Id,Billing_Contact__c=Contact.Id,Primary_Contact__c=Contact.Id,
                                                 name='Test Opportunity',Forecast_Category__c = 'Forecast', NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName=System.Label.Opportunity_Stage_4,
                                                 Offering__c='Leader Edge',
                                                 closeDate=System.today(),Order_number__c=contract.Id,Talent_Level__c='Leader' , Talent_Segment__c= 'Graduate / Apprentice' , Client_Business_Function__c= 'Finance');
        insert opportunity;
        contract.Opportunity__c = opportunity.id;
        contract.Status = 'Draft';
        update contract;
        return contract;
        
    } 
    
    public static Contract getNewContract_varidation()
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
        
        contract.AccountId = account.Id;  
        contract.Legal_Order_Name__c = 'test'; 
        contract.CurrencyIsoCode = account.CurrencyIsoCode;
        contract.S2P_Reference_Required__c = 'New';
        contract.Status = 'Draft';
        contract.CustomerSignedDate = Date.Today();
        contract.StartDate = Date.Today();
        contract.ContractTerm = 6;   
        contract.Activated_Date__c=datetime.now();
        contract.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract.Submission_Offset__c = 10;
        contract.Agreement__c = 'Order';
        
        insert contract;
        Opportunity opportunity1= new Opportunity(OwnerId=UserInfo.getUserId(),Business_Type__c = 'NBB - New Logo',AccountId=Account.Id,Billing_Contact__c=Contact.Id,Primary_Contact__c=Contact.Id,name='Test Opportunity',Forecast_Category__c = 'Forecast', NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName=System.Label.Opportunity_Stage_1,closeDate=System.today(),Order_number__c=contract.Id,Talent_Level__c='Leader' , Talent_Segment__c= 'Graduate / Apprentice' , Client_Business_Function__c= 'Finance');
        insert opportunity1;
        Opportunity opportunity= new Opportunity(OwnerId=UserInfo.getUserId(),Variation_Reason__c='Discount',Variation_Opportunity__c='Yes',Original_Opportunity__c=opportunity1.id,Business_Type__c = 'NBB - New Logo',AccountId=Account.Id,Billing_Contact__c=Contact.Id,Primary_Contact__c=Contact.Id,name='Test Opportunity',Forecast_Category__c = 'Forecast', NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName=System.Label.Opportunity_Stage_1,closeDate=System.today(),Order_number__c=contract.Id,Talent_Level__c='Leader' , Talent_Segment__c= 'Graduate / Apprentice' , Client_Business_Function__c= 'Finance');
        insert opportunity;
        contract.Opportunity__c = opportunity.id;
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
        // contractLine.Running_Total__c = '';
        contractLine.IM_Lookup_Code__c = 'Managed Services';
        
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
            insert contractLine;
            contractLine.End_Date__c = System.today()+1;
            update contractLine; 
        }
        Test.stopTest();
    }
    
    public static testmethod void ContractLine_Manager1_5()
    {
        
        //Boolean IMLookupcheck;
        Contract contract=getNewContract(); 
        contract.Status = 'Complete';        
        update contract;
        //Create a new Contract Line     
        Contract_Line__c contractLine = new Contract_Line__c();
        contractLine.Contract__c = contract.Id;
        contractLine.Price__c  = 0.00;
        contractLine.Running_Total__c = 0;
        contractLine.IM_Lookup_Code__c = 'Expenses';
        Contract_Line__c contractLine3 = new Contract_Line__c();
        contractLine3.Contract__c = contract.Id;
        contractLine3.Price__c  = 0.00;
        contractLine3.Running_Total__c = 0;
        contractLine3.IM_Lookup_Code__c = 'Managed Services';
        
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='OAT' limit 1];
        User usr = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
        Test.startTest();
        System.RunAs(usr)
        {
            
            insert contractLine3;
            Set<string> IMlookupCode = new Set<string>();
            Boolean IMLookupcheck;
            List<Contract> Lcontract = [Select id,name,status from Contract where id=:contractLine.Contract__c limit 1];
            If(Lcontract.size()>0 && Lcontract[0].status == 'Complete')
            {
                IMlookupCode = Utility.getIMLookupCode();
                if(IMlookupCode.size()>0 && contractLine.IM_Lookup_Code__c != '' )
                    IMLookupcheck = IMlookupCode.contains(contractLine.IM_Lookup_Code__c);
                
                if(IMLookupcheck == true){
                    if(contractLine.Price__c  == 0.00 && (contractLine.Running_Total__c == 0 || contractLine.Running_Total__c == null ))
                    {
                        contractLine.addError(System.Label.Order_Line_Line_Price_Zero_On_Insert);
                    }
                    contractLine.Price__c  = 10.00;
                    contractLine.Running_Total__c = 10;
                    contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
                    contractLine.PO_number__c = '12312323423';
                    contractLine.End_Date__c = System.today()+1;
                    contractLine.Start_Date__c = System.today();
                    contractLine.Platform__c = 'MFS';
                    insert contractLine;
                }
                contractLine.Price__c  = 20.00;
                contractLine.IM_Lookup_Code__c= 'Freight';
                update contractLine;  
                
                contractLine.Price__c  = 0.00;
                contractLine.IM_Lookup_Code__c= 'Freight';
                try{
                    update contractLine; 
                }
                catch(exception e)
                {
                    Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;            
                    System.debug('cacdsv'+expectedExceptionThrown);
                    System.AssertEquals(expectedExceptionThrown, true);
                }
                
            }
        }
        
        Test.stopTest();
    }
    
    public static testmethod void ContractLineManager2()
    {
        contract contract=[select id,CurrencyIsoCode from contract where Opportunity__r.Variation_Opportunity__c='No' limit 1];
        Account acc=[select id,CurrencyIsoCode from Account where Same_As_The_Billing_Address__c=true and CurrencyIsoCode !=null limit 1 ];
        Contact contact = [select Id from contact where Same_As_The_Account_Billing_Address__c=true limit 1];  
        Test.startTest();     
        Opportunity opportunity1=[select id from Opportunity where Forecast_Category__c !=null limit 1];
        //Opportunity opportunity=[select id from Opportunity where Variation_Opportunity__c='Yes' and Forecast_Category__c='forcast' limit 1];
        Opportunity opportunity= new Opportunity(OwnerId=UserInfo.getUserId(),Variation_Reason__c='Discount',Variation_Opportunity__c='Yes',Original_Opportunity__c=opportunity1.id,Business_Type__c = 'NBB - New Logo',AccountId=acc.Id,Billing_Contact__c=Contact.Id,Primary_Contact__c=Contact.Id,name='Test Opportunity',Forecast_Category__c = 'Forecast', NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName=System.Label.Opportunity_Stage_1,closeDate=System.today(),Order_number__c=contract.Id,Talent_Level__c='Leader' , Talent_Segment__c= 'Graduate / Apprentice' , Client_Business_Function__c= 'Finance');
        insert opportunity;       
        Contract contract2 = new Contract();
        contract2.AccountId = acc.Id;  
        contract2.Legal_Order_Name__c = 'test'; 
        contract2.CurrencyIsoCode = acc.CurrencyIsoCode;
        contract2.S2P_Reference_Required__c = 'New';
        contract2.Status = 'Submitted';
        contract2.CustomerSignedDate = Date.Today();
        contract2.StartDate = Date.Today();
        contract2.ContractTerm = 6;   
        contract2.Activated_Date__c=datetime.now();
        contract2.Final_Submission_Date_EST__c=datetime.now().addDays(-2);
        contract2.Submission_Offset__c = 10;
        contract2.Agreement__c = 'Order';     
        contract2.Opportunity__c = opportunity.id;
        contract2.Original_Order__c = contract.Id;
        insert contract2;
         
        Contract_Line__c contractLine = new Contract_Line__c();
        contractLine.Contract__c = contract2.Id;
        contractLine.Price__c  = 0.00;
        contractLine.IM_Lookup_Code__c = 'Expenses';
        Contract_Line__c contractLine1 = new Contract_Line__c();
        contractLine1.Contract__c = contract.Id;
        contractLine1.Price__c  = 0.00;
        contractLine1.IM_Lookup_Code__c = 'Expenses';
        insert contractLine1; 
        contractLine.CurrencyIsoCode = contract.CurrencyIsoCode;
        contractLine.PO_number__c = '12312323423';
        contractLine.End_Date__c = System.today()+1;
        contractLine.Start_Date__c = System.today();
        contractLine.Platform__c = 'MFS'; 
        contractLine.Original_Order__c=contract.Id;
        contractLine.Original_Order_Line__c=contractLine1.id;
        contractLine.Scoped_CPS_days__c=10;
        contractLine.Scoped_LPS_days__c=0;
        contractLine.Source_of_PS_Scoping__c='E2E Scoping Tool';
        insert contractLine;
        Test.stopTest();
    } 
    
     public static testmethod void ContractLineManager2updatedDel()
    {    Contract_Line__c contractLinelist=[select id,Scoped_CPS_days__c,Scoped_LPS_days__c from Contract_Line__c where Variation_Order__c = 'Yes' and Scoped_CPS_days__c !=null and Scoped_LPS_days__c !=null and Original_Order_Line__c !=null limit 1 ];
        contractLinelist.Scoped_CPS_days__c=20;
        contractLinelist.Scoped_LPS_days__c=30;
        Contract_Invoice_Line__c Invoiceline=[select id,IM_Lookup_Code_For_Filter__c,Invoice_Header_ID__r.Invoice_Status__c ,
                                              Contract_Line_ID__c,Contract_Line_ID__r.Platform__c,Contract_Line_ID__r.IM_Lookup_Code__c from Contract_Invoice_Line__c where Invoice_Header_ID__r.Invoice_Status__c ='Draft' limit 1];
  		Invoiceline.Contract_Line_ID__r.Platform__c = 'MFS'; 
     Invoiceline.Contract_Line_ID__r.IM_Lookup_Code__c = 'Expenses';
     	update Invoiceline.Contract_Line_ID__r;
        Test.startTest();  
        update contractLinelist;
        Delete contractLinelist;
        Test.stopTest();
     	
    } 
   
}
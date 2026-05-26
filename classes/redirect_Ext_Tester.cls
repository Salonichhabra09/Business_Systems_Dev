/*
Created By: Prabhat Arora, for SSE-7077, 
Purpose: Test Class for Extension Controller used with OLI Standard Controller for Overiding Functionality of OLI standard "EDIT & DELETE" actions. 
*/

@IsTest (seeAllData = true) 
Public class redirect_Ext_Tester {
    public static List<Contact> contacts;
    
    @isTest static void testredirect_Ext(){
        
        Datetime variable=System.now();
        String Testname='Test Account'+variable;
        Account account=new Account(name=Testname,currencyIsoCode='GBP',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry = 'Agriculture');
        insert account;
        
        Contract contract = new Contract();       
        
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
        contract.Subscription_Start_Date__c = system.today();
        insert contract;
        contract.Status  = 'Complete';
        update contract;
        System.debug('ContractId*' + contract.id);
        
        Test.startTest();   
        Opportunity opportunity=new Opportunity(TM_Phase__c='Post-Hire',       
                                                Talent_Segment__c='Graduate / Apprentice',
                                                OwnerId=UserInfo.getUserId(),Business_Type__c = 'Expansion',Offering__c = 'OPQ',Forecast_Category__c='Commit',
                                                AccountId=Account.Id,Billing_Contact__c=Contact.Id,Primary_Contact__c=Contact.Id,
                                                name='Test Opportunity',NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',
                                                CurrencyISOCode='GBP',StageName='Verbal',Variation_Opportunity__c = 'No',closeDate=System.today(),Order_number__c=contract.Id);
        
        insert opportunity;
        //opportunity.StageName='Closed/Won';
        //update opportunity;
        Opportunity.Order_number__c = contract.id;
        Opportunity.SkipValidationLeadConversion__c = true;
        contract.Opportunity__c = opportunity.id;
        update contract;
        
        pricebookentry PR=[select id from Pricebookentry where IsActive=true and currencyIsoCode='GBP' limit 1];
        OpportunityLineItem LI=new OpportunityLineItem(Solution_Cap__c = 5,OpportunityId=opportunity.id,PricebookEntryId=PR.id,TotalPrice=100,Quantity=1,Start_Date__c =System.Today(),End_Date__c =System.Today()+10,Imported_from_Rate_Card_c__c= True);//Added by Prabhat (StartDate & EndDate)
        insert LI;
        system.debug('LIST ID'+LI.Id);
        
        OpportunityLineItem o = [select id,TotalPrice,Quantity,Imported_from_Rate_Card_c__c from OpportunityLineItem where id=:LI.Id Limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        pageReference refpage= Page.ImportRateCard_VF;
        refpage.getParameters().put('id', String.valueOf(o.Id));
        Test.setCurrentPage(refpage);
        
        system.debug('OLIOBJ ID:-->'+o.Id);
        redirect_Ext Objredirect_Ext = new redirect_Ext(sc);
        
        Test.stopTest();
        System.assert(Objredirect_Ext.opptyLineItemRec != null);
        System.assert(Objredirect_Ext.OpptyId != null);
        //System.assert(Objredirect_Ext.rateCardUploaded);
        
    }
    
    
}
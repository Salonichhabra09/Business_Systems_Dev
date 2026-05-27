@IsTest(SeeAllData=True)
public class OpportunityLineItemTriggerManager_Test {
      
     static testmethod void Method1(){
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Commercial' limit 1];
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
         Database.DMLOptions dml = new Database.DMLOptions(); 
         dml.DuplicateRuleHeader.allowSave = true;
         dml.DuplicateRuleHeader.runAsCurrentUser = true;
         
        Account account=new Account(name='Test Account0987'+System.now(),industry='Legal',
                                    ownerid=user.id,Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
        //insert account;
        Database.SaveResult sr = Database.insert(account, dml);
        
        
        Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        contact.ownerid= user.id;
        
        insert contact;
        
        Contract contract= new Contract(
            AccountId=account.Id,        
            Agreement__c='Order',
            ContractTerm=12,
            Status='Draft',
            StartDate=date.today(),
            Invoicing_Contact__c=contact.Id,
            Contract_Type__c='Consulting',
            Subscription_Start_Date__c=date.today()
        );
        insert contract; 
        
        Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Standard Opportunity' limit 1];
        //Id priceBookID = Test.getStandardPricebookId();
        Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
        opportunity.ownerid=user.id;
        opportunity.Billing_Contact__c=contact.id;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=contact.id;
        opportunity.CurrencyIsoCode='AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity.NVM_Credit_Card_ID__c='1234';
        opportunity.Amount=1000;
        opportunity.Variation_Opportunity__c='NO';
        opportunity.Order_Number__c=contract.id;
        opportunity.Original_Opportunity__c=null;
        opportunity.Annual_Contract_Value__c=1000.00;
        opportunity.StageName='First Appointment';   
        opportunity.GCSC__c='Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity.RecordTypeID=RT.id;
        opportunity.Skip_Validation__c=True;
        opportunity.Pricebook2Id=p.id;
        opportunity.Business_Type__c='New customer: subscription';
        opportunity.Forecast_Category__c='Commit';
        opportunity.Multi_YearDeal__c = '2';
        opportunity.Opportunity_Deal_Year__c = 1;
        
        
        insert opportunity;
        pricebookentry PR=[select id from Pricebookentry where IsActive=true and currencyIsoCode='AUD' limit 1];
        
      
        
        OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity.id,CurrencyChange__c = false,Package__c = 'Bespoke',RenewableNew__c = 'Ongoing',PricebookEntryId=PR.id,TotalPrice=100,Quantity=1,Start_Date__c= system.today(),End_Date__c=system.today()+1, Total_Equivalent_Units__c = 10, Platform__c = 'iAssess', Usage_Allowance__c = 'Capped');
        insert LI;
        LI.RenewableNew__c = 'One-off';
       // LI.ms_product__c = true;
        update LI;
        LI.RenewableNew__c = 'Ongoing';
        update LI;
       
        System.runAs(user){            
            Delete LI;
        }
        
        }
        
        static testmethod void Method2(){
        
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='Finance' limit 1];
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
        Database.DMLOptions dml = new Database.DMLOptions(); 
         dml.DuplicateRuleHeader.allowSave = true;
         dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Account account=new Account(name='Test Account1234'+System.now(),industry='Legal',
                                    ownerid=user.id,Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
        //insert account;
        Database.SaveResult sr = Database.insert(account, dml);
        
        Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        contact.ownerid = user.id;
        
        insert contact;
        
        Contract contract= new Contract(
            AccountId=account.Id,        
            Agreement__c='Order',
            ContractTerm=12,
            Status='Draft',
            StartDate=date.today(),
            Invoicing_Contact__c=contact.Id,
            Contract_Type__c='Consulting',
            Subscription_Start_Date__c=date.today()
        );
        insert contract; 
        
        Pricebook2  p=[Select id,name from Pricebook2  where name='Configurator Price Book' limit 1 ];    
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Standard Opportunity' limit 1];
        //Id priceBookID = Test.getStandardPricebookId();
        Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=account.id);
        opportunity.ownerid=user.Id;
        opportunity.Billing_Contact__c=contact.id;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=contact.id;
        opportunity.CurrencyIsoCode='AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity.NVM_Credit_Card_ID__c='1234';
        opportunity.Amount=1000;
        opportunity.Variation_Opportunity__c='NO';
        opportunity.Order_Number__c=contract.id;
        opportunity.Original_Opportunity__c=null;
        opportunity.Annual_Contract_Value__c=1000.00;
        opportunity.StageName='First Appointment';   
        opportunity.GCSC__c='Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity.RecordTypeID=RT.id;
        opportunity.Skip_Validation__c=True;
        opportunity.Pricebook2Id=p.id;
        opportunity.Business_Type__c='New customer: subscription';
        opportunity.Forecast_Category__c='Commit';
        opportunity.Multi_YearDeal__c = '2';
        opportunity.Opportunity_Deal_Year__c = 1;
        opportunity.Probability = 60;
        
        insert opportunity;
            
        Opportunity VariationOpportunity=new Opportunity(name='Test VariationOpportunity', AccountID=account.id);
        VariationOpportunity.ownerid=user.Id;
        VariationOpportunity.Billing_Contact__c=contact.id;
        VariationOpportunity.Closedate=system.today();
        VariationOpportunity.Primary_Contact__c=contact.id;
        VariationOpportunity.CurrencyIsoCode='AUD';
        VariationOpportunity.Amount=1000;
        VariationOpportunity.Variation_Opportunity__c='Yes';
        VariationOpportunity.Order_Number__c=contract.id;
        VariationOpportunity.Original_Opportunity__c=Opportunity.Id;
        VariationOpportunity.Annual_Contract_Value__c=1000.00;
        VariationOpportunity.StageName='First Appointment';   
        VariationOpportunity.RecordTypeID=RT.id;
        VariationOpportunity.Skip_Validation__c=True;
        VariationOpportunity.Pricebook2Id=p.id;
        VariationOpportunity.Business_Type__c='New customer: subscription';
        VariationOpportunity.Forecast_Category__c='Commit';
        VariationOpportunity.Multi_YearDeal__c = '1';
        VariationOpportunity.Opportunity_Deal_Year__c = 1;
        VariationOpportunity.Probability = 60;
        
        insert VariationOpportunity;
         
       // pricebookentry PR=[select id from Pricebookentry where IsActive=true and currencyIsoCode='AUD' limit 1];
         Pricebook2 PR1 = [Select Id, Name, IsActive From Pricebook2 where name='Configurator Price Book' limit 1];
        Product2 MSProd =[select id from Product2 where IsActive=true and ms_product__c=true limit 1];
        PricebookEntry PE2 =[Select id,IsActive,CurrencyIsoCode from PricebookEntry where IsActive=true and CurrencyIsoCode = 'AUD' and Pricebook2Id =:PR1.id  and Product2Id=:MSProd.id limit 1];
        Product2 PSProd =[select id from Product2 where IsActive=true and Revenue_Category__c='Professional Services' limit 1];
        PricebookEntry PE3 =[Select id,IsActive,CurrencyIsoCode from PricebookEntry where IsActive=true and CurrencyIsoCode = 'AUD' and Pricebook2Id =:PR1.id  and Product2Id=:PSProd.id limit 1];
        List<OpportunityLineItem> OLIsToadd = new List<OpportunityLineItem>();
        List<OpportunityLineItem> OLIsToupdate = new List<OpportunityLineItem>();    
        OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity.id,Platform__c='MFS',Usage_Allowance__c='Uncapped',Total_Equivalent_Units__c=10,CurrencyChange__c = false,Package__c = 'Bespoke',RenewableNew__c = 'Ongoing',PricebookEntryId=PE2.id,UnitPrice=100,Quantity=1,Start_Date__c= system.today(),End_Date__c=system.today()+1,Solution_Cap__c = 1);
        OLIsToadd.add(LI);
        OpportunityLineItem LI2=new OpportunityLineItem(OpportunityId=opportunity.id,Platform__c='MFS',Usage_Allowance__c='Uncapped',Total_Equivalent_Units__c=20,CurrencyChange__c = false,Package__c = 'Bespoke',RenewableNew__c = 'Ongoing',PricebookEntryId=PE3.id,UnitPrice=100,Quantity=1,Start_Date__c= system.today(),End_Date__c=system.today()+1,Solution_Cap__c = 1);
        OLIsToadd.add(LI2);
        insert OLIsToadd;
        OLIsToadd.clear();    
        OpportunityLineItem VLI1=new OpportunityLineItem(OpportunityId=VariationOpportunity.id,Platform__c='MFS',Usage_Allowance__c='Uncapped',Total_Equivalent_Units__c=10,CurrencyChange__c = false,Package__c = 'Bespoke',RenewableNew__c = 'Ongoing',PricebookEntryId=PE2.id,UnitPrice=100,Quantity=1,Start_Date__c= system.today(),End_Date__c=system.today()+1,Solution_Cap__c = 1);
        OLIsToadd.add(VLI1);
        OpportunityLineItem VLI2=new OpportunityLineItem(OpportunityId=VariationOpportunity.id,Platform__c='MFS',Usage_Allowance__c='Uncapped',Total_Equivalent_Units__c=20,CurrencyChange__c = false,Package__c = 'Bespoke',RenewableNew__c = 'Ongoing',PricebookEntryId=PE3.id,UnitPrice=100,Quantity=1,Start_Date__c= system.today(),End_Date__c=system.today()+1,Solution_Cap__c = 1);
        OLIsToadd.add(VLI2);
            test.startTest();
            insert OLIsToadd;
            test.stopTest();
        LI.RenewableNew__c = 'One-off';
            update OLIsToupdate;
            
        VLI1.UnitPrice =110;
            OLIsToupdate.add(VLI2);
        update VLI1;
        //delete LI2;
        LI.RenewableNew__c = 'Ongoing';
        /*System.runAs(user){
            //update LI;
        }
        
          
        List<Job__c> jb =[Select id,Opportunity__c from Job__c where Opportunity__r.id=:opportunity.id ];
        System.debug('Job before delete'+ jb.size());
        
        Delete jb;        
        jb =[Select id,Opportunity__c from Job__c where Opportunity__r.id=:opportunity.id];
        System.debug('Job After Delete'+ jb.size());*/
        
        }
   
}
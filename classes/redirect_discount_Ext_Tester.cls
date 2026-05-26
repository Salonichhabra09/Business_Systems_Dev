/*
Created By: Rishabh Kanotra, for SSE-7079, 
Purpose: Overiding Functionality of OLI standard "EDIT & DELETE" actions 
*/
@IsTest (seeAllData = true) 
Public class redirect_discount_Ext_Tester {
    @isTest static void test_redirect_Ext(){
    
        Datetime variable=System.now();
            String Testname='Test Account'+variable;
            
    Account account=new Account(name=Testname,Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1',Industry='Agriculture');
        insert account;
        
        Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
          contact.Same_As_The_Account_Billing_Address__c=true;
          contact.Mailing_Address_Line_1__c ='test';
          contact.Mailing_City__c='test';
          contact.Mailing_ZIP_Postal_Code__c ='110094';
          contact.Mailing_Country__c='India';
          
          insert contact;
          
          Pricebook2 Pricebook=new Pricebook2();
          Pricebook.Description='Test Description';
          Pricebook.IsActive=True;
          Pricebook.Name='Test Pricebook';
          Insert Pricebook;
          
         // List<Pricebookentry> i = [Select Product2Id,(select id from Products) from PriceBookEntry where Id = '01s8E000000DgZEQA0' LIMIT 1];
          //List<Product2> pp = [Select id from Product2 where CurrencyIsoCode='GBP' LIMIT 1];  
           Product2 prodignite = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware',CurrencyIsoCode='GBP') ; 
                                     insert prodignite;     
          Product2 Product=new Product2();
          Product.Description='Test Description';
          Product.IsActive=True;
          Product.Name='Test Product';
          Product.Revenue_Category__c='Training';
          Insert Product;
          
          Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
          PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prodignite.Id, UnitPrice = 1000,CurrencyIsoCode='GBP', IsActive = true);
          insert standardPBE;
           // Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
            //System.debug('This is standard PB**'+standardPB );
            //PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pp[0].Id, UnitPrice = 1000, IsActive = true);
           // insert standardPBE;
           // System.debug('This is Standard PBE**'+standardPBE );
          
          
          
          Pricebook2 ignite = [Select Id, Name, IsActive From Pricebook2 where Name = 'Configurator Price Book'LIMIT 1];
          
          //PricebookEntry PBE = [Select id from PricebookEntry where Product2Id =:pp[0].id AND CurrencyIsoCode='GBP' LIMIT 1 ];
          PricebookEntry PBE = new PricebookEntry(
        Pricebook2Id = ignite.Id, Product2Id = prodignite.id,
        UnitPrice = 12000, IsActive = true,CurrencyIsoCode='GBP');
        insert PBE;

          RecordType RT1=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Configurator Opportunity' limit 1];
         Test.starttest();
         Opportunity opportunity4=new Opportunity(name='Test1 Opportunity', AccountID=account.id,Offering__c='Enterprise Leadership',Talent_Level__c='Leader',Talent_Segment__c='Volume',Client_Business_Function__c='HR');
         opportunity4.ownerid=UserInfo.getUserId();
         opportunity4.Billing_Contact__c=contact.id;
         opportunity4.Closedate=system.today();
         opportunity4.Primary_Contact__c=contact.id;
         opportunity4.CurrencyIsoCode='GBP';
         opportunity4.Unconfirmed_Sun_Order_Number__c='1234';
         opportunity4.NVM_Credit_Card_ID__c='1234';
         opportunity4.Amount=1000;
         opportunity4.Variation_Opportunity__c='NO';
         opportunity4.Original_Opportunity__c=null;
         opportunity4.Annual_Contract_Value__c=1000.00;
         opportunity4.StageName='Prepare';   
         opportunity4.GCSC__c='Phone';
         opportunity4.OpportunityAmountMappedWithLead__c = 323.34;//**********
         opportunity4.OpportunityTypeMappedWithLead__c = 'New Business';//**********
         opportunity4.RecordTypeID=RT1.id;
         opportunity4.Skip_Validation__c=True;
         opportunity4.Pricebook2Id = ignite.id;
         opportunity4.Forecast_Category__c='Commit';
         opportunity4.Business_Type__c='Renewal';
         system.debug('THIS IS Opp PBE1**' + opportunity4.Pricebook2Id);
         insert opportunity4;
         system.debug('THIS IS Opp PBE2**' + opportunity4.Pricebook2Id);
         //Id pp =  opportunity4.Pricebook2Id;
         pricebookentry PR=[select id,Pricebook2Id from Pricebookentry where Pricebook2Id=: opportunity4.Pricebook2Id  limit 1];
         system.debug('THIS IS pr**' + PR );
         
         OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity4.id,PricebookEntryId=PBE.id,Quantity=1,UnitPrice = 1000);
         LI.Product2=Product;
         LI.Year_1_List_Price__c=500; 
         li.Year_1_Sales_Price__c=300;
         li.Year_2_List_Price__c=600; 
         li.Year_2_Sales_Price__c=300;  
         li.Year_3_List_Price__c=600; 
         li.Year_3_Sales_Price__c=300;           
         insert LI;
         //update(opportunity4);
             //Test.starttest();
             
             Discount_Summary__c DS = new Discount_Summary__c(Opportunity__c=opportunity4.id,Discount_Type__c ='Deal Length', Level__c ='2',Discount_Percentage__c =5,Discount_Amount__c =4000,Discount_Applied_On__c =date.parse('9/7/2018'));
            insert DS;
            
            Discount_Summary__c d = [Select id,Discount_Type__c , Level__c,Discount_Percentage__c,Discount_Amount__c,Discount_Applied_On__c from  Discount_Summary__c where id=:DS.Id Limit 1 ];
              
            ApexPages.StandardController sc = new ApexPages.StandardController(d);
            pageReference refpage= Page.ImportRateCard_VF;
            refpage.getParameters().put('id', String.valueOf(d.Id));
            Test.setCurrentPage(refpage);

            
            redirect_discount_Ext Objredirect_Ext = new redirect_discount_Ext(sc);
             Test.stoptest();

            
       
       
            
    
   
    }
}
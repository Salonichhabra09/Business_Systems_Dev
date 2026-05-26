@isTest(SeeAllData=true)
Private Class CurrencyChangeOpportunityTester{
    
    Map<id,pricebookentry> PricebookEntryMap=new map<id,Pricebookentry>();
    Map<id,pricebookentry> PricebookEntryMap1=new map<id,Pricebookentry>();
    
    Static  TestMethod void ValidateChangeCurrencyOpportunity(){
        
        List<OpportunityLineItem> ListOLI=new List<OpportunityLineItem>();
        
        Account account=new Account(name='Test Account0987',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1', Industry='Agriculture');
        insert account;
        
        
        Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
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
        
        
        //Attachment attachment=new Attachment(Name='Test PDF1', OwnerID=UserInfo.getUserId(), ParentID=contract.id, Body=Blob.toPdf('Test Body'), ContentType='application/pdf');
        //insert attachment;
        String yourFiles = 'Test Body';
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'test.pdf'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Test PDF1 '; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(yourFiles); // converting your binary string to Blog
        insert conVer;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = contract.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        
        Pricebook2 Pricebook=new Pricebook2();
        Pricebook.Description='Test Description';
        Pricebook.IsActive=True;
        Pricebook.Name='Test Pricebook';
        Insert Pricebook;
        
        
        Product2 Product=New Product2();
        Product.Description='Test Description';
        Product.IsActive=True;
        Product.Name='Test Product';
        Insert Product;
        
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PricebookEntry PBE=new PricebookEntry();
        PBE.CurrencyIsoCode='USD';
        PBE.IsActive=True;
        PBE.Pricebook2Id=standard.id;
        PBE.Product2Id=Product.Id;
        PBE.UnitPrice=1;
        Insert PBE;
        
        PricebookEntry PBE2=new PricebookEntry();
        PBE2.CurrencyIsoCode='AUD';
        PBE2.IsActive=True;
        PBE2.Pricebook2Id=standard.id;
        PBE2.Product2Id=Product.Id;
        PBE2.UnitPrice=1;
        Insert PBE2;
        
        
        
        Pricebook2  p=[Select id,name from Pricebook2  where name='Standard Price Book' limit 1 ];    
        RecordType RT=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Standard Opportunity' limit 1];
        //Id priceBookID = Test.getStandardPricebookId();
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
        opportunity.Order_Number__c=contract.id;
        opportunity.Original_Opportunity__c=null;
        opportunity.Annual_Contract_Value__c=1000.00;
        opportunity.StageName='Prepare';   
        opportunity.GCSC__c='Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity.RecordTypeID=RT.id;
        opportunity.Skip_Validation__c=True;
        opportunity.Pricebook2Id=p.id;
        opportunity.Business_Type__c='Expansion';
        opportunity.Forecast_Category__c='Commit';
        
        insert opportunity;
        
       // added new
        OpportunityLineItem LI1=new OpportunityLineItem(RenewableNew__c = 'Ongoing',OpportunityId=opportunity.id,PricebookEntryId=PBE2.id,TotalPrice=100,Quantity=1,Platform__c='iAssess',Usage_Allowance__c='Capped', Usage_Cap_or_Estimation__c=1234,Basis_of_Fees__c='Candidates',Solution_Cap__c = 12,List_Price__c=100,Proposition__c='Graduate Hiring',Package__c='Bespoke');
        insert LI1;
       
        Future_Product__c fup = new Future_Product__c();  
        fup.Opportunity__c= opportunity.id;
        fup.Product__c = Product.id;
        insert fup;                
        
        contract.Opportunity__c=opportunity.Id;
        contract.currencyisocode = 'AUD';
        Update Contract;
        
        Order Ord=new order();   // added now
        Ord.AccountId=account.id;
        Ord.ContractId=contract.id;
        Ord.OpportunityId = opportunity.id;
        Ord.CurrencyIsoCode='AUD';
        Ord.Name ='Test';
        Ord.Order_Year__c=2;
        Ord.EffectiveDate=date.today();
        Ord.Oats_Status__c = 'Completed';
        Ord.Status='Draft';
        Ord.Reduction_Order__c = False;
        Ord.Booking_Date__c=date.today();
        Ord.Pricebook2Id = standard.id;
        Ord.Booked_Elsewhere__c=True;
        insert Ord;
        
        OrderItem oi = new OrderItem();       
        oi.OrderId = Ord.id;
        oi.Quantity = LI1.Quantity;
        oi.UnitPrice = 100;
        oi.PricebookEntryId = LI1.PricebookEntryId;                
        insert oi;  // added end
        
        User User=[select id from User where IsActive= true and Is_Project_Manager__c=True and Project_BU__c like '%AU1%' limit 1];
        
        ProjectObject__c project = new ProjectObject__c();
        Project.Account__c=Account.Id;
        Project.Project_Name__c='Test Project';
        Project.Project_Status__c='Pending';
        Project.Project_Type__c='Consulting and outsourced assessments';
        Project.LBU__c='AU1';
        Project.Project_Manager__c=User.id;
        Project.Opportunity__c=Opportunity.id;
        
        insert Project;
        
        pricebookentry PR=[select id from Pricebookentry where IsActive=true and currencyIsoCode='AUD' limit 1];
        OpportunityLineItem LI=new OpportunityLineItem(OpportunityId=opportunity.id,Solution_Cap__c = 2,PricebookEntryId=PR.id,TotalPrice=100,Quantity=1,Start_Date__c= system.today(),End_Date__c=system.today()+1);
        insert LI;
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', opportunity.id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(opportunity);
        
        CurrencyChangeOpportunity ObjCCO=new CurrencyChangeOpportunity(stdController);
        ObjCCO.getOpportunityLineItemToInsert();
        ObjCCO.getPriceBookEntryMap();
        ObjCCO.getOpportunityLineItemToDelete();  
        ObjCCO.SelectedCurrency='USD';
        ObjCCO.getProductsUpdated();
        ObjCCO.UpdateNewCurrencyOnOpportunity();
        ObjCCO.CreateOrderLineItems(); // added now
        ObjCCO.setOpportunityLineItemToInsert(ObjCCO.getOpportunityLineItemToInsert());
        ObjCCO.setOpportunityLineItemToDelete(ObjCCO.getOpportunityLineItemToDelete());
        Test.stopTest(); 
        
    }
    
    
    Static  TestMethod void ValidateChangeCurrencyOpportunity1(){
        
        List<OpportunityLineItem> ListOLI=new List<OpportunityLineItem>();
        
        Account account=new Account(name='Test Account876',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1', Industry='Agriculture');
        insert account;
        
        
        Contact contact=new Contact(lastname='Test Contact1', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
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
        
        Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
        
       
        
        
        //Attachment attachment=new Attachment(Name='Test PDF', OwnerID=UserInfo.getUserId(), ParentID=contract.id, Body=Blob.toPdf('Test Body'), ContentType='application/pdf');
        //insert attachment;
        
        String yourFiles = 'Test Body';
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'test.pdf'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Test PDF1 '; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(yourFiles); // converting your binary string to Blog
        insert conVer;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = contract.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        
        RecordType RT1=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Configurator Opportunity' limit 1];
        
        Opportunity opportunity4=new Opportunity(name='Test1 Opportunity', AccountID=account.id);
        opportunity4.ownerid=UserInfo.getUserId();
        opportunity4.Billing_Contact__c=contact.id;
        opportunity4.Closedate=system.today();
        opportunity4.Primary_Contact__c=contact.id;
        opportunity4.CurrencyIsoCode='INR';
        opportunity4.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity4.NVM_Credit_Card_ID__c='1234';
        opportunity4.Amount=1000;
        opportunity4.Variation_Opportunity__c='NO';
        opportunity4.Order_Number__c=contract.id;
        opportunity4.Original_Opportunity__c=null;
        opportunity4.Annual_Contract_Value__c=1000.00;
        opportunity4.StageName='Prepare';   
        opportunity4.GCSC__c='Phone';
        opportunity4.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity4.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity4.RecordTypeID=RT1.id;
        opportunity4.Skip_Validation__c=True;
        opportunity4.Business_Type__c='Expansion';
        opportunity4.Forecast_Category__c='Commit';
        insert opportunity4;
        contract.Opportunity__c=opportunity4.Id;
        Update Contract;
        
        //Attachment attachment1=new Attachment(Name='Test PDF1', OwnerID=UserInfo.getUserId(), ParentID=opportunity4.id, Body=Blob.toPdf('Test Body'), ContentType='application/pdf');
        //insert attachment1;
        
                
        
        
        
        ContentVersion conVer1 = new ContentVersion();
        conVer1.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer1.PathOnClient = 'test.pdf'; // The files name, extension is very important here which will help the file in preview.
        conVer1.Title = 'Test PDF1 '; // Display name of the files
        conVer1.VersionData = EncodingUtil.base64Decode(yourFiles); // converting your binary string to Blog
        insert conVer1;
        
        conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer1.Id].ContentDocumentId;
        
                
        //Create ContentDocumentLink
        ContentDocumentLink cDe1 = new ContentDocumentLink();
        cDe1.ContentDocumentId = conDoc;
        cDe1.LinkedEntityId = opportunity4.Id; // you can use objectId,GroupId etc
        cDe1.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe1.Visibility = 'InternalUsers';
        insert cDe1;
        
        Discount_Summary__c DisSum = new Discount_Summary__c();
        DisSum.Name__c='test_DiscountSummary';
        DisSum.Discount_Percentage__c=10.00;
        DisSum.Discount_Amount__c=1000000;
        DisSum.CurrencyIsoCode='AUD';     
        DisSum.Discount_Type__c='Cross Sell';
        DisSum.Opportunity__c=opportunity4.id;
        insert DisSum;
        System.debug('>>'+DisSum);
        
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', opportunity4.id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(opportunity4);
        
        CurrencyChangeOpportunity ObjCCO1=new CurrencyChangeOpportunity(stdController);
        
        ObjCCO1.UpdateNewCurrencyOnOpportunity();
        
        Opportunity Opportunity3=[select id, currencyIsoCode, Order_Number__c,StageName,Order_Status__c from Opportunity where id=: Opportunity4.id limit 1];
        Opportunity3.Order_Number__c =Null;
        Opportunity3.StageName='Drive Close';
        Opportunity3.CurrencyIsoCode='USD';
        update Opportunity3 ;
        ObjCCO1.UpdateNewCurrencyOnOpportunity();
        
        Test.stopTest(); 
        
    }
    
    Static  TestMethod void ValidateChangeCurrencyOpportunity2(){
        
        List<OpportunityLineItem> ListOLI=new List<OpportunityLineItem>();
        
        Account account=new Account(name='Test Account654',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1', Industry='Agriculture');
        insert account;
        
        
        Contact contact=new Contact(lastname='Test Contact2', Accountid=account.id);
        contact.Same_As_The_Account_Billing_Address__c=true;
        contact.Mailing_Address_Line_1__c ='test';
        contact.Mailing_City__c='test';
        contact.Mailing_ZIP_Postal_Code__c ='110094';
        contact.Mailing_Country__c='India';
        
        insert contact;
        
        Contract contract1= new Contract(
            AccountId=account.Id,
            
            Agreement__c='Order',
            ContractTerm=12,
            Status='Rejected',
            StartDate=date.today(),
            Invoicing_Contact__c=contact.Id,
            Contract_Type__c='Consulting',
            Subscription_Start_Date__c=date.today()

        );
        insert contract1; 
        
        
        //Attachment attachment=new Attachment(Name='Test PDF', OwnerID=UserInfo.getUserId(), ParentID=contract1.id, Body=Blob.toPdf('Test Body'), ContentType='application/pdf');
        //insert attachment;
        String yourFiles = 'Test Body';
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'test.pdf'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Test PDF '; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(yourFiles); // converting your binary string to Blog
        insert conVer;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = contract1.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        
        RecordType RT1=[Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name='Configurator Opportunity' limit 1];
        
        Opportunity opportunity5=new Opportunity(name='Test1 Opportunity', AccountID=account.id);
        opportunity5.ownerid=UserInfo.getUserId();
        opportunity5.Billing_Contact__c=contact.id;
        opportunity5.Closedate=system.today();
        opportunity5.Primary_Contact__c=contact.id;
        opportunity5.CurrencyIsoCode='INR';
        opportunity5.Unconfirmed_Sun_Order_Number__c='1234';
        opportunity5.NVM_Credit_Card_ID__c='1234';
        opportunity5.Amount=1000;
        opportunity5.Variation_Opportunity__c='NO';
        opportunity5.Order_Number__c=contract1.id;
        opportunity5.Original_Opportunity__c=null;
        opportunity5.Annual_Contract_Value__c=1000.00;
        opportunity5.StageName='Prepare';   
        opportunity5.GCSC__c='Phone';
        opportunity5.OpportunityAmountMappedWithLead__c = 323.34;//**********
        opportunity5.OpportunityTypeMappedWithLead__c = 'New Business';//**********
        opportunity5.RecordTypeID=RT1.id;
        opportunity5.Skip_Validation__c=True;
        opportunity5.Business_Type__c='Expansion';
        opportunity5.Forecast_Category__c='Commit';
        insert opportunity5;
        contract1.Opportunity__c=opportunity5.Id;
        Update Contract1;
        
        Attachment attachment1=new Attachment(Name='Test PDF1', OwnerID=UserInfo.getUserId(), ParentID=opportunity5.id, Body=Blob.toPdf('Test Body'), ContentType='application/pdf');
        insert attachment1;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', opportunity5.id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(opportunity5);
        
        CurrencyChangeOpportunity ObjCCO2=new CurrencyChangeOpportunity(stdController);
        
        ObjCCO2.UpdateNewCurrencyOnOpportunity();
        
        Opportunity Opportunity3=[select id, currencyIsoCode, Order_Number__c,StageName,Order_Status__c from Opportunity where id=: opportunity5.id limit 1];
        Opportunity3.Order_Number__c =Contract1.id;
        Opportunity3.StageName='Drive Close';
        Opportunity3.CurrencyIsoCode='USD';
        update Opportunity3 ;
        ObjCCO2.UpdateNewCurrencyOnOpportunity();
        
        Test.stopTest(); 
        
    }
    
}
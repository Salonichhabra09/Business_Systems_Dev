@IsTest(SeeAllData = True) public class OpportunityLineItemTriggerManager1Test {
    static testmethod void Method1() {
        Profile pf = [ Select p.Name, p.Id From Profile p where p.Name = 'Commercial' limit 1 ];
        User user = [Select id from user where ProfileId =:pf.Id AND isActive = true limit 1];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;

        Account account = new Account(name = 'Test Account0987' + System.now(), industry = 'Legal', ownerid = user.id, Status__c = 'Approved',
                                      Billing_Address_Line_1__c = 'test', Billing_City__c = 'Test City', Billing_Country__c = 'India',
                                      Billing_State__c = 'Test', Billing_ZIP_Postal_Code__c = '1100110', BU__c = 'Australia - AU1');
        // insert account;
        Database.SaveResult sr = Database.insert(account, dml);

        Contact contact = new Contact(lastname = 'Test Contact1', Accountid = account.id);
        contact.Same_As_The_Account_Billing_Address__c = true;
        contact.Mailing_Address_Line_1__c = 'test';
        contact.Mailing_City__c = 'test';
        contact.Mailing_ZIP_Postal_Code__c = '110094';
        contact.Mailing_Country__c = 'India';
        contact.ownerid = user.id;

        insert contact;

        Contract contract =
            new Contract(AccountId = account.Id, Agreement__c = 'Order', ContractTerm = 12, Status = 'Draft', StartDate = date.today(),
                         Invoicing_Contact__c = contact.Id, Contract_Type__c = 'Consulting', Subscription_Start_Date__c = date.today());
        insert contract;

        Pricebook2 p = [ Select id, name from Pricebook2 where name = 'Standard Price Book' limit 1 ];
        RecordType RT = [ Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name = 'Standard Opportunity' limit 1 ];
        // Id priceBookID = Test.getStandardPricebookId();
        Opportunity opportunity = new Opportunity(name = 'Test Opportunity', AccountID = account.id);
        opportunity.ownerid = user.id;
        opportunity.Billing_Contact__c = contact.id;
        opportunity.Closedate = system.today();
        opportunity.Primary_Contact__c = contact.id;
        opportunity.CurrencyIsoCode = 'AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c = '1234';
        opportunity.NVM_Credit_Card_ID__c = '1234';
        opportunity.Amount = 1000;
        opportunity.Variation_Opportunity__c = 'NO';
        opportunity.Order_Number__c = contract.id;
        opportunity.Original_Opportunity__c = null;
        opportunity.Annual_Contract_Value__c = 1000.00;
        opportunity.StageName = 'First Appointment';
        opportunity.GCSC__c = 'Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;        //**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';  //**********
        opportunity.RecordTypeID = RT.id;
        opportunity.Skip_Validation__c = True;
        opportunity.Pricebook2Id = p.id;
        opportunity.Business_Type__c = 'Expansion';
        opportunity.Forecast_Category__c = 'Commit';
        opportunity.Multi_YearDeal__c = '2';
        opportunity.Opportunity_Deal_Year__c = 1;

        insert opportunity;
        pricebookentry PR = [select id from Pricebookentry where IsActive = true and currencyIsoCode = 'AUD' limit 1];

        OpportunityLineItem LI = new OpportunityLineItem(
            OpportunityId = opportunity.id, CurrencyChange__c = false, Package__c = 'Product', RenewableNew__c = 'Ongoing', PricebookEntryId = PR.id,
            TotalPrice = 100, Quantity = 1, Start_Date__c = system.today(), End_Date__c = system.today() + 1, Total_Equivalent_Units__c = 10,
            Platform__c = 'iAssess', Usage_Allowance__c = 'Capped', Product_family__c = 'Other', Product_Stream__c = 'Product in arrear');
        insert LI;
        LI.SOW_Required__c = true;
        update LI;
        LI.Product_family__c = 'Services';
        LI.Product_Stream__c = 'Product in advance';
        update LI;

        System.runAs(user) { Delete LI; }
    }

    static testmethod void Method2() {
        Profile pf = [ Select p.Name, p.Id From Profile p where p.Name = 'Commercial' limit 1 ];
        User user = [Select id from user where ProfileId =:pf.Id AND isActive = true limit 1];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;

        Account account = new Account(name = 'Test Account0987' + System.now(), industry = 'Legal', ownerid = user.id, Status__c = 'Approved',
                                      Billing_Address_Line_1__c = 'test', Billing_City__c = 'Test City', Billing_Country__c = 'India',
                                      Billing_State__c = 'Test', Billing_ZIP_Postal_Code__c = '1100110', BU__c = 'Australia - AU1');
        // insert account;
        Database.SaveResult sr = Database.insert(account, dml);

        Contact contact = new Contact(lastname = 'Test Contact1', Accountid = account.id);
        contact.Same_As_The_Account_Billing_Address__c = true;
        contact.Mailing_Address_Line_1__c = 'test';
        contact.Mailing_City__c = 'test';
        contact.Mailing_ZIP_Postal_Code__c = '110094';
        contact.Mailing_Country__c = 'India';
        contact.ownerid = user.id;

        insert contact;

        Contract contract =
            new Contract(AccountId = account.Id, Agreement__c = 'Order', ContractTerm = 12, Status = 'Draft', StartDate = date.today(),
                         Invoicing_Contact__c = contact.Id, Contract_Type__c = 'Consulting', Subscription_Start_Date__c = date.today());
        insert contract;

        Pricebook2 p = [ Select id, name from Pricebook2 where name = 'Standard Price Book' limit 1 ];
        RecordType RT = [ Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name = 'Standard Opportunity' limit 1 ];
        // Id priceBookID = Test.getStandardPricebookId();
        Opportunity opportunity = new Opportunity(name = 'Test Opportunity', AccountID = account.id);
        opportunity.ownerid = user.id;
        opportunity.Billing_Contact__c = contact.id;
        opportunity.Closedate = system.today();
        opportunity.Primary_Contact__c = contact.id;
        opportunity.CurrencyIsoCode = 'AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c = '1234';
        opportunity.NVM_Credit_Card_ID__c = '1234';
        opportunity.Amount = 1000;
        opportunity.Variation_Opportunity__c = 'NO';
        opportunity.Order_Number__c = contract.id;
        opportunity.Original_Opportunity__c = null;
        opportunity.Annual_Contract_Value__c = 1000.00;
        opportunity.StageName = 'First Appointment';
        opportunity.GCSC__c = 'Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;        //**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';  //**********
        opportunity.RecordTypeID = RT.id;
        opportunity.Skip_Validation__c = True;
        opportunity.Pricebook2Id = p.id;
        opportunity.Business_Type__c = 'Expansion';
        opportunity.Forecast_Category__c = 'Commit';
        opportunity.Multi_YearDeal__c = '2';
        opportunity.Opportunity_Deal_Year__c = 1;

        insert opportunity;
        pricebookentry PR = [select id from Pricebookentry where IsActive = true and currencyIsoCode = 'AUD' limit 1];

        // Create a list to hold the OpportunityLineItem objects
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lineItemsNew = new List<OpportunityLineItem>();

        // Define the different package values
        List<String> packageValues = new List<String>{'Product', 'Graduate Advanced', 'Graduate Advanced', 'Video Advanced', 'Service'};

        // Loop to create and add five OpportunityLineItem records to the list
        for (Integer i = 0; i < 5; i++) {
            OpportunityLineItem li = new OpportunityLineItem(OpportunityId = opportunity.id, CurrencyChange__c = false,
                                                             Package__c = packageValues[i],  // Assign different Package__c values
                                                             RenewableNew__c = 'Ongoing', PricebookEntryId = PR.id, TotalPrice = 100, Quantity = 1,
                                                             Start_Date__c = System.today(), End_Date__c = System.today() + 1,
                                                             Total_Equivalent_Units__c = 10, Platform__c = 'iAssess', Usage_Allowance__c = 'Capped',
                                                             Product_family__c = 'Other', Product_Stream__c = 'Product in arrear');
            lineItems.add(li);
            lineItemsNew = OpportunityLineItemTriggerManager1.handleSolCapBeforeInsert(lineItems);
            
        }

        // Insert all the OpportunityLineItem records in a single DML operation
        insert lineItemsNew;
        
        
    }

    static testmethod void SyncSolTest() {
        Profile pf = [ Select p.Name, p.Id From Profile p where p.Name = 'Commercial' limit 1 ];
        User user = [Select id from user where ProfileId =:pf.Id AND isActive = true limit 1];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;

        Account account = new Account(name = 'Test Account0987' + System.now(), industry = 'Legal', ownerid = user.id, Status__c = 'Approved',
                                      Billing_Address_Line_1__c = 'test', Billing_City__c = 'Test City', Billing_Country__c = 'India',
                                      Billing_State__c = 'Test', Billing_ZIP_Postal_Code__c = '1100110', BU__c = 'Australia - AU1');
        // insert account;
        Database.SaveResult sr = Database.insert(account, dml);

        Contact contact = new Contact(lastname = 'Test Contact1', Accountid = account.id);
        contact.Same_As_The_Account_Billing_Address__c = true;
        contact.Mailing_Address_Line_1__c = 'test';
        contact.Mailing_City__c = 'test';
        contact.Mailing_ZIP_Postal_Code__c = '110094';
        contact.Mailing_Country__c = 'India';
        contact.ownerid = user.id;

        insert contact;

        Contract contract =
            new Contract(AccountId = account.Id, Agreement__c = 'Order', ContractTerm = 12, Status = 'Draft', StartDate = date.today(),
                         Invoicing_Contact__c = contact.Id, Contract_Type__c = 'Consulting', Subscription_Start_Date__c = date.today());
        insert contract;

        Pricebook2 p = [ Select id, name from Pricebook2 where name = 'Standard Price Book' limit 1 ];
        RecordType RT = [ Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name = 'Standard Opportunity' limit 1 ];
        // Id priceBookID = Test.getStandardPricebookId();
        Opportunity opportunity = new Opportunity(name = 'Test Opportunity', AccountID = account.id);
        opportunity.ownerid = user.id;
        opportunity.Billing_Contact__c = contact.id;
        opportunity.Closedate = system.today();
        opportunity.Primary_Contact__c = contact.id;
        opportunity.CurrencyIsoCode = 'AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c = '1234';
        opportunity.NVM_Credit_Card_ID__c = '1234';
        opportunity.Amount = 1000;
        opportunity.Variation_Opportunity__c = 'Yes';
        opportunity.Order_Number__c = contract.id;
        opportunity.Original_Opportunity__c = null;
        opportunity.Annual_Contract_Value__c = 1000.00;
        opportunity.StageName = 'First Appointment';
        opportunity.GCSC__c = 'Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;        //**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';  //**********
        opportunity.RecordTypeID = RT.id;
        opportunity.Skip_Validation__c = True;
        opportunity.Pricebook2Id = p.id;
        opportunity.Business_Type__c = 'Expansion';
        opportunity.Forecast_Category__c = 'Commit';
        opportunity.Multi_YearDeal__c = '2';
        opportunity.Opportunity_Deal_Year__c = 1;

        insert opportunity;
        
        Opportunity opportunity1 = new Opportunity(name = 'Test Opportunity1', AccountID = account.id);
        opportunity1.ownerid = user.id;
        opportunity1.Billing_Contact__c = contact.id;
        opportunity1.Closedate = system.today();
        opportunity1.Primary_Contact__c = contact.id;
        opportunity1.CurrencyIsoCode = 'AUD';
        opportunity1.Unconfirmed_Sun_Order_Number__c = '1234';
        opportunity1.NVM_Credit_Card_ID__c = '1234';
        opportunity1.Amount = 1000;
        opportunity1.Variation_Opportunity__c = 'NO';
        opportunity1.Annual_Contract_Value__c = 1000.00;
        opportunity1.StageName = 'First Appointment';
        opportunity1.GCSC__c = 'Phone';
        opportunity1.RecordTypeID = RT.id;
        opportunity1.Skip_Validation__c = True;
        opportunity1.Pricebook2Id = p.id;
        opportunity1.Business_Type__c = 'Expansion';
        opportunity1.Forecast_Category__c = 'Commit';
        opportunity1.Opportunity_Deal_Year__c = 1;
        
        insert opportunity1;
        pricebookentry PR = [select id from Pricebookentry where IsActive = true and currencyIsoCode = 'AUD' limit 1];

        // Create a list to hold the OpportunityLineItem objects
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lineItemsNew = new List<OpportunityLineItem>();

        // Define the different package values
        List<String> packageValues = new List<String>{'Product', 'Graduate Advanced', 'Graduate Advanced', 'Video Advanced', 'Service'};

        // Loop to create and add five OpportunityLineItem records to the list
        for (Integer i = 0; i < 5; i++) {
            OpportunityLineItem li = new OpportunityLineItem(OpportunityId = opportunity1.id, CurrencyChange__c = false,
                                                             Package__c = packageValues[i],  // Assign different Package__c values
                                                             RenewableNew__c = 'Ongoing', PricebookEntryId = PR.id, TotalPrice = 100, Quantity = 1,
                                                             Start_Date__c = System.today(), End_Date__c = System.today() + 1,
                                                             Total_Equivalent_Units__c = 10, Platform__c = 'iAssess', Usage_Allowance__c = 'Capped',
                                                             Product_family__c = 'Other', Product_Stream__c = 'Product in arrear',Solution_Cap__c=10);
            lineItems.add(li);
        }
        
        for (Integer i = 0; i < 5; i++) {
            OpportunityLineItem li = new OpportunityLineItem(OpportunityId = opportunity.id, CurrencyChange__c = false,
                                                             Package__c = packageValues[i],  // Assign different Package__c values
                                                             RenewableNew__c = 'OneOff', PricebookEntryId = PR.id, TotalPrice = 1000, Quantity = 1,
                                                             Start_Date__c = System.today(), End_Date__c = System.today() + 2,
                                                             Total_Equivalent_Units__c = 20, Platform__c = 'iAssess', Usage_Allowance__c = 'Capped',
                                                             Product_family__c = 'Other', Product_Stream__c = 'Product in arrear',Solution_Cap__c=15);
            lineItemsNew.add(li);
        }

        // Insert all the OpportunityLineItem records in a single DML operation
        insert lineItemsNew;
        // Create LineItemWrapper instance
        OpportunityLineItemTriggerManager1.LineItemWrapper wrapper = new OpportunityLineItemTriggerManager1.LineItemWrapper();
        wrapper.VariationLineItems = lineItems;
        wrapper.ExistingPHLineItems = lineItemsNew;
        wrapper.isOrderCancelled = false;
        // Call the method
        Test.startTest();
        OpportunityLineItemTriggerManager1.SyncSolCapOnPlaceholderOpp(new List<OpportunityLineItemTriggerManager1.LineItemWrapper> { wrapper });
        Test.stopTest();
    }
    
    static testmethod void SyncSolOrderCancellationTest() {
        Profile pf = [ Select p.Name, p.Id From Profile p where p.Name = 'Commercial' limit 1 ];
        User user = [Select id from user where ProfileId =:pf.Id AND isActive = true limit 1];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;

        Account account = new Account(name = 'Test Account0987' + System.now(), industry = 'Legal', ownerid = user.id, Status__c = 'Approved',
                                      Billing_Address_Line_1__c = 'test', Billing_City__c = 'Test City', Billing_Country__c = 'India',
                                      Billing_State__c = 'Test', Billing_ZIP_Postal_Code__c = '1100110', BU__c = 'Australia - AU1');
        // insert account;
        Database.SaveResult sr = Database.insert(account, dml);

        Contact contact = new Contact(lastname = 'Test Contact1', Accountid = account.id);
        contact.Same_As_The_Account_Billing_Address__c = true;
        contact.Mailing_Address_Line_1__c = 'test';
        contact.Mailing_City__c = 'test';
        contact.Mailing_ZIP_Postal_Code__c = '110094';
        contact.Mailing_Country__c = 'India';
        contact.ownerid = user.id;

        insert contact;

        Contract contract =
            new Contract(AccountId = account.Id, Agreement__c = 'Order', ContractTerm = 12, Status = 'Draft', StartDate = date.today(),
                         Invoicing_Contact__c = contact.Id, Contract_Type__c = 'Consulting', Subscription_Start_Date__c = date.today());
        insert contract;

        Pricebook2 p = [ Select id, name from Pricebook2 where name = 'Standard Price Book' limit 1 ];
        RecordType RT = [ Select r.Id, r.Name From RecordType r where r.SobjectType = 'Opportunity' and r.Name = 'Standard Opportunity' limit 1 ];
        // Id priceBookID = Test.getStandardPricebookId();
        Opportunity opportunity = new Opportunity(name = 'Test Opportunity', AccountID = account.id);
        opportunity.ownerid = user.id;
        opportunity.Billing_Contact__c = contact.id;
        opportunity.Closedate = system.today();
        opportunity.Primary_Contact__c = contact.id;
        opportunity.CurrencyIsoCode = 'AUD';
        opportunity.Unconfirmed_Sun_Order_Number__c = '1234';
        opportunity.NVM_Credit_Card_ID__c = '1234';
        opportunity.Amount = 1000;
        opportunity.Variation_Opportunity__c = 'Yes';
        opportunity.Order_Number__c = contract.id;
        opportunity.Original_Opportunity__c = null;
        opportunity.Annual_Contract_Value__c = 1000.00;
        opportunity.StageName = 'First Appointment';
        opportunity.GCSC__c = 'Phone';
        opportunity.OpportunityAmountMappedWithLead__c = 323.34;        //**********
        opportunity.OpportunityTypeMappedWithLead__c = 'New Business';  //**********
        opportunity.RecordTypeID = RT.id;
        opportunity.Skip_Validation__c = True;
        opportunity.Pricebook2Id = p.id;
        opportunity.Business_Type__c = 'Expansion';
        opportunity.Forecast_Category__c = 'Commit';
        opportunity.Multi_YearDeal__c = '2';
        opportunity.Opportunity_Deal_Year__c = 1;

        insert opportunity;
        
        Opportunity opportunity1 = new Opportunity(name = 'Test Opportunity1', AccountID = account.id);
        opportunity1.ownerid = user.id;
        opportunity1.Billing_Contact__c = contact.id;
        opportunity1.Closedate = system.today();
        opportunity1.Primary_Contact__c = contact.id;
        opportunity1.CurrencyIsoCode = 'AUD';
        opportunity1.Unconfirmed_Sun_Order_Number__c = '1234';
        opportunity1.NVM_Credit_Card_ID__c = '1234';
        opportunity1.Amount = 1000;
        opportunity1.Variation_Opportunity__c = 'NO';
        opportunity1.Annual_Contract_Value__c = 1000.00;
        opportunity1.StageName = 'First Appointment';
        opportunity1.GCSC__c = 'Phone';
        opportunity1.RecordTypeID = RT.id;
        opportunity1.Skip_Validation__c = True;
        opportunity1.Pricebook2Id = p.id;
        opportunity1.Business_Type__c = 'Expansion';
        opportunity1.Forecast_Category__c = 'Commit';
        opportunity1.Opportunity_Deal_Year__c = 1;
        
        insert opportunity1;
        pricebookentry PR = [select id from Pricebookentry where IsActive = true and currencyIsoCode = 'AUD' limit 1];

        // Create a list to hold the OpportunityLineItem objects
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lineItemsNew = new List<OpportunityLineItem>();

        // Define the different package values
        List<String> packageValues = new List<String>{'Product', 'Graduate Advanced', 'Graduate Advanced', 'Video Advanced', 'Service'};

        // Loop to create and add five OpportunityLineItem records to the list
        for (Integer i = 0; i < 5; i++) {
            OpportunityLineItem li = new OpportunityLineItem(OpportunityId = opportunity1.id, CurrencyChange__c = false,
                                                             Package__c = packageValues[i],  // Assign different Package__c values
                                                             RenewableNew__c = 'Ongoing', PricebookEntryId = PR.id, TotalPrice = 100, Quantity = 1,
                                                             Start_Date__c = System.today(), End_Date__c = System.today() + 1,
                                                             Total_Equivalent_Units__c = 10, Platform__c = 'iAssess', Usage_Allowance__c = 'Capped',
                                                             Product_family__c = 'Other', Product_Stream__c = 'Product in arrear',Solution_Cap__c=10);
            lineItems.add(li);
        }
        
        for (Integer i = 0; i < 5; i++) {
            OpportunityLineItem li = new OpportunityLineItem(OpportunityId = opportunity.id, CurrencyChange__c = false,
                                                             Package__c = packageValues[i],  // Assign different Package__c values
                                                             RenewableNew__c = 'OneOff', PricebookEntryId = PR.id, TotalPrice = 1000, Quantity = 1,
                                                             Start_Date__c = System.today(), End_Date__c = System.today() + 2,
                                                             Total_Equivalent_Units__c = 20, Platform__c = 'iAssess', Usage_Allowance__c = 'Capped',
                                                             Product_family__c = 'Other', Product_Stream__c = 'Product in arrear',Solution_Cap__c=15);
            lineItemsNew.add(li);
        }

        // Insert all the OpportunityLineItem records in a single DML operation
        insert lineItemsNew;
        // Create LineItemWrapper instance
        OpportunityLineItemTriggerManager1.LineItemWrapper wrapper = new OpportunityLineItemTriggerManager1.LineItemWrapper();
        wrapper.VariationLineItems = lineItems;
        wrapper.ExistingPHLineItems = lineItemsNew;
        wrapper.isOrderCancelled = true;
        // Call the method
        Test.startTest();
        OpportunityLineItemTriggerManager1.SyncSolCapOnPlaceholderOpp(new List<OpportunityLineItemTriggerManager1.LineItemWrapper> { wrapper });
        Test.stopTest();
    }
}
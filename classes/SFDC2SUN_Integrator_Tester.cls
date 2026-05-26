/**************************************************************************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 15/02/2021
DESCRIPTION :- To cover & test the logic in SFDC2SUN_Integrator Class. 
***************************************************************************************************************************************/
@isTest (seealldata=true) 
public class SFDC2SUN_Integrator_Tester {
  /*static void tstSunIntegrator()
    {
        /*Account account = [Select id,SFDC2SUN_SfdcVersion__c,SFDC2SUN_TransferStatus__c, SFDC2SUN_Log__c FROM Account
                           where (NOT BU__c like '%UK5%') AND (NOT BU__c like '%DK5%') AND (NOT BU__c like '%SE5%') AND
                           (NOT BU__c like '%DE1%') AND (NOT BU__c like '%US1%') AND (NOT BU__c like '%BE1%') AND
                           (NOT BU__c like '%FR1%') AND (NOT BU__c like '%NL1%') limit 1];*/
        /*Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Switzerland - CH1');
        insert account;
        Contact con=new Contact(lastname='Test Contact', Accountid=account.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert con;                 
        account.SFDC2SUN_TransferStatus__c = 'Not Transferred';
        account.SFDC2SUN_SfdcVersion__c = 0;
        update account;
        India_GST__c IndiaGst = TestDataUtility.getIndiaGST(account.id);
        insert IndiaGst;
        India_GST__c IndiaGst1 = [select id , ITN__c from India_GST__c where id =:IndiaGst.id];
        SFDC2SUN_Integrator.getInGSTTransferXml(IndiaGst1.ITN__c);
        SFDC2Sun_Transfer_or_Sync_History__c hist = new SFDC2Sun_Transfer_or_Sync_History__c();
        hist.Version__c = 0;
        hist.Start_Date__c = System.now();
        hist.India_GST__c= IndiaGst.id;
        hist.User__c =  UserInfo.getUserId();
        hist.Status__c =  'Transferring';
        hist.Action__c =  'Transfer';
        insert hist;
        SFDC2SUN_Integrator.completeGST_Transfer(IndiaGst1.ITN__c , 'abc');   // added by pankhuri To cover GST success
        Test.startTest();
        //SFDC2SUN_Integrator.getAccount(account.id);
        //system.assertEquals(account.id, account.id);
        SFDC2SUN_Integrator.startAccountTransfer(account.id);
        string accountXML = SFDC2SUN_Integrator.getAccountTransferXml(account.id);
        accountXML = SFDC2SUN_Integrator.getAccountSyncXml(account.id, 1);
        SFDC2SUN_Integrator.completeAccountTransfer(account.id , '');
        SFDC2SUN_Integrator.completeAccountSync(account.id,1, '');
        SFDC2SUN_Integrator.completeAccountTransfer(account.id , 'failed');
        SFDC2SUN_Integrator.completeAccountSync(account.id ,1, 'failed');
        List<string> accountIdsSet = SFDC2SUN_Integrator.getFailedAccountIds();
        
        
        Test.stopTest();
    }
    @isTest(SeeAllData=true) static void tstSunIntegrator1()
    {
        /*Account account = [Select id,SFDC2SUN_SfdcVersion__c,SFDC2SUN_TransferStatus__c, SFDC2SUN_Log__c FROM Account
                           where (NOT BU__c like '%UK5%') AND (NOT BU__c like '%DK5%') AND (NOT BU__c like '%SE5%') AND
                           (NOT BU__c like '%DE1%') AND (NOT BU__c like '%US1%') AND (NOT BU__c like '%BE1%') AND
                           (NOT BU__c like '%FR1%') AND (NOT BU__c like '%NL1%') limit 1];*/
        /*Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Switzerland - CH1');
        insert account;                   
        account.SFDC2SUN_TransferStatus__c = 'Not Transferred';
        account.SFDC2SUN_SfdcVersion__c = 0;
        update account;
        India_GST__c IndiaGst = TestDataUtility.getIndiaGST(account.id);
        insert IndiaGst;
        India_GST__c IndiaGst1 = [select id , ITN__c from India_GST__c where id =:IndiaGst.id];
        SFDC2SUN_Integrator.getInGSTTransferXml(IndiaGst1.ITN__c);
        SFDC2SUN_Integrator.completeGST_Transfer(IndiaGst1.ITN__c , '');   // To cover GST success
        SFDC2SUN_Integrator.startAccountTransfer(account.id);
        string accountXML = SFDC2SUN_Integrator.getAccountTransferXml(account.id);
        accountXML = SFDC2SUN_Integrator.getAccountSyncXml(account.id, 1);
        SFDC2SUN_Integrator.completeAccountTransfer(account.id , '');
        SFDC2SUN_Integrator.completeAccountSync(account.id,1, '');
        SFDC2SUN_Integrator.completeAccountTransfer(account.id , 'failed');
        Test.startTest();
        SFDC2SUN_Integrator.completeAccountSync(account.id ,1, 'failed');
        List<string> accountIdsSet = SFDC2SUN_Integrator.getFailedAccountIds();
        
        //Contact contact = [Select id,SFDC2SUN_TransferStatus__c, SFDC2SUN_Log__c FROM Contact limit 1];
        Contact contact=new Contact(lastname='Test Contact', Accountid=account.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert contact;
        contact.SFDC2SUN_TransferStatus__c = 'Not Transferred';
        contact.SFDC2SUN_TransferredOn__c = Datetime.Now();
        contact.SFDC2SUN_SyncedOn__c = Datetime.Now();
        contact.SFDC2SUN_TransferredBy__c = UserInfo.getUserId();
        contact.SFDC2SUN_SFDCVersion__c = 1;
        contact.SFDC2SUN_SunVersion__c= 1;
        contact.SFDC2SUN_Log__c += Datetime.Now() +': Setting test data.';
        update contact;
        
        SFDC2SUN_Integrator.startContactTransfer(contact.id);
        String contactXML = SFDC2SUN_Integrator.getContactTransferXml(contact.id);
        contactXML = SFDC2SUN_Integrator.getContactSyncXml(contact.id, 1);
        contactXML = SFDC2SUN_Integrator.getContactAndAccountTransferXml(contact.id);
        SFDC2SUN_Integrator.completeContactTransfer(contact.id , '');
        SFDC2SUN_Integrator.completeContactSync(contact.id ,1, '');
        
        SFDC2SUN_Integrator.completeContactTransfer(contact.id , 'failed');
        SFDC2SUN_Integrator.completeContactSync(contact.id ,1, 'failed');
        List<String> contactIdsSet = SFDC2SUN_Integrator.getFailedContactIds();
        Test.stopTest();
    }
    @isTest (Seealldata=true) static void tstSunIntegrator2()   // Test invoice header Success Creation in Infor10
    {
        Account a =CreateTestData.GetAccount();
        Contact c =   CreateTestData.getContact(a.id);
        Opportunity o =  CreateTestData.getOpportunity(a.id , c.id);
        Contract order =CreateTestData.getContract(a.id , o.id);
        Order realorder=CreateTestData.getOrder(a , order.id);
        Contract_Line__c  cl = CreateTestData.getOrderLine(order.id);
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();  // New Header
        invoiceHeader.Order__c = realorder.Id;
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.CurrencyIsoCode = realorder.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = Date.Today();
        invoiceHeader.Billing_Contact__c = c.id;
        invoiceHeader.BU__c = a.BU__c;
        invoiceHeader.Invoice_Comments__c='Test Comments';
        invoiceHeader.Sales_Type__c='SFSOLSPLITCN';
        invoiceHeader.Credit_Reason_Code__c='S01 - Goods returned';
        insert invoiceHeader;
        
        Contract_Invoice_Line__c invoiceLine = new Contract_Invoice_Line__c ();   // New Invoice Line
        invoiceLine.Contract_Line_Id__c = cl.Id;
        invoiceLine.CurrencyIsoCode = cl.CurrencyIsoCode;
        invoiceLine.Invoice_Header_Id__c = invoiceHeader.Id;
        invoiceLine.Quantity__c = 10;
        invoiceLine.Invoice_Line_Total__c=20;
        invoiceLine.Discount_Amount__c =2;
        invoiceLine.Price__c=200;
        invoiceLine.Month__c = '201106';
        //invoiceLine.SUN_IM_lookup_code__c = '123';
        
        insert invoiceLine;
        
        SFDC2Sun_Transfer_or_Sync_History__c hist = new SFDC2Sun_Transfer_or_Sync_History__c();
        hist.Version__c = 0;
        hist.Start_Date__c = System.now();
        hist.Invoice_Header__c = invoiceHeader.id;
        hist.User__c =  UserInfo.getUserId();
        hist.Status__c =  'Transferring';
        hist.Action__c =  'Transfer';
        insert hist;
        
        SFDC2SUN_Integrator.generateSalesOrderTransferXml(invoiceHeader.id);
        SFDC2SUN_Integrator.completeSalesOrderTransfer(invoiceHeader.id, '<SalesOrderTransactionReference> MK123 </SalesOrderTransactionReference>'); 
        
        //Changes added by saloni chhabra for Manual initation button
        SFDC2SUN_Integrator.startInvoiceTransfer(invoiceHeader.id);
        SFDC2SUN_Integrator.completeSalesOrderTransferbutton(invoiceHeader.id, 'S2I-MK123');    
    }
    
    // To cover GST failure in Infor10
    @isTest(SeeAllData=true) static void tstSunIntegrator3()
    {
        /*Account account = [Select id,SFDC2SUN_SfdcVersion__c,SFDC2SUN_TransferStatus__c, SFDC2SUN_Log__c FROM Account
                           where (NOT BU__c like '%UK5%') AND (NOT BU__c like '%DK5%') AND (NOT BU__c like '%SE5%') AND
                           (NOT BU__c like '%DE1%') AND (NOT BU__c like '%US1%') AND (NOT BU__c like '%BE1%') AND
                           (NOT BU__c like '%FR1%') AND (NOT BU__c like '%NL1%') limit 1];*/
        /*Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Switzerland - CH1');
        insert account;
        Contact con=new Contact(lastname='Test Contact', Accountid=account.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert con;                   
        account.SFDC2SUN_TransferStatus__c = 'Not Transferred';
        account.SFDC2SUN_SfdcVersion__c = 0;
        update account;
        India_GST__c IndiaGst = TestDataUtility.getIndiaGST(account.id);
        insert IndiaGst;
        India_GST__c IndiaGst1 = [select id , ITN__c from India_GST__c where id =:IndiaGst.id];
        SFDC2SUN_Integrator.getInGSTTransferXml(IndiaGst1.ITN__c);
        SFDC2Sun_Transfer_or_Sync_History__c hist = new SFDC2Sun_Transfer_or_Sync_History__c();
        hist.Version__c = 0;
        hist.Start_Date__c = System.now();
        hist.India_GST__c= IndiaGst.id;
        hist.User__c =  UserInfo.getUserId();
        hist.Status__c =  'Transferring';
        hist.Action__c =  'Transfer';
        insert hist;
        SFDC2SUN_Integrator.completeGST_Transfer(IndiaGst1.ITN__c , '<UserText>Abort() method called from SASI script </UserText>');   // added by pankhuri
        Test.startTest();
    }   
    
    @isTest (Seealldata=true) static void tstSunIntegrator4()   // Test invoice header Failure Creation in Infor10
    {
        Account a =CreateTestData.GetAccount();
        Contact c =   CreateTestData.getContact(a.id);
        Opportunity o =  CreateTestData.getOpportunity(a.id , c.id);
        Contract order =CreateTestData.getContract(a.id , o.id);
        Order realorder=CreateTestData.getOrder(a , order.id);
        Contract_Line__c  cl = CreateTestData.getOrderLine(order.id);
        
        Contract_Invoice_Header__c invoiceHeader = new Contract_Invoice_Header__c();  // New Header
        invoiceHeader.Order__c = realorder.Id;
        invoiceHeader.PO_number__c = '12312323423';
        invoiceHeader.CurrencyIsoCode = realorder.CurrencyIsoCode;
        invoiceHeader.Service_Start_Date__c = Date.Today();
        invoiceHeader.Billing_Contact__c = c.id;
        invoiceHeader.BU__c = a.BU__c;
        invoiceHeader.Invoice_Comments__c='Test Comments';
        invoiceHeader.Sales_Type__c='SFSOLSPLITCN';
        invoiceHeader.Credit_Reason_Code__c='S01 - Goods returned';
        insert invoiceHeader;
        
        Contract_Invoice_Line__c invoiceLine = new Contract_Invoice_Line__c ();   // New Invoice Line
        invoiceLine.Contract_Line_Id__c = cl.Id;
        invoiceLine.CurrencyIsoCode = cl.CurrencyIsoCode;
        invoiceLine.Invoice_Header_Id__c = invoiceHeader.Id;
        invoiceLine.Quantity__c = 10;
        invoiceLine.Invoice_Line_Total__c=20;
        invoiceLine.Discount_Amount__c =2;
        invoiceLine.Price__c=200;
        
        invoiceLine.Month__c = '201106';
        //invoiceLine.SUN_IM_lookup_code__c = '123';
        
        insert invoiceLine;
        
        SFDC2Sun_Transfer_or_Sync_History__c hist = new SFDC2Sun_Transfer_or_Sync_History__c();
        hist.Version__c = 0;
        hist.Start_Date__c = System.now();
        hist.Invoice_Header__c = invoiceHeader.id;
        hist.User__c =  UserInfo.getUserId();
        hist.Status__c =  'Transferring';
        hist.Action__c =  'Transfer';
        insert hist;
        
        SFDC2SUN_Integrator.generateSalesOrderTransferXml(invoiceHeader.id);
        SFDC2SUN_Integrator.startInvoiceTransfer(invoiceHeader.id);
        try{
            SFDC2SUN_Integrator.completeSalesOrderTransfer(invoiceHeader.id, '<UserText>Abort() method called from SASI script </UserText>'); 
            SFDC2SUN_Integrator.completeSalesOrderTransferbutton(invoiceHeader.id, 'Abort() method called from SASI script');
        }
        catch(Exception e){}
    }
    @isTest (Seealldata=true) static void tstSunIntegrator5()   // Test invoice header Failure Creation in Infor10
    {
        //Contact contact = [Select id,SFDC2SUN_TransferStatus__c, SFDC2SUN_Log__c FROM Contact limit 1];
        Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Switzerland - CH1');
        insert account;
        Contact contact=new Contact(lastname='Test Contact', Accountid=account.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
        insert contact;
        contact.SFDC2SUN_TransferStatus__c = 'Not Transferred';
        contact.SFDC2SUN_TransferredOn__c = Datetime.Now();
        contact.SFDC2SUN_SyncedOn__c = Datetime.Now();
        contact.SFDC2SUN_TransferredBy__c = UserInfo.getUserId();
        contact.SFDC2SUN_SFDCVersion__c = 1;
        contact.SFDC2SUN_SunVersion__c= 1;
        contact.SFDC2SUN_Log__c += Datetime.Now() +': Setting test data.';
        update contact;
        Test.startTest();
        Account a =CreateTestData.GetAccount();
        SFDC2SUN_Integrator.getAccount(a.id);
        SFDC2SUN_Integrator.getContact(contact.Id);
        SFDC2SUN_Integrator.getincludeAccount(contact.id);
        SFDC2SUN_Integrator.startContactSync(contact.id,1);
        SFDC2SUN_Integrator.clearHistory('abc');
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true) static void tstTransferContactToSun()
    {
            //Contact contact = [Select id,SFDC2SUN_TransferStatus__c, SFDC2SUN_Log__c,Same_As_The_Account_Billing_Address__c FROM Contact limit 1];
            Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Switzerland - CH1');
            insert account;
            Contact contact=new Contact(lastname='Test Contact', Accountid=account.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
            insert contact;
            contact.SFDC2SUN_TransferStatus__c = 'Not Transferred';
            contact.Same_As_The_Account_Billing_Address__c = true;
            contact.SFDC2SUN_TransferredOn__c = Datetime.Now();
            contact.SFDC2SUN_SyncedOn__c = Datetime.Now();
            contact.SFDC2SUN_TransferredBy__c = UserInfo.getUserId();
            contact.SFDC2SUN_SFDCVersion__c = 1;
            contact.SFDC2SUN_SunVersion__c= 1;
            contact.SFDC2SUN_Log__c += Datetime.Now() +': Setting test data.';
            update contact;
            PageReference pg = Page.SFDC2SUN_ContactTransfer;
            pg.getParameters().put('id',contact.id);
            Test.setCurrentPage(pg);
            ApexPages.StandardController sc = new ApexPages.StandardController(contact);
            SFDC2SUN_ContactTransferService.isApexTest = true;
            SFDC2SUN_ContactTransferController tranContactToSun = new SFDC2SUN_ContactTransferController(sc); 
            //tranContactToSun.includeAccount = true;
            tranContactToSun.getContact();
            tranContactToSun.showHideHistory();
            tranContactToSun.showHideHistory();
            tranContactToSun.startContactTransfer();
            tranContactToSun.completeContactTransfer();
            
            SFDC2SUN_ContactTransferController.transferContact(contact.id,true);
            tranContactToSun.completeContactTransfer();
            tranContactToSun.startContactSync();
            tranContactToSun.completeContactSync();
            tranContactToSun.errorMessage = '';
            tranContactToSun.completeContactTransfer();
            tranContactToSun.completeContactSync();
            //tranContactToSun.transferContactToSun();
    }
    @isTest(SeeAllData=true) static void tstTransferContactToSun1()
    {
            //Contact contact = [Select id,SFDC2SUN_TransferStatus__c,SFDC2SUN_SfdcVersion__c, SFDC2SUN_Log__c,Same_As_The_Account_Billing_Address__c FROM Contact limit 1];
            Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Switzerland - CH1');
            insert account;
            Contact contact=new Contact(lastname='Test Contact', Accountid=account.id,Same_As_The_Account_Billing_Address__c=true,Mailing_Address_Line_1__c ='test',Mailing_City__c='test',Mailing_ZIP_Postal_Code__c ='110094',Mailing_Country__c='India');
            insert contact;
            contact.SFDC2SUN_TransferStatus__c = 'Transferring';
            contact.SFDC2SUN_SfdcVersion__c = 1;
            contact.Same_As_The_Account_Billing_Address__c = true;
            update contact;
            
            
            
            
            PageReference pg = Page.SFDC2SUN_ContactTransfer;
            pg.getParameters().put('id',contact.id);
            Test.setCurrentPage(pg);
            ApexPages.StandardController sc = new ApexPages.StandardController(contact);
            
            SFDC2SUN_ContactTransferController tranContactToSun1 = new SFDC2SUN_ContactTransferController(sc); 
            tranContactToSun1.showHideHistory();
            contact.SFDC2SUN_TransferStatus__c = 'Out of Sync';
            contact.SFDC2SUN_SyncStatus__c  = 'Out of Sync';
            update contact;
            SFDC2SUN_ContactTransferController tranContactToSun2 = new SFDC2SUN_ContactTransferController(sc); 
            tranContactToSun2.showHideHistory();
            
            
            
            
            
            SFDC2SUN_ContactTransferService contactTransferService = new SFDC2SUN_ContactTransferService();
            SFDC2SUN_ContactTransferService.ContactTransferServiceSoap contactTransferServiceSoap = new SFDC2SUN_ContactTransferService.ContactTransferServiceSoap();
            contactTransferServiceSoap.timeout_x = 60000;
            SFDC2SUN_ContactTransferService.isApexTest = true;
            contactTransferServiceSoap.transferContact(contact.id,true);
    }
    
    @isTest(SeeAllData=true) static void tstTransferAccountToSun()
    {
           /* Account account = [Select id,SFDC2SUN_TransferStatus__c, SFDC2SUN_SfdcVersion__c,SFDC2SUN_Log__c FROM Account 
                            where (NOT BU__c like '%UK5%') AND (NOT BU__c like '%DK5%') AND (NOT BU__c like '%SE5%') AND
                             (NOT BU__c like '%DE1%') AND (NOT BU__c like '%US1%') AND (NOT BU__c like '%BE1%') AND 
                              (NOT BU__c like '%FR1%') AND (NOT BU__c like '%NL1%') limit 1];*/
            /*Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Switzerland - CH1');
            insert account;                 
            account.SFDC2SUN_TransferStatus__c = 'Not Transferred';
            account.SFDC2SUN_SfdcVersion__c = 0;
            update account;
            PageReference pg = Page.SFDC2SUN_AccountTransfer;
            pg.getParameters().put('id',account.id);
            Test.setCurrentPage(pg);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            
            SFDC2SUN_AccountTransferController tranAccountToSun = new SFDC2SUN_AccountTransferController(sc); 
            tranAccountToSun.getAccount();
            test.startTest();
            tranAccountToSun.showHideHistory();
            tranAccountToSun.showHideHistory();
            tranAccountToSun.startAccountTransfer();
            
            tranAccountToSun.completeAccountTransfer();
            SFDC2SUN_AccountTransferService.isApexTest = true;
            SFDC2SUN_AccountTransferController.transferAccount(account.id);
            tranAccountToSun.completeAccountTransfer();
            tranAccountToSun.startAccountSync();
            tranAccountToSun.completeAccountSync();
            tranAccountToSun.errorMessage = '';
            //tranAccountToSun.completeAccountTransfer();
            //tranAccountToSun.completeAccountSync();
            Test.stopTest();
    }
    @isTest(SeeAllData=true) static void tstTransferAccountToSun11()
    {
            /*Account account = [Select id,SFDC2SUN_TransferStatus__c,SFDC2SUN_SfdcVersion__c, SFDC2SUN_Log__c FROM Account 
                                where (NOT BU__c like '%UK5%') AND (NOT BU__c like '%DK5%') AND (NOT BU__c like '%SE5%') AND
                             (NOT BU__c like '%DE1%') AND (NOT BU__c like '%US1%') AND (NOT BU__c like '%BE1%') AND
                              (NOT BU__c like '%FR1%') AND (NOT BU__c like '%NL1%') limit 1];*/
            /*Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Switzerland - CH1');
            insert account;   
            account.SFDC2SUN_TransferStatus__c = 'Not Transferred';
            account.SFDC2SUN_SfdcVersion__c = 0;
            update account;
            PageReference pg = Page.SFDC2SUN_AccountTransfer;
            pg.getParameters().put('id',account.id);
            Test.setCurrentPage(pg);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            
            SFDC2SUN_AccountTransferController tranAccountToSun = new SFDC2SUN_AccountTransferController(sc); 
            tranAccountToSun.getAccount();
            Test.startTest();
            tranAccountToSun.showHideHistory();
            tranAccountToSun.showHideHistory();
            tranAccountToSun.startAccountTransfer();
            
            tranAccountToSun.completeAccountTransfer();
            SFDC2SUN_AccountTransferService.isApexTest = true;
            SFDC2SUN_AccountTransferController.transferAccount(account.id);
            //tranAccountToSun.completeAccountTransfer();
            tranAccountToSun.startAccountSync();
            //tranAccountToSun.completeAccountSync();
            tranAccountToSun.errorMessage = '';
            tranAccountToSun.completeAccountTransfer();
            tranAccountToSun.completeAccountSync();
            Test.stopTest();
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="?"></param>
    /*@isTest(SeeAllData=true) static void tstTransferAccountToSun1()
    {
            /*Account account = [Select id,SFDC2SUN_TransferStatus__c, SFDC2SUN_SfdcVersion__c,SFDC2SUN_Log__c FROM Account 
                                where (NOT BU__c like '%UK5%') AND (NOT BU__c like '%DK5%') AND (NOT BU__c like '%SE5%') AND
                             (NOT BU__c like '%DE1%') AND (NOT BU__c like '%US1%') AND (NOT BU__c like '%BE1%') AND
                              (NOT BU__c like '%FR1%') AND (NOT BU__c like '%NL1%') limit 1];*/
            /*Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='India',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Switzerland - CH1');
            insert account;   
            account.SFDC2SUN_TransferStatus__c = 'Transferring';
            account.SFDC2SUN_SfdcVersion__c = 0;
            update account;
            
            PageReference pg = Page.SFDC2SUN_AccountTransfer;
            pg.getParameters().put('id',account.id);
            Test.setCurrentPage(pg);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            
            SFDC2SUN_AccountTransferController tranAccountToSun1 = new SFDC2SUN_AccountTransferController(sc); 
            account.SFDC2SUN_TransferStatus__c = 'Out of Sync';
            account.SFDC2SUN_SyncStatus__c  = 'Out of Sync';
            update account;
            SFDC2SUN_AccountTransferController tranAccountToSun2 = new SFDC2SUN_AccountTransferController(sc); 
            tranAccountToSun2.showHideHistory();
            
            SFDC2SUN_AccountTransferService accountTransferService = new SFDC2SUN_AccountTransferService();
            SFDC2SUN_AccountTransferService.AccountTransferServiceSoap accountTransferServiceSoap = new SFDC2SUN_AccountTransferService.AccountTransferServiceSoap();
            accountTransferServiceSoap.timeout_x = 60000;
            SFDC2SUN_AccountTransferService.isApexTest = true;
            accountTransferServiceSoap.transferAccount(account.id);
            
            SFDC2SUN_LogViewer logViewer = new SFDC2SUN_LogViewer();
            //Account account = [Select id,SFDC2SUN_TransferStatus__c, SFDC2SUN_Log__c FROM Account limit 1];
            logViewer.accountOrContactId = account.id;
            logViewer.objectType = 'Account';
            logViewer.setSFDC2SunLogs(account.SFDC2SUN_Log__c);
            logViewer.clearHistory();
            SFDC2SUN_AccountTransferController.increaseTestCoverage();
    } */

}
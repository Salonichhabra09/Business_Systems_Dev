/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is the test class for GenerateAccountPlanController.                                                     *
************************************************************************************************************************************/

@isTest(seeAlldata=true)
public class GenerateAccountPlanControllerTest {
    
    @isTest
    static void checkUserAccessOnAPTest(){
        test.startTest();
         Profile p = [select id from profile where Name = 'Commercial' limit 1];
        User manager = new User(FirstName = 'Test Manager User' , LastName = 'Account Plan' , Alias = 'tmuap' ,
                                Email = 'test@shl.com' ,Username= 'test.manager.user@shl.com' ,ProfileId = p.id ,
                                EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                TimeZoneSidKey='America/Los_Angeles');
        insert manager;
        User user = new User(FirstName = 'Test User' , LastName = 'Account Plan' , Alias = 'tuap' ,
                             Email = 'test@shl.com' ,Username= 'test.ap.user@shl.com' ,ProfileId = p.id ,
                             EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ManagerId = manager.id,
                             TimeZoneSidKey='America/Los_Angeles');
        
        
        insert user;
        system.runAs(user){ 
         Account acc = new Account(name= 'AccountPlan3' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Buying_Centre_Id__c = 'Test1',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
         Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',Account_Plan_Type__c='Current',
                                                Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap;
            
          String str =  AccountPlanDataFetch.checkUserAccessOnAP(ap.id);
            system.assertEquals('Edit',str);
        }
        test.stopTest();
    }
    @isTest 
    static void generateAccountPlanTest(){
        Account acc = new Account(name= 'AccountPlan3' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Buying_Centre_Id__c = 'Test1',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account acc1 = new Account(name= 'app 2' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Buying_Centre_Id__c = 'Test1',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc1;
         Account acc2 = new Account(name= 'Data 2' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Buying_Centre_Id__c = 'Test1',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',ParentId = acc1.id,
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc2;
        
        Id recordId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Referral' LIMIT 1].id;
        
        Contact con = CreateTestData.getContact(acc.id);
        Contact con1 = CreateTestData.getContact(acc.id);
        con.Last_Activity_Happen__c = system.now();
        con.Subject_Discussed__c = 'Test Data';
        update con1;
        
        Opportunity opp = CreateTestData.getOpportunity(acc.id,con.id);
        Case cse = new Case();
        cse.What_platform_are_you_using__c = 'iAssess/AMCAT';
        cse.origin = 'Phone';
        cse.Case_Country__c ='IND';
        cse.RecordTypeId = recordId;
        cse.Assigned_To__c = 'Training Academy Services';
        cse.Please_select_the_type_of_enquiry__c = 'Product, billing or ordering query';
        cse.IsSupport__c = true;
        cse.Time_Spent__c = 6;
        cse.Subject = 'Test Subject';
        cse.AccountId = acc.id;
        cse.ContactId = con.id;
        insert cse;
        
        
        
        GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();
        
        Test.startTest();
        rmw = GenerateAccountPlanController.openAccounPlan(acc.Id);
        rmw = GenerateAccountPlanController.openAccounPlan(acc1.Id);
        rmw = GenerateAccountPlanController.openAccounPlan(acc2.Id);
        rmw = GenerateAccountPlanController.generateAccountPlan(acc.Id ,'Current');
        rmw = GenerateAccountPlanController.generateAccountPlan(acc2.Id ,'Regional');
        rmw = GenerateAccountPlanController.generateAccountPlan(acc1.Id ,'Global');
        
        List<Account_Plan__c> apList =[Select id from Account_Plan__c where Account_Name__c =:acc.Id];        
        //Added as part of SSE-21127(Account Plan Phase 3)
        rmw = GenerateAccountPlanController.openAccounPlan(acc.Id);
        rmw = GenerateAccountPlanController.openAccounPlan(acc1.Id);
         rmw = GenerateAccountPlanController.openAccounPlan(acc2.Id);
        Test.stopTest();
        
    }
    
     @isTest 
    static void generateAccountPlanTest2(){
        
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
                
        GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();
        
        
        rmw = GenerateAccountPlanController.generateAccountPlan(acc.id , 'Current');
        system.assertEquals('SUCCESS' , rmw.MessageType);    
        
    }
    
   /* @isTest 
    static void cloneAccountPlanTest(){
        GenerateAccountPlanControllerTest.generateAccountPlanTest();
        List<Account_Plan__c> apList =[Select id,Account_Name__c from Account_Plan__c
                                       where Account_Name__r.Name = 'Testname_AccountPlan'];
        Contact con = CreateTestData.getContact(apList[0].Account_Name__c);
        con.Last_Activity_Happen__c = system.now();
        con.Subject_Discussed__c = 'Test Data';
        update con;
        
        if(apList.size()>0){ 
            GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();
            
            
            rmw = GenerateAccountPlanController.cloneAccountPlan(apList[0].id);
            system.assertEquals('Account Plan have been cloned successfully!', rmw.Message);
            system.assertEquals('SUCCESS' , rmw.MessageType);
            
        }
        
    }
    
    @isTest 
    static void cloneAccountPlanTest2(){
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft');
        insert ap;
        
       
            GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();
            
            
            rmw = GenerateAccountPlanController.cloneAccountPlan(ap.id);
            system.assertEquals('Account Plan have been cloned successfully!', rmw.Message);
            system.assertEquals('SUCCESS' , rmw.MessageType);     
        
    }*/
    
    @isTest 
    static void syncAccountPlanTest(){
        test.StartTest();
          Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',Account_Plan_Type__c='Current',
                                                Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap;

        
        Contact con = CreateTestData.getContact(acc.id);
        Opportunity opp = CreateTestData.getOpportunity(acc.id,con.Id);
        GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();      
        rmw = GenerateAccountPlanController.syncAccountPlan(ap.id);
        system.assertEquals('Account Plan have been synced successfully!', rmw.Message);
        system.assertEquals('SUCCESS' , rmw.MessageType);
        test.stopTest();
        
    }
    
    @isTest 
    static void syncAccountPlanTest2(){
        
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',Account_Plan_Type__c='Current',
                                                Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap;
        
        
        GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();
        
        
        rmw = GenerateAccountPlanController.syncAccountPlan(ap.id);
        system.assertEquals('Account Plan have been synced successfully!', rmw.Message);
        system.assertEquals('SUCCESS' , rmw.MessageType);    
        
    }
    
    //Added by Prachi Account Plan Phase 4
     @isTest 
    static void syncAccountPlanTest3(){
        test.StartTest();
          Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',
                                                 Account_Plan_Type__c='Regional',Buying_Centre_Id__c = 'Test 1',
                                                Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap;

        
        Contact con = CreateTestData.getContact(acc.id);
        Opportunity opp = CreateTestData.getOpportunity(acc.id,con.Id);
        GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();      
        rmw = GenerateAccountPlanController.syncAccountPlan(ap.id);
        system.assertEquals('Account Plan have been synced successfully!', rmw.Message);
        system.assertEquals('SUCCESS' , rmw.MessageType);
        test.stopTest();
        
    }

    //Added by Prachi Account Plan Phase 4
     @isTest 
    static void syncAccountPlanTest4(){
        test.StartTest();
          Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
          Account acc1 = new Account(name= 'Data 5' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',parentId = acc.id,
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc1;
        
        
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',
                                                 Account_Plan_Type__c='Global',
                                                Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap;

        
        Contact con = CreateTestData.getContact(acc.id);
        Opportunity opp = CreateTestData.getOpportunity(acc.id,con.Id);
        GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();      
        rmw = GenerateAccountPlanController.syncAccountPlan(ap.id);
        system.assertEquals('Account Plan have been synced successfully!', rmw.Message);
        system.assertEquals('SUCCESS' , rmw.MessageType);
        test.stopTest();
        
    }
    
    @isTest 
    static void updateLastContactedDetailsTest(){
        test.startTest();
        Account acc = new Account(name= 'AccountPlan3' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Buying_Centre_Id__c = 'Test1',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
       
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',Account_Plan_Type__c='Current',
                                                Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap;
        
        Contact con = CreateTestData.getContact(acc.id);
        con.Last_Activity_Happen__c = system.now();
        con.Subject_Discussed__c = 'Test Data';
        update con;
        
     GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();
     rmw = GenerateAccountPlanController.updateLastContactedDetails(ap.id);
     system.assertEquals('Last Contacted Details have been updated successfully!', rmw.Message);
     system.assertEquals('SUCCESS' , rmw.MessageType);
           
       test.stopTest(); 
    }
    
    @isTest 
    static void callapprovalTest(){
        
        Profile p = [select id from profile where Name = 'Commercial' limit 1];
        User manager = new User(FirstName = 'Test Manager User' , LastName = 'Account Plan' , Alias = 'tmuap' ,
                                Email = 'test@shl.com' ,Username= 'test.manager.user@shl.com' ,ProfileId = p.id ,
                                EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                TimeZoneSidKey='America/Los_Angeles');
        insert manager;
        User user = new User(FirstName = 'Test User' , LastName = 'Account Plan' , Alias = 'tuap' ,
                             Email = 'test@shl.com' ,Username= 'test.ap.user@shl.com' ,ProfileId = p.id ,
                             EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ManagerId = manager.id,
                             TimeZoneSidKey='America/Los_Angeles');
        
        
        insert user;
        system.runAs(user){ 
            Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Business_Defined_Attribute__c='Fortune 500',
                                      Billing_Address_Line_1__c='test',Billing_City__c='Test City',CurrencyIsoCode='GBP',
                                      Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                      Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
            insert acc;
            
            Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft',Business_Defined_Attribute__c='2023 Gold - TM',Account_Plan_Type__c='Current',
                                                     Date_of_Last_Plan_Review__c=system.today() - 6);
            insert ap;
            
            
            Strategy_and_Goal__c sag = new Strategy_and_Goal__c(Account_Plan__c =ap.id,
                                                                Estimated_Completion_Date__c = system.today(),
                                                                Business_Problem_Addressed__c = 'Test Data',
                                                                Solution_Goal__c = 'Test', 
                                                                Solution_Product_Area__c = 'Talent Acquisition - Grad', 
                                                                Strategy_Type__c = 'Relationship', 
                                                                Strategy_Status__c ='Investigation',
                                                                Strategy_Name__c = 'Test Strat'
                                                               );
            insert sag;    
            GenerateAccountPlanController.returnMessageWrapper rmw = new GenerateAccountPlanController.returnMessageWrapper();
            
            
            rmw = GenerateAccountPlanController.callapproval(ap.id);
            system.assertEquals('The Account Plan is submitted for Approval', rmw.Message);
            system.assertEquals('SUCCESS' , rmw.MessageType);
            
        }
        
    }
    
    

   /* @isTest
    static void testUploadFile() {
        // Test data
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                      Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                      Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                      Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,Quarter__c ='Q1',Year__c='2023',Account_Plan_Status__c ='Draft');
        insert ap;
        

        
        Id accountPlanId = ap.Id;
       	String historyTrend = '<img src="https://www.shutterstock.com/image-vector/compact-size-icon-vector-illustration-260nw-489811384.jpg" />';
        String contactRelationship =  '<img src="https://www.shutterstock.com/image-vector/compact-size-icon-vector-illustration-260nw-489811384.jpg" />';
        Boolean historyTrendUpdated = true;
        Boolean contactRelationshipUpdated = true;
        
        // Create a test ContentVersion record
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Account Plan Test',
            FirstPublishLocationId = ap.id,
            VersionData = Blob.valueOf('Test data'),
            PathOnClient = 'AccountPlanTest.pdf'
        );
        insert testContentVersion;
        
        // Test method
        Test.startTest(); 
        GenerateAccountPlanController.returnMessageWrapper result = GenerateAccountPlanController.uploadFile(accountPlanId, 'tesA', 'testB', true, true);
        GenerateAccountPlanController.returnMessageWrapper result1 = GenerateAccountPlanController.uploadFile(accountPlanId, '', '', true, true);
        GenerateAccountPlanController.returnMessageWrapper result2 = GenerateAccountPlanController.uploadFile(accountPlanId, '"tesAamp;"', '"testBamp;"', true, true);
        Test.stopTest();
    }*/
    
}
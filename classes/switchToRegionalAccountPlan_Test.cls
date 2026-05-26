/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is the test class for switchToRegionalAccountPlanController.                                             *
************************************************************************************************************************************/
@isTest(seeAlldata=true)
public class switchToRegionalAccountPlan_Test {

     @isTest 
    static void checkRegionalAccountPlanExist1(){
        test.startTest();
        List<Account> accList = new List<Account>();
         List<Account_Plan__c> apList = new List<Account_Plan__c>();
           Account acc1 = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
         Account acc2 = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        accList.add(acc1);
        accList.add(acc2);
        
        insert accList;
        
        Account acc3 = new Account(name= 'Data 2' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',parentId = accList[0].id,
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc3;
        
        Account_Plan__c ap1 = new Account_Plan__c(Account_Name__c = accList[0].id,Quarter__c ='Q1',Year__c='2023',
                                                  Account_Plan_Status__c ='Draft',
                                                 Account_Plan_Type__c='Current',
                                                Date_of_Last_Plan_Review__c=system.today() - 6);
         Account_Plan__c ap2 = new Account_Plan__c(Account_Name__c = accList[1].id,Quarter__c ='Q1',
                                                   Year__c='2023',Account_Plan_Status__c ='Draft',
                                                   Account_Plan_Type__c='Regional',Buying_Centre_Id__c = 'Test 1',
                                                  Date_of_Last_Plan_Review__c=system.today() - 6);
         apList.add(ap1);
        apList.add(ap2);
        insert apList;
        
        switchToRegionalAccountPlanController.checkRegionalAccountPlanExist(apList[0].id);
        switchToRegionalAccountPlanController.convertAccPlanToGlobal(apList[0].Id);
        test.stopTest();
    }
    
         @isTest 
    static void checkRegionalAccountPlanExist2(){
        test.startTest();
        List<Account> accList = new List<Account>();
         List<Account_Plan__c> apList = new List<Account_Plan__c>();
           Account acc1 = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
         Account acc2 = new Account(name= 'Org Account 2' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        accList.add(acc1);
        accList.add(acc2);
        
        insert accList;
        
        Account acc3 = new Account(name= 'Data 3' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc3;
        
        Account_Plan__c ap1 = new Account_Plan__c(Account_Name__c = accList[0].id,Quarter__c ='Q1',Year__c='2023',
                                                  Account_Plan_Status__c ='Draft',
                                                 Account_Plan_Type__c='Current',
                                                Date_of_Last_Plan_Review__c=system.today() - 6);
         Account_Plan__c ap2 = new Account_Plan__c(Account_Name__c = acc3.id,Quarter__c ='Q1',
                                                   Year__c='2023',Account_Plan_Status__c ='Draft',
                                                   Account_Plan_Type__c='Current',
                                                  Date_of_Last_Plan_Review__c=system.today() - 6);
        apList.add(ap1);
        apList.add(ap2);
        insert apList;
        
        switchToRegionalAccountPlanController.checkRegionalAccountPlanExist(apList[0].id);
        switchToRegionalAccountPlanController.checkRegionalAccountPlanExist(apList[1].id);
        
        test.stopTest();
    }
    
    @isTest 
    static void getStrategyandWhiteSpaceData(){
         Test.startTest();
        List<Strategy_and_Goal__c> stratList = new List<Strategy_and_Goal__c>();
        List<Whitespace_Potential_Opportunity__c> wsList = new List<Whitespace_Potential_Opportunity__c>();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'Test 1',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con = CreateTestData.getContact(acc.id);

        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,
                                                 Quarter__c ='Q1',Account_Plan_Type__c='Current',
                                                 Year__c='2023',Opportunities_Created_since_last_Review__c = 0,
                                                 Contacts_Created_since_last_review__c = 0,
                                                 Account_Plan_Status__c ='Draft');
        insert ap;
        for(Integer i=0;i<20;i++){
            Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = ap.Id, 
                                                                   Strategy_Name__c = 'Test'+i,
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   Key_Contact_Sponsor__c=con.Id);
            stratList.add(stgoal);
        }
        
        for(Integer i=0;i<10;i++){
            Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = ap.Id, 
                                                                   Strategy_Name__c = 'Test'+i,
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Completed - Success',
                                                                   Key_Contact_Sponsor__c=con.Id);
            stratList.add(stgoal);
        }
        
         
        insert stratList;
        
        for(Integer i = 0 ; i<10 ; i++){
        Whitespace_Potential_Opportunity__c wsOpp = new Whitespace_Potential_Opportunity__c();
        wsOpp.Account_Plan__c = ap.Id;
        wsOpp.Strategy_and_Goals__c = stratList[0].Id;
        wsOpp.Who_do_you_need_to_speak_to__c = con.Id;
        wsOpp.Solution__c = 'Product';
        wsOpp.Potential_Value__c = 10000;
        wsOpp.Any_help_needed__c ='No';
        wsOpp.Next_Step_s__c ='Test';
        wsList.add(wsOpp);
        }
        insert wsList;
        switchToRegionalAccountPlanController.returnMessageWrapper rmw = new switchToRegionalAccountPlanController.returnMessageWrapper();
        rmw = switchToRegionalAccountPlanController.getStrategyandWhiteSpaceData(ap.Id);
        
         Account acc2 = new Account(name= 'Data 2' ,Status__c='Approved',CurrencyIsoCode='GBP',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',Business_Defined_Attribute__c='Fortune 500',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',Buying_Centre_Id__c = 'Test 1',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
         insert acc2;
        
         Account_Plan__c ap2 = new Account_Plan__c(Account_Name__c = acc2.id,Quarter__c ='Q1',
                                                   Year__c='2023',Account_Plan_Status__c ='Draft',
                                                   Account_Plan_Type__c='Regional',Buying_Centre_Id__c = 'Test 1',
                                                  Date_of_Last_Plan_Review__c=system.today() - 6);
        insert ap2;
        List<Id> stID = new List<Id>{stratList[0].id};
        List<Id> wsID = new List<Id>{wsList[0].id};
            
        switchToRegionalAccountPlanController.mergeCurrentAndRegionalAP(ap.Id, ap2.id,stID , wsID);
        test.stopTest();
    }
      
    @isTest 
    static void convertAccPlanToRegional(){
        Test.startTest();
        List<Strategy_and_Goal__c> stratList = new List<Strategy_and_Goal__c>();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        

        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,
                                                 Quarter__c ='Q1',Account_Plan_Type__c='Current',
                                                 Year__c='2023',Opportunities_Created_since_last_Review__c = 0,
                                                 Contacts_Created_since_last_review__c = 0,
                                                 Account_Plan_Status__c ='Draft');
        insert ap;
        switchToRegionalAccountPlanController.convertAccPlanToRegional(ap.Id);
        test.stopTest();
    }
}
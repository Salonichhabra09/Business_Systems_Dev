@isTest(seeAlldata=true)
public class GenerateAccountPlanPDFTest {

      @isTest 
    static void getDataForPDFTest(){
        GenerateAccountPlanPDF.getAccountPlanDataWrapper gapdw = new GenerateAccountPlanPDF.getAccountPlanDataWrapper();
        test.startTest();
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;

        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,
                                                 Quarter__c ='Q1',
                                                 Year__c='2023',Opportunities_Created_since_last_Review__c = 0,
                                                 Contacts_Created_since_last_review__c = 0,
                                                 Account_Plan_Status__c ='Draft',Account_Plan_Type__c ='Global');
        insert ap;
        
        List<Strategy_and_Goal__c> stList = new List<Strategy_and_Goal__c>();
        Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = ap.Id, 
                                                               Strategy_Name__c = 'Test',
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration', 
                                                               Strategy_Status__c = 'In Progress');
        
        Strategy_and_Goal__c stgoal1 = new Strategy_and_Goal__c(Account_Plan__c = ap.Id, 
                                                               Strategy_Name__c = 'Test',
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration', 
                                                               Strategy_Status__c = 'Completed - Success');
     
        stList.add(stgoal);
        stList.add(stgoal1);
        
        insert stList;
        
        Contact con = CreateTestData.getContact(acc.Id);
        
        Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id);
        Opportunity opp1 = CreateTestData.getOpportunity(acc.Id,con.Id);
        opp.Strategy_and_Goals__c = stList[0].Id;
        update opp;
        
        Task t3 = new Task(Subject='Email: test',
                           Status='In Progress',
                           Priority='Normal',
                           WhatId = stgoal.id,
                           Task_Start_Time__c = DateTime.Now(),
                           Task_End_Time__c = DateTime.Now());
        
        insert t3;
        gapdw = GenerateAccountPlanPDF.getDataForPDF(ap.id);
        system.assertEquals(acc.id, gapdw.AccountId);
        test.stopTest();
    }
    
     @isTest 
    static void saveAccountPlanPDFTest(){
        
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;

        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,
                                                 Quarter__c ='Q1',
                                                 Year__c='2023',Opportunities_Created_since_last_Review__c = 0,
                                                 Contacts_Created_since_last_review__c = 0,
                                                 Account_Plan_Status__c ='Draft');
        insert ap;
        String apdata = '{"Name" : ' + '"' + ap.Name + '",' + '"AccountPlanId" : ' + '"'   + ap.Id + '","pdfBase64String": "dGVzdCBjbGFzcw==" }' ;
        
        Test.startTest();
        GenerateAccountPlanPDF.returnMessageWrapper rmw = new GenerateAccountPlanPDF.returnMessageWrapper();
        rmw = GenerateAccountPlanPDF.saveAccountPlanPDF(apdata);
        system.assertEquals('SUCCESS', rmw.MessageType);
        Test.stopTest(); 
    }
    
    @isTest
    static void updatecheckPDFTest(){
        test.startTest();
         Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;

        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,
                                                 Quarter__c ='Q1',
                                                 Year__c='2023',Opportunities_Created_since_last_Review__c = 0,
                                                 Contacts_Created_since_last_review__c = 0,
                                                 Account_Plan_Status__c ='Draft');
        insert ap;
        GenerateAccountPlanPDF.returnMessageWrapper rmw = new GenerateAccountPlanPDF.returnMessageWrapper();
        rmw = GenerateAccountPlanPDF.updatecheckPDF(ap.id);
        system.assertEquals('SUCCESS', rmw.MessageType);
        Test.stopTest();
    }
}
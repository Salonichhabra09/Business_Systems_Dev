@isTest(seeAlldata=true)
public class StrategyAndGoalController_Test {

    @IsTest
    static void testStrategies() {
        // Test data setup
        Account acc= new Account();
        acc.Name='Test234';
        acc.BU__c='UK - UK1';
        acc.CurrencyIsoCode='GBP'; 
        acc.Industry='Agriculture';
        acc.Billing_Address_Line_1__c='test23';
        acc.Billing_City__c='test23';
        acc.Same_As_The_Billing_Address__c=true;
        acc.Billing_Country__c='test23';
        acc.Billing_State__c='test23';
        acc.Billing_ZIP_Postal_Code__c='test23'; 
        acc.Buying_Centre_Id__c = 'Test';
        insert acc;

        Contact con = CreateTestData.getContact(acc.Id);
        Contact con1 = CreateTestData.getContact(acc.Id);

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id ,Account_Plan_Type__c = 'Current' );
        insert accPlan;
        
         Account_Plan__c accPlan1 = new Account_Plan__c(Account_Name__c=acc.Id ,Account_Plan_Type__c = 'Regional', 
                                                       Buying_Centre_Id__c = 'Test');
        insert accPlan1;

         Account_Plan__c accPlan2 = new Account_Plan__c(Account_Name__c=acc.Id ,Account_Plan_Type__c = 'Global' );
        insert accPlan2;

        
        //Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id);
        Opportunity opp =
            new Opportunity(name = 'Test Opportunity', AccountID = acc.id);
        opp.Billing_Contact__c = con.id;
        opp.Closedate = system.today();
        opp.Primary_Contact__c = con.id;
        opp.Amount = 1000;
        opp.Variation_Opportunity__c = 'No';
        opp.Business_Type__c = 'Renewal';
        opp.Forecast_Category__c = 'Commit';
        opp.StageName = 'New';

        //insert opp;
        //Opportunity opp1 = CreateTestData.getOpportunity(acc.Id,con.Id);
        Opportunity opp1 =
            new Opportunity(name = 'Test Opportunity', AccountID = acc.id);
        opp1.Billing_Contact__c = con.id;
        opp1.Closedate = system.today();
        opp1.Primary_Contact__c = con.id;
        opp1.Amount = 1000;
        opp1.Variation_Opportunity__c = 'No';
        opp1.Business_Type__c = 'Renewal';
        opp1.Forecast_Category__c = 'Commit';
        opp1.StageName = 'New';

        //insert opp1;
        
        List<AccountContactRelation> acrList = [SELECT id, Roles, Strategies__c, ContactId, AccountId FROM AccountContactRelation WHERE AccountId =: acc.Id];
       
        Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                               Strategy_Name__c = 'Test',
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration', 
                                                               Strategy_Status__c = 'In Progress',
                                                               Key_Contact_Sponsor__c=con.Id,
                                                               Account_Contact_Relations__c = acrList[0].Id);
        insert stgoal;
        Strategy_and_Goal__c stgoal1 = new Strategy_and_Goal__c(Account_Plan__c = accPlan1.Id, 
                                                               Strategy_Name__c = 'Test',
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration', 
                                                               Strategy_Status__c = 'In Progress',
                                                               Key_Contact_Sponsor__c=con.Id,
                                                               Account_Contact_Relations__c = acrList[0].Id);
        insert stgoal1;
        Strategy_and_Goal__c stgoal2 = new Strategy_and_Goal__c(Account_Plan__c = accPlan2.Id, 
                                                               Strategy_Name__c = 'Test',
                                                               Business_Problem_Addressed__c = 'Test', 
                                                               Estimated_Completion_Date__c = System.today(), 
                                                               Solution_Goal__c = 'Goal', 
                                                               Solution_Product_Area__c = 'Training', 
                                                               Strategy_Type__c = 'Product Migration', 
                                                               Strategy_Status__c = 'In Progress',
                                                               Key_Contact_Sponsor__c=con.Id,
                                                               Account_Contact_Relations__c = acrList[0].Id);
        insert stgoal2;
        
        
        
        Strategy_and_Goal__c strat = [SELECT Id, Name FROM Strategy_and_Goal__c WHERE Id =: stgoal.Id];
        opp.Strategy_And_Goals__c = strat.Id;
        //update opp;
        //AccountContactRelation acr = new AccountContactRelation(AccountId = acc.Id, ContactId = con.Id, Strategies__c = strat.Name);
        //insert acr;
        
        // Test method call
        Test.startTest();
        StrategyAndGoalController.returnMessageWrapper rmw = new StrategyAndGoalController.returnMessageWrapper();
        rmw = StrategyAndGoalController.getStrategyAndGoalsDetails(accPlan.Id);
        system.assertEquals('Success', rmw.MessageType);
        system.assertEquals('Strategy Data has been retrived successfully!', rmw.Message);
        StrategyAndGoalController.getStrategyRelationshipDetails(strat.Id);
		StrategyAndGoalController.getRelationshipDetails(acc.Id,strat.Id);
        StrategyAndGoalController.getRelationshipDetails(acc.Id,strat.Id);
        StrategyAndGoalController.getRelationshipDetails(acc.Id,strat.Id);
        StrategyAndGoalController.addNewRelationshipToStrategy(strat.Id, acrList[1].Id);
        StrategyAndGoalController.addOrRemoveRelationship(strat.Id,new List<Id>{acrList[1].Id},null);
        Test.stopTest();
    }
   
    //Added by Prachi Gupta as part of SSE-20678
     @IsTest
    static void testgetCompletedStrategyAndGoalsDetails(){
        
        List<Strategy_and_Goal__c> stratList = new List<Strategy_and_Goal__c>();
        
        Test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'Test',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con = CreateTestData.getContact(acc.id);

        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,
                                                 Quarter__c ='Q1',Account_Plan_Type__c = 'Regional',Buying_Centre_Id__c = 'Test',
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
         
        StrategyAndGoalController.returnMessageWrapper rmw = new StrategyAndGoalController.returnMessageWrapper();
        rmw = StrategyAndGoalController.getCompletedStrategyAndGoalsDetails(ap.Id);
        system.assertEquals('Success', rmw.MessageType);
        system.assertEquals('Strategy Data has been retrived successfully!', rmw.Message);
        system.assertEquals('Strategy Data has been retrived successfully!', rmw.Message);
        system.assertEquals(10, rmw.strategyList.size());
        

        rmw = StrategyAndGoalController.getStrategyAndGoalsDetails(ap.Id);
        system.assertEquals('Success', rmw.MessageType);
        system.assertEquals('Strategy Data has been retrived successfully!', rmw.Message);
        system.assertEquals('Strategy Data has been retrived successfully!', rmw.Message);
        system.assertEquals(20, rmw.strategyList.size());
        Test.stopTest();
        
    }
    
     //Added by Prachi Gupta as part of SSE-20075
     @IsTest
    static void testgetActivityDetails(){
        
        List<Task> taskList = new List<Task>();
        List<Event> eventList = new List<Event>();
        
        Test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con = CreateTestData.getContact(acc.id);

        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,
                                                 Quarter__c ='Q1',Account_Plan_Type__c = 'Current',
                                                 Year__c='2023',Opportunities_Created_since_last_Review__c = 0,
                                                 Contacts_Created_since_last_review__c = 0,
                                                 Account_Plan_Status__c ='Draft');
        insert ap;
        
        
       
         Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = ap.Id, 
                                                                   Strategy_Name__c = 'Test',
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   Key_Contact_Sponsor__c=con.Id); 
        insert stgoal;
        
        for(Integer i=0;i<=10;i++){
            Task t = new Task( Status = 'In Progress',
                              WhoId = con.Id,
                              ActivityDate = System.today()+4,
                              subject = 'call',
                              Description='Test Data' + i,
                              whatId=stgoal.id);
            taskList.add(t);
        }
        
        for(Integer i=0;i<=5;i++){
            Task t = new Task( Status = 'Completed',
                              WhoId = con.Id,
                              ActivityDate = System.today()-2,
                              subject = 'call',
                              Description='Test Data' + i,
                              whatId=stgoal.id);
            taskList.add(t);
        }
        insert taskList;
        
         for(Integer i=0;i<=10;i++){
            Event ev = new Event( 
                              WhoId = con.Id,
                              ActivityDate = System.today()+4,
                              subject = 'call',
                              Description='Test Data' + i,
                              DurationInMinutes=100,
                              ActivityDateTime=system.now(),
                              Is_Completed__c = false,   
                              whatId=stgoal.id);
            eventList.add(ev);
        }
        
        for(Integer i=0;i<=5;i++){
            Event ev = new Event( Is_Completed__c = true,
                              WhoId = con.Id,
                              ActivityDate = System.today()-2,
                              subject = 'call',
                              Description='Test Data' + i,
                              DurationInMinutes=100,   
                              ActivityDateTime=system.now(),
                              whatId=stgoal.id);
            eventList.add(ev);
        }
        insert eventList;
         
        StrategyAndGoalController.returnMessageWrapper rmw = new StrategyAndGoalController.returnMessageWrapper();
        rmw = StrategyAndGoalController.getActivityDetails(stgoal.Id);
        system.assertEquals('Success', rmw.MessageType);
        system.assertEquals('Activity Data has been retrived successfully!', rmw.Message);
        
        Test.stopTest();
        
    }
    
    //Added by Prachi Gupta as part of SSE-20678
     @IsTest
    static void testgetOpportunityDetails(){
        Test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'Test',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc; 
        Contact con = CreateTestData.getContact(acc.Id);
        Contact con1 = CreateTestData.getContact(acc.Id);

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id , Account_Plan_Type__c = 'Current');
        insert accPlan;
        
        //Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id); 
        //Opportunity opp1 = CreateTestData.getOpportunity(acc.Id,con.Id); 
        //Opportunity opp2 = CreateTestData.getOpportunity(acc.Id,con.Id);
        
        Opportunity opp1 =
            new Opportunity(name = 'Test Opportunity', AccountID = acc.id);
        opp1.Billing_Contact__c = con.id;
        opp1.Closedate = system.today();
        opp1.Primary_Contact__c = con.id;
        opp1.Amount = 1000;
        opp1.Variation_Opportunity__c = 'No';
        opp1.Business_Type__c = 'Renewal';
        opp1.Forecast_Category__c = 'Commit';
        opp1.StageName = 'New';

        insert opp1;
        
         Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                                   Strategy_Name__c = 'Test',
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   Key_Contact_Sponsor__c=con.Id); 
        insert stgoal;
        
        StrategyAndGoalController.returnMessageWrapper rmw = new StrategyAndGoalController.returnMessageWrapper();
        rmw = StrategyAndGoalController.getOpportunityDetails(acc.id,stgoal.Id);
        system.assertEquals('Success', rmw.MessageType);
        system.assertEquals('Opportunity Data has been retrived successfully!', rmw.Message);
        system.assertEquals(1, rmw.oppList.size());
     
        Test.stopTest();
    }
    
    
    //Added by Prachi Gupta as part of SSE-20678
     @IsTest
    static void testlinkOrDelinkOpportunities(){
        Test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'Test',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc; 
        Contact con = CreateTestData.getContact(acc.Id);
        Contact con1 = CreateTestData.getContact(acc.Id);

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id , Buying_Centre_Id__c = 'Test' , Account_Plan_Type__c = 'Regional');
        insert accPlan;
        
        //Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id); 
        //Opportunity opp1 = CreateTestData.getOpportunity(acc.Id,con.Id); 
        //Opportunity opp2 = CreateTestData.getOpportunity(acc.Id,con.Id); 
        
        Opportunity opp =
            new Opportunity(name = 'Test Opportunity', AccountID = acc.id);
        opp.Billing_Contact__c = con.id;
        opp.Closedate = system.today();
        opp.Primary_Contact__c = con.id;
        opp.Amount = 1000;
        opp.Variation_Opportunity__c = 'No';
        opp.Business_Type__c = 'Renewal';
        opp.Forecast_Category__c = 'Commit';
        opp.StageName = 'New';

        insert opp;
        
        Opportunity opp1 =
            new Opportunity(name = 'Test Opportunity', AccountID = acc.id);
        opp1.Billing_Contact__c = con.id;
        opp1.Closedate = system.today();
        opp1.Primary_Contact__c = con.id;
        opp1.Amount = 1000;
        opp1.Variation_Opportunity__c = 'No';
        opp1.Business_Type__c = 'Renewal';
        opp1.Forecast_Category__c = 'Commit';
        opp1.StageName = 'New';

        insert opp1;
        
         Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                                   Strategy_Name__c = 'Test',
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   Key_Contact_Sponsor__c=con.Id); 
        insert stgoal;
        
        StrategyAndGoalController.returnMessageWrapper rmw = new StrategyAndGoalController.returnMessageWrapper();
        rmw = StrategyAndGoalController.linkOrDelinkOpportunities(stgoal.Id,new List<Id>{opp1.Id},new List<Id>{opp.Id},1);
        system.assertEquals('Success', rmw.MessageType);
        system.assertEquals('Opportunity has been linked/delinked successfully!', rmw.Message);
        Test.stopTest();
    }
    
     //Added by Prachi Gupta SSE-20682
     @IsTest
    static void testgetStrategyRelationshipDetails(){
        
        Test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c ='Test',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc; 
        Contact con = CreateTestData.getContact(acc.Id);
        Contact con1 = CreateTestData.getContact(acc.Id);

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id ,  Account_Plan_Type__c = 'Regional' , Buying_Centre_Id__c ='Test');
        insert accPlan;
        
         Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                                   Strategy_Name__c = 'Test',
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   Key_Contact_Sponsor__c=con.Id); 
        insert stgoal;
        
        AccountContactRelation acr = new AccountContactRelation(roles='Decision Maker',AccountId=acc.Id,
                                                                contactId=con.id);
        
        StrategyAndGoalController.getStrategyRelationshipDetails(stgoal.Id);
        
        Test.stopTest();
    }
        //Added by Prachi Gupta SSE-21114 
     @IsTest
    static void testgetAllActivityDetailsOnAccountPlan(){
         List<Task> taskList = new List<Task>();
        List<Event> eventList = new List<Event>();
        Test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc; 
        Contact con = CreateTestData.getContact(acc.Id);
        Contact con1 = CreateTestData.getContact(acc.Id);

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id , Account_Plan_Type__c = 'Current');
        insert accPlan;
        
         Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                                   Strategy_Name__c = 'Test',
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   Key_Contact_Sponsor__c=con.Id); 
        insert stgoal;
            
      Strategy_and_Goal__c stgoal2 = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                                   Strategy_Name__c = 'Test',
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   Key_Contact_Sponsor__c=con.Id); 
        
         insert stgoal2;
        
       for(Integer i=0;i<=10;i++){
            Event ev = new Event( 
                              WhoId = con.Id,
                              ActivityDate = System.today()+4,
                              subject = 'call',
                              Description='Test Data' + i,
                              DurationInMinutes=100,
                              ActivityDateTime=system.now(),
                              Is_Completed__c = false,   
                              whatId=stgoal.id);
            eventList.add(ev);
        }
        
        for(Integer i=0;i<=5;i++){
            Event ev = new Event( Is_Completed__c = true,
                              WhoId = con.Id,
                              ActivityDate = System.today()-2,
                              subject = 'call',
                              Description='Test Data' + i,
                              DurationInMinutes=100,   
                              ActivityDateTime=system.now(),
                              whatId=stgoal2.id);
            eventList.add(ev);
        }
        insert eventList;
        
        for(Integer i=0;i<=10;i++){
            Task t = new Task( Status = 'In Progress',
                              WhoId = con.Id,
                              ActivityDate = System.today()+4,
                              subject = 'call',
                              Description='Test Data' + i,
                              whatId=stgoal2.id);
            taskList.add(t);
        }
        
        for(Integer i=0;i<=5;i++){
            Task t = new Task( Status = 'Completed',
                              WhoId = con.Id,
                              ActivityDate = System.today()-2,
                              subject = 'call',
                              Description='Test Data' + i,
                              whatId=stgoal.id);
            taskList.add(t);
        }
        insert taskList;
        
        StrategyAndGoalController.returnMessageWrapper rmw = new StrategyAndGoalController.returnMessageWrapper();
        rmw = StrategyAndGoalController.getAllActivityDetailsOnAccountPlan(accPlan.Id);
        
        Test.stopTest();
    }
    
     //Added as part of Account Plan Phase 4
     @IsTest
    static void testgetOpportunityDetails1(){
        Test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'Test',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc; 
        Contact con = CreateTestData.getContact(acc.Id);
        Contact con1 = CreateTestData.getContact(acc.Id);

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id , Account_Plan_Type__c = 'Regional'
                                                     ,Buying_Centre_Id__c = 'Test');
        insert accPlan;
        
        //Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id); 
        //Opportunity opp1 = CreateTestData.getOpportunity(acc.Id,con.Id); 
        //Opportunity opp2 = CreateTestData.getOpportunity(acc.Id,con.Id); 
        
        Opportunity opp =
            new Opportunity(name = 'Test Opportunity', AccountID = acc.id);
        opp.Billing_Contact__c = con.id;
        opp.Closedate = system.today();
        opp.Primary_Contact__c = con.id;
        opp.Amount = 1000;
        opp.Variation_Opportunity__c = 'No';
        opp.Business_Type__c = 'Renewal';
        opp.Forecast_Category__c = 'Commit';
        opp.StageName = 'New';

        insert opp;
        
         Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                                   Strategy_Name__c = 'Test',
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   Key_Contact_Sponsor__c=con.Id); 
        insert stgoal;
        
        StrategyAndGoalController.returnMessageWrapper rmw = new StrategyAndGoalController.returnMessageWrapper();
        rmw = StrategyAndGoalController.getOpportunityDetails(acc.id,stgoal.Id);
        system.assertEquals('Success', rmw.MessageType);
        system.assertEquals('Opportunity Data has been retrived successfully!', rmw.Message);
        system.assertEquals(1, rmw.oppList.size());
     
        Test.stopTest();
    }
    //Added as part of Account Plan Phase 4
     @IsTest
    static void testgetOpportunityDetails2(){
        Test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'Test',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc; 
        Contact con = CreateTestData.getContact(acc.Id);
        Contact con1 = CreateTestData.getContact(acc.Id);

        Account_Plan__c accPlan = new Account_Plan__c(Account_Name__c=acc.Id , Account_Plan_Type__c = 'Global'
                                                    );
        insert accPlan;
        
        //Opportunity opp = CreateTestData.getOpportunity(acc.Id,con.Id); 
        //Opportunity opp1 = CreateTestData.getOpportunity(acc.Id,con.Id); 
        //Opportunity opp2 = CreateTestData.getOpportunity(acc.Id,con.Id); 
        
        Opportunity opp =
            new Opportunity(name = 'Test Opportunity', AccountID = acc.id);
        opp.Billing_Contact__c = con.id;
        opp.Closedate = system.today();
        opp.Primary_Contact__c = con.id;
        opp.Amount = 1000;
        opp.Variation_Opportunity__c = 'No';
        opp.Business_Type__c = 'Renewal';
        opp.Forecast_Category__c = 'Commit';
        opp.StageName = 'New';

        insert opp;
        
         Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = accPlan.Id, 
                                                                   Strategy_Name__c = 'Test',
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   Key_Contact_Sponsor__c=con.Id); 
        insert stgoal;
        
        StrategyAndGoalController.returnMessageWrapper rmw = new StrategyAndGoalController.returnMessageWrapper();
        rmw = StrategyAndGoalController.getOpportunityDetails(acc.id,stgoal.Id);
        system.assertEquals('Success', rmw.MessageType);
        system.assertEquals('Opportunity Data has been retrived successfully!', rmw.Message);
        system.assertEquals(1, rmw.oppList.size());
     
        Test.stopTest();
    }
    
    @IsTest
    static void testgetInactiveStrategyAndGoalsDetails(){
        
        List<Strategy_and_Goal__c> stratList = new List<Strategy_and_Goal__c>();
        
        Test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'Test',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Contact con = CreateTestData.getContact(acc.id);

        Account_Plan__c ap = new Account_Plan__c(Account_Name__c = acc.id,
                                                 Quarter__c ='Q1',Account_Plan_Type__c = 'Regional',Buying_Centre_Id__c = 'Test',
                                                 Year__c='2023',Opportunities_Created_since_last_Review__c = 0,
                                                 Contacts_Created_since_last_review__c = 0,
                                                 Account_Plan_Status__c ='Draft');
        insert ap;
        for(Integer i=0;i<20;i++){
            Strategy_and_Goal__c stgoal = new Strategy_and_Goal__c(Account_Plan__c = ap.Id, 
                                                                   Strategy_Name__c = 'Testing'+i,
                                                                   Business_Problem_Addressed__c = 'Test', 
                                                                   Estimated_Completion_Date__c = System.today(), 
                                                                   Solution_Goal__c = 'Goal', 
                                                                   Solution_Product_Area__c = 'Training', 
                                                                   Strategy_Type__c = 'Product Migration', 
                                                                   Strategy_Status__c = 'Investigation',
                                                                   InActive__c = true);
            stratList.add(stgoal);
        }
        
        insert stratList;
         
        StrategyAndGoalController.returnMessageWrapper rmw = new StrategyAndGoalController.returnMessageWrapper();
        rmw = StrategyAndGoalController.getInactiveStrategyAndGoalsDetails(ap.Id);
        system.assertEquals('Success', rmw.MessageType);
        system.assertEquals('Strategy Data has been retrived successfully!', rmw.Message);
        system.assertEquals(20, rmw.strategyList.size());
        Test.stopTest();
        
    }
    
}
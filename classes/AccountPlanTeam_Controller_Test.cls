@isTest
private class AccountPlanTeam_Controller_Test {
    
    @isTest(seeAlldata=true)
    static void tesAccountPlanTeam_Controller() {
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
        insert acc;

        Account_Plan__c plan = new Account_Plan__c(
        Account_Name__c = acc.Id ,  Account_Plan_Type__c = 'Current');
        insert plan;
        Account_Plan__c pn = [Select Name From Account_Plan__c WHERE Id =: plan.Id];

        User user = new User(Username='testuserACPLAN@test.com', Email='testuser@test.com', 
                             Alias='testuAP', EmailEncodingKey='UTF-8', LastName='Testing', 
                             LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                             TimeZoneSidKey='America/Los_Angeles', 
                             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id);
        insert user;
        
        AccountTeamMember atm = new AccountTeamMember(
            AccountId=acc.Id, 
            UserId=user.Id,
            Account_Plans__c = pn.Name, 
            TeamMemberRole='Test Role');
        insert atm;

        User u = new User(
            Username='testuser1ACPLAN@test.com', Email='testuser1@test.com', 
            Alias='testuAP1', EmailEncodingKey='UTF-8', LastName='Testing1', 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
            TimeZoneSidKey='America/Los_Angeles', 
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
            );
        insert u;

        AccountTeamMember atm1 = new AccountTeamMember(
            AccountId = acc.Id,
            UserId = u.Id, 
            TeamMemberRole = 'Sales Rep');
        insert atm1;

        User u2 = new User(
            Username='testuser1ACPLAN2@test.com', Email='testuser2@test.com', 
            Alias='testuAP2', EmailEncodingKey='UTF-8', LastName='Testing2', 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
            TimeZoneSidKey='America/Los_Angeles', 
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
            );
        insert u2;
        
        AccountTeamMember atm2 = new AccountTeamMember(
        AccountId = acc.Id,
        UserId = u.Id, 
        TeamMemberRole = 'Sales');
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        atmList.add(atm2);
            
        Test.startTest();
        AccountPlanTeam_Controller.returnMessageWrapper rmw = new AccountPlanTeam_Controller.returnMessageWrapper();
        rmw = AccountPlanTeam_Controller.getCurrentAccountPlanTeamMembers(plan.Id, pn.Name);
        List<AccountPlanTeam_Controller.AccountTeamMemberWrapper> resultCurrent = rmw.atmwList;
        List<AccountPlanTeam_Controller.AccountTeamMemberWrapper> resultNotLinked = AccountPlanTeam_Controller.getAccountTeamMembers(plan.Id, pn.Name);
        List<AccountPlanTeam_Controller.AccountTeamMemberWrapper> resultAll = AccountPlanTeam_Controller.getAllAccountTeamMembers(plan.Id, pn.Name);
        
        Set<Id> ids = new Set<Id>();
        ids.add(atm1.Id);
        String userIds =JSON.serialize(ids);

        String resultLink = AccountPlanTeam_Controller.linkAccountTeamMembers(userIds,pn.Name);
                      
        string records = JSON.serialize(atmList);
        String resultSave = AccountPlanTeam_Controller.saveAccountTeamMembers(records);
        Test.stopTest();
        
    }

    //Added by Prachi SSE-21906
         @isTest(seeAlldata=true)
    static void testAccountPlanTeam_ControllerRegional(){
       List<Account> accList = new List<Account>();
       List<User> userList = new List<User>(); 
       List<AccountTeamMember> atmList = new List<AccountTeamMember>(); 
          Account acc= new Account();
            acc.Name='Data For Testing Regional 1';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23';  
            acc.Buying_Centre_Id__c = 'test 1';
        accList.add(acc);
        
         Account acc1= new Account();
            acc1.Name='Test Regional Account 1';
            acc1.BU__c='China - CN1';
            acc1.CurrencyIsoCode='GBP'; 
            acc1.Industry='Agriculture';
            acc1.Billing_Address_Line_1__c='test23';
            acc1.Billing_City__c='test23';
            acc1.Same_As_The_Billing_Address__c=true;
            acc1.Billing_Country__c='test23';
            acc1.Billing_State__c='test23';
            acc1.Billing_ZIP_Postal_Code__c='test23';
            acc1.Buying_Centre_Id__c = 'test 1';
        accList.add(acc1);

        insert accList;
        
        Account_Plan__c plan = new Account_Plan__c(
        Account_Name__c = acc.Id , Account_Plan_Type__c = 'Regional' , Buying_Centre_Id__c = 'test 1');
        insert plan;
        Account_Plan__c pn = [Select Name From Account_Plan__c WHERE Id =: plan.Id];

        User user = new User(Username='testuserACPLAN@test.com', Email='testuser@test.com', 
                             Alias='testuAP', EmailEncodingKey='UTF-8', LastName='Testing', 
                             LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                             TimeZoneSidKey='America/Los_Angeles', 
                             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id);
        userList.add(user);
        
         User user1 = new User(Username='test2userACPLAN@test.com', Email='test2user@test.com', 
                             Alias='test2uAP', EmailEncodingKey='UTF-8', LastName='Testing', 
                             LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                             TimeZoneSidKey='America/Los_Angeles', 
                             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id);
        userList.add(user1);
        insert userList;
        
        AccountTeamMember atm = new AccountTeamMember(
            AccountId=accList[0].Id, 
            UserId=userList[0].Id,
            Account_Plans__c = pn.Name, 
            TeamMemberRole='Test Role');
        atmList.add(atm);
         AccountTeamMember atm1 = new AccountTeamMember(
            AccountId=accList[1].Id, 
            UserId=userList[0].Id,
            Account_Plans__c = pn.Name, 
            TeamMemberRole='Sales Rep');
        atmList.add(atm1);
         AccountTeamMember atm2 = new AccountTeamMember(
            AccountId=accList[0].Id, 
            UserId=userList[1].Id,
            Account_Plans__c = pn.Name, 
            TeamMemberRole='Sales');
        atmList.add(atm2);
        insert atmList;


            
        Test.startTest();
        AccountPlanTeam_Controller.returnMessageWrapper rmw = new AccountPlanTeam_Controller.returnMessageWrapper();
        rmw = AccountPlanTeam_Controller.getCurrentAccountPlanTeamMembers(plan.Id, pn.Name);
        List<AccountPlanTeam_Controller.AccountTeamMemberWrapper> resultCurrent = rmw.atmwList;
        List<AccountPlanTeam_Controller.AccountTeamMemberWrapper> resultNotLinked = AccountPlanTeam_Controller.getAccountTeamMembers(plan.Id, pn.Name);
        List<AccountPlanTeam_Controller.AccountTeamMemberWrapper> resultAll = AccountPlanTeam_Controller.getAllAccountTeamMembers(plan.Id, pn.Name);
        
        Set<Id> ids = new Set<Id>();
        ids.add(atm1.Id);
        String userIds =JSON.serialize(ids);

        String resultLink = AccountPlanTeam_Controller.linkAccountTeamMembers(userIds,pn.Name);
                      
        string records = JSON.serialize(atmList);
        String resultSave = AccountPlanTeam_Controller.saveAccountTeamMembers(records);
        Test.stopTest();
    }
     //Added by Prachi SSE-21906
         @isTest(seeAlldata=true)
    static void testAccountPlanTeam_ControllerGlobal(){
       List<Account> accList = new List<Account>();
       List<User> userList = new List<User>(); 
       List<AccountTeamMember> atmList = new List<AccountTeamMember>(); 
          Account acc= new Account();
            acc.Name='Data For Testing Regional 1';
            acc.BU__c='UK - UK1';
            acc.CurrencyIsoCode='GBP'; 
            acc.Industry='Agriculture';
            acc.Billing_Address_Line_1__c='test23';
            acc.Billing_City__c='test23';
            acc.Same_As_The_Billing_Address__c=true;
            acc.Billing_Country__c='test23';
            acc.Billing_State__c='test23';
            acc.Billing_ZIP_Postal_Code__c='test23';  
            acc.Buying_Centre_Id__c = 'test 1';
        insert acc;
        
         Account acc1= new Account();
            acc1.Name='Test Regional Account 1';
            acc1.BU__c='China - CN1';
            acc1.CurrencyIsoCode='GBP'; 
            acc1.Industry='Agriculture';
            acc1.Billing_Address_Line_1__c='test23';
            acc1.Billing_City__c='test23';
            acc1.Same_As_The_Billing_Address__c=true;
            acc1.Billing_Country__c='test23';
            acc1.Billing_State__c='test23';
            acc1.Billing_ZIP_Postal_Code__c='test23';
            acc1.Buying_Centre_Id__c = 'test 1';
            acc1.ParentId = acc.id;
      

        insert acc1;
        
        Account_Plan__c plan = new Account_Plan__c(
        Account_Name__c = acc.Id , Account_Plan_Type__c = 'Global' , Buying_Centre_Id__c = 'test 1');
        insert plan;
        Account_Plan__c pn = [Select Name From Account_Plan__c WHERE Id =: plan.Id];

        User user = new User(Username='testuserACPLAN@test.com', Email='testuser@test.com', 
                             Alias='testuAP', EmailEncodingKey='UTF-8', LastName='Testing', 
                             LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                             TimeZoneSidKey='America/Los_Angeles', 
                             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id);
        userList.add(user);
        
         User user1 = new User(Username='test2userACPLAN@test.com', Email='test2user@test.com', 
                             Alias='test2uAP', EmailEncodingKey='UTF-8', LastName='Testing', 
                             LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                             TimeZoneSidKey='America/Los_Angeles', 
                             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id);
        userList.add(user1);
        insert userList;
        
        AccountTeamMember atm = new AccountTeamMember(
            AccountId=acc1.Id, 
            UserId=userList[0].Id,
            Account_Plans__c = pn.Name, 
            TeamMemberRole='Test Role');
        atmList.add(atm);
         AccountTeamMember atm1 = new AccountTeamMember(
            AccountId=acc.Id, 
            UserId=userList[0].Id,
            Account_Plans__c = pn.Name, 
            TeamMemberRole='Sales Rep');
        atmList.add(atm1);
         AccountTeamMember atm2 = new AccountTeamMember(
            AccountId=acc1.Id, 
            UserId=userList[1].Id,
            Account_Plans__c = pn.Name, 
            TeamMemberRole='Sales');
        atmList.add(atm2);
        insert atmList;


            
        Test.startTest();
        AccountPlanTeam_Controller.returnMessageWrapper rmw = new AccountPlanTeam_Controller.returnMessageWrapper();
        rmw = AccountPlanTeam_Controller.getCurrentAccountPlanTeamMembers(plan.Id, pn.Name);
        List<AccountPlanTeam_Controller.AccountTeamMemberWrapper> resultCurrent = rmw.atmwList;
        List<AccountPlanTeam_Controller.AccountTeamMemberWrapper> resultNotLinked = AccountPlanTeam_Controller.getAccountTeamMembers(plan.Id, pn.Name);
        List<AccountPlanTeam_Controller.AccountTeamMemberWrapper> resultAll = AccountPlanTeam_Controller.getAllAccountTeamMembers(plan.Id, pn.Name);
        
        Set<Id> ids = new Set<Id>();
        ids.add(atm1.Id);
        String userIds =JSON.serialize(ids);

        String resultLink = AccountPlanTeam_Controller.linkAccountTeamMembers(userIds,pn.Name);
                      
        string records = JSON.serialize(atmList);
        String resultSave = AccountPlanTeam_Controller.saveAccountTeamMembers(records);
        Test.stopTest();
    }
    
    }
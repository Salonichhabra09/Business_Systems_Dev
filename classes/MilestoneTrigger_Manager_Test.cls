@isTest
public class MilestoneTrigger_Manager_Test {
    
   @testSetup
    static void setupTestData() {
        // Create test data required for the tests
 
      User testUser=[select Id,name,Company_BU__c from user where Name='Globus Development'];
        Trigger_Activation__c setting = new Trigger_Activation__c();
            setting.Name = 'Milestone_Period_Trigger';
            setting.Active__c = True;
            insert setting;
          Trigger_Activation__c setting1 = new Trigger_Activation__c();
            setting1.Name = 'Account_Trigger';
            setting1.Active__c = True;
            insert setting1;
           Trigger_Activation__c setting2 = new Trigger_Activation__c();
            setting2.Name = 'Contact_Trigger';
            setting2.Active__c = True;
            insert setting2;
           Trigger_Activation__c setting3 = new Trigger_Activation__c();
            setting3.Name = 'Opportunity_Trigger';
            setting3.Active__c = True;
            insert setting3;
          Trigger_Activation__c setting4 = new Trigger_Activation__c();
            setting4.Name = 'Project_Trigger';
            setting4.Active__c = True;
            insert setting4;
          Trigger_Activation__c setting5 = new Trigger_Activation__c();
            setting5.Name = 'Milestone_Trigger';
            setting5.Active__c = True;
            insert setting5;
          
          Trigger_Activation__c setting6 = new Trigger_Activation__c();
            setting6.Name = 'OpportunityContactRoleTrigger';
            setting6.Active__c = True;
            insert setting6;
          
        Milestone_Period__c period1 = new Milestone_Period__c();
        period1.Signature_Date__c = Date.today();
        period1.Financial_Period_Date__c = date.today()+1;
        period1.Financial_Period_Closed__c = false;
        period1.BU__c = 'US5';
        period1.name = 'abc';
        insert  period1;
        
        Milestone_Period__c period2 = new Milestone_Period__c();
        period2.Signature_Date__c = Date.today() - 1;
        period2.Financial_Period_Date__c = date.today() - 1;
        period2.Financial_Period_Closed__c = false;
        period2.BU__c = 'US5';
        period2.name = 'abcd';
        insert  period2;
        
        Account acc= new Account();     // insert account
        acc.Name='Test234' + System.today();
        acc.BU__c='India - IN1';
        acc.CurrencyIsoCode='GBP'; 
        acc.Industry='Other';
        acc.Billing_Address_Line_1__c='test23';
        acc.Billing_City__c='test23';
        acc.Same_As_The_Billing_Address__c=true;
        acc.Billing_Country__c='test23';
        acc.Billing_State__c='test23';
        acc.Billing_ZIP_Postal_Code__c='test23';  
        acc.Business_Relationship__c='New Logo (Never Traded)';   
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'abc';
        con.AccountId = acc.id;
        con.email = 'abc@gmail.com';
        con.phone = '123';
        con.Same_As_The_Account_Billing_Address__c=true;
        insert con;
        
        /*Opportunity opp= new Opportunity();
        opp.OwnerId=UserInfo.getUserId();
        opp.AccountId=acc.Id;
        opp.Billing_Contact__c=con.Id;
        opp.Primary_Contact__c=con.Id;
        opp.name='Test Opportunity';
        opp.NVM_Credit_Card_ID__c='';
        opp.Unconfirmed_Sun_Order_Number__c='';
        opp.CurrencyISOCode='GBP';
        opp.StageName='New';
        opp.closeDate=System.today();
        //Order_number__c=contract.Id;
        opp.Business_Type__c='Renewal';
        opp.Forecast_Category__c='Commit';
        insert opp;*/
        
        Opportunity opp= new Opportunity(name='Test Opportunity', 
                                                      AccountID=acc.id,
                                                      Talent_Segment__c='Volume', 
                                                      TM_Phase__c='Post-Hire',
                                                      StageName='Verbal',
                                                      Billing_Contact__c=con.id,
                                                      Closedate=system.today(),
                                                      Primary_Contact__c=con.id,
                                                      CurrencyIsoCode='GBP',
                                                      NVM_Credit_Card_ID__c='1234',
                                                      Amount=1000,
                                                      Variation_Opportunity__c='NO',
                                                      OppUpdatedByOrderOn__c=Date.today(),
                                                      Original_Opportunity__c=null,
                                                      Annual_Contract_Value__c=1000.00,
                                                      Business_Type__c='Expansion',
                                                      GCSC__c='Phone',       
                                                      RecordTypeID=System.label.GCSCRecordType,
                                                      Forecast_Category__c='Commit',
                                                      Offering__c = 'OPQ'); 
            insert opp;
         
        
        ProjectObject__c project = new ProjectObject__c();
        project.Project_Manager__c = testUser.id;
        project.LBU__c = period1.BU__c;
        project.Project_Status__c = 'In Progress';
        project.Account__c = acc.id;
        project.Contact__c = con.id;
        //project.Opportunity__c = opp.id;
        project.Project_Name__c = acc.name;
        project.Project_Type__c = 'Sales';
        project.CurrencyIsoCode = 'GBP';
        project.Functional_Area__c = 'Sales';
        insert project;
        Milestone__c milestone1 = new Milestone__c();   
        milestone1.Project__c = project.Id;   // insert this first.
        milestone1.BU__c = period1.BU__c;
        milestone1.Milestone_Period__c = period1.id;
        milestone1.Amount__c = 123;
        milestone1.Service_Type2__c = '1:1 Assessment';
        milestone1.Milestone_Code2__c = 'Exercise Design';
        milestone1.CurrencyIsoCode = 'GBP';
        milestone1.Track_change__c = 'abcde';
        milestone1.Practice_Area__c = 'High Potential (HPS)';
        milestone1.Cross_Border_BU__c = null;
        insert milestone1;
        
		milestone1.Track_change__c = 'test';
		update milestone1;    
        
        //delete milestone1;
      }
    
    
    @isTest
    static void testMilestoneValidationChecks() {
        // Fetch test data
        List<Milestone__c> milestones = [SELECT Id, Milestone_Period__c, Project__c, Superuser_BU__c, Milestone_Period__r.Financial_Period_Closed__c FROM Milestone__c ];
        
        Test.startTest();
        // Call the method with a list of milestones
        MilestoneTrigger_Manager.MilestoneValidationChecks(milestones);
        Test.stopTest();
        
        // Validate results
        /*for (Milestone__c milestone : milestones) {
            if (milestone.Milestone_Period__r.Financial_Period_Closed__c) {
                System.assertEquals(1, Limits.getDmlStatements(), 'Validation should prevent deletion.');
            } else {
                System.assertEquals(0, Limits.getDmlStatements(), 'Validation should allow deletion.');
            }
        }*/
    }
    
    @isTest
    static void testMilestoneInsertChecks() {
        // Create new milestones for insertion
        Milestone__c milestone = new Milestone__c( Service_Type2__c = 'Service Type', Milestone_Code2__c = 'Code');
        List<Milestone__c> milestones = new List<Milestone__c>{milestone};
        
        Test.startTest();
        // Call the method with the new milestones
        MilestoneTrigger_Manager.MilestoneInsertChecks(milestones);
        Test.stopTest();
        
        // Validate results
        System.assertEquals('', milestone.Track_change__c, 'Track_change__c should be empty.');
        //System.assertNotEquals('', milestone.Track_changes_history__c, 'Track_changes_history__c should be updated.');
    }
    
    
   
    
    @isTest
    static void testExtendOppAccessToCrossBorderMilestone() {
        // Fetch test data
        /*User testUser=[select Id,name,Company_BU__c from user where Name='Globus Development'];
        Trigger_Activation__c setting = new Trigger_Activation__c();
            setting.Name = 'Milestone_Period_Trigger';
            setting.Active__c = True;
            insert setting;
          Trigger_Activation__c setting1 = new Trigger_Activation__c();
            setting1.Name = 'Account_Trigger';
            setting1.Active__c = True;
            insert setting1;
           Trigger_Activation__c setting2 = new Trigger_Activation__c();
            setting2.Name = 'Contact_Trigger';
            setting2.Active__c = True;
            insert setting2;
           Trigger_Activation__c setting3 = new Trigger_Activation__c();
            setting3.Name = 'Opportunity_Trigger';
            setting3.Active__c = True;
            insert setting3;
          Trigger_Activation__c setting4 = new Trigger_Activation__c();
            setting4.Name = 'Project_Trigger';
            setting4.Active__c = True;
            insert setting4;
          Trigger_Activation__c setting5 = new Trigger_Activation__c();
            setting5.Name = 'Milestone_Trigger';
            setting5.Active__c = True;
            insert setting5;
          
          Trigger_Activation__c setting6 = new Trigger_Activation__c();
            setting6.Name = 'OpportunityContactRoleTrigger';
            setting6.Active__c = True;
            insert setting6;
          
        Milestone_Period__c period1 = new Milestone_Period__c();
        period1.Signature_Date__c = Date.today();
        period1.Financial_Period_Date__c = date.today()+1;
        period1.Financial_Period_Closed__c = false;
        period1.BU__c = 'US5';
        period1.name = 'abc';
        insert  period1;
        
        Milestone_Period__c period2 = new Milestone_Period__c();
        period2.Signature_Date__c = Date.today() - 1;
        period2.Financial_Period_Date__c = date.today() - 1;
        period2.Financial_Period_Closed__c = false;
        period2.BU__c = 'US5';
        period2.name = 'abcd';
        insert  period2;
        
        Account acc= new Account();     // insert account
        acc.Name='Test234' + System.today();
        acc.BU__c='India - IN1';
        acc.CurrencyIsoCode='GBP'; 
        acc.Industry='Other';
        acc.Billing_Address_Line_1__c='test23';
        acc.Billing_City__c='test23';
        acc.Same_As_The_Billing_Address__c=true;
        acc.Billing_Country__c='test23';
        acc.Billing_State__c='test23';
        acc.Billing_ZIP_Postal_Code__c='test23';  
        acc.Business_Relationship__c='New Logo (Never Traded)';   
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'abc';
        con.AccountId = acc.id;
        con.email = 'abc@gmail.com';
        con.phone = '123';
        con.Same_As_The_Account_Billing_Address__c=true;
        insert con;
        
        Opportunity opp= new Opportunity();
        opp.OwnerId=UserInfo.getUserId();
        opp.AccountId=acc.Id;
        opp.Billing_Contact__c=con.Id;
        opp.Primary_Contact__c=con.Id;
        opp.name='Test Opportunity';
        opp.NVM_Credit_Card_ID__c='';
        opp.Unconfirmed_Sun_Order_Number__c='';
        opp.CurrencyISOCode='GBP';
        opp.StageName='New';
        opp.closeDate=System.today();
        //Order_number__c=contract.Id;
        opp.Business_Type__c='Renewal';
        opp.Forecast_Category__c='Commit';
        insert opp;
         
        
        ProjectObject__c project = new ProjectObject__c();
        project.Project_Manager__c = testUser.id;
        project.LBU__c = period1.BU__c;
        project.Project_Status__c = 'In Progress';
        project.Account__c = acc.id;
        project.Contact__c = con.id;
        //project.Opportunity__c = opp.id;
        project.Project_Name__c = acc.name;
        project.Project_Type__c = 'Sales';
        project.CurrencyIsoCode = 'GBP';
        project.Functional_Area__c = 'Sales';
        insert project;
        Milestone__c milestone1 = new Milestone__c();   
        milestone1.Project__c = project.Id;   // insert this first.
        milestone1.BU__c = period1.BU__c;
        milestone1.Milestone_Period__c = period1.id;
        milestone1.Amount__c = 123;
        milestone1.Service_Type2__c = '1:1 Assessment';
        milestone1.Milestone_Code2__c = 'Exercise Design';
        milestone1.CurrencyIsoCode = 'GBP';
        milestone1.Track_change__c = 'abcde';
        milestone1.Practice_Area__c = 'High Potential (HPS)';
        milestone1.Cross_Border_BU__c = null;
        insert milestone1;
        Map<Id, Milestone__c> oldMap = new Map<Id, Milestone__c>();
        oldMap.put(milestone1.id,milestone1);
        milestone1.Cross_Border_BU__c  = 'CN1';       
        //milestone1.Track_change__c = 'abc';        
        update milestone1;
        List<Milestone__c> Milestones = new List<Milestone__c>();
        Milestones.add(milestone1);*/
        Milestone__c milestone1 = [SELECT Id, Milestone_Period__c,Cross_Border_BU__c, Project__c FROM Milestone__c ];
        Map<Id, Milestone__c> oldMap = new Map<Id, Milestone__c>();
        oldMap.put(milestone1.id,milestone1);
        milestone1.Cross_Border_BU__c  = 'CN1';       
        //milestone1.Track_change__c = 'abc';        
        update milestone1;
        List<Milestone__c> Milestones = new List<Milestone__c>();
        Milestones.add(milestone1);
               
        system.debug('---milestone.Cross_Border_BU__c---'+ Milestones[0].Cross_Border_BU__c);
        system.debug('---oldMap---'+ oldMap);
        Test.startTest();
        // Call the method with the milestone list and old map
        MilestoneTrigger_Manager.extendOppAccessToCrossBorderMilestone(Milestones, oldMap);
       
        				
        Test.stopTest();
        
        // Validate results
        List<ProjectObject__Share> shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM ProjectObject__Share];
        System.assert(!shares.isEmpty(), 'Project shares should be created.');
    }
}
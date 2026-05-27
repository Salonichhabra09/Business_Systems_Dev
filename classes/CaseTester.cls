@isTest(seeAllData = true)
private class CaseTester{
 
    static testMethod void TestCaseOperations() {
        
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
         insert new KB_CaseCustomerSuccess__c (Name ='Test',
                                                   //Changes start for Customer Success to Customer Experience - SSE-17417
        					                                                  //Assigned_To__c ='AM India Customer Success',  
           					   												   Assigned_To__c ='India Customer Experience',
         					                                                 //Changes end.- SSE-17417 
                                                   
                                                   Help_Desk_Email__c ='in.customersuccess@shl.com',Platform__c ='iAssess/AMCAT');
    insert new KB_CaseCountryCodeAndAssignmentEmails__c (Name = 'Test',Channel__c = 'Web',Assigned_To__c = 'AM India Technical Support',Country_Display_Order__c =251,Help_Desk_Email__c ='globaltechnicalsupport@shl.com');
        Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
        List<Case> caseList = new List<Case>();
        List<RecordType>rtList = new List<RecordType>();
        id rtId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Central PS').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo1@demodomain.com');
        insert u1;
        /*Central_PS_Risk__c cpr = new Central_PS_Risk__c(Requestor_Name__c=u1.id,Custom_Instrument_S2P_Risk__c=1,Custom_Instrument_SODA_Risk__c=1,Custom_Report_Risk__c=1,HiPo_Risk__c=1,Integration_Risk__c=1,Multimedia_Risk__c=1,Optimisation_Risk__c=1,RJP_Risk__c=1,Serious_Games_Risk__c=1,SJT_Risk__c=1,SODA_Branding_Risk__c=1,Talent_Analytics_Risk__c=1,Talent_Audit_Risk__c=1,X360_Risk__c=1);
        insert cpr;*/
        Case caseps = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other', Opportunity__c=oppty.Id,Time_Spent__c=1);
        caseps.Solution_Type__c='General Consulting;360;Branding;Custom Instrument - S2P;Custom Instrument - SODA;Custom Report;Custom Report - Option 1;Custom Report - Option 2;Custom Report - Option 3;Data Extract; HiPo;Integration;Multimedia;Optimisation;RJP/RCP;Serious Games;SJT - Option 1;SJT - Option 2;SJT - Option 3;System Changes;Talent Analytics;Talent Audit';
        caseps.Requestor_Name__c=u1.id; 
        caseps.recordTypeId=rtId; 
        caseps.New_Integrator__c='Yes';
        //insert caseps;                                                   
        caseList.add(caseps);
        
        Case case1 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other', Opportunity__c=oppty.Id);
        caseList.add(case1);
        Case case12 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Bureau Services',Case_Type__c ='Order Amendment', Opportunity__c=oppty.Id);
        caseList.add(case12);
        Case case13 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Customer Collections', Opportunity__c=oppty.Id);
        caseList.add(case13);
        Case case14 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        caseList.add(case14);
        Case case15 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',
                               
                               //Changes start for Customer Success to Customer Experience - SSE-17417
        					  //Assigned_To__c ='Customer Success', 
           					    Assigned_To__c ='Customer Experience',
         					 //Changes end.- SSE-17417 
                               Opportunity__c=oppty.Id);
        caseList.add(case15);
        Case case16 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Legal', Opportunity__c=oppty.Id);
        caseList.add(case16);
        Case case17 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Managed Services',Case_Type__c ='Order Amendment', Opportunity__c=oppty.Id);
        caseList.add(case17);
        Case case18 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Order Assurance', Opportunity__c=oppty.Id,Case_Type__c ='Credit and Reissue');
        caseList.add(case18);
        Case case19 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Payment Services', Opportunity__c=oppty.Id);
        caseList.add(case19);
        Case case20 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Product1__c ='Simulations',Assigned_To__c ='Product',Issues__c='Product documentation', Opportunity__c=oppty.Id);
        caseList.add(case20);
        Case case21 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Product1__c ='DSI',Assigned_To__c ='PSDC',Issues__c='Results', Opportunity__c=oppty.Id);
        caseList.add(case21);
        Case case22 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Sales Order Processing', Opportunity__c=oppty.Id);
        caseList.add(case22);
        Case case23 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Technical Support',Opportunity__c=oppty.Id);
        caseList.add(case23);
        Case case24 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Training Academy Services', Opportunity__c=oppty.Id);
        caseList.add(case24);
        Case case25 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='US Production', Opportunity__c=oppty.Id);
        caseList.add(case25);
        
        Case case26 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Managed Services',Case_Type__c ='Order Amendment', Opportunity__c=oppty.Id);
        caseList.add(case26);
        Case case27 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Managed Services',Case_Type__c ='Order Amendment', Opportunity__c=oppty.Id);
        caseList.add(case27);
        Case case28 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Managed Services',Case_Type__c ='Order Amendment', Opportunity__c=oppty.Id);
        caseList.add(case28);
        Case case29 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Managed Services',Case_Type__c ='Order Amendment', Opportunity__c=oppty.Id);
        caseList.add(case29);
        Case case30 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Managed Services',Case_Type__c ='Order Amendment', Opportunity__c=oppty.Id);
        caseList.add(case30);
//----------------- Added by Prabhat Arora for CodeCoverage Starts Here---------->>
        Case case31 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Product Support',Issues__c = 'Platform-related', Product1__c = 'Ability - Verify',Opportunity__c=oppty.Id);
        caseList.add(case31);
        Case case32 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='Localisation',Issues__c = 'Platform-related', Product1__c = 'Ability - Verify',Opportunity__c=oppty.Id);
        caseList.add(case32);
        Case case33 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CEB Sunstone Analytics Client Advisors',Issues__c = 'Platform-related', Product1__c = 'Ability - Verify',Opportunity__c=oppty.Id);
        caseList.add(case33);
        
        Case case34 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Issues__c = 'Platform-related', Product1__c = 'Ability - Verify',Opportunity__c=oppty.Id);
        caseList.add(case34);
        Case case35 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Issues__c = 'Platform-related', Product1__c = 'Ability - Verify',Opportunity__c=oppty.Id);
        caseList.add(case35);
        Case case36 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Issues__c = 'Platform-related', Product1__c = 'Ability - Verify',Opportunity__c=oppty.Id);
        caseList.add(case36);
        Case case37 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Issues__c = 'Platform-related', Product1__c = 'Ability - Verify',Opportunity__c=oppty.Id);
        caseList.add(case37);
//----------------- Added by Prabhat Arora for CodeCoverage Ends Here---------->>
        
        Case casea1 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        Case casea2 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        Case casea3 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        Case casea4 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        Case casea5 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        Case casea6 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        Case casea7 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        Case casea8 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        Case casea9 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id);
        Case casea10 = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other',Assigned_To__c ='CSIT',Case_Type__c ='Customer Systems Training request', Opportunity__c=oppty.Id); 
        
        caseList.add(casea1); 
        caseList.add(casea2);
        caseList.add(casea3);
        caseList.add(casea4);
        caseList.add(casea5);
        caseList.add(casea6);    
        caseList.add(casea7);
        caseList.add(casea8);
        caseList.add(casea9);
        caseList.add(casea10);    
        insert caseList;
        Test.startTest();            
            
            casea1.Assigned_To__c='Technical Support';
            
            List<Case>updateCaseList = new List<Case>();
            updateCaseList.add(casea1);
            
            case12.Case_Type__c ='Order Amendment - Express';
            update case12;
            updateCaseList.add(case12);
            case12.Case_Type__c ='Credit Request';
            update case12;      //----------------- Added by Prabhat Arora for CodeCoverage Starts Here---------->>
            case12.Case_Type__c ='Credit Approval';
            update case12;
            case12.Case_Type__c ='Order Amendment - Project';
            update case12;
            case12.Case_Type__c ='Offline Request';
            update case12;
                               //----------------- Added by Prabhat Arora for CodeCoverage Ends Here------------->>
             
            casea2.Case_Type__c ='Credit Approval';
            updateCaseList.add(casea2);
            
            casea3.Case_Type__c ='Order Amendment - Project';
            updateCaseList.add(casea3);
            
            casea4.Case_Type__c ='Offline Request';
            updateCaseList.add(casea4); 
           
            
            case14.Case_Type__c ='New SODA site build';
            updateCaseList.add(case14);
           
            casea5.Case_Type__c ='SODA System Change';
            updateCaseList.add(casea5);
            
            casea6.Case_Type__c ='New TalentCentral site build';
            updateCaseList.add(casea6);
            casea7.Case_Type__c ='Other';
            updateCaseList.add(casea7);
            
            casea8.Case_Type__c ='TC Trial New Site Set Up';
            updateCaseList.add(casea8);
            
            casea9.Case_Type__c ='TC Trial Content';
            updateCaseList.add(casea9);
            
            casea10.Case_Type__c ='TC Demo Site Set Up';
            updateCaseList.add(casea10);
            
            case17.Case_Type__c ='Order Amendment - Express';
            updateCaseList.add(case17);
            
            case26.Case_Type__c ='Credit Request';
            updateCaseList.add(case26);
            case27.Case_Type__c ='Credit Approval';
            updateCaseList.add(case27);
            case28.Case_Type__c ='Order Amendment - Project';
            updateCaseList.add(case28);
            case29.Case_Type__c ='Offline Request';
            updateCaseList.add(case29);
        
            case35.Case_Type__c ='New S2P site build';
            updateCaseList.add(case35);
            case36.Case_Type__c ='TC System Change';
            updateCaseList.add(case36);
            case37.Case_Type__c ='S2P System Change';
            updateCaseList.add(case37);
            case34.Case_Type__c ='MS access';
            updateCaseList.add(case34);
        
        
            case30.Case_Type__c ='Unit Adjustment';
            updateCaseList.add(case30);
            
            case18.Case_Type__c ='GK1 Account Change';
            updateCaseList.add(case18);
            
            
            System.debug('Case has been created: ' + case1.id);
            Case case2=new case(id=case1.id,Solution__c='User Error - Clarified Login Steps',Assigned_To__c ='Bureau Services');
            updateCaseList.add(case2);
            update updateCaseList;        
            // Retrieve the new case
            Case  case3 = [SELECT id FROM case WHERE Id =:case1.Id];
            Delete case3;
        
       
       
       
        Test.stopTest();
              
       
    }
    static testMethod void TestCaseprojectupdate(){
        
        
        
         Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
        Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);

      //  ProjectObject__c parentpr = CreateTestData.getProject(Account.id ,oppty.id, parentpr.Scoped_Hours_Effort__c = 0);
       // ProjectObject__c cpsproject = CreateTestData.getCPSProject(parentpr.id);
        id rtId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Central PS').getRecordTypeId();
        
        Case caseps = new case(AccountId=Account.id,ContactId=Contact.Id,Problem2__c='Login Issue',Solution__c='other', Time_Spent__c=1);
        caseps.Solution_Type__c='General Consulting;360;Branding;Custom Instrument - S2P;Custom Instrument - SODA;Custom Report;Custom Report - Option 1;Custom Report - Option 2;Custom Report - Option 3;Data Extract; HiPo;Integration;Multimedia;Optimisation;RJP/RCP;Serious Games;SJT - Option 1;SJT - Option 2;SJT - Option 3;System Changes;Talent Analytics;Talent Audit';
  
        caseps.recordTypeId=rtId; 
        caseps.New_Integrator__c='Yes';
         // caseps.project__c=cpsproject.id;
        insert caseps;     
            Case editcase = new case (id = caseps.id);
           // editcase.project__c= parentpr.id;
            update editcase;
            //insert editcase;
        
        
    }
     static testMethod void TestCSIT(){
                  Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
        Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
       //id rtId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Information_only_CSIT').getRecordTypeId();
         Case csit = new Case();
         csit.Case_Type__c ='Content Disable';
         csit.Time_Spent__c=12;
         csit.Assigned_To__c='CSIT';
         csit.Assignee_Email__c='onlinesystemupdates@shl.com';
       // csit.Problem1__c='Login Issue';
         csit.Problem2__c='Login Issue';
         csit.Solution__c='Bad Connection';
     // csit.Caller_Type__c = 'Candidate';
         insert csit;
          
  
     
     }
   private  static testMethod void WebToCaseTest2(){
        test.startTest(); 
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
      
      List<KB_CaseCustomerSuccess__c> kbccsList = new List<KB_CaseCustomerSuccess__c>();
      List<KB_CaseCountryCodeAndAssignmentEmails__c> kbcccaList = new List<KB_CaseCountryCodeAndAssignmentEmails__c>();
      KB_CaseCustomerSuccess__c kbccs1 = new KB_CaseCustomerSuccess__c(Name ='Test3',
                                                                              //Changes start for Customer Success to Customer Experience - SSE-17417
        					                                                  //Assigned_To__c ='AM India Customer Success',  
           					   												   Assigned_To__c ='India Customer Experience',
         					                                                 //Changes end.- SSE-17417 
                                                                             
                                                                             Help_Desk_Email__c ='in.customersuccess@shl.com',Platform__c ='iAssess/AMCAT');
      KB_CaseCustomerSuccess__c kbccs2 = new KB_CaseCustomerSuccess__c(Name ='Test1',ISO3__c ='AUS',
                                                                             //Changes start for Customer Success to Customer Experience - SSE-17417
                                                                            //Assigned_To__c ='APAC Customer Success',
                                                                               Assigned_To__c ='APAC Customer Experience',
                                                                             //Changes end.- SSE-17417 
                                                                             Help_Desk_Email__c ='au.customersuccess@shl.com');
      kbccsList.add(kbccs1);
      kbccsList.add(kbccs2);
      insert kbccsList;
      
      KB_CaseCountryCodeAndAssignmentEmails__c kbccca1 = new KB_CaseCountryCodeAndAssignmentEmails__c(Name = 'Test4',Channel__c = 'Web',Assigned_To__c = 'AM India Technical Support',Country_Display_Order__c =251,Help_Desk_Email__c ='globaltechnicalsupport@shl.com',Platform__c ='iAssess/AMCAT');
      KB_CaseCountryCodeAndAssignmentEmails__c kbccca2 = new KB_CaseCountryCodeAndAssignmentEmails__c(Name = 'Test2',Channel__c = 'Web',ISO3__c ='IND',
                                                                                                      Assigned_To__c = 'AM India Technical Support',Country_Display_Order__c =252,Help_Desk_Email__c ='globaltechnicalsupport@shl.com',Platform__c ='iAssess/AMCAT');
      kbcccaList.add(kbccca1);
      kbcccaList.add(kbccca2);
      insert kbcccaList;
 
   
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='System Administrator' limit 1];
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
          Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
        
         Case cse2 = new Case();
            cse2.What_platform_are_you_using__c ='iAssess/AMCAT';
           cse2.origin = 'Web';
        cse2.Please_select_the_type_of_enquiry__c ='Technology related questions or issue';
          cse2.Assigned_To__c ='AM India Technical Support';
          cse2.Assignee_Email__c ='globaltechnicalsupport@shl.com';
          cse2.Problem2__c = 'Login Issue';
          cse2.IsSupport__c = true;
          cse2.Time_Spent__c = 6;
       cse2.Call_Type__c = 'Demo';
         cse2.Subject = 'Test Subject';
          cse2.Solution__c ='Bad Connection';
          cse2.System__c ='Brainbench';
          cse2.System_Id__c = '12';
      System.runAs(user){
      insert cse2;
      } 
          Case cse3 = new Case();
          cse3.What_platform_are_you_using__c = 'Brainbench';
         cse3.origin = 'Web';
         cse3.Subject = 'Test Subject';
        cse3.Please_select_the_type_of_enquiry__c ='Technology related questions or issue';
          cse3.Case_Country__c ='IND';
             cse3.Problem2__c = 'Login Issue';
          cse3.Assigned_To__c = 'AM India Technical Support';
          cse3.Assignee_Email__c ='globaltechnicalsupport@shl.com';
          cse3.Solution__c = 'Bad Connection';
          cse3.System__c ='Brainbench';
          cse3.IsSupport__c = true;
      cse3.System_Id__c = '12';
          cse3.System_Id__c = '11';
       cse3.Call_Type__c = 'Demo';
          cse3.Time_Spent__c = 6;
      System.runAs(user){
          //insert cse3;
      }
      test.stopTest();
    }  
  private  static testMethod void WebToCaseTest(){
         test.startTest(); 
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
      
      List<KB_CaseCustomerSuccess__c> kbccsList = new List<KB_CaseCustomerSuccess__c>();
      List<KB_CaseCountryCodeAndAssignmentEmails__c> kbcccaList = new List<KB_CaseCountryCodeAndAssignmentEmails__c>();
      KB_CaseCustomerSuccess__c kbccs1 = new KB_CaseCustomerSuccess__c(Name ='Test3',
                                                                             //Changes start for Customer Success to Customer Experience - SSE-17417
        					                                                  //Assigned_To__c ='AM India Customer Success',  
           					   												   Assigned_To__c ='India Customer Experience',
         					                                                 //Changes end.- SSE-17417 
                                                                             
                                                                             Help_Desk_Email__c ='in.customersuccess@shl.com',Platform__c ='iAssess/AMCAT');
      KB_CaseCustomerSuccess__c kbccs2 = new KB_CaseCustomerSuccess__c(Name ='Test1',ISO3__c ='AUS',
                                                                             //Changes start for Customer Success to Customer Experience - SSE-17417
                                                                            //Assigned_To__c ='APAC Customer Success',
                                                                               Assigned_To__c ='APAC Customer Experience',
                                                                             //Changes end.- SSE-17417 
                                                                            
                                                                             Help_Desk_Email__c ='au.customersuccess@shl.com');
      kbccsList.add(kbccs1);
      kbccsList.add(kbccs2);
      insert kbccsList;
      
      KB_CaseCountryCodeAndAssignmentEmails__c kbccca1 = new KB_CaseCountryCodeAndAssignmentEmails__c(Name = 'Test4',Channel__c = 'Web',Assigned_To__c = 'AM India Technical Support',Country_Display_Order__c =251,Help_Desk_Email__c ='globaltechnicalsupport@shl.com',Platform__c ='iAssess/AMCAT');
      KB_CaseCountryCodeAndAssignmentEmails__c kbccca2 = new KB_CaseCountryCodeAndAssignmentEmails__c(Name = 'Test2',Channel__c = 'Web',ISO3__c ='IND',Assigned_To__c = 'AM India Technical Support',Country_Display_Order__c =252,Help_Desk_Email__c ='globaltechnicalsupport@shl.com',Platform__c ='iAssess/AMCAT');
      kbcccaList.add(kbccca1);
      kbcccaList.add(kbccca2);
      insert kbcccaList;
 
   
        Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='System Administrator' limit 1];
        User user = [Select id from user where ProfileId = : pf.Id AND isActive=true limit 1];
          Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
          Case cse = new Case();
      cse.Problem2__c = 'Login Issue';
          cse.What_platform_are_you_using__c = 'iAssess/AMCAT';
          cse.origin = 'Web';
          cse.Case_Country__c ='IND';
            //Changes start for Customer Success to Customer Experience - SSE-17417
        					                                                  //cse.Assigned_To__c = 'AM India Customer Success';  
           					   												   cse.Assigned_To__c ='India Customer Experience';
         					                                                 //Changes end.- SSE-17417 
          
          cse.Assignee_Email__c = 'in.customersuccess@shl.com';
          cse.Please_select_the_type_of_enquiry__c = 'Product, billing or ordering query';
          cse.IsSupport__c = true;
          cse.Call_Type__c = 'Demo';
      cse.Solution__c ='Bad Connection';
          cse.Time_Spent__c = 6;
      cse.Subject = 'Test Subject';
           System.runAs(user){
          insert cse;
           }
          
          Case cse1 = new Case();
          cse1.What_platform_are_you_using__c ='Brainbench';
          cse1.origin = 'Web';
          cse1.Please_select_the_type_of_enquiry__c ='Product, billing or ordering query';
          cse1.Case_Country__c ='AUS';
          //Changes start for Customer Success to Customer Experience - SSE-17417
         //cse1.Assigned_To__c ='APAC Customer Success';
           cse1.Assigned_To__c ='APAC Customer Experience';
         //Changes end.- SSE-17417 
          
          cse1.Assignee_Email__c = 'au.customersuccess@shl.com';
          cse1.IsSupport__c = true;
          cse1.Time_Spent__c = 6;
          cse1.Problem2__c = 'Login Issue';
          cse1.Solution__c ='Bad Connection';
          cse1.Subject = 'Test Subject';
          cse1.Call_Type__c ='Demo';
          cse1.System_Id__c = '12';
          cse1.Priority = 'P2 - High';
          cse1.System__c = 'TalentCentral';
          System.runAs(user){
          insert cse1;
          }
   
  
         
      test.stopTest();
      }
    
  //Changes Added by Prachi(02-06-2022)  
  private  static testMethod void ReferralCaseTest(){
        test.startTest();
       List<Case> caseRec = new List<Case>();
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User user = new User(Alias = 'standt1',
                           Country='United Kingdom',
                           Email='demo1@randomdemodomain.com',
                           EmailEncodingKey='UTF-8', 
                           LastName='Testing',
                           LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo1@demodomain.com');
        insert user;
        
         Id recordId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Referral' LIMIT 1].id;
          
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
           System.runAs(user){
           insert cse;
           }
           cse.Assigned_To__c = 'Measurement Capabilities';
            System.runAs(user){
                try{update cse;}catch(DMLException ex){
                    String Message = ex.getMessage();
                     system.assert(Message.contains('You do not have the necessary permissions to raise a case to the Measurement Capabilities team.'));
               }
           }
      
         
      
     
      test.stopTest();
      
          
      
  }
  //Changes Added by PRachi(02-05-2022)
      private static testMethod void Cand_CustTest(){
        test.startTest();
          Account Account=CreateTestData.GetAccount();
         Contact Contact=CreateTestData.getContact(Account.id);
          Profile pf =[Select p.Name,p.Id From Profile p where p.Name ='System Administrator' limit 1];
          User user2 = [Select id , lastName,Firstname from user where ProfileId = : pf.Id AND isActive=true limit 1];
          system.debug('HEllo Test : ' + user2.Firstname + ' ' + user2.Lastname);
          Case cse3 = new Case();
          cse3.What_platform_are_you_using__c = 'Brainbench';
          cse3.origin = 'Web';
          cse3.Subject = 'Test Subject';
          cse3.Please_select_the_type_of_enquiry__c ='Technology related questions or issue';
          cse3.Case_Country__c ='IND';
          cse3.Problem2__c = 'Login Issue';
          cse3.Assigned_To__c = 'AM India Technical Support';
          //cse3.Assignee_Email__c ='globaltechnicalsupport@shl.com';
          cse3.Solution__c = 'Bad Connection';
          cse3.System__c ='Brainbench';
          cse3.IsSupport__c = true;
          cse3.System_Id__c = '11';
          cse3.Time_Spent__c = 6;
          cse3.Caller_Type__c = 'Candidate';
          cse3.Candidate_Name__c = 'Test Record Case';
          cse3.Candidate_Email_Address__c = 'Test@shl.com';
          cse3.Candidate_Telephone__c = '123456789';
          cse3.Additional_details_on_your_enquiry__c = 'Test Data';
          system.runAs(user2){   
          insert cse3;
          }
      Case c = [Select id , subject from Case where id = :cse3.id];
      system.assertEquals('Test Record Case Test Data', c.Subject);
      
      
       Case cse4 = new Case();
          cse4.What_platform_are_you_using__c = 'Brainbench';
          cse4.origin = 'Web';
          cse4.Subject = 'Test Subject';
          cse4.Please_select_the_type_of_enquiry__c ='Technology related questions or issue';
          cse4.Case_Country__c ='IND';
          cse4.Problem2__c = 'Login Issue';
          cse4.Assigned_To__c = 'AM India Technical Support';
          cse4.Assignee_Email__c ='globaltechnicalsupport@shl.com';
          cse4.Solution__c = 'Bad Connection';
          cse4.System__c ='Brainbench';
          cse4.IsSupport__c = true;
          cse4.System_Id__c = '11';
          cse4.Time_Spent__c = 6;
          cse4.Caller_Type__c = 'Customer';
          cse4.Admin_Contact__c = 'Test Record Case';
          cse4.Contact_Email__c = 'Test@shl.com';
          cse4.Candidate_Tel__c = '123456789';
          cse4.Additional_details_on_your_enquiry__c = 'Test Data';
          system.runAs(user2){   
          insert cse4;
          }
      Case c2 = [Select id , subject from Case where id = :cse4.id];
      system.assertEquals('Test Record Case Test Data', c2.Subject);
          
           cse4.status = 'Resolved/Closed';
           cse4.OwnerId = UserInfo.getUserId();
          // update cse4;
         test.stopTest(); 
      }    
  
    //Changes Added by Prachi(02-06-2022)  
    private  static testMethod void CPSCaseTest(){
        test.startTest();
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
        Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
         Id recordIdCPS = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Central PS' LIMIT 1].id;
       
       
       ProjectObject__c Proj =CreateTestData.getProject(Account.id,oppty.id);
      Case case25 = new case(AccountId=Account.id, Requestor_Name__c = UserInfo.getUserId(),Solution_Type__c = 'BOS',
                              ContactId=Contact.Id, CurrencyIsoCode = 'GBP', Subject = 'Test Record', RecordTypeId = recordIdCPS,
                              Status = 'Open', Opportunity__c=oppty.Id , Project__c = Proj.id);
       insert case25;
        
       test.stopTest();
    }
     private  static testMethod void CaseAssigneeEmailTest1(){
        test.startTest();
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
        Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
         Id recordId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Referral' LIMIT 1].id;
       
     
     Case cse = new Case();
          cse.What_platform_are_you_using__c = 'iAssess/AMCAT';
          cse.origin = 'Phone';
          cse.Case_Country__c ='IND';
          cse.RecordTypeId = recordId;
          cse.Assigned_To__c = 'Legal';
          cse.Please_select_the_type_of_enquiry__c = 'Product, billing or ordering query';
          cse.IsSupport__c = true; 
          cse.Time_Spent__c = 6;
          cse.Subject = 'Test Subject';
          cse.RecordTypeId = recordId;
          cse.Case_Type__c = 'Referred to Legal';
           
           insert cse;
     
      
       test.stopTest();
    }
     private  static testMethod void CaseAssigneeEmailTest2(){
        test.startTest();
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
        Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
         Id recordId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Referral' LIMIT 1].id;
       
     
     Case cse = new Case();
          cse.What_platform_are_you_using__c = 'iAssess/AMCAT';
          cse.origin = 'Phone';
          cse.Case_Country__c ='IND';
          cse.RecordTypeId = recordId;
          cse.Assigned_To__c = 'Customer Collections';
          cse.Please_select_the_type_of_enquiry__c = 'Product, billing or ordering query';
          cse.IsSupport__c = true; 
          cse.Time_Spent__c = 6;
          cse.Subject = 'Test Subject';
          cse.RecordTypeId = recordId;
          cse.Case_Type__c = 'Refunds';
          cse.ContactId = Contact.id;
           
           insert cse;
           test.stopTest();
    }
       
        private  static testMethod void CaseAssigneeEmailTest3(){
        test.startTest();
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
        Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
         Id recordId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Referral' LIMIT 1].id;
       
     
     Case cse = new Case();
          cse.What_platform_are_you_using__c = 'iAssess/AMCAT';
          cse.origin = 'Phone';
          cse.Case_Country__c ='IND';
          cse.RecordTypeId = recordId;
          cse.Assigned_To__c = 'Order Assurance';
          cse.Please_select_the_type_of_enquiry__c = 'Product, billing or ordering query';
          cse.IsSupport__c = true; 
          cse.Time_Spent__c = 6;
          cse.Subject = 'Test Subject';
          cse.RecordTypeId = recordId;
          cse.Case_Type__c = 'GK1 Account Change';
          cse.ContactId = Contact.id;
           
           insert cse;
           test.stopTest();
    } 
 
         private  static testMethod void CaseAssigneeEmailTest4(){
        test.startTest();
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
        Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
         Id recordId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Referral' LIMIT 1].id;
       
     
     Case cse = new Case();
          cse.What_platform_are_you_using__c = 'iAssess/AMCAT';
          cse.origin = 'Phone';
          cse.Case_Country__c ='IND';
          cse.RecordTypeId = recordId;
          cse.Assigned_To__c = 'Order Assurance';
          cse.Please_select_the_type_of_enquiry__c = 'Product, billing or ordering query';
          cse.IsSupport__c = true; 
          cse.Time_Spent__c = 6;
          cse.Subject = 'Test Subject';
          cse.RecordTypeId = recordId;
          cse.Case_Type__c = 'Other';
          cse.ContactId = Contact.id;
           
           insert cse;
           test.stopTest();
    } 
    
        
private  static testMethod void updateNumberOfChangesOnJobTest(){
        Test.startTest();
        Account Account=CreateTestData.GetAccount();
        Contact Contact=CreateTestData.getContact(Account.id);
        Opportunity oppty = CreateTestData.getOpportunity(Account.id,Contact.Id);
        Id recordId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Information only – Services' LIMIT 1].id;
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Id userId = [select id from User where Is_Bureau_Service_Manager__c = true and IsActive = true limit 1].id;
        
        Job__c job = new Job__c();
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.Project_Lead__c = userId;    
        job.InternalContact__c = UserInfo.getUserId();      
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = '';
        job.ShortFall_Manager__c = 1;
        job.Shortfall_Peer__c = 2;
        job.Shortfall_Subordinate__c = 3;
        job.ShortFall_Customer__c = 2;
        job.Shortfall_Client__c = 2;
        job.ShortFall_Other__c = 2;
        job.PurchaseOrderNo__c='rtertr';
        job.Generic_BS_Field_One__c='Bureau Service';
        job.Generic_Field_MS_One__c='Managed Service';
        job.Generic_Field_Pipeline_One__c = 'MS Pipeline';
        job.Is_Redirect_To_Task__c=true;
        job.System_Used__c = 'MFS;SODA / MFS;SODA / S2P;SODA / PD360;SHL ONLINE;';
        job.System_Used__c ='SHL ONLINE';
        job.RecordTypeId = RecordTypeIdJob1;  
    	job.Job_Region__c ='Non China';
        job.MS_Line_of_Business__c='Talent Management';
        insert job;
     
          Case cse = new Case();
          cse.What_platform_are_you_using__c = 'iAssess/AMCAT';
          cse.origin = 'Phone';
          cse.Case_Country__c ='IND';
          cse.RecordTypeId = recordId;
          cse.Assigned_To__c = 'Order Assurance';
          cse.Please_select_the_type_of_enquiry__c = 'Product, billing or ordering query';
          cse.IsSupport__c = true; 
          cse.Time_Spent__c = 6;
          cse.Subject = 'Test Subject';
          cse.RecordTypeId = recordId;
          cse.Case_Type__c = 'Other';
          cse.ContactId = Contact.id;
          cse.Solution__c = 'Change Request';
          cse.Problem2__c = 'Managed Services Project';
          cse.Bureau_Job__c = job.id;
          insert cse;
          Test.stopTest();
    }         
        
    // Test class 
    // Class: CaseTriggerManager_1 
    // Method Name: LinkWebFormAttachmentToCase
    private  static testMethod void linkWebFormAttachmentToCase(){
        
        Id recordId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Information only – Services' LIMIT 1].id;
        
        Blob inputBlob = Blob.valueOf('Hello');
        String base64Data = EncodingUtil.base64Encode(inputBlob);
        String dataUri = 'data:image/png;base64,' + base64Data;
        String dataUri1 = 'data:image/png;base64,' + 'ThisIsNotBase64!!!';
        
        Case cse = new Case();
        cse.What_platform_are_you_using__c = 'iAssess/AMCAT';
        cse.origin = 'Web';
        cse.Case_Country__c ='IND';
        cse.RecordTypeId = recordId;
        cse.Assigned_To__c = 'Order Assurance';
        cse.Please_select_the_type_of_enquiry__c = 'Technology related questions or issue';
        cse.IsSupport__c = true; 
        cse.Time_Spent__c = 6;
        cse.Subject = 'Test Subject';
        cse.RecordTypeId = recordId;
        cse.Case_Type__c = 'Other';
        cse.Solution__c = 'Bad Connection';
        cse.Problem2__c = 'Login Issue';
        cse.Attachment_Name__c = 'SampleFile.png';
        cse.Attachment_Body__c = dataUri;
        
        // Invalid File or Base64
        Case cse1 = new Case();
        cse1.What_platform_are_you_using__c = 'iAssess/AMCAT';
        cse1.origin = 'Web';
        cse1.Case_Country__c ='IND';
        cse1.RecordTypeId = recordId;
        cse1.Assigned_To__c = 'Order Assurance';
        cse1.Please_select_the_type_of_enquiry__c = 'Technology related questions or issue';
        cse1.IsSupport__c = true; 
        cse1.Time_Spent__c = 6;
        cse1.Subject = 'Test Subject';
        cse1.RecordTypeId = recordId;
        cse1.Case_Type__c = 'Other';
        cse1.Solution__c = 'Bad Connection';
        cse1.Problem2__c = 'Login Issue';
        cse1.Attachment_Name__c = 'SampleFile1.png';
        cse1.Attachment_Body__c = dataUri1;
        
        Test.startTest();
        insert cse;
        insert cse1;
        Test.stopTest();
    }         

         
      }
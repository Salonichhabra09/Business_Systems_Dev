@isTest
public class BureauJob_NewTabPanel_Controller_Test {
      public static Job__c job;
    public static List<Bureau_Item_Master__c> bItemMastersList;
    //public static List<Instrument_Score__c> instrumentScoresList;
    public static List<Contact> contacts;// = [Select id,AccountId,Account.BU__c from Contact where Account.BU__c!='' AND Account.BU__c ='UK - UK1' order by AccountId limit 2 ];
    public static List<System__c> systemsList;// = [Select id from System__c where System_Type__c!='' LIMIT 2];
    public static List<System_Login__c> systemLoginsList;
    public static List<Bureau_System__c> bureauSystemsList;
    public static List<Bureau_Product__c> bureauProductList;
    public static List<Bureau_Candidate__c> bureauCandidateList;
    public static List<Bureau_Candidate_Login__c> bureauCandidateLoginList;
    //public static List<Bureau_Candidate_Score__c> bCandidateScoresList;
    public static List<Bureau_Rating__c> ratingsList;
    public static List<Bureau_Rating__c> ratingsList1;
    public static List<Bureau_Rating_Progress__c> ratingProgressList;
    public static List<Task> tasksList;
    public static List<Report_User__c> supervisorFeedBackProviderList;
    public static Id RecordTypeId;
    public static List<RecordType> RecordTypeList;
    public static Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
    public static Account account;
    //Test tab panel controller
   @IsTest(seeAlldata=true)
    static void testTabPanelController(){
        Test.startTest();
        //createTestData();
        createJobTestData();
        /*
        PageReference pageRef = Page.BureauJob_TabPage;
        pageRef.getParameters().put('id',job.Id);
        Test.setCurrentPage(pageRef);
        BureauJob_NewTabPanel_Controller mmsp = new BureauJob_NewTabPanel_Controller();
		*/
        
        Test.stopTest();
    }
    
     //create  job test data
    public static void createJobTestData()
    {
        Id userId = [select id from User where Is_Bureau_Service_Manager__c = true and IsActive = true limit 1].id;
        job = new Job__c();
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.Project_Lead__c = userId;
        //job.Account__c = contacts[0].AccountId;
        //job.Contact__c = contacts[0].Id;
        job.InternalContact__c = UserInfo.getUserId();
        //job.External_Contact__c = contacts[0].Id;
        job.External_Contact_Others__c = 'External Contact';
        job.External_Contact_Other_Email_Address__c='test@test.com';
        job.Candidate_Username_Prefix__c = 'Test';
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
        job.MS_Line_of_Business__c = 'TA - Corporate';
        insert job;
        job = [Select id,End_Date__c,System_Used__c,PurchaseOrderNo__c,name,Job_Type__c,RecordTypeId,Start_Date__c,Project_Lead__c,Account__c,Contact__c,InternalContact__c,External_Contact_Other_Email_Address__c,
               Candidate_Username_Prefix__c,ShortFall_Manager__c,Shortfall_Peer__c,Shortfall_Subordinate__c,External_Contact_Others__c,
               ShortFall_Customer__c,Shortfall_Client__c,ShortFall_Other__c,Account_BU__c from Job__c where id=:job.id];
        System.debug('***job.Account_BU__c***'+job.Account_BU__c+'****Account__c****'+job.Account__c);
        
        supervisorFeedBackProviderList = new List<Report_User__c>();
        Report_User__c ru = new Report_User__c(Email__c='test@test.com',FirstName__c='First Name',LastName__c='Last Name',Username__c='JobNameRUName',User_Type__c='Supervisor',Job__c=job.Id);
        supervisorFeedBackProviderList.add(ru);
        
        insert supervisorFeedBackProviderList;
        
        
        bItemMastersList = new List<Bureau_Item_Master__c>();
        Bureau_Item_Master__c bItemMaster = new Bureau_Item_Master__c();
        bItemMaster.Name = 'INM1';
        bItemMaster.BU__c = 'UK - UK1';
        bItemMaster.Category__c = '360 Services';
        bItemMaster.IM_Code__c = 'ITEMMASTERCODE';
        bItemMaster.Languages__c = 'English';
        bItemMaster.BU__c = job.Account_BU__c;
        bItemMaster.Type__c = 'Instrument';
        bItemMastersList.add(bItemMaster);
        
        Bureau_Item_Master__c bItemMaster1 = new Bureau_Item_Master__c();
        bItemMaster1.Name = 'INM2';
        bItemMaster1.BU__c = 'UK - UK1';
        bItemMaster1.Category__c = 'Online Admin';
        bItemMaster1.IM_Code__c = 'ITEMMASTERCODE';
        bItemMaster1.Languages__c = 'English';
        bItemMaster1.BU__c = job.Account_BU__c;
        bItemMaster1.Type__c = 'Instrument';
        bItemMastersList.add(bItemMaster1);
        
        insert bItemMastersList;
        
        
      /*  instrumentScoresList = new List<Instrument_Score__c>();
        Instrument_Score__c instrumentScore = new Instrument_Score__c();
        instrumentScore.Name = 'Score1';
        instrumentScore.Instrument__c = bItemMastersList[1].id;
        instrumentScoresList.add(instrumentScore);
        
        insert instrumentScoresList; */
        
        createSystemTestData();
        systemLoginsList = new List<System_Login__c>();
        System_Login__c systemLogin = new System_Login__c();
        if(systemsList.size()>0)
        {
            systemLogin.System__c = systemsList[0].id;
        }
        systemLogin.Username__c = 'Ramesh.Dhull';
        systemLoginsList.add(systemLogin);
        System_Login__c systemLogin1 = new System_Login__c();
        if(systemsList.size()>0)
        {
            systemLogin1.System__c = systemsList[1].id;
        }
        systemLogin1.Username__c = 'Ramesh.Dhull';
        systemLoginsList.add(systemLogin1);
        
        insert systemLoginsList;
        
        
        
        bureauSystemsList = new List<Bureau_System__c>();
        Bureau_System__c bureauSystem = new Bureau_System__c();
        //bureauSystem.Account__c = contacts[0].AccountId;
        bureauSystem.Bureau_Job__c =job.Id;
        if(systemsList.size()>0)
        {
            bureauSystem.System__c =systemsList[0].Id;
        }
        bureauSystem.System_Login__c = systemLoginsList[0].Id;
        bureauSystem.Report_Language__c ='English';
        bureauSystemsList.add(bureauSystem);
        Bureau_System__c bureauSystem1 = new Bureau_System__c();
        //bureauSystem1.Account__c = contacts[0].AccountId;
        bureauSystem1.Bureau_Job__c =job.Id;
        if(systemsList.size()>0)
        {
            bureauSystem1.System__c =systemsList[1].Id;
        }
        bureauSystem1.System_Login__c =systemLoginsList[1].Id;
        bureauSystem1.Report_Language__c ='English';
        bureauSystemsList.add(bureauSystem1);
        
        insert bureauSystemsList;
        
        
        bureauProductList = new List<Bureau_Product__c>();
        Bureau_Product__c bProduct = new Bureau_Product__c();
        bProduct.Bureau_System__c = bureauSystemsList[0].id;
        bProduct.Category__c = 'Instrument';
        bProduct.Item__c = bItemMastersList[0].id;
        bProduct.Job__c = job.id;
        bProduct.Language__c = 'English';
        bureauProductList.add(bProduct);
        Bureau_Product__c bProduct1 = new Bureau_Product__c();
        bProduct1.Bureau_System__c = bureauSystemsList[0].id;
        bProduct1.Category__c = 'Instrument';
        bProduct1.Item__c = bItemMastersList[1].id;
        bProduct1.Job__c = job.id;
        bProduct1.Language__c = 'English';
        bureauProductList.add(bProduct1);
        
        insert bureauProductList;
        
        
        //Code to cover BureauProduct_BeforeDelete
        Bureau_Product__c bProduct11 = new Bureau_Product__c();
        bProduct11.Bureau_System__c = bureauSystemsList[0].id;
        bProduct11.Category__c = 'Instrument';
        bProduct11.Item__c = bItemMastersList[0].id;
        bProduct11.Job__c = job.id;
        bProduct11.Language__c = 'English';
        
        insert bProduct11;
        delete bProduct11;
        
        
        bureauCandidateList = new List<Bureau_Candidate__c>();
        Bureau_Candidate__c bureauCandidate = new Bureau_Candidate__c();
        bureauCandidate.Bureau_Job__c = job.id;
        bureauCandidate.Gender__c = 'Male';
        //bureauCandidate.Name = 'Ramesh Dhull';
        bureauCandidate.Country__c = 'India';
        bureauCandidate.First_Name__c = 'Ramesh';
        bureauCandidate.Last_Name__c = 'Dhull';
        bureauCandidate.Language__c = 'English';
        bureauCandidate.Email__c = 'ramesh.dhull@gmail.com';
        bureauCandidate.Reports_Status__c = 'Unsent';
        bureauCandidateList.add(bureauCandidate);
        
        Bureau_Candidate__c bureauCandidate1 = new Bureau_Candidate__c();
        bureauCandidate1.Bureau_Job__c = job.id;
        bureauCandidate1.Gender__c = 'Female';
        //bureauCandidate1.Name = 'Himani Sharma';
        bureauCandidate1.Country__c = 'India';
        bureauCandidate1.First_Name__c = 'Himani';
        bureauCandidate1.Last_Name__c = 'Sharma';
        bureauCandidate1.Language__c = 'English';
        bureauCandidate1.Email__c = 'ramesh.dhull1@gmail.com';
        bureauCandidate1.Reports_Status__c = 'Unsent';
        bureauCandidateList.add(bureauCandidate1);
        
        Bureau_Candidate__c bureauCandidate2 = new Bureau_Candidate__c();
        bureauCandidate2.Bureau_Job__c = job.id;
        bureauCandidate2.Gender__c = 'Femail';
        //bureauCandidate2.Name = 'Vikash Gandhi';
        bureauCandidate2.Country__c = 'India';
        bureauCandidate2.First_Name__c = 'Vikash';
        bureauCandidate2.Last_Name__c = 'Gandhi';
        bureauCandidate2.Language__c = 'English';
        bureauCandidate2.Email__c = 'ramesh.dhull11@gmail.com';
        bureauCandidate2.Reports_Status__c = 'Unsent';
        bureauCandidateList.add(bureauCandidate2);
        
        insert bureauCandidateList;
        
        
        bureauCandidateLoginList = new List<Bureau_Candidate_Login__c>();
        Bureau_Candidate_Login__c candidateLogin = new Bureau_Candidate_Login__c();
        candidateLogin.Bureau_Candidate__c = bureauCandidate.id;
        candidateLogin.Bureau_System__c = bureauSystem.id;
        candidateLogin.Username_Custom__c = 'dsfsddf';
        bureauCandidateLoginList.add(candidateLogin);
        Bureau_Candidate_Login__c candidateLogin1 = new Bureau_Candidate_Login__c();
        candidateLogin1.Bureau_Candidate__c = bureauCandidate1.id;
        candidateLogin1.Bureau_System__c = bureauSystem.id;
        candidateLogin1.Username_Custom__c = 'dsfsddf';
        bureauCandidateLoginList.add(candidateLogin1);
        
        Bureau_Candidate_Login__c candidateLogin2 = new Bureau_Candidate_Login__c();
        candidateLogin2.Bureau_Candidate__c = bureauCandidate.id;
        candidateLogin2.Bureau_System__c = bureauSystem1.id;
        candidateLogin2.Username_Custom__c = 'dsfsddfd';
        bureauCandidateLoginList.add(candidateLogin2);
        Bureau_Candidate_Login__c candidateLogin3 = new Bureau_Candidate_Login__c();
        candidateLogin3.Bureau_Candidate__c = bureauCandidate1.id;
        candidateLogin3.Bureau_System__c = bureauSystem1.id;
        candidateLogin3.Username_Custom__c = 'dsfsddfd';
        bureauCandidateLoginList.add(candidateLogin3);
        
        Bureau_Candidate_Login__c candidateLogin4 = new Bureau_Candidate_Login__c();
        candidateLogin4.Bureau_Candidate__c = bureauCandidate2.id;
        candidateLogin4.Bureau_System__c = bureauSystem1.id;
        candidateLogin4.Username_Custom__c = 'dsfsddfdd';
        bureauCandidateLoginList.add(candidateLogin4);
        Bureau_Candidate_Login__c candidateLogin5 = new Bureau_Candidate_Login__c();
        candidateLogin5.Bureau_Candidate__c = bureauCandidate2.id;
        candidateLogin5.Bureau_System__c = bureauSystem1.id;
        candidateLogin5.Username_Custom__c = 'dsfsddfdd';
        bureauCandidateLoginList.add(candidateLogin5);
        
        // insert bureauCandidateLoginList;
        
      /*  bCandidateScoresList = new List<Bureau_Candidate_Score__c>();
        Bureau_Candidate_Score__c bCandidateScore = new Bureau_Candidate_Score__c();
        bCandidateScore.Bureau_Candidate__c = bureauCandidateList[0].id;
        bCandidateScore.Instrument_Score__c = instrumentScoresList[0].id;
        bCandidateScore.Bureau_Product__c = bureauProductList[0].id;
        bCandidateScore.Value__c = 4.0;
        bCandidateScoresList.add(bCandidateScore);
        insert bCandidateScoresList; */
        ratingsList = new List<Bureau_Rating__c>();
        ratingsList1 = new List<Bureau_Rating__c>();
        Bureau_Rating__c rating = new Bureau_Rating__c();
        rating.Active__c = true;
        rating.Participant__c = bureauCandidateList[0].id;
        rating.Rater_Type__c = 'Self';
        rating.Reports_Status__c = 'Unsent';
        rating.Respondent__c = bureauCandidateList[0].id;
        //insert rating;
        ratingsList.add(rating);
        
        Bureau_Rating__c ratng1 = new Bureau_Rating__c();
        ratng1.Active__c = true;
        ratng1.Participant__c = bureauCandidateList[1].id;
        ratng1.Rater_Type__c = 'Self';
        ratng1.Reports_Status__c = 'Unsent';
        ratng1.Respondent__c = bureauCandidateList[1].id;
        //insert ratng1;
        ratingsList.add(ratng1);
        Bureau_Rating__c ratng2 = new Bureau_Rating__c();
        ratng2.Active__c = true;
        ratng2.Participant__c = bureauCandidateList[2].id;
        ratng2.Rater_Type__c = 'Self';
        ratng2.Reports_Status__c = 'Unsent';
        ratng2.Respondent__c = bureauCandidateList[2].id;
        ratingsList.add(ratng2);
        //insert ratng2;
        
        insert ratingsList;
        
        
        
        Bureau_Rating__c rating1 = new Bureau_Rating__c();
        rating1.Active__c = true;
        rating1.Participant__c = bureauCandidateList[1].id;
        rating1.Rater_Type__c = 'Manager';
        rating1.Reports_Status__c = 'Unsent';
        rating1.Respondent__c = bureauCandidateList[0].id;
        ratingsList1.add(rating1);
        Bureau_Rating__c rating2 = new Bureau_Rating__c();
        rating2.Active__c = true;
        rating2.Participant__c = bureauCandidateList[2].id;
        rating2.Rater_Type__c = 'Report';
        rating2.Reports_Status__c = 'Unsent';
        rating2.Respondent__c = bureauCandidateList[0].id;
        ratingsList1.add(rating2);
        
        insert ratingsList1;
        
        
        tasksList = new List<Task>();
        Task tsk1 = new Task(Task_Category__c='Pipeline',WhatId=job.Id,Subject = 'Pre Launch Action',ActivityDate=System.today(),OwnerId=job.Project_Lead__c, Status='Not Started');
        tasksList.add(tsk1);
        Task tsk2 = new Task(Task_Category__c='Pre Launch',WhatId=job.Id,Subject = 'Post Launch Action',ActivityDate=System.today().addDays(-2),OwnerId=job.Project_Lead__c, Status='Completed');
        tasksList.add(tsk2);
        Task tsk3 = new Task(Task_Category__c='Launch',WhatId=job.Id,Subject = 'Report Delivery Date',ActivityDate=System.today().addDays(1), OwnerId=job.Project_Lead__c, Status='Not Started');
        tasksList.add(tsk3);
        Task tsk4 = new Task(Task_Category__c='Launch',WhatId=job.Id,Subject = 'Participant Reminder',ActivityDate=System.today(), OwnerId=job.Project_Lead__c, Status='Send Progress Report');
        tasksList.add(tsk4);
        Task tsk5 = new Task(Description='Test Description',Task_Category__c='Post Launch',Task_Start_Time__c=DateTime.Now(),Task_End_Time__c=DateTime.Now(),WhatId=job.Id,Subject = 'Post Launch Action',ActivityDate=System.today().addDays(-2),OwnerId=job.Project_Lead__c, Status='Not Started');
        tasksList.add(tsk5);
        
        insert tasksList;
        
    }
    
        //create system test data
    public static void createSystemTestData()
    {
        System__c sys = new System__c(System_Name__c='System 1',System_URL__c='http://www.test.com',System_Type__c='MFS',Integrated__c='No',Status__c='In Development',System_Client_ID__c='DSCJNFHG',System_Client_Name__c='CMNFBVHJG');
        System__c sys1 = new System__c(System_Name__c='System 2',System_URL__c='http://www.test.com',System_Type__c='SODA',Integrated__c='No',Status__c='In Development',System_Client_ID__c='CMNFBVHJG',System_Client_Name__c='DSCJNFHG');
        systemsList = new List<System__c>();
        systemsList.add(sys);
        systemsList.add(sys1);
        
        insert systemsList;
    }

}
@isTest(seeAllData = true)
Private class MS_TriggerManagers_Tester {
    static testMethod void MSInvoiceTester(){
        Account ActId =[Select id from Account where Business_Relationship__c='New Logo (Never Traded)' limit 1];
        Contact contact = [SELECT Id,AccountId from Contact where AccountId=:ActId.Id LIMIT 1];  
        User GlobsUser=[select id from user where username like'%globus.development@shlgroup.com%' limit 1];
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.name = 'test Opp';
        opp.closedate = System.now().date();
        opp.Business_Type__c='NBB - New Logo';
        opp.Forecast_Category__c='Forecast';
        opp.Stagename='Qualifying';
        opp.accountID = contact.accountId;
        insert opp;
        
        Job__c job = new Job__c();
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.Project_Lead__c = UserInfo.getUserId();
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
        insert job;
        
        Bureau_Invoice__c bi = new Bureau_Invoice__c();
        bi.Job__c=job.id;
        bi.InvoiceType__c = 'Invoice';
        bi.SUNOrderNo__c='1234';
        insert bi;
        bi.InvoiceType__c='SOE Query';
        update bi;
        bi.InvoiceStatus__c='SOE Complete';
        update bi;
        ApexPages.StandardController sc = new ApexPages.standardController(bi);
      
    }
    static testMethod void MSProductTester(){
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Job__c job = new Job__c();
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.Project_Lead__c = UserInfo.getUserId();
        job.InternalContact__c = UserInfo.getUserId();
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
        insert job;
        
        Bureau_Item_Master__c bItemMaster = new Bureau_Item_Master__c();
        bItemMaster.Name = 'INM1';
        bItemMaster.BU__c = 'UK - UK1';
        bItemMaster.Category__c = 'Online Admin';
        bItemMaster.IM_Code__c = 'ITEMMASTERCODE';
        bItemMaster.Languages__c = 'English';
        bItemMaster.BU__c = job.Account_BU__c;
        bItemMaster.Type__c = 'Instrument';
        insert bItemMaster;
         
        
        Bureau_System__c bureauSystem1 = new Bureau_System__c();
        bureauSystem1.Bureau_Job__c =job.Id;
        insert bureauSystem1;
        
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
        insert bureauCandidate;
        
        System__c sys = new System__c(System_Name__c='System 1',System_URL__c='http://www.test.com',System_Type__c='MFS',Integrated__c='No',Status__c='In Development',System_Client_ID__c='DSCJNFHG',System_Client_Name__c='CMNFBVHJG');
        insert sys;
        
        System_Login__c systemLogin = new System_Login__c();
        systemLogin.System__c=sys.id;
        systemLogin.Username__c = 'Ramesh.Dhull';
        insert systemLogin;
        
        Bureau_System__c bureauSystem = new Bureau_System__c();
        bureauSystem.Bureau_Job__c =job.Id;
        bureauSystem.System__c=sys.id;
        bureauSystem.System_Login__c = systemLogin.id;
        bureauSystem.Report_Language__c ='English';
        insert bureauSystem;
        
        Bureau_Candidate_Login__c candidateLogin = new Bureau_Candidate_Login__c();
        candidateLogin.Bureau_Candidate__c = bureauCandidate.id;
        candidateLogin.Bureau_System__c = bureauSystem.id;
        candidateLogin.Username_Custom__c = 'dsfsddf';
        insert candidateLogin;
        
        Bureau_Rating__c rating = new Bureau_Rating__c();
        rating.Active__c = true;
        rating.Participant__c = bureauCandidate.id;
        rating.Rater_Type__c = 'Self';
        rating.Reports_Status__c = 'Unsent';
        rating.Respondent__c = bureauCandidate.id;
        insert rating;
        
        Bureau_Product__c bProduct = new Bureau_Product__c();
        bProduct.Category__c = 'Instrument';
        bProduct.Item__c = bItemMaster.id;
        bProduct.Job__c = job.id;
        bProduct.Language__c = 'English';
        insert bProduct;
        
        bProduct.Invoice_Only__c =true;
        update bProduct;
        //List<Bureau_Rating_Progress__c>BprLst=new List<Bureau_Rating_Progress__c>();
        Bureau_Rating_Progress__c ratingProgress = new Bureau_Rating_Progress__c();
        ratingProgress.Bureau_Product__c = bProduct.id;
        ratingProgress.Bureau_Rating__c = rating.id;
        ratingProgress.Status__c= 'In Progress';
        insert ratingProgress;
        
        
        try{
             delete bProduct;
        }
        Catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('This product cannot be deleted as there are related ratings which are either in progress or completed. Please change the status of these ratings to "Not Started" in order to delete this product.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }
    static testMethod void MSProductTester2(){
        
        Id RecordTypeIdJob1 = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Managed Service Commenced').getRecordTypeId();
        Job__c job = new Job__c();
        job.Job_Type__c = 'Project - 360';
        job.Start_Date__c = System.today();
        job.End_Date__c = System.today().addDays(30);
        job.Project_Lead__c = UserInfo.getUserId();
        job.InternalContact__c = UserInfo.getUserId();
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
        insert job;
        
        Bureau_Item_Master__c bItemMaster = new Bureau_Item_Master__c();
        bItemMaster.Name = 'INM1';
        bItemMaster.BU__c = 'UK - UK1';
        bItemMaster.Category__c = 'Online Admin';
        bItemMaster.IM_Code__c = 'ITEMMASTERCODE';
        bItemMaster.Languages__c = 'English';
        bItemMaster.BU__c = job.Account_BU__c;
        bItemMaster.Type__c = 'Instrument';
        insert bItemMaster;
        
        Bureau_Product__c bProduct2 = new Bureau_Product__c();
        bProduct2.Category__c = 'Instrument';
        bProduct2.Item__c = bItemMaster.id;
        bProduct2.Job__c = job.id;
        bProduct2.Language__c = 'English';
        insert bProduct2;
        
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
        insert bureauCandidate;
        
        Bureau_Rating__c rating2 = new Bureau_Rating__c();
        rating2.Active__c = true;
        rating2.Participant__c = bureauCandidate.id;
        rating2.Rater_Type__c = 'Self';
        rating2.Reports_Status__c = 'Unsent';
        rating2.Respondent__c = bureauCandidate.id;
        insert rating2;
        
        Bureau_Rating_Progress__c ratingProgress2 = new Bureau_Rating_Progress__c();
        ratingProgress2.Bureau_Product__c = bProduct2.id;
        ratingProgress2.Bureau_Rating__c = rating2.id;
        ratingProgress2.Status__c= 'Not Started';
       	insert ratingProgress2;
        Test.startTest();
        delete bProduct2;
        Test.StopTest();
        //Boolean productCanNotBeDeleted=false;
        
        
    }
    
}
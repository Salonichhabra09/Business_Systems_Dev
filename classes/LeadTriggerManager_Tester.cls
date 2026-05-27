@IsTest(seeAlldata=true)
public class LeadTriggerManager_Tester {
    
    
    static testMethod void leadConversionController_TestMethod_1(){
        User eloqUsr= [Select id from User where Username like '%eloqua_shl@cebglobal.com%' and IsActive =true ];
        System.runAs(eloqUsr) 
        {
        //Lead lead= createTestData.getLead();
        Lead lead = new Lead();
        lead.Lastname= 'testLead';
        lead.LeadSource = 'Partner';
        lead.company= 'test company';
        lead.Status = 'New';
        lead.Email = 'test99999@test.com';
        lead.Global_Lead_Country__c = 'INDIA';
        insert lead;
        }
        Account account=CreateTestData.getAccount();
        Contact contact=CreateTestData.getContact(account.id);
        Opportunity opportunity=createTestData.getOpportunity(account.id,contact.id);
        //User eloqUsr= [Select id from User where Username like '%eloqua_shl@cebglobal.com%' and IsActive =true ];
        System.runAs(eloqUsr) 
        {
            //boolean IsLeadOwnerQueue = False;//prabhat
           /* lead.Opportunity_Id__c=Opportunity.id;
            lead.Area_of_Interest__c='Pre-Hire Functional/Professional';
            lead.Account_Id__c=account.id;
            lead.Contact_Id__c=contact.id;
            lead.Same_as_contact_address__c=true;
            lead.Urgent_Follow_Up_Required__c=true;
            lead.Submitter_s_CEB_Division__c = 'BG';
            lead.Submitter_s_Email_Address__c = 'abc@test.com';
            
            update lead;*/
        }
    }
    
    static testMethod void leadConversionController_TestMethod_2(){
        User eloqUsr= [Select id from User where Username like '%eloqua_shl@cebglobal.com%' and IsActive =true ];
        //System.runAs(eloqUsr) 
        //{
            Lead tLead = new Lead();
            tLead.Lastname= 'testLead';
            tLead.LeadSource = 'Partner';
            tLead.company= 'test company';
            tLead.Status = 'New';
            tLead.Email = 'test1@test.com';
            tLead.Global_Lead_Country__c = 'INDIA';
            tLead.Submitter_s_CEB_Division__c = 'BG';
            tLead.Submitter_s_Email_Address__c = 'abc1@test.com';
            tLead.Urgent_Follow_Up_Required__c=true;
            //tLead.Same_as_contact_address__c = true;
            insert tLead;
            tLead.Area_of_Interest__c='Pre-Hire Functional/Professional';
            update tLead;
        	tLead.Area_of_Interest__c='High Potential Solution';
            update tLead;
        	tLead.Area_of_Interest__c='Enterprise Leadership Assessment';
            update tLead;
        	tLead.Area_of_Interest__c='Leader Edge';
            update tLead;
        	tLead.Area_of_Interest__c='PreciseFit';
            update tLead;
        	tLead.Area_of_Interest__c='Pre-Hire Entry-level';
            update tLead;
        	tLead.Area_of_Interest__c='Pre-Hire Graduates';
            update tLead;
        	
        //}
    }
    
    static testMethod void leadConversionController_TestMethod_3(){
        Test.starttest();
        User eloqUsr= [Select id from User where Username like '%eloqua_shl@cebglobal.com%' and IsActive =true ];
        //System.runAs(eloqUsr) 
        //{
            Lead tLead = new Lead();
            tLead.Lastname= 'testLead';
            tLead.LeadSource = 'Partner';
            tLead.company= 'test company';
            tLead.Status = 'New';
            tLead.Email = 'test1@test.com';
            tLead.Global_Lead_Country__c = 'INDIA';
            tLead.Submitter_s_CEB_Division__c = 'BG';
            tLead.Submitter_s_Email_Address__c = 'abc1@test.com';
            tLead.Urgent_Follow_Up_Required__c=true;
            //tLead.Same_as_contact_address__c = true;
            insert tLead;
        	tLead.Area_of_Interest__c='Pre-Hire Managers/Leaders';
            update tLead;
        	tLead.Area_of_Interest__c='Post-Hire Talent Audit/Assessment';
            update tLead;
        	tLead.Area_of_Interest__c='Develop Staff - General';
            update tLead;
        	tLead.Area_of_Interest__c='Develop Staff - High Potential';
            update tLead;
        	tLead.Area_of_Interest__c='Develop Staff - Managers/Leaders';
            update tLead;
        	tLead.Area_of_Interest__c='Succession Planning';
            update tLead;
        //}
        Test.stoptest();
    }
    
    
    static testMethod void QueueAssignment(){
        
        //Lead lead= createTestData.getLead();
        Lead lead = new Lead();
        lead.Lastname= 'testLead';
        lead.LeadSource = 'Partner';
        lead.company= 'test company';
        lead.Status = 'New';
        lead.Email = 'test5555@test.com';
        lead.Global_Lead_Country__c = 'INDIA';
        insert lead;
        
        lead.OwnerId= '005D0000001ls6l';
        update lead;
        
        Lead tLead = new Lead();
        tLead.Lastname= 'testLead';
        tLead.LeadSource = 'Partner';
        tLead.company= 'test company';
        tLead.Status = 'New';
        tLead.Email = 'test2@test.com';
        tLead.Global_Lead_Country__c = 'INDIA';
        tLead.Submitter_s_CEB_Division__c = 'BG';
        tLead.Submitter_s_Email_Address__c = 'abc2@test.com';
        
        insert tLead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(tLead.id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        
        //tLead.Status = 'Converted';
        //update tLead;
    }
    
    static testMethod void AssgnRuleCheckTest(){
        
        List<Group> LeadQueId= [Select id ,name from Group where Name ='Leads - Below Threshold' limit 1];
        //list<QueueSobject>LeadQueId= [select Id, QueueId from QueueSobject WHERE SobjectType = 'Lead' AND Queue.Name ='Leads - Below Threshold'];
        //list<QueueSobject>LeadQueId = [Select Queue.Id, Queue.Name, Queue.Type from QueueSObject WHERE Queue.Type ='Queue' AND Queue.Name = 'Leads - Below Threshold'];
        User eloqUsr= [Select id from User where Username like '%eloqua_shl@cebglobal.com%' and IsActive =true ];
        System.runAs(eloqUsr) 
            
        {
            LeadLastAssignedTo__c leadLast = new LeadLastAssignedTo__c();
            leadLast.Name = 'Last Assigned User1';
            leadLast.LeadLastAssignedTo__c = LeadQueId[0].Name;
            insert leadLast;    
            Lead tLead = new Lead();
            tLead.Lastname= 'testLead123';
            tLead.LeadSource = 'Advertisement';
            tLead.company= 'New company';
            tLead.Status = 'New';
            tLead.Email = 'test333@test.com';
            tLead.Global_Lead_Country__c = 'INDIA';
            tLead.Submitter_s_CEB_Division__c = 'BG';
            tLead.Submitter_s_Email_Address__c = 'abc333@test.com';
            tLead.Lead_Stage__c='Response';
            tLead.Urgent_Follow_Up_Required__c=true;
            //tLead.OwnerId='00GD0000001SJyb';
            tLead.OwnerId=String.valueOf(LeadQueId[0].Id).substring(0, 15);
            
            insert tLead;
        }
        
    }
    static testMethod void AssgnRuleCheckTest2(){
        List<Group> LeadQueId= [Select id from Group where Name ='Leads - Below Threshold' limit 1];
        User eloqUsr= [Select id from User where Username like '%eloqua_shl@cebglobal.com%' and IsActive =true ];
        System.runAs(eloqUsr) 
        {
            Lead tLead = new Lead();
            tLead.Lastname= 'testLead987';
            tLead.LeadSource = 'Advertisement';
            tLead.company= 'New SHL';
            tLead.Status = 'New';
            tLead.Email = 'teggst4@test.com';
            tLead.Global_Lead_Country__c = 'INDIA';
            tLead.Submitter_s_CEB_Division__c = 'BG';
            tLead.Submitter_s_Email_Address__c = 'abc4@test.com';
            tLead.Lead_Stage__c='AQL';
            tLead.Urgent_Follow_Up_Required__c=false;
            //tLead.OwnerId='00GD0000001SJyb';
            tLead.OwnerId=String.valueOf(LeadQueId[0].Id).substring(0, 15);
            
            insert tLead;
            tLead.Urgent_Follow_Up_Required__c=true;
            Update tLead;
            
        }      
        
    }
    
    static testMethod void AssgnRuleCheckTest3(){
        List<Group> LeadQueId= [Select id from Group where Name ='Leads - Below Threshold' limit 1];
        User eloqUsr= [Select id from User where Username like '%eloqua_shl@cebglobal.com%' and IsActive =true ];
        System.runAs(eloqUsr) 
        {
            Lead tLead = new Lead();
            tLead.Lastname= 'testLead987';
            tLead.LeadSource = 'Event';
            tLead.company= 'New SHL Log';
            tLead.Status = 'New';
            tLead.Email = 'teggst5@test.com';
            tLead.Global_Lead_Country__c = 'INDIA';
            tLead.Lead_Stage__c='Response';
            Insert tLead;
            tLead.OwnerId=String.valueOf(LeadQueId[0].Id).substring(0, 15);
            tLead.Urgent_Follow_Up_Required__c=true;
            Update tLead;
            
        }
    }
    
    static testMethod void AssgnRuleCheckTest4(){
        List<Group> LeadQueId= [Select id from Group where Name ='Leads - Below Threshold' limit 1];
        User eloqUsr= [Select id from User where Username like '%eloqua_shl@cebglobal.com%' and IsActive =true ];
        System.runAs(eloqUsr) 
        {
            Lead tLead = new Lead();
            tLead.Lastname= 'testLead1987';
            tLead.LeadSource = 'Event';
            tLead.company= 'New SHL Log';
            tLead.Status = 'New';
            tLead.Email = 'teggst6@test.com';
            tLead.Global_Lead_Country__c = 'INDIA';
            tLead.Lead_Stage__c='AQL';
            tLead.Urgent_Follow_Up_Required__c=false;
            Insert tLead;
            tLead.OwnerId=String.valueOf(LeadQueId[0].Id).substring(0, 15);
            tLead.Inactive_in_Eloqua__c = true;
            Update tLead;
            
        }
    }
    static testMethod void LeadConversionTest(){
        
        Id LeadQueId= [Select id from Group where Name ='ISAM Lead Queue' limit 1].id;
        String Name = [Select id , name from Group where Name ='ISAM Lead Queue' limit 1].name;
        Id leadProfile = [select id from Profile where name ='Commercial' limit 1].id;
        User UserId = [select id from User where profileId =:leadProfile and isActive = true limit 1 ];
        
        {
         LeadLastAssignedTo__c leadLast = new LeadLastAssignedTo__c();
            leadLast.Name = 'Last Assigned User1';
            leadLast.LeadLastAssignedTo__c = Name;
            insert leadLast;    
            Lead tLead = new Lead();
            tLead.Lastname= 'testLead_ChkQueueOrOwnerAssignmentTest';
            tLead.LeadSource = 'Advertisement';
            tLead.company= 'New company TEST';
            tLead.Status = 'New';
            tLead.Same_as_contact_address__c = true;
            tLead.Address_1__c = 'Test';
            tLead.City_Town__c = 'Test';
            tLead.State_County__c = 'Test';
            tLead.Zip_Postcode__c = '110034';
            tLead.title = 'New Test Data';
            tlead.Area_of_Interest__c = 'Training';
            tLead.Email = 'test09017@test.com.uat';
            tLead.Global_Lead_Country__c = 'INDIA';
            tLead.Submitter_s_CEB_Division__c = 'BG';
            tLead.Submitter_s_Email_Address__c = 'abc5@test.com';
            tLead.Lead_Stage__c='Response';
            tLead.Urgent_Follow_Up_Required__c=true;
            //tLead.OwnerId='00GD0000001SJyb';
            tLead.OwnerId=UserId.id;
            
            insert tLead;
   
       
        
        Database.LeadConvert lc = new database.LeadConvert();  
		lc.setLeadId(tLead.Id);  
		lc.setDoNotCreateOpportunity(true);  
		lc.setConvertedStatus( 'Converted' );  
		  
		Database.LeadConvertResult lcr = Database.convertLead(lc, false);  
        for(Database.Error s:lcr.getErrors()){
            system.debug('testing --> ' + s.getMessage());
            system.debug('testing --> ' + s.message);
            system.debug('testing --> ' + s.getFields());
        }
        system.debug( 'Errors are ' + lcr.getErrors());  
        system.debug('lcr.getErrors()' + lcr.isSuccess());
            system.assert( lcr.isSuccess() );  }
    }
    /*static testMethod void ChkQueueOrOwnerAssignmentTest(){
        Id LeadQueId= [Select id from Group where Name ='Leads - Below Threshold' limit 1].id;
        Id LeadQueId1= [Select id from Group where Name ='ISAM Lead Queue' limit 1].id;
        String Name = [Select id , name from Group where Name ='Leads - Below Threshold' limit 1].name;
        Id leadProfile = [select id from Profile where name ='Commercial' limit 1].id;
        User u = new user();
        u.LastName = 'Test Code';
        u.Email = 'test8@test.com';
        u.Alias = 'Tcode';
        u.Username = 'test1234444@test.com.gcsc';
        u.ProfileID = leadProfile;
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        
        GroupMember GM = new GroupMember();
        GM.GroupId = LeadQueId;
        GM.UserOrGroupId = u.Id;
        insert GM;
        Lead tLead = new Lead();
          system.runAs(u){
       
            LeadLastAssignedTo__c leadLast = new LeadLastAssignedTo__c();
            leadLast.Name = 'Last Assigned User1';
            leadLast.LeadLastAssignedTo__c = Name;
            insert leadLast;    
            tLead.Lastname= 'testLead_ChkQueueOrOwnerAssignmentTest';
            tLead.LeadSource = 'Advertisement';
            tLead.company= 'New company';
            tLead.Status = 'New';
            tLead.Email = 'test9@test.com';
            tLead.Lead_Country__c = 'India';
            tLead.Submitter_s_CEB_Division__c = 'BG';
            tLead.Submitter_s_Email_Address__c = 'abc6@test.com';
            tLead.Lead_Stage__c='Response';
            tLead.Urgent_Follow_Up_Required__c=true;
            //tLead.OwnerId='00GD0000001SJyb';
            tLead.OwnerId=String.valueOf(LeadQueId).substring(0, 15);
            
            insert tLead;
            tLead.OwnerId = LeadQueId1;
        	update tLead;
          }
        
        	
        
   
        
        
    }*/
}
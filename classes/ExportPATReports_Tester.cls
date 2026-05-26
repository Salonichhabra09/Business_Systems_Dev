@isTest(seeAllData = true)
public class ExportPATReports_Tester {

     static testMethod void testExportPATReports()
    {
        
        Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
          insert account;
      
          Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
          contact.Same_As_The_Account_Billing_Address__c=true;
          contact.Mailing_Address_Line_1__c ='test';
          contact.Mailing_City__c='test';
          contact.Mailing_ZIP_Postal_Code__c ='110094';
          contact.Mailing_Country__c='India';          
          insert contact;
        
        System__c sys = new System__c(System_Name__c='System 1',System_URL__c='http://www.test.com',System_Type__c='MFS',Integrated__c='No',Status__c='In Development',System_Client_ID__c='DSCJNFHG',System_Client_Name__c='CMNFBVHJG');
    	insert sys;
      
        
        /* BureauJob_Tester bJobTester = new BureauJob_Tester();
         BureauJob_Tester.createJobTestData();
        Apexpages.standardController sc = new Apexpages.standardController(BureauJob_Tester.job);
        PageReference pageRef = Page.BureauJob_CandidateManager;
        Test.setCurrentPage(pageRef);
        BureauJob_CandidateManager bJobCandidateManager = new BureauJob_CandidateManager(sc);
        bJobCandidateManager.exportCandidates();
        */
    }
      static testMethod void testExportPATProgressReports()
    {
                Account account=new Account(name='Test Account',Status__c='Approved',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
          insert account;
      
          Contact contact=new Contact(lastname='Test Contact', Accountid=account.id);
          contact.Same_As_The_Account_Billing_Address__c=true;
          contact.Mailing_Address_Line_1__c ='test';
          contact.Mailing_City__c='test';
          contact.Mailing_ZIP_Postal_Code__c ='110094';
          contact.Mailing_Country__c='India';          
          insert contact;
        
        System__c sys = new System__c(System_Name__c='System 1',System_URL__c='http://www.test.com',System_Type__c='MFS',Integrated__c='No',Status__c='In Development',System_Client_ID__c='DSCJNFHG',System_Client_Name__c='CMNFBVHJG');
    	insert sys;
       BureauJob_Tester bJobTester = new BureauJob_Tester();
        BureauJob_Tester.createJobTestData();
      Test.startTest();
        Job__c job = [select id,name,Account__r.Name from Job__c where Id=:BureauJob_Tester.job.Id];
        Set<Id> candidateIds = new Set<Id>();
        for(Bureau_Candidate__c candidate :BureauJob_Tester.bureauCandidateList){
          candidateIds.add(candidate.Id);
        }
        /*ExportPATProgressReport progressreport = new ExportPATProgressReport(job,candidateIds);
        ID batchprocessid = Database.executeBatch(progressreport,500);*/
      Test.stopTest();
        
    }
}
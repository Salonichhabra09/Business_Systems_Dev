@isTest(seeAllData=true) 
public class MilestoneNew_Tester{
    static testMethod void testMilestone(){
    
      User usr=[select Id,name,Company_BU__c from user where Name='Globus Development'];
      System.RunAs(usr){
        Milestone_Period__c mp = new Milestone_Period__c();
        mp.Signature_Date__c = Date.today();
        mp.Financial_Period_Date__c = date.today();
        mp.Financial_Period_Closed__c = false;
        mp.BU__c = 'US5';
        mp.name = 'abc';
        insert  mp;
        
        Milestone_Period__c mp2 = new Milestone_Period__c();
        mp2.Signature_Date__c = Date.today() - 1;
        mp2.Financial_Period_Date__c = date.today() - 1;
        mp2.Financial_Period_Closed__c = false;
        mp2.BU__c = 'US5';
        mp2.name = 'abcd';
        insert  mp2;
        
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
        opp.StageName='Prepare';
        opp.closeDate=System.today();
        //Order_number__c=contract.Id;
        opp.Business_Type__c='Renewal';
        opp.Forecast_Category__c='Commit';
        insert opp;
        
        ProjectObject__c probj = new ProjectObject__c();
        probj.Project_Manager__c = UserInfo.getuserId();
        probj.LBU__c = mp.BU__c;
        probj.Project_Status__c = 'In Progress';
        probj.Account__c = acc.id;
        probj.Contact__c = con.id;
        probj.Opportunity__c = opp.id;
        probj.Project_Name__c = acc.name;
        probj.Project_Type__c = 'Sales';
        probj.CurrencyIsoCode = 'GBP';
        probj.Functional_Area__c = 'Sales';
        insert probj;
        
        Milestone__c ml = new Milestone__c();   
        ml.Project__c = probj.Id;   // insert this first.
        ml.BU__c = mp.BU__c;
        ml.Milestone_Period__c = mp.id;
        ml.Amount__c = 123;
        ml.Service_Type2__c = '1:1 Assessment';
        ml.Milestone_Code2__c = 'Exercise Design';
        ml.CurrencyIsoCode = 'GBP';
        ml.Track_change__c = 'abcde';
        ml.Practice_Area__c = 'High Potential (HPS)';
        insert ml;
        ml.Milestone_Period__c  = mp2.id;       
        ml.Track_change__c = 'abc';        
        update ml;
        delete ml;
      }
  }
}
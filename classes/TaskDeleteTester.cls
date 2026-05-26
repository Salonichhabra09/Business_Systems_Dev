@isTest(SeeAllData=true)
public class TaskDeleteTester {
    
    static testMethod void TestValidateTaskDeletion(){
        
        Job__c Job = [Select id from Job__c where recordtypeid='012D0000000VAaZIAW' limit 1];
        Task tsk=[Select id from Task limit 1];
        tsk.WhatId=job.id;
        update tsk;
        delete tsk;
        Task t = new Task(Subject='Abc',Status='Not Started',Priority='Normal',WhatId = job.id);
        insert t;
        t.OwnerId='00520000000hIsYAAU';
        t.Actual_Time_Taken__c=20;
        update t;
        //delete t;
        
    }
    //Last Modified by Prabhat Arora on 2/09/2021: For Bulls Eye Project
    static testMethod void NVM_Task_Create_Test(){
        Account acc=new Account(name='ADP',Status__c='Live',Billing_Address_Line_1__c='test',Billing_City__c='Test City',Billing_Country__c='Test Country',Billing_State__c='Test',Billing_ZIP_Postal_Code__c='1100110',BU__c='Australia - AU1');
        insert acc;
        Contact con=new Contact(lastname='Test Contact',AccountId=acc.id,Same_As_The_Account_Billing_Address__c=true);//contact.Same_As_The_Account_Billing_Address__c=true;
        insert con;
        Opportunity opp= new Opportunity(OwnerId=UserInfo.getUserId(),AccountId=acc.id,Billing_Contact__c=con.id,Primary_Contact__c=con.id,name='Test Opportunity',NVM_Credit_Card_ID__c='',Unconfirmed_Sun_Order_Number__c='',CurrencyISOCode='GBP',StageName='New',closeDate=System.today(),Order_number__c=NULL,Forecast_Category__c='Forecast',Business_Type__c='New customer: subscription');
        insert opp;
        Task t2 = new Task(Subject='Outbound call',Status='Not Started',Priority='Normal',WhatId = opp.id);
        insert t2;
    }
}
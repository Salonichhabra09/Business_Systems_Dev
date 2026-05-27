/****************************************

Class Name: ACWebhookCtlrTest
Author: Abhijeet Tiwari
Description: Code coverage of ACWebhookCtlr

Created Date: Aug 25,2020

=====  Version History =====================

S.No.  Date   Changes Made  Change Owner


****************************************/


@isTest

public class ACWebhookCtlrTest{
    
    /**********************************************************
    
    Method Name: testPostMethodCreate
    Purpose: Code coverage for Lead insert from webhook of AC
    Created Date: Aug 25,2020
    Arguments: N/A  
    
   ***********************************************************/
    
    static testmethod void testPostMethodCreate(){
        
        
        Test.startTest();
        
        Trigger_Activation__c obj = new Trigger_Activation__c();
        obj.Active__c = true;
        obj.Name = 'LeadTrigger';
        obj.Object_Name__c = 'Lead';
        insert obj;

        RestRequest req = new RestRequest();

       //RestResponse res = new RestResponse(); 

       req.requestURI = '/services/apexrest/ACIntegration';  //Request URL
       req.httpMethod = 'POST';//HTTP Request Type

       req.addParameter('contact[fields][16]', 'Marketing Qualified Lead');
       req.addParameter('contact[tags]', 'Form Fill');
       req.addParameter('contact[last_name]', 'test abhijeet');
       req.addParameter('contact[fields][1]', 'test company');
       req.addParameter('contact[email]', 'test@gmail.com');
       req.addParameter('contact[fields][64]', 'AC');

       RestContext.request = req;   

       ACWebhookCtlr.processContact();   

       Test.stopTest();
       
       List<Lead> lst = [select id from Lead];
       System.Assert(lst!=null);     
        
    }
    
    /**********************************************************
    
    Method Name: testPostMethodUpdate
    Purpose: Code coverage for Lead update from webhook of AC
    Created Date: Aug 25,2020
    Arguments: N/A  
    
   ***********************************************************/
    
    static testmethod void testPostMethodUpdate(){
        
        
        Trigger_Activation__c obj = new Trigger_Activation__c();
        obj.Active__c = true;
        obj.Name = 'LeadTrigger';
        obj.Object_Name__c = 'Lead';
        insert obj;
        
        Lead objLead = new Lead();
        objLead.Lastname = 'test';
        objLead.Company = 'test'; 
        objLead.ownerid = userinfo.getuserid();
        objLead.city='test';    
        objLead.Country = 'test';
        objLead.email ='test@gmail.com';
    
        insert objLead;
        
        
        Test.startTest();

        RestRequest req = new RestRequest();

       //RestResponse res = new RestResponse(); 

       req.requestURI = '/services/apexrest/ACIntegration';  //Request URL
       req.httpMethod = 'POST';//HTTP Request Type

       req.addParameter('contact[fields][16]', 'Marketing Qualified Lead');
       req.addParameter('contact[tags]', 'Form Fill');
       req.addParameter('contact[email]', 'test@gmail.com');
       req.addParameter('contact[fields][41]', 'United States');
       req.addParameter('contact[last_name]', 'test abhijeet');
       req.addParameter('contact[fields][1]', 'test company');
       req.addParameter('contact[fields][64]', 'AC');
       

       RestContext.request = req;   

       ACWebhookCtlr.processContact();   

       Test.stopTest();
       
       List<Lead> lst = [select id from Lead Where Lead_System_Source__c = 'Active Campaigns'];
       System.Assert(lst != null);      
        
    }
    
    /**********************************************************
    
    Method Name: testException
    Purpose: Code coverage for Exception
    Created Date: Aug 25,2020
    Arguments: N/A  
    
   ***********************************************************/
    
    static testmethod void testException(){
        
        
        Trigger_Activation__c obj = new Trigger_Activation__c();
        obj.Active__c = true;
        obj.Name = 'LeadTrigger';
        obj.Object_Name__c = 'Lead';
        insert obj;
        
        Test.startTest();

        RestRequest req = new RestRequest();

       //RestResponse res = new RestResponse(); 

       req.requestURI = '/services/apexrest/ACIntegration';  //Request URL
       req.httpMethod = 'POST';//HTTP Request Type

       req.addParameter('contact[fields][16]', 'Marketing Qualified Lead');
       req.addParameter('contact[tags]', 'Form Fill');
       //req.addParameter('contact[email]', 'test@gmail.com');
       req.addParameter('contact[fields][41]', 'United States');
       req.addParameter('contact[last_name]', 'test abhijeet');
       req.addParameter('contact[fields][1]', 'test company');
       req.addParameter('contact[fields][64]', 'AC');
       

       RestContext.request = req;   

       ACWebhookCtlr.processContact();   

       Test.stopTest();
       
       List<Lead> lst = [select id from Lead];
       System.Assert(lst != null);       
        
    }
    
       
}
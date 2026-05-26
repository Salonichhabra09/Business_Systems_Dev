@isTest
public class LeadCreationControllerTest {
    
    static testMethod void leadConversionController_TestMethod_1(){
        
        Trigger_Activation__c obj = new Trigger_Activation__c();
        obj.Active__c = true;
        obj.Name = 'Campaign_Trigger';
        obj.Object_Name__c = 'Campaign';
        insert obj;
        
        Trigger_Activation__c obj2 = new Trigger_Activation__c();
        obj2.Active__c = true;
        obj2.Name = 'LeadTrigger';
        obj2.Object_Name__c = 'Lead';
        insert obj2;
        
        List<Lead> leadList=new List<Lead>();
        Lead lead = new Lead();
        lead.Lastname= 'testLead';
        lead.LeadSource = 'Partner';
        lead.company= 'test company';
        lead.Status = 'New';
        lead.Email = 'test99999@test.com';
        lead.Lead_Country__c = 'India';
        leadList.add(lead);
        
        Campaign campaignRec = new Campaign(Name='GCSC-SYS-New Lead Form Addition');
        insert campaignRec;
        LeadCreationController.createLeadRecords(leadList,'GCSC General');
   }
    
    static testMethod void getAppDefination_Negative(){
        try{
           LeadCreationController.getAppDefination();
        }catch(Exception ex){
            
        }
   }
    
    @istest(seealldata=true)
    public static void leadConversionController_TestMethod_Negative(){
        List<Lead> leadList=new List<Lead>();
        Lead lead = new Lead();
        lead.Lastname= 'testLead';
        lead.LeadSource = 'Partner';
        lead.company= 'test company';
        lead.Status = 'New';
        lead.Email = 'test99999@test.com';
        lead.Lead_Country__c = 'India';
        leadList.add(lead);
        Account account =createtestdata.GetAccount();
        Contact contact =createtestdata.getContact(account.Id);
        LeadCreationController.updateContactRecord(contact);
        contact.LID__LinkedIn_Company_Id__c='Test';
        
        try{
        LeadCreationController.createLeadRecords(leadList,'GCSC General');
        LeadCreationController.updateContactRecord(contact);    
        }catch(Exception ex){
            
        }
   }

}
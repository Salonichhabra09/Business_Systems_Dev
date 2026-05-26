@isTest 
      public class TestAssignLeadsUsingAssignmentRules{
      static testMethod void createnewlead() {
      User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
      Trigger_Activation__c setting = new Trigger_Activation__c();
        setting.Name = 'LeadTrigger';
        setting.Active__c = true;
        setting.Object_Name__c = 'Lead';
        insert setting;
      Test.startTest();    
      Lead leadToCreate =new Lead();
      List<id> Ids= New List<Id>();
      leadToCreate.ownerid= userToCreate.id;
      leadToCreate.LastName ='Gupta';
      leadToCreate.Company='Salesforce';
      leadToCreate.LeadSource='Partner Referral';
      leadToCreate.Rating='';
      leadToCreate.Status='';
      leadToCreate.email = 'test@gmail.com';
      insert leadToCreate; 
      
      Ids.add(leadToCreate.id);
      AssignLeadsUsingAssignmentRules.leadAssign(Ids);
      
      Test.stopTest();
   }
}
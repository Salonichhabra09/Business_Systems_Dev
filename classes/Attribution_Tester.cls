@isTest(seeAllData=True)
private class Attribution_Tester {

  static testmethod void testTriggers()
  {
    List<RevenueAttribution__c> attributions;
    
    attributions = insertAttributions(null);
            
    updateAttributions(attributions);
        
    //deleteAttributions(attributions);
    
    //testAttributionListViewController();
  }
  static testmethod void testTriggers1()
  {
    List<RevenueAttribution__c> attributions;
    
    attributions = insertAttributions(null);
    updateAttributions(attributions);
     Test.startTest();   
    deleteAttributions(attributions);
    testAttributionListViewController();
      RevenueAttribution__c rec = [SELECT Id ,Name,Attribution_Month_Number__c,Project__c, Consultant__c,  Project__r.Name,Project__r.Project_Name__c,Attribution_Month2__c,CurrencyIsoCode,Attribution_Year2__c,Attribution_Days__c,Attribution_Rate__c,Attribution_Value__c,Timesheet_Hours__c FROM RevenueAttribution__c WHERE Consultant__c ='005D0000008jUdpIAE' AND Attribution_Year2__c='2024' AND Attribution_Month2__c='Sep' ORDER BY Attribution_Year2__c DESC, Attribution_Month_Number__c DESC, Project__r.Name DESC limit 1];
     Attribution_ListView_Controller cls = new Attribution_ListView_Controller();
      cls.TotalAttributionValue = 0;
      cls.TotalAttributionDays = 0;
      system.debug('Priyank'+rec.Attribution_Value__c);
       cls.UpdateTotals(rec);
    Test.stopTest();
  }
  
  static void testAttributionListViewController()
  {
    Attribution_ListView_Controller controller = new Attribution_ListView_Controller();
    controller.selectMonth = 9;
    controller.selectYear = 2024;
    controller.getAttributions();
    controller.selectMonth = 0;
    controller.Go();
    controller.getAttributions();
    controller.selectYear = 0;
    controller.Go();
    controller.getAttributions();
  }
      
  static List<RevenueAttribution__c> insertAttributions(String projectId)
   {
     system.debug('Attribution: Insert Started');
     Id userId = userinfo.getUserId(); 
     if(projectId==null)
     {
        //ProjectObject__c project = [SELECT Id,Contact__r.AccountId,Contact__r.ID from ProjectObject__c WHERE Project_Manager__c=:userId LIMIT 1 ];
        //edited by saloni chhabra on 4/9/2015
       ProjectObject__c project = [SELECT Id,Contact__r.AccountId,Contact__r.ID from ProjectObject__c WHERE Project_Status__c =: 'In Progress' LIMIT 1 ];
       Project_Deliverables__c objPD = new Project_Deliverables__c();
        objPD.PS_Offering__c = 'Outsourced Assessment';
        objPD.Project__c=project.id;
        objPD.Number__c=10;
        objPD.Deal_Type__c='Assessment for Selection';
        objPD.Complexity__c= 'Tailored';
        objPD.Additional_Comments__c= 'Test Comments';
        insert objPD;
       project.Account__c = project.Contact__r.AccountId;
       project.Contact__c = project.Contact__r.ID;
       project.Billing_Contact__c = project.Contact__r.ID;
       update project;
       projectId = project.Id; 
     }
     Id consultantId = [SELECT Id FROM User WHERE PSA_Role__c='PSA Lead' and Name='Tracy Shen' LIMIT 1].Id;
     
     List<RevenueAttribution__c> attributions = new List<RevenueAttribution__c>();
     List<Milestone_Period__c> MPlist = [Select id,name from Milestone_Period__c where Financial_Period_Closed__c=false limit 1]; //edited by saloni chhabra on 4/9/2015
      for(Integer i=0;i<20;i++)
      {
        RevenueAttribution__c attribution = new RevenueAttribution__c();
        attribution.Project__c = projectId;
       // attribution.Attribution_Month2__c = 'Jan';
       // attribution.Attribution_Year2__c = '2009';
        attribution.Attribution_Days__c = 12;
        attribution.Attribution_Rate__c = 50;
        attribution.Consultant__c = '005D0000008jUdpIAE';
        attribution.CurrencyIsoCode = 'INR';
        //edited by saloni chhabra on 4/9/2015 starts here
        if(MPlist.size()>0)    
        attribution.Attribution_Period__c = MPlist[0].id;
        //edited by saloni chhabra on 4/9/2015 ends here
        attributions.add(attribution);
      }
      
      insert attributions;
      return attributions;
   }
   
   static void updateAttributions(List<RevenueAttribution__c> attributions)
   {
     
     for(RevenueAttribution__c attribution: attributions)
     attribution.Attribution_Rate__c = 60;
     update attributions;
       
   }
   
   static void deleteAttributions(List<RevenueAttribution__c> attributions)
   {
       delete attributions;
   }
   
    static testmethod void ContractAccountHelpertester(){
        List<Id> ids = new List<Id>();
        for (Contract c : [SELECT Id FROM Contract LIMIT 10]) ids.add(c.Id);
        ContractAccountHelper.getAccountNames(ids);
    }
}
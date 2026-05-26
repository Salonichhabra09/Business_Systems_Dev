@isTest(seeAllData=true)
public class Associate_TriggerTester 
{
    @isTest
    static void testAssociateTriggers()
    {
        testBasicMethods(null);
        //testSpecialMethods(null);
    }
    
    
    public static  void testBasicMethods(String projectId)
    {
        List<Associate__c> associates;
        
        associates = insertAssociates(projectId);
                        
        updateAssociates(associates);
        
        deleteAssociates(associates);
    }
    
   
    public static List<Associate__c> insertAssociates(String projectId)
     {
        system.debug('Associate: Insert Started');
        if(projectId==null)
            projectId = [SELECT Id from ProjectObject__c LIMIT 1].Id; 
        
        String userId = [SELECT Id from User LIMIT 1].Id; 
        
        List<Associate__c> associates = new List<Associate__c>();
        
        for(Integer i=0;i<3;i++)
        {
            Associate__c associate = new Associate__c();
            associate.Project__c = projectId;
            associate.Rechargeable__c = true;
            associate.Date_Invoiced_Received__c = Date.newInstance(2008,4+i,21);
          
            associate.Associate_Type__c = 'Actor';
            associates.add(associate);
        }
        
        insert associates;
        system.debug('Associate: Insert Completed');
        
        return associates;
     }
     
    
     public static void updateAssociates(List<Associate__c> insertedAssociates)
     {
        system.debug('Associate: Update Started');
        List<Associate__c> associates = new List<Associate__c>();
        
        for(Associate__c insertedAssociate: insertedAssociates)
        {
            Associate__c associate = new Associate__c(id=insertedAssociate.id);
            associate.Date_Invoiced_Received__c = Date.Today();
            associates.add(associate);
        }
    
        update associates;
        Associate_Manager.Associate_AfterUpdateChecks(associates,associates);
        system.debug('Associate: Update Completed');
     }
     
    
     public static void deleteAssociates(List<Associate__c> insertedAssociates)
     {
        system.debug('Associate: Delete Started');
        delete insertedAssociates;
        system.debug('Associate: Delete Completed');
     }
     
}
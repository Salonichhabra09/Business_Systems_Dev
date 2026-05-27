public class WorkpacketBulkController {

    @AuraEnabled
    public static String saveWorkpackets(List<Workpacket__c> WorkpacketList){
        try{
        Upsert WorkpacketList; 
        return 'Workpacket records saved successfully';
        }
        catch(Exception e)
        {
            return e.getMessage();
        }
    }
      @AuraEnabled
    public static ProjectObject__c getProjectData(Id ProjectId){
        system.debug('Project Id '+ProjectId);
     return [select Id,Project_Name__c,LBU__c,CurrencyIsoCode,Project_Health_Detail__c,Milestone_Status__c,Milestones_Value__c,Total_Orderline_Value_RollUp__c from ProjectObject__c where Id=:ProjectId];
    }
     @AuraEnabled
    public static List<Workpacket__c> getData(String SelectedIds){
        
        system.debug('Selected Ids '+SelectedIds);
        List<String> result = SelectedIds.split(',');
        List<Workpacket__c> Workpackets = [Select CPS_Project_Number__c,Product_PS__c,Solution_Type__c,Status__c,Agreed_Delivery__c,Description__c,CPS_Project_Manager__c,Name,Actual_Delivery__c,Delivery_Variance_Comment__c,Reasons_For_Changed_Delivery_Date__c from Workpacket__c where Id IN:result];
        return Workpackets;
    }
    
}
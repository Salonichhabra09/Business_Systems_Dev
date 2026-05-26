public class MilestoneBulkController {
    
    @AuraEnabled
    public static String saveMilestones(List<Milestone__c> MilestoneList){
        try{ 
            Upsert MilestoneList; 
            return 'Milestone records saved successfully';
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
    public static List<Milestone__c> getMilestonesData(Id ProjectId){
        system.debug('Project Id '+ProjectId);
        List<Milestone__c> Milestones = [Select Project__c,BU__c,Service_Type2__c,Milestone_Period__c,
                                         Amount__c,Milestone_Description__c,CurrencyIsoCode,
                                         Practice_Area__c,Is_Signed__c ,
                                         Milestone_Risk__c,Track_change__c//Added as part of SSE-22281
                                         from Milestone__c where Project__c=:ProjectId and Is_Signed__c=False];
        return Milestones;
    }
    
    @AuraEnabled
    public static Boolean checkAccess(){
        
       Boolean access =  schema.sObjectType.Milestone__c.isUpdateable();
       return access;
    }
    
}
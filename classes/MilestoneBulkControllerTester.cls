@isTest(seeAllData = true)
public class MilestoneBulkControllerTester {
    static testMethod void CoverMethods(){
        ProjectObject__c project = [select id from ProjectObject__c where Project_Status__c='In Progress' and Total_Orderline_Value_RollUp__c!=null limit 1];
        MilestoneBulkController.getProjectData(project.Id);
        MilestoneBulkController.getMilestonesData(project.Id);
        MilestoneBulkController.saveMilestones(CreateMilestoneTestRecords());
        MilestoneBulkController.checkAccess();
    }
    static testMethod List<Milestone__c> CreateMilestoneTestRecords(){
        List<Milestone__c> TempMilestone = new List<Milestone__c>();
        ProjectObject__c project = [select id from ProjectObject__c where Project_Status__c='In Progress' and Total_Orderline_Value_RollUp__c!=null limit 1];
        for(integer i=0;i<5;i++){
            Milestone__c milestone = new Milestone__c();
            TempMilestone.add(milestone);
        }
        return TempMilestone;
    }

}
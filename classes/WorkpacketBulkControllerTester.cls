@isTest(seeAllData = true)
public class WorkpacketBulkControllerTester {

static testMethod void CoverMethods(){
        ProjectObject__c project = [select id from ProjectObject__c where Project_Status__c='In Progress' and Total_Orderline_Value_RollUp__c!=null limit 1];
        WorkpacketBulkController.getProjectData(project.Id);
        WorkpacketBulkController.getData('TestID');
        WorkpacketBulkController.saveWorkpackets(CreateWorkpacketTestRecords());
    }
    static testMethod List<Workpacket__c> CreateWorkpacketTestRecords(){
        List<Workpacket__c> TempWorkpacket = new List<Workpacket__c>();
        ProjectObject__c project = [select id from ProjectObject__c where Project_Status__c='In Progress' and Total_Orderline_Value_RollUp__c!=null limit 1];
        for(integer i=0;i<5;i++){
            Workpacket__c workpacket = new Workpacket__c();
            TempWorkpacket.add(workpacket);
        }
        return TempWorkpacket;
    }

}
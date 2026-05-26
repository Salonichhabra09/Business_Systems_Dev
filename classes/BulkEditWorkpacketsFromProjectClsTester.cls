@isTest(seeAllData = true)
public class BulkEditWorkpacketsFromProjectClsTester {
    static testMethod void CoverMethods(){
        List<Workpacket__c> TempWorkpacket = [select id from Workpacket__c limit 5];
        List<Id> TempIds = new List<Id>();
        for(Workpacket__c workpacket:TempWorkpacket){
            TempIds.add(workpacket.Id);
        }
       Test.startTest();
  Test.setCurrentPage(Page.BulkEditWorkpacketProjectVF);
  ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(TempWorkpacket);
  stdSetController.setSelected(TempWorkpacket);
  BulkEditWorkpacketsFromProjectCls ext = new BulkEditWorkpacketsFromProjectCls(stdSetController);
        ext.redirectToLC();
 Test.stopTest();
    }
}
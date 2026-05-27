public class BulkEditWorkpacketsFromProjectCls {
public List<Workpacket__c> selWorkpacketsLst;
      public String WorkpacketIds;
      public Id ProjectId;

      // Constructor
      public BulkEditWorkpacketsFromProjectCls(ApexPages.StandardSetController cntlr){
           selWorkpacketsLst = cntlr.getSelected(); //get selected records from workpacket realated list view
           WorkpacketIds = '';  
           for(Workpacket__c workpacket : selWorkpacketsLst){
               WorkpacketIds += workpacket.Id + ','; //build list of ids string concatenated with comma  
            }
          
           WorkpacketIds = WorkpacketIds.removeEnd(','); 
      } 

      public PageReference redirectToLC(){
            String returnUrl = '/lightning/cmp/c__BulkEditWorkpacketsFromProject?c__recordId='+ApexPages.currentPage().getParameters().get('id')+'&c__listofWorkpackets='+WorkpacketIds;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
      }
}
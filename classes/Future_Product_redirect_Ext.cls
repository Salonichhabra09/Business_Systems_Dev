/*Created By: Pankhuri Jain, for SSE-10854, 
Purpose: Overiding Functionality of Future Product standard "EDIT & DELETE" actions 
*/
public class Future_Product_redirect_Ext {
    Public Future_Product__c fut;
    Public String OpptyId{get;set;}
  
    public Future_Product_redirect_Ext (ApexPages.StandardController controller) {
        if (!Test.isRunningTest()){ // Added by pankhuri for test class
         controller.addFields(new List<String>{'Opportunity__c'});//Added by Padam
        }
        fut = (Future_Product__c)controller.getRecord();//[Select id,Opportunity__c from Future_Product__c where id =: System.currentPageReference().getParameters().get('id')];  Changed by Padam 
        OpptyId = fut.Opportunity__c ;
    }
    public PageReference saveAndRedirect() {
      if(OpptyId != null) {
        PageReference redirectPage = Page.Clone_Custom_Add_Products_Page;
        redirectPage.setRedirect(true);
        redirectPage.getParameters().put('id',OpptyId);
        return redirectPage;
      } 
      return null;
    }
    
}
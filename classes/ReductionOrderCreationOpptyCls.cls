public class ReductionOrderCreationOpptyCls {
    public String currentRecordId {get;set;}
    public Order ord{get;set;}
    public ApexPages.StandardController controller {get; set;}
    public ReductionOrderCreationOpptyCls(ApexPages.StandardController controller){
        ord = new Order();
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        try{
       	 ord = [Select id,name,status,Reduction_Order__c,Variation_Opportunity__c,OpportunityId from Order where OpportunityId=:currentRecordId AND Order_Year__c!= 0 AND Reduction_Order__c=:false AND Variation_Opportunity__c=:'No' limit 1];
        }
        catch(exception e){
            
        }
    }
    public PageReference getCloseWindow(){
        return new PageReference('/apex/closeFlow');
    }
}
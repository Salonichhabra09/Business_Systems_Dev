public with sharing  class ReductionOrderLEXClass {
    @AuraEnabled 
	public static string relatedOrderRecord(String OrderId){
        List<Order> ord = [Select id,name,status,Reduction_Order__c,Variation_Opportunity__c,OpportunityId from Order where OpportunityId=:OrderId AND Order_Year__c!= 0 AND Reduction_Order__c=:false AND Variation_Opportunity__c=:'No'];
        String ordId = ord[0].id;
        return ordId;
	}
}
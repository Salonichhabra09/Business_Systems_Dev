public class DiscountSummaryCreation {
    
    @InvocableMethod
    public static void discountSummaryLogic(List<InputValues> inputValuesList){
        Id opportunityId = inputValuesList.get(0).opportunityId;
        createDiscountSummary(false, opportunityId, null);
    }
    
    public static void createDiscountSummary(Boolean isTrigger, Id opportunityId, Map<Id, OpportunityLineItem> oldLineItemMap){
        Decimal totalServiceListPrice = 0;
        Decimal totalServiceSalesPrice = 0;
        Decimal totalProductListPrice = 0;
        Decimal totalProductSalesPrice = 0;
        Decimal productDiscountPercentage = 0;
        Decimal servicesDiscountPercentage = 0;
        List<OpportunityLineItem> oppLineItemList = [SELECT Id, Product2.Family, Total_List_Price__c, TotalPrice, OpportunityId
                                                     FROM OpportunityLineItem 
                                                     WHERE OpportunityId = :opportunityId];
        
        if(!oppLineItemList.isEmpty()){
            for(OpportunityLineItem oli : oppLineItemList){
                if(oli.Product2.Family == 'Product' || oli.Product2.Family == 'Experiences' || oli.Product2.Family == 'Insights'){
                    totalProductListPrice = totalProductListPrice + oli.Total_List_Price__c;
                    totalProductSalesPrice = totalProductSalesPrice + oli.TotalPrice; 
                }
                if(oli.Product2.Family == 'Services' || oli.Product2.Family == 'Ancilliary' || oli.Product2.Family == 'Assessment'){
                    totalServiceListPrice = totalServiceListPrice + oli.Total_List_Price__c;
                    totalServiceSalesPrice = totalServiceSalesPrice + oli.TotalPrice;
                }   
            }
            if(totalProductListPrice > 0 && totalProductSalesPrice > 0){
                productDiscountPercentage = (totalProductListPrice - totalProductSalesPrice)*100/totalProductListPrice;
            }
            if(totalServiceListPrice > 0 && totalServiceSalesPrice > 0){
                servicesDiscountPercentage = (totalServiceListPrice - totalServiceSalesPrice)*100/totalServiceListPrice;
            }
            
            if(!isTrigger || (oppLineItemList.size() == 1 && oldLineItemMap == null)){
                insertDiscountSummary(Math.round(productDiscountPercentage), Math.round(servicesDiscountPercentage), opportunityId);   
            }else if(isTrigger && (oppLineItemList.size() == 1 && oldLineItemMap != null) || (oppLineItemList.size() > 1)){
                updateDiscountSummary(Math.round(productDiscountPercentage), Math.round(servicesDiscountPercentage), null);   
            }
        }
    }
    
    public static void insertDiscountSummary(Decimal productDiscountPercentage, Decimal servicesDiscountPercentage, Id opportunityId){
        Discount_Summary__c ds = new Discount_Summary__c();
        ds.Product_Discount__c = productDiscountPercentage;
        ds.Service_Discount__c = servicesDiscountPercentage;
        ds.Opportunity__c = opportunityId;
        INSERT ds;
    }
    
    public static void updateDiscountSummary(Decimal productDiscountPercentage, Decimal servicesDiscountPercentage, Id discountSummaryId){
        Discount_Summary__c ds = new Discount_Summary__c();
        ds.Product_Discount__c = productDiscountPercentage;
        ds.Service_Discount__c = servicesDiscountPercentage;
        ds.Id = discountSummaryId;
        UPDATE ds;
    }
    
    public class InputValues{
        @invocableVariable
        public Id opportunityId;
    }
}
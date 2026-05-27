public class GenericClassToGetData {
    
    @AuraEnabled
    public static list<Order> getOrderData(String jobId){
        list<Order> orderData = new list<Order>();

        try{
            Id oppId = [SELECT Id, Opportunity__c FROM Job__c WHERE Id =: jobId].Opportunity__c;
            if(oppId != null){
                orderData = [SELECT 
                            Id, Name, OrderNumber, Status, Oats_Status__c, 
                            EffectiveDate, Booking_Date__c, TotalAmount, CurrencyISOCode
                            FROM Order 
                            WHERE OpportunityId =: oppId];
            }
            if(orderData.size() > 0){
                return orderData;
            }
            return new list<Order>();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
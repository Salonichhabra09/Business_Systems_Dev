public with sharing class OrderProductsInformation {
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> GetOrderProducts(String OrderId){
        return [select id,Product2.Name,Legacy_Start_Date__c,Legacy_End_Date__c from orderitem where orderId=:OrderId];
    }
}
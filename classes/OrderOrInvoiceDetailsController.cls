public class OrderOrInvoiceDetailsController {  
    
    @AuraEnabled
   public static Order fetchOrderAndInvoice(Id CourseBookingId) {
        Id OppId;
        Course_Booking__c cBooking = [SELECT Id, Opportunity__c  FROM Course_Booking__c WHERE Id =:CourseBookingId
                                     AND Opportunity__c != null];
       if(cBooking != Null){
           OppId = cBooking.Opportunity__c;
       } 
       List<Order> orderList = [SELECT Id,OrderNumber,Status, Oats_Status__c, TotalAmount, OAT_Email__c,Rejection_Reason__c,
                                (SELECT Id,Name , Invoice_Status__c, Invoice_Total__c, SunSystems_Order_Reference__c,
                                 Service_Start_Date__c 
                                 FROM Invoice_Headers__r LIMIT 1)
                                FROM Order WHERE OpportunityId =:OppId AND Reduction_Order__c != true LIMIT 1];
       if(orderList.Size()>0){
            return orderList[0];
       }
      
      return null;
    }
    
    

}
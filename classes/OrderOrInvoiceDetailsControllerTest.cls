@isTest
public class OrderOrInvoiceDetailsControllerTest {

    @testSetup static void setup() {
        
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Courses__c', 'Course_Trigger');
        createTriggerActivationCustomSettingRecords('Contract', 'Contract_Trigger');
        createTriggerActivationCustomSettingRecords('Order', 'Order_Trigger');
        createTriggerActivationCustomSettingRecords('Campaign', 'Campaign_Trigger');
        createTriggerActivationCustomSettingRecords('Contract_Invoice_Header__c', 'InvoiceHeader_Trigger');
        createTriggerActivationCustomSettingRecords('Course_Booking__c', 'CourseBooking_Trigger ');  
      
        Id pricebookId = Test.getStandardPricebookId();
        
        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Campaign campaignRecord = TestDataUtility.getCampaign();
        INSERT campaignRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id);
        opportunityRecord.CampaignId = campaignRecord.Id;
        INSERT opportunityRecord;
        
        Contract contractRecord = TestDataUtility.getContract(accountRecord.id, opportunityRecord.id);
        INSERT contractRecord; 
        
        Order orderRecord = TestDataUtility.getOrder(contractRecord.id, accountRecord.id);
        orderRecord.Booked_Elsewhere__c = False;
        orderRecord.EffectiveDate = date.today();
        orderRecord.Submission_Offset__c = -18000000;
        orderRecord.Activation_Offset__c = -18000000;
        orderRecord.Pricebook2Id = pricebookId;
        orderRecord.OpportunityId = opportunityRecord.Id;
        INSERT orderRecord;
        
        // First Product
        Product2 productRecord = TestDataUtility.getProduct2();
        productRecord.Revenue_Category__c='Product in advance';
        productRecord.Renewable__c = 'Yes';
        productRecord.Status__c = 'Revenue Ready';
        INSERT productRecord;
        
        PricebookEntry pricebookEntryRecord = TestDataUtility.getPricebookEntry(productRecord.Id, 'GBP', pricebookId);
        INSERT pricebookEntryRecord;
        
        OrderItem orderItemRecord = TestDataUtility.getOrderItem(orderRecord.Id, pricebookEntryRecord.Id);
        orderItemRecord.UnitPrice = 100;
        orderItemRecord.Platform__c = 'MFS';
        orderItemRecord.Quantity = 1;
        INSERT orderItemRecord;
        
        Courses__c courseRecord = TestDataUtility.getCourse(contactRecord);
        INSERT courseRecord;
        
        Course_Booking__c courseBookingRecord = TestDataUtility.getCourseBooking(courseRecord, opportunityRecord, contactRecord);
        INSERT courseBookingRecord;
          
    }
    
    @isTest
    public static void testFetchOrderAndInvoice(){
        
        list<Course_Booking__c> courseBookingList = new list<Course_Booking__c>();
        courseBookingList = [SELECT Id FROM Course_Booking__c LIMIT 1];
        Order orderRecord = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        Order orderData = OrderOrInvoiceDetailsController.fetchOrderAndInvoice(courseBookingList[0].Id);
        Test.stopTest();
        System.assertEquals(orderData.Id, orderRecord.Id);
      
    }
    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }
}
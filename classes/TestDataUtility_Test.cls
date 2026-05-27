@isTest
public class TestDataUtility_Test {
    
    @TestSetup
    static void makeData(){
        
        
        String valueFV = 'XTRAE-EMP,XTRAE-ASSOC,XTREL,DEB,FREIGHT';
       
        createTriggerActivationCustomSettingRecords('Account', 'Account_Trigger');
        createTriggerActivationCustomSettingRecords('Contact', 'Contact_Trigger');
        createTriggerActivationCustomSettingRecords('Opportunity', 'Opportunity_Trigger');
        createTriggerActivationCustomSettingRecords('OpportunityContactRole', 'OpportunityContactRoleTrigger');
        createTriggerActivationCustomSettingRecords('Job__c', 'Job_Trigger');
        createTriggerActivationCustomSettingRecords('Contract', 'Contract_Trigger');
        createTriggerActivationCustomSettingRecords('Order', 'Order_Trigger');
        createTriggerActivationCustomSettingRecords('Courses__c', 'Course_Trigger');
        createTriggerActivationCustomSettingRecords('User', 'User_Trigger');
        createFieldValueCustomSettingRecords(valueFV, 'Credit Note IM Codes');
        TestDataUtility.insertProjectManagerUser('Talent Management'); 
        AutomaticJobCreation__c autoJobCreation = new AutomaticJobCreation__c();
        autoJobCreation.Name = 'Values';
        autoJobCreation.MS_Line_of_Business__c = 'TA - Corporate,Talent Management,TA - Credentialing';
        Insert autoJobCreation;
        

        Account accountRecord = TestDataUtility.getAccount();
        INSERT accountRecord;
        
        Contact contactRecord = TestDataUtility.getContact(accountRecord.Id);
        INSERT contactRecord;
        
        Opportunity opportunityRecord = TestDataUtility.getOpportunity(accountRecord.id, contactRecord.id, UserInfo.getUserId());
        INSERT opportunityRecord;

        Opportunity opportunityRecord2 = TestDataUtility.getOpportunity(accountRecord.Id, contactRecord.Id);

        Contract contractRecord = TestDataUtility.getContract(accountRecord.Id, opportunityRecord.Id);
        Insert contractRecord;

        Product2 productRecord = TestDataUtility.getProduct2();
        Insert productRecord;

        List<Product2> productList = TestDataUtility.getProduct2List(2);

        PricebookEntry pbeRecord = TestDataUtility.getPricebookEntry(productRecord.Id, 'INR', Test.getStandardPricebookId());
        Insert pbeRecord;

        Order orderRecord = TestDataUtility.getOrder(contractRecord.Id, accountRecord.Id);
        Insert orderRecord;

        AutomaticJobCreation__c autoJobCreationRecord = TestDataUtility.getAutomaticJobCreation('Values', 'TA - Corporate,Talent Management,TA - Credentialing');

        OrderItem orderItemRecord = TestDataUtility.getOrderItem(orderRecord.Id, pbeRecord.Id);

        Campaign campaignRecord = TestDataUtility.getCampaign();

        India_GST__c indiaGSTRecord = TestDataUtility.getIndiaGST(accountRecord.Id);

        Courses__c courseRecord = TestDataUtility.getCourse(contactRecord);
        Insert courseRecord;

        Course_Booking__c courseBookingRecord = TestDataUtility.getCourseBooking(courseRecord, opportunityRecord, contactRecord);

        Job__c jobRecord = TestDataUtility.getManualJob(opportunityRecord.Id, UserInfo.getUserId());
        
        Bureau_Candidate__c candidateRecord = TestDataUtility.getCandidate(jobRecord.Id, 'Pass', 'candidate1@test.com');
        
        Work_Request__c generatedRequest = TestDataUtility.getGeneratedWRF(accountRecord.Id, jobRecord.Id);
        
    }

    @isTest
    static void testMethod1() {
        User testUser = TestDataUtility.getUser('Standard User');

        TestDataUtility.insertQueue();

    }

    public static void createTriggerActivationCustomSettingRecords(String objectName, String customSettingName){
        Trigger_Activation__c recordToInsert = TestDataUtility.getTriggerActivation(objectName, customSettingName);
        INSERT recordToInsert;
    }

    public static void createFieldValueCustomSettingRecords(String values, String customSettingName){
        Field_Value_Setting__c fVS = TestDataUtility.getFieldValueSetting(values, customSettingName);
        INSERT fVS;
    }
}
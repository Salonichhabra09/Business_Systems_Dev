@isTest
public class FieldCreationController_test {
    @testSetup
    static void setup() {
        // Create a custom setting record for Metadata_API_Setting__c
        Metadata_API_Setting__c setting = new Metadata_API_Setting__c();
        setting.Name = 'Metadata';
        setting.Consumer_Key__c = 'test_client_id';
        setting.Consumer_Secret__c = 'test_client_secret';
        insert setting;
    }
    
    @isTest
    public static void callScheduleClass(){
        
        String jsonData = '[{"fieldLabel": "TestField", "fieldtype": "text", "Values": ""}]';
        Test.setMock(HttpCalloutMock.class, new MockAccessTokenHttpResponse(200, '{"access_token": "test_access_token"}'));
        FieldCreationScheduler scheduleJob = new FieldCreationScheduler(jsonData);
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute());
        String ss = String.valueOf(Datetime.now().second());
        String sch = ss + ' ' + min + ' ' + hour + ' * * ?';
        Test.StartTest();
        String jobID1 = System.schedule('Test Field Creation '+System.now(), sch, scheduleJob);
        Test.stopTest();
    }
   
    @isTest
    static void testFieldDataList() {
        String jsonData = '[{"fieldLabel": "TestField", "fieldtype": "text", "Values": ""}]';
        String jsonData1 = '[{"fieldLabel": "TestField", "fieldtype": "number", "Values": ""}]';
        String jsonData2 = '[{"fieldLabel": "TestField", "fieldtype": "dropdown", "Values": "abc"}]';
        String jsonData3 = '[{"fieldLabel": "TestField", "fieldtype": "checkbox", "Values": ""}]';
        String jsonData4 = '[{"fieldLabel": "TestField", "fieldtype": "email", "Values": ""}]';
        String jsonData5 = '[{"fieldLabel": "TestField", "fieldtype": "date", "Values": ""}]';
        String jsonData6 = '[{"fieldLabel": "TestField", "fieldtype": "textarea", "Values": ""}]';
        String jsonData7 = '[{"fieldLabel": "TestField", "fieldtype": "time", "Values": ""}]';
        String jsonData8 = '[{"fieldLabel": "&^%$", "fieldtype": "text", "Values": ""}]';
        String accessToken = 'dummyAccessToken';
        
        Test.startTest();
        FieldCreationController.fieldDataList(jsonData, accessToken);
        FieldCreationController.fieldDataList(jsonData1, accessToken);
        FieldCreationController.fieldDataList(jsonData2, accessToken);
        FieldCreationController.fieldDataList(jsonData3, accessToken);
        FieldCreationController.fieldDataList(jsonData4, accessToken);
        FieldCreationController.fieldDataList(jsonData5, accessToken);
        FieldCreationController.fieldDataList(jsonData6, accessToken);
        FieldCreationController.fieldDataList(jsonData7, accessToken);
        FieldCreationController.fieldDataList(jsonData8, accessToken);
        //List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
        //FieldCreationController.handleSaveResults(results);
        Test.stopTest();
    }
}
@isTest(seeAlldata=true)
public class TriggerContextUtility_Tester {
    
    @isTest static void classTest() {
        Test.startTest();
        Boolean result = TriggerContextUtility.isCourseTriggerFirstRun();
        System.assertEquals(true, result);
        TriggerContextUtility.setCourseTriggerFirstRunFalse();
        Boolean resultFalse = TriggerContextUtility.isCourseTriggerFirstRun();
        System.assertEquals(false, resultFalse);
        Test.stopTest();
    }
}
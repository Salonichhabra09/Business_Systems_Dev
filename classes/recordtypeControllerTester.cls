@istest
public class recordtypeControllerTester {
static testMethod void fetchRecordTypeValuesTest(){
    List<String> recordtypevalues = recordtypeController.fetchRecordTypeValues();
    String Id = recordtypeController.getRecTypeId('Configurator Opportunity');
    recordtypeController.getCurrentUserProfile();
}
}
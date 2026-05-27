@isTest
public class CurrentUserInfoControlllerTester {
@istest(seealldata=true)
    public static void CurrentUserInfoControlllerTestMethod(){
        test.startTest();
        CurrentUserInfoController.fetchUser();
        Account account =createtestdata.GetAccount();
        Contact contact =createtestdata.getContact(account.Id);
        Opportunity opp = createtestdata.getOpportunity(account.Id, contact.Id);
        CurrentUserInfoController.fetchProject(CreateTestData.getProject(account.Id, createtestdata.getOpportunity(account.Id, createtestdata.getContact(account.Id).Id).Id).Id);
        CurrentUserInfoController.checkuser();
        NewExpense.fetchUser();
ScheduleBatchProjectDailyAlert sh1 = new ScheduleBatchProjectDailyAlert();
String sch = '0 0 2 * * ?'; 
system.schedule('Test Territory Check', sch, sh1); 
        ProjectObject__c project = createtestdata.getProject(account.Id, opp.Id);
        project.Is_Auto_Created__c = true;
        project.LBU__c='US5';
        update project;
        database.executeBatch(new Project_Daily_Alert());
        test.stopTest();
    }
}
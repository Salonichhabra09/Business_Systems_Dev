@isTest(seeAllData=true)
class MoveToAnotherAccountControllerTest {

    @isTest 
    public static void createContactTest(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Industry = 'Agriculture';
        Insert acc;
        
        Contact con = new Contact();
        con.Lastname = 'Test';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        
        Contact con1 = new Contact();
        con1.Lastname = 'Test';
        con1.Email = 'test';
        con1.AccountId = acc.Id;
        
        
        Test.startTest();
        MoveToAnotherAccountController.createNewContact(con);
        MoveToAnotherAccountController.createNewContact(con1);
        MoveToAnotherAccountController.createNewContact(new contact());
        Test.stopTest();
        
    }
}
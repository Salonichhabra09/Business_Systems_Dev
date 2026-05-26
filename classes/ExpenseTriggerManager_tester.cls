@IsTest(SeeAllData=true)
@testVisible
public class ExpenseTriggerManager_tester {
    
    
    Public static testMethod  void updateStatusInExpensesTest()
    {
        Account a = CreateTestData.GetAccount();
        contact c = CreateTestData.getContact(a.id);
        Opportunity o = CreateTestData.getOpportunity(a.id,c.id);
        ProjectObject__c p = CreateTestData.getProject(a.id, o.id);
        Expense__c expense = CreateTestData.getExpense(p.id);
        
        Project_Invoice__c  invoice =CreateTestData.getProjectInvoice(p.id);
        Project_Invoice__c  invoice1 =CreateTestData.getProjectInvoice(p.id);
        invoice1.Status__c='Processed';
        list <Expense__c> EList = [select id,Date_Incurred__c,Project__c from Expense__c where Expense__c.Project__c=:p.id];
        expense.Status__c='Approved';
        expense.Invoice_Request__c=invoice.Id;
        test.starttest();
        update expense;
        test.stoptest();
        
    }
    Public static testMethod  void TestingExpenseMngr(){
        Account a = CreateTestData.GetAccount();
        contact c = CreateTestData.getContact(a.id);
        Opportunity o = CreateTestData.getOpportunity(a.id,c.id);
        ProjectObject__c p = CreateTestData.getProject(a.id, o.id);
        Id userId = Userinfo.getUserId();
        List<User>PrjMngr=[select id from user where is_project_manager__c = true and IsActive = true limit 1];
        integer i=3;
        List<Expense__c> expensesLst=new List<Expense__c>();
        List<Expense__c> expensesLst2=new List<Expense__c>();
        
        Expense__c expense = new Expense__c();
        expense.Project__c = p.id;
        expense.Status__c='In Progress';
        expense.Resource__c = userId;
        expense.Project_Manager__c = '00520000000ihf6';
        expense.Date_Incurred__c = Date.newInstance(2008,4+i,21);
        expense.Value__c = 200 + i*100;
        expense.Expense_Type__c = 'Hotel';
        expense.Rechargeable__c = false;
        expensesLst.Add(Expense);
        
        Insert expensesLst;
        /*test.starttest();
        delete expensesLst;
        test.stoptest(); */       
        
        Expense_Manager.submitExpense(expensesLst[0].Id);
        Expense_Manager.approveExpenses(expensesLst);
        Expense__c UpdExp=[Select id from Expense__c where id=:Expense.Id];
        Expense__c c2 = [SELECT Id, CreatedDate FROM Expense__c WHERE Id = :expense.Id];
        ProcessInstance pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :expense.Id];
        System.assertEquals(c2.CreatedDate,pi.CreatedDate);
        test.starttest();
        delete expensesLst;
        test.stoptest();
    }
    
}
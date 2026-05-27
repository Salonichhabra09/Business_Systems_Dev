/*****************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 22-07-2019
DESCRIPTION :- This class contains various Methods/Checks/Assignments to controll Expense Functionality as per SHL business process,
               this class is being refered from Expense_Trigger, covering all the Before/After, Insert/Delete & Update Events on Expense Records. 
******************************************************************************/


public class ExpenseTriggerManager {
    //Getting Project Manager from Project
    public static void copyDataFromProject(List<Expense__c> expenses){
        Set<Id> projectIds = new Set<Id>();
        for(Expense__c expense: expenses)
            if(!projectIds.contains(expense.Project__c))
            projectIds.add(expense.Project__c);
        Map<Id, ProjectObject__c> projectsMap = new Map<Id, ProjectObject__c>([SELECT Id, Project_Manager__c FROM ProjectObject__c WHERE id IN :projectIds]);
        for(Expense__c expense: expenses)
            expense.Project_Manager__c = projectsMap.get(expense.Project__c).Project_Manager__c;
    }
    //Restricting the Editing of Expenses if User role is not PSA Lead
    public static void RestrictExpenseEdit(List<Expense__c> NewExpenseList,List<Expense__c> OldExpenseList){
        User user = [SELECT Id, PSA_Role__c FROM User WHERE Id= :UserInfo.getUserId()];
        for(Integer i=0; i<NewExpenseList.size(); i++){
        //If the status of the expense has not changed.
            if(OldExpenseList[i].Status__c==NewExpenseList[i].Status__c){
                if(NewExpenseList[i].Status__c=='Approved' && user.PSA_Role__c!='PSA Lead')
                NewExpenseList[i].addError('You do not have permissions to modify this expense');
            }
        }
    }
    //Restricting the Editing of Expenses if User role is not PSA Lead, throw error.
    public static void RestrictExpenseDelete(List<Expense__c> OldExpenseList){
        User user = [SELECT Id, PSA_Role__c FROM User WHERE Id= :UserInfo.getUserId()];
        for(Integer i=0; i<OldExpenseList.size(); i++){
            if(OldExpenseList[i].Status__c=='Approved' && user.PSA_Role__c!='PSA Lead')
            OldExpenseList[i].addError('You do not have permissions to delete this expense');
        }
    }
}
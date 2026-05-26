public class Account_Manager 
{
    //Below method is being used due to the SFDC governor limits inside a trigger.we can bypass these limits by using @future calls.
    //This methods takes IDs Set as parameter and fetch all the related accounts against the IDs Set then updating their NumberOfContacts field. 
    @future public static void updateNumberOfContacts(Set<Id> accountIds)
    {
     	List<Account> accounts = [SELECT Id,NumberOfContacts__c ,(Select id from 
                                                                 contacts) FROM Account WHERE Id in :accountIds order by Id];
        if(accounts.size()>0){
             for(Account account: accounts){
            account.NumberOfContacts__c = account.Contacts.size();
        }
        }
       
            update accounts;
        
    }
    
    
}
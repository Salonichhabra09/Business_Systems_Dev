public class OpportunityAutoCloserDaysController {
   

    @AuraEnabled
    public static string calculateDaysForAutoClose(Id oppId) {
        Integer countDays;
        Opportunity oppRec = [Select Id,Days_left_to_Auto_Close__c  FROM Opportunity WHERE Id = : oppId];
        Integer daysCount = (Integer)oppRec.Days_left_to_Auto_Close__c;
        return String.valueOf(daysCount) + ' DAY(S) LEFT'  ;
    }

    @AuraEnabled
    public static String getUsersToChangeAutoCloseDate(){
        try {
            Map<String, UsersToChangeAutoCloseDate__c> usersToChangeAutoCloseDateMap = UsersToChangeAutoCloseDate__c.getAll();
            String userEmails = '';
            
            if(usersToChangeAutoCloseDateMap == null || usersToChangeAutoCloseDateMap.isEmpty()) { return null; }
            for(UsersToChangeAutoCloseDate__c usersToChangeAutoCloseDate : usersToChangeAutoCloseDateMap.values()) {
                if(String.isNotEmpty(usersToChangeAutoCloseDate.User_Email__c)) {
                    userEmails = userEmails + usersToChangeAutoCloseDate.User_Email__c + ',';
                }
            }

            return String.isEmpty(userEmails) ? null : userEmails.removeEnd(',');

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
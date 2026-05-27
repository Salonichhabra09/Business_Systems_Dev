Global with sharing class GetRejectedOrders {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrders(String recordId) {
        return [SELECT Id,OrderNumber,oats_status__c,Rejection_Reason__c,recordtype.id FROM Order where (OpportunityId=:recordId or ContractId=:recordId) and oats_status__c='Rejected'];    }

    @AuraEnabled
    public static boolean UpdateAllowClosed(String recordId){
         Opportunity opp = new Opportunity();
        if(recordId.startsWith('800'))
        {
            opp = [Select id,Allow_Closed__c from opportunity where ContractId=:recordId and Rejected_Order_IDs__c!=null and Opportunity_Deal_Year__c=1];
        }
        else 
            opp = [Select id,Allow_Closed__c from opportunity where id=:recordId];
        if(opp.Allow_Closed__c==False)
            opp.Allow_Closed__c=True;
        update opp;
        return opp.Allow_Closed__c;
    }
    
     @AuraEnabled
    public static boolean UserVerification(String recordId){
        Boolean UserIsValid = False;
        Order order =[SELECT ownerid,createdbyid FROM Order where (OpportunityId=:recordId or ContractId=:recordId) and oats_status__c='Rejected'];
        if(order.ownerid == UserInfo.getUserId() || order.createdbyid == UserInfo.getUserId())
        {
            UserIsValid = True;
        }
        if(UserIsValid == False)
        {
           List<GroupMember> members = [SELECT Id, GroupId, UserOrGroupid FROM GroupMember where Group.name ='Order Initial Submitter - Opps Lead/ OAT'];
        for(GroupMember member:members)
        {
            if(member.UserOrGroupid == UserInfo.getUserId())
            {
                UserIsValid = True;
                break;
            }
            else
                continue;
        } 
        }
        return UserIsValid;
    }
    
}
public class AssignLeadsUsingAssignmentRules
{
    @InvocableMethod
    public static void LeadAssign(List<Id> LeadIds){
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;          
        Lead leads=[select id, Not_My_Lead__c from lead where lead.id in :LeadIds];
        leads.setOptions(dmo);
        Decimal count = 0;
        count = (leads.Not_My_Lead__c == null) ? 1 : (1 + leads.Not_My_Lead__c);
        leads.Not_My_Lead__c = count;
        update Leads;
   }
}
Public Class LeadBelowThresholdQueueReAssignment{
Public Static boolean allow = true;

//@future
Public static void ChangeAssignment(set<ID> LeadSet){

allow =false;
List<lead> LeadList=[select id,Lead_stage__C, Owner.Name from Lead where id in : LeadSet];

AssignmentRule  AR = new AssignmentRule();  
AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1]; 

For(Lead L: LeadList){
   
       Database.DMLOptions dmo=new Database.DMLOptions();
       dmo.assignmentRuleHeader.assignmentRuleId=AR.id;
       L.setOptions(dmo);
       
   system.debug('LeadList***'+LeadList);
   }
   
   if(LeadList.size()>0)
    {
        Database.update(LeadList);
    }
   
}

}
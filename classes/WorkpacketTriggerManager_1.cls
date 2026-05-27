/**************************************************************************************************************************************
CREATED BY :- SALONI CHHABRA
CREATED DATE :- 22-08-2019
DESCRIPTION :- This class contains various validations to modify workpacket and its fields refered from Workpacket_Trigger triggers :before update
***************************************************************************************************************************************/ 
 
Global class WorkpacketTriggerManager_1 {
    public static void beforeUpdate(List<Workpacket__c> newWorkpackets, Map<id,Workpacket__c> oldmap){
    set<ID> opsset= new set<ID>();
    group gropob= [select id from group where name ='Workpacket Ops Users' LIMIT 1]; 
    for(groupmember gm : [select id,UserOrGroupId from groupmember where groupid =:gropob.id]){
            opsset.add(gm.UserOrGroupId);
        } 
        
    for(Workpacket__c workpacketobj : newWorkpackets)
    {
        if(trigger.isUpdate)
        {
          if(workpacketobj.Actual_Delivery__c != oldmap.get(workpacketobj.id).Actual_Delivery__c && oldmap.get(workpacketobj.id).Actual_Delivery__c!=null )
          {
            if(!opsset.contains(Userinfo.getUserId())){workpacketobj.adderror(System.Label.Workpacket_Trigger_Label); }
          }
         
        }
    }
}
}
public class CurrentUserInfoController {
    
    @AuraEnabled 
    public static user fetchUser(){
       User u = [select id,Name,PSA_Role__c from User where id =: userInfo.getUserId()];
        return u;
    }
    
    @AuraEnabled 
    public static ProjectObject__c fetchProject(string projectid){
       ProjectObject__c p = [select Project_Manager__c,recordtypeid,Project_Co_ordinator__c,Account_Owner_Email__c from ProjectObject__c where id =:projectid limit 1];
        return p;
    }
	
    @AuraEnabled 
    public static boolean checkuser(){
        boolean validuser = false;
        for(group g : [SELECT Id,(SELECT id FROM GroupMembers WHERE UserOrGroupId=:userInfo.getUserId()) FROM Group WHERE DeveloperName IN('CPS_Create_Edit_Perm_Group')]){
            //system.debug(g);
            //system.debug(g.GroupMembers.size());
            if(g.GroupMembers.size()>0){
                validuser = true;
            }
        }
        return validuser;
    }
}
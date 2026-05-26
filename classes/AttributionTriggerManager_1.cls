/**************************************************************************************************************************************
CREATED BY :- SALONI CHHABRA
CREATED DATE :- 22-08-2019
DESCRIPTION :- This class contains various validations to modify attribution and delete attribution record called from trigger Attribution_Trigger
***************************************************************************************************************************************/ 
 
Global class AttributionTriggerManager_1{
    
    //Validate if user is having PSA role as Lead
    //OR PSA role is Manager and Project manager of related project allow insert
    public static void AttributionTriggerManager_beforeinsert(List<RevenueAttribution__c> newAttribution){
        User user = new User();
        ProjectObject__c project = new ProjectObject__c();
        List<Id>projectIdList = new List<Id>();
        Map<id,ProjectObject__c> projectIdWithProjectObject = new Map<id,ProjectObject__c>();
        
        user = [SELECT Id, PSA_Role__c,Name, ProfileId FROM User WHERE Id= :UserInfo.getUserId()];
        for(RevenueAttribution__c ra: newAttribution){
            projectIdList.add(ra.Project__c);
        }
        for(ProjectObject__c p: [SELECT Id,Project_Manager__c FROM ProjectObject__c where id IN:projectIdList  ]){
            projectIdWithProjectObject.put(p.id,p);
        }
        
        for(Integer i=0; i< newAttribution.size();i++){
            if(!(user.PSA_Role__c == 'PSA Lead' || (user.PSA_Role__c == 'Project Manager' && projectIdWithProjectObject.get(newAttribution[i].Project__c).Project_Manager__c  == user.Id )))
                newAttribution[i].addError('You do not have sufficient privileges to create an attribution for this project. Please contact GSD if you believe this to be incorrect.');
        }
    }
    
    //Validate if user is having PSA role as Lead
    //OR PSA role is Manager and Project manager of related project
    //AND the Financial Period Closed field value is same allow update
    public static void AttributionTriggerManager_beforeupdate(List<RevenueAttribution__c> newAttribution, List<RevenueAttribution__c> oldAttribution){
        User user = new User();
        ProjectObject__c project = new ProjectObject__c();
        List<Id>projectIdList = new List<Id>();
        Map<id,ProjectObject__c> projectIdWithProjectObject = new Map<id,ProjectObject__c>();
        Map<String,Boolean>MapOfOldValues = new Map<String,Boolean>();
        for(RevenueAttribution__c ra :[select id,Financial_Period_Closed__c from RevenueAttribution__c where id IN : oldAttribution]){
          MapofOldValues.put(ra.id,ra.Financial_Period_Closed__c);
        }
        user = [SELECT Id, PSA_Role__c,Name, ProfileId FROM User WHERE Id= :UserInfo.getUserId()];
        for(RevenueAttribution__c ra: newAttribution){
            projectIdList.add(ra.Project__c);
        }
        for(ProjectObject__c p: [SELECT Id,Project_Manager__c FROM ProjectObject__c where id IN:projectIdList  ]){
            projectIdWithProjectObject.put(p.id,p);
        }
        
        for(Integer i=0; i< newAttribution.size();i++){
            system.debug('--->NEWuser.PSA_Role__c<---'+user.PSA_Role__c);
            
            if(!(user.PSA_Role__c == 'PSA Lead' || (user.PSA_Role__c == 'Project Manager' && projectIdWithProjectObject.get(newAttribution[i].Project__c).Project_Manager__c == user.Id )) && (newAttribution[i].Financial_Period_Closed__c== MapofOldValues.get(newAttribution[i].id)))
            newAttribution[i].addError('You do not have sufficient privileges to edit this attribution. Please contact GSD if you believe this to be incorrect.');
        }
    }
    
    
    //Delete not allowed if Financial Period closed is set to true
    //Else validate if user is having PSA role as Lead or (PSA manager and Project manager) of related project allow delete 
    public static void AttributionTriggerManager_beforedelete(List<RevenueAttribution__c> oldAttribution){
        User user = new User();
        ProjectObject__c project = new ProjectObject__c();
        List<Id>projectIdList = new List<Id>();
        Map<id,ProjectObject__c> projectIdWithProjectObject = new Map<id,ProjectObject__c>();
            
        user = [SELECT Id, PSA_Role__c FROM User WHERE Id= :UserInfo.getUserId()];
        
        for(RevenueAttribution__c ra: oldAttribution){
            projectIdList.add(ra.Project__c);
        }
        for(ProjectObject__c p: [SELECT Id,Project_Manager__c FROM ProjectObject__c where id IN:projectIdList  ]){
            projectIdWithProjectObject.put(p.id,p);
        }
        
        for(Integer i=0; i< oldAttribution.size();i++)
            {
                if(oldAttribution[i].Financial_Period_Closed__c==true){
                    oldAttribution[i].addError('You cannot delete this record as attribution period is closed.');
                }
                else if(!(user.PSA_Role__c == 'PSA Lead' || (user.PSA_Role__c == 'Project Manager' && projectIdWithProjectObject.get(oldAttribution[i].Project__c).Project_Manager__c == user.Id ))){
                    oldAttribution[i].addError('You do not have sufficient privileges to delete this attribution. Please contact GSD if you believe this to be incorrect.');
                }
            }
    }
}
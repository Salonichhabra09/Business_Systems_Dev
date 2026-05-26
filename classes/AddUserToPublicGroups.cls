public class AddUserToPublicGroups {
    //Check Profile & Case Team Value from Metdata
    //Remove User from Group logic
    public static void onInsertOfUser(List<User> userList){
        Map<String, Case_Team_Assignment__mdt> mcs = Case_Team_Assignment__mdt.getAll();
        System.debug('mcs'+mcs);
        Map<String,Id> mapOfCaseTeams = new Map<String,Id>();
        Map<Id,String> addUserToGroup = new Map<Id,String>();
        List<Profile> profileList = [SELECT Id,Name From Profile];
        system.debug('profileList'+profileList);
        for(User usr : userList){
            if(addUserToGroup.containsKey(usr.ProfileId)){
                system.debug('usr ###6  '+usr);
                addUserToGroup.put(usr.ProfileId,addUserToGroup.get(usr.ProfileId)+','+usr.Id);
            }else{
                system.debug('usr ###11  '+usr);
                system.debug('usr ###12  '+usr.Profile.Name+' Id '+usr.ProfileId);
                addUserToGroup.put(usr.ProfileId,usr.Id);
            }
            if(usr.Case_Teams__c!=null){
                mapOfCaseTeams.put(usr.Case_Teams__c,usr.Id); 
            }
            system.debug('addUserToGroup '+addUserToGroup);
        }
        if(!addUserToGroup.isEmpty()){
            mainMethod(addUserToGroup);
        }
        if(mapOfCaseTeams!=null){
            handleCaseTeam(mapOfCaseTeams);
        }
    }
    public static void onUserUpdate(List<User> userList, Map<Id,User> oldMap){
        system.debug('userList'+userList);
        system.debug('oldMap'+oldMap);
        Map<Id,String> addUserToGroup = new Map<Id,String>();
        Map<Id,String> removeUserFromGroup = new Map<Id,String>();
        Map<String,String> addCaseTeamGroup = new Map<String,String>();
        Map<String,String> removeCaseTeamGroup = new Map<String,String>();
        for(User usr : userList){
            if(usr.ProfileId!=oldMap.get(usr.Id).ProfileId){
                if(addUserToGroup.containsKey(usr.ProfileId) && usr.IsActive== true){
                    system.debug('usr ###30  '+usr);
                    addUserToGroup.put(usr.ProfileId,addUserToGroup.get(usr.ProfileId)+','+usr.Id);
                }else{
                    system.debug('usr ###33  '+usr);
                    system.debug('usr ###34  '+usr.Profile.Name+' Id '+usr.ProfileId);
                    addUserToGroup.put(usr.ProfileId,usr.Id);
                }
                if(removeUserFromGroup.containsKey(oldMap.get(usr.Id).ProfileId) && usr.IsActive== true){
                    removeUserFromGroup.put(oldMap.get(usr.Id).ProfileId,removeUserFromGroup.get(usr.ProfileId)+','+usr.Id);
                }else{
                    removeUserFromGroup.put(oldMap.get(usr.Id).ProfileId,usr.Id);
                }
                system.debug('addUserToGroup'+addUserToGroup);
                system.debug('removeUserFromGroup'+removeUserFromGroup);
            }
            if(usr.IsActive!=oldMap.get(usr.Id).isActive){
                system.debug('here usr.IsActive '+usr.IsActive);
                if(usr.IsActive){
                    addUserToGroup.put(usr.ProfileId,usr.Id);
                    system.debug('here'+addUserToGroup);
                }else{
                    removeUserFromGroup.put(usr.ProfileId,usr.Id);
                    system.debug('here else'+removeUserFromGroup);
                }
            }
            if(oldMap != null && oldMap.get(usr.Id).Case_Teams__c != null && usr.Case_Teams__c!=oldMap.get(usr.Id).Case_Teams__c){
                for(String str : oldMap.get(usr.Id).Case_Teams__c.split(';')){
                    removeCaseTeamGroup.put(str,usr.Id);    
                }
                system.debug('removeCaseTeamGroup'+removeCaseTeamGroup);
            }
            if(usr.Case_Teams__c!=null){
                for(String str : usr.Case_Teams__c.split(';')){
                    addCaseTeamGroup.put(str,usr.Id);  
                }  
                system.debug('addCaseTeamGroup'+addCaseTeamGroup);
            }
        }
        if(!removeUserFromGroup.isEmpty()){
            deleteOldGroupMember(removeUserFromGroup);
        }
        
        if(!removeCaseTeamGroup.isEmpty()){
            deleteOldCaseTeam(removeCaseTeamGroup);
        }
        if(!addUserToGroup.isEmpty()){
            mainMethod(addUserToGroup);
        }
        if(!addCaseTeamGroup.isEmpty()){
            handleCaseTeam(addCaseTeamGroup);
        }
        
        
    }
    public static void mainMethod(Map<Id,String> addUserToGroup){
        List<GroupMember> listGroupMember =new List<GroupMember>(); 
        Map<String,String> metadataMap = new Map<String,String>();
        Map<String,String> metadataCaseMap = new Map<String,String>();
        Case_Team_Assignment__mdt[] caseMdt = [SELECT Case_Team__c ,Case_Team_Value__c ,Public_Group_Name__c  FROM Case_Team_Assignment__mdt];
        
        Map<String,String> profileMap = new Map<String,String>();
        List<String> profileName = new List<String>();
        for(Profile p : [SELECT Id,Name From Profile Where Id in:addUserToGroup.KeySet()]){
            
            system.debug('profileName 123 '+p);
            profileMap.put(p.Name,p.Id);
            system.debug('profileName '+profileMap);
        }
        for (Case_Team_Assignment__mdt caseMetadata : caseMdt) {
            if(profileMap.containsKey(caseMetadata.Case_Team_Value__c)){
                metadataMap.put(caseMetadata.Public_Group_Name__c,caseMetadata.Case_Team_Value__c);
                // metadataCaseMap.put(caseMetadata.Public_Group_Name__c,caseMetadata.Case_Team__c);
                system.debug('metadataMap'+metadataMap);
                //  system.debug('metadataCaseMap'+metadataCaseMap);  
            }
            
        }
        if (profileMap != null || !profileMap.isEmpty()) {
            List<Group> groupNames = [select Id,Name from Group where Name in: metadataMap.KeySet()];
            system.debug('groupNames'+groupNames);
            for(Group g : groupNames){
                GroupMember gm= new GroupMember(); 
                gm.GroupId = g.id;
                system.debug('metadataMap.get(profileMap.get(g.Name) 123);'+metadataMap.get(g.Name));
                system.debug('metadataMap.get(profileMap.get(g.Name));'+metadataMap.get(profileMap.get(g.Name)));
                gm.UserOrGroupId = addUserToGroup.get(profileMap.get(metadataMap.get(g.Name)));
                listGroupMember.add(gm);
                system.debug('listGroupMember'+listGroupMember);
            }
            insert listGroupMember;
        }
    }
    
    public static void deleteOldGroupMember(Map<Id,String> removeUserFromGroup){
        List<GroupMember> listGroupMember2 =new List<GroupMember>(); 
        Map<String,String> profileMap = new Map<String,String>();
        Map<String,String> metadataMap = new Map<String,String>();
        Map<String,String> metadataCaseMap = new Map<String,String>();
        Map<String,String> removeGroupMember = new Map<String,String>();
        Case_Team_Assignment__mdt[] caseMdt = [SELECT Case_Team__c ,Case_Team_Value__c ,Public_Group_Name__c  FROM Case_Team_Assignment__mdt];
        
        for(Profile p : [SELECT Id,Name From Profile Where Id in:removeUserFromGroup.KeySet()]){
            system.debug('profileName 123 '+p);
            profileMap.put(p.Name,p.Id);
            system.debug('profileName '+profileMap);
        }
        for (Case_Team_Assignment__mdt caseMetadata : caseMdt) {
            if(profileMap.containsKey(caseMetadata.Case_Team_Value__c)){
                metadataMap.put(caseMetadata.Public_Group_Name__c,caseMetadata.Case_Team_Value__c);
                //  metadataCaseMap.put(caseMetadata.Public_Group_Name__c,caseMetadata.Case_Team__c);
                system.debug('metadataMap'+metadataMap);
                //   system.debug('metadataCaseMap'+metadataCaseMap);  
            }
            
        }
        if (profileMap != null || !profileMap.isEmpty()) {
            /*List<Group> groupNames = [select Id,Name from Group where Name in: metadataMap.KeySet()];
for(Group g : groupNames){
listGroupMember2 = [select Id from GroupMember where  GroupId =: g.Id and UserOrGroupId=:removeUserFromGroup.get(profileMap.get(metadataMap.get(g.Name)))];
}*/
            Map<Id, Id> mapGroupIdByUserOrGroupId = new Map<Id, Id>();
            for(Group g : [select Id,Name from Group where Name in: metadataMap.KeySet()]){
                mapGroupIdByUserOrGroupId.put(g.Id, removeUserFromGroup.get(profileMap.get(metadataMap.get(g.Name))));
            }
            //system.debug('groupNames'+groupNames);
            system.debug('groupNames idyh: '+mapGroupIdByUserOrGroupId.keySet());
            for(GroupMember groupMem : [select Id,GroupId,UserOrGroupId from GroupMember where  GroupId IN: mapGroupIdByUserOrGroupId.keySet() and UserOrGroupId IN: mapGroupIdByUserOrGroupId.values()]){
                if(groupMem.UserOrGroupId == mapGroupIdByUserOrGroupId.get(groupMem.GroupId)){
                    listGroupMember2.add(groupMem); 
                }
            }
            system.debug('groupNames'+listGroupMember2);
            try{
                delete listGroupMember2;
            }catch(Exception e){
                system.debug('e-->'+e.getStackTraceString());
            }
            
        }
    }
    
    // case team
    public static void handleCaseTeam(Map<String,String> addCaseTeamGroup){
        Map<Id,List<String>> userMap = new Map<Id,List<String>>();
        List<String> caseTeamList = new List<String>();
        List<User> usr  = [SELECT Id, Case_Teams__c from User where Id in: addCaseTeamGroup.values()];
        system.debug('usr'+usr);
        for(User usrMap : [SELECT Id, Case_Teams__c from User where Id in: addCaseTeamGroup.values()]){
            if(userMap.containsKey(usrMap.Id)){
                caseTeamList.add(usrMap.Case_Teams__c);
                userMap.put(usrMap.Id, caseTeamList);    
            } else{
                userMap.put(usrMap.Id, new List<String>{usrMap.Case_Teams__c}); 
            }
        }
        System.debug('userMap'+userMap);
        List<GroupMember> listGroupMember =new List<GroupMember>(); 
        Map<String,String> metadataMap = new Map<String,String>();
        Map<String,String> metadataCaseMap = new Map<String,String>();
        Case_Team_Assignment__mdt[] caseMdt = [SELECT Case_Team_Value__c ,Public_Group_Name__c  FROM Case_Team_Assignment__mdt where Case_Team_Value__c in:addCaseTeamGroup.keySet()];
        system.debug('caseMdt'+caseMdt);
        Map<String,String> profileMap = new Map<String,String>();
        List<String> profileName = new List<String>();
        /*for(Profile p : [SELECT Id,Name From Profile Where Id in:addCaseTeamGroup.KeySet()]){
//Commercial >> 
system.debug('profileName 123 '+p);
profileMap.put(p.Name,p.Id);
system.debug('profileName '+profileMap);
}*/
        for (Case_Team_Assignment__mdt caseMetadata : caseMdt) {
            // metadataMap.put(caseMetadata.Public_Group_Name__c,caseMetadata.Case_Team_Value__c);
            metadataCaseMap.put(caseMetadata.Public_Group_Name__c,caseMetadata.Case_Team_Value__c);
            //system.debug('metadataMap'+metadataMap);
            system.debug('metadataCaseMap'+metadataCaseMap);  
        }
        if (metadataCaseMap != null || !metadataCaseMap.isEmpty()) {
            system.debug('metadataCaseMap'+metadataCaseMap);
            System.debug(''+[select Id,Name from Group where Name in: metadataCaseMap.KeySet()]);
            List<Group> groupNames = [select Id,Name from Group where Name in: metadataCaseMap.KeySet()];
            system.debug('groupNames'+groupNames);
            for(Group g : groupNames){
                GroupMember gm= new GroupMember(); 
                gm.GroupId = g.id;
                gm.UserOrGroupId = addCaseTeamGroup.get(metadataCaseMap.get(g.Name));
                listGroupMember.add(gm);
                system.debug('listGroupMember'+listGroupMember);
            }
            insert listGroupMember;
        } 
    }
    public static void deleteOldCaseTeam(Map<String,String> removeCaseTeamGroup){
        List<GroupMember> listGroupMember2 =new List<GroupMember>(); 
        Map<String,String> metadataMap = new Map<String,String>();
        Map<String,String> metadataCaseMap = new Map<String,String>();
        Case_Team_Assignment__mdt[] caseMdt = [SELECT Case_Team_Value__c ,Public_Group_Name__c  FROM Case_Team_Assignment__mdt where Case_Team_Value__c in:removeCaseTeamGroup.keySet()];
        system.debug('caseMdt'+caseMdt);
        Map<String,String> profileMap = new Map<String,String>();
        List<String> profileName = new List<String>();
        for (Case_Team_Assignment__mdt caseMetadata : caseMdt) {
            // metadataMap.put(caseMetadata.Public_Group_Name__c,caseMetadata.Case_Team_Value__c);
            metadataCaseMap.put(caseMetadata.Public_Group_Name__c,caseMetadata.Case_Team_Value__c);
            //system.debug('metadataMap'+metadataMap);
            system.debug('metadataCaseMap'+metadataCaseMap);  
        }
        if (metadataCaseMap != null || !metadataCaseMap.isEmpty()) {
            //List<Group> groupNames = [select Id,Name from Group where Name in: metadataCaseMap.KeySet()];
            Map<Id, Id> mapGroupIdByUserOrGroupId = new Map<Id, Id>();
            for(Group g : [select Id,Name from Group where Name in: metadataCaseMap.KeySet()]){
                mapGroupIdByUserOrGroupId.put(g.Id, removeCaseTeamGroup.get(metadataCaseMap.get(g.Name)));
            }
            //system.debug('groupNames'+groupNames);
            system.debug('groupNames id: '+mapGroupIdByUserOrGroupId.keySet());
            for(GroupMember groupMem : [select Id,GroupId,UserOrGroupId from GroupMember where  GroupId IN: mapGroupIdByUserOrGroupId.keySet() and UserOrGroupId IN: mapGroupIdByUserOrGroupId.values()]){
                if(groupMem.UserOrGroupId == mapGroupIdByUserOrGroupId.get(groupMem.GroupId)){
                    listGroupMember2.add(groupMem); 
                }
            }
            /*for(Group g : groupNames){
listGroupMember2 = [select Id from GroupMember where  GroupId =: g.Id and UserOrGroupId=:removeCaseTeamGroup.get(metadataCaseMap.get(g.Name))];
}*/
            system.debug('groupNames'+listGroupMember2);
            try{
                delete listGroupMember2;
            }catch(Exception e){
                system.debug('e-->'+e.getStackTraceString());
            }
        }  
    }
}
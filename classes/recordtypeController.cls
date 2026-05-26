/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-01-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class recordtypeController {
    public static Map<Id, String> recordtypemap {get;set;}
    
   @AuraEnabled(cacheable=true)        
    public static List<String> fetchRecordTypeValues(){
        // Build a decision set of allowed record type names based on current user's Profile/Role
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        String roleName = UserInfo.getUserRoleId() == null ? null :
                          [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() LIMIT 1].Name;

        // Evaluate membership in public group with DeveloperName 'Distributors_for_Case'
        // Using Group + GroupMember to determine if current user is a direct member (bulk-safe and no DML-in-loop)
        Id distributorGroupId = null;
        for (Group g : [SELECT Id FROM Group WHERE Type = 'Regular' AND DeveloperName = 'Distributors_for_Case' LIMIT 1]) {
            distributorGroupId = g.Id;
        }
        Boolean isDistributorGroupMember = false;
        if (distributorGroupId != null) {
            // Check direct user membership
            isDistributorGroupMember = [
                SELECT COUNT()
                FROM GroupMember
                WHERE GroupId = :distributorGroupId
                AND UserOrGroupId = :UserInfo.getUserId()
            ] > 0;
        }

        // Evaluate membership in any group whose DeveloperName starts with 'Commercial_Regional_Operations'
        // Treat membership as equivalent to role/distributor in decision logic
        Boolean isCommercialRegionalOpsMember = false;
        List<Group> croGroups = [
            SELECT Id
            FROM Group
            WHERE Type = 'Regular'
            AND DeveloperName LIKE 'Commercial_Regional_Operations%'
            LIMIT 200
        ];
        if (!croGroups.isEmpty()) {
            Set<Id> croGroupIds = new Set<Id>();
            for (Group cg : croGroups) {
                croGroupIds.add(cg.Id);
            }
            isCommercialRegionalOpsMember = [
                SELECT COUNT()
                FROM GroupMember
                WHERE GroupId IN :croGroupIds
                AND UserOrGroupId = :UserInfo.getUserId()
            ] > 0;
        }
       
        // Target profiles and roles
        Set<String> targetProfiles = new Set<String>{'System Administrator','GCSC General','Managed Service Lightning'};
        Set<String> targetRoles = new Set<String>{'JAPAN','IN: Commercial - Credentialling'};

        Boolean isTargetProfile = profileName != null && targetProfiles.contains(profileName);
        Boolean isTargetRole = roleName != null && targetRoles.contains(roleName);
        Boolean isDistributor = isDistributorGroupMember;
        Boolean isCommercialRegionalOps = isCommercialRegionalOpsMember;

        // Custom Permission gate: Can edit standard opportunities
        // Add this as an OR condition alongside role/distributor groups for granting Standard record type
        Boolean canEditStandardOpp = FeatureManagement.checkPermission('Can_edit_standard_opportunities');
        
        // Determine allowed record type labels (use enum-like constants to avoid typos)
        final String CONFIG = 'Configurator Opportunity';
        final String STANDARD = 'Standard Opportunity';
        final String GCSC = 'GCSC Opportunity';

        Set<String> allowedNames = new Set<String>();
        /*
         Decision matrix updated to include distributor membership:
         - Neither target profile nor role nor distributor: {Configurator}
         - Target role only or distributor: {Configurator, Standard}
         - Target profile only: {Configurator, GCSC}
         - Both target profile and (role or distributor): {Configurator, Standard, GCSC}
        */
        Boolean hasRoleOrDistributor = isTargetRole || isDistributor || isCommercialRegionalOps || canEditStandardOpp;
        if (!isTargetProfile && !hasRoleOrDistributor) {
            allowedNames.add(CONFIG);
        } else if (!isTargetProfile && hasRoleOrDistributor) {
            allowedNames.addAll(new List<String>{CONFIG, STANDARD});
        } else if (isTargetProfile && !hasRoleOrDistributor) {
            allowedNames.addAll(new List<String>{CONFIG, GCSC});
        } else {
            allowedNames.addAll(new List<String>{CONFIG, STANDARD, GCSC});
        }

        // SPECIAL CASE: System Administrators get ALL record types regardless of other filters
        if (isTargetProfile && profileName == 'System Administrator') {
            allowedNames.clear();
            allowedNames.addAll(new List<String>{CONFIG, STANDARD, GCSC});
        }

        // Build return values by filtering org RecordTypeInfos
        List<Schema.RecordTypeInfo> recordtypes = Opportunity.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for (Schema.RecordTypeInfo rt : recordtypes) {
            if (rt.isAvailable() && allowedNames.contains(rt.getName())) {
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }

        // Return a deterministic, de-duplicated sorted list of names
        List<String> result = new List<String>();
        result.addAll(new Set<String>(recordtypemap.values()));
        result.sort();
        return result;        
    }
    
           
       
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }
    @AuraEnabled
    public static String getCurrentUserProfile(){
        Profile currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
		return currentUserProfile.Name;
    }
    
    @AuraEnabled
    public static String getCurrentUserRole(){
        if (UserInfo.getUserRoleId() == null) {
            return null;
        }
        UserRole currentUserRole = [SELECT Id, Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() LIMIT 1];
        return currentUserRole.Name;
    }
    
    
}
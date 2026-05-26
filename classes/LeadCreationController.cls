// Replaced sharing access from with sharing to without sharing as a part of SSE-23138 by Aashi
public without sharing class LeadCreationController {
    
    @AuraEnabled
    public static String createLeadRecords(List<Lead> leadRecordList,String profileName){
        try {
            Campaign campaignRec; 
            String cmpaignName;
            insert leadRecordList;
            if(profileName.contains('GCSC')){
                cmpaignName='GCSC-SYS-New Lead Form Addition';
            }else{
                cmpaignName='GL-SYS-SFDC New Lead and Referral Form';
            }
            //Commenting below query as this is not in use and causing exception as a part of SSE-23138 by Aashi
            /*Lead lead = [Select id, owner.Name from lead where id = :leadRecordList[0].id];
            system.debug(lead);*/
            campaignRec=[Select id from Campaign where name =: cmpaignName];
            CampaignMember camgnMember= new CampaignMember(CampaignId = campaignRec.id , LeadId = leadRecordList[0].id);
            insert camgnMember;
            return leadRecordList[0].id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static String getAppDefination(){
        try {
            List<UserAppInfo> userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
            List<AppDefinition> appDefinition = new List<AppDefinition>();
            if(userAppInfo.size()>0){
            	appDefinition = [SELECT DurableId, NavType FROM AppDefinition Where DurableId = :userAppInfo[0].AppDefinitionId LIMIT 1];
            }
            return appDefinition.size()>0?appDefinition[0].NavType:'not found';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String updateContactRecord(Contact contact){
        try{
            System.debug('contact '+contact);
            update contact;
            return 'Success';
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}
/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is created to display the custom Highlight Panel for Account Plan its getting used in                    *
*              generateAccountPlan LWC Component.                                                                                  *
************************************************************************************************************************************/

public without sharing class HighlightPanelController {

    @AuraEnabled
    public static ReturnWP fetchFields(String recordId, String objectName, String fieldSetName) {
        ReturnWP res = new ReturnWP();
        try {
            // Querying Name Field
            system.debug('Inside Class Fetch');
            if(String.isBlank(recordId)) {
                res.message = 'Invalid Id';
                return res;
            }
            List<sObject> objectList = Database.query('SELECT id, Name ,Account_Plan_Name__c,Account_Name__c , Account_Plan_Status__c, Unapproved_Strategy_Rolloup__c,Days_After_AP_Next_Review__c, Account_Plan_Type__c FROM ' + objectName + ' WHERE Id =: recordId');
            res.nameField = String.valueof(objectList[0].get('Account_Plan_Name__c'));
            res.AccountID = String.valueof(objectList[0].get('Account_Name__c'));
            res.Status = String.valueof(objectList[0].get('Account_Plan_Status__c'));
            res.UnapprovedStrat = String.valueof(objectList[0].get('Unapproved_Strategy_Rolloup__c'));
            res.DaysForNextReview = String.valueof(objectList[0].get('Days_After_AP_Next_Review__c'));
            res.AccountPlanType = String.valueof(objectList[0].get('Account_Plan_Type__c')); //Added as part of SSE-21663 Account Plan Phase 4     
            
             UserRecordAccess checkRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess 
                                                   WHERE UserId =:UserInfo.getUserId() 
                                                   AND RecordId =:recordId];
         if(checkRecordAccess != null){
             if(checkRecordAccess.HasEditAccess == true){
                  res.accessLevel = 'Edit' ;
             }
             else{
                 if(checkRecordAccess.HasReadAccess == true){
                     res.accessLevel = 'Read' ; 
                 }
             }
         }
  

            // Fetching Highlight Panel Field Set
            if(String.isBlank(fieldSetName)) {
                res.message = 'Please provide a Field Set Name';
                return res;
            }
            Schema.FieldSet fieldSet = Schema.getGlobalDescribe().get(objectName).getDescribe().fieldSets.getMap().get(fieldSetName);
            if(fieldSet == null) {
                res.message = 'Field Set provided is not Valid';
                return res;
            }
            res.fieldsAPI = new List<fieldMap>();
            for(Schema.FieldSetMember fieldSetMem: fieldSet.getFields()){
                system.debug('fieldSetMem' + fieldSetMem);
                fieldMap fmWrapper = new fieldMap();
                fmWrapper.name = fieldSetMem.getLabel();
                fmWrapper.apiname = fieldSetMem.getFieldPath();
                res.fieldsAPI.add(fmWrapper);
                
             
            }
            system.debug('Inside Class Fetch  -> ' +res );
            return res;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class ReturnWP {
        @AuraEnabled public String message;
        @AuraEnabled public String accessLevel;
        @AuraEnabled public String nameField;
        @AuraEnabled public String AccountID;
        @AuraEnabled public String Status;
        @AuraEnabled public List<fieldMap> fieldsAPI;
        @AuraEnabled public String UnapprovedStrat;
        @AuraEnabled public String DaysForNextReview;
        @AuraEnabled public String AccountPlanType; //Added as part of SSE-21663 Account Plan Phase 4       
    }
    
    public class fieldMap{
        @AuraEnabled public String name;
        @AuraEnabled public String apiname;
    }
}
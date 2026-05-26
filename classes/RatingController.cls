/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class RatingController {
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getRatingDataTCStatus(String raterType, String jobId) {
        return [
            SELECT TC_Status__c, COUNT(Id) totalCount
            FROM Bureau_Rating__c
            WHERE Rater_Type__c = :raterType 
            AND Participant__r.Bureau_Job__c = :jobId
            AND TC_Status__c != NULL
            GROUP BY TC_Status__c
            LIMIT 50000
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getRatingDataMFSStatus(String raterType, String jobId) {
        return [
            SELECT MFS_Status__c, COUNT(Id) totalCount
            FROM Bureau_Rating__c
            WHERE Rater_Type__c != :raterType 
            AND Respondent__r.Bureau_Job__c = :jobId
            AND MFS_Status__c != NULL
            GROUP BY MFS_Status__c
            LIMIT 50000
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getRatingDataSELFStatus(String raterType, String jobId) {
        return [
            SELECT MFS_Status__c, COUNT(Id) totalCount
            FROM Bureau_Rating__c
            WHERE Rater_Type__c = :raterType 
            AND Participant__r.Bureau_Job__c = :jobId
            AND MFS_Status__c != NULL
            GROUP BY MFS_Status__c
            LIMIT 50000
        ];
    }

    @AuraEnabled(cacheable=true)
    public static String getDefaultRecordTypeId(String objectApiName) {
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
            if (objType != null) {
                Schema.DescribeSObjectResult describeResult = objType.getDescribe();
                return describeResult.getRecordTypeInfos().get(0).getRecordTypeId();
            }
        } catch (Exception e) {
            System.debug('Error fetching record type ID: ' + e.getMessage());
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectApiName, String fieldApiName) {
        List<String> picklistValues = new List<String>();
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
            if (objType != null) {
                Schema.DescribeSObjectResult describeResult = objType.getDescribe();
                Schema.SObjectField field = describeResult.fields.getMap().get(fieldApiName);
                if (field != null) {
                    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                        if (entry.isActive()) {
                            picklistValues.add(entry.getLabel());
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching picklist values: ' + e.getMessage());
        }
        return picklistValues;
    }
}
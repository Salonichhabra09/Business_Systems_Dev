public with sharing class CaseAssigneToMe {
    @AuraEnabled
    public static void assignToMe(Id caseId) {
        system.debug('--->caseId<---'+caseId);
        Case caseRecord = [SELECT Id, OwnerId FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.OwnerId = UserInfo.getUserId();
        update caseRecord;
    }
}
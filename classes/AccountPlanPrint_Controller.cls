public with sharing class AccountPlanPrint_Controller {
    //For Print Account Plan file functionality on LWC Component 'PrintAccountPlan'
    @AuraEnabled
    public static String getLatestAccountPlanByRecordId(String recordId) {

        String checkid = recordID.substring(0, 3);
        String returnID;
           
            List<ContentDocumentLink> files = [SELECT Id, ContentDocumentId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId = :recordId];

            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }

            // Filter PDF files 
            ContentVersion doc = [SELECT ContentDocumentId, FileExtension, Title , VersionData
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN : fileIDs
                                        AND FileExtension='pdf' 
                                        AND Title LIKE '%Account Plan%'
                                        ORDER BY CreatedDate Desc LIMIT 1];
            returnID = doc.ContentDocumentId;

        return returnID; //data;
    }

}
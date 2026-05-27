/**
* @description       : To get Approval submission and Approval work item records
* @author            : saloni.chhabra
* @last modified on  : 04-04-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ApprovalHistoryController {
    
    // Row structure sent to LWC
    public class ApprovalRowDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String recordId;
        @AuraEnabled public String type;          // 'Submission' or 'Work Item'
        @AuraEnabled public String status;
        @AuraEnabled public String actorName;  
        @AuraEnabled public String reviewerName;
        @AuraEnabled public String submitterUserId;  // Submitted By / Assigned To
        @AuraEnabled public String actionLabel;   // 'Submitted' / 'Assigned'
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String comment;
        @AuraEnabled public Boolean isRecallButtonVisible;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ApprovalRowDTO> getApprovalRows(Id recordId) {
        List<ApprovalRowDTO> result = new List<ApprovalRowDTO>();
        if (recordId == null) {
            return result;
        }
        
        User currentUser = [SELECT Id, Name, Profile.Name, UserRole.Name 
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];
		String userProfileName = currentUser.Profile.Name;
        
        
        
        List<ApprovalWorkItem> workItems = [
            SELECT Id,
            Status,
            CreatedDate,
            AssignedTo.Name,
            ReviewedBy.Name,
            Comments,
            ApprovalSubmission.RelatedRecordId
            FROM ApprovalWorkItem
            WHERE ApprovalSubmission.RelatedRecordId = :recordId
            AND Status !='Error'
            ORDER BY CreatedDate DESC
            LIMIT 4
        ];

        System.debug('workItems [0] : '+ workItems.size());
        
        for (ApprovalWorkItem wi : workItems) {
            ApprovalRowDTO row = new ApprovalRowDTO(); row.id          = wi.Id;
            row.recordId    = String.valueOf(wi.ApprovalSubmission.RelatedRecordId);
            row.type        = 'Approval Item'; row.status = wi.Status;
            row.actorName   = (wi.AssignedTo == null) ? null : wi.AssignedTo.Name;
            row.reviewerName   = (wi.ReviewedBy == null) ? null : wi.ReviewedBy.Name;
            row.actionLabel = 'Assigned'; row.createdDate = wi.CreatedDate; row.comment = wi.Comments;
            result.add(row);
        }

        List<ApprovalSubmission> submissions = [
            SELECT Id,
            RelatedRecordId,
            Status,
            CreatedDate,
            SubmittedBy.Name,
            SubmittedById,
            Comments
            FROM ApprovalSubmission
            WHERE RelatedRecordId = :recordId
            AND Status !='Error'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Map<Id, Opportunity> opps = new Map<Id, Opportunity>([
            SELECT Id, 
            Discount_Reason_Justification__c, 
            Discount_Reason_Code__c
            FROM Opportunity
            WHERE Id = :recordId
        ]);

        
        for (ApprovalSubmission sub : submissions) {
            Opportunity opp = opps.get(sub.RelatedRecordId);
            ApprovalRowDTO row = new ApprovalRowDTO();
            row.id          = sub.Id;
            row.recordId    = String.valueOf(sub.RelatedRecordId);
            row.type        = 'Submission Action';
            row.status      = sub.Status;
            row.actorName   = (sub.SubmittedBy == null) ? null : sub.SubmittedBy.Name;
            row.submitterUserId =  (sub.SubmittedById == null) ? null : sub.SubmittedById;
            row.actionLabel = 'Submitted';
            row.createdDate = sub.CreatedDate;
            row.comment     = opp.Discount_Reason_Code__c + '-'+opp.Discount_Reason_Justification__c;
            if((userProfileName == 'System Administrator' || row.submitterUserId == UserInfo.getUserId()) && row.status == 'InProgress'){
                row.isRecallButtonVisible = true;
            }
            result.add(row);
        }
        
        // Sort by createdDate DESC using Comparable
        //result.sort();
        return result;
    }
}
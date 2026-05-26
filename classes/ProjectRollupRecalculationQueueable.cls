public with sharing class ProjectRollupRecalculationQueueable
    implements Queueable {

    private Set<Id> orderIds;

    public ProjectRollupRecalculationQueueable(Set<Id> orderIds) {
        this.orderIds = orderIds;
    }

    public void execute(QueueableContext context) {

        if (orderIds == null || orderIds.isEmpty()) {
            return;
        }

        // Get Project Ids from OrderItems
        Set<Id> projectIds = new Set<Id>();

        for (OrderItem oi : [
            SELECT Project__c
            FROM OrderItem
            WHERE OrderId IN :orderIds
            AND Project__c != NULL
        ]) {
            projectIds.add(oi.Project__c);
        }

        if (!projectIds.isEmpty()) {
            ProjectRollupService.recalculate(projectIds);
            sendCancellationEmails(projectIds);
        }
    }
    
    private static void sendCancellationEmails(Set<Id> projectIds) {

    if (projectIds == null || projectIds.isEmpty()) {
        return;
    }

    List<ProjectObject__c> projects = [
        SELECT Id,
               Name,
               Project_Status__c,
               Owner.Email,
               Project_Manager__c,
               Project_Manager__r.Email,
               Project_Co_ordinator__c,
               Project_Co_ordinator__r.Email
        FROM ProjectObject__c
        WHERE Id IN :projectIds
        AND Project_Status__c NOT IN ('Completed', 'Cancelled')
    ];

    if (projects.isEmpty()) return;

    List<Messaging.SingleEmailMessage> emails =
        new List<Messaging.SingleEmailMessage>();

    for (ProjectObject__c p : projects) {

        Set<String> recipientEmails = new Set<String>();

        if (p.Project_Manager__r != null &&
            String.isNotBlank(p.Project_Manager__r.Email)) {

            recipientEmails.add(p.Project_Manager__r.Email);
        }

        if (p.Project_Co_ordinator__c!= null &&
            String.isNotBlank(p.Project_Co_ordinator__r.Email)) {

            recipientEmails.add(p.Project_Co_ordinator__r.Email);
        }
        
        // Fallback – Owner (only if no PM/PC)
        if (recipientEmails.isEmpty() &&
            p.Ownerid != null &&
            String.isNotBlank(p.Owner.Email)) {

            recipientEmails.add(p.Owner.Email);
        }

        if (!recipientEmails.isEmpty()) {

            Messaging.SingleEmailMessage mail =
                new Messaging.SingleEmailMessage();

            mail.setToAddresses(new List<String>(recipientEmails));
            mail.setSubject('Order Cancelled - Project Impacted');
            
            String baseUrl = URL.getOrgDomainUrl().toExternalForm();
            String projectUrl = baseUrl + '/lightning/r/ProjectObject__c/' + p.Id + '/view';

            mail.setHtmlBody(
                'Dear Team,<br/><br/>' +
                'One or more order line(s) linked to Project "<b>' +
                '<a href="' + projectUrl + '">' + p.Name + '</a>' +
                '</b>" has been cancelled. You are receiving this e-mail as the Project Manager on Salesforce.<br/><br/>' +
                'The order product lines have been automatically recalculated.<br/><br/>' +
                'Please review your project for the revised values and update your milestones accordingly.<br/><br/>' +
                'Regards,<br/>Salesforce System'
            );
            emails.add(mail);
        }
    }

    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}

}
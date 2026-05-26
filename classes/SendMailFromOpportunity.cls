/**
 * ----------------------------------------------------------------------------------------
 * Class Name     : SendMailFromOpportunity
 * Author         : Prabhat Arora
 * Created Date   : 20-09-2025
 * Purpose        : 
 *   - This Class Handles Sending Price Increase emails - To Linked Contact & Specific Roles
 *   - Select Correct Template - Based on Opp (Placeholder/Multiyear/China/Etc)
 *   - Handle failures- Send email to Admin
 *   - Handle Bounce Emails & Update Bounce Flag on Opp
 *   - Updates Renewal Notification time stamp on Opp if email is sent
 *   - Update Contacts for Last Activity Happen & Subject Discussed fields
 *   - Criteria:
 *        1. Criteria is defined in Renewal Notification Alert flow - scheduled to run daily       
 * 
 * ----------------------------------------------------------------------------------------
 */
public class SendMailFromOpportunity {

    // Admin email collector
    private static List<Messaging.SingleEmailMessage> emailToAdmin = new List<Messaging.SingleEmailMessage>();

    // Map to track which template subject was sent per Opportunity
    private static Map<Id, String> oppToTemplateSubject = new Map<Id, String>();

    // Roles that qualify for sending renewal emails
    private static final List<String> CONTACT_ROLES = new List<String>{
        'Billing Contact', 'Decision Maker', 'Decision Maker / Billing Contact'
    };

    @InvocableMethod(label='Send Renewal Emails for Opportunities')
    public static void sendEmail(List<List<String>> inputOppIds) {
        // --- Make input safe: dedupe & cast to Ids (keeps original input shape but prevents duplicates) ---
        Set<Id> oppIdSet = new Set<Id>();
        if (inputOppIds != null) {
            for (List<String> innerList : inputOppIds) {
                if (innerList == null) continue;
                for (String s : innerList) {
                    if (String.isBlank(s)) continue;
                    try {
                        // cast to Id; if invalid it will throw — we skip invalid entries
                        oppIdSet.add((Id)s);
                    } catch (Exception e) {
                        // Ignore invalid Id strings (keeps behavior robust)
                        System.debug('SendMailFromOpportunity: skipping invalid id "' + s + '"');
                    }
                }
            }
        }

        if (oppIdSet.isEmpty()) return;

        List<Id> oppIdList = new List<Id>(oppIdSet);

        // Step 1: Fetch Opportunities + Contacts + Templates
        Map<Id, Opportunity> oppMap = getOpportunities(oppIdList);
        Map<Id, List<String>> oppToEmailsMap = getOpportunityContactEmails(oppIdList);
        Map<String, EmailTemplate> templateMap = getTemplates();

        // Step 2: Build Emails to Send (and capture template subject)
        List<Messaging.SingleEmailMessage> mails = buildOpportunityEmails(oppMap, oppToEmailsMap, templateMap);

        // Step 3: Send Emails + Process Results
        if (!mails.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
            processSendResults(results, oppMap, templateMap);
        }

        // Step 4: Update Opportunities & Contacts (includes template subject mapping)
        updateOpportunitiesAndContacts(oppMap);

        // Step 5: Check for Tasks and update Renewal Notification date
        updateRenewalNotificationSentDate(new List<Id>(oppMap.keySet()));

        // Step 6: Send Admin Notifications (if any)
        if (!emailToAdmin.isEmpty()) {
            Messaging.sendEmail(emailToAdmin, false);
        }
    }

    // ================= HELPER METHODS ================= //

    /** Fetch Opportunity records with necessary fields */
    private static Map<Id, Opportunity> getOpportunities(List<Id> oppIds) {
        return new Map<Id, Opportunity>([
            SELECT Id, Billing_Contact__c, Primary_Contact__c, Owner.Email, Opportunity_Deal_Year__c,
                   Account.BU__c, Account.Owner.Email, Price_Notification_Email_Bounced__c
            FROM Opportunity
            WHERE Id IN :oppIds
        ]);
    }

    /**
     * Fetch emails from OpportunityContactRole for qualifying roles
     * - Uses a Set<String> per Opportunity to dedupe email addresses
     * - Returns Map<OpportunityId, List<String>> (keeps original return type/shape)
     */
    private static Map<Id, List<String>> getOpportunityContactEmails(List<Id> oppIds) {
        Map<Id, Set<String>> oppToEmailSet = new Map<Id, Set<String>>();

        // include ContactId in query and check Contact != null to be defensive
        for (OpportunityContactRole roleRec : [
            SELECT OpportunityId, ContactId, Contact.Email, Role
            FROM OpportunityContactRole
            WHERE OpportunityId IN :oppIds
        ]) {
            if (roleRec.Contact != null && CONTACT_ROLES.contains(roleRec.Role) && roleRec.Contact.Email != null) {
                if (!oppToEmailSet.containsKey(roleRec.OpportunityId)) {
                    oppToEmailSet.put(roleRec.OpportunityId, new Set<String>());
                }
                oppToEmailSet.get(roleRec.OpportunityId).add(roleRec.Contact.Email);
            }
        }

        // Convert back to List<String> for downstream use (preserves original method contract)
        Map<Id, List<String>> oppToEmails = new Map<Id, List<String>>();
        for (Id oppId : oppToEmailSet.keySet()) {
            oppToEmails.put(oppId, new List<String>(oppToEmailSet.get(oppId)));
        }
        return oppToEmails;
    }

    /** Fetch required email templates */
    private static Map<String, EmailTemplate> getTemplates() {
        Set<String> templateNames = new Set<String>{
            System.Label.Renewal_Mail_Template,
            System.Label.China_Renewal_Mail_Template,
            'Renewal_Price_Uplift_Failure_Email_Template',
            System.Label.MultiYear_Renewal_Template
        };

        Map<String, EmailTemplate> templateMap = new Map<String, EmailTemplate>();
        for (EmailTemplate et : [
            SELECT Id, DeveloperName, Subject, Body 
            FROM EmailTemplate 
            WHERE DeveloperName IN :templateNames
        ]) {
            templateMap.put(et.DeveloperName, et);
        }
        return templateMap;
    }

    /** Build renewal emails for each Opportunity & record template subject */
    private static List<Messaging.SingleEmailMessage> buildOpportunityEmails(
        Map<Id, Opportunity> oppMap,
        Map<Id, List<String>> oppToEmailsMap,
        Map<String, EmailTemplate> templateMap
    ) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (Opportunity opp : oppMap.values()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // Keep original behavior: set target contact and also use the contact-role emails as ToAddresses (if any)
            if (opp.Primary_Contact__c != null) {
                mail.setTargetObjectId(opp.Primary_Contact__c);
            }

            // Only set ToAddresses if there are emails collected for the Opp (defensive)
            List<String> toAddrs = (oppToEmailsMap != null && oppToEmailsMap.containsKey(opp.Id)) ? oppToEmailsMap.get(opp.Id) : null;
            if (toAddrs != null && !toAddrs.isEmpty()) {
                mail.setToAddresses(toAddrs);
            }

            // Preserve original CC behavior
            List<String> ccList = new List<String>();
            if (opp.Owner != null && opp.Owner.Email != null) ccList.add(opp.Owner.Email);
            if (opp.Account != null && opp.Account.Owner != null && opp.Account.Owner.Email != null) ccList.add(opp.Account.Owner.Email);
            if (!ccList.isEmpty()) mail.setCcAddresses(ccList);

            mail.setOrgWideEmailAddressId(System.Label.Renewal_Teams_OrgWideEmailAddressId);

            EmailTemplate chosenTemplate;

            // Choose template based on Deal Year & BU (preserve original branching)
            if (opp.Opportunity_Deal_Year__c == 1) {
                if (opp.Account != null && opp.Account.BU__c == 'China - CN1') {
                    chosenTemplate = templateMap.get(System.Label.China_Renewal_Mail_Template);
                } else {
                    chosenTemplate = templateMap.get(System.Label.Renewal_Mail_Template);
                }
            } else {
                chosenTemplate = templateMap.get(System.Label.MultiYear_Renewal_Template);
            }

            // Assign template to mail
            if (chosenTemplate != null) {
                mail.setTemplateId(chosenTemplate.Id);
                // Track the template subject per Opp for later use in Contact update
                oppToTemplateSubject.put(opp.Id, chosenTemplate.Subject);
            }
                    
            mail.setWhatId(opp.Id);
            mails.add(mail);
            System.debug('Chosen Template: ' + (chosenTemplate != null ? chosenTemplate.DeveloperName : 'NULL') +
             ' | OppId=' + opp.Id +
             ' | PrimaryContactId=' + opp.Primary_Contact__c);
        }
        return mails;
    }

    /** Handle SendEmail results: mark failures, send admin notifications */
    private static void processSendResults(
        Messaging.SendEmailResult[] results,
        Map<Id, Opportunity> oppMap,
        Map<String, EmailTemplate> templateMap
    ) {
        for (Messaging.SendEmailResult result : results) {
            if (!result.isSuccess()) {
                String errorMsg = (result.errors != null && result.errors.size() > 0)
                                  ? result.errors[0].message : 'Unknown Error';

                Id contactId = (result.errors != null && result.errors.size() > 0)
                               ? result.errors[0].getTargetObjectId() : null;
                 System.debug(LoggingLevel.ERROR,
                'Email send FAILED. ErrorMsg=' + errorMsg +
                ' | ContactId=' + contactId
                    );              

                for (Opportunity opp : oppMap.values()) {
                    if (opp.Primary_Contact__c == contactId) {
                    
                        sendEmailToAdmin(opp.Id, errorMsg, templateMap.get('Renewal_Price_Uplift_Failure_Email_Template'));
                        opp.Price_Notification_Email_Bounced__c = true;
                    }
                }
            }
        }
    }

    /** Update Opportunity & Contact fields (now includes template subject) */
    private static void updateOpportunitiesAndContacts(Map<Id, Opportunity> oppMap) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        // Use a Map to ensure a Contact is only added once for update (prevents duplicate Ids)
        Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact>();

        for (Opportunity opp : oppMap.values()) {
            if (opp.Price_Notification_Email_Bounced__c) {
                oppsToUpdate.add(new Opportunity(
                    Id = opp.Id,
                    Price_Notification_Email_Bounced__c = opp.Price_Notification_Email_Bounced__c
                ));
            }

            if (opp.Primary_Contact__c != null) {
                // Get subject of email sent for this Opportunity
                String templateSubject = oppToTemplateSubject.containsKey(opp.Id) 
                                         ? oppToTemplateSubject.get(opp.Id) 
                                         : 'Renewal Notification Sent';

                // Put into map — this overwrites previous value for same contact (keeps original "last write wins" behavior),
                // but ensures the contact Id only appears once in the update list.
                contactsToUpdateMap.put(opp.Primary_Contact__c, new Contact(
                    Id = opp.Primary_Contact__c,
                    AutomationBypassDateTime__c = System.now(),
                    Last_Activity_Happen__c = System.now(),
                    Subject_Discussed__c = 'Email: ' + templateSubject
                ));
            }
        }

        if (!oppsToUpdate.isEmpty()) Database.update(oppsToUpdate, false);
        if (!contactsToUpdateMap.isEmpty()) Database.update(contactsToUpdateMap.values(), false);
    }

    /** Check Tasks and update Renewal Notification Date */
    private static void updateRenewalNotificationSentDate(List<Id> oppIds) {
        if (oppIds.isEmpty()) return;

        List<Task> tasks = [
            SELECT Id, WhatId, Subject, CreatedDate
            FROM Task
            WHERE WhatId IN :oppIds
              AND CreatedDate = LAST_N_DAYS:1
              AND (
                   Subject LIKE :('%' + System.Label.Renewal_Price_Uplift_Email_for_MY_Subject + '%')
                OR Subject LIKE :('%' + System.Label.Renewal_Price_Uplift_Email_Chinese_Subject + '%')
                OR Subject LIKE :('%' + System.Label.Renewal_Price_Uplift_Email_Subject + '%')
              )
        ];

        Set<Id> oppsWithTasks = new Set<Id>();
        for (Task t : tasks) {
            oppsWithTasks.add(t.WhatId);
        }

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : [
            SELECT Id, Price_Notification_Email_Bounced__c
            FROM Opportunity
            WHERE Id IN :oppsWithTasks
        ]) {
            if (!opp.Price_Notification_Email_Bounced__c) {
                opp.Renewal_Notification_Sent_On__c = System.now();
                oppsToUpdate.add(opp);
            }
        }

        if (!oppsToUpdate.isEmpty()) {
            Database.update(oppsToUpdate, false);
        }
    }

    /** Build & queue admin notification email */
    @TestVisible
    private static void sendEmailToAdmin(Id oppId, String errorMessage, EmailTemplate et) {
        String body = et.Body;
        String subject = et.Subject;

        String oppURL = URL.getOrgDomainUrl().toExternalForm() + '/' + oppId;
        body = body.replace('{!Opportunity.Name}', '<a href=' + oppURL + '>' + oppId + '</a><br/>');
        body = body.replace('{!errorMessage}', errorMessage);
        subject = subject.replace('{!Opportunity.Name}', oppId);

        List<String> adminEmails = System.Label.Admin_Emails_for_Failure_in_Price_Increase_Notification.split(',');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(adminEmails);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mail.setOrgWideEmailAddressId(System.Label.Renewal_Teams_OrgWideEmailAddressId);

        emailToAdmin.add(mail);
    }
}
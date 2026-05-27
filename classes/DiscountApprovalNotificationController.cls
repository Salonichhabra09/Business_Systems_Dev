public with sharing class DiscountApprovalNotificationController {

    @InvocableMethod(label='Send Discount Approval Emails'
                     description='Send reminder and escalation emails using DOA fields')
    public static void sendNotification(List<List<String>> opportunityDetails)
    {
        if(opportunityDetails == null || opportunityDetails.isEmpty()) {
            System.debug('No input received');
            return;
        }

        List<String> input = opportunityDetails[0];

        if(input == null || input.size() < 2) return;

        Id opportunityId = input[0];
        String typeOfEmail = input[1];

        String opportunityLink =
            URL.getOrgDomainURL().toExternalForm() + '/' + opportunityId;

        // Query Opportunity
        Opportunity opp = [
            SELECT Id,
                   OpportunityId__c,
                   Name,
                   Sales_Price_in_USD__c,
                   Products_Discount__c,
                   Services_Discount__c,
                   Account.Name,
                   Account.Global_Billing_Country__c,
                   Account.Owner.FirstName,
                   Account.Owner.LastName,
                   Account.Territory__c,
                   Account.Territory__r.Id,
                   Account_Territory_Region__c,
                   Owner.FirstName,
                   Owner.LastName,
                   Business_Type__c,
                   Actual_Contract_Duration__c,
                   Forecast_Category__c,
                   CloseDate,
                   Discount_Reason_Justification__c,
                   Discount_Reason_Code__c
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        if(opp.Account == null || opp.Account.Territory__c == null) return;

        String type =
            opp.Products_Discount__c > opp.Services_Discount__c ?
            'Product' : 'Services';

        Decimal percentageToUse =
            opp.Products_Discount__c > opp.Services_Discount__c ?
            opp.Products_Discount__c :
            opp.Services_Discount__c;

        // Query Discount Category
        List<Discount_Approval_Category__c> discountList = [
            SELECT Id,
                   Original_Approver_DOA__c,
                   Escalation_Level_1_DOA__c,
                   Escalation_Level_2_DOA__c
            FROM Discount_Approval_Category__c
            WHERE Active__c = true
            AND Maximum_ACV__c >= :opp.Sales_Price_in_USD__c
            AND Minimum_ACV__c < :opp.Sales_Price_in_USD__c
            AND Type__c = :type
            AND Region__c = :opp.Account_Territory_Region__c
            AND Maximum_Discount__c >= :percentageToUse
            AND Minimum_Discount__c < :percentageToUse
            LIMIT 1
        ];

        if(discountList.isEmpty()) return;

        Discount_Approval_Category__c discount = discountList[0];

        // Build dynamic Territory query
        Set<String> fieldApis = new Set<String>();
        fieldApis.addAll(convertMultiPicklistToApi(discount.Original_Approver_DOA__c));
        fieldApis.addAll(convertMultiPicklistToApi(discount.Escalation_Level_1_DOA__c));
        fieldApis.addAll(convertMultiPicklistToApi(discount.Escalation_Level_2_DOA__c));

        if(fieldApis.isEmpty()) return;

        String soql = 'SELECT Id';

        for(String fieldApi : fieldApis)
        {
            soql += ', Account.Territory__r.' + fieldApi;
            soql += ', Account.Territory__r.' +
                    fieldApi.replace('__c','__r.Email');
        }

        soql += ' FROM Opportunity WHERE Id = :opportunityId LIMIT 1';

        Opportunity oppDynamic = Database.query(soql);

        if(oppDynamic.Account == null || oppDynamic.Account.Territory__r == null)
            return;

        SObject territory = oppDynamic.Account.Territory__r;

        Set<String> emailSet = new Set<String>();

        if(typeOfEmail == 'Approval Reminder' ||
           typeOfEmail == 'Escalation Level 1')
        {
            emailSet.addAll(resolveEmails(discount.Original_Approver_DOA__c, territory));
        }

        if(typeOfEmail == 'Escalation Level 2')
        {
            emailSet.addAll(resolveEmails(discount.Original_Approver_DOA__c, territory));
            emailSet.addAll(resolveEmails(discount.Escalation_Level_1_DOA__c, territory));
        }

        if(typeOfEmail == 'Daily Reminder')
        {
            emailSet.addAll(resolveEmails(discount.Original_Approver_DOA__c, territory));
            emailSet.addAll(resolveEmails(discount.Escalation_Level_1_DOA__c, territory));
            emailSet.addAll(resolveEmails(discount.Escalation_Level_2_DOA__c, territory));
        }

        if(emailSet.isEmpty()) return;

        String emailTemplateToUse =
            typeOfEmail.contains('Escalation') ?
            'Discount_Approval_Approval_Escalation' :
            'Discount_Approval_Approval_Reminder';

        List<EmailTemplate> templates = [
            SELECT Id, Subject, HtmlValue
            FROM EmailTemplate
            WHERE DeveloperName = :emailTemplateToUse
            LIMIT 1
        ];

        if(templates.isEmpty()) return;

        EmailTemplate emailTemplate = templates[0];

        String finalHtml = emailTemplate.HtmlValue;

        String opportunityLinkHtml =
            '<a href="' + opportunityLink +'">' + opp.Name + '</a>';

        finalHtml = finalHtml.replace('OpportunityLink', opportunityLinkHtml);
        finalHtml = finalHtml.replace('OpportunityName', opp.OpportunityId__c);
        finalHtml = finalHtml.replace('Opportunity_Type', String.valueOf(opp.Business_Type__c));
        finalHtml = finalHtml.replace('Duration_In_Months', String.valueOf(opp.Actual_Contract_Duration__c));
        finalHtml = finalHtml.replace('Forecast_Category', String.valueOf(opp.Forecast_Category__c));
        finalHtml = finalHtml.replace('Close_Date', String.valueOf(opp.CloseDate));
        finalHtml = finalHtml.replace('Services_Discount', String.valueOf(opp.Services_Discount__c));
        finalHtml = finalHtml.replace('Product_Discount', String.valueOf(opp.Products_Discount__c));
        finalHtml = finalHtml.replace('Countryy', String.valueOf(opp.Account.Global_Billing_Country__c));
        finalHtml = finalHtml.replace('Opportunity_Owner',
            opp.Owner.FirstName + ' ' + opp.Owner.LastName);
        finalHtml = finalHtml.replace('Account_Manager',
            opp.Account.Owner.FirstName + ' ' + opp.Account.Owner.LastName);
        finalHtml = finalHtml.replace('Account_Name', opp.Account.Name);
        finalHtml = finalHtml.replace('Annual_Contract_Value',
            String.valueOf(opp.Sales_Price_in_USD__c));
        finalHtml = finalHtml.replace('Discount_Reason_Code', opp.Discount_Reason_Code__c);
        finalHtml = finalHtml.replace('Discount_Reason_Justification', opp.Discount_Reason_Justification__c);

        String finalSubject = emailTemplate.Subject;
        finalSubject = finalSubject.replace('OpportunityName', opp.OpportunityId__c);
        finalSubject = finalSubject.replace('Account_Name', opp.Account.Name);

        List<OrgWideEmailAddress> oweaList = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE Address = 'noreply@shl.com'
            LIMIT 1
        ];

        if(oweaList.isEmpty()) return;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>(emailSet));
        mail.setSubject(finalSubject);
        mail.setOrgWideEmailAddressId(oweaList[0].Id);
        mail.setHtmlBody(finalHtml);
        mail.setWhatId(opportunityId);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }

    
    private static Set<String> convertMultiPicklistToApi(String value)
    {
        Set<String> apiSet = new Set<String>();
        if(String.isBlank(value)) return apiSet;

        for(String label : value.split(';'))
        {
            if(String.isBlank(label)) continue;

            String api = label.trim().replaceAll('\\s+','_');

            if(!api.endsWith('__c'))
            {
                api += '__c';
            }

            apiSet.add(api);
        }

        return apiSet;
    }

    
    private static Set<String> resolveEmails(String multi, SObject territory)
    {
        Set<String> emails = new Set<String>();
        if(String.isBlank(multi) || territory == null) return emails;

        for(String label : multi.split(';'))
        {
            if(String.isBlank(label)) continue;

            String api = label.trim().replaceAll('\\s+','_');

            if(!api.endsWith('__c'))
            {
                api += '__c';
            }

            String rel = api.replace('__c','__r');

            try
            {
                SObject userObj = territory.getSObject(rel);

                if(userObj != null)
                {
                    String email = (String) userObj.get('Email');
                    if(email != null)
                        emails.add(email);
                }
            }
            catch(Exception e)
            {
                System.debug('Field not found: ' + rel);
            }
        }

        return emails;
    }
}
/*public class DiscountApprovalNotificationController {
    
    @InvocableMethod(label='Send Discount Approval Emails' description='Used to send apporval reminders and escalation emails')
    Public static void sendNotification(List<List<String>> opportunityDetails)
    {
        List<String> opportunityDetailsToUse = opportunityDetails[0];
        Id opportunityId = opportunityDetailsToUse[0];
        String opportunityLink = URL.getOrgDomainURL().toExternalForm() + '/' + opportunityId;
        List<Opportunity> submittedOpportunity = [SELECT Id, OpportunityId__c,Account.Owner.FirstName,Account.Owner.LastName,Owner.FirstName, Owner.LastName, Account.Name, Account.Global_Billing_Country__c, Name , Sales_Price_in_USD__c, Products_Discount__c, Services_Discount__c, Account_Territory_Super_Region__c ,Business_Type__c,Actual_Contract_Duration__c,Forecast_Category__c,CloseDate
                                                  FROM Opportunity 
                                                  WHERE Id = :opportunityId];
        
        String type = submittedOpportunity[0].Products_Discount__c > submittedOpportunity[0].Services_Discount__c ? 'Product':'Services';
        Decimal percentageToUse = submittedOpportunity[0].Products_Discount__c > submittedOpportunity[0].Services_Discount__c ? submittedOpportunity[0].Products_Discount__c:submittedOpportunity[0].Services_Discount__c;
        
        List<Discount_Approval_Category__c> discountApprovalRecord = [SELECT Id,Original_Approver__c, Escalation_Level_1_Approver__c, Escalation_Level_2_Approver__c FROM Discount_Approval_Category__c 
                                                                      WHERE Maximum_ACV__c >= :submittedOpportunity[0].Sales_Price_in_USD__c
                                                                      AND Minimum_ACV__c < :submittedOpportunity[0].Sales_Price_in_USD__c
                                                                      AND Type__c = :type
                                                                      AND Region__c = :submittedOpportunity[0].Account_Territory_Super_Region__c
                                                                      AND Maximum_Discount__c >= :percentageToUse
                                                                      AND Minimum_Discount__c < :percentageToUse];
        if(!discountApprovalRecord.isEmpty()){
            Set<Id> recipientsList = new Set<Id>();
            List<String> recipientsName = new List<String>();
            Map<String,Id> recipientsMap = new Map<String,Id>();
            if(discountApprovalRecord[0].Original_Approver__c != null){
                recipientsName.add(discountApprovalRecord[0].Original_Approver__c);
            }
            if(discountApprovalRecord[0].Original_Approver__c != null){
                recipientsName.add(discountApprovalRecord[0].Escalation_Level_1_Approver__c);
                
            }
            if(discountApprovalRecord[0].Original_Approver__c != null){
                recipientsName.add(discountApprovalRecord[0].Escalation_Level_2_Approver__c);
            }
            
            List<Group> approverGroups = [SELECT Id, Name FROM Group WHERE Name IN :recipientsName];
            for(Group approverGroup : approverGroups){
                recipientsMap.put(approverGroup.Name, approverGroup.Id);
            }
            String typeOfEmail = opportunityDetailsToUse[1];
            String emailTemplateToUse = typeOfEmail.contains('Escalation') ? 'Discount_Approval_Approval_Escalation' : 'Discount_Approval_Approval_Reminder';
            
            EmailTemplate emailTemplate =[Select Id,Subject,Description,
                                          HtmlValue,DeveloperName,Body
                                          from EmailTemplate where DeveloperName =: emailTemplateToUse];
            
            if(typeOfEmail == 'Approval Reminder' || typeOfEmail == 'Escalation Level 1'){
                recipientsList.add(recipientsMap.get(discountApprovalRecord[0].Original_Approver__c));
            }
            if(typeOfEmail == 'Escalation Level 2'){
                recipientsList.add(recipientsMap.get(discountApprovalRecord[0].Original_Approver__c));
                recipientsList.add(recipientsMap.get(discountApprovalRecord[0].Escalation_Level_1_Approver__c));
            }
            if(typeOfEmail == 'Daily Reminder'){
                recipientsList.add(recipientsMap.get(discountApprovalRecord[0].Original_Approver__c));
                if(discountApprovalRecord[0].Escalation_Level_1_Approver__c != null){
                    recipientsList.add(recipientsMap.get(discountApprovalRecord[0].Escalation_Level_1_Approver__c));
                }
                if(discountApprovalRecord[0].Escalation_Level_2_Approver__c != null){
                    recipientsList.add(recipientsMap.get(discountApprovalRecord[0].Escalation_Level_2_Approver__c));
                }
            }
            List<GroupMember> usersInGroups = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :recipientsList];
            List<Id> recipientIds = new List<Id>();
            for(GroupMember member : usersInGroups){
                recipientIds.add(member.UserOrGroupId);
            }
            String finalHtml = emailTemplate.HtmlValue;
            String opportunityLinkHtml = '<a href="' + opportunityLink +'">' + submittedOpportunity[0].Name + '</a>';
            finalHtml = finalHtml.replace('OpportunityLink',opportunityLinkHtml);
            finalHtml = finalHtml.replace('OpportunityName',submittedOpportunity[0].OpportunityId__c);
            //JIRA - SSE-29027 CHANGES START
			finalHtml = finalHtml.replace('Opportunity_Type',String.valueOf(submittedOpportunity[0].Business_Type__c));
			finalHtml = finalHtml.replace('Duration_In_Months',String.valueOf(submittedOpportunity[0].Actual_Contract_Duration__c));
			finalHtml = finalHtml.replace('Forecast_Category',String.valueOf(submittedOpportunity[0].Forecast_Category__c));
			finalHtml = finalHtml.replace('Close_Date',String.valueOf(submittedOpportunity[0].CloseDate));
            finalHtml = finalHtml.replace('Services_Discount',String.valueOf(submittedOpportunity[0].Services_Discount__c));
            finalHtml = finalHtml.replace('Product_Discount',String.valueOf(submittedOpportunity[0].Products_Discount__c));
			finalHtml = finalHtml.replace('Countryy',String.valueOf(submittedOpportunity[0].Account.Global_Billing_Country__c ));
            finalHtml = finalHtml.replace('Opportunity_Owner',String.valueOf(submittedOpportunity[0].Owner.FirstName+' '+submittedOpportunity[0].Owner.LastName ));        
			finalHtml = finalHtml.replace('Account_Manager',String.valueOf(submittedOpportunity[0].Account.Owner.FirstName + ' ' + submittedOpportunity[0].Account.Owner.LastName));
            finalHtml = finalHtml.replace('Account_Name',String.valueOf(submittedOpportunity[0].Account.Name));
            finalHtml = finalHtml.replace('Annual_Contract_Value',String.valueOf(submittedOpportunity[0].Sales_Price_in_USD__c));
			//JIRA - SSE-29027 CHANGES END
			
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            
            //JIRA - SSE-29027 CHANGES START
            String finalSubject = emailTemplate.subject;
            finalSubject = finalSubject.replace('OpportunityName',submittedOpportunity[0].OpportunityId__c);
            finalSubject = finalSubject.replace('Account_Name',String.valueOf(submittedOpportunity[0].Account.Name));
            //JIRA - SSE-29027 CHANGES END
            Message.setSubject(finalSubject);
            Message.setHTMLBody(finalHtml);
            OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: 'noreply@shl.com' Limit 1];
            message.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
            message.SetToAddresses(new List<Id>(recipientIds));
            message.setWhatId(opportunityId); //This is important for the merge fields in template to work
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success)
            {
                System.debug('The email was sent successfully.');
            }
            else
            {
                System.debug('The email failed to send: ' +
                             results[0].errors[0].message);
            }
        }
    }
    
}*/
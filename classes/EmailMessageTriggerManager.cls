public class EmailMessageTriggerManager {
    
    public static void restrictDeletionOfJobMails(List<EmailMessage> EmailMessages){
        For(EmailMessage msg:EmailMessages){
            String parentid = msg.RelatedToId;
            if(parentid.startswith('a00')){
                msg.adderror('You dont have permission to delete this mail');
            }
        }
    }
    
    public static void processNewEmailMessagesonJob(List<EmailMessage> newEmails) {
        Set<Id> jobIdsToProcess = new Set<Id>();
        Map<Id, List<String>> jobEmailMap = new Map<Id, List<String>>();
        
        for (EmailMessage email : newEmails) {
            if (email.Subject != null && email.Subject.startsWith('New Report View Generated for request:')) {
                System.debug('Inside first If');
                if (email.RelatedToId != null && email.RelatedToId.getSObjectType() == Job__c.SObjectType) {
                    System.debug('Inside Second If');
                    Id jobId = email.RelatedToId;
                    
                    // Extract recipients (To, CC, BCC)
                    List<String> recipientEmails = new List<String>();
                    if (email.ToAddress != null) {
                        recipientEmails.addAll(email.ToAddress.split(';'));
                    }
                    if (email.CcAddress != null) {
                        recipientEmails.addAll(email.CcAddress.split(';'));
                    }
                    if (email.BccAddress != null) {
                        recipientEmails.addAll(email.BccAddress.split(';'));
                    }
                    
                    // Remove duplicates
                    Set<String> uniqueEmails = new Set<String>();
                    for (String emailAddr : recipientEmails) {
                        String trimmedEmail = emailAddr.trim();
                        if (!String.isEmpty(trimmedEmail)) {
                            uniqueEmails.add(trimmedEmail);
                        }
                    }
                    
                    if (!uniqueEmails.isEmpty()) {
                        jobIdsToProcess.add(jobId);
                        jobEmailMap.put(jobId, new List<String>(uniqueEmails));
                    }
                }
            }
        }
        
        if (!jobIdsToProcess.isEmpty()) {
            List<Job__c> jobsToUpdate = [SELECT Id, Client_Report_Mail_Ids__c FROM Job__c WHERE Id IN :jobIdsToProcess];
            
            for (Job__c job : jobsToUpdate) {
                List<String> updatedEmails = jobEmailMap.get(job.Id);
                if (updatedEmails != null && !updatedEmails.isEmpty()) {
                    job.Client_Report_Mail_Ids__c = String.join(updatedEmails, ',');
                }
            }
            
            // Update Job records with recipient emails
            if (!jobsToUpdate.isEmpty()) {
                update jobsToUpdate;
            }
            
            // Trigger password generation and email sending
            for (Job__c job : jobsToUpdate) {
                JobPasswordController.initiatePasswordGeneration(job.Id, jobEmailMap.get(job.Id));
            }
        }
    }
    
    // Used to reopen Referral cases after an incoming email or to send reply incase the it is permanently closed (SSE-28014)
    public static void processIncomingReferralCaseEmails(List<EmailMessage> newEmails) {
        
        Map<Id,EmailMessage> incomingEmailMap = new  Map<Id,EmailMessage>();
        Set<Id> caseIds = new Set<Id>();
        
        for(EmailMessage email : newEmails)
        { 
            if(email.Incoming){
            	caseIds.add(email.ParentId);
				incomingEmailMap.put(email.ParentId,email);
            }            	
        }
        
        if(!caseIds.isEmpty()){
            List<Case> referralCaseList = new List<Case>();
            referralCaseList = [Select Id,Status,isClosed, ClosedDate, RecordType.Name, Origin, OwnerId, Assigned_To__c 
                                FROM Case 
                                WHERE Id in : caseIds 
                                AND isClosed = true 
                                AND RecordType.Name = 'Referral'];
            
            List<EmailMessage> caseClosedPermananentlyEmailList = new List<EmailMessage>();
            List<Case> caseToBeReopened = new List<Case>();
            Date today = system.Today();
            
            for(Case referralCase : referralCaseList){
                if(referralCase.ClosedDate < today.addDays(-90)){
                    caseClosedPermananentlyEmailList.add(incomingEmailMap.get(referralCase.Id));
                }else if(referralCase.ClosedDate >= today.addDays(-90)){
                    caseToBeReopened.add(referralCase);
                }
            }
            
            if(!caseToBeReopened.isEmpty()){
                List<Case> caseToUpdateList = new List<Case>();
                for(Case referralCase : caseToBeReopened){
                    if(referralCase.OwnerId != System.label.NVM_Web_Queue_Id){
                        Case caseToUpdate = new Case();
                        
                        caseToUpdate.Id = referralCase.Id;
                        caseToUpdate.Previous_Owner__c = referralCase.OwnerId;
                        caseToUpdate.Status = 'In Progress';
                        caseToUpdate.OwnerId = System.label.NVM_Web_Queue_Id;
                        
                        caseToUpdateList.add(caseToUpdate);
                    }
                }
                if(!caseToUpdateList.isEmpty())
                	Update caseToUpdateList;
            }
            
            /*if(!caseClosedPermananentlyEmailList.isEmpty()){
                List<OrgWideEmailAddress> orgWideAddressList = [SELECT Id, Address from OrgWideEmailAddress 
                                                            WHERE Address='globaltechnicalsupport@shl.com'];
                
                Map<String,Id> orgWideAddressMap = new Map<String,Id>();
                List<String> toAddressesList = new List<String>();
                
                for(OrgWideEmailAddress orgWideAddress : orgWideAddressList){
                    orgWideAddressMap.put(orgWideAddress.Address,orgWideAddress.Id);
                }
				        
        		EmailTemplate template = [SELECT Id, Name, Subject, body, HtmlValue FROM EmailTemplate 
                                       WHERE name like :'Referral_Case_Permanently_Closed'];
        		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                
                for(EmailMessage emailToReply : caseClosedPermananentlyEmailList){
                    toAddressesList.add(emailToReply.FromAddress);
                    Messaging.reserveSingleEmailCapacity(caseClosedPermananentlyEmailList.size());
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(toAddressesList);
                    email.setPlainTextBody(template.body);
                    email.setSubject(template.Subject);
                    if(emailToReply.ToAddress == 'globaltechnicalsupport@shl.com'){
                        email.setOrgWideEmailAddressId(orgWideAddressMap.get('globaltechnicalsupport@shl.com'));
                    }
                    emails.add(email);
                }
                if(!emails.isEmpty())
                	Messaging.sendEmail(emails);
            }*/
            
        }
    }
    
}
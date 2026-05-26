trigger EmailMessage_AfterInsert on EmailMessage (after insert) {
    EmailMessageTriggerManager.processNewEmailMessagesonJob(Trigger.new);
    EmailMessageTriggerManager.processIncomingReferralCaseEmails(Trigger.new);
    
    List<String> toAddressesList = new List<String>();
    List<EmailMessage> incomingEmailMessagesList = new  List<EmailMessage>();
    List<EmailMessage> incomingEmailMessagesListCPS = new  List<EmailMessage>();
    List<EmailMessage> incomingEmailMessagesListIOFO = new  List<EmailMessage>();
    List<String> caseIdsSet = new List<String>();
    
    for(integer i = 0;i<Trigger.new.size();i++)
    { 
        if(trigger.new[i].Incoming)
            caseIdsSet.add(trigger.new[i].ParentId);
    }
    
    Map<Id,Case> caseMap = new Map<Id,Case>();
    List<Case> lstCase = new List<Case>();
    
    if(caseIdsSet.size()>0){
        caseMap = new Map<Id,Case>([Select id,Status,isClosed, ClosedDate, RecordType.Name, Origin, OwnerId,Case_Country__c, Submitted_From__c from Case where id in : caseIdsSet]);
    }
    
    for(integer i = 0;i<Trigger.new.size();i++)
    {
        
        Date dt = system.Today();
        
        if(trigger.new[i].Incoming && caseMap.get(trigger.new[i].ParentId)!=null && caseMap.get(trigger.new[i].ParentId).isClosed == true &&
           caseMap.get(trigger.new[i].ParentId).RecordType.Name == 'AMS PS')
        {
            incomingEmailMessagesList.add(Trigger.new[i]);
        }
        else if(trigger.new[i].Incoming && caseMap.get(trigger.new[i].ParentId)!=null && caseMap.get(trigger.new[i].ParentId).isClosed == true &&
                caseMap.get(trigger.new[i].ParentId).RecordType.Name == 'Central PS')
        {
            incomingEmailMessagesListCPS.add(Trigger.new[i]);
        }
        
        
        else if(trigger.new[i].Incoming && caseMap.get(trigger.new[i].ParentId)!=null && 
                caseMap.get(trigger.new[i].ParentId).isClosed == true &&
                caseMap.get(trigger.new[i].ParentId).RecordType.Name == 'Information only – Front Office'&& 
                caseMap.get(trigger.new[i].ParentId).ClosedDate < dt.addDays(-90)) 
        {       
            system.debug('Prachi --> inside else if' );
            incomingEmailMessagesListIOFO.add(Trigger.new[i]);   
        }
        else if(trigger.new[i].Incoming && caseMap.get(trigger.new[i].ParentId)!=null && 
                caseMap.get(trigger.new[i].ParentId).RecordType.Name == 'Information only – Front Office' &&  
                (caseMap.get(trigger.new[i].ParentId).ClosedDate == null || 
                 caseMap.get(trigger.new[i].ParentId).ClosedDate >= dt.addDays(-90)))  
        {
            caseMap.get(trigger.new[i].ParentId).Status = 'Inbound Reply';
            System.debug('test inbound reply '+caseMap.get(trigger.new[i].ParentId).Status);
            String CaseId = caseMap.get(trigger.new[i].ParentId).OwnerId;
            //move IOFO cases other than chat and non japan cases to NVM Web queue for external routing
            if(caseMap.get(trigger.new[i].ParentId).Origin != 'Chat' && 
               caseMap.get(trigger.new[i].ParentId).OwnerId != System.label.NVM_Web_Queue_Id  &&
               (caseMap.get(trigger.new[i].ParentId).Case_Country__c!='JPN' ||
                (caseMap.get(trigger.new[i].ParentId).Case_Country__c=='JPN' && 
                 caseMap.get(trigger.new[i].ParentId).Submitted_From__c=='Main website'))){
                     System.debug('test inbound reply 2'+caseMap.get(trigger.new[i].ParentId).OwnerId);
                     caseMap.get(trigger.new[i].ParentId).Previous_Owner__c = caseMap.get(trigger.new[i].ParentId).OwnerId;
                     caseMap.get(trigger.new[i].ParentId).OwnerId = System.label.NVM_Web_Queue_Id;
                 }
            
            //move IOFO cases chat origin to NVM Chat queue for external routing
            else if(caseMap.get(trigger.new[i].ParentId).Origin == 'Chat' && 
                    caseMap.get(trigger.new[i].ParentId).OwnerId != System.label.NVM_Chat_Queue_Id){
                        caseMap.get(trigger.new[i].ParentId).Previous_Owner__c = caseMap.get(trigger.new[i].ParentId).OwnerId;
                        caseMap.get(trigger.new[i].ParentId).OwnerId = System.label.NVM_Chat_Queue_Id;
                    }
            lstCase.add(CaseMap.get(trigger.new[i].ParentId));
            
        }
    }
    
    if(incomingEmailMessagesList.size()>0)
    {
        EmailTemplate e = [select Id, Name, Subject, body from EmailTemplate where name like :'AMS_PS_Auto_response'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(EmailMessage eMessage:incomingEmailMessagesList)
        {
            toAddressesList.add(eMessage.FromAddress);
            Messaging.reserveSingleEmailCapacity(trigger.size);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddressesList);
            email.setHtmlBody(e.body);
            //email.setTargetObjectId(eMessage.ParentId);
            //email.setReplyTo('support@shl.com');
            //email.setSenderDisplayName('SHL Support Team');
            email.setSubject('Thank you for your email');
            //email.setTemplateId(e.Id);
            emails.add(email);
        }
        Messaging.sendEmail(emails);        
    } 
    
    
    
    if(incomingEmailMessagesListCPS.size()>0)
    {
        EmailTemplate e = [select Id, Name, Subject, body from EmailTemplate where name like :'Central_PS_Auto_response'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(EmailMessage eMessage:incomingEmailMessagesListCPS)
        {
            toAddressesList.add(eMessage.FromAddress);
            Messaging.reserveSingleEmailCapacity(trigger.size);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddressesList);
            email.setHtmlBody(e.body);
            //email.setTargetObjectId(eMessage.ParentId);
            //email.setReplyTo('support@shl.com');
            //email.setSenderDisplayName('SHL Support Team');
            email.setSubject('Thank you for your email');
            //email.setTemplateId(e.Id);
            emails.add(email);
            
        }
        Messaging.sendEmail(emails);        
    } 
    
    
    if(incomingEmailMessagesListIOFO.size()>0) 
    {
        
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress];        
        system.debug('--->owea<---'+owea);
        
        EmailTemplate eTemp = [select Id, Name, Subject, body, HtmlValue from EmailTemplate where name 
                               like :'Case_is_Closed_before_30_days'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(EmailMessage eMessage:incomingEmailMessagesListIOFO)
        {
            toAddressesList.add(eMessage.FromAddress);
            Messaging.reserveSingleEmailCapacity(trigger.size);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddressesList);
            email.setHtmlBody(eTemp.HtmlValue);
            email.setPlainTextBody(eTemp.body);
            email.setSubject('***YOUR E-MAIL HAS NOT BEEN RECEIVED***');
            if ( owea.size() > 0 ) {
                for(OrgWideEmailAddress w : owea) {
                    /*if(eMessage.ToAddress == 'globaltechnicalsupport@cebglobal.com' && eMessage.ToAddress == w.Address)                    
email.setOrgWideEmailAddressId(w.Id);
if(eMessage.ToAddress == 'globalcustomersuccess@cebglobal.com' && eMessage.ToAddress == w.Address)                    
email.setOrgWideEmailAddressId(w.Id); */
                    if((eMessage.ToAddress == 'uatnvmprocess@shl.com') &&
                       eMessage.ToAddress == w.Address)                    
                    {email.setOrgWideEmailAddressId(w.Id);
                     
                    }
                    if((eMessage.ToAddress == 'globaltechnicalsupport@shl.com' || eMessage.ToAddress =='gcsccontinuousimprovements@shl.com' || eMessage.ToAddress =='jfa-support@shl.co.jp') && eMessage.ToAddress == w.Address)                    
                    {email.setOrgWideEmailAddressId(w.Id);
                     system.debug('inside the loop' + w.id);
                    }
                    if((eMessage.ToAddress == 'globalcustomersuccess@shl.com' ||  eMessage.ToAddress == 'globalcustomerexperience@shl.com'||
                        eMessage.ToAddress == 'gcsc2022.shl@gmail.com') && //The email address gcsc2022.shl@gmail.com is for UAT Purpose
                       eMessage.ToAddress == w.Address) 
                    {email.setOrgWideEmailAddressId(w.Id);
                     system.debug('inside the loop' + w.id);
                    }
                }
                system.debug('---> to address<---'+email.getToAddresses());
            }
            emails.add(email);
            
        }
        
        system.debug('---->emails<----'+emails);
        //system.debug('email from add' + emails[0].FromAddress );
        Messaging.sendEmail(emails);   
        
    } 
    if(lstCase.size()>0) {
        update lstCase;
    }  
    
}
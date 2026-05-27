public class AccountSanctionNotificationController {
    
    @InvocableMethod(label='Send Account Sanctioned Email' description='When an account is sanctioned then an email notification is sent')
    Public static void sendNotification(List<Id> accountIds)
    {
        Id accountId = accountIds[0];
        String accountLink = URL.getOrgDomainURL().toExternalForm() + '/' + accountId;
        List<Account> account = [SELECT Id,Account_Number__c,Name,OwnerId,Owner.ManagerId FROM Account WHERE Id =:accountId];
        List<Opportunity> oppList = [SELECT Id,OpportunityId__c,ContractId,CloseDate,Sales_Price_in_USD__c,Opportunity_Nickname__c,OwnerId,Owner.FirstName,Owner.LastName,Owner.ManagerId,Actual_Record_Type_Name__c,Opportunity_Submitted__c FROM Opportunity WHERE AccountId =:accountId AND StageName != :System.Label.Opportunity_Stage_7 AND StageName != :System.Label.Opportunity_Stage_6 AND Variation_Reason__c != 'Debooking' ORDER BY CloseDate];
        List<Id> opportunityIds = new List<Id>();
        List<Id> contractIds = new List<Id>();
        Set<Id> recipientsList = new Set<Id>();
        recipientsList.add(account[0].OwnerId);
        if(account[0].Owner.ManagerId != null){
            recipientsList.add(account[0].Owner.ManagerId);
        }
        String htmlBody = '';
        String finalHtml = '';
        String templateToUse = 'Account Sanctioned Email';
        //open table..  
        EmailTemplate emailTemplate =[Select Id,Subject,Description,
                                      HtmlValue,DeveloperName,Body
                                      from EmailTemplate where name =: templateToUse];
        
        finalHtml = emailTemplate.HtmlValue;
        
        List<AccountTeamMember> accTeam = [SELECT Id,UserId FROM AccountTeamMember WHERE AccountId =:accountId];
        for(AccountTeamMember member : accTeam){
            recipientsList.add(member.userId);
        }

        
        System.debug(finalHtml);
        
        if(!oppList.isEmpty()){
            htmlBody = '<table border="1" style="border-collapse: collapse"><tr><th></th><th>Owner </th><th>Opportunity Number </th><th>Opportunity Nickname </th><th>Sales Price (USD) </th><th>Close Date </th></tr>';     
            //iterate over list and output columns/data into table rows..
            Integer count = 1;
            for(Opportunity opp : oppList){  
                opportunityIds.add(opp.Id);
                String salesPriceUSD = '$'+String.valueOf(opp.Sales_Price_in_USD__c);
                String oppNickname = opp.Opportunity_Nickname__c!=null ? opp.Opportunity_Nickname__c : '';
                String closeDate = String.valueOf(opp.CloseDate);
                String oppNumber = opp.OpportunityId__c;
                String ownerName = opp.Owner.FirstName + ' ' + opp.Owner.LastName;
                
                htmlBody += '<tr><td Style="padding:5px">'+ count +'</td><td Style="padding:5px">' + ownerName + ' </td><td Style="padding:8px">' + oppNumber + ' </td><td Style="padding:5px">' + oppNickname + ' </td><td Style="padding:5px">' + salesPriceUSD + ' </td><td Style="padding:5px">' + closeDate + ' </td></tr>';  
            	count++;
                
                if(opp.Actual_Record_Type_Name__c =='GCSC Opportunity'){
                    recipientsList.add(opp.Opportunity_Submitted__c);
                }
                if(opp.ContractId!=null){
                    contractIds.add(opp.ContractId);
                }
                
                recipientsList.add(opp.OwnerId);
                if(opp.Owner.ManagerId != null){
            		recipientsList.add(opp.Owner.ManagerId);
        		}
            }
            //close table...
            htmlBody += '</table>';
            
            List<OpportunityTeamMember> oppTeam = [SELECT Id,UserId FROM OpportunityTeamMember WHERE OpportunityId IN :opportunityIds];
            
            for(OpportunityTeamMember member : oppTeam){
                recipientsList.add(member.userId);
            }
            
            finalHtml = finalHtml.replace('*Opp start*','');
            finalHtml = finalHtml.replace('{Closed lost opportunities} *Opp end*',htmlBody);
            //finalHtml = finalHtml.replace('48 hours','<b style="color:red">72 hours</b>');
            
        }else{
            System.debug(finalHtml);
            finalHtml = finalHtml.replace('<br><br>*Opp start*','');
        	finalHtml = finalHtml.replace('<b>The following open Opportunities will be set to Closed Lost (this includes the cancellation of any in-flight CLM processes):</b>','');
            finalHtml = finalHtml.replace('<br><br>{Closed lost opportunities} *Opp end*','');

        }
        
        finalHtml = finalHtml.replace('<br><br>*Contract start*','');
        finalHtml = finalHtml.replace('<b>The following current active Contracts will be cancelled:</b><br><br>','');
        finalHtml = finalHtml.replace('{Cancelled Contracts} *Contract end*','');
        
        /*List<Contract> contractList = [SELECT Id,ContractNumber,Contract_End_Date__c,StartDate,Total_Contract_Value_in_USD__c FROM Contract WHERE Id IN :contractIds];
        
        if(!contractList.isEmpty()){
            String contractHtmlBody = '<table border="1" style="border-collapse: collapse"><tr><th></th><th>Contract Number </th><th>Start Date </th><th>End Date </th><th>Total Contract Value (USD) </th></tr>';     
            //iterate over list and output columns/data into table rows..
            Integer count = 1;
            for(Contract con : contractList){  
                String contractNumber = con.ContractNumber;
                String startDate = String.valueOf(con.StartDate);
                String closeDate = String.valueOf(con.Contract_End_Date__c);
                String contractValueUSD = '$'+String.valueOf(con.Total_Contract_Value_in_USD__c);
                
                contractHtmlBody += '<tr><td Style="padding:5px">'+ count +'</td><td Style="padding:5px">' + contractNumber + ' </td><td Style="padding:8px">' + startDate + ' </td><td Style="padding:5px">' + closeDate + ' </td><td Style="padding:5px">' + contractValueUSD + ' </td></tr>';  
            	count++;
                
            }
            //close table...
            contractHtmlBody += '</table>';
            
            finalHtml = finalHtml.replace('*Contract start*','');
            finalHtml = finalHtml.replace('{Cancelled Contracts} *Contract end*',contractHtmlBody);
        }*/
        
        System.debug(finalHtml);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        //Get templete id for set the templete.
        
        finalHtml = finalHtml.replace('{!Account.Link}',accountLink);
        finalHtml = finalHtml.replace('{!Account.Name}',account[0].Name);
        finalHtml = finalHtml.replace('{!Account.AccountNumber}',account[0].Account_Number__c);
        
        String finalSubject = emailTemplate.subject.replace('{!Account.Name}',account[0].Name);
        Message.setSubject(finalSubject);
        Message.setHTMLBody(finalHtml);
        OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: 'noreply@shl.com' Limit 1];
        message.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
        message.SetToAddresses(new List<Id>(recipientsList));
        message.setCcAddresses(new List<String>(System.Label.Account_Sanction_Email_Recipients.split(',')));
        message.setWhatId(accountId); //This is important for the merge fields in template to work
        
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
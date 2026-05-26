/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is created to handle the update of NumberofAccountPlan field on Account if any Account Plan is deleted.  *
************************************************************************************************************************************/

public class accountPlanTriggerManager {

    public static void updateNumberofAccountPlanOnAccount(List<Account_Plan__c> apList){
        if(!apList.isEmpty()){
            List<Account> accountListToUpdate = new List<Account>();
            Set<id> accountIds = new Set<id>();
            Set<String> buyingCentreID = new Set<String>();
            for(Account_Plan__c ap: apList){
                if(ap.Account_Plan_Type__c == 'Regional' && ap.Buying_Centre_Id__c != '' && ap.Buying_Centre_Id__c != null){
                   buyingCentreID.add(ap.Buying_Centre_Id__c);
                }
                else if((ap.Account_Plan_Type__c == 'Global' || ap.Account_Plan_Type__c == 'Current') && 
                        (ap.Buying_Centre_Id__c == '' || ap.Buying_Centre_Id__c == null)){
                    accountIds.add(ap.Account_Name__c);
                }
            }
            
            if(!buyingCentreID.isEmpty()){
              List<Account>  accountList1 =[Select id,  Number_of_Account_Plan__c , Buying_Centre_Id__c from account 
                                            where Buying_Centre_Id__c in :buyingCentreID];
                if(!accountList1.isEmpty()){
                    for(Account acc: accountList1){
                        if( acc.Number_of_Account_Plan__c == null ||  acc.Number_of_Account_Plan__c == 0){
                             acc.Number_of_Account_Plan__c = 0;
                        }else{
                             acc.Number_of_Account_Plan__c = acc.Number_of_Account_Plan__c - 1;
                        }
                       
                        accountListToUpdate.add(acc);
                    }
                }
                
            }
            
            if(!accountIds.isEmpty()){
                 List<Account>  accountList2 =[Select id,  Number_of_Account_Plan__c , Buying_Centre_Id__c from account 
                                               where id in :accountIds];
                   if(!accountList2.isEmpty()){
                      for(Account acc: accountList2){
                         if( acc.Number_of_Account_Plan__c == null ||  acc.Number_of_Account_Plan__c == 0){
                             acc.Number_of_Account_Plan__c = 0;
                        }else{
                             acc.Number_of_Account_Plan__c = acc.Number_of_Account_Plan__c - 1;
                        }
                        accountListToUpdate.add(acc);
                    }
                       
                }
            }
            
            update accountListToUpdate;
        }
    }
    
    public static void sendMailToApprovalSubmitter(List<Account_Plan__c> OldList,List<Account_Plan__c> NewList){
        List<Id> accountPlanIdsToWorkUpon = new List<Id>();
        List<Account_Plan__c> accountPlans = new List<Account_Plan__c>();
        List<ApprovalProcessWrapper> wrapperList = new List<ApprovalProcessWrapper>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Integer i=0;i<OldList.size();i++){
            if(OldList[i].Account_Plan_Status__c!=NewList[i].Account_Plan_Status__c &&
               (NewList[i].Account_Plan_Status__c=='Approved' ||NewList[i].Account_Plan_Status__c=='Rejected')){
                   accountPlanIdsToWorkUpon.add(NewList[i].Id);
                   accountPlans.add(NewList[i]);
               }
        }
        List<ProcessInstance> approvalProcessList = new List<ProcessInstance>([SELECT Id, Status, TargetObjectId,submittedbyid,submittedby.name FROM ProcessInstance WHERE TargetObjectId IN :accountPlanIdsToWorkUpon]);
        List<ProcessInstanceStep> approvalProcessStepsList = new List<ProcessInstanceStep>([select id,Comments,ProcessInstanceid,Actor.name from ProcessInstanceStep where ProcessInstanceid in :approvalProcessList and (stepstatus='Approved' or stepstatus='Rejected') order by SystemModStamp desc limit 1]);
        
      for(Account_Plan__c accountPlan:accountPlans){
        for(ProcessInstance instance:approvalProcessList){
            for(ProcessInstanceStep step:approvalProcessStepsList){
                if(step.ProcessInstanceid==instance.Id && instance.TargetObjectId ==accountPlan.Id){
                    ApprovalProcessWrapper wrapperItem = new ApprovalProcessWrapper(
                        accountPlan,
                    	step.Comments,
                    	instance.SubmittedById,
                    	instance.submittedby.name,
                    	step.Actor.name);
                    wrapperList.add(wrapperItem);
                }
            }
        }
        }
        EmailTemplate Approvedtemplate=[SELECT Id,Subject,body FROM EmailTemplate WHERE developername='Account_Plan_Approval_Email_Template'];
        EmailTemplate Rejectedtemplate=[SELECT Id,Subject,body FROM EmailTemplate WHERE developername='Account_Plan_Rejection_Email_Template'];
        String htmlBody;
        String formateddate;
        String SubjectBody;
        for(ApprovalProcessWrapper apWrapper : wrapperList){
            if(apWrapper != null && (apWrapper.accountPlan.Account_Plan_Status__c == 'Approved' ||
                                    apWrapper.accountPlan.Account_Plan_Status__c == 'Rejected')){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(apWrapper.submitterId);
                                       
                                        if(apWrapper.accountPlan.Account_Plan_Status__c=='Approved'){
                                            htmlBody = Approvedtemplate.body;
                                            SubjectBody = Approvedtemplate.subject;
                                            formateddate = Datetime.newInstance(apWrapper.accountPlan.Date_for_next_Plan_Review__c.year(),
                                                                              apWrapper.accountPlan.Date_for_next_Plan_Review__c.month(),
                                                                              apWrapper.accountPlan.Date_for_next_Plan_Review__c.day()).format('dd-MMM-YYYY');
                       						htmlBody = htmlBody.replace('{!Account_Plan__c.Date_for_next_Plan_Review__c}', formateddate);
                                        	
                                        }
                                        else if (apWrapper.accountPlan.Account_Plan_Status__c=='Rejected'){
                                            htmlBody = Rejectedtemplate.body;
                                            SubjectBody = Rejectedtemplate.subject;
                                             htmlBody = htmlBody.replace('{!ApprovalRequest.Comments}', apWrapper.comments);
                                        }
                
                htmlBody = htmlBody.replace('{!SubmitterName}', apWrapper.submitterName);
                htmlBody = htmlBody.replace('{!Account_Plan__c.Account_Plan_Name__c}',apWrapper.accountPlan.Account_Plan_Name__c);
                htmlBody = htmlBody.replace('{!Account_Plan__c.Account_Name__c}', apWrapper.accountPlan.Account_Name_System_Use__c);
                //htmlBody = htmlBody.replace('{!Account_Plan__c.Account_Plan_Status__c}', apWrapper.accountPlan.Account_Plan_Status__c);
               htmlBody = htmlBody.replace('{!ApprovalRequest.Process_Approver}', apWrapper.approverName);
                SubjectBody = SubjectBody.replace('{!Account_Plan__c.Account_Name__c}',apWrapper.accountPlan.Account_Name_System_Use__c);
                SubjectBody = SubjectBody.replace('{!Account_Plan__c.Account_Plan_Name__c}',apWrapper.accountPlan.Account_Plan_Name__c);
                mail.setSubject(SubjectBody);
                mail.setplainTextBody(htmlBody);
                mail.saveAsActivity = false;
                emailList.add(mail);
                System.debug('Email is '+mail);
            }
        }
        Messaging.sendEmail(emailList,false);
        
    }
public class ApprovalProcessWrapper{
        public Account_Plan__c accountPlan{get;set;}
        public String comments{get;set;}
        public Id submitterId{get;set;}
        public String submitterName{get;set;}
        public String approverName{get;set;}
        public ApprovalProcessWrapper(Account_Plan__c accountPlan,String comments,Id submitterId,String submitterName,String approverName){
            this.accountPlan = accountPlan;
            this.comments = comments;
            this.submitterId = submitterId;
            this.submitterName = submitterName;
            this.approverName = approverName;
        }
    }
     
}
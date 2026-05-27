/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is the test class for accountPlanTriggerManager.                                                         *
************************************************************************************************************************************/

@isTest(seeAlldata=true)
public class accountPlanTriggerManager_Test {
    
    @isTest 
    static void deleteAccountPlanTest(){
        test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'India - 1',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        Account_Plan__c plan = new Account_Plan__c(Account_Name__c = acc.Id ,  Account_Plan_Type__c = 'Current');
        insert plan;
        
        delete plan;
        test.stopTest();
    }  
    
        @isTest 
    static void deleteRegionalAccountPlanTest(){
        test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'India - 1',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
         Account acc1 = new Account(name= 'Data 2' ,Status__c='Approved',Buying_Centre_Id__c = 'India - 1',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc1;
        
        Account_Plan__c plan = new Account_Plan__c(Account_Name__c = acc.Id , Buying_Centre_Id__c = 'India - 1', 
                                                   Account_Plan_Type__c = 'Regional');
        insert plan;
        
        delete plan;
        test.stopTest();
    }  
    
   
    @isTest
    static void sendMailToApprovalSubmitterRejectiontest(){
        
        
        test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'India - 1',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
         System.runAs(getTestUsers()){
        Account_Plan__c plan = new Account_Plan__c(Account_Name__c = acc.Id ,  Account_Plan_Type__c = 'Current',Date_for_next_Plan_Review__c=Date.Today(),Account_Plan_Status__c='Draft');
        insert plan;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(plan.id);
        req1.setNextApproverIds(new Id[] {acc.createdbyid});
        Approval.ProcessResult result = Approval.process(req1);
        Id workitemId = result.getNewWorkitemIds()[0];
		rejectrecord(plan,workitemId);	
         }
        test.stoptest();
    }
    
    @isTest
    static void sendMailToApprovalSubmitterApprovaltest(){
        test.startTest();
        Account acc = new Account(name= 'Testname_AccountPlan' ,Status__c='Approved',Buying_Centre_Id__c = 'India - 1',
                                  Billing_Address_Line_1__c='test',Billing_City__c='Test City',
                                  Billing_Country__c='India',Billing_State__c='Test',Industry= 'Legal',
                                  Billing_ZIP_Postal_Code__c='1100110',BU__c='China - CN1');
        insert acc;
        
        System.runAs(getTestUsers()){
        Account_Plan__c plan = new Account_Plan__c(Account_Name__c = acc.Id ,  Account_Plan_Type__c = 'Current',Date_for_next_Plan_Review__c=Date.Today(),Account_Plan_Status__c='Draft');
        insert plan;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(plan.id);
        req1.setNextApproverIds(new Id[] {acc.createdbyid});
        Approval.ProcessResult result = Approval.process(req1);
        Id workitemId = result.getNewWorkitemIds()[0];
		approverecord(plan,workitemId);	
        }
        test.stoptest();
    }
    
    public static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;

        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
        }

        return retVal;
    }

    /**
    * This method will Approve the opportunity
    **/
    public static void approveRecord(Account_Plan__c plan,Id workItemId)
    {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request using Trigger');
        req.setAction('Approve');
        //Id workItemId = getWorkItemId(plan.id); 


            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
    
    }

    /**
    * This method will Reject the opportunity
    **/
    public static void rejectRecord(Account_Plan__c plan,Id workItemId)
    {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Rejected request using Trigger');
        req.setAction('Reject');
        //Id workItemId = getWorkItemId(plan.id);   

      req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
     
    }
    
     public static user getTestUsers(){
         
        User contractor = [select id,managerId from user where managerId!=null and ProfileId = :UserInfo.getProfileId() limit 1];
         
         return contractor;
    }
}
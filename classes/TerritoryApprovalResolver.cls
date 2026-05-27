public with sharing class TerritoryApprovalResolver {

    @InvocableMethod(
        label='Get Approval Group Fields from Territory'
        description='Resolves Territory approval fields dynamically from Opportunity.Account.Territory__r'
    )
    public static List<OutputWrapper> resolveApproval(List<InputWrapper> inputs) {
        List<OutputWrapper> results = new List<OutputWrapper>();
        OutputWrapper output = new OutputWrapper();
        List<String> approvalFields = new List<String>();
        List<String> currentApprovers = new List<String>();
        List<String> escalationLevel1Approvers = new List<String>();
        List<String> escalationLevel2Approvers = new List<String>();
        List<String> priorApprovers = new List<String>();
        String originalApproverString;
        String escalationLevel1ApproverString;
        String escalationLevel2ApproverString;
        String priorApproverString;

        if (inputs == null || inputs.isEmpty()) {
            return results;
        }
		
        String approvalStatus = inputs.get(0).discountApprovalStatus;
        if(approvalStatus == 'Submitted for Approval'){
            originalApproverString = inputs.get(0).originalApprovers;
        }else if(approvalStatus == 'Escalated Level 1'){
            escalationLevel1ApproverString = inputs.get(0).originalApprovers;
            priorApproverString = inputs.get(0).escalationLevel1Approvers;
        }else if(approvalStatus == 'Escalated Level 2'){
            escalationLevel2ApproverString = inputs.get(0).originalApprovers;
            priorApproverString = inputs.get(0).escalationLevel1Approvers;
        }
        Id opportunityId = inputs.get(0).recordId;
        
        if(originalApproverString != null){
            currentApprovers = originalApproverString.split(';');
            approvalFields.addAll(currentApprovers);
            //output.currentApproverList = currentApprovers;
        }
        if(escalationLevel1ApproverString != null){
            escalationLevel1Approvers = escalationLevel1ApproverString.split(';');
            approvalFields.addAll(escalationLevel1Approvers);
            //output.priorApproverList = escalationLevel1Approvers;
        }
        if(escalationLevel2ApproverString != null){
            escalationLevel2Approvers = escalationLevel2ApproverString.split(';');
            approvalFields.addAll(escalationLevel2Approvers);
        }
        if(priorApproverString != null){
            priorApprovers = priorApproverString.split(';');
            approvalFields.addAll(priorApprovers);
        }
        
        Opportunity opportunityRecord = [SELECT Id, Account.Territory__c, Opportunity_Deal_Year__c,
                                         Business_Type__c, Renewal_Opportunity__c, Renewal_Date__c,
                                         Sales_Price_in_USD__c, Original_Opportunity__c, 
                                         Original_Opportunity__r.Sales_Price_in_USD__c,
                                         Recurring_Products_value__c, Previous_Price__c
                                         FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        Id territoryId = opportunityRecord.Account.Territory__c;
        String soql = 'SELECT Id ';
                for (String fieldApi : approvalFields) {
                    soql += ', ' + fieldApi;
                    soql += ', ' + fieldApi.replace('__c','__r.Username');
                    soql += ', ' + fieldApi.replace('__c','__r.Name');
                }
                soql += ' FROM Territory__c WHERE Id = :territoryId LIMIT 1';
         System.debug('soql '+ soql);       
                list<Territory__c> territoryData = Database.query(soql);
                SObject territory = territoryData[0];
        
        Boolean doNotSendApprovalToCRO = false;
        Boolean sendApprovalOnlyToCRO = false;
        
        if(opportunityRecord.Opportunity_Deal_Year__c == 1
          && opportunityRecord.Business_Type__c == 'Renewal'
          && opportunityRecord.Renewal_Opportunity__c == true
          && opportunityRecord.Renewal_Date__c != null
		  && opportunityRecord.Recurring_Products_value__c >= 100001
		  && opportunityRecord.Recurring_Products_value__c <= 300000
          ){
              Decimal originalACV = opportunityRecord.Previous_Price__c;
              Decimal renewalACV = opportunityRecord.Recurring_Products_value__c;
              Decimal calculateDecrease = ((originalACV - renewalACV)/originalACV) * 100;
              if(calculateDecrease <= 15){
                  doNotSendApprovalToCRO = true;
              }
			  if(calculateDecrease > 15){
                  sendApprovalOnlyToCRO = true;
              }
        }
        
        for (String fieldApi : currentApprovers){
            String relationshipName = fieldApi.replace('__c','__r');
            SObject userObj = territory.getSObject(relationshipName);
            if (userObj != null) {
                String username = (String) userObj.get('Username');
                System.debug('username '+ username);
                if(fieldApi.trim().toLowerCase().contains('commercial_leader_primary')){
                    output.leader1 = username;
                    output.CommercialDirector = null;
                }
                if(fieldApi.trim().toLowerCase().contains('commercial_leader_secondary')){
                    output.leader2 = username;
                    output.CommercialDirector = null;
                } 
                if(fieldApi.trim().toLowerCase().contains('commercial_director')){
                    output.CommercialDirector = username;
                }
                if (fieldApi.trim().toLowerCase().contains('fbp_team')) {
                    output.FBPTeam = username;
                }
                if (!sendApprovalOnlyToCRO && fieldApi.trim().toLowerCase().contains('fbp_director')) {
                //if(fieldApi.trim().toLowerCase().contains('fbp_director')) {
                    output.FBPDirector = username;
                }
                if (!doNotSendApprovalToCRO && fieldApi.trim().toLowerCase().contains('cro')) {
                //if(fieldApi.trim().toLowerCase().contains('cro')) {
                    output.CRO = username;
                }
                if (!sendApprovalOnlyToCRO && fieldApi.trim().toLowerCase().contains('md')) {
                //if (fieldApi.trim().toLowerCase().contains('md')) {
                    output.MD = username;
                }
            }
        }
        
        for (String fieldApi : escalationLevel1Approvers){
            String relationshipName = fieldApi.replace('__c','__r');
            SObject userObj = territory.getSObject(relationshipName);
            if (userObj != null) {
                String username = (String) userObj.get('Username');
                System.debug('username '+ username);
                if(output.escalationLevel1Approver1 == null){
                 	output.escalationLevel1Approver1 = username;   
                }else{
                    output.escalationLevel1Approver2 = username;   
                }
            }
        }
        
        for (String fieldApi : escalationLevel2Approvers){
            String relationshipName = fieldApi.replace('__c','__r');
            SObject userObj = territory.getSObject(relationshipName);
            if (userObj != null) {
                String username = (String) userObj.get('Username');
                System.debug('username '+ username);
                if(output.escalationLevel2Approver1 == null){
                 	output.escalationLevel2Approver1 = username;   
                }else{
                    output.escalationLevel2Approver2 = username;   
                }
            }
        }

        for (String fieldApi : priorApprovers){
            String relationshipName = fieldApi.replace('__c','__r');
            SObject userObj = territory.getSObject(relationshipName);
            if (userObj != null) {
                String fullname = (String) userObj.get('Name');
                System.debug('fullname '+ fullname);
                if(output.priorApproverForEmailBody == null){
                 	output.priorApproverForEmailBody = fullname;   
                }else{
                    output.priorApproverForEmailBody = output.priorApproverForEmailBody + ', ' + fullname;   
                }
            }
        }
        results.add(output);
        return results;
    }

    // INPUT
    public class InputWrapper {
		    
        @InvocableVariable(required=true)
        public Id recordId;

        @InvocableVariable(required=true)
        public String originalApprovers;
        
        @InvocableVariable(required=true)
        public String discountApprovalStatus;

        @InvocableVariable(required=false)
        public String escalationLevel1Approvers;

        @InvocableVariable(required=false)
        public String escalationLevel2Approvers;
    }


    // OUTPUT
    public class OutputWrapper {
	
        // Normal approval outputs
        @InvocableVariable
        public String CommercialDirector;

        @InvocableVariable
        public String FBPTeam;

        @InvocableVariable
        public String FBPDirector;

        @InvocableVariable
        public String CRO;

        @InvocableVariable
        public String MD;
        
        @InvocableVariable
        public String leader1;

        @InvocableVariable
        public String leader2;

        // Escalation outputs
        @InvocableVariable
        public String escalationLevel1Approver1;

        @InvocableVariable
        public String escalationLevel1Approver2;
        
        @InvocableVariable
        public String escalationLevel2Approver1;

        @InvocableVariable
        public String escalationLevel2Approver2;

        @InvocableVariable
        public list<String> currentApproverList;

        @InvocableVariable
        public list<String> priorApproverList;

        @InvocableVariable
        public list<String> priorToPriorApproverList;

        @InvocableVariable
        public String priorApproverForEmailBody;
    }
}
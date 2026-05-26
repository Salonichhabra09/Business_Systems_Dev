public class CreateVariation_LEX {
    @AuraEnabled  
    public static Opportunity getOppDetails(Id recordId, Id AccId){
        Opportunity opp = [select Id,Name,CampaignId,Amount,StageName,Primary_Contact__c,Billing_Contact__c,Business_Type__c,RecordType.Name,AccountId, 
                           Original_Opportunity__c,Total_Sales_Price__c,Order_Status__c,Variation_Opportunity__c,Renewal_Date__c,
                           Proposition_Detail__c,TM_Phase__c,Talent_Segment__c,Forecast_Category__c,
                           Lead_Stage__c,Marketing_Attribution__c,
                           last_Forecast_category_field_change__c,Probability,
                           Package_Level__c,Opportunity_Nickname__c,Days_remaining_from_annual_subscription__c,
                           Legal_Owner__c,Cross_Border_Opportunity__c,User__c,User_2__c,Integrated_Solution__c,Transition_related__c,
                           Closed_Lost_Reason__c,
                           Primary_Contact__r.Contact_Status__c ,Billing_Contact__r.Contact_Status__c,//Changes done as a part of SSE-16097
                          // Competitor__c,Opportunity_Lost_To__c,(Changes done as a part of SSE-16097)
                           Reasons_for_lost_Opportunity__c,Is_Subsrciption__c,MS_opportunity__c,Previous_Record_Type__c,GCSC__c,
                           Earliest_Start_Date__c,Earliest_Start_Date_Plus_Leap_Year__c,Central_PS_Attributed_to__c,NextStep,
                           Includes_Managed_Services__c,Includes_Multimedia_Services__c,Includes_Central_Professional_Services__c,
                           Won_LossReason_Influencer__c,Won_Loss_Explanation__c,Competitor_winner__c,Content_Groups__c,MMS_Next_Step_Due_Date__c,
                           Project_Manager__c,MMS_Next__c,Lead_Consultant__c,MMS_Next_Step_Description__c,Non_Standard_T_s_C_s__c,Challenger_opportunity__c,RFP_Status__c,ReasonforlostOpportunity__c,Offering__c,Client_Business_Function__c,Proposition__c,Talent_Level__c,
                           ContractId, Contract.Contract_End_Date__c, Contract.StartDate, Opportunity_Deal_Year__c, Target_Program__c
                           from Opportunity Where Id = :recordId limit 1];   // SSE-10872
        return opp ;
    }
    
    @AuraEnabled
    public static List<RecordType> getRecordList() {
        
        List<RecordType> L = new List<RecordType>();
        //L= [SELECT SobjectType, Id, Name FROM RecordType where (SobjectType= 'Opportunity' AND RecordType.Name!= 'GCSC Opportunity') ];
        L= [SELECT SobjectType, Id, Name FROM RecordType where (SobjectType= 'Opportunity') ];
        return L;
    }   
    
    @AuraEnabled
    public static list<Opportunity> getOpportunityList(Id contractId){
        list<Opportunity> oppList = new list<Opportunity>();
        oppList = [SELECT Id, Name, Opportunity_Deal_Year__c, ContractId, Contract.StartDate, Contract.Contract_End_Date__c 
                   FROM Opportunity 
                   WHERE ContractId = :contractId Order By Opportunity_Deal_Year__c];
        return oppList;
    }
    
}
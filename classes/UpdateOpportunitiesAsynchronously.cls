public without sharing class UpdateOpportunitiesAsynchronously {
    
    @InvocableMethod
    public static void updateOpportunities(List<InputValues> inputValuesList){
        Boolean updateFlag = false;
        List<Opportunity> finalOppListToUpdate = new List<Opportunity>();
        List<Opportunity> oppList = inputValuesList.get(0).opportunityListToUpdate;
        String closedLostOppId = inputValuesList.get(0).closedLostOpportunityIdToUpdate;
        Boolean clonePlaceholderOpportunityFlag = inputValuesList.get(0).clonePlaceholderOpportunity;
        Opportunity openOpp = inputValuesList.get(0).openPlaceholderInCaseOfOrderActivation;
        if(!oppList.isEmpty()){
            finalOppListToUpdate.addAll(oppList);
            if(openOpp != null){
                Integer indexToRemove = finalOppListToUpdate.indexOf(openOpp);
            	finalOppListToUpdate.remove(indexToRemove);
                openOpp.AutomationBypassDateTime__c = System.now();
                finalOppListToUpdate.add(openOpp);
            }
            if(closedLostOppId != null){
                list<Opportunity> closedLostOpportunityData = [SELECT Id, FormalTender__c, Skip_Validation_Auto_Renewal__c FROM Opportunity WHERE Id = :closedLostOppId AND StageName = 'Closed Lost' LIMIT 1];
                if(closedLostOpportunityData.size() > 0){
                    if(closedLostOpportunityData[0].Skip_Validation_Auto_Renewal__c){
                        closedLostOpportunityData[0].Skip_Validation_Auto_Renewal__c = false;
                        updateFlag = true;
                    }
                    if(clonePlaceholderOpportunityFlag){
                        closedLostOpportunityData[0].FormalTender__c = 'Renewal Created';
                        updateFlag = true;
                    }
                    if(updateFlag){
                        finalOppListToUpdate.addAll(closedLostOpportunityData);
                    }
                }
            }
        }
        if(finalOppListToUpdate.size() > 0){
            UPDATE finalOppListToUpdate;
        }
    }
    
    public class InputValues{
        @invocableVariable
        public List<Opportunity> opportunityListToUpdate;
        
        @invocableVariable
        public String closedLostOpportunityIdToUpdate;
        
        @invocableVariable
        public Boolean clonePlaceholderOpportunity;
        
        @invocableVariable
        public Opportunity openPlaceholderInCaseOfOrderActivation;
    }
}
public class EndOfLifeProducts {
    @AuraEnabled
    public static Boolean existEOFProducts(String recordId, String objectName){
        Boolean hasEOFProducts = false;
        
        hasEOFProducts = recordHasEOFProducts(recordId, objectName);

        return hasEOFProducts;
    }
    
    private static Boolean recordHasEOFProducts(String recordId, String objectName){
        Boolean hasEOFProducts = false;
        List<Opportunity> recordList = new List<Opportunity>();
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GCSC Opportunity').getRecordTypeId();
        
        if(objectName == 'Account'){
			recordList = [SELECT Id, (Select Id 
                                      From OpportunityLineItems
                                      Where Status__c = 'End of Life') 
                          From Opportunity 
                          Where AccountId =: recordId 
                          AND Opportunity_Deal_Year__c = 1 
                          AND Business_Type__c = 'Renewal'
                          AND (
                              (RecordTypeId =: recTypeId 
                               AND StageName != 'Closed Lost') 
                              OR 
                               (RecordTypeId !=: recTypeId 
                               //AND StageName != 'Verbal' 
                               AND StageName != 'Closed/Won' 
                               AND StageName != 'Closed Lost') 
                          )
                         ];
        }
        if(objectName == 'Opportunity'){
			recordList = [SELECT Id, (Select Id 
                                      From OpportunityLineItems
                                      Where Status__c = 'End of Life') 
                          From Opportunity 
                          Where Id =: recordId
                          AND Opportunity_Deal_Year__c = 1
                          AND (
                              (RecordTypeId =: recTypeId 
                               AND StageName != 'Closed Lost') 
                              OR 
                               (RecordTypeId !=: recTypeId 
                               //AND StageName != 'Verbal' 
                               AND StageName != 'Closed/Won' 
                               AND StageName != 'Closed Lost') 
                          ) AND Variation_Reason__c != 'Debooking'
                         ];
        }
		System.debug('recordList --' + recordList);
        if(recordList.size() > 0) {
            for(Opportunity opp : recordList){
                oliList = opp.OpportunityLineItems;
                if(oliList.size() > 0) {
                    hasEOFProducts = true;
                }                
            }
        }
        
        return hasEOFProducts;
    }
    
    
}
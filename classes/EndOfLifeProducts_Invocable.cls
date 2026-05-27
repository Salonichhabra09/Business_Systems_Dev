public class EndOfLifeProducts_Invocable {
	
    @InvocableMethod
    public static List<OutputValues> existEOFProducts(List<InputValues> inputValuesList){
        Boolean hasEOFProducts = false;
        
        String recordId = inputValuesList.get(0).recordId; 
        String objectName = inputValuesList.get(0).objectName;
        
        hasEOFProducts = recordHasEOFProducts(recordId, objectName);
        
        OutputValues outputValues = new OutputValues(); 
        outputValues.oppHasEOFProducts = hasEOFProducts;
        List<OutputValues> outputValuesList = new List<OutputValues>();
        outputValuesList.add(outputValues);
        
        return outputValuesList;
    }
    
    private static Boolean recordHasEOFProducts(String recordId, String objectName){
        Boolean hasEOFProducts = false;
        List<Opportunity> recordList = new List<Opportunity>();
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

			recordList = [SELECT Id, (Select Id 
                                      From OpportunityLineItems
                                      Where Status__c = 'End of Life') 
                          From Opportunity 
                          Where Id =: recordId
                         ];

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

    public class InputValues{
        @invocableVariable
        public String recordId;  
        
        @invocableVariable
        public String objectName;
    }
    
    public class OutputValues{
        @invocableVariable
        public Boolean oppHasEOFProducts;
    }
}
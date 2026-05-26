public class Opportunity_RecordType_change {
    @InvocableMethod
    public static List<OutputValues> createProducts_On_OppRecordTypeChange( List<InputValues> inputValuesList ){
        List<Future_Product__c> futureProductsList = inputValuesList.get(0).FutureProducts;
        List<OpportunityLineItem> opportunityProducts = inputValuesList.get(0).OpportunityProducts;

        List<Future_Product__c> futureProductsList_To_Update = new List<Future_Product__c>();
        
        OutputValues outputValues = new OutputValues();
        outputValues.FutureProductsUpdated = futureProductsList_To_Update;
        List<OutputValues> outputValuesList = new List<OutputValues>();
        outputValuesList.add(outputValues); 
        
        if(futureProductsList != null && !futureProductsList.isEmpty()){
            
            for(Future_Product__c futureProd : futureProductsList ){
                System.debug('futureProd.Product__r.Id  --->' + futureProd.Product__r.Id );
                
                if(futureProd.Opportunity_Product_Id__c == null){
                    if(opportunityProducts != null ){
                        for(OpportunityLineItem oppProd: opportunityProducts){
                            System.debug('oppProd.Product2.Id   --->' + oppProd.Product2.Id );
                            /*if(futureProd.Product__r.Id == oppProd.Product2.Id 
                               && futureProd.Add_On__c == oppProd.Add_On__c 
                               && futureProd.Basis_of_Fees__c == oppProd.Basis_of_Fees__c 
                               && futureProd.ListPrice__c == oppProd.List_Price__c
                               && futureProd.Package__c == oppProd.Package__c 
                               && futureProd.Platform__c == oppProd.Platform__c 
                               && futureProd.Quantity__c == oppProd.Quantity 
                               && futureProd.Sales_Price__c == oppProd.UnitPrice 
                               && futureProd.Solution_Cap__c == oppProd.Solution_Cap__c 
                               && futureProd.Usage_Allowance__c == oppProd.Usage_Allowance__c 
                               && futureProd.Usage_Cap_or_Estimation__c == oppProd.Usage_Cap_or_Estimation__c 
                               && futureProd.Opportunity_Product_Id__c == null) {
                                   
                                futureProd.Opportunity_Product_Id__c = oppProd.Id;
                                
                            } else if (futureProd.Product__r.Id == oppProd.Product2.Id 
                                       && futureProd.Add_On__c == oppProd.Add_On__c 
                                       && futureProd.Basis_of_Fees__c == oppProd.Basis_of_Fees__c 
                                       && futureProd.Package__c == oppProd.Package__c 
                                       && futureProd.Platform__c == oppProd.Platform__c  
                                       && futureProd.Solution_Cap__c == oppProd.Solution_Cap__c
                                       && futureProd.Usage_Allowance__c == oppProd.Usage_Allowance__c 
                                       && futureProd.Usage_Cap_or_Estimation__c == oppProd.Usage_Cap_or_Estimation__c  
                                       && ( futureProd.ListPrice__c == oppProd.List_Price__c
                                       || futureProd.Sales_Price__c == oppProd.UnitPrice       
                                       || futureProd.Quantity__c == oppProd.Quantity )
                                       && futureProd.Opportunity_Product_Id__c == null) {
                                   
                                futureProd.Opportunity_Product_Id__c = oppProd.Id;
                                   
                            } else */ 
                            if (futureProd.Product__r.Id == oppProd.Product2.Id ) {
                                           
                                futureProd.Opportunity_Product_Id__c = oppProd.Id;
                            }
                        }
                        futureProductsList_To_Update.add(futureProd);
                    }
                }
            }
            
            if(!futureProductsList_To_Update.isEmpty()){
                update futureProductsList_To_Update;
            }
        }
        return outputValuesList;
    }
    
    public class InputValues{
        @invocableVariable
        public List<Future_Product__c> FutureProducts;
        
        @invocableVariable
        public List<OpportunityLineItem> OpportunityProducts;
        
    }
    
    public class OutputValues{
        @invocableVariable
        public List<Future_Product__c> FutureProductsUpdated;
    }
}
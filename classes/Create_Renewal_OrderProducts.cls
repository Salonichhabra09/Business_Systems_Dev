public class Create_Renewal_OrderProducts {
    @InvocableMethod
    public static List<OutputValues> create_OrderProducts( List<InputValues> inputValuesList ){

		List<OpportunityLineItem> oppLineItemList_Original = inputValuesList.get(0).OpportunityLineItemList_Original;        
        List<OutputValues> outputsList = new List<OutputValues>();
        OutputValues output = new OutputValues();
        
        if(!oppLineItemList_Original.isEmpty()){
            
            List<OrderItem> orderItemList_to_Create = new List<OrderItem>();
            String orderYear = inputValuesList.get(0).OrderYear;
            String createdRenewalOrderId = inputValuesList.get(0).CreatedRenewalOrderId;
            
            for(OpportunityLineItem oli : oppLineItemList_Original){
                if(oli.Contract_Year__c == orderYear){
                    OrderItem oItem = new OrderITem(Basis_of_Fees__c = oli.Basis_of_Fees__c,
                                                    Description = oli.Description, 
                                                    Package__c = oli.Package__c, 
                                                    List_Price__c = oli.List_Price__c, 
                                                    Platform__c = oli.Platform__c,
                                                    PricebookEntryId = oli.PricebookEntryId, 
                                                    Product2Id = oli.Product2Id, 
                                                    Proposition__c = oli.Proposition__c,
                                                    UnitPrice = oli.UnitPrice,
                                                    Quantity = oli.Quantity,
                                                    Usage_Allowance__c = oli.Usage_Allowance__c, 
                                                    //Usage_Cap_or_Estimation__c = oli.Total_Equivalent_Units__c,
                                                    Total_Equivalent_Units__c = oli.Total_Equivalent_Units__c, // Change added by Priyank (SSE-22491)
                                                    OrderId = createdRenewalOrderId, 
                                                    Renewable__c = oli.RenewableNew__c,
                                                    Service_End_Date__c = oli.Service_End_Date__c, 
                                                    Opportunity_Product_Id__c = oli.Id, 
                                                    //Changes added by Prachi (SSE-17449)
                                                    Number_of_Services__c = oli.Number_of_Services__c,
                                                  	//Changes End Prachi (SSE-17449)
                                                  	Solution__c = oli.Solution__c,//Change added by Joana (SSE-16464)
                                                    Solution_Cap__c = oli.Solution_Cap__c);
                    orderItemList_to_Create.add(oItem);
                }
            }
            if(!orderItemList_to_Create.isEmpty()){
                try{
                    output.ResultMessage = 'SUCCESS';
                   	insert orderItemList_to_Create;                 	
                } catch (Exception e){
                    output.ResultMessage = 'ERROR: ' + e.getMessage();
                }
                
            } else {
                output.ResultMessage = 'ERROR: No Order Products to insert';
            }

        } else {
            output.ResultMessage = 'ERROR: No Opportunity Products';
        }
        outputsList.add(output);
        return outputsList;
    }
    
    public class InputValues{

        @invocableVariable
        public List<OpportunityLineItem> OpportunityLineItemList_Original;
        
        @invocableVariable
        public String OrderYear;  
        
        @invocableVariable
        public String CreatedRenewalOrderId;  
    }
    
    public class OutputValues{

        @invocableVariable
        public String ResultMessage;
 
    }
}
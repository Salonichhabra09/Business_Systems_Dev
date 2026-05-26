public class Add_PriceBookEntryId_To_OppProduct {
    @InvocableMethod
    public static void matchPriceBookId_with_OpportunityProduct( List<InputValues> inputValuesList ){
      
        List<OpportunityLineItem> oppLineItemList = inputValuesList.get(0).OpportunityProductList_ToCreate;
         //logic added by Prabhat to correct the Solution Cap--Starts-->
        OpportunityLineItemTriggerManager1.handleSolCapBeforeInsert(oppLineItemList);
        //logic added by Prabhat to correct the Solution Cap--Ends-->
        
        
        if(!oppLineItemList.isEmpty()){
            List<OpportunityLineItem> oppLineItemList_Original = inputValuesList.get(0).OpportunityProductList_Original;
            string currencyIsoCode = inputValuesList.get(0).CurrencyIsoCode;
            string pricebook2Id = inputValuesList.get(0).Pricebook2Id;
            Set<Id> product2Id_Set = new Set<Id>();
            
            for(integer i = 0; i<oppLineItemList_Original.size(); i++){
                product2Id_Set.add(oppLineItemList_Original[i].Product2Id);
            }
            
            List<PriceBookEntry> priceBookEntryList = [SELECT id, Product2Id
                                                       From PriceBookEntry 
                                                       Where IsActive = true 
                                                       AND CurrencyIsoCode =: currencyIsoCode 
                                                       AND Pricebook2Id =: pricebook2Id
                                                       AND Product2Id IN: product2Id_Set];
                
            if(!priceBookEntryList.isEmpty()){

                map<Id,Id> product2Id_priceBookEntry_Map = new map<Id,Id>();
                for(integer i = 0; i<priceBookEntryList.size(); i++){
                    product2Id_priceBookEntry_Map.put(priceBookEntryList[i].Product2Id,priceBookEntryList[i].Id );
                }
                
                
                for(integer i = 0; i<oppLineItemList.size(); i++){   
                    oppLineItemList[i].PricebookEntryId = product2Id_priceBookEntry_Map.get(oppLineItemList[i].Product2Id);
                }
                
                insert oppLineItemList;
            }
        }
        
    }
    
    public class InputValues{
        @invocableVariable
        public List<OpportunityLineItem> OpportunityProductList_ToCreate;
        
        @invocableVariable
        public List<OpportunityLineItem> OpportunityProductList_Original;
        
        @invocableVariable
        public String CurrencyIsoCode;  
        
        @invocableVariable
        public String PriceBook2Id;  
    }
}
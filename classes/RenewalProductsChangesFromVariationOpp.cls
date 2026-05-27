public class RenewalProductsChangesFromVariationOpp {
    public static OpportunityLineItem lineItemToAdd = new OpportunityLineItem();
    
    @InvocableMethod
    public static void syncVariationProductsOnPlaceholderOpp(List<InputValues> inputValuesList){
        
        list<String> uniqueKeyList = new list<String>();
        list<String> variationIdsList = new list<String>();
        list<Opportunity> placeholderOppList = new list<Opportunity>();
        list<Opportunity> opportunityRecordsList = new list<Opportunity>();
        list<Opportunity> variationOppsToUpdate = new list<Opportunity>();
        list<OpportunityLineItem> variationLineItemsList = new list<OpportunityLineItem>();
        list<OpportunityLineItem> placeholderLineItemsList = new list<OpportunityLineItem>();
        list<OpportunityLineItem> uniquePlaceholderLineItemList = new list<OpportunityLineItem>();
        list<OpportunityLineItem> newProductToInsert = new list<OpportunityLineItem>();
        List<OpportunityLineItem> combinedLineItemsList = new List<OpportunityLineItem>();
        
        Boolean newProductFound;
        String placeholderId;
        String uniqueKey;
        Double increaseSalesPrice;
        
        opportunityRecordsList = inputValuesList.get(0).opportunityData;
        variationLineItemsList = inputValuesList.get(0).variationOLIData;
        
        if(!opportunityRecordsList.isEmpty()){
            
            /*for(Opportunity opp : opportunityRecordsList){
variationIdsList.add(opp.Id);
}*/
            
            placeholderOppList = [SELECT Id, Price_Increase_Percentage__c FROM Opportunity WHERE Original_Opportunity__c = :opportunityRecordsList[0].Original_Opportunity__c 
                                  AND Business_Type__c = 'Renewal'
                                  AND StageName != 'Closed/Won'
                                  AND StageName != 'Closed Lost'
                                  AND ContractId = null];
            placeholderId = placeholderOppList[0].Id;
        }
        
        if(!placeholderOppList.isEmpty()){
            //Get Variation Products
            /*
variationLineItemsList = [SELECT Id, OpportunityId, SortOrder, PricebookEntryId, Product2Id, ProductCode, Name, CurrencyIsoCode, Quantity, Discount, Subtotal, TotalPrice, 
UnitPrice, ListPrice, ServiceDate, HasRevenueSchedule, HasQuantitySchedule, Description, HasSchedule, CanUseQuantitySchedule, CanUseRevenueSchedule, Invoice_Date__c, 
Unit_Price__c, Duration_Day_Amount__c, Duration_Days__c, End_Date__c, Start_Date__c, Product_Name__c, MS_Product__c, Basis_of_Fees__c, Other__c, 
Platform__c, Related_Product__c, Usage_Allowance__c, Usage_Cap_or_Estimation__c, Renewable__c, Auto_Renewable__c, List_Price__c, 
Total_List_Price__c, Delete_Required__c, Hiring_Need__c, Imported_from_Rate_Card_c__c, Level__c, Package_Level__c, Talent_Level__c, 
Total_Discount__c, Volume__c, Year_1_Discount__c, Year_1_List_Price__c, Year_1_Sales_Price__c, Year_2_Discount__c, Year_2_List_Price__c, 
Year_2_Sales_Price__c, Year_3_Discount__c, Year_3_List_Price__c, Year_3_Sales_Price__c, Proposition__c, Package__c, Add_On__c, Booking_Type__c, 
Contract_Value__c, Contract_Year__c, RenewableNew__c, Subscription_Category__c, CurrencyChange__c, Order_Form_Category__c, Service_End_Date__c, 
Solution_Cap__c, Total_Equivalent_Units__c, Configurator_sales_price__c, Product_Services_Stream__c, Client_Friendly_Name__c, ProductMasterFamily__c,
Product_Family__c, Auto_created_with_Renewal__c, Opportunity_Product_ID18__c, Status__c, Number_of_Services__c, RAG_Option_Value__c, Solution__c, 
RAG_Indicator__c, Is_MS_Product__c, Item_Added_From__c, Product_Stream__c, In_Advance__c FROM OpportunityLineItem WHERE OpportunityId IN :variationIdsList];
*/
            //variationLineItemsList = [SELECT Id, UnitPrice, Product2Id, Package__c, TotalPrice, Quantity, RenewableNew__c, Item_Added_From__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :variationIdsList];
            
            //Get Renewal Products
            placeholderLineItemsList = [SELECT Id, UnitPrice, Product2Id, Package__c, TotalPrice, Quantity, RenewableNew__c, OpportunityId, Solution_Cap__c  FROM OpportunityLineItem WHERE OpportunityId = :placeholderId];
        }
        
        if(!placeholderLineItemsList.isEmpty()){
            for(OpportunityLineItem oppLine : placeholderLineItemsList){
                uniqueKey = oppLine.Product2Id + oppLine.Package__c;
                if(!uniqueKeyList.contains(uniqueKey)){
                    uniqueKeyList.add(uniqueKey);
                    //Add Unique Line Items
                    uniquePlaceholderLineItemList.add(oppLine);
                }
            }
        }
        
        if(!variationLineItemsList.isEmpty()){
            //Loop on Variation Products
            for(OpportunityLineItem variationLine : variationLineItemsList){
                if(placeholderOppList[0].Price_Increase_Percentage__c != null){
                    increaseSalesPrice = variationLine.UnitPrice + ((placeholderOppList[0].Price_Increase_Percentage__c * variationLine.UnitPrice)/100);
                }else{
                    increaseSalesPrice = variationLine.UnitPrice;
                }
                
                newProductFound = true;
                //Loop on Placeholder Products
                for(OpportunityLineItem oppLine : uniquePlaceholderLineItemList){
                    if(variationLine.Product2Id == oppLine.Product2Id 
                       && variationLine.Package__c == oppLine.Package__c){
                           newProductFound = false;
                           //New Similar Product Assignment
                           addLineItem(variationLine, placeholderId, increaseSalesPrice);
                           newProductToInsert.add(lineItemToAdd);
                       }
                }    
                if(newProductFound){
                    if(variationLine.RenewableNew__c == 'Ongoing'){
                        //New Ongoing Product Assignment
                        addLineItem(variationLine, placeholderId, increaseSalesPrice);
                        newProductToInsert.add(lineItemToAdd);
                    }
                }
            }
        }
        
        // Combine newProductToInsert and placeholderLineItemsList
        if(!newProductToInsert.isEmpty()){
            combinedLineItemsList.addAll(newProductToInsert);   
        }
        combinedLineItemsList.addAll(placeholderLineItemsList);
        //System.debug('combinedLineItemsList size'+ combinedLineItemsList.size());
        
        if (!combinedLineItemsList.isEmpty()) {
            List<OpportunityLineItem> processedLineItems = OpportunityLineItemTriggerManager1.handleSolCapBeforeInsert(combinedLineItemsList);
            system.debug('this is in finalList'+processedLineItems.size());
            
            for(OpportunityLineItem oli : processedLineItems){
                if(oli.Id == null){
                    oli.OpportunityId = placeholderId;
                }
            }
            upsert processedLineItems;
        }
        
        for(Opportunity opp : opportunityRecordsList){
            if(opp.Business_Type__c != 'Extension'){
                //Mark Variation Oppty as Synced
                opp.FormalTender__c = 'Synced Variation';
                variationOppsToUpdate.add(opp);
            }
        }
        
        if(!variationOppsToUpdate.isEmpty()){
            UPDATE variationOppsToUpdate;
        }
        
    }
    
    public static void addLineItem(OpportunityLineItem vL, String placeholderId, Double increaseSalesPrice){
        
        lineItemToAdd = vL;
        lineItemToAdd.Id = null;
        //lineItemToAdd.OpportunityId = placeholderId;
        lineItemToAdd.UnitPrice = increaseSalesPrice;
        lineItemToAdd.TotalPrice = null;
        lineItemToAdd.Item_Added_From__c = 'Variation';
    }
    
    public class InputValues{
        @invocableVariable
        public list<Opportunity> opportunityData;
        @invocableVariable
        public list<OpportunityLineItem> variationOLIData;
        
    }
}
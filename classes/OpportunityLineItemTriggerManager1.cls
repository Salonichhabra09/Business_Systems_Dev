//******************************
// CREATED BY :- Prabhat Arora
// CREATED DATE :- 15-06-2024
//******************************

Global class OpportunityLineItemTriggerManager1 {
    public static void UpdateCLMLineInfoOnOpp(List<OpportunityLineItem> OLIs, Map<Id, OpportunityLineItem> oldMap) {
        // Set to collect Opportunity IDs that need updating
        Set<Id> opportunityIds = new Set<Id>();
        
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (OpportunityLineItem oli : OLIs) {
                // Always add IDs for inserts
                if (Trigger.isInsert) {
                    opportunityIds.add(oli.OpportunityId);
                }
                // For updates, only add IDs if relevant fields have changed
                if (Trigger.isUpdate) {
                    OpportunityLineItem oldOli = oldMap.get(oli.Id);
                    if (oli.Product_Family__c != oldOli.Product_Family__c
                        || oli.Product_Stream__c != oldOli.Product_Stream__c
                        || oli.SOW_Required__c != oldOli.SOW_Required__c) {
                            opportunityIds.add(oli.OpportunityId);
                        }
                }
            }
            
        } else if (Trigger.isDelete) {
            for (OpportunityLineItem oli : OLIs) {
                opportunityIds.add(oli.OpportunityId);
            }
        }
        
        // Check if there are any Opportunity IDs to process
        if (!opportunityIds.isEmpty()) {
            // Map to hold opportunities that need updating
            Map<Id, Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
            
            // Query Opportunities and their existing CLM_Line_Information__c values
            List<Opportunity> oppList = [
                SELECT Id, CLM_Line_Information__c,
                (SELECT Product_Family__c, Product_Stream__c,
                 SOW_Required__c FROM OpportunityLineItems) FROM Opportunity WHERE Id IN : opportunityIds
            ];
            
            // Process each Opportunity
            for (Opportunity opp : oppList) {
                Set<String> clmInfoSet = new Set<String>();
                /*if (opp.CLM_Line_Information__c != null) {
clmInfoSet.addAll(opp.CLM_Line_Information__c.split(';'));
}*/
                
                // Check each OpportunityLineItem for the conditions
                for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                    if (oli.Product_Family__c != null) {
                        if (oli.Product_Family__c.contains('Product') || oli.Product_Family__c.contains('Other')
                            || oli.Product_Family__c.contains('Experiences') || oli.Product_Family__c.contains('Insights')
                            || oli.Product_Family__c.contains('Ancillary')) {
                                clmInfoSet.add('Includes Product');
                            }
                        if (oli.Product_Family__c.contains('Services')) {
                            clmInfoSet.add('Includes Service');
                        }
                    }
                    if (oli.Product_Stream__c != null) {
                        if (oli.Product_Stream__c.contains('Product in advance')) {
                            clmInfoSet.add('Includes In Advance');
                        }
                        if (oli.Product_Stream__c.contains('Product in arrears')) {
                            clmInfoSet.add('Includes In Arrears');
                        }
                    }
                    if (oli.SOW_Required__c) {
                        clmInfoSet.add('SOW Required');
                    }
                }
                
                // Convert the set back to a semicolon-separated string
                String updatedCLMInfo = String.join(new List<String>(clmInfoSet), ';');
                
                // Prepare to update the CLM_Line_Information__c field if it has changed
                if (opp.CLM_Line_Information__c != updatedCLMInfo) {
                    Opportunity oppToUpdate = new Opportunity();
                    oppToUpdate.Id = opp.Id;
                    oppToUpdate.CLM_Line_Information__c = updatedCLMInfo;
                    opportunitiesToUpdate.put(opp.Id, oppToUpdate);
                }
            }
            
            // Perform the update if there are any Opportunities to update
            if (!opportunitiesToUpdate.isEmpty()) {
                try {
                    update opportunitiesToUpdate.values();
                } catch (DmlException e) {
                    // Handle DML exceptions
                    System.debug('An error occurred: ' + e.getMessage());
                }
            }
        }
    }
    
    // New logic to Solution Cap Correction Starts from here
    public static List<OpportunityLineItem> handleSolCapBeforeInsert(List<OpportunityLineItem> newLineItems) {
        return processOpportunityLineItems(newLineItems);
    }
    
    public static List<OpportunityLineItem> handleSolCapAfterDelete(List<OpportunityLineItem> newLineItems) {
        return processOpportunityLineItemsOnOrderCancellation(newLineItems);
    }
    
    private static List<OpportunityLineItem> processOpportunityLineItems(List<OpportunityLineItem> lineItems) {
        Map<Id, Map<String, Decimal>> oppPackageToMaxSolutionCapMap = new Map<Id, Map<String, Decimal>>();
        Map<String, Decimal> combinedPackageToSolutionCapMap = new Map<String, Decimal>();
        
        // Group the line items by Opportunity Id and Package and find max solution cap for each package within the same opportunity
        for (OpportunityLineItem oli : lineItems) {
            Id oppId = oli.OpportunityId;
            String packageValue = oli.Package__c;
            Decimal solutionCapValue = oli.Solution_Cap__c;
            
            if (packageValue != null && solutionCapValue != null) {
                if (!oppPackageToMaxSolutionCapMap.containsKey(oppId)) {
                    oppPackageToMaxSolutionCapMap.put(oppId, new Map<String, Decimal>());
                }
                
                Map<String, Decimal> packageToMaxSolutionCapMap = oppPackageToMaxSolutionCapMap.get(oppId);
                
                if (!packageToMaxSolutionCapMap.containsKey(packageValue)) {
                    packageToMaxSolutionCapMap.put(packageValue, solutionCapValue);
                } else {
                    packageToMaxSolutionCapMap.put(
                        packageValue, Math.max(packageToMaxSolutionCapMap.get(packageValue), solutionCapValue));
                }
            }
        }
        
        // Sum the maximum solution caps for the same package across different opportunities
        for (Id oppId : oppPackageToMaxSolutionCapMap.keySet()) {
            Map<String, Decimal> packageToMaxSolutionCapMap = oppPackageToMaxSolutionCapMap.get(oppId);
            
            for (String packageValue : packageToMaxSolutionCapMap.keySet()) {
                Decimal maxSolutionCap = packageToMaxSolutionCapMap.get(packageValue);
                
                if (!combinedPackageToSolutionCapMap.containsKey(packageValue)) {
                    combinedPackageToSolutionCapMap.put(packageValue, maxSolutionCap);
                } else {
                    combinedPackageToSolutionCapMap.put(
                        packageValue, combinedPackageToSolutionCapMap.get(packageValue) + maxSolutionCap);
                }
            }
        }
        
        // Apply the summed maximum Solution Cap value to each OpportunityLineItem
        for (OpportunityLineItem oli : lineItems) {
            String packageValue = oli.Package__c;
            
            if (packageValue != null && packageValue !='Product' && combinedPackageToSolutionCapMap.containsKey(packageValue)) {
                Decimal summedSolutionCap = combinedPackageToSolutionCapMap.get(packageValue);
                oli.Solution_Cap__c = summedSolutionCap;
            }
        }
        
        return lineItems;
    }
    
    private static List<OpportunityLineItem> processOpportunityLineItemsOnOrderCancellation(List<OpportunityLineItem> lineItems) {
        Map<Id, Map<String, Decimal>> oppPackageToMaxSolutionCapMap = new Map<Id, Map<String, Decimal>>();
        Map<String, Decimal> combinedPackageToSolutionCapMap = new Map<String, Decimal>();
        
        // Group the line items by Opportunity Id and Package and find max solution cap for each package within the same opportunity
        for (OpportunityLineItem oli : lineItems) {
            Id oppId = oli.OpportunityId;
            String packageValue = oli.Package__c;
            Decimal solutionCapValue = oli.Solution_Cap__c;
            
            if (packageValue != null && solutionCapValue != null) {
                if (!oppPackageToMaxSolutionCapMap.containsKey(oppId)) {
                    oppPackageToMaxSolutionCapMap.put(oppId, new Map<String, Decimal>());
                }
                
                Map<String, Decimal> packageToMaxSolutionCapMap = oppPackageToMaxSolutionCapMap.get(oppId);
                
                if (!packageToMaxSolutionCapMap.containsKey(packageValue)) {
                    packageToMaxSolutionCapMap.put(packageValue, solutionCapValue);
                } else {
                    packageToMaxSolutionCapMap.put(
                        packageValue, Math.max(packageToMaxSolutionCapMap.get(packageValue), solutionCapValue));
                }
            }
        }
        
        // Subtract the maximum solution caps for the same package across different opportunities
        for (Id oppId : oppPackageToMaxSolutionCapMap.keySet()) {
            System.debug('oppPackageToMaxSolutionCapMap '+ oppId);
            System.debug('oppPackageToMaxSolutionCapMap '+ oppPackageToMaxSolutionCapMap.get(oppId));
            Map<String, Decimal> packageToMaxSolutionCapMap = oppPackageToMaxSolutionCapMap.get(oppId);
            
            for (String packageValue : packageToMaxSolutionCapMap.keySet()) {
                System.debug('packageToMaxSolutionCapMap '+ packageValue);
            	System.debug('packageToMaxSolutionCapMap '+ packageToMaxSolutionCapMap.get(packageValue));
                Decimal maxSolutionCap = packageToMaxSolutionCapMap.get(packageValue);
                System.debug('packageToMaxSolutionCapMap maxSolutionCap '+ maxSolutionCap);
                if (!combinedPackageToSolutionCapMap.containsKey(packageValue)) {
                    combinedPackageToSolutionCapMap.put(packageValue, maxSolutionCap);
                } else {
                    Decimal solutionCap;
                    if(combinedPackageToSolutionCapMap.get(packageValue) > maxSolutionCap){
                        solutionCap = combinedPackageToSolutionCapMap.get(packageValue) - maxSolutionCap;
                    }else{
                        solutionCap = maxSolutionCap - combinedPackageToSolutionCapMap.get(packageValue);
                    }
                    combinedPackageToSolutionCapMap.put(packageValue, solutionCap);
                }
                System.debug('combinedPackageToSolutionCapMap '+ packageValue);
            	System.debug('combinedPackageToSolutionCapMap '+ combinedPackageToSolutionCapMap.get(packageValue));
            }
        }
        
        // Apply the summed maximum Solution Cap value to each OpportunityLineItem
        for (OpportunityLineItem oli : lineItems) {
            String packageValue = oli.Package__c;
            
            if (packageValue != null && packageValue !='Product' && combinedPackageToSolutionCapMap.containsKey(packageValue)) {
                Decimal summedSolutionCap = combinedPackageToSolutionCapMap.get(packageValue);
                oli.Solution_Cap__c = summedSolutionCap;
            }
        }
        
        return lineItems;
    }
    
    @InvocableMethod
    public static void SyncSolCapOnPlaceholderOpp(List<LineItemWrapper> lineItemWrappers){
        
        // Assuming only one wrapper is passed from the Flow
        LineItemWrapper wrapper = lineItemWrappers[0];
        //Id PHiD = wrapper.PlhId;
        String PhId;
        
        // Combine the variation and placeholder line items
        List<OpportunityLineItem> combinedLineItems = new List<OpportunityLineItem>();
        
        if(wrapper.VariationLineItems != null){ // Added
            for(OpportunityLineItem oli : wrapper.VariationLineItems){
                oli.Id = null;
            }   
                combinedLineItems.addAll(wrapper.VariationLineItems);   
        }
        
        combinedLineItems.addAll(wrapper.ExistingPHLineItems);
        
        List<OpportunityLineItem> processedLineItems = new List<OpportunityLineItem>();
        // Process the combined line items
        if(wrapper.isOrderCancelled){
            processedLineItems = handleSolCapAfterDelete(combinedLineItems);   
        }else{
         	processedLineItems = handleSolCapBeforeInsert(combinedLineItems);   
        }
        
        // Separate the processed line items back into variation and placeholder line items
        List<OpportunityLineItem> variationLineItemsToInsert = new List<OpportunityLineItem>();
        List<OpportunityLineItem> placeholderLineItemsToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> linesItemsToUpdate = new List<OpportunityLineItem>();
        
        for(OpportunityLineItem phli : wrapper.ExistingPHLineItems) {
            PhId = phli.OpportunityId;
        }
        
        if(wrapper.isOrderCancelled){
            for (OpportunityLineItem oli : processedLineItems) {
                if(oli.Id != null){
                    System.debug('final oli '+ oli.Solution_Cap__c);
                    linesItemsToUpdate.add(oli);
                }
            }  
        }
        else{
            for (OpportunityLineItem oli : processedLineItems) {
                if(oli.Id == null){
                    oli.OpportunityId = PhId;
                }
                linesItemsToUpdate.add(oli);
            }
        }
        
        upsert linesItemsToUpdate; 
    }    
    
    public class LineItemWrapper {
        @invocableVariable
        public list<OpportunityLineItem> VariationLineItems;
        @invocableVariable
        public list<OpportunityLineItem> ExistingPHLineItems;
        @invocableVariable
        public Boolean isOrderCancelled;
        
    }
}
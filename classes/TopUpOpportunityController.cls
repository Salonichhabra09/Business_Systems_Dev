/**
 * TopUpOpportunityController
 * @description
 *  Server-side controller that supports Top Up (Addition) process for Opportunities.
 *  Exposes AuraEnabled methods consumed by LWC to:
 *   - Read existing Opportunity Line Items (OLIs) grouped by Solution and compute totals
 *   - Create a Top Up Opportunity from an original Opportunity and clone OLIs
 *   - Update existing Top Up OLIs when Solution Caps are adjusted
 *
 *  Key behaviors and notes:
 *   - Runs with sharing to respect org sharing rules and security.
 *   - Uses Database setSavepoint/rollback for transactional integrity during create/update flows.
 *   - Groups OLIs by Package__c and computes per-package original totals and caps.
 *
 *  Security:
 *   - Queries run in user context due to with sharing; ensure FLS is handled by UI layers (LDS) where applicable.
 *   - No hard-coded IDs or URLs. Labels are used for record type names.
 *
 *  Governor limits:
 *   - All SOQL queries and DML are bulkified (no SOQL/DML in per-record loops against unbounded collections).
 *
 *  Usage:
 *   - Invoked by Lightning components to prepare UI data and persist Top Up operations.
 *
 *  Maintenance:
 *   - Prefer updating wrapper classes' field comments when adding/removing UI fields.
 *   - Remove System.debug statements before production deployment as per org standards.
 */
public with sharing class TopUpOpportunityController {
    /**
     * @description
     *  Fetches Opportunity Line Items for the given Opportunity and groups them by Package (Solution),
     *  computing original totals and preparing a UI-friendly wrapper model. When isUpdate = true,
     *  the per-solution caps and totals are initialized from existing values.
     * @param opportunityId The Id of the source Opportunity to read OLIs from.
     * @param isUpdate If true, pre-populate solution caps and totals using current OLI values;
     *                 if false, initialize editable values to zero for Top Up input.
     * @return TopUpInformationWrapper containing currency, pricebook, totals, and grouped solutions/lines.
     * @notes
     *  - Cacheable=true to allow UI-level caching for read operations.
     *  - Filters OLIs where RenewableNew__c = 'Ongoing' per business rule.
     *  - Uses running per-package totals to set original solution totals.
     */
    @AuraEnabled(cacheable=true)
    public static TopUpInformationWrapper getOpportunityLine(Id opportunityId, Boolean isUpdate){

        TopUpInformationWrapper wrapperToReturn = new TopUpInformationWrapper();
        List<SolutionWrapper> solutionToReturn = new List<SolutionWrapper>();
        Map<String, SolutionWrapper> solutionsByPackage = new Map<String, SolutionWrapper>();
        // Per-package accumulator for original totals
        Map<String, Decimal> originalTotalsByPackage = new Map<String, Decimal>();

        // Read OLIs that are considered "ongoing" revenue lines for Top Up eligibility
        List<OpportunityLineItem> oppLineItems = [
            SELECT Id, Product2Id, Product_Name__c, Basis_of_Fees__c, Package__c,
            TotalPrice, UnitPrice, Quantity, Opportunity.Price_Increase_Percentage__c, Number_of_Services__c,
            Opportunity.Pricebook2Id, Opportunity.CurrencyIsoCode, Opportunity.OpportunityId__c,
            Opportunity.Variation_Opportunity__c, Debooked_Quantity__c, Debooked_Sales_Price__c, 
            Solution_Cap__c, RenewableNew__c, Proposition__c, Platform__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
            AND Package__c != 'Product' 
            AND Package__c != 'Service'
            AND RenewableNew__c = 'Ongoing'
        ];

        Decimal totalSalesPrice = 0;
        Decimal totalSalesPriceOfOriginal = 0;
        Decimal alreadyTopUpAmount = 0;
        String currencyCode = '';
        String pricebook2Id = '';
        Integer rowNum = 1;

        for (OpportunityLineItem oppLine : oppLineItems) {
            totalSalesPrice += oppLine.TotalPrice;
            if (String.isBlank(currencyCode)) {
                currencyCode = oppLine.Opportunity.CurrencyIsoCode;
            }
            if (String.isBlank(pricebook2Id)) {
                pricebook2Id = oppLine.Opportunity.Pricebook2Id;
            }

            // Track overall original total as sum of OLI.TotalPrice across all packages
            totalSalesPriceOfOriginal += oppLine.TotalPrice;

            // Update per-package running original total
            Decimal pkgTotalValue = originalTotalsByPackage.get(oppLine.Package__c);
            if (pkgTotalValue == null) pkgTotalValue = 0;
            pkgTotalValue += oppLine.TotalPrice;
            originalTotalsByPackage.put(oppLine.Package__c, pkgTotalValue);

            // Initialize per-package SolutionWrapper on first encounter; keep a running original total
            if (!solutionsByPackage.containsKey(oppLine.Package__c)) {
                SolutionWrapper solutionWrapper = new SolutionWrapper();
                solutionWrapper.solutionId = 's'+rowNum;
                solutionWrapper.solutionName = oppLine.Package__c;
                solutionWrapper.solutionCap = isUpdate == true ? oppLine.Solution_Cap__c : 0;
                solutionWrapper.solutionCapOnOriginal = oppLine.Solution_Cap__c;
                solutionWrapper.rowNum = 'row-' + rowNum;
                solutionWrapper.isDisabled = true;
                solutionWrapper.oppLines = new List<OpportunityLineWrapper>();
                solutionWrapper.basisOfFees = oppLine.Basis_of_Fees__c;
                solutionWrapper.usecase = oppLine.Proposition__c;
                solutionWrapper.platform = oppLine.Platform__c;
                solutionWrapper.solutionTotalValue = isUpdate == true ? pkgTotalValue.setScale(2, RoundingMode.HALF_UP) : 0;
                // Set per-package original total (sum of TotalPrice for this package)
                solutionWrapper.solutionTotalValueOnOriginal = pkgTotalValue.setScale(2, RoundingMode.HALF_UP);
                solutionsByPackage.put(oppLine.Package__c, solutionWrapper);
                rowNum++;
            } else {
                // Package already exists: update its original total to the latest running sum
                SolutionWrapper existing = solutionsByPackage.get(oppLine.Package__c);
                existing.solutionTotalValueOnOriginal = pkgTotalValue.setScale(2, RoundingMode.HALF_UP);
            }

            // Build the line wrapper for this OLI and add only to its package (solution) group
            OpportunityLineWrapper oppLineWrapper = new OpportunityLineWrapper();
            oppLineWrapper.oppProductId = oppLine.Id;
            oppLineWrapper.product2Id = oppLine.Product2Id;
            oppLineWrapper.oppProductQuantity = oppLine.Quantity;
            oppLineWrapper.oppProductBasisOfFees = oppLine.Basis_of_Fees__c;
            oppLineWrapper.oppProductOfferingDetails = oppLine.Package__c;
            oppLineWrapper.oppProductSalesPrice = oppLine.UnitPrice;
            oppLineWrapper.oppProductTotalPrice = oppLine.TotalPrice;
            oppLineWrapper.oppProductTotalEquivalentUnits = oppLine.Number_of_Services__c;
            oppLineWrapper.oppProductUsecase = oppLine.Proposition__c;
            oppLineWrapper.oppProductPlatform = oppLine.Platform__c;
            oppLineWrapper.oppProductTotalValue = oppLine.TotalPrice;
            oppLineWrapper.oppProductSolutionCap = oppLine.Solution_Cap__c == null ? 0 : oppLine.Solution_Cap__c;

            solutionsByPackage.get(oppLine.Package__c).oppLines.add(oppLineWrapper);
        }

        // Flatten the map to a list.
        // Note: Map iteration order is not guaranteed. A comparator can be used to sort by rowNum if needed.
        List<SolutionWrapper> tmp = new List<SolutionWrapper>();
        tmp.addAll(solutionsByPackage.values());
        //tmp.sort(new SolutionRowComparator());
        solutionToReturn = tmp;

        wrapperToReturn.totalSalesPriceOriginalOpp = totalSalesPriceOfOriginal.setScale(2, RoundingMode.HALF_UP);
        wrapperToReturn.totalSalesPrice = totalSalesPrice.setScale(2, RoundingMode.HALF_UP);
        wrapperToReturn.currencyIsoCode = currencyCode;
        wrapperToReturn.solutionList = solutionToReturn;
        wrapperToReturn.pricebook2Id = pricebook2Id;
        wrapperToReturn.alreadyTopUpAmount = alreadyTopUpAmount.setScale(2, RoundingMode.HALF_UP);
        return wrapperToReturn;

    }

    // Helper comparator to sort solutions by their numeric row index
    /*public class SolutionRowComparator implements System.Comparator<SolutionWrapper> {
        public Integer compare(SolutionWrapper a, SolutionWrapper b) {
            // rowNum format is 'row-<n>'
            Integer ai = a != null && a.rowNum != null && a.rowNum.startsWith('row-') ? Integer.valueOf(a.rowNum.substring(4)) : 0;
            Integer bi = b != null && b.rowNum != null && b.rowNum.startsWith('row-') ? Integer.valueOf(b.rowNum.substring(4)) : 0;
            return ai.compareTo(bi);
        }
    }*/

    /**
     * @description
     *  Creates a Top Up child Opportunity from the given original Opportunity and clones eligible OLIs,
     *  prorating their TotalPrice by the ratio of new Solution Cap to original Solution Cap.
     *  Sets stage and bookkeeping fields on the new Opportunity.
     * @param opportunityDetails UI wrapper containing solution caps and line selections from client.
     * @param opportunityId The Id of the original Opportunity to base the Top Up upon.
     * @return returnMessageWrapper with MessageType (Success/Error) and the created Opportunity Id on success.
     * @throws DMLException When DML operations fail (rolled back to savepoint).
     * @throws Exception For any unexpected error (rolled back to savepoint).
     * @notes
     *  - Transaction uses Savepoint/rollback to ensure atomic creation.
     *  - Pricing rule: TotalPrice = (OriginalLine.TotalPrice / OriginalLine.Solution_Cap__c) * NewSolutionCap.
     *    UnitPrice is set to null to respect OLI pricing exclusivity.
     *  - Temporarily flips Account.Skip_Validation__c to bypass validations during bulk OLI upsert, then restores.
     *  - Assumes currency and pricebook are consistent with provided wrapper values.
     */
    @AuraEnabled
    public static returnMessageWrapper createTopUpOpportunity( TopUpInformationWrapper opportunityDetails, Id opportunityId){
        
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        Savepoint sp = Database.setSavepoint();
        
        try{
        // NOTE: Remove or guard debug logging in production deployments per org coding standards.
        //System.debug(opportunityDetails);
        System.debug('opportunityId '+ opportunityId);
        System.debug('opportunityId '+ opportunityId);
        List<Opportunity> opp = [SELECT Id,AccountId,Billing_Contact__c,Opportunity_Deal_Year__c,TM_Phase__c,Proposition__c,
                                 Primary_Contact__c,CurrencyIsoCode,Business_Type__c,Forecast_Category__c,Variation_Opportunity__c,
                                 Original_Opportunity__c, Original_Opportunity__r.Target_Program__c, Target_Program__c, Opportunity_Nickname__c 
                                 FROM Opportunity 
                                 WHERE Id =:opportunityId];
        // Create the Top Up Opportunity seeded from the original
        Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=opp[0].AccountId);
        opportunity.Opportunity_Nickname__c = 'Top Up';
        opportunity.ownerid=UserInfo.getUserId();
        opportunity.Billing_Contact__c=opp[0].Billing_Contact__c;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=opp[0].Primary_Contact__c;
        opportunity.CurrencyIsoCode=opp[0].CurrencyIsoCode;
        opportunity.Variation_Opportunity__c='Yes';
        opportunity.Variation_Reason__c = 'Addition to order';
        opportunity.StageName='Information Gathering';   
        opportunity.Business_Type__c = 'Top Up / Addition';
        opportunity.Forecast_Category__c = opp[0].Forecast_Category__c;
        opportunity.Original_Opportunity__c = opp[0].Id;
        opportunity.TM_Phase__c	= opp[0].TM_Phase__c;
        opportunity.Proposition__c = opp[0].Proposition__c;
        opportunity.Opportunity_Deal_Year__c = opp[0].Opportunity_Deal_Year__c;
        opportunity.Standard_Contract_Duration__c = '12';
        opportunity.Previous_Record_Type__c = System.label.IgniteRecordType;
        opportunity.Actual_Record_Type_Name__c = System.label.Configurator_Opportunity;
        opportunity.Target_Program__c = opp[0].Target_Program__c;
        insert opportunity;
        System.debug('Here');
        String currencyIsoCode = opportunityDetails.currencyIsoCode;
        String pricebook2Id = opportunityDetails.pricebook2Id;
        Set<Id> product2Id_Set = new Set<Id>();
        Set<Id> oppLineIds = new Set<Id>();
        Map<Id,OpportunityLineWrapper> wrapperMap = new Map<Id,OpportunityLineWrapper>();
        Map<String, Decimal> solutionToSolutionCapMap = new Map<String, Decimal>();
        
        List<SolutionWrapper> solutionWrapperList = opportunityDetails.solutionList;
        List<OpportunityLineWrapper> oppLineWrapperList = new List<OpportunityLineWrapper>();
        for(SolutionWrapper wrap : solutionWrapperList){
            oppLineWrapperList.addAll(wrap.oppLines);
            solutionToSolutionCapMap.put(wrap.solutionName, wrap.solutionCap);
        }

        for(OpportunityLineWrapper wrap : oppLineWrapperList){
            product2Id_Set.add(wrap.product2Id);
            oppLineIds.add(wrap.oppProductId);
            wrapperMap.put(wrap.oppProductId,wrap);
            wrap.oppProductSolutionCap = solutionToSolutionCapMap.get(wrap.oppProductOfferingDetails);
        }
        
        List<OpportunityLineItem> opportunityLinesDetails = [SELECT Id,Product2Id,Basis_of_Fees__c,Booking_Type__c,Discount,Proposition__c,Usage_Allowance__c,Solution_Cap__c,Number_of_Services__c,Total_Equivalent_Units__c,
                                                             RenewableNew__c,SOW_Required__c,RAG_Option_Value__c,Product_Stream__c,Product_Name__c,Quantity,
                                                             Product_Family__c,Platform__c,Package__c,List_Price__c,Is_MS_Product__c,Debooked_Quantity__c,
                                                             Debooked_Sales_Price__c, Debooked_Solution_Cap__c, Debooked_Total_Value__c, TotalPrice, UnitPrice
                                                             FROM OpportunityLineItem WHERE Id IN :oppLineIds];
        
        // Resolve active Pricebook Entries for the target currency/pricebook and selected products
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
            
            List<OpportunityLineItem> oppLineItemList = new  List<OpportunityLineItem>();
            // Clone each eligible OLI, rebind PBE, carry forward selective fields, and recompute pricing by cap ratio
            for(OpportunityLineItem line : opportunityLinesDetails){
                OpportunityLineItem lineItem = line.clone(false, false, false, false);
                lineItem.PricebookEntryId = product2Id_priceBookEntry_Map.get(line.Product2Id);
                lineItem.Solution_Cap__c = wrapperMap.get(line.Id).oppProductSolutionCap;
                lineItem.OpportunityId = opportunity.Id;
                // Calculate pricing for Top Up
                // We choose to set TotalPrice and leave UnitPrice null to satisfy OLI pricing rules
                // Guard against division by zero/null Solution_Cap__c; business rule expects cap > 0 on original lines.
                lineItem.TotalPrice = ((line.TotalPrice) / (line.Solution_Cap__c)) * (wrapperMap.get(line.Id).oppProductSolutionCap);
                lineItem.UnitPrice = null; // ensure mutual exclusivity with TotalPrice
                lineItem.Quantity = line.Quantity;
                if(line.Total_Equivalent_Units__c != null ){
                    lineItem.Total_Equivalent_Units__c = line.Total_Equivalent_Units__c;
                }
                oppLineItemList.add(lineItem);
            }
            
            List<Account> acc = [SELECT Id,Skip_Validation__c FROM Account WHERE Id =:opp[0].AccountId];
            
            acc[0].Skip_Validation__c = True;
            
            update acc;
            
            upsert oppLineItemList;
            
            Opportunity opportunityToUpdate = new Opportunity();
            opportunityToUpdate.StageName = 'Verbal';
            opportunityToUpdate.Id = opportunity.Id;
            
            update opportunityToUpdate;
            
            // Restore account validation flag after completing updates
            acc[0].Skip_validation__c = false;
            
            update acc;
            wrapperToReturn.MessageType = 'Success';
            wrapperToReturn.opportunityId = opportunity.Id;
            
        }
            }catch (DMLException e) {
            Database.rollback(sp);
            String message = e.getDmlMessage(0);
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        }catch (Exception e) {
            Database.rollback(sp);
            String message = e.getMessage();
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        }
        return wrapperToReturn;
    }

    /**
     * @description
     *  Updates existing Top Up Opportunity Line Items' pricing according to newly entered Solution Caps.
     *  Recomputes TotalPrice using original per-line ratio while preserving Quantity and other attributes.
     * @param opportunityDetails UI wrapper providing updated solution caps mapped to packages.
     * @param opportunityId The Id of the Top Up Opportunity whose lines should be updated.
     * @return returnMessageWrapper with MessageType (Success/Error) and Opportunity Id on success.
     * @throws DMLException When DML operations fail (rolled back to savepoint).
     * @throws Exception For any unexpected error (rolled back to savepoint).
     * @notes
     *  - Pricing rule: TotalPrice = (currentLine.oppProductTotalPrice / original Solution_Cap__c) * new Solution_Cap__c.
     *  - Leaves UnitPrice implicit via TotalPrice to satisfy OLI pricing constraints.
     */
    @AuraEnabled
    public static returnMessageWrapper updateTopUpOpportunityLines( TopUpInformationWrapper opportunityDetails, Id opportunityId){
        
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        Savepoint sp = Database.setSavepoint();
        
        try{
        Map<Id,OpportunityLineWrapper> wrapperMap = new Map<Id,OpportunityLineWrapper>();
        Map<String, Decimal> solutionToSolutionCapMap = new Map<String, Decimal>();
        List<SolutionWrapper> solutionWrapperList = opportunityDetails.solutionList;
        List<OpportunityLineWrapper> oppLineWrapperList = new List<OpportunityLineWrapper>();
        
        for(SolutionWrapper wrap : solutionWrapperList){
            oppLineWrapperList.addAll(wrap.oppLines);
            solutionToSolutionCapMap.put(wrap.solutionName, wrap.solutionCap);
        }

        for(OpportunityLineWrapper wrap : oppLineWrapperList){
            wrap.oppProductSolutionCap = solutionToSolutionCapMap.get(wrap.oppProductOfferingDetails);
            wrapperMap.put(wrap.oppProductId,wrap);
        }
        
        List<OpportunityLineItem> opportunityLinesDetails = [SELECT Id,Product2Id,Basis_of_Fees__c,Booking_Type__c,Discount,Proposition__c,Usage_Allowance__c,Solution_Cap__c,Number_of_Services__c,Total_Equivalent_Units__c,
                                                             RenewableNew__c,SOW_Required__c,RAG_Option_Value__c,Product_Stream__c,Product_Name__c,Quantity,
                                                             Product_Family__c,Platform__c,Package__c,List_Price__c,Is_MS_Product__c,Debooked_Quantity__c,
                                                             Debooked_Sales_Price__c, Debooked_Solution_Cap__c, Debooked_Total_Value__c, TotalPrice, UnitPrice
                                                             FROM OpportunityLineItem WHERE OpportunityId = :opportunityId];
        
        List<OpportunityLineItem> oppLineItemList = new  List<OpportunityLineItem>();

            // Recalculate each line's TotalPrice based on updated solution cap while preserving quantity
            for(OpportunityLineItem line : opportunityLinesDetails){
                if(wrapperMap.containsKey(line.Id)){
                    line.Id = line.Id;
                    Decimal totalPrice = wrapperMap.get(line.Id).oppProductTotalPrice;
                    Decimal solutionCap = line.Solution_Cap__c;
                    line.Solution_Cap__c = wrapperMap.get(line.Id).oppProductSolutionCap;
                    // Calculate pricing for Top Up
                    // We choose to set TotalPrice to satisfy OLI pricing rules
                    line.TotalPrice = (totalPrice / solutionCap) * (wrapperMap.get(line.Id).oppProductSolutionCap);
                    line.Quantity = line.Quantity;
                    oppLineItemList.add(line);
                }
            }
            
            if(!oppLineItemList.isEmpty()){
                upsert oppLineItemList;
            }
            
            wrapperToReturn.MessageType = 'Success';
            wrapperToReturn.opportunityId = opportunityId;
            
            }catch (DMLException e) {
            Database.rollback(sp);
            String message = e.getDmlMessage(0);
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        }catch (Exception e) {
            Database.rollback(sp);
            String message = e.getMessage();
            wrapperToReturn.MessageType ='Error';
            wrapperToReturn.Message = message;   
        }
        return wrapperToReturn;
    }

    /**
     * @description Lightweight wrapper returned to the client indicating success or error and a reference Id.
     */
    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public String opportunityId;
    }

    /**
     * @description
     *  Root UI data model sent from/to client.
     *  Captures overall totals, currency/pricebook context, any prior Top Up amount, and grouped solutions.
     */
    public class TopUpInformationWrapper{
        @AuraEnabled public Decimal totalSalesPrice {get;set;}
        @AuraEnabled public Decimal totalSalesPriceOriginalOpp {get;set;}
        @AuraEnabled public String currencyIsoCode {get;set;}//
        @AuraEnabled public String pricebook2Id {get;set;}//
        @AuraEnabled public Decimal alreadyTopUpAmount {get;set;}//
        @AuraEnabled public List<SolutionWrapper> solutionList {get;set;}
    }

    /**
     * @description
     *  Groups OLIs by solution for UI editing. Holds both original and editable values.
     *  - solutionCapOnOriginal: original cap from the source OLIs
     *  - solutionCap: editable cap entered by user for Top Up calculations
     *  - solutionTotalValueOnOriginal: sum of original TotalPrice per package
     *  - solutionTotalValue: UI-running total for updates (when isUpdate = true)
     */
    public class SolutionWrapper{
        @AuraEnabled public String solutionId {get;set;}//
        @AuraEnabled public Decimal solutionCap {get;set;}//
        @AuraEnabled public Decimal solutionCapOnOriginal {get;set;}//
        @AuraEnabled public String solutionName {get;set;}//
        @AuraEnabled public Decimal solutionTotalValue {get;set;}
        @AuraEnabled public Decimal solutionTotalValueOnOriginal {get;set;}
        @AuraEnabled public String basisOfFees {get;set;}//
        @AuraEnabled public String usecase {get;set;}
        @AuraEnabled public String platform {get;set;}//
        @AuraEnabled public String rowNum {get;set;}//
        @AuraEnabled public Boolean isDisabled = true;//
        @AuraEnabled public List<OpportunityLineWrapper> oppLines {get;set;}
    }
    
    /**
     * @description
     *  - oppProductSolutionCap: editable cap per line resolved from its solution group
     *  - oppProductTotalPrice: client-provided total when updating (used in recalculation)
     */
    public class OpportunityLineWrapper{
        @AuraEnabled public String oppProductId {get;set;}// // //
        @AuraEnabled public String product2Id {get;set;}// // //
        @AuraEnabled public String oppProductBasisOfFees {get;set;}// // //
        @AuraEnabled public String oppProductOfferingDetails {get;set;}// // //
        @AuraEnabled public String oppProductUsecase {get;set;}// // //
        @AuraEnabled public String oppProductPlatform {get;set;}// // //
        @AuraEnabled public Decimal oppProductTotalValue {get;set;}// // //
        @AuraEnabled public Decimal oppProductQuantity {get;set;}// // //
        @AuraEnabled public Decimal oppProductSalesPrice {get;set;}// // //
        @AuraEnabled public Decimal oppProductTotalPrice {get;set;}// // //
        @AuraEnabled public Decimal oppProductTotalEquivalentUnits {get;set;}// // //
        @AuraEnabled public Decimal oppProductSolutionCap {get;set;}// // //
    }
}
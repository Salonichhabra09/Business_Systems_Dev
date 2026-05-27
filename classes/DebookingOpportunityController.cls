/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-03-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class DebookingOpportunityController {
    
    @AuraEnabled
    public static DebookingInformationWrapper getOpportunityLine(Id opportunityId){
        
        DebookingInformationWrapper wrapperToReturn = new DebookingInformationWrapper();
        List<OpportunityLineWrapper> oppLinesToReturn  = new List<OpportunityLineWrapper>();
        List<OpportunityLineItem> oppLineItems = [SELECT Id,Product2Id,Product_Name__c,Basis_of_Fees__c,Package__c,
                                                  TotalPrice,UnitPrice,Quantity,Opportunity.Price_Increase_Percentage__c,Number_of_Services__c,
                                                  Opportunity.Pricebook2Id,Opportunity.CurrencyIsoCode ,Opportunity.OpportunityId__c,
                                                  Opportunity.Variation_Opportunity__c,Debooked_Quantity__c,Debooked_Sales_Price__c, Solution_Cap__c, Debooked_Solution_Cap__c, Debooked_Total_Value__c FROM OpportunityLineItem WHERE OpportunityId =:opportunityId];
        List<Opportunity> relatedOpportunity = [SELECT Id,Amount,Variation_Reason__c FROM Opportunity WHERE Original_Opportunity__c =:opportunityId AND Variation_Opportunity__c = 'Yes' AND ((StageName = :System.Label.Opportunity_Stage_6 AND Variation_Reason__c ='Addition to order' AND Order_activated_and_greater_than_zero__c = 'True') OR (Variation_Reason__c ='Debooking' AND StageName != :System.Label.Opportunity_Stage_7))];
        List<Id> relatedOppIds = new List<Id>();
        Decimal totalSalesPrice = 0;
        Decimal totalSalesPriceOfOriginal = 0;
        Decimal alreadyDebookedAmount = 0;
        String currencyCode = '';
        String pricebook2Id = '';
        Decimal priceIncreasePercentage;
        Decimal inflationAmount = 0;
        Integer rowNum = 0;
        String parentOppType = oppLineItems[0].Opportunity.Variation_Opportunity__c;
        for(Opportunity opp : relatedOpportunity){
            if(opp.Variation_Reason__c =='Debooking'){
                alreadyDebookedAmount +=  opp.Amount; 
                system.debug('alreadyDebookedAmount '+alreadyDebookedAmount);
            }else{
                relatedOppIds.add(opp.Id);
                
            }
        }
        List<OpportunityLineItem> relatedOppLineItems = [SELECT Id,Product2Id,Product_Name__c,Basis_of_Fees__c,Package__c,TotalPrice,UnitPrice,
                                                         Quantity,Opportunity.CurrencyIsoCode, Opportunity.OpportunityId__c,Number_of_Services__c,
                                                         Opportunity.Variation_Opportunity__c,Debooked_Quantity__c,Debooked_Sales_Price__c, Solution_Cap__c,Debooked_Solution_Cap__c, Debooked_Total_Value__c FROM OpportunityLineItem WHERE OpportunityId IN :relatedOppIds];
        List<OpportunityLineItem> oppLineItemsToProcess = new List<OpportunityLineItem>();
        oppLineItemsToProcess.addAll(oppLineItems);
        if(!relatedOppLineItems.isEmpty()){
            oppLineItemsToProcess.addAll(relatedOppLineItems);
        }
        
        for (OpportunityLineItem oppLine : oppLineItemsToProcess) {
            
            OpportunityLineWrapper oppLineWrapper = new OpportunityLineWrapper();
            oppLineWrapper.oppProductId = oppLine.Id;
            oppLineWrapper.oppProductName = oppLine.Product_Name__c;
            oppLineWrapper.oppNumber = oppLine.Opportunity.OpportunityId__c;
            oppLineWrapper.isVariationOpp = oppLine.Opportunity.Variation_Opportunity__c;
            oppLineWrapper.oppProductQuantity = oppLine.Quantity - (oppLine.Debooked_Quantity__c==null?0:oppLine.Debooked_Quantity__c);
            //oppLineWrapper.oppProductSalesPrice = oppLine.UnitPrice - (oppLine.Debooked_Sales_Price__c==null||oppLine.Debooked_Sales_Price__c==oppLine.UnitPrice?0:oppLine.Debooked_Sales_Price__c);
            oppLineWrapper.oppProductQuantityMax = oppLineWrapper.oppProductQuantity;
            //oppLineWrapper.oppProductSalesPriceMax = oppLineWrapper.oppProductSalesPrice;
            oppLineWrapper.oppProductTotalPrice = oppLine.TotalPrice - (oppLine.Debooked_Total_Value__c==null||oppLine.Debooked_Total_Value__c==oppLine.UnitPrice?0:oppLine.Debooked_Total_Value__c);
            oppLineWrapper.oppProductTotalPriceMax = oppLineWrapper.oppProductTotalPrice;
            oppLineWrapper.oppProductBasisOfFees = oppLine.Basis_of_Fees__c;
            oppLineWrapper.oppProductOfferingDetails = oppLine.Package__c;
            oppLineWrapper.oppProductNumberOfService = oppLine.Number_of_Services__c;
            //oppLineWrapper.oppProductTotalPriceWithCurrency = oppLine.TotalPrice!=null?oppLine.Opportunity.CurrencyIsoCode + ' '+oppLine.TotalPrice:opp.Account.CurrencyIsoCode + ' ' + 0;
            oppLineWrapper.oppProductSolutionCap= oppLine.Solution_Cap__c ==null?0:oppLine.Solution_Cap__c - (oppLine.Debooked_Solution_Cap__c==null?0:oppLine.Debooked_Solution_Cap__c);
            oppLineWrapper.oppProductSolutionCapMax = oppLineWrapper.oppProductSolutionCap;
            totalSalesPrice += oppLine.TotalPrice;
            if(oppLine.Opportunity.Variation_Opportunity__c=='No'){
                totalSalesPriceOfOriginal += oppLine.TotalPrice;
            }
            if(currencyCode ==''){
                currencyCode = oppLine.Opportunity.CurrencyIsoCode;
            }
            if(pricebook2Id ==''){
                pricebook2Id = oppLine.Opportunity.Pricebook2Id;
            }
            if(priceIncreasePercentage==null){
                priceIncreasePercentage = oppLine.Opportunity.Price_Increase_Percentage__c!=null ? oppLine.Opportunity.Price_Increase_Percentage__c:0;
            }
            oppLineWrapper.rowNum = 'row-'+rowNum;
            oppLineWrapper.product2Id = oppLine.Product2Id;
            if(parentOppType=='Yes'){
                /*if(oppLine.Debooked_Quantity__c == oppLine.Quantity && oppLine.Debooked_Sales_Price__c == oppLine.UnitPrice){
                    alreadyDebookedAmount +=  -oppLine.TotalPrice;
                }else if(oppLine.Debooked_Quantity__c != oppLine.Quantity && oppLine.Debooked_Sales_Price__c == 0){
                    alreadyDebookedAmount +=  -((oppLine.Debooked_Quantity__c==null?0:oppLine.Debooked_Quantity__c) * oppLine.UnitPrice);
                }else if(oppLine.Debooked_Sales_Price__c != oppLine.UnitPrice && oppLine.Debooked_Quantity__c == 0){
                    alreadyDebookedAmount +=  -((oppLine.Debooked_Sales_Price__c==null?0:oppLine.Debooked_Sales_Price__c) * oppLine.Quantity);
                }else if(oppLine.Debooked_Quantity__c != oppLine.Quantity && oppLine.Debooked_Sales_Price__c != oppLine.UnitPrice && oppLine.Debooked_Sales_Price__c!=null && oppLine.Debooked_Quantity__c!=null){
                    alreadyDebookedAmount +=  -(oppLine.TotalPrice - ((oppLine.Debooked_Sales_Price__c==null?0:oppLine.Debooked_Sales_Price__c) * (oppLine.Quantity - (oppLine.Debooked_Quantity__c==null?0:oppLine.Debooked_Quantity__c))));
                }*/
                if(oppLine.Debooked_Total_Value__c >= oppLine.TotalPrice){
                    alreadyDebookedAmount +=  -oppLine.TotalPrice;
                }else if(oppLine.Debooked_Total_Value__c < oppLine.TotalPrice){
                    alreadyDebookedAmount +=  -(oppLine.Debooked_Total_Value__c==null?0:oppLine.Debooked_Total_Value__c);
                }
            }
            if(oppLineWrapper.oppProductTotalPrice != 0){
                rowNum++;
                oppLinesToReturn.add(oppLineWrapper);
            }
            	
        }
        system.debug(totalSalesPrice);
        system.debug(priceIncreasePercentage);
        if(priceIncreasePercentage!=0){
            inflationAmount = totalSalesPriceOfOriginal - (totalSalesPriceOfOriginal/ (1+(priceIncreasePercentage/100)));
        }
        system.debug(inflationAmount);
        wrapperToReturn.totalSalesPriceOriginalOpp = totalSalesPriceOfOriginal.setScale(2, RoundingMode.HALF_UP);
        wrapperToReturn.totalSalesPrice = totalSalesPrice.setScale(2, RoundingMode.HALF_UP);
        wrapperToReturn.currencyIsoCode = currencyCode;
        wrapperToReturn.pricebook2Id = pricebook2Id;
        wrapperToReturn.oppLines = oppLinesToReturn;
        wrapperToReturn.alreadyDebookedAmount = -alreadyDebookedAmount.setScale(2, RoundingMode.HALF_UP);
        wrapperToReturn.inflationAmount = inflationAmount.setScale(2, RoundingMode.HALF_UP);
        return wrapperToReturn;
    }
    
    @AuraEnabled
    public static returnMessageWrapper createDebookingOpportunity( DebookingInformationWrapper opportunityDetails, Id opportunityId){
        
        returnMessageWrapper wrapperToReturn = new returnMessageWrapper();
        Savepoint sp = Database.setSavepoint();
        
        try{
        System.debug(opportunityDetails);
        List<Opportunity> opp = [SELECT Id,AccountId,Billing_Contact__c,Opportunity_Deal_Year__c,TM_Phase__c,Proposition__c,
                                 Primary_Contact__c,CurrencyIsoCode,Business_Type__c,Forecast_Category__c,Variation_Opportunity__c,
                                 Original_Opportunity__c, Original_Opportunity__r.Target_Program__c, Target_Program__c FROM Opportunity WHERE Id =:opportunityId];
        Opportunity opportunity=new Opportunity(name='Test Opportunity', AccountID=opp[0].AccountId);
        opportunity.ownerid=UserInfo.getUserId();
        opportunity.Billing_Contact__c=opp[0].Billing_Contact__c;
        opportunity.Closedate=system.today();
        opportunity.Primary_Contact__c=opp[0].Primary_Contact__c;
        opportunity.CurrencyIsoCode=opp[0].CurrencyIsoCode;
        opportunity.Variation_Opportunity__c='Yes';
        opportunity.Variation_Reason__c = 'Debooking';
        opportunity.StageName='Information Gathering';   
        opportunity.Business_Type__c = 'Debooking';
        opportunity.Forecast_Category__c = opp[0].Forecast_Category__c;
        opportunity.Original_Opportunity__c = opp[0].Variation_Opportunity__c=='Yes'? opp[0].Original_Opportunity__c : opportunityId;
        opportunity.TM_Phase__c	= opp[0].TM_Phase__c;
        opportunity.Proposition__c = opp[0].Proposition__c;
        opportunity.Opportunity_Deal_Year__c = opp[0].Opportunity_Deal_Year__c;
        opportunity.Standard_Contract_Duration__c = '12';
        opportunity.Previous_Record_Type__c = System.label.IgniteRecordType;
        opportunity.Actual_Record_Type_Name__c = System.label.Configurator_Opportunity;
        opportunity.Target_Program__c = opp[0].Variation_Opportunity__c == 'Yes' ? (opp[0].Original_Opportunity__r.Target_Program__c) : opp[0].Target_Program__c;
        insert opportunity;
        
        List<OpportunityLineWrapper> oppLineWrapperList = opportunityDetails.oppLines;
        String currencyIsoCode = opportunityDetails.currencyIsoCode;
        String pricebook2Id = opportunityDetails.pricebook2Id;
        Set<Id> product2Id_Set = new Set<Id>();
        Set<Id> oppLineIds = new Set<Id>();
        Map<Id,OpportunityLineWrapper> wrapperMap = new Map<Id,OpportunityLineWrapper>();
        
        
        for(OpportunityLineWrapper wrap : oppLineWrapperList){
            product2Id_Set.add(wrap.product2Id);
            oppLineIds.add(wrap.oppProductId);
            wrapperMap.put(wrap.oppProductId,wrap);
        }
        
        
        List<OpportunityLineItem> opportunityLinesDetails = [SELECT Id,Product2Id,Basis_of_Fees__c,Booking_Type__c,Discount,Proposition__c,Usage_Allowance__c,Solution_Cap__c,Number_of_Services__c,Total_Equivalent_Units__c,
                                                             RenewableNew__c,SOW_Required__c,RAG_Option_Value__c,Product_Stream__c,Product_Name__c,Quantity,
                                                             Product_Family__c,Platform__c,Package__c,List_Price__c,Is_MS_Product__c,Debooked_Quantity__c,Debooked_Sales_Price__c, Debooked_Solution_Cap__c, Debooked_Total_Value__c 
                                                             FROM OpportunityLineItem WHERE Id IN :oppLineIds];
        
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
            for(OpportunityLineItem line : opportunityLinesDetails){
                OpportunityLineItem lineItem = line.clone(false, false, false, false);
                lineItem.PricebookEntryId = product2Id_priceBookEntry_Map.get(line.Product2Id);
                lineItem.Quantity = -(wrapperMap.get(line.Id).oppProductQuantity);
                System.debug(wrapperMap.get(line.Id).oppProductSalesPrice);
                lineItem.UnitPrice = (wrapperMap.get(line.Id).oppProductTotalPrice/wrapperMap.get(line.Id).oppProductQuantity);
                lineItem.Solution_Cap__c = -(wrapperMap.get(line.Id).oppProductSolutionCap);
                lineItem.OpportunityId = opportunity.Id;
                lineItem.Original_Opportunity_Product__c = line.Id;
                lineItem.Debooked_Quantity__c = 0;
                lineItem.Debooked_Sales_Price__c = 0; 
                lineItem.Debooked_Solution_Cap__c = 0;
                lineItem.Debooked_Total_Value__c = 0;
                
                /*if(lineItem.Basis_of_Fees__c == 'Units' || lineItem.Basis_of_Fees__c == 'Assessments and Reports'){
                    lineItem.Total_Equivalent_Units__c = lineItem.Quantity;
                }else if(lineItem.Basis_of_Fees__c == 'Candidates' || lineItem.Basis_of_Fees__c == 'Employees' || lineItem.Basis_of_Fees__c == 'Participants' || lineItem.Basis_of_Fees__c == 'Full-Time Equivalents (FTEs)'){
                    lineItem.Total_Equivalent_Units__c = (lineItem.Quantity/wrapperMap.get(line.Id).oppProductQuantityMax) * (lineItem.Total_Equivalent_Units__c!=null?lineItem.Total_Equivalent_Units__c:0);
                }*/
                if(line.Total_Equivalent_Units__c != null ){
                    lineItem.Total_Equivalent_Units__c = (lineItem.Quantity/line.Quantity) * line.Total_Equivalent_Units__c;
                }
                
                oppLineItemList.add(lineItem);
                
                Decimal debookedQuantity = line.Debooked_Quantity__c==null?0:line.Debooked_Quantity__c;
                Decimal debookedSalesPrice = line.Debooked_Sales_Price__c==null?0:line.Debooked_Sales_Price__c;
                Decimal debookedSolutionCap = line.Debooked_Solution_Cap__c==null?0:line.Debooked_Solution_Cap__c;
                Decimal debookedTotalPrice = line.Debooked_Total_Value__c==null?0:line.Debooked_Total_Value__c;
                OpportunityLineItem lineItemToUpdate = new OpportunityLineItem();
                lineItemToUpdate.Id = line.Id;
                
                /*if(wrapperMap.get(line.Id).oppProductQuantity==wrapperMap.get(line.Id).oppProductQuantityMax && wrapperMap.get(line.Id).oppProductSalesPrice==wrapperMap.get(line.Id).oppProductSalesPriceMax){
                  lineItemToUpdate.Debooked_Quantity__c = (debookedQuantity + wrapperMap.get(line.Id).oppProductQuantity).setScale(2, RoundingMode.HALF_UP);
                  lineItemToUpdate.Debooked_Sales_Price__c = (debookedSalesPrice + wrapperMap.get(line.Id).oppProductSalesPrice).setScale(8, RoundingMode.HALF_UP);  
                }else if(wrapperMap.get(line.Id).oppProductQuantity==wrapperMap.get(line.Id).oppProductQuantityMax && wrapperMap.get(line.Id).oppProductSalesPrice!=wrapperMap.get(line.Id).oppProductSalesPriceMax){
                    lineItemToUpdate.Debooked_Quantity__c = (debookedQuantity + (wrapperMap.get(line.Id).oppProductQuantityMax - wrapperMap.get(line.Id).oppProductQuantity)).setScale(2, RoundingMode.HALF_UP);
                  	lineItemToUpdate.Debooked_Sales_Price__c = (debookedSalesPrice + wrapperMap.get(line.Id).oppProductSalesPrice).setScale(8, RoundingMode.HALF_UP);  
                }else if(wrapperMap.get(line.Id).oppProductQuantity!=wrapperMap.get(line.Id).oppProductQuantityMax && wrapperMap.get(line.Id).oppProductSalesPrice==wrapperMap.get(line.Id).oppProductSalesPriceMax){
                    lineItemToUpdate.Debooked_Quantity__c = (debookedQuantity + wrapperMap.get(line.Id).oppProductQuantity).setScale(2, RoundingMode.HALF_UP);
                  	lineItemToUpdate.Debooked_Sales_Price__c = (debookedSalesPrice + (wrapperMap.get(line.Id).oppProductSalesPriceMax - wrapperMap.get(line.Id).oppProductSalesPrice)).setScale(8, RoundingMode.HALF_UP);  
                }else if(wrapperMap.get(line.Id).oppProductQuantity!=wrapperMap.get(line.Id).oppProductQuantityMax && wrapperMap.get(line.Id).oppProductSalesPrice!=wrapperMap.get(line.Id).oppProductSalesPriceMax){
                    Decimal RemainingQuantity = wrapperMap.get(line.Id).oppProductQuantityMax - wrapperMap.get(line.Id).oppProductQuantity;
					Decimal currentPrice = wrapperMap.get(line.Id).oppProductQuantity*wrapperMap.get(line.Id).oppProductSalesprice;
                    Decimal totalPrice =  wrapperMap.get(line.Id).oppProductQuantityMax*wrapperMap.get(line.Id).oppProductSalespriceMax;
	                Decimal remainingPrice = totalPrice-currentPrice;
                    Decimal additionToPrice = (wrapperMap.get(line.Id).oppProductSalespriceMax-(remainingPrice/RemainingQuantity)).setScale(8, RoundingMode.HALF_UP);
                    //Decimal reducedScope = wrapperMap.get(line.Id).oppProductQuantityMax - (((totalPrice - currentPrice)/wrapperMap.get(line.Id).oppProductSalespriceMax));
                    //lineItemToUpdate.Debooked_Quantity__c = (debookedQuantity + reducedScope);
                    //Decimal remainingValue = ((wrapperMap.get(line.Id).oppProductQuantityMax*wrapperMap.get(line.Id).oppProductSalespriceMax)-())/(wrapperMap.get(line.Id).oppProductQuantityMax - wrapperMap.get(line.Id).oppProductQuantity)
                  	lineItemToUpdate.Debooked_Quantity__c = (debookedQuantity + (wrapperMap.get(line.Id).oppProductQuantity)).setScale(2, RoundingMode.HALF_UP);
                    lineItemToUpdate.Debooked_Sales_Price__c = debookedSalesPrice + additionToPrice;  
                }*/
                if(wrapperMap.get(line.Id).oppProductQuantity==wrapperMap.get(line.Id).oppProductQuantityMax && wrapperMap.get(line.Id).oppProductTotalPrice==wrapperMap.get(line.Id).oppProductTotalPriceMax){
                  lineItemToUpdate.Debooked_Quantity__c = (debookedQuantity + wrapperMap.get(line.Id).oppProductQuantity).setScale(2, RoundingMode.HALF_UP);
                  lineItemToUpdate.Debooked_Total_Value__c = (debookedTotalPrice + wrapperMap.get(line.Id).oppProductTotalPrice).setScale(2, RoundingMode.HALF_UP);  
                }else if(wrapperMap.get(line.Id).oppProductQuantity==wrapperMap.get(line.Id).oppProductQuantityMax && wrapperMap.get(line.Id).oppProductTotalPrice!=wrapperMap.get(line.Id).oppProductTotalPriceMax){
                    lineItemToUpdate.Debooked_Quantity__c = (debookedQuantity + (wrapperMap.get(line.Id).oppProductQuantityMax - wrapperMap.get(line.Id).oppProductQuantity)).setScale(2, RoundingMode.HALF_UP);
                  	lineItemToUpdate.Debooked_Total_Value__c = (debookedTotalPrice + wrapperMap.get(line.Id).oppProductTotalPrice).setScale(2, RoundingMode.HALF_UP);  
                }else if(wrapperMap.get(line.Id).oppProductQuantity!=wrapperMap.get(line.Id).oppProductQuantityMax && wrapperMap.get(line.Id).oppProductTotalPrice==wrapperMap.get(line.Id).oppProductTotalPriceMax){
                    lineItemToUpdate.Debooked_Quantity__c = (debookedQuantity + wrapperMap.get(line.Id).oppProductQuantity).setScale(2, RoundingMode.HALF_UP);
                  	lineItemToUpdate.Debooked_Total_Value__c = (debookedTotalPrice + wrapperMap.get(line.Id).oppProductTotalPrice).setScale(2, RoundingMode.HALF_UP);  
                }else if(wrapperMap.get(line.Id).oppProductQuantity!=wrapperMap.get(line.Id).oppProductQuantityMax && wrapperMap.get(line.Id).oppProductTotalPrice!=wrapperMap.get(line.Id).oppProductTotalPriceMax){
                    lineItemToUpdate.Debooked_Quantity__c = debookedQuantity + wrapperMap.get(line.Id).oppProductQuantity.setScale(2, RoundingMode.HALF_UP);
                	lineItemToUpdate.Debooked_Total_Value__c = debookedTotalPrice + wrapperMap.get(line.Id).oppProductTotalPrice.setScale(2, RoundingMode.HALF_UP);
                }

                lineItemToUpdate.Debooked_Solution_Cap__c = debookedSolutionCap + wrapperMap.get(line.Id).oppProductSolutionCap;
                
                oppLineItemList.add(lineItemToUpdate);
            }
            
            List<Account> acc = [SELECT Id,Skip_Validation__c FROM Account WHERE Id =:opp[0].AccountId];
            
            acc[0].Skip_Validation__c = True;
            
            update acc;
            
            upsert oppLineItemList;
            
            Opportunity opportunityToUpdate = new Opportunity();
            opportunityToUpdate.StageName = 'Verbal';
            opportunityToUpdate.Id = opportunity.Id;
            
            update opportunityToUpdate;
            
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
    
    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public String opportunityId;
    }
    
    public class DebookingInformationWrapper{
        
        @AuraEnabled public Decimal totalSalesPrice {get;set;}
        @AuraEnabled public Decimal totalSalesPriceOriginalOpp {get;set;}
        @AuraEnabled public String currencyIsoCode {get;set;}
        @AuraEnabled public Decimal inflationAmount {get;set;}
        @AuraEnabled public String pricebook2Id {get;set;}
        @AuraEnabled public Decimal alreadyDebookedAmount {get;set;}
        @AuraEnabled public List<OpportunityLineWrapper> oppLines {get;set;}
        
        
    }
    
    public class OpportunityLineWrapper{
        
        @AuraEnabled public String oppProductId {get;set;}
        @AuraEnabled public String product2Id {get;set;}
        @AuraEnabled public String oppProductName {get;set;}
        @AuraEnabled public String oppNumber {get;set;}
        @AuraEnabled public String isVariationOpp {get;set;}
        @AuraEnabled public String oppProductBasisOfFees {get;set;}
        @AuraEnabled public String oppProductOfferingDetails {get;set;}
        @AuraEnabled public Decimal oppProductQuantity {get;set;}
        @AuraEnabled public Decimal oppProductSalesPrice {get;set;}
        @AuraEnabled public Decimal oppProductQuantityMax {get;set;}
        @AuraEnabled public Decimal oppProductSalesPriceMax {get;set;}
        @AuraEnabled public Decimal oppProductTotalPrice {get;set;}
        @AuraEnabled public Decimal oppProductTotalPriceMax {get;set;}
        @AuraEnabled public Decimal oppProductSolutionCap {get;set;}
        @AuraEnabled public Decimal oppProductSolutionCapMax {get;set;}
        @AuraEnabled public Decimal oppProductNumberOfService {get;set;}
        @AuraEnabled public Boolean isDisabled = true;
        @AuraEnabled public String rowNum {get;set;}
        
    }
}
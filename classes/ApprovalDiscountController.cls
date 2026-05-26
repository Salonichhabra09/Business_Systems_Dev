/**
 * @description       : 
 * @author            : OppotLine and Future Product discount
 * @group             : 
 * @last modified on  : 12-18-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ApprovalDiscountController {

    // Row structure sent to LWC
    public class ApprovalRowDTO implements Comparable {
        @AuraEnabled public String id;
        @AuraEnabled public String recordId;
        @AuraEnabled public String productname;         
        @AuraEnabled public String dealyear;
        @AuraEnabled public Decimal listprice;     
        @AuraEnabled public Decimal salesprice;   
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Decimal discountperage;
        @AuraEnabled public Decimal discountvalue;
        @AuraEnabled public String type;

        // Sort newest first
        public Integer compareTo(Object other) {
            ApprovalRowDTO o = (ApprovalRowDTO)other;
            if (this.createdDate == o.createdDate) {
                return 0;
            }
            return this.createdDate > o.createdDate ? -1 : 1;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ApprovalRowDTO> getDiscountRows(Id recordId) {
        List<ApprovalRowDTO> result = new List<ApprovalRowDTO>();
        if (recordId == null) {
            return result;
        }

       
        List<OpportunityLineItem> Oppline = [
            SELECT Id,
                   OpportunityId,
                   Product_Name__c,
                   CreatedDate,
                   Contract_Year__c,
                   List_Price__c,
                   UnitPrice,
                   Discount__c,
                   Discount_Value__c,
                   Product_Family__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :recordId
            AND Discount__c!= null
            AND Discount__c!=0
            ORDER BY CreatedDate DESC
        ];

        for (OpportunityLineItem oppprod : Oppline) {
            ApprovalRowDTO row = new ApprovalRowDTO();
            row.id          = oppprod.Id;
            row.recordId    = String.valueOf(oppprod.OpportunityId);
            row.type        = oppprod.Product_Family__c;
            row.productname = oppprod.Product_Name__c;
            row.dealyear    = oppprod.Contract_Year__c;
            row.listprice   = oppprod.List_Price__c;
            row.salesprice  = oppprod.UnitPrice;
            row.discountperage = oppprod.Discount__c;
            row.discountvalue  = oppprod.Discount_Value__c;
            result.add(row);
        }

       
        List<Future_Product__c> workItems = [
            SELECT Id,
                   Opportunity__c,
                   Product_Name__c,
                   CreatedDate,
                   Contract_Year__c,
                   ListPrice__c,
                   Sales_Price__c,
                   Discount__c,
                   Discount_Value__c,
                   Product__r.Product_Family__c
            FROM Future_Product__c
            WHERE Opportunity__c = :recordId
            AND Discount__c!= null
            AND Discount__c !=0
            ORDER BY CreatedDate DESC
        ];

        for (Future_Product__c futureprod : workItems) {
            ApprovalRowDTO row = new ApprovalRowDTO();
            row.id          = futureprod.Id;
            row.recordId    = String.valueOf(futureprod.Opportunity__c);
            row.type        = futureprod.Product__r.Product_Family__c;
            row.productname = futureprod.Product_Name__c;
            row.dealyear    = futureprod.Contract_Year__c;
            row.listprice   = futureprod.ListPrice__c;
            row.salesprice  = futureprod.Sales_Price__c;
            row.discountperage = futureprod.Discount__c;
            row.discountvalue  = futureprod.Discount_Value__c;
            result.add(row);
        }

        // Sort by createdDate DESC using Comparable
        result.sort();
        return result;
    }
}
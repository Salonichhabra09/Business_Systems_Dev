/*
Created By: Prabhat Arora, for SSE-7077, 
Purpose: Overiding Functionality of OLI standard "EDIT & DELETE" actions 
*/
public class redirect_Ext {
    public OpportunityLineItem opptyLineItemRec;
    Public Opportunity OpptyRec;
    Public String OpptyId{get;set;}
    //public Boolean rateCardUploaded{get;set;}
    public boolean isIgniteOpp{get;set;}
    public redirect_Ext(ApexPages.StandardController controller) {
        opptyLineItemRec = [select id, Imported_from_Rate_Card_c__c, OpportunityId,opportunity.recordtypeid from OpportunityLineItem where id =: System.currentPageReference().getParameters().get('id')];
        isIgniteOpp = false;
        //rateCardUploaded = opptyLineItemRec.Imported_from_Rate_Card_c__c;
        OpptyId = opptyLineItemRec.OpportunityId;
        if(opptyLineItemRec.opportunity.recordtypeid == '012D0000000KN0H'){
            isIgniteOpp = true;
        }

    }
}
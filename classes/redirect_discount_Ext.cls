/*
Created By: Rishabh Kanotra, for SSE-7079, 
Purpose: Overiding Functionality of OLI standard "EDIT & DELETE" actions 
*/
public class redirect_discount_Ext {
    
    
    Public String OpptyIddiscount{get;set;}
    public Discount_Summary__c Discountrec;
    
    
    public redirect_discount_Ext (ApexPages.StandardController controller) {
        
        Discountrec= [select id, Opportunity__c from Discount_Summary__c where id =: System.currentPageReference().getParameters().get('id')];
        OpptyIddiscount=Discountrec.Opportunity__c ;
    }
}
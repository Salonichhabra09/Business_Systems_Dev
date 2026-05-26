/********************************************************************************************************                
   Created By: Pankhuri Jain
   Created On: 20/2/2018
   Last Modified On: 31/07/2019
   Description: This class is getting called from Apex trigger: ContractInvoiceLine_CheckIMLookup.Contains Invoice Line trigger functionality 
   (before insert, before update) 
   1. Populating SUN_IM_lookup_code__c in Contract_Invoice_Line__c based on matching similar combination of Custom Metadatype records. 
   2. Sets Invoice Line Currency with related Invoice Header Contract currency on Invoice Line Insert
*********************************************************************************************************/

public with sharing class ContractInvoiceLine_CheckIMLookupClass {

    //Populating SUN_IM_lookup_code__c in Contract_Invoice_Line__c based on matching similar combination of Custom Metadatype records
    public static void SearchIMLookup(List<Contract_Invoice_Line__c > allInvLineslist, Map<id,Contract_Invoice_Line__c > oldInvLineMap){
       List<Contract_Invoice_Line__c> contractInvoiceLines = new List<Contract_Invoice_Line__c>();
        system.debug('-- Prachi Inside Class --> After Insert' + allInvLineslist);
         system.debug('-- Prachi Inside Class --> After Insert' + oldInvLineMap);
       
       System.debug('**allInvLineslist' + allInvLineslist);
       
        for(Contract_Invoice_Line__c inv : allInvLineslist) { 
           //Changes SSE-17631 - Prachi (added the logic to work on insert of invoice lines as well) 
                   system.debug('-- Prachi Inside Class --> After Insert' + inv.SUN_IM_lookup_code__c);
                    system.debug('-- Prachi Inside Class --> After Insert' + (oldInvLineMap== Null && inv.SUN_IM_lookup_code__c == null)); 
           if((oldInvLineMap== Null && inv.SUN_IM_lookup_code__c == null )||(oldInvLineMap != null &&                                                             
             inv.SUN_IM_lookup_code__c == null ))
           { 
                  system.debug('-- Prachi Inside For loop --> After Insert' + inv.IM_Lookup_Code__c); 
                   
                   if(inv.IM_Lookup_Code__c!=null){
                       system.debug('-- Prachi Inside If --> After Insert' + inv.IM_Lookup_Code__c);
                       inv.SUN_IM_lookup_code__c = inv.IM_Lookup_Code__c;    
                   } 
               else{
                       inv.SUN_IM_lookup_code__c = 'No valid option available';
                       system.debug('-- Prachi Inside IF --> After Insert' + inv.SUN_IM_lookup_code__c);
                   }                  
                       
                  
                              
              /*     
              else{
                  system.debug('-- Prachi Inside Else --> After Insert');
                  List<IM_Look_Up_Code__mdt> IMLookupCodes = [SELECT MasterLabel, Tax_Analysis__c, 
                                                              QualifiedApiName, Item_Code__c ,
                                                              Long_Description__c,Lookup_Code__c,
                                                              Order_Line_Item__c,Platform__c,Usage_Allowance__c 
                                                              FROM IM_Look_Up_Code__mdt  
                                                              where Order_Line_Item__c = :inv.Order_Line_Item__c 
                                                              and Platform__c =: inv.Platform__c and Usage_Allowance__c =: inv.Usage_Allowance__c];  
                  // Custom Metadata         
                  system.debug('-- Prachi Inside Else --> After Insert' + IMLookupCodes.size());
                  
                  System.debug('-- Prachi Inside Else --> After Insert ' + IMLookupCodes);
                  System.debug('**IMLookupCodesSize ' + IMLookupCodes.size());
                  
                  if(IMLookupCodes != null && IMLookupCodes.size() == 1){
                       system.debug('-- Prachi Inside IF --> After Insert' + IMLookupCodes[0].Lookup_Code__c);
                      inv.SUN_IM_lookup_code__c = IMLookupCodes[0].Lookup_Code__c;
                      inv.Tax_Analysis__c = IMLookupCodes[0].Tax_Analysis__c;              // Added on 13th Nov 2018
                  }
                  else if(IMLookupCodes != null  && IMLookupCodes.size() > 1){
                        
                      inv.SUN_IM_lookup_code__c = 'Multiple Options available';
                      system.debug('-- Prachi Inside IF --> After Insert' + inv.SUN_IM_lookup_code__c);
                  }
                  else                   
                      inv.SUN_IM_lookup_code__c = 'No valid option available';  
                  system.debug('-- Prachi Inside IF --> After Insert' + inv.SUN_IM_lookup_code__c);
              }*/
              
        }
        }
    }
    
    // Setting Invoice Line Currency with related Invoice Header Contract currency on Invoice Line Insert
    public static void ChangeCurrencyIsoCode(List<Contract_Invoice_Line__c > allNewInvLineslist){
        Set<Id> Contract_Invoice_HeaderIdsSet = new Set<Id>();
        for(integer i=0;i<allNewInvLineslist.size();i++){
            Contract_Invoice_HeaderIdsSet.add(allNewInvLineslist[i].Invoice_Header_ID__c);
        }
        Map<Id,Contract_Invoice_Header__c> Contract_Invoice_LineMap = new Map<Id,Contract_Invoice_Header__c>([Select id,Order__r.CurrencyIsoCode from Contract_Invoice_Header__c where id in :Contract_Invoice_HeaderIdsSet]);
       
        for(Integer i = 0;i<allNewInvLineslist.size();i++){
            if(Contract_Invoice_LineMap!=null && Contract_Invoice_LineMap.get(allNewInvLineslist[i].Invoice_Header_ID__c)!=null)
                allNewInvLineslist[i].CurrencyIsoCode = Contract_Invoice_LineMap.get(allNewInvLineslist[i].Invoice_Header_ID__c).Order__r.CurrencyIsoCode;
        }
    }
    
}
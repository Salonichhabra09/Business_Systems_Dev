/**************************************************************************************************************************************
CREATED BY :- Virendra Kumar
CREATED DATE :- 29-07-2019
DESCRIPTION :-  This class contains ContractLine trigger related functionalities :  after update(Invoice Line Field Update)
***************************************************************************************************************************************/
public class ContractLineTriggerManager_6{
/* This method helps in updating Invoice line fields when:
    1. New Line price is not equal to old line price & quantity !=null.
    2. If new and old values of IM_Lookup_Code__c Platform__cUsage_Allowance__c are not same and Invoice Header's Status in 'Draft' , cross border, Queried, Cancelled, awaiting po, No      
         Usage then set invoice line's platform, usage allowance, order line  item
*/
public static void invoiceLineFieldupdate(list<Contract_Line__c> ContractlineNewlist,Map<Id,Contract_Line__c> ContractlineNewmaplist,list<Contract_Line__c> ContractlineOldlist,Map<Id,Contract_Line__c> ContractlineOldmaplist   )
{
  Set<Id> contractLineIds = new Set<Id>();
    Set<Id> updatedIMLookupOnOLI = new Set<Id>();
    Map<String, Decimal> m = new Map<String, Decimal>();  // Added for SSE-5399
    List<Contract_Invoice_Line__c> contractInvoiceLines = new List<Contract_Invoice_Line__c>();
    for (integer i=0;i<ContractlineNewlist.size();i++)
    {
        if(ContractlineNewlist[i].Price__c != ContractlineOldlist[i].Price__c)
            contractLineIds.add(ContractlineNewlist[i].Id);
            m.put(ContractlineNewlist[i].name,ContractlineNewlist[i].Price__c);    // Added for SSE-5399
            System.debug('mapid ' + m);
        if(ContractlineNewlist[i].IM_Lookup_Code__c != ContractlineOldlist[i].IM_Lookup_Code__c || ContractlineNewlist[i].Platform__c!=ContractlineOldlist[i].Platform__c || ContractlineNewlist[i].Usage_Allowance__c != ContractlineOldlist[i].Usage_Allowance__c)         
            updatedIMLookupOnOLI.add(ContractlineNewlist[i].Id);
    }
   
    contractInvoiceLines = [SELECT Id,Quantity__c,Contract_Line_ID__c,Contract_Line_ID__r.name,Contract_Line_Price__c,Price__c,Invoice_Line_Total__c from Contract_Invoice_Line__c WHERE Contract_Line_ID__c IN:contractLineIds];  
    // Added by pankhuri on 1 Nov 2017 for SSE-5399
    System.debug('List** ' + contractInvoiceLines); 
    for(Contract_Invoice_Line__c cv: contractInvoiceLines){
    
        System.debug('Price** '+ cv.Price__c);
        System.debug('Name** ' + m.get(cv.Contract_Line_ID__r.name));
        
        if(cv.Quantity__c == null){
           cv.Quantity__c = 0;
        }
        if(cv.Price__c != null && cv.Quantity__c != null){
            cv.Invoice_Line_Total__c = cv.Quantity__c * cv.Price__c;  
            System.debug('Total1 '+ cv.Invoice_Line_Total__c);        
        }
        else
            cv.Invoice_Line_Total__c = cv.Quantity__c * m.get(cv.Contract_Line_ID__r.name);
            System.debug('Total2 '+ cv.Invoice_Line_Total__c);
     // end
    }
    update contractInvoiceLines;
    
    if(updatedIMLookupOnOLI.size()>0){
        List<Contract_Invoice_Line__c> updatedInvoiceLine = new List<Contract_Invoice_Line__c>();
        for(Contract_Invoice_Line__c cil : [select id,IM_Lookup_Code_For_Filter__c,Invoice_Header_ID__r.Invoice_Status__c ,Contract_Line_ID__c from Contract_Invoice_Line__c where Contract_Line_ID__c IN: updatedIMLookupOnOLI]){
            //if (cil.Invoice_Header_ID__r.Invoice_Status__c  != 'Transferred to Infor10' && cil.Invoice_Header_ID__r.Invoice_Status__c  != 'Invoice Complete' )
            if (cil.Invoice_Header_ID__r.Invoice_Status__c  == 'Draft' || cil.Invoice_Header_ID__r.Invoice_Status__c  == 'Cross Border' || cil.Invoice_Header_ID__r.Invoice_Status__c  == 'Queried' || cil.Invoice_Header_ID__r.Invoice_Status__c  == 'Cancelled' || cil.Invoice_Header_ID__r.Invoice_Status__c  == 'Awaiting PO' || cil.Invoice_Header_ID__r.Invoice_Status__c  == 'No Usage' )   // SSE-5643
            {
                 cil.Platform__c = ContractlineNewmaplist.get(cil.Contract_Line_ID__c).Platform__c;
                 cil.Usage_Allowance__c = ContractlineNewmaplist.get(cil.Contract_Line_ID__c).Usage_Allowance__c;
                 cil.Order_Line_Item__c = ContractlineNewmaplist.get(cil.Contract_Line_ID__c).IM_Lookup_Code__c;
                 cil.IM_Lookup_Code_For_Filter__c = ContractlineNewmaplist.get(cil.Contract_Line_ID__c).IM_Lookup_Code__c;
                 updatedInvoiceLine.add(cil);
            }
            else if(ContractlineNewmaplist.get(cil.Contract_Line_ID__c).IM_Lookup_Code__c != ContractlineOldmaplist.get(cil.Contract_Line_ID__c).IM_Lookup_Code__c )
            {
                cil.IM_Lookup_Code_For_Filter__c = ContractlineNewmaplist.get(cil.Contract_Line_ID__c).IM_Lookup_Code__c;
                updatedInvoiceLine.add(cil);
            }
            
        }
        if(updatedInvoiceLine.size()>0){
            update updatedInvoiceLine;
        }
    }
    }
}
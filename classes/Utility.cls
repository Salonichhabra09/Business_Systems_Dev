/**************************************************************************************************************************************

CREATED BY :- ANJALI CHAUDHARY
CREATED DATE :- 16-12-2014
DESCRIPTION :- This class contains utiltiy methods related to Custom Setting.
                        

***************************************************************************************************************************************/

public class Utility {

    public static boolean runME = true; 
    public static boolean runOnce = true; 
    public static boolean runOnceOrder = true;
    public static boolean lead_isconveretd = true;
    public static boolean Timesheetinsert= true;
    public static boolean EACVFlag= true;
    public static boolean runOpptyAfterUpdateTrigOnce = true; 
    
    public static Map<String,Field_Value_Setting__c> getFieldValueSettings() 
    {
   
        Map<String,Field_Value_Setting__c> custSettingMap = Field_Value_Setting__c.getAll();       
        return custSettingMap;
    }
    
    public static Map<String,Multiyear_Opportunity_Product_Sequence__c> getMultiYear() 
    {
   
        Map<String,Multiyear_Opportunity_Product_Sequence__c> custSettingMap = Multiyear_Opportunity_Product_Sequence__c.getAll();       
        return custSettingMap;
    }
    
    //Added by Anjali for SSE-2721 called in  class - LeadConversionController_ConvertPage and Trigger - 
    public static Set<String> getOpptyType() {  
        Set<String> opptyTypeSet = new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String oppTypeValue = custSettingMap.get('Opportunity Type').Value__c;      
        for(String s : oppTypeValue.split(',')) 
        {        
            opptyTypeSet.add(s.trim());
        }
        return opptyTypeSet;
    } 
    //Added by Anjali for SSE-2721 called in  class - LeadConversionController_ConvertPage and Trigger - 
    public static Set<String> getAccountTradingStatus() {  
        Set<String> accTradingStatusSet = new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String statusValue = custSettingMap.get('Account Trading Status').Value__c;      
        for(String s : statusValue.split(',')) 
        {        
            accTradingStatusSet.add(s.trim());
        }
        return accTradingStatusSet;
    }
    public static String getOpptyTypeNBBNL() {        
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String str = custSettingMap.get('Opportunity Type NBB-NL').Value__c;             
        return str;
    }
    public static String getOpptyTypeNBBCS() {        
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String str = custSettingMap.get('Opportunity Type NBB-CS').Value__c;             
        return str;
    }
    
    /*Returns the values of 'System Transition Status' field from custom settings */  
    public static Set<String> getSystemTransitionStatus() {  
        Set<String> systemTrantStatusSet = new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String statusValue = custSettingMap.get('System Transition Status').Value__c;      
        for(String s : statusValue.split(',')) 
        {        
            systemTrantStatusSet.add(s.trim());
        }
        return systemTrantStatusSet;
    }
    
    /*Returns the values of 'Current Transition Activity' field from custom settings */  
    public static String getCurrentTransitionActivity() {        
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String str = custSettingMap.get('Current Transition Activity').Value__c;             
        return str;
    }
    
    //edited by Saloni Chhabra on 2/2/2015
    //returns the value of IM Lookup Code field for Order Line 
    //called in  trigger : ContractLine_BeforeInsert 
    public static Set<String> getIMLookupCode() 
    { 
        Set<String> OrderLineIMLookupCode = new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String statusValue = custSettingMap.get('Order Line IM lookup code').Value__c;      
        for(String s : statusValue.split(',')) {        
            OrderLineIMLookupCode.add(s.trim());
        }
        return OrderLineIMLookupCode;
        
    }
    
    
    //edited by Saloni Chhabra on 2/13/2015
    //returns the value of Booking  Availability field for TC Transition Slot
    //called in  Controller Class : TC_slotLookupCtrl
    public static String getBookingStatus() 
    { 
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings(); 
        string RegionalBooking = custSettingMap.get('Booking Availability').Value__c;
        return RegionalBooking;
        
    }
    
    //edited by Saloni Chhabra on 11/3/2016
    //returns the value of Subscription PriceBook Platform field for Opportunity Line Item
    //called in  Trigger  :  OpportunityLineItem_Afterinsert,OpportunityLineItem_AfterUpdate,OpportunityLineItem_AfterDeleteUndelete
    public static Set<String> getSubscriptionPBI() 
    { 
        Set<String> SubscriptionPBI = new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String statusValue = custSettingMap.get('Subscription PriceBook Platform').Value__c;      
        for(String s : statusValue.split(',')) {        
            SubscriptionPBI.add(s.trim());
        }
        return SubscriptionPBI;
        
    }
    
    //edited by Saloni Chhabra on 11/3/2016
    //returns the value of Subscription PriceBook Name field for Opportunity Line Item
    //called in  Trigger  : OpportunityLineItem_Afterinsert,OpportunityLineItem_AfterUpdate,OpportunityLineItem_AfterDeleteUndelete
    public static Set<String> getSubscriptionPBIName() 
    {   //Changes made by Priyank Anand for SSE-8855
        Set<String> SubscriptionPBI=new Set<String>();
        for(Subscription_Product__mdt mdRecord : [SELECT Product_Name__c FROM Subscription_Product__mdt where ADMIN_CATEGORY__c='Subscription'])
            {SubscriptionPBI.add(mdRecord.Product_Name__c);} 
        
        //Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        //String statusValue = custSettingMap.get('Subscription PriceBook Name').Value__c;      
        //for(String s : statusValue.split(',')) {        
            //SubscriptionPBI.add(s.trim());
        //}
        return SubscriptionPBI;
        
    }
    
    /*Added By :- ANJALI CHAUDHARY
      Date     :- 22-04-2015
      This method is used in trigger TalentCentralAfterUpdate 
    */
    public static void slotProvandConfTotal(List<Talent_Central__c> tcList) 
    {
        
         set<Id> slotIdsSet = new set<Id>();
         Map<Id,Integer> mapTCIdAndProv = new Map<Id,Integer>();
         Map<Id,Integer> mapTCIdAndConf = new Map<Id,Integer>();      
         if(tcList != null && tcList.size()>0) {
             for(Talent_Central__c tc : tcList) {
                 slotIdsSet.add(tc.TC_Transition_Slot__c);   
             }
         }      
        
         for(TC_Transition_Slot__c tc : [Select id,Provisional_Total__c,Confirmed_Total__c from TC_Transition_Slot__c where id in : slotIdsSet]){
             if(tc.Provisional_Total__c != null){
                 mapTCIdAndProv.put(tc.id,integer.valueof(tc.Provisional_Total__c));
             }else{
                 mapTCIdAndProv.put(tc.id,0);
             }       
             if(tc.Confirmed_Total__c != null){
                 mapTCIdAndConf.put(tc.id,integer.valueof(tc.Confirmed_Total__c));
             }else{
                 mapTCIdAndConf.put(tc.id,0);
             }    
         }    
         
         
         for(Talent_Central__c tcobj : tcList) {
             integer prov = 0;
             integer conf = 0;
            
             if(tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold') {
                 if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c) && mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c) != null){
                     prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                     mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov+1);
                 }
             }else if(tcobj.Transition_Booking_Status__c == 'Confirmed') {    
                 if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(tcobj.TC_Transition_Slot__c) && mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c) != null){
                     conf = mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c);
                     mapTCIdAndConf.put(tcobj.TC_Transition_Slot__c,conf+1);
                 }
             }   
         }  
      
         TCupdateSlotRec(mapTCIdAndProv , mapTCIdAndConf);        
     }   
     
     public static void delTCTransitionRec(List<Talent_Central__c> tcList)      
     {
         set<Id> slotIdsSet = new set<Id>();
         Map<Id,Integer> mapTCIdAndProv = new Map<Id,Integer>();
         Map<Id,Integer> mapTCIdAndConf = new Map<Id,Integer>();      
         if(tcList != null && tcList.size()>0) {
             for(Talent_Central__c tc : tcList) {
                 slotIdsSet.add(tc.TC_Transition_Slot__c);   
             }
         }      
         for(TC_Transition_Slot__c tc : [Select id,Provisional_Total__c,Confirmed_Total__c from TC_Transition_Slot__c where id in : slotIdsSet]){
             if(tc.Provisional_Total__c != null){
                 mapTCIdAndProv.put(tc.id,integer.valueof(tc.Provisional_Total__c));
             }else{
                 mapTCIdAndProv.put(tc.id,0);
             }       
             if(tc.Confirmed_Total__c != null){
                 mapTCIdAndConf.put(tc.id,integer.valueof(tc.Confirmed_Total__c));
             }else{
                 mapTCIdAndConf.put(tc.id,0);
             }    
         }  
     
         for(Talent_Central__c tcobj : tcList) {
             integer prov = 0;
             integer conf = 0;
            
             if(tcobj.Transition_Booking_Status__c == 'Provisional' || tcobj.Transition_Booking_Status__c == 'On Hold') {
                 if(mapTCIdAndProv != null && mapTCIdAndProv.containsKey(tcobj.TC_Transition_Slot__c) && mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c) != null){
                     prov = mapTCIdAndProv.get(tcobj.TC_Transition_Slot__c);
                     mapTCIdAndProv.put(tcobj.TC_Transition_Slot__c,prov-1);
                 }
             }else if(tcobj.Transition_Booking_Status__c == 'Confirmed') {    
                 if(mapTCIdAndConf != null && mapTCIdAndConf.containsKey(tcobj.TC_Transition_Slot__c) && mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c) != null){
                     conf = mapTCIdAndConf.get(tcobj.TC_Transition_Slot__c);
                     mapTCIdAndConf.put(tcobj.TC_Transition_Slot__c,conf-1);
                 }
             }   
         }  
     
         TCupdateSlotRec(mapTCIdAndProv , mapTCIdAndConf);        
     }   
     
     public static void TCupdateSlotRec(Map<Id,Integer> mapTCIdAndProv , Map<Id,Integer> mapTCIdAndConf) { 
         List<TC_Transition_Slot__c> mainListToUpdateCr = new List<TC_Transition_Slot__c>();
         List<TC_Transition_Slot__c> mainListToUpdatePr = new List<TC_Transition_Slot__c>();
         system.debug('mapTCIdAndProv ===='+mapTCIdAndProv +'mapTCIdAndConf---------'+mapTCIdAndConf);
         
         if(mapTCIdAndConf != null && mapTCIdAndConf.size() > 0){
             for(Id i : mapTCIdAndConf.keyset() ){
                 TC_Transition_Slot__c tt = new TC_Transition_Slot__c(id = i);
                 system.debug('i----------'+i);
                 tt.Confirmed_Total__c = mapTCIdAndConf.get(i);
                 system.debug('tt.Confirmed_Total__c----------'+tt.Confirmed_Total__c);
                 mainListToUpdateCr.add(tt);
             }
         }
         if(mapTCIdAndProv != null && mapTCIdAndProv.size() > 0) {
             for(Id i : mapTCIdAndProv.keyset()){
                 TC_Transition_Slot__c tt = new TC_Transition_Slot__c(id = i);
                 tt.Provisional_Total__c = mapTCIdAndProv.get(i);
                 system.debug('tt.Provisional_Total__c ----------'+tt.Provisional_Total__c );
                 mainListToUpdatePr.add(tt);
             }
         }
         system.debug('mainListToUpdatePr----'+mainListToUpdatePr+'mainListToUpdateCr-----'+mainListToUpdateCr);
         //Savepoint sp = Database.setSavepoint();

         if(mainListToUpdatePr != null && mainListToUpdatePr.size()>0) {  
             system.debug('************************');           
             //Database.DMLOptions dml = new Database.DMLOptions();
             //dml.optAllOrNone = false; // tried true also 
             //database.update(mainListToUpdatePr,dml);
            //Added by Sagar Pareek to check if the records were successfully updated or not.
            Database.SaveResult[] srList = Database.update(mainListToUpdatePr, false); 
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated TC slot. TC slot id ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('TC slot fields that affected this error: ' + err.getFields());
                    }
                }
            }
         }    
         if(mainListToUpdateCr != null && mainListToUpdateCr.size()>0) {
             system.debug('############################'); 
             //Database.DMLOptions dml = new Database.DMLOptions();
             //dml.optAllOrNone = false; // tried true also 
             //database.update(mainListToUpdateCr,dml);
             //update mainListToUpdateCr;
             //Added by Sagar Pareek to check if the records were successfully updated or not.
            Database.SaveResult[] srList = Database.update(mainListToUpdateCr, false); 
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated TC slot. TC slot id ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('TC slot fields that affected this error: ' + err.getFields());
                    }
                }
            }
         }         
         //Database.rollback(sp);
   
         system.debug('mainListToUpdatePr----'+mainListToUpdatePr+'mainListToUpdateCr-----'+mainListToUpdateCr);
     }
     
      //edited by Dimpy Kinger on 31/03/2016
    //returns  Order Line field values for Order Line Trigger-ContractLine_AfterInsertUpdate
     public static Set<String> getOrderLineItemValuesFilter2() {  
        Set<String> OLIValues = new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String oliValue = custSettingMap.get('Order Line Item Filter 2').Value__c;      
        for(String s : oliValue.split(',')) 
        {        
            OLIValues.add(s.trim());
        }
        return OLIValues ;
    }
    
    
    //edited by Dimpy Kinger on 31/03/2016
    //returns  Order Line field values for Order Line Trigger-ContractLine_AfterInsertUpdate
    public static Set<String> getOrderLineItemValuesFilter1() {  
        Set<String> OLIValues = new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String oliValue = custSettingMap.get('Order Line Item Filter 1').Value__c;      
        for(String s : oliValue.split(',')) 
        {        
            OLIValues.add(s.trim());
        }
        return OLIValues ;
    }
    
    //returns  Order Line field values for Order Line Trigger-ContractLine_AfterInsertUpdate
    public static Set<String> getOrderLineItemValuesFilter1_1() {  
        Set<String> OLIValues = new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String oliValue = custSettingMap.get('Order Line Item Filter 1_1').Value__c;      
        for(String s : oliValue.split(',')) 
        {        
            OLIValues.add(s.trim());
        }
        return OLIValues ;
    }
    
        
    //returns Order Line field values for Order Line Trigger-ContractLine_BeforeUpdate to get UserID of Ulyana Ferreira and Aiden Ware
    public static Set<String> getUlyanaFerreria() 
    {  
        Set<String> OLIValues = new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();
        system.debug('---->abc<------'+custSettingMap.get('Ulyana Aiden skip validation').Value__c);
        String oliValue = custSettingMap.get('Ulyana Aiden skip validation').Value__c;   
        for(String s : oliValue.split(',')) 
        {        
            OLIValues.add(s.trim());
        }
        
        return OLIValues ;
    }
    
    //returns Auto Renewal Values to Contract_BeforeUpdate trigger
    public static Set<String> getAutoRenewalfromOrder() 
    {  
        Set<String> OLIValues=new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String oliValue = custSettingMap.get('Auto Renewal from Order').Value__c;      
        for(String s : oliValue.split(',')) 
        {        
            OLIValues.add(s.trim());
        }
        return OLIValues ;
    }
    
    public static set<string> getreboostProducts()
    {
        
        set<string > OLIValues = new set<string>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();  
         String oliValue = custSettingMap.get('Reboost Opp Products').Value__c;      
        for(String s : oliValue.split(',')) 
        {        
            OLIValues.add(s.trim());
        }
        return OLIValues ;
    }
     
    //returns EACV values to ContractLine_AfterInsertUpdate trigger
    public static Set<String> getEACVvaluesforOrder() 
    { 
        Set<String> OLIValues=new Set<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String oliValue = custSettingMap.get('Order EACV').Value__c;      
        for(String s : oliValue.split(',')) 
        {        
            OLIValues.add(s.trim());
        }
        return OLIValues ;
    }
    
    //returns MultiYear Order line priority list to Apex class: Order_Multiyear_Calculator
    public static List<String> getMultiYearOrderLinesName() 
    {  
        List<String> OLIValues = new List<String>();
        Map<String,Multiyear_Opportunity_Product_Sequence__c> custSettingMap = getMultiYear();       
        String oliValue = custSettingMap.get('Products').Products_Sequence__c;      
        for(String s : oliValue.split(',')) 
        {        
            OLIValues.add(s.trim());
        }
        return OLIValues ;
    }
    
    //returns MultiYear Order line platform list to Apex class: Order_Multiyear_Calculator
    public static List<String> getMultiYearOrderLinesPlatform() 
    {  
        List<String> OLIValues = new List<String>();
        Map<String,Multiyear_Opportunity_Product_Sequence__c> custSettingMap = getMultiYear();       
        String oliValue = custSettingMap.get('Platforms').Products_Sequence__c;      
        for(String s : oliValue.split(',')) 
        {        
            OLIValues.add(s.trim());
        }
        return OLIValues ;
    }
    
    /*This method added by Anjali for SSE-5122 on 13th sept 2017 called in trigger - Contract_BeforeUpdate
    It returns the IM Lookup code field values priority list to set the Target Date for a mid term event.*/
    public static List<string> getSubscriptionProductSequence() {
        List<String> IMLookupCodeValues = new List<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String imcodeValue = custSettingMap.get('SubscriptionProductSequence').Value__c;      
        for(String s : imcodeValue.split(',')) 
        {        
            IMLookupCodeValues.add(s.trim());
        }
        return IMLookupCodeValues ;
    }   
    //Added by ANjali for SSE-4818 called in trigger:Milestone_BeforeUpdate 
    public static List<string> getMilestoneWatcheremail() {
        List<String> milestomeEmails = new List<String>();
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        String mWatcherEmail = custSettingMap.get('Milestone Watcher').Milestone_Email__c;
        for(String s : mWatcherEmail.split(',')) 
        {        
            milestomeEmails.add(s.trim());
        }
        return milestomeEmails ;
    }
    //Added by ANjali for SSE-4818 called in trigger:Milestone_BeforeUpdate 
    public static boolean getMWatcherChecked() {
        Map<String,Field_Value_Setting__c> custSettingMap = getFieldValueSettings();       
        boolean mWatcherchked = custSettingMap.get('Milestone Watcher').Skip_email_to_AMSmilestone__c;
        return mWatcherchked ;
    }
}
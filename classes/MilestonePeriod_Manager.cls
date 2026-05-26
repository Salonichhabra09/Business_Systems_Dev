global class MilestonePeriod_Manager{
     // This method updates the Signature_Date__c ,FC_Agent__c field on Milestone Period object when Financial_Period_Closed__c is changed/updated.
     // It also updates the record type of dependent RevenueAttributions depending upon Financial_Period_Closed__c value
     public static void MilestonePeriodUpdateChecks(List<Milestone_Period__c> MilestonePeriodNewList,List<Milestone_Period__c> MilestonePeriodOldList){
        
        List<RecordType> recordTypeLockedList = new List<RecordType>();
        List<RecordType> recordTypeUnLockedList = new List<RecordType>(); 
               
        List<RevenueAttribution__c> raList = new List<RevenueAttribution__c>();
        
        recordTypeLockedList = [select id,name from RecordType where name ='Attribution ReadOnly Record Type'];
        recordTypeUnLockedList = [select id,name from RecordType where name ='Attribution Master RecordType'];  
              
        List<Milestone_Period__c> milestonePeriodLockedList = new List<Milestone_Period__c>();
        List<Milestone_Period__c> milestonePeriodUnLockedList = new List<Milestone_Period__c>();
        
        for(Integer i=0;i<MilestonePeriodNewList.size();i++){
            if(MilestonePeriodNewList[i].Financial_Period_Closed__c != MilestonePeriodOldList[i].Financial_Period_Closed__c && MilestonePeriodNewList[i].Financial_Period_Closed__c==true){
               MilestonePeriodNewList[i].Signature_Date__c = System.today();
               MilestonePeriodNewList[i].FC_Agent__c = UserInfo.getUserId();
            }
            if(MilestonePeriodNewList[i].Financial_Period_Closed__c==true){
                milestonePeriodLockedList.add(MilestonePeriodNewList[i]);
            }
            if(MilestonePeriodNewList[i].Financial_Period_Closed__c==false){
                milestonePeriodUnLockedList.add(MilestonePeriodNewList[i]);
            }
        }
        
        for(RevenueAttribution__c ra : [select id,name from RevenueAttribution__c where Attribution_Period__r.id IN : milestonePeriodLockedList]){
            ra.recordTypeId=recordTypeLockedList[0].id;
            raList.add(ra);      
        }
        for(RevenueAttribution__c ra : [select id,name from RevenueAttribution__c where Attribution_Period__r.id IN : milestonePeriodUnLockedList]){
            ra.recordTypeId=recordTypeUnLockedList[0].id;
            raList.add(ra);      
        }      
        update raList;
      
     }  // end method
     
     // This method results in updating the Signature Date and FC Agent value before Milestone Period record is inserted and if Financial Period Closed value is true
      public static void MilestonePeriodInsertChecks(List<Milestone_Period__c> MilestonePeriodNewList){
        for(Integer i=0;i<MilestonePeriodNewList.size();i++){
            if(MilestonePeriodNewList[i].Financial_Period_Closed__c==true){
                MilestonePeriodNewList[i].Signature_Date__c = System.today();
                MilestonePeriodNewList[i].FC_Agent__c = UserInfo.getUserId();
            }
        }
      }
     
}
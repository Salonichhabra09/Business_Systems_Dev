/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND 
CREATED DATE :- 10-06-2019
DESCRIPTION :- This class contains validation, assignments and calculations of fields of Opportunity and OpportunityLineItem object, this class is called in OpportunityLineItem_Trigger.
***************************************************************************************************************************************/ 

Global class OpportunityLineItemTriggerManager {
    
     
    //This method creates future products of opportunity when current year subscription products are created
    public static void createFutureProducts(List<OpportunityLineItem> OLIs){
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.createFutureProducts START ------- ' + Limits.getQueries()); 
        set<Id> opportunityIds = new set<Id>();
        list<future_product__c> futureProductsToInsert = new list<future_product__c>();
        
        /* query not needed - it't fetching the same records as in the method param List<OpportunityLineItem> OLIs
        List<OpportunityLineItem> OLIlist = new list<OpportunityLineItem>();
        OLIlist = [SELECT Id,CurrencyChange__c ,Solution_Cap__c,
                   currencyisocode,RenewableNew__c ,Service_End_Date__c ,
                   OpportunityId,Product2Id,Basis_of_Fees__c,Quantity,Description,List_Price__c,Other__c,Package__c,Platform__c,
                   PricebookEntryId,Proposition__c,UnitPrice,Total_Equivalent_Units__c,Usage_Allowance__c ,
                   //Changes added by Prachi (SSE-SSE-17449)   
                   Number_of_Services__c,
                   //Changes End Prachi (SSE-SSE-17449)
                   Solution__c//Changes added by Joana (SSE-16464)
                   FROM OpportunityLineItem WHERE Id IN: Trigger.newMap.keySet()];
        System.debug('OLIlist** ' + OLIlist );
        */
        
        System.debug('OLIs** ' + OLIs );
        
        for(OpportunityLineItem oli : OLIs){ // replaced OLIlist by OLIs in for
            if(oli.CurrencyChange__c == false && oli.RenewableNew__c == 'Ongoing'){  // added due to currency change
                System.debug('currencychange** ' + oli.CurrencyChange__c);
                opportunityIds.add(oli.OpportunityId);
            }
        }
        
        map<id,opportunity> opportunitymap = new map<id,opportunity>();
        if(opportunityIds.size() > 0){
       		opportunitymap = new map<id,opportunity>([select id,stagename,Multi_YearDeal__c,Variation_Opportunity__c,RecordTypeId,Opportunity_Deal_Year__c 
                                                                      from opportunity 
                                                                      where id in :opportunityIds]);
        }
        
        if(opportunitymap.size() > 0){
        	for(OpportunityLineItem oli : OLIs){
                if(opportunitymap.containskey(oli.OpportunityId) &&
                   opportunitymap.get(oli.OpportunityId).Variation_Opportunity__c == 'No' &&
                   opportunitymap.get(oli.OpportunityId).RecordTypeId == '012D0000000V7oq' &&
                   integer.valueOf(opportunitymap.get(oli.OpportunityId).Multi_YearDeal__c)>1 &&
                   opportunitymap.get(oli.OpportunityId).Opportunity_Deal_Year__c == 1 &&
                   oli.RenewableNew__c == 'Ongoing'){
                    for(integer i = 2;i<=integer.valueOf(opportunitymap.get(oli.OpportunityId).Multi_YearDeal__c);i++){
                        futureProductsToInsert.add(new future_product__c(Solution_Cap__c = oli.Solution_Cap__c,
                                                                         currencyisocode = oli.currencyisocode,
                                                                         RenewableNew__c = oli.RenewableNew__c,
                                                                         Service_End_Date__c = oli.Service_End_Date__c,
                                                                         Opportunity__c = oli.OpportunityId,Product__c = oli.Product2Id,
                                                                         Quantity__c = oli.Quantity,Basis_of_Fees__c = oli.Basis_of_Fees__c,
                                                                         Contract_Year__c = string.valueOf(i),Line_Description__c = oli.Description,
                                                                         ListPrice__c = oli.List_Price__c,Other__c = oli.Other__c,
                                                                         Package__c = oli.Package__c,Platform__c = oli.Platform__c,
                                                                         Pricebook_Entry_Id__c = oli.PricebookEntryId,Proposition__c = oli.Proposition__c,
                                                                         Sales_Price__c = oli.UnitPrice,Usage_Allowance__c = oli.Usage_Allowance__c,
                                                                         Usage_Cap_or_Estimation__c = oli.Total_Equivalent_Units__c,
                                                                         Opportunity_Product_Id__c = oli.id,
                                                                        //Changes added by Prachi (SSE-SSE-17449)
                                                                         Number_of_Services__c= oli.Number_of_Services__c
                                                                        //Changes End Prachi (SSE-SSE-17449)
                                                                         ,Solution__c = oli.Solution__c//Changes added by Joana (SSE-16464)
                                                                        ));
                    }
                }
            }
        }
        if(futureProductsToInsert.size()>0){
            insert futureProductsToInsert;
        }
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.createFutureProducts END ------- ' + Limits.getQueries()); 
    }
    
    
    public static void renewabilityUpdate(Map<id,OpportunityLineItem> newmap,Map<id,OpportunityLineItem> oldmap){
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.renewabilityUpdate START ------- ' + Limits.getQueries()); 
        list<OpportunityLineItem> newSubscriptionProducts = new list<OpportunityLineItem>();
        list<OpportunityLineItem> newNonSubscriptionProducts = new list<OpportunityLineItem>();
        
        for(OpportunityLineItem oli : newmap.values()){
            system.debug(newmap.get(oli.id).RenewableNew__c);
            if(newmap.get(oli.id).RenewableNew__c == 'Ongoing' && oldmap.get(oli.id).RenewableNew__c == 'One-off'){
                system.debug('inside if');
                newSubscriptionProducts.add(oli);
                
            }
            if(newmap.get(oli.id).RenewableNew__c == 'One-off' && oldmap.get(oli.id).RenewableNew__c == 'Ongoing'){
                newNonSubscriptionProducts.add(oli);
            }
        }
        if(newSubscriptionProducts.size()>0){
            system.debug('inside function call');
            createFutureProducts(newSubscriptionProducts);
        }
        if(newNonSubscriptionProducts.size()>0){
            deleteFutureProducts(newNonSubscriptionProducts);
        }
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.renewabilityUpdate END ------- ' + Limits.getQueries()); 
    }
    
    //This function is added to delete the future products in case of multi year opportunity if a opportunity product is deleted
    public static void deleteFutureProducts(List<OpportunityLineItem> OLIs){
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.deleteFutureProducts START ------- ' + Limits.getQueries()); 
        list<OpportunityLineItem> multiYearLineItems = [select id,opportunity.change_currency__c,pricebookentryid,opportunityId from OpportunityLineItem where opportunity.Multi_YearDeal__c != '' and opportunity.Multi_YearDeal__c != '1' and opportunity.StageName != 'Verbal' and opportunity.StageName != 'Closed/Won' and opportunity.StageName != 'Closed Lost' and id in :OLIs];
        if(multiYearLineItems!= null && multiYearLineItems.size()>0){
            if(!multiYearLineItems.get(0).opportunity.change_currency__c){
                set<Id> opportunityAndPriceBookEntryIds = new set<Id>();
                for(OpportunityLineItem oli : multiYearLineItems){
                    opportunityAndPriceBookEntryIds.add(oli.id);
                    opportunityAndPriceBookEntryIds.add(oli.opportunityId);
                    system.debug('OLI'+OLI);
                }
                list<future_product__c> futureProductsToDelete = [select id from future_product__c where opportunity__c in :opportunityAndPriceBookEntryIds and Opportunity_Product_Id__c in :opportunityAndPriceBookEntryIds];
                if(futureProductsToDelete.size()>0){
                    integer i = 1;
                    for(future_product__c fp : futureProductsToDelete){
                        system.debug('fp '+i+' '+fp);
                        i++;
                    }
                    delete futureProductsToDelete;
                }
            }
        }
         System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.deleteFutureProducts END ------- ' + Limits.getQueries()); 
    }
    
    //This method is validating the stage name when user is trying to update the opportunitylineitem.
    public static void validateStageNameBeforeUpdate(List<OpportunityLineItem> OLIs,Map<id,OpportunityLineItem> oldmap){    // ADDED BY pankhuri for SSE-11575
         System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.validateStageNameBeforeUpdate START ------- ' + Limits.getQueries()); 
        set<string> Profiles = new set<string>();
        Profiles.addall(System.Label.OpptyLineItemDeleteProfiles.split(','));
        System.debug('This is label values '+Profiles);
        Profiles.addall(System.Label.Commercial_Analytic_user.split(','));
        String userprofileid=(String)UserInfo.getProfileId().substring(0,15);
        String userid=(String)UserInfo.getUserId().substring(0,15);
        System.debug('This is user profile '+userprofileid);
        if(!(Profiles.contains(userprofileid)||Profiles.contains(userid)))
        { 
            
            set<Id> oppids = new set<Id>();
            map<Id,Opportunity> oidtostagenamemap = new map<Id,Opportunity>();
            for(OpportunityLineItem oli:OLIs){
                if(oli.Debooked_Quantity__c==oldmap.get(oli.Id).Debooked_Quantity__c && oli.Debooked_Sales_Price__c ==oldmap.get(oli.Id).Debooked_Sales_Price__c)
                	oppids.add(oli.OpportunityId);
            } 
            for(Opportunity opp:[select id,stagename,Eligible_for_Auto_Close__c,Apply_Price_Increase_Switch__c   from opportunity where id in :oppids])
            {
                oidtostagenamemap.put(opp.id,opp);
            }
            for (OpportunityLineItem Op: OLIs)
            {
                //Added Eligible Auto-Close logic in if condition - Sanjeev - 16343
                if(oidtostagenamemap.containsKey(Op.OpportunityId) && oidtostagenamemap.get(Op.OpportunityId).Apply_Price_Increase_Switch__c == false && oidtostagenamemap.get(Op.OpportunityId).Eligible_for_Auto_Close__c == false && (oidtostagenamemap.get(Op.OpportunityId).StageName == System.label.Opportunity_Stage_6 || oidtostagenamemap.get(Op.OpportunityId).StageName == System.Label.Opportunity_Stage_7)){
                    //OpportunityLineItem actualRecord = OLIoldMap.get(Op.Id);
                    op.addError('Products cannot be edited if Opportunity is in Closed/Won or Closed/Lost ');
                }
                
            }
        }
                 System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.validateStageNameBeforeUpdate END ------- ' + Limits.getQueries()); 
    }
    
    //This method is validating the stage name when user is trying to delete the opportunitylineitem.
    public static void validateStageNameBeforeDelete(List<OpportunityLineItem> OLIs, Map<id,OpportunityLineItem> OLIoldMap){
                 System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.validateStageNameBeforeDelete START ------- ' + Limits.getQueries()); 
        set<string> Profiles = new set<string>();
        Profiles.addall(System.Label.OpptyLineItemDeleteProfiles.split(','));
        System.debug('This is label values '+Profiles);
        String userprofileid=(String)UserInfo.getProfileId().substring(0,15);
        System.debug('This is user profile '+userprofileid);
        if(!(Profiles.contains(userprofileid)))
        { 
            List<id> OLIIds= new List<id>();
            for(OpportunityLineItem oli:OLIs)
                OLIIds.add(oli.id);
            List <OpportunityLineItem> OppProduct = [Select id ,Opportunity.Change_Currency__c, Opportunity.StageName, Opportunity.Eligible_for_Auto_Close__c from OpportunityLineItem  where id=:OLIIds];            
            for (OpportunityLineItem Op: OppProduct )
            {
                //Added Eligible Auto-Close logic in if condition - Sanjeev - 16343
                if(op.Opportunity.Eligible_for_Auto_Close__c == false && Op.Opportunity.Change_Currency__c == false && (Op.Opportunity.StageName== System.label.Opportunity_Stage_5 || Op.Opportunity.StageName== System.label.Opportunity_Stage_6 || Op.Opportunity.StageName== System.Label.Opportunity_Stage_7)){
                    OpportunityLineItem actualRecord = OLIoldMap.get(Op.Id);
                    actualRecord.addError('Products cannot be deleted after Opportunity is in verbal. ');
                }
                
            }
        }
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.validateStageNameBeforeDelete END ------- ' + Limits.getQueries()); 
    }
    
     //This method is creating Jobs when a Managed service product is added in an opportunity.
    public static void createJobs(List<OpportunityLineItem> OLIs){
        Set<ID> OppMSSet = new Set<ID>();
        Set<ID> Product2IdSet = new Set<ID>();
        Map<ID, Set<Id>> oppProductMap = new Map<ID, Set<Id>>();
        Map<ID, Set<String>> oppProductMSTypeMap = new Map<ID, Set<String>>();
        AutomaticJobCreation__c cs = AutomaticJobCreation__c.getValues('Values');
        List<String> msTypeValuesList= cs.MS_Line_of_Business__c.trim().split(',');
        Set<String> msTypeValuesSet= new Set<String>(msTypeValuesList);
        for(OpportunityLineItem OLI:OLIs){
            if(OLI.ms_product__c==true){
                OppMSSet.add(OLI.opportunityID);
                Product2IdSet.add(OLI.Product2Id);
                if(!oppProductMap.containsKey(OLI.OpportunityID)){
                    Set<Id> pdIDSet =new Set<Id>{OLI.Product2Id};
                    oppProductMap.put(OLI.OpportunityID,pdIDSet);
                }else{
                    oppProductMap.get(OLI.OpportunityID).add(OLI.Product2Id);
                    oppProductMap.put(OLI.OpportunityID,oppProductMap.get(OLI.OpportunityID));   
                }
            }
        }
         
         for(Product2 pd :[Select id,MS_Type__c from Product2 where id in: Product2IdSet and MS_Type__c in: msTypeValuesSet]){
             for(Id oppId: oppProductMap.KeySet()){
                 Set<Id> productSet =oppProductMap.get(oppId);
                 if(productSet.contains(pd.id)){
                     if(!oppProductMSTypeMap.containsKey(oppId)){
                       Set<String> msTypeSet =new Set<String>{pd.MS_Type__c};
                       oppProductMSTypeMap.put(oppId,msTypeSet);
                     }else if(!oppProductMSTypeMap.get(oppId).contains(pd.MS_Type__c)){
                       oppProductMSTypeMap.get(oppId).add(pd.MS_Type__c);
                       oppProductMSTypeMap.put(oppId,oppProductMSTypeMap.get(oppId));   
                     }
                 }
            }
        }
        
        if(OppMSSet.size() > 0){
            Map<ID, Set<String>> map_oppName_jobCount = new Map<ID,Set<String>>();
            for(Job__c jb: [Select id,Opportunity__c,MS_Line_of_Business__c from Job__c where Opportunity__c in: OppMSSet and MS_Line_of_Business__c in: msTypeValuesSet]){
                if(!map_oppName_jobCount.containsKey(jb.Opportunity__c)){
                        Set<String> msTypeSet =new Set<String>{jb.MS_Line_of_Business__c};
                        map_oppName_jobCount.put(jb.Opportunity__c,msTypeSet);
                    }else if(!map_oppName_jobCount.get(jb.Opportunity__c).contains(jb.MS_Line_of_Business__c)){
                        map_oppName_jobCount.get(jb.Opportunity__c).add(jb.MS_Line_of_Business__c);
                        map_oppName_jobCount.put(jb.Opportunity__c, map_oppName_jobCount.get(jb.Opportunity__c));   
                    }
            }
            
            List<Job__c> lCreateJob = new List<Job__c>();
            Map<id,Opportunity> OppMapJob=new map<id,Opportunity>([select id,name,ownerid,AccountId,Account_LBU__c from Opportunity where id in : OppMSSet and Probability >=50]);  //SSE-8227  
            if(OppMapJob.keyset().size() > 0){
                Id pipelineRecordTypeId = System.Label.Managed_Service_Pipeline_RecordType_Id;
                System.debug('pipelinerecordid is '+pipelineRecordTypeId);
                for(String oid : OppMapJob.keyset()){
                    if(OppMapJob.get(oid) != null && oppProductMSTypeMap.get(oid) != null){
                        Opportunity opRec = OppMapJob.get(oid);
                        if(map_oppName_jobCount.get(oid)!=null)
                           oppProductMSTypeMap.get(oid).removeAll(map_oppName_jobCount.get(oid)) ;
                            
                        for(String msType : oppProductMSTypeMap.get(oid)){ // <-- SSE-16766 Automatic Job Creation Process
                         Job__c j = new Job__c();
                         j.recordTypeId = pipelineRecordTypeId;
                         j.Opportunity__c = oid;
                         j.Project_Name__c = opRec.name;
                         j.JobStatus__c = 'UnConfirmed';
                         j.InternalContact__c = opRec.ownerId;
                         j.Is_Auto_Pipeline_Job__c=true;
                         j.MS_Line_of_Business__c=msType;
                         if(opRec.Account_LBU__c=='CN1'){
                            j.Job_Region__c='China';
                        }
                             else if(opRec.Account_LBU__c=='HK1'){
                            j.Job_Region__c='Hong Kong';
                        }
                             else if(opRec.Account_LBU__c=='SG1'){
                            j.Job_Region__c='Singapore';
                        }
                        else{
                            j.Job_Region__c='Non China';
                        }
                         if(opRec.accountId != null) j.Account__c = opRec.accountId;
                         lCreateJob.add(j); 
                        }     
                    }
                }
                
                if(lCreateJob.size() > 0) 
                    insert lCreateJob;
            }
            
        }

        }
    
    public static void deleteOppLineItemOnDeleteRequired(Map<id,OpportunityLineItem> newmap){
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.deleteOppLineItemOnDeleteRequired START ------- ' + Limits.getQueries()); 
        list<Id> oppProductToDelete = new list<Id>();
        list<OpportunityLineItem> validOppProduct = [Select Id,Opportunity.RecordType.DeveloperName From OpportunityLineItem WHERE Id in :newmap.keySet() AND (Opportunity.RecordType.DeveloperName='Configurator_Opportunity' OR Opportunity.RecordType.DeveloperName='GCSC_Opportunity')];
        for(OpportunityLineItem lineItem : validOppProduct){
            if(newmap.get(lineItem.Id).Delete_Required__c == true){
                oppProductToDelete.add(lineItem.Id);      
            }
        }
        if(oppProductToDelete.size()>0){
            Database.delete(oppProductToDelete);
        }
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.deleteOppLineItemOnDeleteRequired END ------- ' + Limits.getQueries()); 
    }
    
       //SSE-18243 : Used in calculating the Overall Complexity on Opportunity
    public static void updateRAGOptionValue(List<OpportunityLineItem> OLIs){
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.updateRAGOptionValue START ------- ' + Limits.getQueries()); 
        if(OLIs!= null) {
            for(OpportunityLineItem oli : OLIs){
               if(oli.RAG_Indicator__c != null && oli.RAG_Indicator__c.contains('Red')){oli.RAG_Option_Value__c = 'High';}
                else if(oli.RAG_Indicator__c != null && oli.RAG_Indicator__c.contains('Green')){oli.RAG_Option_Value__c = 'Light';}
                 else if(oli.RAG_Indicator__c != null && oli.RAG_Indicator__c.contains('Amber')){oli.RAG_Option_Value__c = 'Medium';}
               
            }
        }
        System.debug('Number of Queries used -- OpportunityLineItemTriggerManager.updateRAGOptionValue END ------- ' + Limits.getQueries()); 
    }
    
    /**************************** Below this is all the methods not in use *****************************************/
    //This method is validating start date and end date fields for Subsription product.
    /*public static void validateDate(List<OpportunityLineItem> newOLIs){
        Set<Id> priceBookEntryIdsSet = new Set<Id>();
        for(OpportunityLineItem newOLI:newOLIs)
            priceBookEntryIdsSet.add(newOLI.PricebookEntryId);
        Map<Id,Pricebookentry> priceBookEntryMap = new Map<Id,Pricebookentry>([SELECT id,Name,Pricebook2Id,Product2.Revenue_Category__c FROM PricebookEntry where id in:priceBookEntryIdsSet]);
        for(OpportunityLineItem newOLI:newOLIs)
        {
            if(priceBookEntryMap!=null && priceBookEntryMap.get(newOLI.PricebookEntryId)!=null && priceBookEntryMap.get(newOLI.PricebookEntryId).Product2.Revenue_Category__c == 'Subscription')
            {
                if(newOLI.Start_Date__c == null)
                    newOLI.Start_Date__c.addError('Start Date is required if the Product\'s Revenue Category is Subscription');
                if(newOLI.End_Date__c == null)
                    newOLI.End_Date__c.addError('End Date is required if the Product\'s Revenue Category is Subscription');
            }
        }
    }*/
    
    //This method is updating fields related to subscription/unsubscription amount/days of opportunity when opportunitylineitem is updated.
   /* public static void updateOpportunity(List<OpportunityLineItem> OLIs,Map<id,OpportunityLineItem> OLIoldMap) {
        Set<ID> opportunityIdsSet = new Set<ID>();
        for(OpportunityLineItem orderlineItem:OLIs)
            opportunityIdsSet.add(orderlineItem.opportunityID);
        Map<Id,Opportunity> opportunityProductLinesMap = new Map<Id,Opportunity>([SELECT id,Days_remaining_from_annual_subscription__c,Running_total_of_non_subscription_amount__c,
                                                                                  Running_total_of_subscription_amount__c,Running_total_of_subscription_days__c,
                                                                                  (Select id,Duration_days__c, Duration_Day_Amount__c,End_Date__c,Start_Date__c,TotalPrice,PriceBookEntry.Product2.Revenue_Category__c  
                                                                                   FROM OpportunityLineItems ORDER BY Start_Date__c asc) 
                                                                                  from Opportunity where id in :opportunityIdsSet]);
        
        
        
        if(opportunityProductLinesMap!=null && opportunityProductLinesMap.size()>0)
        {
            for(Opportunity opportunity:opportunityProductLinesMap.values())
            {
                opportunity.Days_remaining_from_annual_subscription__c = 365;
                opportunity.Running_total_of_subscription_amount__c = 0;
                opportunity.Running_total_of_subscription_days__c = 0;
                opportunity.Running_total_of_non_subscription_amount__c = 0;
                for(OpportunityLineItem opportunityLine:opportunity.OpportunityLineItems)
                {
                    
                    if(opportunityLine.PriceBookEntry.Product2.Revenue_Category__c=='Subscription')
                    {
                        if(opportunityLine.Start_Date__c == null || opportunityLine.End_Date__c == null)
                            continue;
                        Double durationDaysAmount = 0;
                        if(opportunityLine.TotalPrice!=0)
                            durationDaysAmount = opportunityLine.TotalPrice / opportunityLine.Duration_Days__c;
                        if(opportunity.Days_remaining_from_annual_subscription__c>0)
                        {
                            if(opportunity.Days_remaining_from_annual_subscription__c - opportunityLine.Duration_days__c >0 || opportunity.Days_remaining_from_annual_subscription__c - opportunityLine.Duration_days__c == 0)
                            {
                                if(opportunityLine.TotalPrice!=0)
                                    opportunity.Running_total_of_subscription_amount__c+=opportunityLine.Duration_days__c*durationDaysAmount;
                                opportunity.Running_total_of_subscription_days__c+=opportunityLine.Duration_days__c;
                                opportunity.Days_remaining_from_annual_subscription__c = opportunity.Days_remaining_from_annual_subscription__c-opportunityLine.Duration_days__c;
                            }
                            else
                            {
                                if(opportunityLine.TotalPrice!=0)
                                    opportunity.Running_total_of_subscription_amount__c+=opportunity.Days_remaining_from_annual_subscription__c*durationDaysAmount;
                                opportunity.Running_total_of_subscription_days__c+=opportunity.Days_remaining_from_annual_subscription__c;
                                opportunity.Days_remaining_from_annual_subscription__c = 0;
                                opportunity.Skip_Validation__c=True;
                            }
                        }
                    }
                    else
                        opportunity.Running_total_of_non_subscription_amount__c+=opportunityLine.TotalPrice;
                    opportunity.Skip_Validation__c=True;
                }
            }
            try{
                update opportunityProductLinesMap.values();
            }
            catch(Exception e)
            {
                List<id> OLIIds= new List<id>();
                for(OpportunityLineItem oli:OLIs)
                    OLIIds.add(oli.id);
                List <OpportunityLineItem> OppProduct = [Select id , Opportunity.StageName from OpportunityLineItem  where id=:OLIIds];
                for (OpportunityLineItem Op: OppProduct )
                {                 
                    OpportunityLineItem actualRecord = OLIoldMap.get(Op.Id);
                    actualRecord.addError(e.getMessage());
                }
            }
        }
    }*/
    
  
    
    //This method is validating the stage name when user is trying to insert the opportunitylineitem.
   /* public static void validateStageNameBeforeInsert(List<OpportunityLineItem> OLIs){
        set<string> Profiles = new set<string>();
        Profiles.addall(System.Label.OpptyLineItemDeleteProfiles.split(','));
        //System.debug('This is label values '+Profiles);
        String userprofileid=(String)UserInfo.getProfileId().substring(0,15);
        //System.debug('This is user profile '+userprofileid);
        if(!(Profiles.contains(userprofileid)))
        { 
            set<id> oppids = new set<id>();
            for(OpportunityLineItem oli:OLIs)
                oppids.add(oli.opportunityid);
            map<ID,Opportunity> relatedOppMap = new map<ID,Opportunity>([Select id ,Change_Currency__c,StageName from Opportunity  where id IN :oppids]);            
            for (OpportunityLineItem Oli: OLIs)
            {
                if(relatedOppMap.get(Oli.opportunityid).Change_Currency__c == false && (relatedOppMap.get(Oli.opportunityid).StageName== System.label.Opportunity_Stage_5 || relatedOppMap.get(Oli.opportunityid).StageName== System.label.Opportunity_Stage_6 || relatedOppMap.get(Oli.opportunityid).StageName== System.Label.Opportunity_Stage_7)){
                    Oli.addError('Products cannot be added after Opportunity is in verbal ');
                }
                
            }
        }
    }*/
    
    
    
    //This method is calling calculateEacv method when opportunitylineitems are updated.
   /* public static void calculateEacv(List<OpportunityLineItem> OLIs,Map<id,OpportunityLineItem> OLIMap) {
        if(Utility.EACVFlag == true)
        {
            Map<string,list<decimal>> map2 = new Map<string,list<decimal>>();
            Map<string,decimal> RemainingDaysMap = new Map<string,decimal>();
            Map<string,list<decimal>> map2Name = new Map<string,list<decimal>>();
            Map<string,decimal> RemainingDaysMapName = new Map<string,decimal>();
            
            Set<ID> OppSet = new Set<ID>();
            for(OpportunityLineItem orderlineItem:OLIs)
                OppSet.add(orderlineItem.opportunityID);
            
            Map<Id,Opportunity> opportunityProductLinesMap = new Map<Id,Opportunity>([SELECT id,Skip_Validation__c,Days_remaining_from_annual_subscription__c,Running_total_of_non_subscription_amount__c,
                                                                                      Running_total_of_subscription_amount__c,Running_total_of_subscription_days__c,Earliest_Start_Date__c,Earliest_Start_Date_Plus_Leap_Year__c,
                                                                                      (Select Related_Product__c,CreatedDate,id,Platform__c,Duration_days__c, Duration_Day_Amount__c,End_Date__c,Start_Date__c,UnitPrice,Quantity,TotalPrice,PriceBookEntry.Product2.Revenue_Category__c  
                                                                                       FROM OpportunityLineItems ORDER BY Start_Date__c asc) 
                                                                                      from Opportunity where id in :OppSet]);
            
            
            
            if(opportunityProductLinesMap!=null && opportunityProductLinesMap.size()>0)
            {
                try{
                    OpportunityLineItem_EACV.EACV_Opportunity(opportunityProductLinesMap,map2,RemainingDaysMap,map2Name,RemainingDaysMapName);   
                }
                catch(Exception e)
                {List<id> OLIIds= new List<id>();
                 for(OpportunityLineItem oli:OLIs)
                     OLIIds.add(oli.id);
                 List <OpportunityLineItem> OppProduct = [Select id , Opportunity.StageName from OpportunityLineItem  where id=:OLIIds];
                 for (OpportunityLineItem Op: OppProduct )
                 {
                     OpportunityLineItem actualRecord =OLIMap.get(Op.Id);
                     actualRecord.addError(e.getMessage());
                 }
                }
            }   
        }
        
        
    }*/
    
   
    
    //This method is updating start date and end date of subscription products when any renewal opportunity is created.
   /* public static void updateStartEndDateOnRenewal(List<OpportunityLineItem> OLIs){
        List<Opportunity> ListRenewalOpp= new List<Opportunity>();
        Set<ID> OppSet = new Set<ID>();
        LIST<OpportunityLineItem> ListOLI=new List<OpportunityLineItem>();
        for(OpportunityLineItem OLI:OLIs){
            OppSet.add(OLI.opportunityID);
        }        
        Map<id,Opportunity> OppMap=new map<id,Opportunity>([select o.id, o.Original_opportunity__c from Opportunity o where id in : OppSet and Renewal_Opportunity__c =True and Business_Type__c = 'Renewal' and HasOpportunityLineItem=False]);
        if(OppMap.size()>0)
        {
            for(OpportunityLineItem OL: OLIs )
            {           
                if(OL.Start_Date__c != null && OL.End_Date__c != null )
                { 
                    OpportunityLineItem OLI=new OpportunityLIneItem(id=OL.id); 
                    integer duration =  OL.Start_Date__c.daysBetween(OL.End_Date__c);
                    OLI.Start_Date__c=OL.End_Date__c + 1;
                    OLI.End_Date__c = OL.End_Date__c + 1+ duration;
                    ListOLI.add(OLI);
                }
            }
            if(ListOLI.size()>0)
                Update ListOLI;
        }
    }*/
        
    
    //This method throws error when user is trying to add a product to opportunity which already exists under that opportunity
   /* public static void duplicateProductError(List<OpportunityLineItem> OLIs){
        list<OpportunityLineItem> currentlineitems = [select product2id,opportunityid from OpportunityLineItem where opportunityid = :OLIs.get(0).opportunityid];
        for(integer i = 0;i<OLIs.size();i++){
            for(integer j = 0;j<OLIs.size();j++){
                if(i != j && OLIs.get(j).product2id == OLIs.get(i).product2id && OLIs.get(i).opportunityid == OLIs.get(j).opportunityid){
                    OLIs.get(i).addError('Duplicate products cannot be added ');
                }
            }
        }
        for(integer i = 0;i<OLIs.size();i++){
            for(integer j = 0;j<currentlineitems.size();j++){
                if(OLIs.get(i).product2id == currentlineitems.get(j).product2id && OLIs.get(i).opportunityid == currentlineitems.get(j).opportunityid){
                    OLIs.get(i).addError('Duplicate products cannot be added ');
                }
            }
        }
    }*/
    
    //This method updates future products of opportunity when current year products are updated
   /* public static void syncFutureProducts(List<OpportunityLineItem> OLIs){
        set<Id> opportunityIds = new set<Id>();
        for(OpportunityLineItem oli : OLIs){
            opportunityIds.add(oli.OpportunityId);
        }
        list<future_product__c> FPList = [select Basis_of_Fees__c,Other__c,Booking_Type__c,Hiring_Need__c,Discount_Percent__c,Level__c,Line_Description__c,Package__c,Package_Level__c,Platform__c,Pricebook_Entry_Id__c,Proposition__c,Talent_Level__c,Usage_Allowance__c,Usage_Cap_or_Estimation__c,Volume__c from future_product__c where Opportunity__c IN :opportunityIds];
        if(FPList.size()>0){
        list<future_product__c> FPListToUpdate = new list<future_product__c>();
        map<Id,list<future_product__c>> pbkidToFPMap = new map<Id,list<future_product__c>>();
        for(future_product__c fp : FPList){
            if(pbkidToFPMap.containsKey(fp.Pricebook_Entry_Id__c)){
                pbkidToFPMap.get(fp.Pricebook_Entry_Id__c).add(fp);
            }
            else{
                pbkidToFPMap.put(fp.Pricebook_Entry_Id__c,new list<future_product__c>{fp});
            }
        }
        for(OpportunityLineItem oli : OLIs){
            for(future_product__c fp : pbkidToFPMap.get(oli.PricebookEntryId)){
                    fp.Basis_of_Fees__c = oli.Basis_of_Fees__c;
                    fp.Other__c = oli.Other__c;
                    fp.Booking_Type__c = oli.Booking_Type__c;
                    fp.Hiring_Need__c = oli.Hiring_Need__c;                    
                    fp.Level__c = oli.Level__c;
                    fp.Line_Description__c = oli.Description;
                    fp.Package__c = oli.Package__c;
                    fp.Package_Level__c = oli.Package_Level__c;
                    fp.Platform__c = oli.Platform__c;
                    fp.Proposition__c = oli.Proposition__c;
                    fp.Talent_Level__c = oli.Talent_Level__c;
                    fp.Usage_Allowance__c = oli.Usage_Allowance__c;
                    fp.Usage_Cap_or_Estimation__c = oli.Usage_Cap_or_Estimation__c;
                    fp.Volume__c = oli.Volume__c;
                    FPListToUpdate.add(fp);    
            }
        }
        
        if(FPListToUpdate.size()>0){
            update FPListToUpdate;
        }
        }
    }*/
    
    public static void updateSmartSheetFieldOnInsert(List<OpportunityLineItem> NewOLIs){
        List<OpportunityLineItem> PSOLIs = new List<OpportunityLineItem>();
        for(OpportunityLineItem OLI:NewOLIs){
            if(OLI.Product_Services_Stream__c=='Professional Services'){
                PSOLIs.add(OLI);
            }
        }
        if(PSOLIs.size()>0){
            Map<Id,List<OpportunityLineItem>> OppAndLineitemsMap = new Map<Id,List<OpportunityLineItem>>();
            Map<Id,OpportunityLineItem> OLIMap = new map<Id,OpportunityLineItem> ([select id,Opportunity.SmartSheetField__c,Product2.name,Product2.Product_Number__c from OpportunityLineItem where id in:NewOLIs and Product2.Revenue_Category__c='Professional Services']);
            List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
            for(OpportunityLineItem oli:PSOLIs){
                if(OppAndLineitemsMap.containsKey(oli.OpportunityId)){
                    List<OpportunityLineItem> OLIList = OppAndLineitemsMap.get(oli.OpportunityId);
                    OLIList.add(oli);
                    OppAndLineitemsMap.put(oli.OpportunityId,OLIList);
                }
                else{
                    List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>();
                    OLIList.add(oli); 
                    OppAndLineitemsMap.put(oli.OpportunityId,OLIList); 
                }
            }
            for(Id oppId:OppAndLineitemsMap.keyset()){
                String SmartSheetFieldValue = OLIMap.get(OppAndLineitemsMap.get(oppId)[0].Id).Opportunity.SmartSheetField__c;
                //System.debug('Field Value '+SmartSheetFieldValue);
                Opportunity opp = new Opportunity(Id=oppId);
                for(OpportunityLineItem OLI:OppAndLineitemsMap.get(oppId)){
                    System.debug('Name Value '+(OLIMap.get(OLI.Id).Product2.Product_Number__c));
                    if(SmartSheetFieldValue==null){
                        SmartSheetFieldValue = OLIMap.get(OLI.Id).Product2.Product_Number__c;
                    }
                    else{
                        SmartSheetFieldValue = SmartSheetFieldValue + ',' + OLIMap.get(OLI.Id).Product2.Product_Number__c;
                    }  
                }
                opp.SmartSheetField__c = SmartSheetFieldValue;
                OpportunitiesToUpdate.add(opp);
            }
            update OpportunitiesToUpdate;
        }
        
    }
    
    public static void updateSmartSheetFieldOnDelete(List<OpportunityLineItem> OLIs){
        List<OpportunityLineItem> PSOLIs = new List<OpportunityLineItem>();
        for(OpportunityLineItem OLI:OLIs){
            if(OLI.Product_Services_Stream__c=='Professional Services'){
                PSOLIs.add(OLI);
            }
        }
        if(PSOLIs.size()>0){
            Map<Id,List<OpportunityLineItem>> OppAndLineitemsMap = new Map<Id,List<OpportunityLineItem>>();
            Map<Id,OpportunityLineItem> OLIMap = new map<Id,OpportunityLineItem> ([select id,Opportunity.SmartSheetField__c,Product2.name,Product2.Product_Number__c from OpportunityLineItem where id in:OLIs and Product2.Revenue_Category__c='Professional Services']);
            System.debug('Map Value '+OLIMap);
            List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
            for(OpportunityLineItem oli:PSOLIs){
                if(OppAndLineitemsMap.containsKey(oli.OpportunityId)){
                    List<OpportunityLineItem> OLIList = OppAndLineitemsMap.get(oli.OpportunityId);
                    OLIList.add(oli);
                    OppAndLineitemsMap.put(oli.OpportunityId,OLIList);
                }
                else{
                    List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>();
                    OLIList.add(oli); 
                    OppAndLineitemsMap.put(oli.OpportunityId,OLIList); 
                }
            }
            for(Id oppId:OppAndLineitemsMap.keyset()){
                String SmartSheetFieldValue = OLIMap.get(OppAndLineitemsMap.get(oppId)[0].Id).Opportunity.SmartSheetField__c;
                System.debug('Field Value '+SmartSheetFieldValue);
                Opportunity opp = new Opportunity(Id=oppId);
                List<String> FieldValueList = SmartSheetFieldValue.split(',');
                for(OpportunityLineItem OLI:OppAndLineitemsMap.get(oppId)){
                    if(SmartSheetFieldValue.contains(OLIMap.get(OLI.Id).Product2.Product_Number__c)){
                        for(String value:FieldValueList){
                            if(value==OLIMap.get(OLI.Id).Product2.Product_Number__c){
                                FieldValueList.remove(FieldValueList.indexof(value));
                                break;
                            }
                        }
                        System.debug('Value '+FieldValueList);  
                    }
                }
                opp.SmartSheetField__c = String.join(FieldValueList,',');
                OpportunitiesToUpdate.add(opp);
            }
            update OpportunitiesToUpdate;
        }
    }
    
    /*public static void checkPricesForRenewalsOnInsert(List<OpportunityLineItem> OLIs){
        Map<Id,List<OpportunityLineItem>> variationOppAndLinesMap = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,List<OpportunityLineItem>> OriginalOppAndLinesMap = new Map<Id,List<OpportunityLineItem>>();
        List<OpportunityLineItem> OriginalOppsProducts =  new List<OpportunityLineItem>();
        for(OpportunityLineItem OLI:OLIs){
            if(variationOppAndLinesMap.containsKey(OLI.OpportunityId)){
                variationOppAndLinesMap.get(OLI.OpportunityId).add(OLI);
            }
            else{
                List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>();
                OLIList.add(OLI);
                variationOppAndLinesMap.put(OLI.OpportunityId,OLIList);
            }
        }
        List<Opportunity> RenewalOpps = new List<Opportunity>([Select id,Business_Type__c,StageName,Original_Opportunity__c from opportunity
                                                   where id in :variationOppAndLinesMap.KeySet() and StageName!='Closed/Won'
                                                   and StageName!='Closed Lost' and Variation_Opportunity__c='Yes']);
        
        if(RenewalOpps.size()>0){
            List<Id> OriginalOppsIds = new List<Id>();
            For(Opportunity renewalOpp:RenewalOpps){
                OriginalOppsIds.add(renewalOpp.Original_Opportunity__c);
            }
           OriginalOppsProducts =  [select id,UnitPrice,Product2Id,OpportunityId,Package__c,Description,Basis_of_Fees__c from OpportunityLineItem
                                                                   where OpportunityId in:OriginalOppsIds];       
        if(OriginalOppsProducts.size()>0){
            for(OpportunityLineItem OLI:OriginalOppsProducts){
            if(OriginalOppAndLinesMap.containsKey(OLI.OpportunityId)){
                OriginalOppAndLinesMap.get(OLI.OpportunityId).add(OLI);
            }
            else{
                List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>();
                OLIList.add(OLI);
                OriginalOppAndLinesMap.put(OLI.OpportunityId,OLIList);
            }
        }
        }
            for(Opportunity renwalOpp:RenewalOpps){
                for(OpportunityLineItem renewalOLI:variationOppAndLinesMap.get(renwalOpp.Id)){
                    for(OpportunityLineItem originalOLI:OriginalOppAndLinesMap.get(renwalOpp.Original_Opportunity__c)){
                        if(originalOLI.Product2Id==renewalOLI.Product2Id && originalOLI.Package__c==renewalOLI.Package__c &&
                           originalOLI.Description==renewalOLI.Description &&
                          originalOLI.Basis_of_Fees__c==renewalOLI.Basis_of_Fees__c){
                            if(originalOLI.UnitPrice<=renewalOLI.UnitPrice)
                                continue;
                            else
                               renewalOLI.addError('Price cannot be less than the Original Opp Price'); 
                               
                        }
                    }
                }
            }
        }
        
    } */
    
    /*public static void checkPricesForRenewalsOnUpdate(List<OpportunityLineItem> OldOLIs,List<OpportunityLineItem> NewOLIs){
        List<OpportunityLineItem> oLIsToWorkUpon = new List<OpportunityLineItem>();
        for(Integer i=0;i<OldOLIs.size();i++){
            if(OldOLIs[i].unitprice!=NewOLIs[i].unitprice){
                oLIsToWorkUpon.add(NewOLIs[i]);
            }
        }
        if(oLIsToWorkUpon.size()>0){
            Map<Id,List<OpportunityLineItem>> variationOppAndLinesMap = new Map<Id,List<OpportunityLineItem>>();
            Map<Id,List<OpportunityLineItem>> OriginalOppAndLinesMap = new Map<Id,List<OpportunityLineItem>>();
            List<OpportunityLineItem> OriginalOppsProducts =  new List<OpportunityLineItem>();
            for(OpportunityLineItem OLI:oLIsToWorkUpon){
                if(variationOppAndLinesMap.containsKey(OLI.OpportunityId)){
                    variationOppAndLinesMap.get(OLI.OpportunityId).add(OLI);
                }
                else{
                    List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>();
                    OLIList.add(OLI);
                    variationOppAndLinesMap.put(OLI.OpportunityId,OLIList);
                }
            }
            List<Opportunity> RenewalOpps = new List<Opportunity>([Select id,Business_Type__c,StageName,Original_Opportunity__c from opportunity
                                                                   where id in :variationOppAndLinesMap.KeySet() and StageName!='Closed/Won'
                                                                   and StageName!='Closed Lost' and Variation_Opportunity__c='Yes']);
            
            if(RenewalOpps.size()>0){
                List<Id> OriginalOppsIds = new List<Id>();
                For(Opportunity renewalOpp:RenewalOpps){
                    OriginalOppsIds.add(renewalOpp.Original_Opportunity__c);
                }
                OriginalOppsProducts =  [select id,UnitPrice,Product2Id,OpportunityId,Package__c,Description,Basis_of_Fees__c from OpportunityLineItem
                                         where OpportunityId in:OriginalOppsIds];       
                if(OriginalOppsProducts.size()>0){
                    for(OpportunityLineItem OLI:OriginalOppsProducts){
                        if(OriginalOppAndLinesMap.containsKey(OLI.OpportunityId)){
                            OriginalOppAndLinesMap.get(OLI.OpportunityId).add(OLI);
                        }
                        else{
                            List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>();
                            OLIList.add(OLI);
                            OriginalOppAndLinesMap.put(OLI.OpportunityId,OLIList);
                        }
                    }
                }
                for(Opportunity renwalOpp:RenewalOpps){
                    for(OpportunityLineItem renewalOLI:variationOppAndLinesMap.get(renwalOpp.Id)){
                        for(OpportunityLineItem originalOLI:OriginalOppAndLinesMap.get(renwalOpp.Original_Opportunity__c)){
                            if(originalOLI.Product2Id==renewalOLI.Product2Id && originalOLI.Package__c==renewalOLI.Package__c &&
                              originalOLI.Description==renewalOLI.Description &&
                              originalOLI.Basis_of_Fees__c==renewalOLI.Basis_of_Fees__c ){
                                if(originalOLI.UnitPrice<=renewalOLI.UnitPrice)
                                    continue;
                                else
                                  renewalOLI.addError('Price cannot be less than the Original Opp Price');
                                    
                            }
                        }
                    }
                }
            }
            
        }   
    }*/
    
}
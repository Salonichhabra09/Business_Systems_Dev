/**************************************************************************************************************************************
CREATED BY :- PRIYANK ANAND 
CREATED DATE :- 22-07-2019
DESCRIPTION :- This class contains various validations and assignments on fields of Opportunity object, this class is called in Opportunity_Trigger.
***************************************************************************************************************************************/ 

Global class OpportunityTriggerManager {
    
    //This method is locking Opportunities on Closed/won && Closed Lost stage, only system admins profile allowed to edit opportunities else error is thrown.
    public static void LockOnClosedWon_LostStage(Map<id,Opportunity> OldOpportunitiesMap,Map<id,Opportunity> NewOpportunitiesMap,List<Opportunity> NewOpportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.LockOnClosedWon_LostStage START ------- ' + Limits.getQueries());
        boolean isOAT = false;
        set<string> Profiles = new set<string>();
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        Profiles.addall(System.Label.SystemAdminProfiles.split(','));
        // Profiles.addall(System.Label.OATsProfiles.split(','));
        String userprofileid=(String)UserInfo.getProfileId().substring(0,15); 
        
        Set<ID> OrderOpportunityIdsSet = new Set<ID>();
        Set<ID> opportunityIdsSet = new Set<ID>();
        List <Order> olist = new list<Order>();
        List<Opportunity> opplistnew  = new list<Opportunity>();       
        Set<ID> ContactIdSet = new Set<ID>(); // positive set of contact that are part of account
        Set<id> AccountIdSet = new set<id>();
        Map<Id,List<Contact>> mapAccountContact = new Map<Id,List<Contact>>();
        String OAT_profile = Label.OAT_profile;  // added by Saloni
        Boolean hasOATsPermission = FeatureManagement.checkPermission('OATs'); // Added by Jai for SSE-24406
        //Profile OATPr = [select id from profile where name ='OAT'Limit 1];  // Commented by Saloni for SOQL limit
        system.debug('--->OAT_profile<---'+OAT_profile);
        
        if(hasOATsPermission==true)
            isOAT = true;
        System.debug('Aashi NewOpportunities --> '+NewOpportunities.size());
        for(Opportunity opp : NewOpportunities){
            if(opp.StageName == 'Closed/Won' || opp.StageName == 'Closed Lost'){            
                opportunityIdsSet.add(opp.ID);
                /*if(opp.StageName == 'Closed Lost'){
System.debug('insideclosedlost');
opp.RecordTypeId = System.label.ReadOnlyRecordType;
}*/
            }
            System.debug('Billing contact** ' + opp.Billing_Contact__c);
            if(opp.Billing_Contact__c != null){
                AccountIdSet.add(opp.AccountId);
                System.debug('AccountIdSet** ' + AccountIdSet);
            }    
            System.debug('actualId** ' + opportunityIdsSet);
        }
        System.debug('AccountIdSet** ' + AccountIdSet.size());
        if(AccountIdSet != null && AccountIdSet.size()!=0 && opportunityIdsSet.size()>0){
            System.debug('set**' + AccountIdSet);
            List<Account> acclist = [Select id,(Select Id from Contacts) from Account where Id IN: AccountIdSet];
            for(Account acc: acclist){                
                mapAccountContact.put(acc.Id, acc.contacts);
            }
            System.debug('mapAccountContact --> Aashi' +mapAccountContact.size());
            System.debug('mapAccountContact --> Aashi' +mapAccountContact);
            for(Opportunity opp : NewOpportunities){ 
                if(mapAccountContact != null && opp.AccountId!=null){
                    for(Contact con: mapAccountContact.get(opp.AccountId)) {                                               
                        if(opp.Billing_Contact__c != null && (opp.Billing_Contact__c == con.id)){
                            ContactIdSet.add(opp.Billing_Contact__c);
                        }
                    }
                }
            }                
        }
        
        
        if(!(Profiles.contains(userprofileid))){                 
            for(Opportunity newRec : NewOpportunities){                              
                Opportunity oldrec = OldOpportunitiesMap.get(newRec.Id);
                System.debug('Skip_Validation_Auto_Renewal__c** ' + newRec.Skip_Validation_Auto_Renewal__c);
                
                System.debug('stage*** ' + (oldrec.get('StageName')));
                System.debug('stage*** ' + newRec.StageName);
                if((oldrec.get('StageName') != 'Closed/Won') && (newRec.get('StageName') == 'Closed/Won') && newRec.Opportunity_Deal_Year__c>1) { // deal year add
                    System.debug('EnteredFormMatchContact**');
                    if(!ContactIdSet.contains(newRec.Billing_Contact__c)) {  // not a part of positive set
                        newRec.addError('Opportunity cannot be marked as Closed/Won as Opportunity Billing Contact is not a part of same Account');
                    }             
                }
                
                
            }                    
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.LockOnClosedWon_LostStage END ------- ' + Limits.getQueries());
        //} 
    }
    
    //This method is used for Creating Future Services when Contract Length is increased.
    public static void CreateFutureServices(Map<id,Opportunity> OldOpportunitiesMap,Map<id,Opportunity> NewOpportunitiesMap,List<Opportunity> NewOpportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.CreateFutureServices START ------- ' + Limits.getQueries());
        Set<ID> OppIdSet= new Set<ID>();
        Map<Id,Id> prodIdToPBEntryIDmap = new Map<Id,Id>();
        Map<id,List<OpportunityLineItem>> Opp_LineItemMap = new Map<id,List<OpportunityLineItem>>();
        List<OpportunityLineItem> OliList2 = new List<OpportunityLineItem>();   
        List<Future_Product__c> CreateFuList = new List<Future_Product__c>();
        //Set<id> OliRenewableSet = new Set<id>();
        
        List<OpportunityLineItem> OliList = new List<OpportunityLineItem>();
        for(Opportunity newRec : NewOpportunities){                              
            Opportunity oldrec = OldOpportunitiesMap.get(newRec.Id);
            if((newRec.RecordTypeId == System.label.StandardRecordType) && (oldrec.get('Multi_YearDeal__c') != null || oldrec.get('Multi_YearDeal__c') != '') && (oldrec.get('Multi_YearDeal__c') != newRec.Multi_YearDeal__c) && (integer.valueOf(newRec.Multi_YearDeal__c) > integer.valueOf(oldrec.get('Multi_YearDeal__c')))){
                OppIdSet.add(newRec.id);                      
            }
        } 
        if(OppIdSet.size()>0 && OppIdSet!=null){
            List<Opportunity> Opplist = [Select id,Multi_YearDeal__c,(Select id,Solution_Cap__c ,Service_End_Date__c,
                                                                      RenewableNew__c,Product2id,UnitPrice,
                                                                      Product2.Revenue_Category__c,Product2.Renewable__c,
                                                                      Product2.name,pricebookentryid,Quantity,
                                                                      List_Price__c,Description,Platform__c,Basis_of_Fees__c,
                                                                      Other__c,Usage_Allowance__c,Proposition__c,Package__c,
                                                                      Booking_Type__c,Total_Equivalent_Units__c,
                                                                      //Changes added by Prachi (SSE-SSE-17449)  
                                                                      Number_of_Services__c
                                                                      //Changes End Prachi (SSE-SSE-17449)
                                                                      ,Solution__c//Changes added by Joana (SSE-16464)
                                                                      from OpportunityLineItems 
                                                                      where RenewableNew__c = 'Ongoing') 
                                         from Opportunity 
                                         where Id IN: OppIdSet];
            for(Opportunity o: Opplist){            
                Opp_LineItemMap.put(o.id,o.OpportunityLineItems);              
            }           
            for(OpportunityLineItem oli : [select id,Solution_Cap__c ,Service_End_Date__c,RenewableNew__c,
                                           //Changes added by Prachi (SSE-SSE-17449)
                                           Number_of_Services__c,
                                           //Changes End Prachi (SSE-SSE-17449)
                                           Solution__c,//Changes added by Joana (SSE-16464)
                                           Product2id,UnitPrice,Product2.Revenue_Category__c,Product2.Renewable__c,
                                           Product2.name,pricebookentryid,Quantity,List_Price__c,Description,
                                           Platform__c,Basis_of_Fees__c,Other__c,Usage_Allowance__c,Total_Equivalent_Units__c,
                                           Proposition__c,Package__c,Booking_Type__c 
                                           from OpportunityLineItem 
                                           where opportunityid IN :OppIdSet]){
                                               if( oli.RenewableNew__c == 'Ongoing'){ //oli.Product2.Revenue_Category__c == 'Subscription' && 
                                                   prodIdToPBEntryIDmap.put(oli.Product2id,oli.pricebookentryid);
                                                   //OliRenewableSet.add(oli.id);
                                               }
                                           }
        }
        for(Opportunity newRec : NewOpportunities){
            if(newRec.RecordTypeId == System.label.StandardRecordType && OppIdSet.size()>0 && OppIdSet!=null){
                Opportunity oldrec = OldOpportunitiesMap.get(newRec.Id);                
                integer newvalue = integer.valueof(newRec.Multi_YearDeal__c);
                integer oldvalue = integer.valueOf(oldrec.get('Multi_YearDeal__c'));
                System.debug('new value** ' + newvalue);
                System.debug('ola value** ' + oldvalue);
                
                if(Opp_LineItemMap.get(newRec.id) != null){
                    for(Integer i=oldvalue; i<newvalue; i++){
                        System.debug( 'list** ' + Opp_LineItemMap.get(newRec.id));
                        OliList2 = Opp_LineItemMap.get(newRec.id); // get OLI values from Map                   
                        if(OliList2.size()>0 && OliList2 != null){
                            for(OpportunityLineItem oli : OliList2){
                                if(prodIdToPBEntryIDmap.keyset().contains(oli.Product2id)){
                                    System.debug('entered***');
                                    Future_Product__c fu = new Future_Product__c();
                                    fu.Opportunity_Product_Id__c = oli.id;
                                    fu.Opportunity__c = newRec.id;
                                    fu.Product__c = oli.Product2id;
                                    fu.Pricebook_Entry_Id__c = prodIdToPBEntryIDmap.get(oli.Product2id);
                                    fu.Contract_Year__c = String.Valueof(i+1);
                                    fu.Quantity__c = oli.Quantity;
                                    fu.ListPrice__c = oli.List_Price__c;
                                    fu.Sales_Price__c = oli.UnitPrice;
                                    fu.Line_Description__c = oli.Description;
                                    fu.Platform__c = oli.Platform__c;
                                    fu.Basis_of_Fees__c = oli.Basis_of_Fees__c;
                                    fu.Other__c = oli.Other__c;
                                    fu.Usage_Allowance__c = oli.Usage_Allowance__c;
                                    //fu.Usage_Cap_or_Estimation__c = oli.Usage_Cap_or_Estimation__c;
                                    fu.Usage_Cap_or_Estimation__c = oli.Total_Equivalent_Units__c;
                                    fu.Proposition__c = oli.Proposition__c;
                                    fu.Package__c = oli.Package__c;
                                    fu.Booking_Type__c = oli.Booking_Type__c;
                                    fu.CurrencyIsoCode = newRec.CurrencyIsoCode;
                                    fu.Service_End_Date__c = oli.Service_End_Date__c;
                                    fu.RenewableNew__c = oli.RenewableNew__c;
                                    fu.Solution_Cap__c = oli.Solution_Cap__c;
                                    //Changes added by Prachi (SSE-SSE-17449)  
                                    fu.Number_of_Services__c = oli.Number_of_Services__c;
                                    //Changes End Prachi (SSE-SSE-17449)
                                    fu.Solution__c = oli.Solution__c;//Changes added by Joana (SSE-16464)
                                    CreateFuList.add(fu);
                                } // if end 
                            } // for end
                        }  // if end  
                    } // for end                
                } // if end             
            } // main for end
            System.debug('CreateFuList** ' + CreateFuList);
            if(CreateFuList.size()>0 && CreateFuList!=null){
                insert CreateFuList;
            }
        }// main-if of record type  
        System.debug('Number of Queries used -- OpportunityTriggerManager.CreateFutureServices END ------- ' + Limits.getQueries());
    }
    
    
    //This method is used for Deleting Future Services when Contract Length is decreased.
    public static void DeleteFutureServices(Map<id,Opportunity> OldOpportunitiesMap,Map<id,Opportunity> NewOpportunitiesMap,List<Opportunity> NewOpportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.DeleteFutureServices START ------- ' + Limits.getQueries());
        Set<ID> OppIdSet= new Set<ID>();
        Map<id,List<Future_Product__c>> OppFutureMap = new Map<id,List<Future_Product__c>>();
        List<Future_Product__c> FupList = new List<Future_Product__c>();        
        Set<id> FupSetToDel = new Set<id>();
        
        for(Opportunity newRec : NewOpportunities){   
            Opportunity oldrec = OldOpportunitiesMap.get(newRec.Id);
            if((
                (newRec.recordtypeid == System.label.StandardRecordType
                 || (newRec.RecordTypeId == System.label.ReadOnlyRecordType && newRec.Business_Type__c == 'Renewal'
                     && newRec.Opportunity_Deal_Year__c == 1 && newRec.Auto_Created_Renewal__c == true
                     && newRec.Auto_Close_Date__c == System.today())
                )
                && (oldrec.get('Multi_YearDeal__c') != null || oldrec.get('Multi_YearDeal__c') != '') && (oldrec.get('Multi_YearDeal__c') != newRec.Multi_YearDeal__c) && (integer.valueOf(newRec.Multi_YearDeal__c) < integer.valueOf(oldrec.get('Multi_YearDeal__c'))))){
                    OppIdSet.add(newRec.id);                      
                }
        }  
        if(OppIdSet.size()>0 && OppIdSet!=null){
            List<Opportunity> Opplist = [Select id,Multi_YearDeal__c,(Select Id,Contract_Year__c from Future_Year_Opportunity_Products__r) from Opportunity where Id IN: OppIdSet];
            for(Opportunity o: Opplist){            
                OppFutureMap.put(o.id,o.Future_Year_Opportunity_Products__r);              
            }
            //System.debug('Ma** ' + OppFutureMap);
            //System.debug('OList** ' + NewOpportunities);
            for(Opportunity newRec : Opplist){
                Opportunity oldrec = OldOpportunitiesMap.get(newRec.Id);
                
                integer newvalue = integer.valueof(newRec.Multi_YearDeal__c);
                integer oldvalue = integer.valueOf(oldrec.get('Multi_YearDeal__c'));
                
                //System.debug('new value** ' + newvalue);
                //System.debug('ola value** ' + oldvalue);
                //System.debug('OppFutureMap ' + OppFutureMap.get(newRec.id));               
                
                if(OppFutureMap.get(newRec.id) != null){
                    for(Integer i=oldvalue; i>newvalue; i--){
                        //System.debug( 'list** ' + OppFutureMap.get(newRec.id));
                        FupList = OppFutureMap.get(newRec.id);
                        if(FupList.size()>0 && FupList!= null){
                            for(Future_Product__c fu : FupList){
                                if(integer.valueof(fu.Contract_Year__c) == i){
                                    FupSetToDel.add(fu.id);
                                }
                            } // for end
                        }
                    } // for end                
                } // if end            
            } // main for end           
        }
        
        if(FupSetToDel.size()>0) {                    
            delete[select Id from Future_Product__c where Id IN: FupSetToDel];
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.DeleteFutureServices END ------- ' + Limits.getQueries());
    }
    
    //This method is validating profile of user, only system admins profile allowed to delete opportunities else error is thrown.
    public static void validateUserOnDeletion(List<Opportunity> Opportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.validateUserOnDeletion START ------- ' + Limits.getQueries());
        set<string> Profiles = new set<string>();
        Profiles.addall(System.Label.SystemAdminProfiles.split(','));
        String userprofileid=(String)UserInfo.getProfileId().substring(0,15);
        if(!(Profiles.contains(userprofileid)))
        { 
            for(Opportunity oppty:Opportunities)
                oppty.addError('Only users System Admin profiles can delete opportunities.');
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.validateUserOnDeletion END ------- ' + Limits.getQueries());
    }
    
    
    
    //This method is creating OpportunityContactRole records based on Primary contact and Billing Contact.
    public static void CreateOpportunityContactRole(List<Opportunity> Opportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.CreateOpportunityContactRole START ------- ' + Limits.getQueries());
        List<OpportunityContactRole> insertedocrList = new List<OpportunityContactRole>();
        for(Opportunity oppty:Opportunities){
            if(oppty.Primary_Contact__c != null && oppty.Primary_Contact__c==oppty.Billing_Contact__c){
                OpportunityContactRole ocr = new OpportunityContactRole ();
                ocr.ContactId = oppty.Primary_Contact__c;
                ocr.OpportunityId=oppty.id;
                ocr.role='Decision Maker / Billing Contact';
                ocr.IsPrimary=true;
                insertedocrList.add(ocr);
            }
            if(oppty.Primary_Contact__c != null && oppty.Primary_Contact__c!=oppty.Billing_Contact__c){
                OpportunityContactRole ocr = new OpportunityContactRole ();
                ocr.ContactId = oppty.Primary_Contact__c;
                ocr.OpportunityId=oppty.id;
                ocr.role='Decision Maker';
                ocr.IsPrimary=true;
                insertedocrList.add(ocr);
            }
            if(oppty.Billing_Contact__c !=null && oppty.Primary_Contact__c!=oppty.Billing_Contact__c){
                OpportunityContactRole ocr1 = new OpportunityContactRole ();
                ocr1.ContactId = oppty.Billing_Contact__c;
                ocr1.OpportunityId=oppty.id;
                ocr1.role='Billing Contact';
                ocr1.IsPrimary=false;
                insertedocrList.add(ocr1);
            }
        }
        if(insertedocrList.size()>0)
            insert insertedocrList;
        
        System.debug('Number of Queries used -- OpportunityTriggerManager.CreateOpportunityContactRole END ------- ' + Limits.getQueries());
    }
    
    
    
    /*This method is performing the below tasks
1) If probability is equal to 100 then show error for not cloning the opportunity.
2) Make order number null.
3) If Opportunity name contains '.' the set Renewal_Opportunity__c = true else false.
4) if Variation_Opportunity__c is Yes then set amount=0.00
5) if Opportunity_Submitted__c is null then set Opportunity_Submitted__c to user id.
6) if CampaignId is null then set CampaignId to '7012000000006S1AAI'
7) If opportunity account != null then set opportunity OwnerId = Account owner id.*/
    public static void BeforeInsertTasks(List<Opportunity> Opportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.BeforeInsertTasks START ------- ' + Limits.getQueries());
        Set<Id> accountIdsSet = new Set<Id>();
        for(Opportunity oppty:Opportunities){
            accountIdsSet.add(oppty.AccountId);
            oppty.Order_Number__c = null;
            /* if(oppty.name.Contains('.'))
oppty.Renewal_Opportunity__c=TRUE;
else
oppty.Renewal_Opportunity__c=False; */
            
            if(oppty.Probability ==100)
                oppty.Probability.addError('You can not clone an opportunity with 100% probability. Please change the Stage to New.');
            
            if(oppty.Variation_Opportunity__c=='Yes')
                oppty.amount=0.00;  
            
            oppty.Opportunity_Submitted__c=UserInfo.getUserId(); 
            if(oppty.CampaignId==null) // Added by Priyank Anand for ITSD-35478
                oppty.CampaignId=System.label.Campaign_Id;
            
        }
        
        if(accountIdsSet.size() > 0){    
            Map<Id,Account> accountMap = new Map<Id,Account>([Select id,CurrencyIsoCode,OwnerId from Account where id in :accountIdsSet]);  
            if(accountMap!=null){ 
                for(Opportunity oppty:Opportunities){
                    if(oppty.Opportunity_Deal_Year__c == 1){
                        /* Commented by Aashi for story SSE-20055 */
                        /* Account owner will no longer be Opportunity owner
/*if(accountMap.get(oppty.AccountId)!=null)
oppty.OwnerId = accountMap.get(oppty.AccountId).OwnerId;*/
                    }
                }
            }
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.BeforeInsertTasks END ------- ' + Limits.getQueries());
    }
    
    //This method is creating Jobs if Probability is greater than 50% and product is Managed Services.
    public static void CreateJobs(List<Opportunity> Opportunities, Map<Id,Opportunity> OldOpportunities){
        Set<ID> OppMSSet = new Set<ID>();
        AutomaticJobCreation__c cs = AutomaticJobCreation__c.getValues('Values');
        List<String> msTypeValuesList= cs.MS_Line_of_Business__c.trim().split(',');
        Set<String> msTypeValuesSet= new Set<String>(msTypeValuesList);
        Map<id,Opportunity> OppMapJob=new map<id,Opportunity>();
        for(Opportunity oppty:Opportunities){            
            if(oppty.Probability >=50 && oppty.Probability != OldOpportunities.get(oppty.id).Probability){  // Added by Saloni for SQOL Limit from flow                       
                OppMSSet.add(oppty.id);
                OppMapJob.put(oppty.id,oppty);
            }    
        }
        //System.debug('OppMSSet**' + OppMSSet.size() + ' - '+ OppMSSet); 
        if(OppMSSet.size() > 0){  //SSE-16766 Automatic Job Creation Process -->
            Map<ID, Set<String>> oppProductMSTypeMap = new Map<ID, Set<String>>();
            for(OpportunityLineItem jb: [Select id,OpportunityID,Product2.MS_Type__c from OpportunityLineItem where OpportunityId in: OppMSSet and Ms_product__c=true and Product2.MS_Type__c in: msTypeValuesSet]){
                if(!oppProductMSTypeMap.containsKey(jb.OpportunityID)){
                    Set<String> msTypeSet =new Set<String>{jb.Product2.MS_Type__c};
                        oppProductMSTypeMap.put(jb.OpportunityID,msTypeSet);
                }else if(!oppProductMSTypeMap.get(jb.OpportunityID).contains(jb.Product2.MS_Type__c)){
                    oppProductMSTypeMap.get(jb.OpportunityID).add(jb.Product2.MS_Type__c);
                    oppProductMSTypeMap.put(jb.OpportunityID,oppProductMSTypeMap.get(jb.OpportunityID));   
                }
            } 
            
            Map<ID, Set<String>> map_oppName_jobCount = new Map<ID,Set<String>>();
            if(!oppProductMSTypeMap.isEmpty()){
                for(Job__c jb: [Select id,Opportunity__c,MS_Line_of_Business__c from Job__c where Opportunity__c in: OppMSSet and MS_Line_of_Business__c in: msTypeValuesSet]){
                    if(!map_oppName_jobCount.containsKey(jb.Opportunity__c)){
                        Set<String> msTypeSet =new Set<String>{jb.MS_Line_of_Business__c};
                            map_oppName_jobCount.put(jb.Opportunity__c,msTypeSet);
                    }else if(!map_oppName_jobCount.get(jb.Opportunity__c).contains(jb.MS_Line_of_Business__c)){
                        map_oppName_jobCount.get(jb.Opportunity__c).add(jb.MS_Line_of_Business__c);
                        map_oppName_jobCount.put(jb.Opportunity__c, map_oppName_jobCount.get(jb.Opportunity__c));   
                    }
                }
            }
            
            List<Job__c> lCreateJob = new List<Job__c>();
            if( !oppProductMSTypeMap.isEmpty() && OppMapJob.keyset().size() > 0){
                Id pipelineRecordTypeId = System.label.Managed_Service_Pipeline_RecordType_Id;
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
    
    
    
    //This method is updating OpportunityContactRole when primary contact or billing contact is changed. 
    public static void UpdateOpportunityContactRoleNew(Map<id,Opportunity> OldOpportunitiesMap,Map<id,Opportunity> NewOpportunitiesMap,List<Opportunity> NewOpportunities){ 
        System.debug('Number of Queries used -- OpportunityTriggerManager.UpdateOpportunityContactRoleNew START ------- ' + Limits.getQueries());
        Set<Id> oppIdsSet = new Set<Id>();
        Set<Id> deletedPrimaryContactRoleIds = new Set<Id>();
        Set<Id> deletedPrimaryBillingContactRoleIds = new Set<Id>();
        Set<Id> deletedBillingContactRoleIds = new Set<Id>();
        Set<Id> deletedContactRoleIds = new Set<Id>();
        Set<OpportunityContactRole> ContactRoleToUpdateList = new Set<OpportunityContactRole>();
        List<OpportunityContactRole> ContactRolelst = new List<OpportunityContactRole>();
        Map<Id,Integer> ContactCountMap = new Map<Id,Integer>();
        List<OpportunityContactRole> deletedocrlist = new List<OpportunityContactRole>();
        List<OpportunityContactRole> insertedocrList = new List<OpportunityContactRole>();
        Boolean NormalRun = True;
        
        for(Integer i = 0;i<NewOpportunities.size();i++) {
            if((NewOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c!= OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c)
               && (NewOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c != OldOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c)
               && (NewOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c==NewOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c)){
                   NormalRun =False;
                   deletedContactRoleIds.add(OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c);
                   deletedContactRoleIds.add(OldOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c);
                   oppIdsSet.add(NewOpportunities[i].Id);
               }
            else if((NewOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c!= OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c)
                    && (NewOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c != OldOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c)
                    && (NewOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c!=NewOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c)){
                        deletedPrimaryBillingContactRoleIds.add(OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c);
                        oppIdsSet.add(NewOpportunities[i].Id);
                    }
            else if((NewOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c!= OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c)
                    && (NewOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c != OldOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c)
                    && (OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c==OldOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c)){
                        deletedPrimaryBillingContactRoleIds.add(OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c);
                    }
            else if(NewOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c!= OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c){
                deletedPrimaryContactRoleIds.add(OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c);
                oppIdsSet.add(NewOpportunities[i].Id);
            }
            else if(NewOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c != OldOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c){
                deletedBillingContactRoleIds.add(OldOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c);
                oppIdsSet.add(NewOpportunities[i].Id);
            }
        } 
        
        /*lines moved to inside if(oppIdsSet.size()>0 && NormalRun==True) to avoid unnecessary queries before being needed
Map<Id,List<OpportunityContactRole>> OppContactRoleMap = new Map<Id,List<OpportunityContactRole>>();

List<OpportunityContactRole> AllContactRoles = [select id,contactId,Role,opportunityId,isPrimary 
from OpportunityContactRole 
where opportunityId In:NewOpportunities order by CreatedDate desc];

for(OpportunityContactRole oppconrole:AllContactRoles){
if(OppContactRoleMap.get(oppconrole.opportunityId)==null){
List<OpportunityContactRole> OppConList = new List<OpportunityContactRole>();
OppConList.add(oppconrole);
OppContactRoleMap.put(oppconrole.opportunityId,OppConList);
}
else{
OppContactRoleMap.get(oppconrole.opportunityId).add(oppconrole); 
}
}
*/
        
        if(oppIdsSet.size()>0 && NormalRun==False){
            for(Id oppId:oppIdsSet){
                OpportunityContactRole ocr = new OpportunityContactRole ();
                ocr.ContactId = NewOpportunitiesMap.get(oppId).Billing_Contact__c;
                ocr.OpportunityId=oppId;
                ocr.role='Decision Maker / Billing Contact';
                ocr.IsPrimary=true;
                insertedocrList.add(ocr);
            }
            for(OpportunityContactRole ocr : [select ContactId , OpportunityId ,role, IsPrimary 
                                              from OpportunityContactRole 
                                              where  ContactId IN  : deletedContactRoleIds 
                                              AND OpportunityId IN: oppIdsSet]){
                                                  deletedocrlist.add(ocr);
                                              }
        }
        
        if(oppIdsSet.size()>0 && NormalRun==True) {
            
            Map<Id,List<OpportunityContactRole>> OppContactRoleMap = new Map<Id,List<OpportunityContactRole>>();
            
            List<OpportunityContactRole> AllContactRoles = [select id,contactId,Role,opportunityId,isPrimary 
                                                            from OpportunityContactRole 
                                                            where opportunityId In:NewOpportunities order by CreatedDate desc];
            
            for(OpportunityContactRole oppconrole:AllContactRoles){
                if(OppContactRoleMap.get(oppconrole.opportunityId)==null){
                    List<OpportunityContactRole> OppConList = new List<OpportunityContactRole>();
                    OppConList.add(oppconrole);
                    OppContactRoleMap.put(oppconrole.opportunityId,OppConList);
                }
                else{
                    OppContactRoleMap.get(oppconrole.opportunityId).add(oppconrole); 
                }
            }
            
            
            for(OpportunityContactRole ocr : [select ContactId , OpportunityId ,role, IsPrimary 
                                              from OpportunityContactRole 
                                              where  ContactId IN  : deletedPrimaryBillingContactRoleIds 
                                              AND OpportunityId IN: oppIdsSet]){
                                                  deletedocrlist.add(ocr);
                                              }
            //in case primary contact and billing contacts are same and one is changed then only one opp contact role should be deleted
            for(OpportunityContactRole ocr : [select ContactId , OpportunityId ,role, IsPrimary 
                                              from OpportunityContactRole 
                                              where  ContactId IN  : deletedPrimaryContactRoleIds 
                                              AND OpportunityId IN: oppIdsSet]){
                                                  if(ocr.Role=='Decision Maker / Billing Contact' || ocr.Role=='Billing Contact'){
                                                      ocr.IsPrimary=False;
                                                      ocr.Role='Billing Contact';
                                                      ContactRoleToUpdateList.add(ocr);
                                                  } else {
                                                      deletedocrlist.add(ocr);
                                                  }      
                                              }
            
            for(OpportunityContactRole ocr : [select ContactId , OpportunityId ,role, IsPrimary 
                                              from OpportunityContactRole 
                                              where  ContactId IN  : deletedBillingContactRoleIds
                                              AND OpportunityId IN: oppIdsSet]) {
                                                  if(ocr.IsPrimary==True){
                                                      ocr.Role='Decision Maker';
                                                      ContactRoleToUpdateList.add(ocr);
                                                  } else {
                                                      deletedocrlist.add(ocr);
                                                  }
                                                  
                                              }
            
            for(Id oppId:oppIdsSet) {
                boolean ToCreateNewOppConRoleForPrimary = True;
                boolean ToCreateNewOppConRoleForBilling = True;
                
                if(NewOpportunitiesMap.get(oppId).Primary_Contact__c != null && 
                   NewOpportunitiesMap.get(oppId).Primary_Contact__c != OldOpportunitiesMap.get(oppId).Primary_Contact__c) {
                       
                       List<OpportunityContactRole> RelatedContactRole = new List<OpportunityContactRole>();
                       RelatedContactRole = OppContactRoleMap.get(oppId);
                       
                       if(RelatedContactRole!=null) {
                           for(OpportunityContactRole opprole:RelatedContactRole){
                               if(opprole.contactId==NewOpportunitiesMap.get(oppId).Primary_Contact__c) {
                                   ToCreateNewOppConRoleForPrimary=False;
                                   opprole.IsPrimary=True;
                                   if(NewOpportunitiesMap.get(oppId).Primary_Contact__c==NewOpportunitiesMap.get(oppId).Billing_contact__c){
                                       opprole.role='Decision Maker / Billing Contact'; 
                                   }
                                   ContactRoleToUpdateList.add(opprole);
                                   break;
                               }
                           }
                           
                           if(ToCreateNewOppConRoleForPrimary==true){
                               OpportunityContactRole ocr = new OpportunityContactRole ();
                               ocr.ContactId = NewOpportunitiesMap.get(oppId).Primary_Contact__c;
                               ocr.OpportunityId=oppId;
                               ocr.IsPrimary=true;
                               ocr.Role='Decision Maker';
                               insertedocrList.add(ocr);
                           }
                       } else{
                           OpportunityContactRole ocr = new OpportunityContactRole ();
                           ocr.ContactId = NewOpportunitiesMap.get(oppId).Primary_Contact__c;
                           ocr.OpportunityId=oppId;
                           ocr.IsPrimary=true;
                           ocr.Role='Decision Maker';
                           insertedocrList.add(ocr);
                       }
                   }
                
                
                if(NewOpportunitiesMap.get(oppId).Billing_Contact__c != OldOpportunitiesMap.get(oppId).Billing_Contact__c){
                    if(NewOpportunitiesMap.get(oppId).Billing_Contact__c == null){
                        /*   List<OpportunityContactRole> RelatedContactRole = new List<OpportunityContactRole>();
for(OpportunityContactRole conrole:AllContactRoles){
if(conrole.Role=='Billing Contact' && conrole.OpportunityId==oppId){
RelatedContactRole.add(conrole); 
}
}
NewOpportunitiesMap.get(oppId).Billing_Contact__c = RelatedContactRole[0].contactId; */
                    } else{
                        List<OpportunityContactRole> RelatedContactRole = OppContactRoleMap.get(oppId);
                        if(RelatedContactRole!=null){
                            for(OpportunityContactRole opprole:RelatedContactRole){
                                if(opprole.contactId==NewOpportunitiesMap.get(oppId).Billing_Contact__c) {
                                    ToCreateNewOppConRoleForBilling=False;
                                    if(opprole.role!='Billing Contact' && opprole.IsPrimary==False){
                                        opprole.Role='Billing Contact';
                                    } else if(opprole.role!='Billing Contact' && opprole.IsPrimary==True){
                                        opprole.Role='Decision Maker / Billing Contact';
                                    }
                                    ContactRoleToUpdateList.add(opprole);
                                }
                            }
                            if(ToCreateNewOppConRoleForBilling==True){
                                OpportunityContactRole ocr1 = new OpportunityContactRole ();
                                ocr1.ContactId = NewOpportunitiesMap.get(oppId).Billing_Contact__c;
                                ocr1.OpportunityId=oppId;
                                ocr1.IsPrimary=false;
                                ocr1.Role='Billing Contact';
                                insertedocrList.add(ocr1);
                            }
                        }
                    }
                }
            }
        }   
        
        if(ContactRoleToUpdateList.size()>0) {
            System.debug('This is Set '+ContactRoleToUpdateList);
            ContactRolelst.addall(ContactRoleToUpdateList);
            System.debug('This is list '+ContactRolelst);
            update ContactRolelst;
        }   
        if(deletedocrlist.size()>0){
            delete deletedocrlist;
        }
        if(insertedocrList.size()>0){
            insert insertedocrList;
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.UpdateOpportunityContactRoleNew END ------- ' + Limits.getQueries());
        
    } 
    /*
public static void UpdateOpportunityContactRole(Map<id,Opportunity> OldOpportunitiesMap,Map<id,Opportunity> NewOpportunitiesMap,List<Opportunity> NewOpportunities){ 
Set<Id> oppIdsSet = new Set<Id>();
Set<Id> deletedContacrRoleIds = new Set<Id>();
Map<Id,Integer> ContactCountMap = new Map<Id,Integer>();
for(Integer i = 0;i<NewOpportunities.size();i++) {
if(NewOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c!= OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c){
deletedContacrRoleIds.add(OldOpportunitiesMap.get(NewOpportunities[i].Id).Primary_Contact__c);
ContactCountMap.put(NewOpportunities[i].Id,1);
oppIdsSet.add(NewOpportunities[i].Id);
}
if(NewOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c != OldOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c){
deletedContacrRoleIds.add(OldOpportunitiesMap.get(NewOpportunities[i].Id).Billing_Contact__c);
if(ContactCountMap.containsKey(NewOpportunities[i].Id)){
ContactCountMap.put(NewOpportunities[i].Id,2);
}else{
ContactCountMap.put(NewOpportunities[i].Id,1);
}
oppIdsSet.add(NewOpportunities[i].Id);
}
}
if(oppIdsSet.size()>0){
List<OpportunityContactRole> deletedocrlist = new List<OpportunityContactRole>();
//in case primary contact and billing contacts are same and one is changed then only one opp contact role should be deleted
Map<String,OpportunityContactRole> conOppRoleMap = new Map<String,OpportunityContactRole>();
for(OpportunityContactRole ocr : [select ContactId , OpportunityId ,role, IsPrimary from OpportunityContactRole where  ContactId IN  : deletedContacrRoleIds AND OpportunityId IN: oppIdsSet]){
//if opp primary contact and billing contact both are same and both are changed then add both to delete list
if(ContactCountMap.get(ocr.OpportunityId) == 2){
deletedocrlist.add(ocr);
//if opp primary contact and billing contact both are same and only one is changed then only one opp con role should be deleted
}else{
conOppRoleMap.put(ocr.ContactId+'-'+ocr.OpportunityId,ocr);
}
}
if(conOppRoleMap.size()>0){
for(String str : conOppRoleMap.keySet()){
deletedocrlist.add(conOppRoleMap.get(str));
}
}
List<OpportunityContactRole> insertedocrList = new List<OpportunityContactRole>();
for(Id oppId:oppIdsSet){
//opp contact role for primary contact
if(NewOpportunitiesMap.get(oppId).Primary_Contact__c != null && NewOpportunitiesMap.get(oppId).Primary_Contact__c!= OldOpportunitiesMap.get(oppId).Primary_Contact__c && !LeadConversionController_ConvertPage.IsleadConversion){
OpportunityContactRole ocr = new OpportunityContactRole ();
ocr.ContactId = NewOpportunitiesMap.get(oppId).Primary_Contact__c;
ocr.OpportunityId=oppId;
ocr.IsPrimary=true;
insertedocrList.add(ocr);
}
if(NewOpportunitiesMap.get(oppId).Billing_Contact__c != null && NewOpportunitiesMap.get(oppId).Billing_Contact__c != OldOpportunitiesMap.get(oppId).Billing_Contact__c){
// opp contact role for billing contact
OpportunityContactRole ocr1 = new OpportunityContactRole ();
ocr1.ContactId = NewOpportunitiesMap.get(oppId).Billing_Contact__c;
ocr1.OpportunityId=oppId;
ocr1.IsPrimary=false;
insertedocrList.add(ocr1);
}
}
if(deletedocrlist.size()>0){
delete deletedocrlist;
}
if(insertedocrList.size()>0){
insert insertedocrList;
}
}   

} */
    
    //This method is updating Send_Mail_To_Mgr_and_Coord__c field of Project object when stage is changed to Closed/Won.
    public static void SendMailToProjectManager_Coordinator(List<Opportunity> OldOpportunities,List<Opportunity> NewOpportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.SendMailToProjectManager_Coordinator START ------- ' + Limits.getQueries());
        
        if(Utility.runOpptyAfterUpdateTrigOnce == true) {
            set<id> opptyId = new set<Id>();
            for(Integer i = 0; i < NewOpportunities.size(); i++) {
                if(NewOpportunities[i].stageName == System.label.Opportunity_Stage_6 
                   && NewOpportunities[i].stageName!= OldOpportunities[i].stageName) {
                       opptyId.add(NewOpportunities[i].id);
                   }
            }  
            
            if(opptyId.size()>0 && opptyId != null) { //added
                List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();  
                
                List<ProjectObject__c> projectUpdateList = new List<ProjectObject__c>();
                for(Opportunity oppty : [select Id,Name, StageName,(select Id,Name,LBU__c,Opportunity__c,Project_Manager__c,Project_Co_ordinator__r.email,Send_Mail_To_Mgr_and_Coord__c
                                                                    from Projects__r) 
                                         from Opportunity 
                                         where Id IN: opptyId]) {
                                             for(ProjectObject__c probj : oppty.Projects__r) {                   
                                                 probj.Send_Mail_To_Mgr_and_Coord__c = true;
                                                 
                                                 projectUpdateList.add(probj);
                                                 
                                             }
                                         }
                if(projectUpdateList.size()>0 && projectUpdateList != null) {
                    update projectUpdateList;
                }
            }
            Utility.runOpptyAfterUpdateTrigOnce = false;
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.SendMailToProjectManager_Coordinator END ------- ' + Limits.getQueries());
    }
    
    //This method is updating pricebook2id field of opportunity when recordtype is GCSC.
    public static void UpdatePricebookid(List<Opportunity> Opportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.UpdatePricebookid START ------- ' + Limits.getQueries());
        for(Opportunity oppty : Opportunities){
            if(oppty.RecordTypeId == System.label.GCSCRecordType && (oppty.pricebook2id == null)){                                  
                //oppty.pricebook2id = System.Label.MasterPricebookId; (commented as part of SSE-12869 only configurator pricebook will be used from now)      
                oppty.pricebook2id = System.Label.ConfiguratorPricebookId;
            }       
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.UpdatePricebookid END ------- ' + Limits.getQueries());
    }
    
    
    
    //Opportunity cannot be deleted if contract is related
    public static void OpptyDeleteWithContract(List<Opportunity> Opptylistdel) {
        System.debug('Number of Queries used -- OpportunityTriggerManager.OpptyDeleteWithContract START ------- ' + Limits.getQueries());
        for(Opportunity oppt:Opptylistdel)
        {
            if(oppt.ContractID != null)
            {
                oppt.addError('Opportunity cannot be deleted as it is linked with a contract');
            }
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.OpptyDeleteWithContract END ------- ' + Limits.getQueries());
    }
    
    //This method deletes all the Discount summeries from ignite opportunities when it is changed to standard opportunity
    /*public static void recordTypeChange(Map<Id,Opportunity> OldOpportunities,Map<Id,Opportunity> NewOpportunities){
list<Opportunity> oppwithrecordtypechange = new list<Opportunity>();
list<Future_Product__c> FPToDelete = new list<Future_Product__c>();
list<OpportunityLineItem> prodsToDelete = new list<OpportunityLineItem>();
list<Discount_Summary__c> DSToDelete = new list<Discount_Summary__c>();

for(Opportunity opp : OldOpportunities.values()){
if(opp.RecordTypeId == '012D0000000KN0H' && NewOpportunities.get(opp.id).RecordTypeId == '012D0000000V7oq'){
opportunity opp2 = new opportunity(id = opp.id,pricebook2id = system.label.IgnitePricebookId);
oppwithrecordtypechange.add(opp2);
}
}
if(oppwithrecordtypechange.size()>0){
FPToDelete = [select id from Future_Product__c where Opportunity__c IN :oppwithrecordtypechange];
prodsToDelete = [select id from OpportunityLineItem where opportunityid IN :oppwithrecordtypechange];
DSToDelete = [select id from Discount_Summary__c where Opportunity__c IN :oppwithrecordtypechange];
}
if(FPToDelete.size()>0){
//system.debug('FPToDelete'+FPToDelete)
delete FPToDelete;
}
if(prodsToDelete.size()>0){
//system.debug('prodsToDelete'+prodsToDelete)
delete prodsToDelete;
}
if(DSToDelete.size()>0){
//system.debug('DSToDelete'+DSToDelete)
delete DSToDelete;
}
if(oppwithrecordtypechange.size()>0){
update oppwithrecordtypechange;
}
}*/
    
    // To store previous record type id   for SSE- 12332
    public static void PreviousRecordTypeUpdate(Map<Id,Opportunity> OldOpportunities,Map<Id,Opportunity> NewOpportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.PreviousRecordTypeUpdate START ------- ' + Limits.getQueries());
        
        for(Opportunity opp : NewOpportunities.values()){        
            // If Record type is changed to Read only from non-Read only, store previous record type Id in field
            if(opp.RecordTypeId == System.label.ReadOnlyRecordType && OldOpportunities.get(opp.id).RecordTypeId != System.label.ReadOnlyRecordType){
                opp.Previous_Record_Type__c = OldOpportunities.get(opp.id).RecordTypeId; // now Actual record type id
                
                if(opp.Previous_Record_Type__c == System.label.GCSCRecordType){
                    opp.Actual_Record_Type_Name__c = System.label.GCSC_Opportunity; //'GCSC Opportunity';
                }
                if(opp.Previous_Record_Type__c == System.label.StandardRecordType){
                    opp.Actual_Record_Type_Name__c = System.label.Standard_Opportunity; //'Standard Opportunity';
                }
                if(opp.Previous_Record_Type__c == System.label.IgniteRecordType){
                    opp.Actual_Record_Type_Name__c = System.label.Configurator_Opportunity; //'Configurator Opportunity';
                }
            }
            
            // If Record Type is changed from Non Read only to other Non Read only profile, store the changed record type Id in field
            if((opp.RecordTypeId != OldOpportunities.get(opp.id).RecordTypeId) && opp.RecordTypeId!=System.label.ReadOnlyRecordType){
                opp.Previous_Record_Type__c = opp.RecordTypeId;
                if(opp.Previous_Record_Type__c == System.label.GCSCRecordType){
                    opp.Actual_Record_Type_Name__c = System.label.GCSC_Opportunity; //'GCSC Opportunity';
                }
                if(opp.Previous_Record_Type__c == System.label.StandardRecordType){
                    opp.Actual_Record_Type_Name__c = System.label.Standard_Opportunity; //'Standard Opportunity';
                }
                if(opp.Previous_Record_Type__c == System.label.IgniteRecordType){
                    opp.Actual_Record_Type_Name__c = System.label.Configurator_Opportunity; //'Configurator Opportunity';
                }
                //opp.Actual_Record_Type_Name__c = opp.RecordType.Name;
            }
            
            // no change if Record type is changed from Read only to non Read only in previous Record Type Id field.
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.PreviousRecordTypeUpdate END ------- ' + Limits.getQueries());
    }
    
    public static void ValidationLockedStage(Map<Id,Opportunity> OldOpportunities,Map<Id,Opportunity> NewOpportunities){
        System.debug('Number of Queries used -- OpportunityTriggerManager.ValidationLockedStage START ------- ' + Limits.getQueries());
        boolean isOAT = false;
        set<string> Profiles = new set<string>();
        Profiles.addall(System.Label.SystemAdminProfiles.split(','));
        //Profiles.addall(System.Label.OATsProfiles.split(','));
        Boolean hasOATsPermission = FeatureManagement.checkPermission('OATs'); // Added by Jai for SSE-24406
        Boolean hasLegalPermission = FeatureManagement.checkPermission('Legal_Page_Restrictions');

        String userprofileid=(String)UserInfo.getProfileId().substring(0,15);
        Set<String> groupNames = new Set<String>();
        for (GroupMember gm : [select 
                               group.name,
                               group.DeveloperName 
                               from GroupMember 
                               where UserOrGroupId = :UserInfo.getUserId()]) {
                                   groupNames.add(gm.group.DeveloperName);
                               }
        
        if(!(Profiles.contains(userprofileid) || hasOATsPermission==true || hasLegalPermission==true) && !(groupNames.contains('SOE_Queue'))){  // Changes added by Jai for SSE-24406
            for(Opportunity opp : NewOpportunities.values()){ 
                if(opp.RecordTypeId == System.label.ReadOnlyRecordType 
                   && OldOpportunities.get(opp.id).RecordTypeId == System.label.ReadOnlyRecordType 
                   && opp.Skip_Validation_Auto_Renewal__c == false){
                       if((opp.StageName != OldOpportunities.get(opp.id).StageName) 
                          || (opp.CloseDate != OldOpportunities.get(opp.id).CloseDate) 
                          || (opp.Name != OldOpportunities.get(opp.id).Name) 
                          || (opp.OwnerId!= OldOpportunities.get(opp.id).OwnerId) ){
                              
                              opp.addError('Opportunity is locked for editing on stage Closed/Won and Closed Lost. Kindly contact System admin.');
                          }
                   }
                
            }
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.ValidationLockedStage END ------- ' + Limits.getQueries());
    }
    
    public static void RecordTypecheck (List<Opportunity> newOpportunity, Map<Id,Opportunity> oldOpportunityMap){
        System.debug('Number of Queries used -- OpportunityTriggerManager.RecordTypecheck START ------- ' + Limits.getQueries());
        Id recordtypeId = Label.ReadOnlyRecordType;
        String limitToGCSC = Label.GCSC_Opportunity;
        
        Set<id> opportunityIdSet = new Set <id>();
        List <Opportunity> OppList = new List <Opportunity>();
        Map<Id,Integer> OpportunityOrderMap = new Map<Id,Integer>();
        
        for(Opportunity opp: newOpportunity){
            if(oldOpportunityMap.get(opp.Id).Actual_Record_Type_Name__c == limitToGCSC && (opp.Actual_Record_Type_Name__c != oldOpportunityMap.get(opp.Id).Actual_Record_Type_Name__c)){
                opportunityIdSet.add(opp.Id);
            }
        }
        
        if(!opportunityIdSet.isEmpty()){
            OppList = [SELECT id,name, (SELECT id,Name FROM Orders LIMIT 199) FROM Opportunity  where Id IN: opportunityIdSet];
            
            for(Opportunity opp: OppList){
                OpportunityOrderMap.put(opp.Id, opp.Orders.size());
            }
        }
        for(Opportunity opp: newOpportunity){
            if(OpportunityOrderMap.get(opp.Id)>0){
                opp.RecordTypeId.addError('You cannot change the record type from GCSC Opportunity to any other once order is linked ');
            } 
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.RecordTypecheck END ------- ' + Limits.getQueries());
    }
    
    
    public static void checkEndOfLifeProducts(List<Opportunity> newList, Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        System.debug('Number of Queries used -- OpportunityTriggerManager.checkEndOfLifeProducts START ------- ' + Limits.getQueries());
        
        /*List<Profile> profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
String proflieName = profile[0].Name;

if(proflieName != 'System Administrator'){*/
        if(userinfo.getProfileId() != System.Label.System_Admin_Id_18_Digit){
            List<Opportunity> recordList = new List<Opportunity>();
            List<Opportunity> autoCloseRecordList = new List<Opportunity>();
            Set<Id> oppIdsSet = new Set<Id>();
            Set<Id> oppAutoCloseIdsSet = new Set<Id>();
            
            Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GCSC Opportunity').getRecordTypeId();
            
            
            for(Opportunity newOpp : newList){
                //if GCSC Opp else Other Opp
                if(newOpp.RecordTypeId == recTypeId){    
                    if(newOpp.StageName == 'Proposal' && newOpp.StageName  != oldMap.get(newOpp.Id).StageName 
                       && newOpp.Opportunity_Deal_Year__c == 1){
                           
                           if(oldMap.get(newOpp.Id).StageName != 'Verbal'){
                               oppIdsSet.add(newOpp.Id);
                           }
                       } else
                       {
                           if(newOpp.StageName != 'Closed Lost' && newOpp.StageName  != oldMap.get(newOpp.Id).StageName 
                              && newOpp.Opportunity_Deal_Year__c == 1 ){
                                  oppIdsSet.add(newOpp.Id);
                              }
                       }   
                    
                } else {
                    if(newOpp.StageName == 'Proposal' &&
                       newOpp.StageName  != oldMap.get(newOpp.Id).StageName &&
                       newOpp.Opportunity_Deal_Year__c == 1){
                           
                           if(oldMap.get(newOpp.Id).StageName != 'Verbal'){
                               oppIdsSet.add(newOpp.Id);
                           }
                           
                       } else {
                           if(newOpp.StageName != 'Closed Lost' && newOpp.StageName != 'Closed/Won' &&
                              newOpp.StageName != 'Verbal' && newOpp.StageName  != oldMap.get(newOpp.Id).StageName 
                              && newOpp.Opportunity_Deal_Year__c == 1 ){
                                  oppIdsSet.add(newOpp.Id);
                              }
                       }                 
                }
                
                if(newOpp.Eligible_for_Auto_Close__c == true && 
                   newOpp.Eligible_for_Auto_Close__c != oldMap.get(newOpp.Id).Eligible_for_Auto_Close__c){
                       oppAutoCloseIdsSet.add(newOpp.Id);
                   }
                
            }
            if(!oppIdsSet.isEmpty()){
                recordList = [SELECT Id, (Select Id 
                                          From OpportunityLineItems
                                          Where Status__c = 'End of Life')
                              FROM Opportunity
                              WHERE Id IN: oppIdsSet];
            }
            
            if(!oppAutoCloseIdsSet.isEmpty()){
                autoCloseRecordList = [SELECT Id, (Select Id 
                                                   From OpportunityLineItems
                                                   Where Status__c = 'End of Life')
                                       FROM Opportunity
                                       WHERE Id IN: oppAutoCloseIdsSet];
            }
            
            if(!recordList.isEmpty()){
                List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                Set<Id> oppNotToUpdateIdsSet = new Set<Id>();
                for(Opportunity opp : recordList){
                    oliList = opp.OpportunityLineItems;
                    if(oliList.size() > 0) {
                        oppNotToUpdateIdsSet.add(opp.Id);
                    }                
                }
                
                if(!oppNotToUpdateIdsSet.isEmpty()){
                    for(Id opId : oppNotToUpdateIdsSet){
                        if(newMap.get(opId) != null){
                            newMap.get(opId).addError(System.Label.End_Of_Life_Products_Validation_Message);
                        }
                    }
                }
            }
            
            if(!autoCloseRecordList.isEmpty()){
                List<OpportunityLineItem> oliList1 = new List<OpportunityLineItem>();
                Set<Id> oppNotToUpdateIdsSet1 = new Set<Id>();
                for(Opportunity opp1 : autoCloseRecordList){
                    oliList1 = opp1.OpportunityLineItems;
                    if(oliList1.size() > 0) {
                        oppNotToUpdateIdsSet1.add(opp1.Id);
                    }                
                }
                
                if(!oppNotToUpdateIdsSet1.isEmpty()){
                    for(Id opId1 : oppNotToUpdateIdsSet1){
                        if(newMap.get(opId1) != null){
                            newMap.get(opId1).addError(System.Label.End_Of_Life_Products_Eligible_for_Auto_Close_Message);
                        }
                    }
                }
            }
        }
        System.debug('Number of Queries used -- OpportunityTriggerManager.checkEndOfLifeProducts END ------- ' + Limits.getQueries());
    }    
    
    //START Added below method copyClosedWonOrLostReason for SSE-21292 by Aashi 
    //To Copy Closed Won/Lost Reason, Sub-Reason and Comments to consecutive year renewal opprtunities
    public static void copyClosedWonOrLostReason(list<Opportunity> newList, Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        
        set<Id> contractIds = new set<Id>();
        Map<Id, list<Opportunity>> contractOppMap = new Map<Id, list<Opportunity>>();
        Map<Id, Opportunity> contractMapwith1stYearOpp = new Map<Id, Opportunity>();
        list<Opportunity> oppListToUpdate = new list<Opportunity>();
        
        for(Opportunity opp : newList){
            if(opp.Opportunity_Deal_Year__c == 1
               && opp.RecordTypeId != System.label.GCSCRecordType
               && (opp.StageName == System.label.Opportunity_Stage_6 || opp.StageName == System.label.Opportunity_Stage_7)
               && opp.Variation_Opportunity__c == 'No'
               && opp.Business_Type__c != 'Renewal'
               && opp.Auto_Created_Renewal__c == false
               && (oldMap.get(opp.Id).Closed_Lost_Reason__c != opp.Closed_Lost_Reason__c
                   || oldMap.get(opp.Id).Closed_Won_Lost_Reason_Sub_Type__c != opp.Closed_Won_Lost_Reason_Sub_Type__c
                   || oldMap.get(opp.Id).Closed_Lost_Reason_Additional_Details__c != opp.Closed_Lost_Reason_Additional_Details__c) &&
               ((opp.Closed_Lost_Reason__c != null || opp.Closed_Lost_Reason__c != '')
                   && (opp.Closed_Won_Lost_Reason_Sub_Type__c != null || opp.Closed_Won_Lost_Reason_Sub_Type__c != '')
                   && (opp.Closed_Lost_Reason_Additional_Details__c != null || opp.Closed_Lost_Reason_Additional_Details__c != ''))
              ){
                  if(opp.ContractId != null){
                      contractIds.add(opp.ContractId);
                      contractMapwith1stYearOpp.put(opp.ContractId, opp);
                  }
              }
        }
        
        if(contractMapwith1stYearOpp.size() > 0 && contractIds.size() > 0){
            list<Opportunity> autoRenewalOpportunities = [SELECT Id,ContractId,Closed_Lost_Reason__c,Closed_Won_Lost_Reason_Sub_Type__c,Closed_Lost_Reason_Additional_Details__c
                                                          FROM Opportunity 
                                                          WHERE Opportunity_Deal_Year__c != 1 
                                                          AND (StageName = 'Closed/Won' OR StageName = 'Closed Lost')
                                                          AND ContractId IN :contractIds];
            if(autoRenewalOpportunities.size() > 0){
                for(Opportunity oppRecord : autoRenewalOpportunities){
                    if(contractOppMap.containsKey(oppRecord.ContractId)){
                        contractOppMap.get(oppRecord.ContractId).add(oppRecord);
                    }else{
                        contractOppMap.put(oppRecord.ContractId, new list<Opportunity>{oppRecord});
                    }
                }
            } 
        }
        
        if(contractOppMap.size() > 0){
            for(Id contractId : contractOppMap.keySet()){
                list<Opportunity> oppListNew = contractOppMap.get(contractId);
                for(Opportunity oppp : oppListNew){
                    oppp.Closed_Lost_Reason__c = contractMapwith1stYearOpp.get(contractId).Closed_Lost_Reason__c;
                    if(oppp.Closed_Lost_Reason__c != 'Sanctioned Account'){
                        oppp.Closed_Won_Lost_Reason_Sub_Type__c = contractMapwith1stYearOpp.get(contractId).Closed_Won_Lost_Reason_Sub_Type__c;
                    	oppp.Closed_Lost_Reason_Additional_Details__c = contractMapwith1stYearOpp.get(contractId).Closed_Lost_Reason_Additional_Details__c;
                    }
                    
                    oppListToUpdate.add(oppp);
                }
            }
            if(oppListToUpdate.size() > 0)
                System.debug('opp list '+oppListToUpdate);
                UPDATE oppListToUpdate;
        }
        
    }
    
    public static void trackNextStepAndManagerComments(list<Opportunity> oppList){
        for(Opportunity opp : oppList){
            String currentValue, oldTrackValue, finalTrackValue, trackValueOfNextstep, trackValue;
            Integer updatedLength;
            String dateFormat = Datetime.now().format('dd-MMM-yy');
            if(opp.NextStep != null){
                currentValue = opp.NextStep;
                updatedLength =currentValue.length() + dateFormat.length();
                if(updatedLength > 255)
                    opp.NextStep.addError('Available character limit is 244');
                else{
                    opp.NextStep = dateFormat + ' ' + currentValue;
                    trackValue = processLogic(currentValue, 'Next Step');
                    finalTrackValue = assignmentLogic(trackValue, null);
                    opp.Next_Step_Manager_Notes_Tracking__c = finalTrackValue;   
                }
            }
            if(opp.Manager_s_Notes__c != null){
                trackValueOfNextstep = trackValue;
                currentValue = opp.Manager_s_Notes__c;
                updatedLength =currentValue.length() + dateFormat.length();
                if(updatedLength > 255)
                    opp.Manager_s_Notes__c.addError('Available character limit is 244');
                else{
                    opp.Manager_s_Notes__c = dateFormat + ' ' + currentValue;
                    trackValue = processLogic(currentValue, 'Manager\'s Notes');
                    finalTrackValue = assignmentLogic(trackValue, null);
                    opp.Next_Step_Manager_Notes_Tracking__c = (trackValueOfNextstep != null) ? (trackValueOfNextstep + '\n' + finalTrackValue) : finalTrackValue;   
                }
            }
        }
    }
    
    public static void trackNextStepAndManagerComments(list<Opportunity> oppList, Map<Id, Opportunity> oldMap){
        for(Opportunity opp : oppList){
            String currentValue, oldTrackValue, finalTrackValue, trackValueOfNextstep, trackValue;
            Integer updatedLength;
            oldTrackValue = oldMap.get(opp.Id).Next_Step_Manager_Notes_Tracking__c;
            String dateFormat = Datetime.now().format('dd-MMM-yy');
            if(opp.NextStep != null && oldMap.get(opp.Id).NextStep != opp.NextStep){
                currentValue = opp.NextStep;
                updatedLength =currentValue.length() + dateFormat.length();
                if(updatedLength > 255)
                    opp.NextStep.addError('Available character limit is '+ (255-dateFormat.length()));
                else{
                    opp.NextStep = dateFormat + ' ' + currentValue;
                    trackValue = processLogic(currentValue, 'Next Step');
                    finalTrackValue = assignmentLogic(trackValue, oldTrackValue);
                    opp.Next_Step_Manager_Notes_Tracking__c = finalTrackValue;   
                }
            }
            if(opp.Manager_s_Notes__c != null && oldMap.get(opp.Id).Manager_s_Notes__c != opp.Manager_s_Notes__c){
                trackValueOfNextstep = trackValue;
                currentValue = opp.Manager_s_Notes__c;
                updatedLength =currentValue.length() + dateFormat.length();
                if(updatedLength > 255)
                    opp.Manager_s_Notes__c.addError('Available character limit is '+ (255-dateFormat.length()));
                else{
                    opp.Manager_s_Notes__c = dateFormat + ' ' + currentValue;
                    trackValue = processLogic(currentValue, 'Manager\'s Notes');
                    finalTrackValue = assignmentLogic(trackValue, oldTrackValue);
                    opp.Next_Step_Manager_Notes_Tracking__c = (trackValueOfNextstep != null) ? (trackValueOfNextstep + '\n' + finalTrackValue) : finalTrackValue;   
                }
            }
        }
    }
    
    public static String processLogic(String currentValue, String fieldName){
        String currentDatetime = '(' + Datetime.now().format('dd-MMM-yy') + ')';
        //String currentDatetime = '(' + DateTime.now().format('yyyy-MM-dd HH:mm:ss') + ')';
        String trackValue = fieldName + ': ' + UserInfo.getName() + ' ' + currentDatetime + '\n' + currentValue;
        return trackValue;
    }
    
    public static String assignmentLogic(String trackValue, String oldTrackValue){
        String finalTrackValue = '';
        if(oldTrackValue != null)
            finalTrackValue = trackValue + '\n' + oldTrackValue;
        else
            finalTrackValue = trackValue;
        return finalTrackValue;
    } 
    
    public static void CheckBouncedMailOnPriceIncrease(List<Opportunity> OldOpps,List<Opportunity> NewOpps){
        for(integer i=0;i<OldOpps.size();i++){
            if(OldOpps[i].Renewal_Notification_Sent_On__c!=NewOpps[i].Renewal_Notification_Sent_On__c){
                if(NewOpps[i].Price_Notification_Email_Bounced__c==true && NewOpps[i].Renewal_Notification_Sent_On__c!=null){
                    NewOpps[i].Renewal_Notification_Sent_On__c=null;
                }
            }
        }
    }
    
    public static void extendOppAccessToOpportunityOwnerManager(list<Opportunity> oppList, Map<Id, Opportunity> oldMap){
        list<OpportunityShare> oppShareList = new list<OpportunityShare>();
        List<Database.SaveResult> saveOpportunityShareResult = new List<Database.SaveResult>();
        list<Id> oppOwnerList = new list<Id>();
        List<Group> managerGroupDetails = new List<Group>();
        Map<Id, Id> userWithGroupIdsMap = new Map<Id,Id>();
        
        for(Opportunity opp : oppList){
            oppOwnerList.add(opp.OwnerId);
        }
        String profileId = System.Label.CommercialProfileId;
        managerGroupDetails = [SELECT Id, RelatedId FROM Group WHERE Type = 'Manager' AND Related.IsActive = true AND RelatedId IN :oppOwnerList AND Related.ProfileId != :profileId];
        if(managerGroupDetails.size() > 0){
            for(Group grp : managerGroupDetails){
                userWithGroupIdsMap.put(grp.RelatedId,grp.Id);
            }
        }
        
        if(userWithGroupIdsMap.size() > 0){
            for(Opportunity opp : oppList){
                OpportunityShare oppShare = new OpportunityShare();
                if(oldMap != null && oldMap.size() > 0){
                    if(opp.OwnerId != null && oldMap.get(opp.Id).OwnerId != opp.OwnerId){
                        oppShare.OpportunityAccessLevel = 'Edit';
                        oppShare.OpportunityId = opp.Id;
                        oppShare.UserOrGroupId = userWithGroupIdsMap.get(opp.OwnerId);
                        oppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;
                        oppShareList.add(oppShare);
                    }
                }else{
                    if(opp.OwnerId != null){
                        oppShare.OpportunityAccessLevel = 'Edit';
                        oppShare.OpportunityId = opp.Id;
                        oppShare.UserOrGroupId = userWithGroupIdsMap.get(opp.OwnerId);
                        oppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;
                        oppShareList.add(oppShare);
                    }  
                } 
            }
        }
        
        if(oppShareList.size()>0){
            saveOpportunityShareResult = Database.insert(oppShareList,false);
        }
        
        if(saveOpportunityShareResult.size()>0){
            Integer i=0;
            for(Database.SaveResult sr : saveOpportunityShareResult){
                if(sr.isSuccess()){
                    System.debug('Success Id: '+ sr.getId());
                }else{
                    for(Database.Error err : sr.getErrors()){
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Opportunity fields that causes error: ' + err.getFields());
                    }
                }
                i++;
            }
        }
    }
    
    // Change for Extension Process
    public static void captureTotalExtensionLength(list<Opportunity> oppList, Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Map<Id, Opportunity> originalOppOfExtension = new Map<Id, Opportunity>();
        list<Id> parentOppIdsList = new list<Id>();
        
        for(Opportunity opp : oppList){
            if(opp.Business_Type__c == System.label.ExtensionOpportunityName && opp.Custom_Contract_Duration__c != null && opp.Variation_Reason__c <> System.label.ExtensionServiceDelayNoCharge && opp.Original_Opportunity__c != null){
                parentOppIdsList.add(opp.Original_Opportunity__c);
            }
        }
        
        if(parentOppIdsList.size() > 0){
            originalOppOfExtension = new Map<Id, Opportunity>([SELECT Id,Business_Type__c,Custom_Contract_Duration__c,Total_Extension_Length__c FROM Opportunity Where Id IN :parentOppIdsList]);
            for(Opportunity opp : oppList){
                if(opp.Business_Type__c == System.label.ExtensionOpportunityName && opp.Custom_Contract_Duration__c != null
                   && (oldMap == null || opp.Custom_Contract_Duration__c != oldMap.get(opp.Id).Custom_Contract_Duration__c)){
                       if(originalOppOfExtension.get(opp.Original_Opportunity__c).Business_Type__c == System.label.ExtensionOpportunityName
                          && originalOppOfExtension.get(opp.Original_Opportunity__c).Custom_Contract_Duration__c != null){
                              opp.Total_Extension_Length__c = opp.Custom_Contract_Duration__c + originalOppOfExtension.get(opp.Original_Opportunity__c).Total_Extension_Length__c;
                          }else{
                              opp.Total_Extension_Length__c = opp.Custom_Contract_Duration__c;
                          }
                   }
            }
        }
        
    }
    
    //SSE-24952 changes start
    public static void checkCancellationDocOnCloseLost(List<Opportunity> NewOpportunities,Map<id,Opportunity> OldOpportunitiesMap){
        
        Set<Id> closeLostOpportunityIds = new Set<Id>();
        
        for(Opportunity opp : NewOpportunities){
            if(opp.StageName == 'Closed Lost' && opp.Can_be_Auto_renewed__c == True && OldOpportunitiesMap.get(opp.Id).StageName!='Closed Lost' ){            
                closeLostOpportunityIds.add(opp.ID);
            }
        }
        
        if(!closeLostOpportunityIds.isEmpty()){
            
            List<GroupMember> userIdsList = [select UserOrGroupId from GroupMember where Group.DeveloperName in ('Commercial_Central_Operations','Commercial_Regional_Operations_AMERS','Commercial_Regional_Operations_ANZ','Commercial_Regional_Operations_China','Commercial_Regional_Operations_Europe','Commercial_Regional_Operations_HK','Commercial_Regional_Operations_India')];
            Set<Id> userIds = new Set<Id>();
            for(GroupMember gr : userIdsList){
                userIds.add(gr.UserOrGroupId);
            }
            Id currentUserId = UserInfo.getUserId();
            String userProfile =  [SELECT Id,Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
            Boolean hasOATsPermission = FeatureManagement.checkPermission('OATs');
            if(!userIds.contains(currentUserId) && userProfile!='System Administrator' && hasOATsPermission==False){
                List<String> rescindNoticeKeywordsList = System.Label.Opportunity_Rescind_Notice_Keywords.split(',');
                List<String> cancellationNoticeKeywordsList = System.Label.Opportunity_Cancellation_Notice_Keywords.split(',');      
                List<ContentDocumentLink> docList = [SELECT Id,LinkedEntityId,ContentDocument.Title,ContentDocument.LastModifiedDate from ContentDocumentLink where LinkedEntityId IN :closeLostOpportunityIds ORDER BY ContentDocument.LastModifiedDate ];
                
                Map<Id,String> opportunityFileMap = new Map<Id,String>();
                Map<Id,DateTime> opportunityFileDateMap = new Map<Id,DateTime>();
                
                for(ContentDocumentLink con : docList){
                    String type = '';
                    if(opportunityFileMap.get(con.LinkedEntityId)==null){
                        For(String keyword:rescindNoticeKeywordsList){
                            if(con.ContentDocument.title.containsIgnoreCase(keyword)){
                                type = 'rescind';
                            }
                        }
                        if(type==''){
                            For(String keyword:cancellationNoticeKeywordsList){
                                if(con.ContentDocument.title.containsIgnoreCase(keyword)){
                                    type = 'cancel';
                                }
                            } 
                        }
                        
                        opportunityFileMap.put(con.LinkedEntityId,type);
                        opportunityFileDateMap.put(con.LinkedEntityId,con.ContentDocument.LastModifiedDate);
                    }else{
                        if(opportunityFileDateMap.get(con.LinkedEntityId)<con.ContentDocument.LastModifiedDate){
                            For(String keyword:rescindNoticeKeywordsList){
                                if(con.ContentDocument.title.containsIgnoreCase(keyword)){
                                    type = 'rescind';
                                }
                            }
                            if(type==''){
                                For(String keyword:cancellationNoticeKeywordsList){
                                    if(con.ContentDocument.title.containsIgnoreCase(keyword)){
                                        type = 'cancel';
                                    }
                                } 
                            }
                            opportunityFileMap.put(con.LinkedEntityId,type);
                            opportunityFileDateMap.put(con.LinkedEntityId,con.ContentDocument.LastModifiedDate);
                        }
                    }
                }
                
                for(Opportunity opp : NewOpportunities){
                    if((opportunityFileMap.get(opp.Id)==null || opportunityFileMap.get(opp.Id)!='cancel') && opp.Account_Approval_Status__c !='Rejected - Sanctioned Account'){            
                        opp.addError('Cancellation Attachment Required to Close Lose the Renewal Opportunity');
                    }
                }
            }
        }
    }
    
    /*public static void checkVariationReasonChangedFromDebooking(List<Opportunity> NewOpportunities,Map<id,Opportunity> OldOpportunitiesMap){
        
        Set<Opportunity> opportunityList = new Set<Opportunity>();
        
        for(Opportunity opp : NewOpportunities){
            if(opp.Variation_Opportunity__c == 'Yes' && opp.Variation_Reason__c!='Correction' && opp.Variation_Reason__c!='Debooking' && OldOpportunitiesMap.get(opp.Id).Variation_Reason__c=='Debooking' ){            
                opportunityList.add(opp);
            }
        }
        
        if(!opportunityList.isEmpty()){
            Id currentUserId = UserInfo.getUserId();
            String userProfile =  [SELECT Id,Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
            
            if(userProfile!='System Administrator')
                for(Opportunity opp : opportunityList){
                    opp.addError('You cannot change the variation reason on the debooking opportunity');
                }
        }
    }*/
    
    public static void updateDebookingScopeOnCloseLost(List<Opportunity> NewOpportunities,Map<id,Opportunity> OldOpportunitiesMap){
        
        Set<Opportunity> opportunityList = new Set<Opportunity>();
        List<Id> opportunityIds = new List<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountList = new List<Account>();
        
        for(Opportunity opp : NewOpportunities){
            if((opp.StageName == System.Label.Opportunity_Stage_7 && OldOpportunitiesMap.get(opp.Id).StageName != System.Label.Opportunity_Stage_7 && opp.Variation_Opportunity__c == 'Yes' && (opp.Variation_Reason__c=='Correction' || opp.Variation_Reason__c=='Debooking'))||
               opp.Variation_Opportunity__c == 'Yes' && opp.Variation_Reason__c=='Correction' && OldOpportunitiesMap.get(opp.Id).Variation_Reason__c=='Debooking'){            
                opportunityList.add(opp);
                opportunityIds.add(opp.Id);
            }
            if(opp.Account_Approval_Status__c == 'Rejected - Sanctioned Account'){
                accountIds.add(opp.AccountId);
            }
        }
        
        if(!opportunityList.isEmpty()){
            
            if(!accountIds.isEmpty()){
                for(Id accId : accountIds){
                    Account acc = new Account();
                    acc.Id = accId;
                    acc.Skip_Validation__c = true;
                    
                    accountList.add(acc);
                }
                
                update accountList;
            }
            
            system.debug('inside scope update');
            List<OpportunityLineItem> oppLineItems = [SELECT Id,Quantity,TotalPrice,UnitPrice,Original_Opportunity_Product__c,Solution_Cap__c FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIds and Original_Opportunity_Product__c!=null];
            List<Id> oppLineIds = new List<Id>();
            Map<Id,OpportunityLineItem> oppLineMap = new Map<Id,OpportunityLineItem>();
            for(OpportunityLineItem line : oppLineItems){
                oppLineIds.add(line.Original_Opportunity_Product__c);
                oppLineMap.put(line.Original_Opportunity_Product__c,line);
            }
            system.debug('inside scope update 2');
            List<OpportunityLineItem> oppLineItemsToUpdate = [SELECT Id,Quantity,UnitPrice,TotalPrice,Solution_Cap__c,Debooked_Quantity__c,Debooked_Sales_Price__c,Debooked_Total_Value__c,Debooked_Solution_Cap__c FROM OpportunityLineItem WHERE Id IN :oppLineIds];
            system.debug(oppLineItemsToUpdate);
            for(OpportunityLineItem lineItem : oppLineItemsToUpdate){
                if(-lineItem.Quantity == oppLineMap.get(lineItem.Id).Quantity && -lineItem.TotalPrice == oppLineMap.get(lineItem.Id).TotalPrice){
           
                  	lineItem.Debooked_Quantity__c = (lineItem.Debooked_Quantity__c - (-(oppLineMap.get(lineItem.Id).Quantity))).setScale(2, RoundingMode.HALF_UP);
                	//lineItem.Debooked_Sales_Price__c = (lineItem.Debooked_Sales_Price__c - (oppLineMap.get(lineItem.Id).UnitPrice)).setScale(8, RoundingMode.HALF_UP); 
                	lineItem.Debooked_Total_Value__c = (lineItem.Debooked_Total_Value__c - (-(oppLineMap.get(lineItem.Id).TotalPrice))).setScale(2, RoundingMode.HALF_UP);  
                }else if(-lineItem.Quantity != oppLineMap.get(lineItem.Id).Quantity && -lineItem.TotalPrice == oppLineMap.get(lineItem.Id).TotalPrice){
                    system.debug('inside scope update 4');
                    lineItem.Debooked_Quantity__c = (lineItem.Debooked_Quantity__c - (-(oppLineMap.get(lineItem.Id).Quantity))).setScale(2, RoundingMode.HALF_UP);
					lineItem.Debooked_Total_Value__c = (lineItem.Debooked_Total_Value__c - (-(oppLineMap.get(lineItem.Id).TotalPrice))).setScale(2, RoundingMode.HALF_UP);  

                }else if(-lineItem.Quantity == oppLineMap.get(lineItem.Id).Quantity && -lineItem.TotalPrice != oppLineMap.get(lineItem.Id).TotalPrice){
                    
                    lineItem.Debooked_Total_Value__c = (lineItem.Debooked_Total_Value__c - (-(oppLineMap.get(lineItem.Id).TotalPrice))).setScale(2, RoundingMode.HALF_UP);
                }else if(-lineItem.Quantity != oppLineMap.get(lineItem.Id).Quantity && -lineItem.TotalPrice != oppLineMap.get(lineItem.Id).TotalPrice){
     
                    lineItem.Debooked_Quantity__c = (lineItem.Debooked_Quantity__c - (-(oppLineMap.get(lineItem.Id).Quantity))).setScale(2, RoundingMode.HALF_UP);
					lineItem.Debooked_Total_Value__c = (lineItem.Debooked_Total_Value__c - (-(oppLineMap.get(lineItem.Id).TotalPrice))).setScale(2, RoundingMode.HALF_UP);
                	//Decimal remainingQuantity = lineItem.Quantity + oppLineMap.get(lineItem.Id).Quantity;
                    //Decimal remainingPrice = ((lineItem.Quantity*lineItem.UnitPrice) + (oppLineMap.get(lineItem.Id).Quantity*oppLineMap.get(lineItem.Id).UnitPrice));
                    //Decimal priceIncreasePerQuantity = (lineItem.UnitPrice - (remainingPrice/remainingQuantity)).setScale(8, RoundingMode.HALF_UP);
           
                    //lineItem.Debooked_Sales_Price__c = (lineItem.Debooked_Sales_Price__c - priceIncreasePerQuantity); 

                }    
                lineItem.Debooked_Solution_Cap__c = (lineItem.Debooked_Solution_Cap__c - (-(oppLineMap.get(lineItem.Id).Solution_Cap__c))).setScale(2, RoundingMode.HALF_UP);
            }
            
            Update oppLineItemsToUpdate;
            
            if(!accountIds.isEmpty()){
                for(Account acc : accountList){
                    acc.Skip_Validation__c = false;
                }
                
                update accountList;
            }
            
        }
    }

    public static void totalSolutionCapCalculation(List<Opportunity> oldOpportunities,List<Opportunity> NewOpportunities){
        System.debug('Inside method');
        List<Opportunity> closedOpps = new List<Opportunity>();
        for(integer i=0;i<oldOpportunities.size();i++){
            if(oldOpportunities[i].stageName!=newOpportunities[i].stageName && newOpportunities[i].stageName=='Closed/Won'){
                closedOpps.add(newOpportunities[i]);
            }
            System.debug('Closed Opps '+closedOpps);
            if(closedOpps.size()>0){
            List<AggregateResult> results = [select max(Solution_Cap__c),Opportunityid from OpportunityLineItem  where opportunityid in :closedOpps and Package__c!='Service' and  Package__c!='Product' group by Package__c,Opportunityid];
            Map<Id,Decimal> OppCapMap = new Map<Id,Decimal>();
            for(AggregateResult result:results){
                System.debug('result: '+result);
                Id key = (Id)result.get('OpportunityId');
                if(OppCapMap.containskey(key)){
                    Decimal temp = OppCapMap.get(key) + (Decimal)result.get('expr0');
                    OppCapMap.put(key,temp);
                }
                else{
                    OppCapMap.put(key,(Decimal)result.get('expr0'));  
                }
            }
            System.debug('Map '+OppCapMap);
            List<AggregateResult> prodResults = [select sum(Solution_Cap__c),Opportunityid from OpportunityLineItem  where opportunityid in :closedOpps and Package__c='Product' group by Opportunityid];
            for(AggregateResult result:prodResults){
                System.debug('result: '+result);
            }
            for(Id oppid:OppCapMap.keyset()){
                Decimal TotalSolutionCap=0;
                for(AggregateResult result:prodResults){
                    if(oppid==(Id)result.get('OpportunityId')){
                        if(result.get('expr0')!=null){
                            TotalSolutionCap = OppCapMap.get(oppid) + (Decimal)result.get('expr0');
                        }
                        else{
                           TotalSolutionCap = OppCapMap.get(oppid) + 0; 
                        }
                        
                        OppCapMap.put(oppid,TotalSolutionCap);
                    }   
                }
            }
            System.debug('Map '+OppCapMap); 
            for(Id oppId:OppCapMap.keyset()){
                for(Opportunity closedOpp:closedopps){
                    if(oppId==closedOpp.Id){
                        closedOpp.Total_Solution_Cap__c = OppCapMap.get(oppId);
                    }
                }
            }
            System.debug('Opps to Update '+closedopps);
            }
        }
    }
}
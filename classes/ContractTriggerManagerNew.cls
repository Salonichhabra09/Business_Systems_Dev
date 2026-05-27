/**************************************************************************************************************************************
CREATED BY :- Saloni Chhabra
CREATED DATE :- 12-08-2020
DESCRIPTION :- This class contains Contract trigger related functionalities : before update,after update
***************************************************************************************************************************************/ 
global class ContractTriggerManagerNew{

    //Contract cannot be marked as cancelled if have any related Order activated
    public static void ContractCancel(List<Contract> contractlistnew,List<Contract> contractlistold){
			 System.debug('Number of Queries used -- ContractTriggerManagerNew.ContractCancel START ------- ' + Limits.getQueries());
            set<id> contractid = new set<id>();
            for(integer i=0; i<contractlistnew.size(); i++){
                if( contractlistnew[i].RecordType.DeveloperName != 'MSA_Contract' && ( //add check to exclude MSA Contract
                    contractlistnew[i].Status=='Cancelled' && contractlistold[i].Status != 'Cancelled') ){
                        contractid.add(contractlistnew[i].id);
                        
                    }
                }
        system.debug('---->contractid<---'+contractid);
        if(!contractid.isEmpty()){
            List<Order> ActvOrderList = [Select id,name,Status,Contractid,Order_Year__c from Order where Contractid in: contractid AND Status ='Activated' AND Order_Year__c>1];
            if(ActvOrderList.size()>0){
                for(Contract contr:contractlistnew){
                contr.addError('Contract cannot be marked as cancelled as linked Renewal Order is already activated');
                }
            }
        }
        System.debug('Number of Queries used -- ContractTriggerManagerNew.ContractCancel END ------- ' + Limits.getQueries());
        }
        
    //Contract can only be accepted until linked opportunity billing contact is null or not a part of same Account.
    //Contract can only be accepted until linked opportunity is moved to verbal
    public static void ContractActvOpptyVerbal(List<Contract> contractlistnew,List<Contract> contractlistold){
        System.debug('Number of Queries used -- ContractTriggerManagerNew.ContractActvOpptyVerbal START ------- ' + Limits.getQueries());
        set<id> contractid = new set<id>();
            for(integer i=0; i<contractlistnew.size(); i++){
                if( contractlistnew[i].RecordType.DeveloperName != 'MSA_Contract' && ( //add check to exclude MSA Contract
                    contractlistnew[i].Status=='Accepted' && contractlistold[i].Status != 'Accepted') ){
                        contractid.add(contractlistnew[i].id);
                        
                    }
                }
        system.debug('----> contractid second method--'+contractid);
           if(!contractid.isEmpty()){                                 
            List<Opportunity> OrgOpptyList2 = [Select id,name,StageName,Contractid,Business_Type__c,Billing_Contact__c from Opportunity where Billing_Contact__c = null AND Contractid in: contractid];
            if(OrgOpptyList2.size()>0){
                for(Contract contr:contractlistnew){
                contr.addError('Contract cannot be marked as Accepted as associated Opportunity does not have a Billing Contact');
                }
            }
            
            set<id> accountids = new set<id>();            
            Set<id> contractids = new set<id>();   // set of contract ids where contact is a part of account.
            Map<Id,List<Contact>> mapAccountContact = new Map<Id,List<Contact>>();
            
            List<Opportunity> OrgOpptyList3 = [Select id,name,AccountId,StageName,Contractid,Business_Type__c,Billing_Contact__c from Opportunity where Billing_Contact__c != null AND Contractid in: contractid]; 
            if(OrgOpptyList3.size()>0){
               for(Opportunity olist : OrgOpptyList3){
                   accountids.add(olist.AccountId);
               }
            }
            
            if(accountids != null){
               List<Account> acclist = [Select id,(Select Id from Contacts) from Account where Id IN: accountids];
                   for(Account acc: acclist){                
                      mapAccountContact.put(acc.Id, acc.contacts);
                   }
               
            }
                         
            for(Opportunity olist : OrgOpptyList3){ 
                for(Contact con: mapAccountContact.get(olist.AccountId)) {
                    if(olist.Billing_Contact__c == con.id)
                      contractids.add(olist.ContractId);   // positive contracts where combination of contact and account is right on opp
                } 
             } 
             
             if(OrgOpptyList3.size()>0){ 
                 for(Contract contr:contractlistnew){
                    if(!contractids.contains(contr.id)){ // if contract is not a part of positive combination of contact and account set.
                       contr.addError('Contract cannot be marked as Accepted as associated Opportunity Billing Contact is not a part of Account');
                    }
                 }
             } 
           } 
            /*List<Opportunity> OrgOpptyList = [Select id,name,StageName,Opportunity_Deal_Year__c,Contractid,Business_Type__c from Opportunity where StageName!='Verbal' AND Contractid in: contractid];
            if(OrgOpptyList.size()>0){
                for(Contract contr:contractlistnew){
                contr.addError('Contract cannot be marked as Accepted as Opportunity is not in Verbal');
                }
            }*/
        System.debug('Number of Queries used -- ContractTriggerManagerNew.ContractActvOpptyVerbal END ------- ' + Limits.getQueries());
        
    }
    
     // This method is responsible for PDF and CSV checks/errors on Contract when User is trying to attach files/attachment.
      public static void OrderPdfCsvChecks(List<Contract> ContractsNewList, List<Contract> ContractsOldList){
          System.debug('Number of Queries used -- ContractTriggerManagerNew.OrderPdfCsvChecks START ------- ' + Limits.getQueries());
         Boolean isAdmin = false;
         Boolean statusIsSubmitted = false;
         Set<Id> contractIdsSet = new Set<Id>(); 
         String oppRecordType = System.Label.GCSCRecordType;
         String oppRecordTypeIgnite = System.Label.IgniteRecordType; 
         
        for(Profile prf : [Select id,Name from Profile where Name like '%System Admin%']){
            if(prf.Id == UserInfo.getProfileId()){
              isAdmin = true;
              break;
            }
        }
        
         for(Integer i=0;i<ContractsNewList.size();i++){
            if( ContractsNewList[i].RecordType.DeveloperName != 'MSA_Contract' && ( //add check to exclude MSA Contract
                (ContractsNewList[i].status=='Under Customer Review' && ContractsOldList[i].status!='Under Customer Review') ||
                (ContractsNewList[i].status=='Accepted' && ContractsOldList[i].status!='Accepted') )
            ){
                statusIsSubmitted = true;
                contractIdsSet.add(ContractsNewList[i].id);
            }        
        }
        
        if(statusIsSubmitted == true && !contractIdsSet.isEmpty()){            
            Map<id,Contract> contractMap = new Map<Id,Contract>([Select id, OwnerId,PDFCount__c,CSVCount__c, Accountid,Billing_Contact__c,Booking_Date__c,Invoicing_Contact__c,TCV__c,
                                                            Annual_Contract_Value__c,Unconfirmed_Sun_Order_Number__c, NVM_Credit_Card_ID__c,
                                                            Opportunity__r.Annual_Contract_Value__c,Opportunity__r.Amount,Opportunity__r.ownerId,Opportunity__r.Eligible_for_Auto_Close__c,
                                                            Opportunity__r.AccountId,Opportunity__r.Billing_Contact__c,Opportunity__r.Closedate,Opportunity__r.StageName,
                                                            Opportunity__r.Primary_Contact__c,Opportunity__r.CurrencyIsoCode,Opportunity__r.Unconfirmed_Sun_Order_Number__c,
                                                            Opportunity__r.NVM_Credit_Card_ID__c,Opportunity__r.GCSC__c,Opportunity__r.RecordTypeId,
                                                            (Select id,ParentID from Attachments where contenttype='application/pdf') 
                                                            from Contract where id in :contractIdsSet]);
            
             //Added Eligible Auto- Close condition by Prachi - SSE-16342
            List<opportunity> oppList = new List<opportunity>([Select id ,Eligible_for_Auto_Close__c ,RecordTypeId, ContractId from opportunity where ContractId in :contractIdsSet ]);
            Map<string,opportunity> oppMap = new Map<string,opportunity>();
            for(Opportunity o: oppList){
                oppMap.put(o.ContractId , o);
            }
            //Change End SSE-16342
          //  Map<string, Opportunity> oppMap = new Map<
             for(Contract contract : ContractsNewList){
                if(!isAdmin){
                      if((contract.status=='Under Customer Review' || contract.status=='Accepted')){
                           /*if(contractMap.get(contract.id).Opportunity__r.RecordTypeId !=oppRecordTypeIgnite){
                                if(contractMap!= null  && contract.Booked_Elsewhere__c == false && contractMap.get(contract.id).Opportunity__r.RecordTypeId != oppRecordType){  
                                    if(contractMap.get(contract.id).PDFCount__c==0 ||contractMap.get(contract.id).PDFCount__c==null){
                                        contract.adderror('Contract status cannot be changed to "'+ contract.status + '" as it does not have a signed Order PDF attached');
                                    }
                                }
                            }*/
                            
                            //Added Eligible Auto- Close condition by Prachi - SSE-16342
                            if(contractMap!= null  && contract.Booked_Elsewhere__c == false && contractMap.containsKey(contract.id) && oppMap.get(contract.id).Eligible_for_Auto_Close__c == false && contractMap.get(contract.id).Opportunity__r.RecordTypeId != oppRecordType){  
                                if((contractMap.get(contract.id).PDFCount__c==null)||(contractMap.get(contract.id).CSVCount__c ==null)||(contractMap.get(contract.id).CSVCount__c ==0) || (contractMap.get(contract.id).PDFCount__c<1)){
                                    contract.adderror('Contract status cannot be changed to "'+ contract.status + '" as it does not have both  \'Signed Order Form PDF\' and \'Pricing Configurator\'');  
                                }
                            }
                      }
                }
             }              
        }
          System.debug('Number of Queries used -- ContractTriggerManagerNew.OrderPdfCsvChecks END ------- ' + Limits.getQueries());
      }
    
    //This method is to update total contract value on contract activation.
     public static void ContractValue(List<Contract> contractlistnew,List<Contract> contractlistold){
         System.debug('Number of Queries used -- ContractTriggerManagerNew.ContractValue START ------- ' + Limits.getQueries());
        System.debug('Hello***');
        
        
        set<id> contractid = new set<id>();
        List< Contract> contList = new List <Contract>();
        List<Contract> conlist2 = new List<Contract>();
        double count =0;
        for(integer i=0; i<contractlistnew.size(); i++){
            if( contractlistnew[i].RecordType.DeveloperName != 'MSA_Contract' && ( //add check to exclude MSA Contract
                contractlistnew[i].Status=='Accepted' && contractlistold[i].Status != 'Accepted' ) 
              ){
                contractid.add(contractlistnew[i].id);
                
            }
            
            
        }
        System.debug('count*****'+ contractid);
        
        if(!contractid.isEmpty())
        {
            contList = [Select id,(Select id,Future_Product_Total_Price__c,Amount,Contractid from Opportunities) from Contract where id in: contractid];
            
            for( contract c :contList){
                if(c.Opportunities.size()>0){
                    for(Opportunity opp :c.Opportunities){
                        count =  opp.Future_Product_Total_Price__c + opp.Amount;
                        System.debug('count'+count);
                    }
                    c.Total_Contract_Value__c = count;
                    System.debug('count***'+ c.Total_Contract_Value__c);
                    
                }
                conlist2.add(c);
                
                
                
                
                
            }     
        }
        update conlist2;
        
        System.debug('Number of Queries used -- ContractTriggerManagerNew.ContractValue END ------- ' + Limits.getQueries());
        
        
    }
      
      // This method is responsible for adding zero year product as susbcription does not start on same day of contract start date.
      /*public static void SubscriptionValidations(List<Contract> ContractsNewList, List<Contract> ContractsOldList){
        Boolean validationtrue = false;
        Boolean isAdmin = false;
        Set<id> OpptyIdSet = new Set<id>();
        Set<Id> ContractIDSet = new Set<id>();
        List<Opportunity> ListOpportunity  = new List<Opportunity>();
        List<OpportunityLineItem> OpptyProductList = new List<OpportunityLineItem>();
        
        for(Profile prf : [Select id,Name from Profile where Name like '%System Admin%']){
            if(prf.Id == UserInfo.getProfileId()){
              isAdmin = true;
              break;
            }
        }
        if(!isAdmin){
            for(Integer i=0;i<ContractsNewList.size();i++){
                ContractIDSet.add(ContractsNewList[i].id);               
                    if(ContractsOldList[i].status !='Accepted' && ContractsNewList[i].status=='Accepted'){
                        validationtrue = true;
                    }
                }
        
        
            if(validationtrue == true){
                ListOpportunity = [Select id,name,ContractID,Opportunity_Deal_Year__c from Opportunity where ContractId in:ContractIDSet AND Opportunity_Deal_Year__c =1];
            }
            
            if(ListOpportunity.size()>0){
                for(Opportunity OppObj:ListOpportunity){
                    OpptyIdSet.add(OppObj.id);
                }
            }
            OpptyProductList = [Select id,Contract_Year__c,OpportunityId from OpportunityLineItem where Contract_Year__c = '0' AND OpportunityId IN: OpptyIdSet];
        
        
            for(Integer i=0;i<ContractsNewList.size();i++){
                    if(OpptyProductList.isEmpty() == true && ContractsNewList[i].Subscription_Start_Date__c > ContractsNewList[i].StartDate && ContractsOldList[i].status !='Accepted' && ContractsNewList[i].status=='Accepted'){
                    ContractsNewList[i].addError('Please add Zero year product to Opportunity as product subscription starts after contract start date.');
                }
                else if(OpptyProductList.size() > 0 && ContractsNewList[i].Subscription_Start_Date__c == ContractsNewList[i].StartDate && ContractsOldList[i].status !='Accepted' && ContractsNewList[i].status=='Accepted'){
                    ContractsNewList[i].addError('Please mark Product subscription start date after Contract start date as opportunity has zero year products or delete zero year product & services');
                }
            }
        }
          
    }*/
     
}
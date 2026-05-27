/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 06-06-2019
DESCRIPTION :- This class contains Contract trigger related functionalities : before delete,after update (order delete checks, Related Case, Opportunity,ContractLine updates)
***************************************************************************************************************************************/ 
global class ContractTriggerManager_1{
    
    // This method validates profile of a user. Validation error is thrown if user with profile other than OAT, System Admin and Leagl Team tries to delete order.
    public static void ValidateUserProfile(List<Contract> ContractsList){
        Set<Id> profileIdsSet = new Set<Id>();
        List<Profile> profileList = [Select id,Name from Profile where Name = 'OAT' OR  Name like '%System Admin%' OR  Name like '%Legal Team%'];    
        
        for(Profile prof:profileList)
        profileIdsSet.add(prof.id);
        
        List<User> usr = [Select id from User where id=:UserInfo.getUserId() and profileId in :profileIdsSet];
       
        if(usr.size()==0){
            for(Contract cont:ContractsList)
            cont.addError('Only users of OAT and System Admin profiles can delete orders.');
        }
    }
   
   /*In this method, when order status is changed as below, related opportunity stage is updated too.
     Order Status updated to: Cancelled OR Order - Cancelled :  Related Opp stage updated to Closed Lost
     Order Status updated to: Submitted OR Booked elsewhere complete :  Related Opp stage updated to Closed/Won
     Order Status updated to: Rejected Related Opp stage updated to Verbal
   */
    public static void UpdateRelatedOpportunityStage(List<Contract> ContractsNewList,List<Contract> ContractsOldList){
        Set<Id> oppIdsSet = new Set<Id>();
        Map<Id,Contract> oppIdContractMap = new Map<Id,Contract>();   
        Order_Skip_Validation__c tempSkipValidation = Order_Skip_Validation__c.getInstance();
        
        if(tempSkipValidation == null){
            tempSkipValidation = new Order_Skip_Validation__c();
        }
        
        for(integer i=0; i<ContractsNewList.size(); i++){
             if((ContractsNewList[i].Status=='Cancelled' && ContractsOldList[i].Status!='Cancelled') || (ContractsNewList[i].Status =='Order - Cancelled' && ContractsOldList[i].Status!='Order - Cancelled') ||  (ContractsNewList[i].Status =='Submitted' && ContractsOldList[i].Status !='Submitted') || (ContractsNewList[i].Status =='Rejected' && ContractsOldList[i].Status !='Rejected') || (ContractsNewList[i].Status =='Booked elsewhere complete' && ContractsOldList[i].Status !='Booked elsewhere complete')){
                 oppIdsSet.add(ContractsNewList[i].Opportunity__c);
                 oppIdContractMap.put(ContractsNewList[i].Opportunity__c,ContractsNewList[i]);
             }       
        }
        try{
             //End code for CRI - 823
            for(Opportunity[] oppList:[select id,StageName,Closed_Lost_Reason__c from opportunity where id in :oppIdsSet]){
                for(Opportunity opp:oppList){                    
                    if(oppIdContractMap.get(opp.id).Status == 'Cancelled' || oppIdContractMap.get(opp.id).Status=='Order - Cancelled'){
                        opp.StageName = System.Label.Opportunity_Stage_7;
                        opp.Allow_Closed__c= true;
                        opp.Closed_Lost_Reason__c = 'Finance Drop'; 
                    }
                     else if((oppIdContractMap.get(opp.id).Status == 'Submitted') || (oppIdContractMap.get(opp.id).Status == 'Booked elsewhere complete')){
                         opp.StageName = System.Label.Opportunity_Stage_6;
                         opp.Allow_Closed__c= true;
                         System.debug('*********opp.StageName******'+opp);
                    }                   
                     else if(oppIdContractMap.get(opp.id).Status == 'Rejected'){
                        //updating  custom setting flag back to true to work validations on opportunity.
                        tempSkipValidation.Skip_Validation__c = true;
                        upsert tempSkipValidation;
                        if(tempSkipValidation.Skip_Validation__c == true){
                         //opp.Likelihood__c='90%';
                         opp.Probability=90; //SSE-8225
                         opp.StageName = System.Label.Opportunity_Stage_5;
                         opp.Allow_Closed__c= true;
                        }
                    }                   
                }
                    update oppList;              
            }                       
            //updating  custom setting flag back to false  to work validations on opportunity.
            tempSkipValidation.Skip_Validation__c = false;
            upsert tempSkipValidation;
        }
        catch(Exception e){
            //Edited By Virendra Kumar as per feedback story SSE-7732 on 19/09/2018
            //Trigger.new[0].addError('To submit an order for an opportunity, "Talent Level, Function & Offering" fields are mandatory on related opportunity. Please note that the value of Unknown cannot be chosen for non-GCSC opps');
            String S1 = e.getMessage();  
            S1 = S1.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': [');   
            ContractsNewList[0].adderror(S1);   // CHECK
        }
    } 
    
    //In this method,Updating Activation Date on Order from blank to some value updates the Order Activation Date on Related Case.
    public static void UpdateRelatedCase(List<Contract> ContractsNewList, List<Contract> ContractsOldList){
         Set<Id> orderIdsSet = new Set<Id>();
         for(integer i=0; i<ContractsNewList.size(); i++){
             if(ContractsNewList[i].ActivatedDate!=null && ContractsOldList[i].ActivatedDate==null){
                 orderIdsSet.add(ContractsNewList[i].id);
             }             
         }
         //Below code is implemented for CRI - 823          
        List<Case> caseList = [Select id ,Order_Activation_Date__c,Order__c from Case where Order__c in :orderIdsSet];
        Map<Id,Case> orderIdCaseMap = new Map<Id,Case>();
        if(caseList.size()>0){
            for(Case cse: caseList)
                orderIdCaseMap.put(cse.Order__c,cse);
            for(Integer j = 0; j<ContractsNewList.size(); j++){
                if(orderIdCaseMap.get(ContractsNewList[j].id)!=null)
                orderIdCaseMap.get(ContractsNewList[j].id).Order_Activation_Date__c = ContractsNewList[j].ActivatedDate;
            }
            if(orderIdCaseMap.size()>0)
            update orderIdCaseMap.values();
        }
    }  
    
    // In this method, When order Status and Currency is updated, Related ContractLine Currency value is updated with Order currency.
    public static void UpdateRelatedContractLineCurrency(List<Contract> ContractsNewList,List<Contract> ContractsOldList){
        Set<Id> OrderCurrencyChange = new set<id>();
        Map<Id,String> OrderCurrencyvalue = new Map<id,string>();
        for(integer i=0; i<ContractsNewList.size(); i++){         
             if((ContractsNewList[i].Status!='Cancelled' || ContractsNewList[i].Status!='Completed') && ContractsOldList[i].CurrencyIsoCode!= ContractsNewList[i].CurrencyIsoCode){
                OrderCurrencyChange.add(ContractsNewList[i].id);
                OrderCurrencyvalue.put(ContractsNewList[i].id,ContractsNewList[i].CurrencyIsoCode);
            }            
        }
        //Added by saloni chhabra for SSE-4820 mapping currency between Order-Order Line
        if(OrderCurrencyChange != null){
            Map<Id,Contract_Line__c> contractList = new Map<Id,Contract_Line__c>([SELECT id,CurrencyIsoCode,Contract__c FROM Contract_Line__c WHERE  Contract__c in : OrderCurrencyChange]);
            system.debug('---->begin_contractList.values()<----'+contractList.values());
            if(contractList.size()>0 && contractList != null)
            {
                for(Contract_Line__c contractLine:contractList.values())
                {
                    contractLine.CurrencyIsoCode = OrderCurrencyvalue.get(contractLine.Contract__c);
                    
                }
                system.debug('---->contractList.values()<----'+contractList.values());
                update contractList.values();
            }
        }
    }  
    
    // In this method, Booking Date on Order is updated on the basis of Activated_Date__c and Last_Possible_Submission_Date__c.
    public static void UpdateOrderBookingDate(List<Contract> ContractsNewList,List<Contract> ContractsOldList){
        Set<Id> activatedOrderIdsSet = new Set<Id>();
        Map<Id,Contract> NewConId_OldConMap = new Map<Id,Contract>();
        integer workingDays =0;
        date currentDate;
        date lastDayOfPriorMonth;
        datetime lastPossibleSubmissionDate;
        integer submissionOffset;
        integer activationOffSet;
        integer quarterEnd;
        List<Date> workingDaysList = new List<Date>();
        
        for(integer i=0; i<ContractsNewList.size(); i++){  
            if(ContractsNewList[i].Activated_Date__c != ContractsOldList[i].Activated_Date__c)
                activatedOrderIdsSet.add(ContractsNewList[i].id);
                NewConId_OldConMap.put(ContractsNewList[i].id,ContractsOldList[i]);               
        }  
        
        //Edited by saloni chhabra on 4/28/2015 for skiping validation rule for updating booking date on complete order SSE-25
        Order_Skip_Validation__c tempSkipValidation = Order_Skip_Validation__c.getInstance();
        if(tempSkipValidation == null) {
            tempSkipValidation = new Order_Skip_Validation__c();
        }
              
        List<Contract> contractList = [SELECT id,ActivatedDate,Activated_Date__c,Booking_Date_EST__c,Submission_Offset__c,Activation_Offset__c,Last_Possible_Submission_Date__c,Final_Submission_Date_EST__c,Booking_Date_New__c FROM Contract WHERE id in : activatedOrderIdsSet];
        for(Contract contractRec : contractList)
        {
            Contract oldContract = NewConId_OldConMap.get(contractRec.ID);// Added By Rishabh Kanotra as per SSE-5873
            currentDate = date.today();
            lastDayOfPriorMonth = currentDate.toStartOfMonth().addDays(-1);
            submissionOffset = Integer.valueOf(contractRec.Submission_Offset__c)/3600000;
            activationOffSet = Integer.valueOf(contractRec.Activation_Offset__c)/3600000;
            if(contractRec.Last_Possible_Submission_Date__c!= null)
            {
                lastPossibleSubmissionDate = contractRec.Last_Possible_Submission_Date__c.addHours(submissionOffset);
                quarterEnd = math.mod(lastPossibleSubmissionDate.monthGMT(),3);
            }
            
            if(contractRec.Activated_Date__c != NULL && lastPossibleSubmissionDate!=NULL){     
                if(contractRec.Activated_Date__c <= lastPossibleSubmissionDate){
                    contractRec.Booking_Date_EST__c = contractRec.Activated_Date__c;
                }
                else if(contractRec.Activated_Date__c > lastPossibleSubmissionDate){
                        workingDaysList = DatetimeHelper.getWorkingDaysBetweenDates(lastPossibleSubmissionDate.dateGMT(),contractRec.Activated_Date__c.dateGMT(),quarterEnd);
                        workingDays = workingDaysList.size();
                        system.debug('*******workingDaysList**********' + workingDaysList + '**quarterEnd**' + math.mod(lastPossibleSubmissionDate.monthGMT()-1,3));
                        if(workingDaysList[workingDays - 1] < contractRec.Activated_Date__c.dateGMT()){
                            contractRec.Booking_Date_EST__c = contractRec.Activated_Date__c;
                        }
                        else{
                            contractRec.Booking_Date_EST__c = contractRec.Final_Submission_Date_EST__c;
                        }
                }
                              
                //Edited by saloni chhabra on 4/28/2015 for skiping validation rule for updating booking date on complete order SSE-25
                tempSkipValidation.Skip_Validation__c = true;
                upsert tempSkipValidation;
                        
                if(contractRec.Booking_Date_EST__c != null){
                   if(tempSkipValidation.Skip_Validation__c == true) //Edited by saloni chhabra on 4/28/2015 for skiping validation rule for updating booking date on complete order SSE-25
                   {                   
                        //Added by Rishabh Kanotra as per SSE-5873/8215 and Sahil Chhabra for SSE-10296                    
                       if(oldContract.Status != 'Awaiting PO' && oldContract.Status != 'De-Booked – Awaiting PO' && oldContract.Status != 'Awaiting GST/VAT Info' ){ 
                           contractRec.Booking_Date_New__c = contractRec.Booking_Date_EST__c;
                        }                    
                   } 
                }          
            }
        }   
        update contractList;
        
        //Edited by saloni chhabra on 4/28/2015 for skiping validation rule for updating booking date on complete order SSE-25
        tempSkipValidation.Skip_Validation__c = false;
        upsert tempSkipValidation;
    }
}
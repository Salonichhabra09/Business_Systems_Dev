/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 11-06-2019
DESCRIPTION :- This class contains Contract trigger related functionalities : before update (Renewal,Reboost,MTVR Logic)
***************************************************************************************************************************************/ 
global class ContractTriggerManager_3{
    
    //This method is responsible for Creating Renewal and Reboost Opportunity with MTVR Logic check..
    public static void RenewalReboostOppCreation(List<Contract> ContractsNewList, List<Contract> ContractsOldList){    
    //edited by saloni chhabra on 19/3/2015 as per SSE-148 starts  here
    date CloseDate;
    date ReboostMTVRStartDate;
    date earliestenddate;
    date earliestenddateMTVR;
    datetime earlieststartdate ;
    List<Date> EndDateList=new List<Date> ();
    boolean IsSubscriptionOrderLine=false;
    string oppID;
    List<string> ErrorMessage = new List<string>();
    List<string> ErrorMessagereboost = new List<string>();
    
    set<ID> OrderId  = new set<ID>();
    List<Contract_Line__c> OLlist;
    List<Contract_Line__c> OLlist1;
    List<Contract> Orderlistupdate;
    integer OLsubscription;
    List<date> OLstartdate = new List<date>();
    
    Set<String> AutoRenewalValues = Utility.getAutoRenewalfromOrder();
    List<string> subsIMCodeValues = Utility.getSubscriptionProductSequence();
    set<string> subsIMlookupValueSet = new set<string>();
    Set<string> ReboostProducts = Utility.getreboostProducts();
    system.debug('---->subsIMCodeValues <----'+subsIMCodeValues );
    
    for(String subsProdName : subsIMCodeValues){
        subsIMlookupValueSet.add(subsProdName);
    }
    for(Integer i=0;i<ContractsNewList.size();i++){
        OrderId.add(ContractsNewList[i].id);
    }
    if(OrderId.size()>0){ 
        OLlist = [Select id,name,CreatedDate,End_Date__c,Start_Date__c,IM_Lookup_Code__c,Contract__c from Contract_Line__c where Contract__c in:OrderId  ORDER BY Start_Date__c DESC,CreatedDate DESC];
    }
    
    list<Contract_Line__c> OLlistRenewal = new List<Contract_Line__c> ();
    list<Contract_Line__c> OLlistReeboost = new List<Contract_Line__c> ();
    
    for(Contract_Line__c OL : OLlist){
        if(OL.IM_Lookup_Code__c.contains('Subscription') || AutoRenewalValues.contains(OL.IM_Lookup_Code__c)){
            OLlistRenewal.add(OL);
        }
        if(ReboostProducts.contains(OL.IM_Lookup_Code__c)){
            OLlistReeboost.add(OL);
        }                           
    }
    for(Integer i=0;i<ContractsNewList.size();i++){
        Map<string,List<string>> IMCodevalueandDateMap = new Map<string,List<string>>();
        Map<string,List<date>> IMCodevalueandEndDateMap = new Map<string,List<date>>();
        Date OLStDate = null;
        Date OLEndDate = null;
        string orderLineDates = '';
            
        if(ContractsNewList[i].status=='Complete' && ContractsOldList[i].status !='Complete'){
            if(OLlistRenewal.size()>0){
                OLsubscription = OLlistRenewal.size();                               
                for(Contract_Line__c OL:OLlistRenewal){  
                    //added by Anjali to get the priority of IMLookupcode field values as per SSE-5112
                    for(integer j=0;j<subsIMCodeValues.size();j++){
                        if(OL.IM_Lookup_Code__c == subsIMCodeValues[j]) {
                            if(OL.End_Date__c != null){
                                orderLineDates = string.valueof(DateTime.valueof(OL.CreatedDate)).trim()+'@'+string.valueof(OL.Start_Date__c).trim()+'@'+string.valueof(OL.End_Date__c).trim();
                                system.debug('orderLineDates ---'+orderLineDates );
                            }
                            if(IMCodevalueandDateMap != null && IMCodevalueandDateMap.containsKey(OL.IM_Lookup_Code__c)){
                                IMCodevalueandDateMap.get(OL.IM_Lookup_Code__c).add(orderLineDates);
                                //added by saloni chhabra for creating map of IM lookup code adn end dates as per SSE-2720
                                IMCodevalueandEndDateMap.get(OL.IM_Lookup_Code__c).add(OL.End_Date__c);
                            }
                            else{
                                List<string> orderLineDateList = new List<string>();
                                orderLineDateList.add(orderLineDates);
                                
                                List<date> orderLineEndDateList = new List<date>();
                                orderLineEndDateList.add(OL.End_Date__c);
                                
                                IMCodevalueandDateMap.put(OL.IM_Lookup_Code__c,orderLineDateList);
                                //added by saloni chhabra for creating map of IM lookup code adn end dates as per SSE-2720
                                IMCodevalueandEndDateMap.put(OL.IM_Lookup_Code__c,orderLineEndDateList);
                            }                                                   
                         }                                              
                    }
                    
                    if(OL.End_Date__c !=NULL){
                        EndDateList.add(OL.End_Date__c); 
                    }
                            
                    if(AutoRenewalValues.contains(OL.IM_Lookup_Code__c) || OL.IM_Lookup_Code__c.contains('Subscription')){
                        IsSubscriptionOrderLine=true;
                    }
                }
                
              
                if(EndDateList.size()>0){
                    date dt=EndDateList[0];
                    closedate = dt;
                }
                if(ContractsNewList[i].Opportunity__c != null){
                    OppID = ContractsNewList[i].Opportunity__c;
                }            
                if(IsSubscriptionOrderLine == true && OppID != '' && ContractsNewList[0].Renewal_Opp_Error__c == null && ContractsNewList[0].Renewal_Opportunity__c == null){
                    ErrorMessage = Contract_BeforeUpdate_cls.RenewalOpportunity(IsSubscriptionOrderLine,closedate,OppID,OLsubscription,IMCodevalueandEndDateMap,IMCodevalueandDateMap);
                } 
            }
            
            else if(OLlistRenewal.size()==0 && OLlistReeboost.size()>0 && ContractsNewList[i].Offering__c== 'Assessments (Consumption-Based)' && ContractsNewList[i].Account_Region__c !='Distributors' &&  ContractsNewList[0].Reboost_Opp_Error__c == null &  ContractsNewList[0].Reboost_Opportunity__c == null){
                system.debug('inside rebosst logic');
                IsSubscriptionOrderLine= false;
                if(ContractsNewList[i].Opportunity__c != null){
                    OppID = ContractsNewList[i].Opportunity__c;
                }               
                for (Contract_Line__c OL : OLlistReeboost){
                    if (earliestenddate ==null){
                         closedate= OL.End_Date__c+ 1;
                         earliestenddate = closedate;   
                    }
                    else if(earliestenddate!= null){
                        if(earliestenddate >OL.End_Date__c){
                            closedate= OL.End_Date__c+ 1;
                            earliestenddate =OL.End_Date__c;  
                        }
                    }
                    /*MTVR dates*/
                    if (earliestenddateMTVR ==null){
                         ReboostMTVRStartDate= OL.Start_Date__c;
                         earliestenddateMTVR = ReboostMTVRStartDate;   
                    }
                    else if(earliestenddate!= null){
                        if(earliestenddateMTVR >OL.Start_Date__c){
                            ReboostMTVRStartDate= OL.Start_Date__c;
                            earliestenddateMTVR =OL.Start_Date__c;  
                        }
                    }                                     
                }
                ErrorMessagereboost = Contract_BeforeUpdate_cls.ReboostOpportunity(IsSubscriptionOrderLine,closedate,OppID,ReboostProducts,ReboostMTVRStartDate);
                system.debug('ErrorMessagereboost' + ErrorMessagereboost);               
            }  // end else-if
        } // end if
       } // end for
       
        if(ErrorMessage.size()>0){
            if(ErrorMessage.size()>1){
                ContractsNewList[0].Renewal_Opp_Error__c  = ErrorMessage.get(1);
            }
            if(ErrorMessage.get(0).contains('006')){
                ContractsNewList[0].Renewal_Opportunity__c  = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ErrorMessage.get(0);
            }
        }
         if(ErrorMessagereboost.size()>0){
            if(ErrorMessagereboost.size()>1){
                ContractsNewList[0].Reboost_Opp_Error__c  = ErrorMessagereboost.get(1);
            }
            if(ErrorMessagereboost.get(0).contains('006')){
                ContractsNewList[0].Reboost_Opportunity__c  = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ErrorMessagereboost.get(0);
            }
        }
      
        //edited by saloni chhabra on 19/3/2015 as per SSE-148 ends here        
        //edited by saloni chhabra on 01/06/2016 as per SSE-2544 to update last possible submission date daylight saving formula value to be used in last possible submission date field
        for(Integer i=0;i<trigger.new.size();i++){
            if((ContractsNewList[i].Final_Submission_Date_EST__c != null && ContractsNewList[i].Final_Submission_Date_EST__c!= ContractsOldList[i].Final_Submission_Date_EST__c )  && ContractsNewList[i].Submission_Offset__c != null){
                ContractsNewList[i].Last_Possible_Submission_Date_Daylight__c = (ContractsNewList[i].Final_Submission_Date_EST__c+ ((ContractsNewList[i].Submission_Offset__c/3600000)/24));               
            }
            else if(ContractsNewList[i].Final_Submission_Date_EST__c == null){
                ContractsNewList[i].Last_Possible_Submission_Date_Daylight__c = null;
            }
        }
        //edited by saloni chhabra on 01/06/2016 as per SSE-2544 ends here
    }
}
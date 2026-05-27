/**************************************************************************************************************************************
CREATED BY :- Virendra Kumar
CREATED DATE :- 29-07-2019
DESCRIPTION :-  This class contains ContractLine trigger related functionalities :  after delete, after undelete(Renewable date logic and subscription field update)
***************************************************************************************************************************************/
public class ContractLineTriggerManager_3{
  // This method helps to calcualte renewale date and running total subscription field updates when respective field values are present in Custom setting.
  public static void Subscriptionfieldupdate_RenewabledateLogic(Set<Id> ContractLineNewList)
  {
   try{  
    //EACV order line items value
    Set<String> EACVvalues = Utility.getEACVvaluesforOrder();    
    List<string> subsIMCodeValues = Utility.getSubscriptionProductSequence();
    Date RenewalDate;
    Map<id,date> OpptyRenewalDate = new Map<id,date>();
    Set<id> OpptyId = new Set<id>();    
   
    //edited by Dimpy for SSE-2290 starts here
    Set<String> OliValuseFilter1 = Utility.getOrderLineItemValuesFilter1();
    Set<String> OliValuseFilter1_1 = Utility.getOrderLineItemValuesFilter1_1();
    Set<String> OliValuesFilter2= Utility.getOrderLineItemValuesFilter2();
    //edited by Dimpy for SSE-2290 ends here
    Map<Id,Contract> contractVsSubscriptionContractLineMap = new Map<Id,Contract>([SELECT id,Renewal_Opportunity__c,Days_remaining_from_annual_subscription__c,Running_total_of_non_subscription_amount__c,
                                                            Running_total_of_subscription_amount__c,Running_total_of_subscription_days__c,Earliest_Start_Date__c,Earliest_Start_Date_Plus_Leap_Year__c,
                                                            (Select id,Price_per__c ,Duration_days__c, Duration_Day_Amount__c,End_Date__c,Start_Date__c,Price__c,IM_Lookup_Code__c 
                                                            FROM Contract_Line_Items__r ORDER BY Start_Date__c asc) 
                                                            from Contract where id in :ContractLineNewList]);               
    
    if(contractVsSubscriptionContractLineMap!=null && contractVsSubscriptionContractLineMap.size()>0)
    {
        
        for(Contract contract:contractVsSubscriptionContractLineMap.values())
        {
            Map<string,List<date>> IMCodevalueandEndDateMap = new Map<string,List<date>>();
            
            contract.Days_remaining_from_annual_subscription__c = 365;
            Boolean isEarliestStartDateCalculated = false;
            contract.Running_total_of_subscription_amount__c = 0;
            contract.Running_total_of_subscription_days__c = 0;
            contract.Running_total_of_non_subscription_amount__c = 0;
            for(Contract_Line__c contractLine:contract.Contract_Line_Items__r)
            {
                //edited by Dimpy for SSE-2290
               // if(contractLine.IM_Lookup_Code__c=='Limited Subscription'  || contractLine.IM_Lookup_Code__c=='Unlimited Subscription')
               if(EACVvalues.contains(contractLine.IM_Lookup_Code__c) || contractLine.IM_Lookup_Code__c.contains('Subscription'))
                {
                    if(contractLine.Start_Date__c == null || contractLine.End_Date__c == null)
                        continue;
                        
                    if(contractLine.Duration_Days__c >=365)// edited by saloni chhabra on 4/24/2015
                    isEarliestStartDateCalculated = false;
                    if(!isEarliestStartDateCalculated)
                    {
                        contract.Earliest_Start_Date__c = contractLine.Start_Date__c;
                        contract.Earliest_Start_Date_Plus_Leap_Year__c = contractLine.Start_Date__c.addDays(366);
                        if(contract.Earliest_Start_Date__c.month() <= 2)
                        {
                            if(Date.isLeapYear(contract.Earliest_Start_Date__c.Year()))
                            {
                                contract.Days_remaining_from_annual_subscription__c = 366;
                            }
                        }
                        else if(contract.Earliest_Start_Date__c.month() > 2)
                        {
                            if(Date.isLeapYear(contract.Earliest_Start_Date_Plus_Leap_Year__c.Year()))
                            {
                                contract.Days_remaining_from_annual_subscription__c = 366;
                            }
                        }
                        isEarliestStartDateCalculated = true;
                    }
                    Double durationDaysAmount = 0;
                    if(contractLine.Price__c!=null && contractLine.Price_per__c == 'One-off')
                        durationDaysAmount = contractLine.Price__c / contractLine.Duration_days__c;
                    if(contract.Days_remaining_from_annual_subscription__c>0)
                    {
                        if(contract.Days_remaining_from_annual_subscription__c - contractLine.Duration_days__c >0 || contract.Days_remaining_from_annual_subscription__c - contractLine.Duration_days__c == 0)
                        {
                            contract.Running_total_of_subscription_amount__c+=contractLine.Duration_days__c*durationDaysAmount;
                            contract.Running_total_of_subscription_days__c+=contractLine.Duration_days__c;
                            contract.Days_remaining_from_annual_subscription__c = contract.Days_remaining_from_annual_subscription__c-contractLine.Duration_days__c;
                        }
                        else
                        {
                            contract.Running_total_of_subscription_amount__c+=contract.Days_remaining_from_annual_subscription__c*durationDaysAmount;
                            contract.Running_total_of_subscription_days__c+=contract.Days_remaining_from_annual_subscription__c;
                            contract.Days_remaining_from_annual_subscription__c = 0;
                            
                        }
                    }
                    else // edited by saloni chhabra on 4/24/2015
                    {
                        contract.Running_total_of_subscription_amount__c+=contractLine.Price__c;
                    }
                }
               // else if(contractLine.IM_Lookup_Code__c=='Units in advance' ||  contractLine.IM_Lookup_Code__c=='Other units'|| contractLine.IM_Lookup_Code__c=='Site set up'|| contractLine.IM_Lookup_Code__c=='LSI' || contractLine.IM_Lookup_Code__c=='P&P Materials' || contractLine.IM_Lookup_Code__c=='PCX units' || contractLine.IM_Lookup_Code__c=='SMH' || contractLine.IM_Lookup_Code__c=='SXH' || contractLine.IM_Lookup_Code__c=='Consulting' || contractLine.IM_Lookup_Code__c=='Royalties' || contractLine.IM_Lookup_Code__c=='Please refer to T&E invoice request' || contractLine.IM_Lookup_Code__c=='In-Company Training')
               ///edited by Dimpy for SSE-2290
               else if (OliValuseFilter1.contains(contractLine.IM_Lookup_Code__c) || OliValuseFilter1_1.contains(contractLine.IM_Lookup_Code__c))
               
                {
                    if(contractLine.Price__c!=null)
                        contract.Running_total_of_non_subscription_amount__c+=contractLine.Price__c;
                }
                
            }
            
            //Renewal Date Logic as per SSE-2720 starts here
            for(Contract_Line__c contractLine:contract.Contract_Line_Items__r)
                {
                    
                    if(subsIMCodeValues.contains(contractLine.IM_Lookup_Code__c))
                           {
                            if(IMCodevalueandEndDateMap.containsKey(contractLine.IM_Lookup_Code__c))
                            {
                                
                                IMCodevalueandEndDateMap.get(contractLine.IM_Lookup_Code__c).add(contractLine.End_Date__c);
                            }
                            else
                            {
                                List<date> orderLineEndDateList = new List<date>();
                                orderLineEndDateList.add(contractLine.End_Date__c);
                                IMCodevalueandEndDateMap.put(contractLine.IM_Lookup_Code__c,orderLineEndDateList);
                            }
                                
                        
                    }
                }
                
            RenewalDate = Renewal_Date_from_OrderLines.RenewalDate(IMCodevalueandEndDateMap);
            if(RenewalDate!= null)
            {
                if(contract.Renewal_Opportunity__c != null)
                {
                    
                    Integer lengthRemove = contract.Renewal_Opportunity__c.length()-18;
                    id Opptyidvalue = contract.Renewal_Opportunity__c.right(18);
                    if(Opptyidvalue != null)
                    {
                        OpptyRenewalDate.put(Opptyidvalue,RenewalDate);
                        OpptyId.add(Opptyidvalue);
                    }
                  }
            }
            //ends here
        }
        
        update contractVsSubscriptionContractLineMap.values();
    }
    
    //Renewal Date Logic as per SSE-2720 starts here
    if(OpptyId != null && OpptyRenewalDate != null)
    {
        List<Opportunity> LOppty = [Select id,Renewal_Opportunity__c,Business_Type__c,Renewal_Date__c from Opportunity where id in:OpptyId];
        for(Opportunity Opp:LOppty)
        {
            if(Opp.Renewal_Opportunity__c == true && Opp.Business_Type__c == 'Renewal')
            {
                if(Opp.Renewal_Date__c!= null) 
                {
                    if(Opp.Renewal_Date__c != OpptyRenewalDate.get(Opp.id))
                    {
                        Opp.Renewal_Date__c = OpptyRenewalDate.get(Opp.id);
                    }
                }
                else
                Opp.Renewal_Date__c = OpptyRenewalDate.get(Opp.id); 
            }
            system.debug('-->Opp.Renewal_Date__c <----'+Opp.Renewal_Date__c );
        }
        
        update LOppty;
    }
    }
    Catch(Exception e)
{
}
    
}


}
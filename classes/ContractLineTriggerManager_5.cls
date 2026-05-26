/**************************************************************************************************************************************
CREATED BY :- Virendra Kumar
CREATED DATE :- 29-07-2019
DESCRIPTION :-  This class contains ContractLine trigger related functionalities :  Before Insert(Running total field update and error message: Line price can't be null)
***************************************************************************************************************************************/
public class ContractLineTriggerManager_5{
// This method helps:  1. Update the running total field if variation order value is 'No'
//                     2. Line price update condition: when order status is complete, and Im lookup code value present in Custom setting.
public static void fieldupdate_Datavalidationcheck(list<Contract_Line__c> ContractlineNewlist )
{
    // Below code is to set currency of contract lines same as related order's currency.
    Set<Id> contractIdsSet = new Set<Id>();
    
    //logged in user profile and check whether its OAT
    List<Profile> OATProfile = [Select id,name from Profile where name=:'OAT' limit 1];
    ID ProfileID = UserInfo.getProfileId();
    Boolean ProfileOATcheck;
    if(OATProfile.size()>0)
    {
        if(ProfileID == OATProfile[0].id)
        {
            ProfileOATcheck = true;
        }
    }
    // Creating set of all the ids of the contracts.
    for(Integer i = 0;i<ContractlineNewlist.size();i++)
        contractIdsSet.add(ContractlineNewlist[i].Contract__c);
    // Creating Map of the all the contracts related to the set of contract ids.
    
    Map<Id,Contract> contractMap = new Map<Id,Contract>([Select id,CurrencyIsoCode,Original_Order__c,Variation_Order__c,Status from Contract where id in :contractIdsSet]);
    for(Integer i = 0;i<ContractlineNewlist.size();i++)
    {
        System.debug('*****ContractlineNewlist[i].Variation_Order__c*****'+ContractlineNewlist[i].Variation_Order__c);
        // Setting currency same as related order's currency.
        if(contractMap!=null && contractMap.get(ContractlineNewlist[i].Contract__c)!=null)
        {
            ContractlineNewlist[i].CurrencyIsoCode = contractMap.get(ContractlineNewlist[i].Contract__c).CurrencyIsoCode;
           
            if(ContractlineNewlist[i].Variation_Order__c == 'No')
                ContractlineNewlist[i].Running_Total__c = ContractlineNewlist[i].Price__c;
            
            
            //End Code change requested in CRI - 1203
        } 
        
        //SSE -25
        //Edited by : Saloni Chhabra on 2/23/2015
        if(ProfileOATcheck == true) // only for OAT profile users
        {
            if(contractMap.get(ContractlineNewlist[i].Contract__c)!=null) //Order line is linked with some Order
            {
               //check Order related to Order line should be in "Complete" status.
                if(ContractlineNewlist[i].Contract__c!=null)
                {
                List<Contract> Lcontract = [Select id,name,status from Contract  where  id=:ContractlineNewlist[i].Contract__c limit 1];
                    IF(Lcontract.size()>0 && Lcontract[0].status == 'Complete')
                    {
                    
                        // getting  IM lookup code predefined values via Utility  class from a custom setting(Field Value Setting)
                        Set<string> IMlookupCode = Utility.getIMLookupCode();
                        
                        //setting boolean IMLookupcheck with true/false whether IM lookup code is one of the defined values in custom setting
                        boolean IMLookupcheck ;
                        if(IMlookupCode.size()>0 && ContractlineNewlist[i].IM_Lookup_Code__c != '' )
                        {
                            IMLookupcheck = IMlookupCode.contains(ContractlineNewlist[i].IM_Lookup_Code__c);
                        }
                        
                        
                        //IM in the list and Line price and running total both 0 then insert not allowed
                        if(IMLookupcheck == true)
                        {
                            if(ContractlineNewlist[i].Price__c  == 0.00 && (ContractlineNewlist[i].Running_Total__c == 0 || ContractlineNewlist[i].Running_Total__c == null ))
                            {
                                ContractlineNewlist[i].addError(System.Label.Order_Line_Line_Price_Zero_On_Insert);
                            }
                        }
                        
                        //IM not in the list and Line price and running total any non 0 then insert not allowed
                        else if(IMLookupcheck == false)
                        {
                            if(ContractlineNewlist[i].Price__c != 0.00 || (ContractlineNewlist[i].Running_Total__c != 0 && ContractlineNewlist[i].Running_Total__c != null))
                            {
                                ContractlineNewlist[i].addError(System.Label.Order_Line_Line_Price_Zero_On_Insert);
                            }       
                        
                        }
                    }
                }
            }
        
        }
        
    }
}
}
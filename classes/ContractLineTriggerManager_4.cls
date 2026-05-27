/**************************************************************************************************************************************
CREATED BY :- Virendra Kumar
CREATED DATE :- 29-07-2019
DESCRIPTION :-  This class contains ContractLine trigger related functionalities :  before Delete(Restriction on deletion of order line)
***************************************************************************************************************************************/
//This method contains the logic for restriction of deletion of order line when the order's status is complete and running total is not equal to 0.
public class ContractLineTriggerManager_4{

  public static void ValidationOnDeletion(List<Contract_Line__c> ContractLineOldList)
  {
        //edited by saloni chhabra on 2/23/2015
    //SSE-25 (point 1: Order Lines linked with an Completed Order can only be deleted if logged in user if "OAT"/ line price and running total both 0
    Set<Id> contractIdsSet = new Set<Id>();
    
    // getting logged in user's profile ID
    Id profileId=userinfo.getProfileId();
    List<profile> OATProfile = [Select id,name from profile where name =:'OAT' limit 1];
    
    //check logged in user is OAT profile
    if(OATProfile.size()>0 && OATProfile[0].id == profileId)
    {system.debug('OAT user');
        for(Integer i=0;i<ContractLineOldList.size();i++)
        {
            contractIdsSet.add(ContractLineOldList[i].Contract__c);    //set of contract(order) id's related to the ContractLine(order line)
        }
        
        Map<Id,Contract> contractMap = new Map<Id,Contract>([Select id,CurrencyIsoCode,Original_Order__c,Variation_Order__c,Status from Contract where id in :contractIdsSet]);
        
        for(Integer i = 0;i<ContractLineOldList.size();i++)
        {    
            //check Order related to Order line should be in "Complete" status.
            if(contractMap!=null && contractMap.get(ContractLineOldList[i].Contract__c)!=null && contractMap.get(ContractLineOldList[i].Contract__c).Status == 'Complete')
            {
                       system.debug('OAT user status complete');         
                // Line  price or Running total any value is not 0 then delete not allowed
                if(ContractLineOldList[i].Price__c != 0 && ContractLineOldList[i].Running_Total__c != 0)
                { system.debug('OAT user status complete error');
                    ContractLineOldList[i].addError(System.Label.ContractLine_beforedelete_DeleteMessage);
                }
                
                
            }
        }
    }
  }
  }
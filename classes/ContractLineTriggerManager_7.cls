/**************************************************************************************************************************************
CREATED BY :- Virendra Kumar
CREATED DATE :- 29-07-2019
DESCRIPTION :-  This class contains ContractLine trigger related functionalities :  after insert, after update(running total field update)
***************************************************************************************************************************************/
public class ContractLineTriggerManager_7{
    //This method contains the logic for Updation of running total filed as per line price.
    public static void runningtotalfieldUpdate(Set<Id> ContractLineList)
    {
    system.debug('ContractLineList_7'+ContractLineList);
    map<Contract_Line__c, Double> Orderlineprice=new map<Contract_Line__c, Double>();
    list<Contract_Line__c> Contractlineinnerlist = new list<Contract_Line__c>();
         //Below code added against the CRI - 1203 implementation. Below code fetches all the original order lines and update the running total field whenever there is a change in price of the variation order lines.
    List<Contract_Line__c> orderlinesList = [Select id, Price__c,Running_Total__c,(Select id,Price__c from Order_Line__r where
     Variation_Order__c = 'Yes') from Contract_Line__c where id in :ContractLineList];
   
   if(orderlinesList.size()>0)
    {
        for(Contract_Line__c orderLine:orderlinesList)
        {
            orderLine.Running_Total__c = orderLine.Price__c;
            if(orderLine.Order_Line__r.size()>0)
            {
                for(Contract_Line__c ordLine:orderLine.Order_Line__r)
                {
                    orderLine.Running_Total__c += ordLine.Price__c;
                }
            }
        }
        update orderlinesList;
    }
    
    }
    }
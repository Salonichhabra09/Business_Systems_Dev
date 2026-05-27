/**************************************************************************************************************************************
CREATED BY :- Virendra Kumar
CREATED DATE :- 25-07-2019
DESCRIPTION :-  This class contains ContractLine trigger related functionalities for before update event:
1. Line price update condition.
2. IM lookup code update condition.
3. Update the Running total.
4. Validation error on disassociating project.     
   

***************************************************************************************************************************************/
public class ContractLineTriggerManager_1{
    
    /*This method contains below functionalities:
    1. If Related  order is in complete status  then IM Lookup Code cannot be edited 
    2. If IM Lookup code has specific values(defined in custom setting - Field Value Setting) then Line price cannot be  changed  from >0 to 0
    3. if variation order is 'NO' & old and new line price are different Update the Running total.
    4. Apart from admin & if project !=null & Milestones related to project >0 & invoice related to project >0 then error to be:     
              "You cannot disassociate Project: Name from its order line, as there is either a signed milestone/Submitted for Processing invoice request for this project"""
    
    
    */
    public static void runningtotalUpdate_validationErrors(list<Contract_Line__c> ContractlineNewlist, list<Contract_Line__c> Contractlineoldlist)
    {
        Set<Id> profileIdsSet = new Set<Id>();
        Boolean isAdmin = false;    
        // getting logged in user's profile ID
        Id profileId=userinfo.getProfileId();  
        list<id> contractlist=new list<id>();
        List<profile> OATProfile = [Select id,name from profile where name =:'OAT' limit 1];
        //edited  by saloni chhabra  on 2/25/2015 starts here
        //SSE-25: 1. Related  order is in complete status  then IM Lookup Code cannot be edited  and 
        //2. if IM Lookup code has specific values(defined in custom setting - Field Value Setting) then Line price cannot be  changed  from >0 to 0
        //check logged in user is OAT profile except Ulyana Ferreira and Adien Ware added as part of SSE-4273 and SSE-3816 
        Set<string> UlyanaFerreiraUserID = Utility.getUlyanaFerreria();
        system.debug('--->UlyanaFerreiraUserID<----'+UlyanaFerreiraUserID);
        if(OATProfile.size()>0 && OATProfile[0].id == profileId && UlyanaFerreiraUserID.contains(UserInfo.getUserId()) == false)
        {
            /******************************************** LINE PRICE UPDATE CONDITIONS********************************************************/
            for(Contract_Line__c contractline:ContractlineNewlist)
            {
            contractlist.add(contractline.Contract__c);
            }
            List<Contract> Lcontract = [Select id,name,status from Contract where id IN:contractlist limit 1];
                   
            for(Integer i = 0;i<ContractlineNewlist.size();i++)
            {
                //check Order related to Order line should be in "Complete" status.
                if(ContractlineNewlist[i].Contract__c!=null)
                {
                    If(Lcontract.size()>0 && Lcontract[0].status == 'Complete')
                    {
                        // getting  IM lookup code predefined values via Utility  class from a custom setting(Field Value Setting)
                        Set<string> IMlookupCode = Utility.getIMLookupCode();
                        
                        //setting boolean IMLookupcheck with true/false whether IM lookup code is one of the defined values in custom setting
                        boolean IMLookupcheck ;
                        if(IMlookupCode.size()>0 && ContractlineNewlist[i].IM_Lookup_Code__c != '' )
                        {
                            IMLookupcheck = IMlookupCode.contains(ContractlineNewlist[i].IM_Lookup_Code__c);
                        }
                        
                        //IM in the list and Line price and running total any value or both 0 then update on Line price to value>0 is allowed
                        if(IMLookupcheck == true)
                        {
                            //check LINE PRICE or RUNNING TOTAL any value is zero
                            if((ContractlineNewlist[i].Price__c == 0 && (ContractlineNewlist[i].Running_Total__c == 0 || ContractlineNewlist[i].Running_Total__c == null ))
                               || (ContractlineNewlist[i].Price__c != 0 || (ContractlineNewlist[i].Running_Total__c != 0 && ContractlineNewlist[i].Running_Total__c != null)))
                            {
                                //Checking line price is changed to 0 from >0 
                                if(Contractlineoldlist[i].Price__c != 0 && ContractlineNewlist[i].Price__c == 0)
                                {
                                    ContractlineNewlist[i].addError(System.Label.ContractLine_BeforeUpdate_ModificationOnCompleteOrder);
                                }
                            }
                        }
                        else if(IMLookupcheck == false)
                        {
                            //Checking line price is changed to 0 from >0 
                            if(ContractlineNewlist[i].Price__c != Contractlineoldlist[i].Price__c)
                            {
                                ContractlineNewlist[i].addError(System.Label.ContractLine_BeforeUpdate_ModificationOnCompleteOrder);
                            }
                        }
                    }
                }
            }   
            
            
            /******************************************* IM LOOKUP CODE UPDATE CONDITIONS********************************************************/
            
            for(Integer i = 0;i<ContractlineNewlist.size();i++)
            {
                //check Order related to Order line should be in "Complete" status.
                if(ContractlineNewlist[i].Contract__c!=null)
                {
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
                        //IM in the list and Line price and running total any value or both 0 then update on Line price to value>0 is allowed
                        if(IMLookupcheck == true)
                        {
                            //check LINE PRICE or RUNNING TOTAL both is zero
                            if(ContractlineNewlist[i].Price__c != 0 || (ContractlineNewlist[i].Running_Total__c != 0 && ContractlineNewlist[i].Running_Total__c != null))
                            {
                                if((ContractlineNewlist[i].IM_Lookup_Code__c != Contractlineoldlist[i].IM_Lookup_Code__c) && (IMlookupCode.contains(Contractlineoldlist[i].IM_Lookup_Code__c) == false))
                                {
                                    ContractlineNewlist[i].addError('Order Line Item cannot be modified');
                                }
                            }
                        }
                        else
                        {
                            if(IMlookupCode.contains(Contractlineoldlist[i].IM_Lookup_Code__c ) == true)
                            {
                                if(ContractlineNewlist[i].Price__c != 0|| (ContractlineNewlist[i].Running_Total__c != 0 && ContractlineNewlist[i].Running_Total__c != null))
                                {
                                    if(ContractlineNewlist[i].IM_Lookup_Code__c != Contractlineoldlist[i].IM_Lookup_Code__c)
                                    {
                                        ContractlineNewlist[i].addError('Order Line Item cannot be modified');
                                    }
                                }
                            }
                            else if(IMlookupCode.contains(Contractlineoldlist[i].IM_Lookup_Code__c ) == false)
                            {
                                if(ContractlineNewlist[i].Price__c != 0 || (ContractlineNewlist[i].Running_Total__c != 0 && ContractlineNewlist[i].Running_Total__c != null))
                                {
                                    if(ContractlineNewlist[i].IM_Lookup_Code__c != Contractlineoldlist[i].IM_Lookup_Code__c)
                                    {
                                        ContractlineNewlist[i].addError('Order Line Item cannot  be modified');
                                    }
                                }
                                
                            }
                        }
                    }
                    
                }
            }       
        }
        
        //edited  by saloni chhabra  on 2/25/2015 ends here
        //Below code has been added for the requirement requested in the CRI - 1203
        Set<Id> orderIdsSet = new Set<Id>();
        for(Integer i=0;i<Trigger.new.size();i++)
        {
            if(ContractlineNewlist[i].Original_Order__c!=Contractlineoldlist[i].Original_Order__c || ContractlineNewlist[i].Original_Order_Line__c==null)
                orderIdsSet.add(ContractlineNewlist[i].Contract__c);
        }
        Map<Id,Contract> contractMap = new Map<Id,Contract>([Select id,Original_Order__c,Variation_Order__c,Status from Contract where id in :orderIdsSet]);
        for(Integer i=0;i<ContractlineNewlist.size();i++)
        {
            if(ContractlineNewlist[i].Variation_Order__c == 'No' && ContractlineNewlist[i].Price__c != Contractlineoldlist[i].Price__c)
            {
                if(ContractlineNewlist[i].Running_Total__c==null)
                    ContractlineNewlist[i].Running_Total__c = 0;
                if(Contractlineoldlist[i].Price__c!=null)
                    ContractlineNewlist[i].Running_Total__c = ContractlineNewlist[i].Running_Total__c - Contractlineoldlist[i].Price__c;
                ContractlineNewlist[i].Running_Total__c = ContractlineNewlist[i].Running_Total__c + ContractlineNewlist[i].Price__c;
            }
             
        }
        //End Code change requested in CRI - 1203
        
        for(Profile prf : [Select id,Name from Profile where Name like '%System Admin%']){
            if(prf.Id == UserInfo.getProfileId()){
                isAdmin = true;
                break;
            }
        }   
        if(!isAdmin)
        {        
            Set<Id> projectIdsSet = new Set<Id>();
            for(Integer i=0;i<ContractlineNewlist.size();i++)
            {
                if(ContractlineNewlist[i].Project__c != Contractlineoldlist[i].Project__c)
                    projectIdsSet.add(Contractlineoldlist[i].Project__c);
            }
            Map<Id,ProjectObject__c> projectsMap = new Map<Id,ProjectObject__c>([Select id, Name,(SELECT id FROM Milestones__r WHERE Is_Signed__c = True limit 1),(SELECT id FROM Invoices__r WHERE Status__c = 'Submitted for Processing' or Status__c = 'Processed' limit 1) from ProjectObject__c where id in :projectIdsSet]);
            for(Integer i=0;i<ContractlineNewlist.size();i++)
            {    
                if(projectsMap!=null && projectsMap.get(Contractlineoldlist[i].Project__c)!= null && (projectsMap.get(Contractlineoldlist[i].Project__c).Milestones__r.size()>0 || projectsMap.get(Contractlineoldlist[i].Project__c).Invoices__r.size()>0))
                    ContractlineNewlist[i].addError('You cannot disassociate Project:'+projectsMap.get(Contractlineoldlist[i].Project__c).Name+' from its order line, as there is either a signed milestone/Submitted for Processing invoice request for this project');
                
            }
        }
    }      
}
/**************************************************************************************************************************************
CREATED BY :- Virendra Kumar
CREATED DATE :- 29-07-2019
DESCRIPTION :-  This class contains ContractLine trigger related functionalities : after delete,after update,after insert (Scoped LPS and CPS days will be updated
                over orginal order line)
***************************************************************************************************************************************/
public class ContractLineTriggerManager_2{
    
    //This method calculates the LPS & CPS days on insert of OrderLine
    public static void ScopedLPS_CPS_Insert(list<Contract_Line__c> Contractlinelist)
    {   
        set<Id> contrLineIds = new set<Id>();
        //Maps will contain one original contractLine Id to one sum value
        map<Id,Double> mpContrLineIdandCPSsum = new map<Id,Double>();
        map<Id,Double> mpContrLineIdandLPSsum = new map<Id,Double>();        
        map<Id,Double> mpContrLineIdandOldCPSsum = new map<Id,Double>();
        map<Id,Double> mpContrLineIdandOldLPSsum = new map<Id,Double>();
        List<Contract_Line__c> ContrLineToUpdateCPS = new List<Contract_Line__c>();
        List<Contract_Line__c> ContrLineToUpdateLPS = new List<Contract_Line__c>();
        
        for(Contract_Line__c cl : Contractlinelist){
            if(cl.Variation_Order__c == 'Yes' && cl.Original_Order_Line__c != null) 
                contrLineIds.add(cl.Original_Order_Line__c);
        }
        
        //Produce a sum of contractLine and add them to the map
        //use group by to have a single original contractLine Id with a single sum value
        
        for(Contract_Line__c cl : [Select Id,Original_Order_Line__c, Scoped_CPS_days__c, Scoped_LPS_days__c from Contract_Line__c where 
                                   Id IN :contrLineIds and Variation_Order__c = 'No']) {                                       
                                       mpContrLineIdandCPSsum.put(cl.Id,cl.Scoped_CPS_days__c);
                                       mpContrLineIdandLPSsum.put(cl.Id,cl.Scoped_LPS_days__c);                                       
                                   }
       
        for(Contract_Line__c cl : Contractlinelist) {    
            if(cl.Variation_Order__c == 'Yes') { 
                Double PaymentCPSsum = (mpContrLineIdandCPSsum != null && mpContrLineIdandCPSsum.containsKey(cl.Original_Order_Line__c)) ? mpContrLineIdandCPSsum.get(cl.Original_Order_Line__c) : 0 ;
                system.debug('PaymentCPSsum '+PaymentCPSsum );
                mpContrLineIdandCPSsum.put(cl.Original_Order_Line__c,(PaymentCPSsum != null ? PaymentCPSsum :0) +(cl.Scoped_CPS_days__c != null ? cl.Scoped_CPS_days__c :0));
                system.debug('mpContrLineIdandCPSsum'+mpContrLineIdandCPSsum);
                Double PaymentLPSsum = (mpContrLineIdandLPSsum != null && mpContrLineIdandLPSsum.containsKey(cl.Original_Order_Line__c)) ? mpContrLineIdandLPSsum.get(cl.Original_Order_Line__c) : 0;
                  system.debug('PaymentLPSsum '+PaymentLPSsum );
                mpContrLineIdandLPSsum.put(cl.Original_Order_Line__c,(PaymentLPSsum != null ? PaymentLPSsum :0) +(cl.Scoped_LPS_days__c != null ? cl.Scoped_LPS_days__c :0)); 
            system.debug('mpContrLineIdandLPSsum'+mpContrLineIdandLPSsum);
            }
        }   
        if(mpContrLineIdandCPSsum != null && mpContrLineIdandCPSsum.size() > 0){
            for(Id i : mpContrLineIdandCPSsum.keyset()){
                Contract_Line__c cl = new Contract_Line__c(id = i);                
                cl.Scoped_CPS_days__c = mpContrLineIdandCPSsum.get(i);  
                if(cl.Scoped_CPS_days__c ==0)
                    cl.Scoped_CPS_days__c = null;                
                ContrLineToUpdateCPS.add(cl);
                system.debug('ContrLineToUpdateCPS'+ContrLineToUpdateCPS);
            }
        }   
        if(mpContrLineIdandLPSsum != null && mpContrLineIdandLPSsum.size() > 0){
            for(Id i : mpContrLineIdandLPSsum.keyset() ){
                Contract_Line__c cl = new Contract_Line__c(id = i);                
                cl.Scoped_LPS_days__c = mpContrLineIdandLPSsum.get(i);    
                if(cl.Scoped_LPS_days__c ==0)
                    cl.Scoped_LPS_days__c = null;           
                ContrLineToUpdateLPS.add(cl);
                system.debug('ContrLineToUpdateLPS'+ContrLineToUpdateLPS);
            }
        }
        if(ContrLineToUpdateCPS != null && ContrLineToUpdateCPS.size()>0) {  
            update ContrLineToUpdateCPS; 
        }    
        if(ContrLineToUpdateLPS != null && ContrLineToUpdateLPS.size()>0) {  
            update ContrLineToUpdateLPS;        
        }  
        
    }
    //This method calculates the LPS & CPS days on Update of OrderLine
    public static void ScopedLPS_CPS_update(list<Contract_Line__c> Contractlinelist, map<Id,Contract_Line__c> Contractlineoldlist)
    {   
        set<Id> contrLineIds = new set<Id>();
        //Maps will contain one original contractLine Id to one sum value
        map<Id,Double> mpContrLineIdandCPSsum = new map<Id,Double>();
        map<Id,Double> mpContrLineIdandLPSsum = new map<Id,Double>();
        List<Contract_Line__c> ContrLineToUpdateCPS = new List<Contract_Line__c>();
        List<Contract_Line__c> ContrLineToUpdateLPS = new List<Contract_Line__c>();        
        map<Id,Double> mpContrLineIdandOldCPSsum = new map<Id,Double>();
        map<Id,Double> mpContrLineIdandOldLPSsum = new map<Id,Double>();        
        //When adding new contractLine or updating existing contractLine        
        for(Contract_Line__c cl : Contractlinelist){
            if(cl.Variation_Order__c == 'Yes' && cl.Original_Order_Line__c != null) 
                contrLineIds.add(cl.Original_Order_Line__c);
        }
        
        
        //Produce a sum of contractLine and add them to the map
        //use group by to have a single original contractLine Id with a single sum value
        
        for(Contract_Line__c cl : [Select Id,Original_Order_Line__c, Scoped_CPS_days__c, Scoped_LPS_days__c from Contract_Line__c where 
                                   Id IN :contrLineIds and Variation_Order__c = 'No']) {
                                       
                                       mpContrLineIdandCPSsum.put(cl.Id,cl.Scoped_CPS_days__c);
                                       mpContrLineIdandLPSsum.put(cl.Id,cl.Scoped_LPS_days__c);
                                       
                                   }   
        for(Contract_Line__c cl : Contractlinelist) {    
            // If scoped CPS Days is changed
            if(Contractlineoldlist.get(cl.Id).Scoped_CPS_days__c != cl.Scoped_CPS_days__c && cl.Scoped_CPS_days__c != null && cl.Variation_Order__c == 'Yes') {    
                system.debug('mpContrLineIdandCPSsum-----'+mpContrLineIdandCPSsum);                
                Double PaymentCPSsum = (mpContrLineIdandCPSsum != null && mpContrLineIdandCPSsum.containsKey(cl.Original_Order_Line__c) && mpContrLineIdandCPSsum.get(cl.Original_Order_Line__c) != null) ? mpContrLineIdandCPSsum.get(cl.Original_Order_Line__c) : 0 ;            
                system.debug('PaymentCPSsum====='+PaymentCPSsum );   
                Double totalPaymentCPSsum = PaymentCPSsum - (Contractlineoldlist.get(cl.Id).Scoped_CPS_days__c != null ? Contractlineoldlist.get(cl.Id).Scoped_CPS_days__c :0) + (cl.Scoped_CPS_days__c != null ? cl.Scoped_CPS_days__c :0); 
                system.debug('totalPaymentCPSsum====='+totalPaymentCPSsum );  
                mpContrLineIdandCPSsum.put(cl.Original_Order_Line__c,(totalPaymentCPSsum != null ? totalPaymentCPSsum :0));                
            }  
            // If scoped LPS Days is changed
            if(Contractlineoldlist.get(cl.Id).Scoped_LPS_days__c != cl.Scoped_LPS_days__c && cl.Scoped_LPS_days__c != null && cl.Variation_Order__c == 'Yes') {                
                Double PaymentLPSsum = (mpContrLineIdandLPSsum != null && mpContrLineIdandLPSsum.containsKey(cl.Original_Order_Line__c) && mpContrLineIdandLPSsum.get(cl.Original_Order_Line__c) != null) ? mpContrLineIdandLPSsum.get(cl.Original_Order_Line__c) : 0 ;
                system.debug('PaymentLPSsum====='+PaymentLPSsum);   
                Double totalPaymentLPSsum = PaymentLPSsum - (Contractlineoldlist.get(cl.Id).Scoped_LPS_days__c != null ? Contractlineoldlist.get(cl.Id).Scoped_LPS_days__c :0) + (cl.Scoped_LPS_days__c != null ? cl.Scoped_LPS_days__c :0 ); 
                system.debug('totalPaymentLPSsum===='+totalPaymentLPSsum); 
                mpContrLineIdandLPSsum.put(cl.Original_Order_Line__c,(totalPaymentLPSsum != null ? totalPaymentLPSsum :0));
            } 
            system.debug('mpContrLineIdandCPSsum----'+mpContrLineIdandCPSsum);
            system.debug('mpContrLineIdandLPSsum----'+mpContrLineIdandLPSsum);
            
        }
        if(mpContrLineIdandCPSsum != null && mpContrLineIdandCPSsum.size() > 0){
            for(Id i : mpContrLineIdandCPSsum.keyset()){
                Contract_Line__c cl = new Contract_Line__c(id = i);                
                cl.Scoped_CPS_days__c = mpContrLineIdandCPSsum.get(i);              
                ContrLineToUpdateCPS.add(cl);
            }
        } 
        if(mpContrLineIdandLPSsum != null && mpContrLineIdandLPSsum.size() > 0){
            for(Id i : mpContrLineIdandLPSsum.keyset() ){
                Contract_Line__c cl = new Contract_Line__c(id = i);                
                cl.Scoped_LPS_days__c = mpContrLineIdandLPSsum.get(i);              
                ContrLineToUpdateLPS.add(cl);
            }
        }
        system.debug('ContrLineToUpdateCPS----'+ContrLineToUpdateCPS);
        if(ContrLineToUpdateCPS != null && ContrLineToUpdateCPS.size()>0) {  
            update ContrLineToUpdateCPS; 
        }    
        system.debug('ContrLineToUpdatelps----'+ContrLineToUpdateLPS);
        if(ContrLineToUpdateLPS != null && ContrLineToUpdateLPS.size()>0) {  
            update ContrLineToUpdateLPS; 
        } 
        
    }
    //This method re-calculates the LPS & CPS days on Delete of OrderLine
    public static void ScopedLPS_CPS_Delete(list<Contract_Line__c> Contractlinelist)
    {   
        //Limit the size of list by using Sets which do not contain duplicate elements
        set<Id> contrLineIds = new set<Id>();
        //Maps will contain one original contractLine Id to one sum value
        map<Id,Double> mpContrLineIdandCPSsum = new map<Id,Double>();
        map<Id,Double> mpContrLineIdandLPSsum = new map<Id,Double>();
        
        map<Id,Double> mpContrLineIdandOldCPSsum = new map<Id,Double>();
        map<Id,Double> mpContrLineIdandOldLPSsum = new map<Id,Double>();
        List<Contract_Line__c> ContrLineToUpdateCPS = new List<Contract_Line__c>();
        List<Contract_Line__c> ContrLineToUpdateLPS = new List<Contract_Line__c>();
        
        for(Contract_Line__c cl : Contractlinelist){
            if(cl.Variation_Order__c == 'Yes' && cl.Original_Order_Line__c != null) 
                contrLineIds.add(cl.Original_Order_Line__c);
        }
        
        for(Contract_Line__c cl : [Select Id,Original_Order_Line__c, Scoped_CPS_days__c, Scoped_LPS_days__c from Contract_Line__c where 
                                   Id IN :contrLineIds and Variation_Order__c = 'No']) {
                                       mpContrLineIdandCPSsum.put(cl.Id,cl.Scoped_CPS_days__c);
                                       mpContrLineIdandLPSsum.put(cl.Id,cl.Scoped_LPS_days__c);
                                      
                                   }  
       
        for(Contract_Line__c cl : Contractlinelist) {     
            if(cl.Variation_Order__c == 'Yes' && cl.Original_Order_Line__c != null) {         
                
                Double PaymentCPSsum = mpContrLineIdandCPSsum.get(cl.Original_Order_Line__c) ;
                mpContrLineIdandCPSsum.put(cl.Original_Order_Line__c,(PaymentCPSsum != null ? PaymentCPSsum :0) - (cl.Scoped_CPS_days__c != null ? cl.Scoped_CPS_days__c:0));
                Double PaymentLPSsum = mpContrLineIdandLPSsum.get(cl.Original_Order_Line__c);
                mpContrLineIdandLPSsum.put(cl.Original_Order_Line__c,(PaymentLPSsum != null ? PaymentLPSsum :0) - (cl.Scoped_LPS_days__c != null ? cl.Scoped_LPS_days__c :0));    
            }
        }
        
        if(mpContrLineIdandCPSsum != null && mpContrLineIdandCPSsum.size() > 0){
            for(Id i : mpContrLineIdandCPSsum.keyset()){
                Contract_Line__c cl = new Contract_Line__c(id = i);                
                cl.Scoped_CPS_days__c = mpContrLineIdandCPSsum.get(i);              
                ContrLineToUpdateCPS.add(cl);
            }
        }   
        if(mpContrLineIdandLPSsum != null && mpContrLineIdandLPSsum.size() > 0){
            for(Id i : mpContrLineIdandLPSsum.keyset() ){
                Contract_Line__c cl = new Contract_Line__c(id = i);                
                cl.Scoped_LPS_days__c = mpContrLineIdandLPSsum.get(i);              
                ContrLineToUpdateLPS.add(cl);
            }
        }
        if(ContrLineToUpdateCPS != null && ContrLineToUpdateCPS.size()>0) {  
            update ContrLineToUpdateCPS; 
        }    
        if(ContrLineToUpdateLPS != null && ContrLineToUpdateLPS.size()>0) {  
            update ContrLineToUpdateLPS; 
        }   
    }
}
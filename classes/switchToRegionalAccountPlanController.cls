/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is used to Switch or Covert the Current Account Plan to Global/Regional.                                 *
************************************************************************************************************************************/

public without sharing class switchToRegionalAccountPlanController {
    
    @AuraEnabled
    public static returnMessageWrapper checkRegionalAccountPlanExist(String apId) {
        returnMessageWrapper rmw =  new returnMessageWrapper();
        rmw.ApplicableForRegional = false;
        rmw.ApplicableForGlobal = false;
        try{
            if(apId != '' && apId != null){
                Account_Plan__c accPlanData = [Select id , Account_Name__c, Account_Name__r.Buying_Centre_Id__c,
                                               Account_Plan_Type__c , is_Account_Plan_Retired__c,Account_Plan_Name__c
                                               from Account_Plan__c where id =: apId ]; 
                
             
                Id accId =  accPlanData.Account_Name__c;     
                String buyingCentreId = accPlanData.Account_Name__r.Buying_Centre_Id__c; 
              
               
                    
                  List<Account> accList = [select id from account where parentId = :accId];
                  if(!accList.isEmpty()){
                   // rmw.ApplicableForGlobal = true; 
                   // Remove the comments from above whenever Global Option will be made available for Users.              
                    
                } 
               
                if(buyingCentreId != null && buyingCentreId != '' && accPlanData.Account_Plan_Type__c == 'Current'){
                    List<Account_Plan__c> apList = [select id , name , Account_Plan_Type__c from Account_Plan__c
                                                    where Buying_Centre_Id__c =: buyingCentreId and 
                                                    Account_Plan_Type__c ='Regional' and is_Account_Plan_Retired__c = false];
                    
                    
                    if(!apList.isEmpty() && apList[0].id != apId){
                        rmw.MessageType = 'Success';
                        rmw.Message = 'Regional Account Plan Found';
                        rmw.accountPlanId = apList[0].id;
                    }  
                    else{
                         
                        rmw.MessageType = 'Success';
                        rmw.Message = 'No Regional Account Plan Found';
                        rmw.ApplicableForRegional = true;
                    } 
                     
                } 
                
                else{
                    rmw.MessageType = 'Success';
                    rmw.Message = 'No Regional Account Plan Required ';
                }
                
            }
            
            
        }
        catch(Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
        }
         
        return rmw;
    }
    
    @AuraEnabled
    public static returnMessageWrapper getStrategyandWhiteSpaceData(String apId){
        returnMessageWrapper rmw =  new returnMessageWrapper();
        try{
            StrategyAndGoalController.returnMessageWrapper strategyList = new StrategyAndGoalController.returnMessageWrapper(); 
            strategyList = StrategyAndGoalController.getStrategyAndGoalsDetails(apId);
            
            WhiteSpaceOpportunityController.returnMessageWrapper whitespaceList = new WhiteSpaceOpportunityController.returnMessageWrapper();
            whitespaceList = WhiteSpaceOpportunityController.getWhiteSpaceOpportunitiesDetails(apId);
            
            rmw.MessageType = 'Success';
            rmw.whiteSpaceWrapper = whitespaceList;
            rmw.strategyWrapper = strategyList;
            
        }catch(Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
        }
        return rmw;
    }

 @AuraEnabled
    public static returnMessageWrapper convertAccPlanToRegional(String apId){
        returnMessageWrapper rmw =  new returnMessageWrapper();
        try{
            if(apId!= null && apId != ''){
                 Account_Plan__c accPlanData = [Select id , Account_Name__c, Account_Name__r.Buying_Centre_Id__c,
                                               Account_Plan_Type__c , is_Account_Plan_Retired__c
                                               from Account_Plan__c where id =: apId];
                Id accId =  accPlanData.Account_Name__c;     
                String buyingCentreId = accPlanData.Account_Name__r.Buying_Centre_Id__c;  
                
                Account_Plan__c ap = new Account_Plan__c(
                id = apId,
                Account_Plan_Type__c = 'Regional',
                Buying_Centre_Id__c = buyingCentreId  
                );
                
                update ap;
                
               /*  List<Account> accData = [Select id , Number_of_Account_Plan__c 
                                          from Account where Buying_Centre_Id__c = :buyingCentreId];
                List<Account> accToUpdate = new List<Account>();
                if(!accData.isEmpty()){
                    for(Account acc : accData){
                        if(acc.Id != accId){
                            Decimal noOfAP = 0;
                            if(acc.Number_of_Account_Plan__c == null ){
                                noOfAP = 1;
                            }
                            else if( acc.Number_of_Account_Plan__c != null){
                                 noOfAP = acc.Number_of_Account_Plan__c + 1;
                            }
                       
                             acc.Number_of_Account_Plan__c = noOfAP;  
                             accToUpdate.add(acc);
                        
                        }                        
                    }
                   
                    update accToUpdate; 
                }*/
                
            }
            
            rmw.MessageType = 'Success';
          
            
        }catch(Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
        }
        return rmw;
    }
    
    @AuraEnabled
    public static returnMessageWrapper convertAccPlanToGlobal(String apId){
        returnMessageWrapper rmw =  new returnMessageWrapper();
        try{
            if(apId!= null && apId != ''){
                 Account_Plan__c accPlanData = [Select id , Account_Name__c, Account_Name__r.Buying_Centre_Id__c,
                                               Account_Plan_Type__c , is_Account_Plan_Retired__c
                                               from Account_Plan__c where id =: apId];
                Id accId =  accPlanData.Account_Name__c;     
                String buyingCentreId = accPlanData.Account_Name__r.Buying_Centre_Id__c;  
                
                Account_Plan__c ap = new Account_Plan__c(
                id = apId,
                Account_Plan_Type__c = 'Global');
                
                update ap;
            }
            
            rmw.MessageType = 'Success';
          
            
        }catch(Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
        }
        return rmw;
    }
    
    @AuraEnabled
    public static returnMessageWrapper  mergeCurrentAndRegionalAP(String currentAPId , 
                                                                  String regionalAPId , List<Id> stList,
                                                                  List<Id> wsList
                                                                 ){
        returnMessageWrapper rmw = new returnMessageWrapper();
                                                                  
        List<Strategy_and_Goal__c> stListUpdated = new List<Strategy_and_Goal__c>();
        List<Whitespace_Potential_Opportunity__c> wsListUpdated = new List<Whitespace_Potential_Opportunity__c>();
        try{
        if(regionalAPId != '' && regionalAPId != null){
           Account_Plan__c apData = [Select id , Account_Name__c, Account_Name__r.Buying_Centre_Id__c,
                                               Account_Plan_Status__c , is_Account_Plan_Retired__c,
                                               Account_Plan_Name__c,Account_Name__r.Number_of_Account_Plan__c
                                               from Account_Plan__c where id =: regionalAPId and is_Account_Plan_Retired__c= false ];
            if(apData.Account_Plan_Status__c == 'In Review'){
             rmw.MessageType = 'ERROR';
             rmw.Message = 'We can not switch Account To Regional since the Regional Account Plan : ' + apData.Account_Plan_Name__c + ' is In Review';
            }
            else{
            if(!stList.isEmpty()){
                
                for(Id stId : stList ){
                    Strategy_and_Goal__c st = new Strategy_and_Goal__c(
                    Account_Plan__c = regionalAPId,
                    id = stId); 
                    
                    stListUpdated.add(st);
                }
               update stListUpdated;
                
            }
            if(wsList.size()>0){
                 
                for(Id ws : wsList ){
                    Whitespace_Potential_Opportunity__c w = new Whitespace_Potential_Opportunity__c(
                        id = ws,
                        Account_Plan__c = regionalAPId
                    );
                    
                   wsListUpdated.add(w);                    
                }
                 
                update wsListUpdated;
                
            }
            Account_Plan__c ap = new Account_Plan__c(id = currentAPId ,
                                                     is_Account_Plan_Retired__c = true,
                                                     Account_Plan_Status__c	 ='Retired',
                                                     Sub_Status__c = 'Switched To Regional',
                                                     Active_Account_Plan__c = regionalAPId
                                                     );
            update ap;
            
       
             rmw.MessageType = 'Success';
             rmw.Message = 'Success';
            }
            }
            
        }catch(Exception ex){
              rmw.MessageType = 'ERROR';
             rmw.Message = ex.getMessage();            
        }
        return rmw;
        }
    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public String accountPlanId;
        @AuraEnabled public Boolean ApplicableForRegional;
        @AuraEnabled public Boolean ApplicableForGlobal;
        @AuraEnabled public StrategyAndGoalController.returnMessageWrapper strategyWrapper;
        @AuraEnabled public WhiteSpaceOpportunityController.returnMessageWrapper whiteSpaceWrapper;
        
    }
}
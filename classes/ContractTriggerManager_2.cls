/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 10-06-2019
DESCRIPTION :- This class contains Contract trigger related functionalities : after update,before update (covers PdfCsv checks,Validation Checks on order)
***************************************************************************************************************************************/ 
global class ContractTriggerManager_2{

    //In this method, Variation order headers cannot be activated unless its related order line/s are linked to the original order line/s. Exception to this is if the ACV1 value is zero.       
    public static void ValidateRelatedOrderLines(List<Contract> ContractsNewList){
        Set<Id> activatedOrderIdsSet = new Set<Id>();
        
        for(integer i=0; i<ContractsNewList.size(); i++){
            if(ContractsNewList[i].Variation_Order__c == 'Yes' && ContractsNewList[i].status=='Complete' && ContractsNewList[i].TCV__c !=0)
                activatedOrderIdsSet.add(ContractsNewList[i].id);
        }
        Map<Id,Contract> contMap = new Map<Id,Contract>([Select id,(Select id from Contract_Line_Items__r where Original_Order_Line__c =null) from Contract where id in :activatedOrderIdsSet]);
        for(Integer i=0;i<ContractsNewList.size();i++){
           if(ContractsNewList[i].Variation_Order__c == 'Yes' && ContractsNewList[i].status=='Complete' && ContractsNewList[i].TCV__c !=0){
               if(contMap!=null && contMap.get(ContractsNewList[i].id)!=null && contMap.get(ContractsNewList[i].id).Contract_Line_Items__r.size()>0)
                   ContractsNewList[i].addError('Variation order headers cannot be activated unless its related order lines are linked to the original order lines.');
           }
        }        
    }
    
    /* This method updates the Value of Final Submission Date,Submission offset and Activation Offset in Order based on update in
       Activated Date, Final Submission Date.*/
     public static void UpdateOrderFieldValues(List<Contract> ContractsNewList, List<Contract> ContractsOldList){    
        for(Integer i=0;i<ContractsNewList.size();i++){
            if(ContractsNewList[i].Activated_Date__c != ContractsOldList[i].Activated_Date__c && ContractsOldList[i].Final_Submission_Date_EST__c == NULL){
                ContractsNewList[i].Final_Submission_Date_EST__c = ContractsNewList[i].Activated_Date__c;
            }
            if(ContractsNewList[i].Final_Submission_Date_EST__c != ContractsOldList[i].Final_Submission_Date_EST__c){
                if(ContractsNewList[i].Final_Submission_Date_EST__c >= ContractsNewList[i].Daylight_Start_Date_US_Submission__c && ContractsNewList[i].Final_Submission_Date_EST__c < ContractsNewList[i].Daylight_End_Date_US_Submission__c)
                    ContractsNewList[i].Submission_Offset__c = -14400000;           
                else
                    ContractsNewList[i].Submission_Offset__c = -18000000;
            }
            if(ContractsNewList[i].Activated_Date__c != ContractsOldList[i].Activated_Date__c){
                if(ContractsNewList[i].Activated_Date__c >= ContractsNewList[i].Daylight_Start_Date_US_Submission__c && ContractsNewList[i].Activated_Date__c < ContractsNewList[i].Daylight_End_Date_US_Submission__c)
                    ContractsNewList[i].Activation_Offset__c = -14400000;        
                else
                    ContractsNewList[i].Activation_Offset__c = -18000000;
            }
         }
     }
     
     // This method is responsible for PDF and CSV checks/errors on Order when User is trying to attach files/attachment.
     // Order and Opportunity sync is also checked.
     public static void OrderPdfCsvChecks(List<Contract> ContractsNewList, List<Contract> ContractsOldList){
        Boolean isAdmin = false;
        Boolean statusIsSubmitted = false;
        Set<Id> contractIdsSet = new Set<Id>();     //Edited By Virendra Kumar on 28/11/18 For Lightning Component            
        String oppRecordType = System.Label.GCSCRecordType;
        String oppRecordTypeIgnite = System.Label.IgniteRecordType;   //edited by Rishabh Kanotra on 05/09/2018 as per SSE-7508
        
        for(Profile prf : [Select id,Name from Profile where Name like '%System Admin%']){
            if(prf.Id == UserInfo.getProfileId()){
              isAdmin = true;
              break;
            }
        }
        for(Integer i=0;i<ContractsNewList.size();i++){
            if((ContractsNewList[i].status=='Submitted' && ContractsOldList[i].status!='Submitted') || (ContractsNewList[i].status=='Queried' && ContractsOldList[i].status!='Queried')|| (ContractsNewList[i].status=='Under Legal Review' && ContractsOldList[i].status!='Under Legal Review')|| (ContractsNewList[i].status=='De-Booked – Awaiting PO' && ContractsOldList[i].status!='De-Booked – Awaiting PO')){
            statusIsSubmitted = true;
            contractIdsSet.add(ContractsNewList[i].id);
            }        
        }
        if(statusIsSubmitted == true){            
            Map<id,Contract> contractMap = new Map<Id,Contract>([Select id, OwnerId,PDFCount__c,CSVCount__c, Accountid,Billing_Contact__c,Booking_Date__c,Invoicing_Contact__c,TCV__c,
                                                            Annual_Contract_Value__c,Unconfirmed_Sun_Order_Number__c, NVM_Credit_Card_ID__c,
                                                            Opportunity__r.Annual_Contract_Value__c,Opportunity__r.Amount,Opportunity__r.ownerId,
                                                            Opportunity__r.AccountId,Opportunity__r.Billing_Contact__c,Opportunity__r.Closedate,Opportunity__r.StageName,
                                                            Opportunity__r.Primary_Contact__c,Opportunity__r.CurrencyIsoCode,Opportunity__r.Unconfirmed_Sun_Order_Number__c,
                                                            Opportunity__r.NVM_Credit_Card_ID__c,Opportunity__r.GCSC__c,Opportunity__r.RecordTypeId,
                                                            (Select id,ParentID from Attachments where contenttype='application/pdf') 
                                                            from Contract where id in :contractIdsSet]);
            for(Contract contract : ContractsNewList){
                if(!isAdmin){
                    if((contract.status=='Submitted' || contract.status=='Queried' || contract.status=='Under Legal Review' || contract.status=='De-Booked – Awaiting PO')){
                        if(contract.Opportunity__c!=null){
                            //Check if contract is in sync with cont.Opportunity__r before submit.
                            Contract cont = contractMap.get(contract.id);
                            //Decimal annualContractValue;
                            System.debug('*******contractMap.get(contract.id)********'+contractMap.get(contract.id));
                           
                            if(((contract.OwnerId != null || cont.Opportunity__r.ownerId !=null) && contract.OwnerId != cont.Opportunity__r.ownerId)
                               || ((contract.AccountId != null || cont.Opportunity__r.AccountId !=null) && contract.AccountId != cont.Opportunity__r.AccountId) || ((contract.Billing_Contact__c != null || cont.Opportunity__r.Billing_Contact__c !=null) && contract.Billing_Contact__c != cont.Opportunity__r.Billing_Contact__c)
                               || ((contract.Booking_Date__c != null || cont.Opportunity__r.Closedate !=null) && contract.Booking_Date__c != cont.Opportunity__r.Closedate && cont.Opportunity__r.StageName != System.Label.Opportunity_Stage_6) || ((contract.Invoicing_Contact__c != null || cont.Opportunity__r.Primary_Contact__c !=null) && contract.Invoicing_Contact__c != cont.Opportunity__r.Primary_Contact__c) || ((contract.CurrencyIsoCode != null || cont.Opportunity__r.CurrencyIsoCode !=null) && contract.CurrencyIsoCode != cont.Opportunity__r.CurrencyIsoCode) || ((contract.TCV__c != null || cont.Opportunity__r.Amount !=null) && contract.TCV__c != cont.Opportunity__r.Amount) || ((contract.Unconfirmed_Sun_Order_Number__c != null || cont.Opportunity__r.Unconfirmed_Sun_Order_Number__c !=null) && contract.Unconfirmed_Sun_Order_Number__c != cont.Opportunity__r.Unconfirmed_Sun_Order_Number__c) || ((contract.NVM_Credit_Card_ID__c != null || cont.Opportunity__r.NVM_Credit_Card_ID__c !=null) && contract.NVM_Credit_Card_ID__c != cont.Opportunity__r.NVM_Credit_Card_ID__c))
                            {                              
                                contract.adderror('Order is out of sync with its related opportunity so its status cannot be changed to "'+ contract.status + '" . ');
                            } 
                         
                            if(contractMap.get(contract.id).Opportunity__r.RecordTypeId !=oppRecordTypeIgnite){
                                if(contractMap!= null  && contract.Booked_Elsewhere__c == false && contractMap.get(contract.id).Opportunity__r.RecordTypeId != oppRecordType){  
                                    if(contractMap.get(contract.id).PDFCount__c==0 ||contractMap.get(contract.id).PDFCount__c==null){
                                        contract.adderror('Order status cannot be changed to "'+ contract.status + '" as it does not have a signed Order PDF attached');
                                    }
                                }
                            }
                            else if(contractMap!= null  && contract.Booked_Elsewhere__c == false && contractMap.get(contract.id).Opportunity__r.RecordTypeId != oppRecordType){  
                                if((contractMap.get(contract.id).PDFCount__c==null)||(contractMap.get(contract.id).CSVCount__c ==null)||(contractMap.get(contract.id).CSVCount__c ==0) || (contractMap.get(contract.id).PDFCount__c<2)){
                                    contract.adderror('Order status cannot be changed to "'+ contract.status + '" as it does not have both  \'Signed Order Form PDF\' and \'Rate Card Summary\'');  
                                }
                            }
                            
                            //Edition Ended By Virendra Kumar on 28/11/18 for lightning Component
                        }
                        else{
                            contract.adderror('Order status cannot be changed to "'+ contract.status + '" as it does not have opportunity linked to.');
                        }
                    }
                }   
            }  // for end
        }
     }
}
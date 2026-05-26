//Created By RISHABH KANOTRA to combine all triggers on Reseller_Agreement__c on 19/08/2019
trigger Reseller_Agreement_Trigger on Reseller_Agreement__c (before delete) {

    if(Trigger_Activation__c.getInstance('Reseller_Agreement_Trigger').Active__c){
            
        if (Trigger.isDelete) {
        
            if (Trigger.isBefore) {
                
                ResellerAgreementTriggerManager.BeforeDeleteResellerAgreement(Trigger.old);
            
            }               
        
        }//Delete     
    
    
    }//Trigger_Activation

}//end
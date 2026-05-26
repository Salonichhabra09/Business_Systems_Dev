/**************************************************************************************************************************************
CREATED BY :- RISHABH KANOTRA
CREATED DATE :- 19/08/2019
DESCRIPTION :- This class contains various validations and restrictions to modify Reseller_Agreement__c and its fields and refered from Reseller_Agreement_Trigger triggers : before delete
***************************************************************************************************************************************/ 
 
Global class ResellerAgreementTriggerManager{

    //Prevent deletion if user is not System Admin.
    public static void BeforeDeleteResellerAgreement(List<Reseller_Agreement__c> oldResellerAgreement){
        
        Profile profile = [Select id,Name from Profile where id = :UserInfo.getProfileId() ];
        for(integer i=0;i<oldResellerAgreement.size();i++)
        {
        if(profile.Name != 'System Administrator' && profile.Name !='Bullseye Project (Commercial)')
        oldResellerAgreement[i].addError('Only System Administrator can delete Reseller Agreement records.');
        }
    }//BeforeDeleteResellerAgreement

}
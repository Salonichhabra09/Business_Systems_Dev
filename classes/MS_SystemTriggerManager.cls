/*****************************************************************************
CREATED BY :- Prabhat Arora
CREATED DATE :- 22-08-2019
DESCRIPTION :- This class contains Methods to create Candidate Login & Passwords in context to MS System Functionality as per SHL business process,
               this class is being refered from MS_System_Trigger, covering the After Insert Event on MS System Records. 
******************************************************************************/
Global class MS_SystemTriggerManager{
    Global MS_SystemTriggerManager(){
        
    }
    // Public static void CreateCandidatelogins(List<Bureau_System__c> NewSystemList){
    //     System.debug('NewSystemList ###'+NewSystemList.size());
    //     Set<Id> jobIds = new Set<Id>();
    //     for(Bureau_System__c bureauSystem:NewSystemList)
    //     {
    //         if(!jobIds.contains(bureauSystem.Bureau_Job__c))
    //             jobIds.add(bureauSystem.Bureau_Job__c);
    //     }
    //     Map<Id,Job__c> jobMap = new Map<Id,Job__c>([SELECT Id,Name,Candidate_Username_Prefix__c,(SELECT Id, Name FROM Bureau_Candidates__r) FROM Job__c WHERE Id IN:jobIds]);
        
    //     List<Bureau_Candidate_Login__c> candidateLogins = new List<Bureau_Candidate_Login__c>();
    //     for(Bureau_System__c bureauSystem:NewSystemList)
    //     {
    //         Job__c job = jobMap.get(bureauSystem.Bureau_Job__c);
    //         List<Bureau_Candidate__c> candidates = job.Bureau_Candidates__r;
    //         for(Bureau_Candidate__c candidate: candidates)
                
    //         {
    //             Bureau_Candidate_Login__c candidateLogin = new Bureau_Candidate_Login__c();
    //             candidateLogin.Bureau_Candidate__c = candidate.Id;
    //             candidateLogin.Bureau_System__c = bureauSystem.Id;
    //             candidateLogin.Password__c = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0,8).replace('0','h').replace('1','i').replace('2','j').replace('3','k').replace('4','l').replace('5','m').replace('6','n').replace('7','o').replace('8','p').replace('9','q');        
    //             candidateLogins.add(candidateLogin);
    //         }
    //     }
    //     //system.debug('This is Candidate Id'+candidates[0].id);
    //     insert candidateLogins;
        
    //     BureauJob_Manager.refreshRaterTypes(jobIds);
    // }
    
}
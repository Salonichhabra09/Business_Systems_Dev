/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is used to display the Account Intelligence Data as data table on Account Plan its getting used in       *
*              createAccountIntelligence LWC Component also in generateAccountPlanPDF Apex class.                                  *
************************************************************************************************************************************/
public without sharing class getAccountIntelligenceData {
    @AuraEnabled
    public static returnMessageWrapper getSystem(Id systemId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        try{
            System__c systemRecord = new System__c();
            systemRecord =  [SELECT Technographic_Category__c, Sub_Category__c, Technology__c FROM System__c WHERE Id =: systemId];
            rmw.MessageType ='Success';
            rmw.systemRecord = systemRecord;
            
            }catch(DMLException e){
                string message = e.getDmlMessage(0);
                rmw.MessageType ='Error';
                rmw.Message = message;
            }catch(Exception ex){
                rmw.MessageType ='Error';
                rmw.Message = ex.getMessage();
            }
            
            return rmw;
        
    }
  
    @AuraEnabled(cacheable=true)
    public static AccountIntelligenceWrapper getSystemDetails(Id accountPlanId){
       
        AccountIntelligenceWrapper aiw = new AccountIntelligenceWrapper();
        Account_Plan__c accplan = [select id , Account_Name__c,Account_Plan_Status__c , Account_Name__r.CurrencyIsoCode,Account_Plan_Type__c,Buying_Centre_Id__c
                                     from Account_Plan__c where id=:accountPlanId];
        
        List<Account_Intelligence__c> aiList = new List<Account_Intelligence__c>();
        if(accplan.Account_Plan_Type__c=='Regional'){
            List<Account> accList = [SELECT Id FROM Account WHERE Buying_Centre_Id__c= :accplan.Buying_Centre_Id__c];
            List<Id> accIds = new List<Id>();
            for (Account acc : accList) {
                accIds.add(acc.Id);
            }
            aiList = [SELECT id ,AccountName__r.Account_Number__c, Account_Intelligence_Name__c, Account_Intelligence_Type__c, 
                        AccountName__c, Salesforce_System_Id__c, name,Short_Description__c,
                        AccountName__r.name ,  Salesforce_System_Id__r.System_Name__c,
                        Salesforce_System_ID__r.Name, Technographic_Category__c, Sub_Category__c,Technology__c, Archived__c
                        FROM Account_Intelligence__c  WHERE AccountName__c IN :accIds and Archived__c = false];        
        }else if(accplan.Account_Plan_Type__c=='Current'){
            aiList = [SELECT id ,AccountName__r.Account_Number__c, Account_Intelligence_Name__c, Account_Intelligence_Type__c, 
                        AccountName__c, Salesforce_System_Id__c, name,Short_Description__c,
                        AccountName__r.name ,  Salesforce_System_Id__r.System_Name__c,
                        Salesforce_System_ID__r.Name, Technographic_Category__c, Sub_Category__c,Technology__c, Archived__c
                        FROM Account_Intelligence__c  WHERE AccountName__c= :accplan.Account_Name__c and Archived__c=false];         
        }else if(accplan.Account_Plan_Type__c=='Global'){
            Set<Id> allAccountIds = new Set<Id>{accplan.Account_Name__c};
            Set<Id> parentIds = new Set<Id>{accplan.Account_Name__c};
            List<Account> childAccounts = new List<Account>();
            do {
                childAccounts = [SELECT Id FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                parentIds.clear();
                for (Account child : childAccounts){
                    parentIds.add(child.Id);
                    allAccountIds.add(child.Id);
                }
            } while (childAccounts.size() > 0);
            aiList = [SELECT id ,AccountName__r.Account_Number__c, Account_Intelligence_Name__c, Account_Intelligence_Type__c, 
                        AccountName__c, Salesforce_System_Id__c, name,Short_Description__c,
                        AccountName__r.name ,  Salesforce_System_Id__r.System_Name__c,
                        Salesforce_System_ID__r.Name, Technographic_Category__c, Sub_Category__c,Technology__c, Archived__c
                        FROM Account_Intelligence__c  WHERE AccountName__c IN :allAccountIds and Archived__c = false];         
            }
        
        List<aiDataWrapper> swList = new List<aiDataWrapper>(); 
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Integer serialNumber = 1;
        List<String> systemIds = new List<String>();
        for (Account_Intelligence__c ai : aiList) {
            if(!systemIds.contains(ai.Salesforce_System_Id__c)){
            aiDataWrapper wrap = new aiDataWrapper();
            wrap.aiUrl = sfdcBaseURL+'/'+ai.Id;
            wrap.Name = ai.Name;
             if(ai.Salesforce_System_ID__r.System_Name__c != '' && ai.Salesforce_System_ID__r.System_Name__c != null){
                 wrap.systemName = ai.Salesforce_System_ID__r.System_Name__c;
            }
            else{
                 wrap.systemName = ai.Salesforce_System_ID__r.Name; 
             
                }
            wrap.AccountName = ai.AccountName__r.name;
            wrap.Type = ai.Account_Intelligence_Type__c;
            wrap.systemURL = sfdcBaseURL + '/' +ai.Salesforce_System_Id__c; 
            wrap.Description = ai.Short_Description__c;
            // Change by Joana -> related to feddback "Add new columns Technological Category, Sub category and technology and remove Account Intelligence Type" 
            wrap.technographicCategory = ai.Technographic_Category__c;
            wrap.subCategory = ai.Sub_Category__c;
            wrap.technology = ai.Technology__c;
            wrap.serialNumber = serialNumber;
            wrap.dNumber = ai.AccountName__r.Account_Number__c;
            serialNumber++;
            // End Changes by Joana
            swList.add(wrap);
            systemIds.add(ai.Salesforce_System_Id__c);
            }
        }
        aiw.aiData = swList;
        aiw.AccountId = accplan.Account_Name__c;
        aiw.Status =accplan.Account_Plan_Status__c;
        aiw.currCode = accplan.Account_Name__r.CurrencyIsoCode;
        aiw.genericRecordTypeId = Schema.SObjectType.System__c.getRecordTypeInfosByDeveloperName().get('HR_MS_System').getRecordTypeId();
     
        return aiw;
    }
	
	//return account intelligence details on opportunity page
	@AuraEnabled(cacheable=true)
    public static AccountIntelligenceOppWrapper getSystemDetailsOpp(Id OppId){
       
        AccountIntelligenceOppWrapper aiw = new AccountIntelligenceOppWrapper();
        Opportunity Opplist = [select id, AccountId,Account.Status__c, CurrencyIsoCode,name
                                     from Opportunity where id=:OppId];
        
        List<Account_Intelligence__c> aiList = [SELECT id , Account_Intelligence_Name__c, Account_Intelligence_Type__c, 
                                                   AccountName__c, Salesforce_System_Id__c, name,Short_Description__c,
                                                     Salesforce_System_Id__r.System_Name__c,
                                                   Salesforce_System_ID__r.Name, Technographic_Category__c, Sub_Category__c,
                                                   Technology__c, Archived__c FROM Account_Intelligence__c
                                                WHERE AccountName__c=:Opplist.AccountId and Archived__c = false];
        
        List<aiDataWrapper> swList = new List<aiDataWrapper>(); 
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Integer serialNumber = 1;
        for (Account_Intelligence__c ai : aiList) {
            aiDataWrapper wrap = new aiDataWrapper();
            wrap.aiUrl = sfdcBaseURL+'/'+ai.Id;
            wrap.Name = ai.Name;
             if(ai.Salesforce_System_ID__r.System_Name__c != '' && ai.Salesforce_System_ID__r.System_Name__c != null){
                 wrap.systemName = ai.Salesforce_System_ID__r.System_Name__c;
            }
            else{
                 wrap.systemName = ai.Salesforce_System_ID__r.Name; 
             
                }
            wrap.AccountName = ai.AccountName__c;
            wrap.Type = ai.Account_Intelligence_Type__c;
            wrap.systemURL = sfdcBaseURL + '/' +ai.Salesforce_System_Id__c; 
            wrap.Description = ai.Short_Description__c;
            wrap.technographicCategory = ai.Technographic_Category__c;
            wrap.subCategory = ai.Sub_Category__c;
            wrap.technology = ai.Technology__c;
            wrap.serialNumber = serialNumber;
            serialNumber++;
            swList.add(wrap);
        }
        aiw.aiData = swList;
        aiw.AccountId = Opplist.AccountId;
        aiw.currCode = Opplist.CurrencyIsoCode;
        aiw.oppName = Opplist.name;
        aiw.isAccountSanctioned = Opplist.Account.Status__c == 'Rejected - Sanctioned Account' ? true : false;
        aiw.genericRecordTypeId = Schema.SObjectType.System__c.getRecordTypeInfosByDeveloperName().get('HR_MS_System').getRecordTypeId();

     
        return aiw;
    }
	
	public class AccountIntelligenceOppWrapper{
        
        @AuraEnabled public List<aiDataWrapper> aiData;
        @AuraEnabled public String AccountId;
        @AuraEnabled public String currCode;
        @AuraEnabled public String oppName;
        @AuraEnabled public String genericRecordTypeId;
        @AuraEnabled public Boolean isAccountSanctioned;
    }
	
    
    public class AccountIntelligenceWrapper{
        
        @AuraEnabled public List<aiDataWrapper> aiData;
        @AuraEnabled public String AccountId;
        @AuraEnabled public String Status;
        @AuraEnabled public String currCode;
        @AuraEnabled public String genericRecordTypeId;
    }
    public class aiDataWrapper{
        
        @AuraEnabled public String aiUrl { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String systemName { get; set; }
        @AuraEnabled public String AccountName { get; set; }
        @AuraEnabled public String Type { get; set; }
        @AuraEnabled public String systemURL { get; set; }
        @AuraEnabled public String Description { get; set; }
        // Change by Joana -> added bellow 3 variables
        @AuraEnabled public String technographicCategory { get; set; }
        @AuraEnabled public String subCategory { get; set; }
        @AuraEnabled public String technology { get; set; }
        @AuraEnabled public Integer serialNumber {get; set;}
        @AuraEnabled public String dNumber { get; set; }
                
    }

    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public System__c systemRecord;
    }
    
}
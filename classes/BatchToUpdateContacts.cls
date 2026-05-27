public class BatchToUpdateContacts implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Contact_Status__c, Do_Not_Contact__c, Email_Undeliverable__c, Constant_Soft_Bounce_Domain__c,
                                         Constant_Soft_Bounce_Contact__c, Email_Opted_In__c, Double_Opted_In__c,
                                         Global_Mailing_Country__c, High_Risk_Country__c, NonHotCountryCheck__c,
                                         Personal_Email_Address_Domain__c, Calculated_ACV__c, Inactive_in_Eloqua__c,
                                         Email_Group_Subscription__c, Output_Detail__c FROM Contact]);   
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> contactList) {
        try{
        	ContactTriggerManager.computeOutputDetailForMarketingPermissible(contactList, null);    
        }catch(Exception ex){
            System.debug('exception '+ex.getMessage());
        } 
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}
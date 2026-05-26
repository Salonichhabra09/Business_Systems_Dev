/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is created to handle multiple functionality which needs to run in system mode also it will               *
               fetch data for different related objects for Account Plan.(SSE-23166)                                               *
************************************************************************************************************************************/
public without Sharing class AccountPlanDataFetch {
    
    public static List<Account_Plan__c> getAccountPlanData(String BuyingCentreId , string accountId){
         List<Account_Plan__c> accplanList = new  List<Account_Plan__c>();
        if(BuyingCentreId != '' && BuyingCentreId != null){
            accplanList = [select id , name ,Account_Plan_Type__c,Account_Name__c,Date_for_next_Plan_Review__c,
                               Account_Plan_Name__c,Account_Plan_Status__c
                               from Account_Plan__c
                               where (Account_Name__c=:accountId 
                                      or Buying_Centre_Id__c = :BuyingCentreId) 
                               and is_Account_Plan_Retired__c != true  //Change Added Account Plan Phase 4
                              ];
        }
        else{
             accplanList = [select id , name ,Account_Plan_Type__c,Account_Name__c,
                               Date_for_next_Plan_Review__c,
                               Account_Plan_Name__c,Account_Plan_Status__c
                               from Account_Plan__c
                               where Account_Name__c=:accountId 
                               
                              ];
        }
       
        return accplanList;
    }
    
    public static String syncAccountPlanMethod(String accountplanId){
          
       string successMessage = '';  
        Account_Plan__c accPlan = [select id , Account_Name__c,Date_of_Last_Plan_Review__c,
                                   Account_Name__r.Business_Defined_Attribute__c,Account_Plan_Type__c,Buying_Centre_Id__c,
                                   Account_Name__r.CurrencyIsoCode,CurrencyIsoCode,Business_Defined_Attribute__c
                                   from Account_Plan__c where id = :accountplanId];
        List<Contact> contactList = new List<Contact>();
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<Case> caseList = new List<Case>();
        List<Case> allCaseList = new List<Case>();
        Datetime dateTimevar =  System.now();
        DateTime checklastyear = dateTimevar.addYears(-1);
        
        if(accPlan.Account_Plan_Type__c == 'Current'){
            contactList = [select id, Last_Activity_Happen__c,Subject_Discussed__c ,createddate from contact
                           where AccountId = :accPlan.Account_Name__c and 
                           Contact_Status__c = 'Active' 
                           order by Last_Activity_Happen__c desc ];
            
            oppList =[select id , amount , createdDate , Sales_Price_in_USD__c from opportunity 
                      where stagename != 'Closed/Won' and stagename != 'Closed Lost'  
                      and AccountId = :accPlan.Account_Name__c];
            
            caseList =[select id , createddate , status from case where AccountId =:accPlan.Account_Name__c
                       and (not Status like '%close%')];
            
             allCaseList = [select id , createddate , status from case 
                           where  AccountId =:accPlan.Account_Name__c
                           and  CreatedDate > :checklastyear  ];  
        }
        
        
        else if(accPlan.Account_Plan_Type__c == 'Regional'){
            
            contactList = [select id, Last_Activity_Happen__c,Subject_Discussed__c ,createddate from contact
                           where account.Buying_Centre_Id__c = :accPlan.Buying_Centre_Id__c and 
                           Contact_Status__c = 'Active' 
                           order by Last_Activity_Happen__c desc ];
            
            oppList =[select id , amount , createdDate , Sales_Price_in_USD__c from opportunity 
                      where stagename != 'Closed/Won' and stagename != 'Closed Lost'  
                      and account.Buying_Centre_Id__c = :accPlan.Buying_Centre_Id__c];
            
            caseList =[select id , createddate , status from case
                       where Account.Buying_Centre_Id__c =:accPlan.Buying_Centre_Id__c
                       and (not Status like '%close%')];
            
            allCaseList = [select id , createddate , status from case 
                           where  Account.Buying_Centre_Id__c =:accPlan.Buying_Centre_Id__c
                           and  CreatedDate > :checklastyear  ];  
            
        }
        
        
        else if(accPlan.Account_Plan_Type__c == 'Global'){
            
            Set<Id> allAccountIds = new Set<Id>{accPlan.Account_Name__c};
                Set<Id> parentIds = new Set<Id>{accPlan.Account_Name__c};
                    List<Account> childAccounts = new List<Account>();
            do {
                childAccounts = [SELECT Id FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                parentIds.clear();
                for (Account child : childAccounts){
                    parentIds.add(child.Id);
                    allAccountIds.add(child.Id);
                }
            } while (childAccounts.size() > 0);
  
            
            contactList = [select id, Last_Activity_Happen__c,Subject_Discussed__c ,createddate from contact
                           where AccountId in :allAccountIds and 
                           Contact_Status__c = 'Active' 
                           order by Last_Activity_Happen__c desc ];
            
            oppList =[select id , amount , createdDate , Sales_Price_in_USD__c from opportunity 
                      where stagename != 'Closed/Won' and stagename != 'Closed Lost'  
                      and AccountId in :allAccountIds];
            
            caseList =[select id , createddate , status from case where AccountId in :allAccountIds
                       and (not Status like '%close%')];
            
             allCaseList = [select id , createddate , status from case 
                           where  AccountId in :allAccountIds
                           and  CreatedDate > :checklastyear  ]; 
        }   
        
        Account_Plan__c ap = new Account_Plan__c();
            
            ap.id = accountplanId;
            if(accPlan.Business_Defined_Attribute__c!=accPlan.Account_Name__r.Business_Defined_Attribute__c){
                ap.Business_Defined_Attribute__c = accPlan.Account_Name__r.Business_Defined_Attribute__c;
            }
            
            
            if(contactList.size() > 0){
                
                Integer totalContactlastyear= 0;  
                Integer contactsCreatedAfterReview =0;
                
                ap.Contacts_at_this_Account__c = contactList.size();
                for(Contact c:contactList){
                    Date created_Date = date.newinstance((c.createdDate).year(), (c.createdDate).month(), (c.createdDate).day());
                   
                    
                    if(c.createdDate > checklastyear){
                        totalContactlastyear = totalContactlastyear +1;
                    }
                    if(accPlan.Date_of_Last_Plan_Review__c != null){
                        
                        if(created_Date > accPlan.Date_of_Last_Plan_Review__c){
                            contactsCreatedAfterReview = contactsCreatedAfterReview + 1;
                        
                        }
                    }
                    
                }
                
                ap.Contacts_Created_Last_12_Months__c = totalContactlastyear;
                ap.Contacts_Created_since_last_review__c = contactsCreatedAfterReview;
            }
            else{
                ap.Contacts_at_this_Account__c = 0;
                ap.Contacts_Created_Last_12_Months__c = 0;
                ap.Contacts_Created_since_last_review__c =0;
            }
             
            
                    if(!caseList.isEmpty()){
                    Integer noOfCase  = 0;
                    for(Case o : caseList){                       
                        noOfCase = noOfCase+ 1;                
                    }
                    ap.Open_Cases__c = noOfCase;
                }
                 else{
                    ap.Open_Cases__c = 0;
                }
                
                if(!allCaseList.isEmpty()){
                    Integer totalCaselastyear = 0;
                    
                    for(Case o : allCaseList){                       
                        totalCaselastyear = totalCaselastyear +1;              
                    }
                    ap.Cases_Last_12_Months_open_closed__c = totalCaselastyear;
                }else{
                    ap.Cases_Last_12_Months_open_closed__c = 0;
                }
            
            if(oppList.size() > 0){
                Decimal oppAmount = 0 ; 
                ap.Open_Opportunities__c = oppList.size();
                Integer oppCreatedAfterReview = 0;
                for(Opportunity o:oppList){
                    Date created_Date = date.newinstance((o.createdDate).year(), (o.createdDate).month(), (o.createdDate).day());
                  
                    if( o.Sales_Price_in_USD__c != null){
                        oppAmount = oppAmount + o.Sales_Price_in_USD__c;
                        
                    }
                    if(accPlan.Date_of_Last_Plan_Review__c != null){
                        
                        if(created_Date > accPlan.Date_of_Last_Plan_Review__c){
                            oppCreatedAfterReview = oppCreatedAfterReview + 1;
                            
                        }
                    }
                }   
                //Integer oppAmountInt = oppAmount.intValue();
                Decimal oppAmountInt = oppAmount.setScale(0);
                ap.Open_Opportunity_Value__c = oppAmountInt;
                ap.Opportunities_Created_since_last_Review__c = oppCreatedAfterReview;
            }
            else{
                ap.Open_Opportunities__c = 0;
                ap.Open_Opportunity_Value__c = 0;
            }
            
            if(accPlan.CurrencyIsoCode != accPlan.Account_Name__r.CurrencyIsoCode){
                ap.CurrencyIsoCode = accPlan.Account_Name__r.CurrencyIsoCode;
            }
            
            update ap; 
            successMessage = 'SUCCESS';
               
       return successMessage;
        
    }
    
    @AuraEnabled
    public static string checkUserAccessOnAP(string accountplanId){
        string AccessLevel = '';
        
        Account_Plan__c accPlan = [select id , Account_Name__c,Date_of_Last_Plan_Review__c,
        Account_Name__r.Business_Defined_Attribute__c,Account_Plan_Type__c,Buying_Centre_Id__c,
        Account_Name__r.CurrencyIsoCode,CurrencyIsoCode,Business_Defined_Attribute__c
        from Account_Plan__c where id = :accountplanId];

        if(accPlan != null){
         UserRecordAccess checkRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess 
                                                WHERE UserId =:UserInfo.getUserId() 
                                                AND RecordId =:accPlan.Account_Name__c];
         if(checkRecordAccess != null){
             if(checkRecordAccess.HasEditAccess == true){
                  AccessLevel = 'Edit' ;
             }
             else{
                 if(checkRecordAccess.HasReadAccess == true){
                     AccessLevel = 'Read' ; 
                 }
             }
            
               
            
         }
        }
        return AccessLevel;
    }
    
    public static string updateLastContactedDetailsMethod(String accountplanId){
         string successMessage = ''; 
         Account_Plan__c accPlan = [select id , Account_Name__c
                                   from Account_Plan__c where id = :accountplanId];
        
        List<Contact> contactList = [select id, Last_Activity_Happen__c,Subject_Discussed__c from contact
                                     where AccountId = :accPlan.Account_Name__c and Last_Activity_Happen__c != null
                                     order by Last_Activity_Happen__c desc limit 1];
            
            if(contactList.size() > 0){
                for(Contact c:contactList){
                    accPlan.Who_did_we_last_meet_in_the_organisation__c = c.id;
                    accPlan.Subject_discussed_actions_agreed__c = c.Subject_Discussed__c;
                }
            }
            
            update accPlan;
        successMessage = 'SUCCESS';
            return successMessage;
        
        
     
        
    }
        
    
    
}
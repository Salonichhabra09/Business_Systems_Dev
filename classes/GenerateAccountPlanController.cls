/***********************************************************************************************************************************
* Created By: Prachi Gupta                                                                                                         * 
* Description: This class is created to handle multiple functionality such as autoSync ,creation of Account Plan                   *
*              from Account, Cloning Account Plan ,sending the Account Plan for approval its getting used in                       *
*              generateAccountPlan LWC  and createAccountPlanComponent LWC .                                                       *
************************************************************************************************************************************/

public class GenerateAccountPlanController {
    
    
    //This method is used to check if an account Plan exist on the account.Added as part of SSE-21127(Account Plan Phase 3)
    @AuraEnabled(cacheable=true)
    public static returnMessageWrapper openAccounPlan(String accountId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        List<accountPlanList> apList = new List<accountPlanList>();
        List<Account_Plan__c> apDatainSystemContext = new List<Account_Plan__c>();
        String BuyingCentreId = '';
        rmw.showRegional = false; 
        rmw.showGlobal = false;
        
        //rmw.globalAPExists = false;
        try{
            //Change Start Prachi Account Plan Phase 4 SSE-21126
            
            List<Account> accList = [select id , Buying_Centre_Id__c from Account 
                                     where (id =:accountId or ParentId =:accountId) and RecordType.name != 'Competitor Account'];
            List<Account_Plan__c> accplanList = new List<Account_Plan__c>(); 
            
            if(accList.size() == 1){
                for(Account a: accList){
                    if(a.id == accountId && a.Buying_Centre_Id__c != null && a.Buying_Centre_Id__c != ''){
                        BuyingCentreId = a.Buying_Centre_Id__c; 
                        rmw.showRegional = true;
                        
                    }
                }
            }
            else if(accList.size()>1){
                for(Account a: accList){
                    
                    if(a.id == accountId && a.Buying_Centre_Id__c != null && a.Buying_Centre_Id__c != ''){
                        BuyingCentreId = a.Buying_Centre_Id__c; 
                        rmw.showRegional = true; 
                        
                    }
                }
                
                // rmw.showGlobal = true; 
                // Remove the comments from above whenever Global Option will be made available for Users.
            }
            //Change End Account Plan Phase 4 SSE-21126
            if(BuyingCentreId!= '' && BuyingCentreId!= null ){
                
                accplanList = [select id , name ,Account_Plan_Type__c,Account_Name__c,Date_for_next_Plan_Review__c,
                               Account_Plan_Name__c,Account_Plan_Status__c
                               from Account_Plan__c
                               where (Account_Name__c=:accountId 
                                      or Buying_Centre_Id__c = :BuyingCentreId) 
                               and is_Account_Plan_Retired__c != true  //Change Added Account Plan Phase 4
                              ];
                
                //Added as part of SSE-23166
                apDatainSystemContext = AccountPlanDataFetch.getAccountPlanData(BuyingCentreId,accountId);
                
            }
            else{
                accplanList = [select id , name ,Account_Plan_Type__c,Account_Name__c,
                               Date_for_next_Plan_Review__c,
                               Account_Plan_Name__c,Account_Plan_Status__c
                               from Account_Plan__c
                               where Account_Name__c=:accountId 
                               
                              ];
                //Added as part of SSE-23166
                apDatainSystemContext = AccountPlanDataFetch.getAccountPlanData('',accountId);
            }
            
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm(); 
            
            //Change Start Account Plan Phase 4 SSE-21126
            if(!accplanList.isEmpty()){
                //Added as part of SSE-23166
                if(!apDatainSystemContext.isEmpty() ){               
                        rmw.MessageType = 'SUCCESS';
                        rmw.Message = 'Account Plan Exists';  
                        if(accplanList.size() == 1 ){
                            rmw.AccountPlanId = accplanList[0].id;
                            for(Account_Plan__c ap : accplanList){        
                                accountPlanList apWrapper = new accountPlanList();
                                apWrapper.apURL = sfdcBaseURL+'/'+ap.id;
                                apWrapper.apName = ap.Account_Plan_Name__c;
                                apWrapper.apType = ap.Account_Plan_Type__c;
                                apWrapper.nextReview = ap.Date_for_next_Plan_Review__c;
                                apWrapper.apStatus = ap.Account_Plan_Status__c;
                                apList.add(apWrapper);
                                
                            }
                            rmw.apList = apList;                }
                        else{
                            for(Account_Plan__c ap : accplanList){        
                                accountPlanList apWrapper = new accountPlanList();
                                apWrapper.apURL = sfdcBaseURL+'/'+ap.id;
                                apWrapper.apName = ap.Account_Plan_Name__c;
                                apWrapper.apType = ap.Account_Plan_Type__c;
                                apWrapper.nextReview = ap.Date_for_next_Plan_Review__c;
                                apWrapper.apStatus = ap.Account_Plan_Status__c;
                                apList.add(apWrapper);
                                
                            }
                            rmw.apList = apList;
                        }
                                  
                   
                }
            }
            // Change end Account Plan Phase 4 SSE-21126
            else if(accplanList.size() <= 0 && apDatainSystemContext.size() <= 0){
                rmw.MessageType = 'SUCCESS';
                rmw.Message = 'No Account Plan Found';
            }
            else if(accplanList.size() <= 0 && apDatainSystemContext.size() != accplanList.size()){
                rmw.MessageType = 'ERROR';
                rmw.Message = 'You do not have access to linked Account Plan. Please contact system administrator for further assistance.';
            }
            
        }catch(Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
            rmw.AccountPlanId = '';
        }
        return rmw;
    }
    @AuraEnabled
    public static returnMessageWrapper generateAccountPlan(String accountId , String apType ){
        //Changes Done as part of Account Plan phase 4
        List<Account> updateAccountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<Case> caseList = new List<Case>();
        List<Case> allCaseList = new List<Case>();
        Datetime dateTimevar =  System.now();
        DateTime checklastyear = dateTimevar.addYears(-1);
        
        List<Account> accList  = [select id , 
                                  //DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessDescription__c,//Commented as part of SSE-19161
                                  //DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__FiscalYearEnd__c,//Commented as part of SSE-19161
                                 DNBConnect__D_B_Connect_Company_Profile__r.activity_desc_1__c, //Added as part of SSE-19161(needs to remove if dnb changes goes after account plan)
                                 DNBConnect__D_B_Connect_Company_Profile__r.fiscal_year_end__c,//Added as part of SSE-19161(needs to remove if dnb changes goes after account plan)
                                  Buying_Centre_Id__c,Account_Number__c,//Added as part of Account Plan Phase 4 SSE-21126
                                  CurrencyIsoCode,Business_Defined_Attribute__c,
                                  Number_of_Account_Plan__c,//Added as part of Account Plan Phase 4 SSE-21126
                                  ZI_Employee_Count__c,Highest_Employee_Count__c,//Added  SSE-21115 Account Plan Phase3
                                  Global_FTEs__c
                                  from Account where id = :accountId ];
        
        if(apType == 'Current'){
            
            contactList = [select id, Last_Activity_Happen__c,Subject_Discussed__c ,createddate,AccountId from contact
                           where Account.Buying_Centre_Id__c  = :accountId and  Contact_Status__c = 'Active' 
                           order by Last_Activity_Happen__c desc ];
            
            
            
            oppList = [select id , amount,Sales_Price_in_USD__c from opportunity 
                       where stagename != 'Closed/Won' and stagename != 'Closed Lost' 
                       and AccountId = :accountId];
            
            caseList = [select id , createddate , status from case where AccountId =:accountId  and (not Status like '%close%')];
            
            allCaseList = [select id , createddate , status from case 
                           where Account.Buying_Centre_Id__c  = :accList[0].Buying_Centre_Id__c 
                           and  CreatedDate > :checklastyear  ];     
        }
        if(apType == 'Global'){
            Set<Id> allAccountIds = new Set<Id>{accountId};
                Set<Id> parentIds = new Set<Id>{accountId};
                    List<Account> childAccounts = new List<Account>();
            do {
                childAccounts = [SELECT Id FROM Account WHERE ParentId IN :parentIds AND RecordType.name != 'Competitor Account'];
                parentIds.clear();
                for (Account child : childAccounts){
                    parentIds.add(child.Id);
                    allAccountIds.add(child.Id);
                }
            } while (childAccounts.size() > 0);
            contactList = [select id, Last_Activity_Happen__c,Subject_Discussed__c ,createddate,AccountId from contact
                           where AccountId  in :allAccountIds and  
                           Contact_Status__c = 'Active' 
                           order by Last_Activity_Happen__c desc ];     
            
            oppList = [select id , amount , Sales_Price_in_USD__c from opportunity 
                       where stagename != 'Closed/Won' and stagename != 'Closed Lost' 
                       and AccountId  in :allAccountIds];
            
            caseList = [select id , createddate , status from case 
                        where AccountId  in :allAccountIds 
                        and (not Status like '%close%') ];
            
            allCaseList = [select id , createddate , status from case 
                           where AccountId  in :allAccountIds
                           and  CreatedDate > :checklastyear  ];  
            
            
        }
        if(apType == 'Regional'){
            
            contactList = [select id, Last_Activity_Happen__c,Subject_Discussed__c ,createddate,AccountId from contact
                           where Account.Buying_Centre_Id__c  = :accList[0].Buying_Centre_Id__c and  
                           Contact_Status__c = 'Active' 
                           order by Last_Activity_Happen__c desc ];     
            
            oppList = [select id , amount , Sales_Price_in_USD__c from opportunity 
                       where stagename != 'Closed/Won' and stagename != 'Closed Lost' 
                       and Account.Buying_Centre_Id__c  = :accList[0].Buying_Centre_Id__c];
            
            caseList = [select id , createddate , status from case 
                        where Account.Buying_Centre_Id__c  = :accList[0].Buying_Centre_Id__c 
                        and (not Status like '%close%') ];
            
            allCaseList = [select id , createddate , status from case 
                           where Account.Buying_Centre_Id__c  = :accList[0].Buying_Centre_Id__c 
                           and  CreatedDate > :checklastyear  ];  
            
        }
        
        
        
        
        returnMessageWrapper rmw = new returnMessageWrapper();
        String quarter;
        Date dt = System.today(); //current date
        Integer month = dt.Month(); //get month
        Integer year = dt.Year(); //get year
        String yearString = String.valueOf(year);
        
        if(month == 1 || month == 2 || month == 3){
            quarter = 'Q1';
        }
        else if(month == 4 || month == 5 || month == 6){
            quarter = 'Q2';
        }
        else if(month == 7 || month == 8 || month == 9){
            quarter = 'Q3';
        }
        else if(month == 10 || month == 11 || month == 12){
            quarter = 'Q4';
        }
        if(accountId != ''){
            try{
                
                Account_Plan__c ap = new Account_Plan__c();
                ap.Account_Name__c = accountId;
                ap.Quarter__c = quarter ;  
                ap.Year__c =yearString;
                //Added as part of Account Plan phase 4 SSE-21126
                ap.Account_Plan_Type__c = apType;
                
                //Change end as part of Account Plan phase 4 SSE-21126
                
                if(!contactList.isEmpty()){
                    Boolean lastContactedBool = true;
                    Integer totalContactlastyear= 0;  
                    ap.Contacts_at_this_Account__c = contactList.size();
                    for(Contact c:contactList){
                        
                        if(lastContactedBool = true && c.Last_Activity_Happen__c != null && c.AccountId == accountId){
                            lastContactedBool = false;
                            ap.Who_did_we_last_meet_in_the_organisation__c = c.id;
                            ap.Subject_discussed_actions_agreed__c = c.Subject_Discussed__c;
                        }   
                        if(c.createdDate > checklastyear){
                            totalContactlastyear = totalContactlastyear +1;
                        }
                    }
                    
                    ap.Contacts_Created_Last_12_Months__c = totalContactlastyear;
                }
                else{
                    ap.Contacts_at_this_Account__c = 0;
                    ap.Contacts_Created_Last_12_Months__c = 0;
                }
                
                /* Commented as part of Account Plan phase 4
* if(caseList.size() > 0){
Integer noOfCase  = 0;
Integer totalCaselastyear = 0; 

for(Case o : caseList){
if(!o.status.contains('Close')){
noOfCase = noOfCase+ 1;          
} 
if(o.createdDate > checklastyear){
totalCaselastyear = totalCaselastyear +1;
}
}
ap.Open_Cases__c = noOfCase;
ap.Cases_Last_12_Months_open_closed__c = totalCaselastyear;
}
else{
ap.Open_Cases__c = 0;
ap.Cases_Last_12_Months_open_closed__c = 0;
}*/
                
                if(!caseList.isEmpty()){
                    Integer noOfCase  = 0;
                    for(Case o : caseList){                       
                        noOfCase = noOfCase+ 1;                
                    }
                    ap.Open_Cases__c = noOfCase;
                }else{
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
                
                //Account Plan Phase 4 changes end
                
                if(!oppList.isEmpty()){
                    Decimal oppAmount = 0 ; 
                    ap.Open_Opportunities__c = oppList.size();
                    for(Opportunity o:oppList){
                        if( o.Sales_Price_in_USD__c != null){
                            oppAmount = oppAmount + o.Sales_Price_in_USD__c;
                            
                        }
                    }   
                    
                    //Integer oppAmountInt = oppAmount.intValue();
                    Decimal oppAmountInt = oppAmount.setScale(0);
                    ap.Open_Opportunity_Value__c = oppAmountInt;
                }
                else{
                    ap.Open_Opportunities__c = 0;
                    ap.Open_Opportunity_Value__c = 0;
                }
                if(accList.size()>0){
                    for(Account acc : accList){
                      // ap.Overview_of_Business__c = acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessDescription__c;//Commented as part of SSE-19161(needs to remove if dnb changes goes after account plan)
                      // ap.Fiscal_Year_End__c = acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__FiscalYearEnd__c;//Commented as part of SSE-19161(needs to remove if dnb changes goes after account plan)
                       ap.Overview_of_Business__c = acc.DNBConnect__D_B_Connect_Company_Profile__r.activity_desc_1__c;//Added as part of SSE-19161(needs to remove if dnb changes goes after account plan)
                       ap.Fiscal_Year_End__c = acc.DNBConnect__D_B_Connect_Company_Profile__r.fiscal_year_end__c;//Added as part of SSE-19161(needs to remove if dnb changes goes after account plan)
                        ap.Account_Plan_Status__c = 'Draft';
                        ap.CurrencyIsoCode = acc.CurrencyIsoCode;
                        ap.Business_Defined_Attribute__c = acc.Business_Defined_Attribute__c;
                        //ap.Global_FTE_Number__c=acc.ZI_Employee_Count__c;//Added  SSE-21115 Account Plan Phase3
                        ap.Global_FTE_Number__c=acc.Global_FTEs__c;
                        ap.Regional_FTE_Number__c =acc.Highest_Employee_Count__c;//Added  SSE-21115 Account Plan Phase3
                        //Account Plan Phase 4 changes SSE-21126
                        if(apType == 'Regional'){
                            ap.Buying_Centre_Id__c = acc.Buying_Centre_Id__c;  
                            
                        }
                        else{
                            Decimal noOfAP = 0;
                            if(acc.Number_of_Account_Plan__c == null){
                                noOfAP = 1;
                            }
                            else{
                                noOfAP = acc.Number_of_Account_Plan__c + 1;
                            }
                            Account a = new Account(id = acc.id ,
                                                    Number_of_Account_Plan__c = noOfAP
                                                   );
                            updateAccountList.add(a); 
                        }
                        //Changes end Account Plan Phase 4 changes SSE-21126
                    }
                }
                insert   ap; 
                //Changes start Account Plan Phase 4 changes SSE-21126
                /*  if(apType == 'Regional'){
List<Account> regionalAccount = [Select id , Number_of_Account_Plan__c 
from Account where Buying_Centre_Id__c = :accList[0].Buying_Centre_Id__c];
if(!regionalAccount.isEmpty()){
for(Account a: regionalAccount){
Decimal noOfAP = 0;
if(a.Number_of_Account_Plan__c == null){
noOfAP = 1;
}
else{
noOfAP = a.Number_of_Account_Plan__c + 1;
}
a.Number_of_Account_Plan__c = noOfAP; 
updateAccountList.add(a);
}
}

}
*/
                if(!updateAccountList.isEmpty()){
                    update updateAccountList;
                }
                
                //Changes end Account Plan Phase 4 changes SSE-21126
                rmw.MessageType = 'SUCCESS';
                rmw.Message = 'Account Plan have been saved successfully!';
                rmw.AccountPlanId = ap.id;
                
                
                
            }catch(Exception ex){
                rmw.MessageType = 'ERROR';
                if(ex.getMessage().contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, insufficient access rights on cross-reference id: 001')){
                    rmw.Message = 'Looks like you do not have access to this Account for generating Account Plan.';
                }
                else{
                    rmw.Message = ex.getMessage();
                }
                
                rmw.AccountPlanId = '';   
            }
        }
        return rmw;
    } 
    
    //This method is used to clone an account Plan using clone button on Account Plan  
    /* @AuraEnabled
public static returnMessageWrapper cloneAccountPlan(String accountplanId){
system.debug('Inside Clone--');
Account_Plan__c apToCreate = new Account_Plan__c();
returnMessageWrapper rmw = new returnMessageWrapper();
String quarter;
Date dt = System.today(); //current date
Integer month = dt.Month(); //get month
Integer year = dt.Year(); //get year
String yearString = String.valueOf(year);
if(month == 1 || month == 2 || month == 3){
quarter = 'Q1';
}
else if(month == 4 || month == 5 || month == 6){
quarter = 'Q2';
}
else if(month == 7 || month == 8 || month == 9){
quarter = 'Q3';
}
else if(month == 10 || month == 11 || month == 12){
quarter = 'Q4';
}
if(accountplanId != ''){

Account_Plan__c accPlan = [select id , Account_Name__c,Account_Name__r.name, Account_Manager__c, Sales_Manager__c,
SHL_BU_Region__c, Territory_Type__c, 
Location_of_Global_HQ__c, RAD_Strategy__c, Segment__c , Website__c, 
Industry__c, Global_FTEs__c, Regional_FTEs__c, Overview_of_Business__c,
Our_Current_Situation_Outlook__c, Account_Name__r.CurrencyIsoCode,
Client_s_Strategy__c, Risk_Exposure__c, 
Relationship_History__c,  Account_Name__r.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessDescription__c,
Account_Name__r.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__FiscalYearEnd__c,
Summary_of_Current_SHL_Relationship__c
from Account_Plan__c where id = :accountplanId];



List<Contact> contactList = [select id, Last_Activity_Happen__c,Subject_Discussed__c ,createddate from contact
where AccountId = :accPlan.Account_Name__c and  Contact_Status__c = 'Active' 
order by Last_Activity_Happen__c desc ];


List<Opportunity> oppList = [select id , amount from opportunity 
where stagename != 'Closed/Won' and stagename != 'Closed Lost' 
and AccountId = :accPlan.Account_Name__c];

List<Case> caseList = [select id , createddate , status from case where AccountId =:accPlan.Account_Name__c];

Datetime dateTimevar =  System.now();
DateTime checklastyear = dateTimevar.addYears(-1);

try{
system.debug('month'+month);
system.debug('year'+yearString);
system.debug('Quarter__c'+quarter);

apToCreate.Account_Name__c = accPlan.Account_Name__c;
apToCreate.Quarter__c = quarter;  
apToCreate.Year__c =yearString;
apToCreate.Location_of_Global_HQ__c  = accPlan.Location_of_Global_HQ__c;
apToCreate.Summary_of_Current_SHL_Relationship__c  = accPlan.Summary_of_Current_SHL_Relationship__c;
apToCreate.Client_s_Strategy__c  = accPlan.Client_s_Strategy__c;
apToCreate.Our_Current_Situation_Outlook__c  = accPlan.Our_Current_Situation_Outlook__c;
apToCreate.Risk_Exposure__c  = accPlan.Risk_Exposure__c;
apToCreate.Relationship_History__c  = accPlan.Relationship_History__c;
apToCreate.Account_Plan_Status__c = 'Draft';
apToCreate.CurrencyIsoCode = accPlan.Account_Name__r.CurrencyIsoCode;
apToCreate.Fiscal_Year_End__c = accPlan.Account_Name__r.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__FiscalYearEnd__c;
apToCreate.Overview_of_Business__c = accPlan.Account_Name__r.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessDescription__c;


if(contactList.size() > 0){
Boolean lastContactedBool = true;
Integer totalContactlastyear= 0;  
apToCreate.Contacts_at_this_Account__c = contactList.size();
for(Contact c:contactList){

if(lastContactedBool = true && c.Last_Activity_Happen__c != null ){
lastContactedBool = false;
apToCreate.Who_did_we_last_meet_in_the_organisation__c = c.id;
apToCreate.Subject_discussed_actions_agreed__c = c.Subject_Discussed__c;
}   
if(c.createdDate > checklastyear){
totalContactlastyear = totalContactlastyear +1;
}
}

apToCreate.Contacts_Created_Last_12_Months__c = totalContactlastyear;
}
else{
apToCreate.Contacts_at_this_Account__c = 0;
apToCreate.Contacts_Created_Last_12_Months__c = 0;
}

if(caseList.size() > 0){
Integer noOfCase  = 0;
Integer totalCaselastyear = 0; 

for(Case o : caseList){
if(!o.status.contains('Close')){
noOfCase = noOfCase+ 1;          
} 
if(o.createdDate > checklastyear){
totalCaselastyear = totalCaselastyear +1;
}
}
apToCreate.Open_Cases__c = noOfCase;
apToCreate.Cases_Last_12_Months_open_closed__c = totalCaselastyear;
}
else{
apToCreate.Open_Cases__c = 0;
apToCreate.Cases_Last_12_Months_open_closed__c = 0;
}

if(oppList.size() > 0){
Decimal oppAmount = 0 ; 
apToCreate.Open_Opportunities__c = oppList.size();
for(Opportunity o:oppList){
if( o.amount != null){
oppAmount = oppAmount + o.amount;

}
}   
Integer oppAmountInt = oppAmount.intValue();
apToCreate.Open_Opportunity_Value__c = oppAmountInt;
}
else{
apToCreate.Open_Opportunities__c = 0;
apToCreate.Open_Opportunity_Value__c = 0;
}



insert apToCreate; 

rmw.MessageType = 'SUCCESS';
rmw.Message = 'Account Plan have been cloned successfully!';
rmw.AccountPlanId = apToCreate.id;


}catch(Exception ex){
rmw.MessageType = 'ERROR';
rmw.Message = ex.getMessage();
rmw.AccountPlanId = '';   
}
}
return rmw;
} */
    
    //This method is used to sync the Salesforce Overview section on account Plan automatically everytime Account Plan component is loaded       
    @AuraEnabled
    public static returnMessageWrapper syncAccountPlan(String accountplanId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        try{
            String successMessage = AccountPlanDataFetch.syncAccountPlanMethod(accountplanId);  
            if(successMessage == 'SUCCESS'){
                rmw.MessageType = 'SUCCESS';
                rmw.Message = 'Account Plan have been synced successfully!';
                
            }
            else{
                rmw.MessageType = 'ERROR';
                rmw.Message = 'Some error occured while fetching latest Salesforce Overview details.Please contact system admin';
            }
        }catch(Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
            rmw.AccountPlanId = '';  
        }
        
        //Commented as part of 
        
        //Changed as part of Account Plan Phase 4
        /*returnMessageWrapper rmw = new returnMessageWrapper();

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

try{

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

/*  if(caseList.size() > 0){
Integer noOfCase  = 0;
Integer totalCaselastyear = 0; 

for(Case o : caseList){
if(!o.status.contains('Close')){
noOfCase = noOfCase+ 1;          
} 
if(o.createdDate > checklastyear){
totalCaselastyear = totalCaselastyear +1;
}
}
ap.Open_Cases__c = noOfCase;
ap.Cases_Last_12_Months_open_closed__c = totalCaselastyear;
}
else{
ap.Open_Cases__c = 0;
ap.Cases_Last_12_Months_open_closed__c = 0;
}*/
        
        /*    if(!caseList.isEmpty()){
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
rmw.MessageType = 'SUCCESS';
rmw.Message = 'Account Plan have been synced successfully!';
rmw.AccountPlanId = ap.id;




}catch(Exception ex){
rmw.MessageType = 'ERROR';
rmw.Message = ex.getMessage();
rmw.AccountPlanId = '';   
}*/
        
        return rmw;
    }
    
    //This method is used to update the Last Contacted Details on account Plan everytime its updated
    @AuraEnabled
    public static returnMessageWrapper  updateLastContactedDetails(String accountplanId){
        
        returnMessageWrapper rmw = new returnMessageWrapper();
        try{
            String successMessage = AccountPlanDataFetch.updateLastContactedDetailsMethod(accountplanId);  
            if(successMessage == 'SUCCESS'){
                rmw.MessageType = 'SUCCESS';
                rmw.Message = 'Last Contacted Details have been updated successfully!';
                
            }
            else{
                rmw.MessageType = 'ERROR';
                rmw.Message = 'Some error occured while updating Last Contacted Details.Please contact system admin';
            }
        }catch(Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
            rmw.AccountPlanId = '';  
        }
        return rmw;
        
    }
    //This method will call an approval process once Submit for Review button is pressed on Account Plan.    
    @AuraEnabled
    public static returnMessageWrapper callapproval(String accountplanId){
        returnMessageWrapper rmw = new returnMessageWrapper();
        // Create an approval request for the account
        try{
            Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(accountplanId);
            
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Account_Plan_Approval');
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            rmw.MessageType = 'SUCCESS';
            rmw.Message = 'The Account Plan is submitted for Approval';
            rmw.AccountPlanId = '';
        }catch(Exception ex){
            rmw.MessageType = 'ERROR';
            rmw.Message = ex.getMessage();
            rmw.AccountPlanId = '';
        }
        
        //  system.debug('result --> ' + result);
        return rmw;
    }
    
    //This method will save the image/screenshot added in History Trend/Contact Relation Screenshot as a CV.
    /* @AuraEnabled
public static returnMessageWrapper uploadFile(Id accountPlanId,String historyTrend, 
String contactRelationship,Boolean historyTrendUpdated, 
Boolean contactRelationshipUpdated){

returnMessageWrapper rmw = new returnMessageWrapper();
try{
system.debug(historyTrend);
system.debug(contactRelationship);
Blob contactRelationshipImage;
Blob historyTrendImage;
if(!String.isBlank(historyTrend) && historyTrendUpdated==true){
historyTrendImage = getImageBlob(historyTrend,accountPlanId,'history');
}
if(!String.isBlank(contactRelationship) && contactRelationshipUpdated==true){
contactRelationshipImage= getImageBlob(contactRelationship,accountPlanId,'contactRelationship');
}
if(String.isBlank(contactRelationship) && contactRelationshipUpdated==true){
List<ContentDocumentLink> fileToDelete = [select id ,ContentDocument.title,LinkedEntityId,
ShareType from ContentDocumentLink WHERE
LinkedEntityId=:accountPlanId AND 
ContentDocument.title='ContactRelationshipScreenshot'];
if(fileToDelete.size()>0){
delete fileToDelete[0];
}
}
if(String.isBlank(historyTrend) && historyTrendUpdated==true){
List<ContentDocumentLink> fileToDelete = [select id ,ContentDocument.title,LinkedEntityId,
ShareType from ContentDocumentLink WHERE
LinkedEntityId=:accountPlanId AND 
ContentDocument.title='HistoryTrendScreenshot'];
if(fileToDelete.size()>0){
delete fileToDelete[0];
}
}
if(historyTrendImage!=null){
String cdId ='';
List<ContentDocumentLink> cvlist = [SELECT Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=:accountPlanId and ContentDocument.Title='HistoryTrendScreenshot'];

if(cvlist.size() > 0){
cdId=cvlist[0].ContentDocumentId;
}
createVersions(historyTrendImage,'HistoryTrendScreenshot',accountPlanId,cdId);
}
if(contactRelationshipImage!=null){
String cdId ='';
List<ContentDocumentLink> cvlist = [SELECT Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=:accountPlanId and ContentDocument.Title='ContactRelationshipScreenshot'];

if(cvlist.size() > 0){
cdId=cvlist[0].ContentDocumentId;
}
createVersions(contactRelationshipImage,'ContactRelationshipScreenshot',accountPlanId,cdId);
}

rmw.MessageType = 'success';
}catch(Exception ex){
rmw.MessageType = 'ERROR';
rmw.Message = ex.getMessage();
rmw.AccountPlanId = '';
}
return rmw;
}

private static blob getImageBlob(String richTextValue,Id accountPlanId,String type){

String str = richTextValue.subStringBetween('"', '"' );
String target ='amp;';
String replacement ='';
String s2 = str.replace(target, replacement);
String base64Content = EncodingUtil.Base64Encode(Blob.valueOf( s2 ) );
Blob blobContent = EncodingUtil.base64Decode( base64Content );
String imageURL = blobContent.toString();
String decodedURL = imageURL.unescapeHtml4();
PageReference page = new PageReference( decodedURL );
Blob imageblob = page.getContent();

return imageblob;
}

private static void createVersions(Blob imageblob , String fileName, Id accountPlanId ,String cdId){
ContentVersion cv = new ContentVersion();
cv.ContentLocation = 'S';
cv.VersionData = imageblob;
cv.Title = fileName;
cv.PathOnClient = fileName + '.jpeg';
cv.SharingPrivacy = 'N' ;
cv.SharingOption = 'A';
cv.IsMajorVersion = true; 
if(cdId != null && cdId != ''){

cv.ContentDocumentId = cdId;  
} else{ 
cv.FirstPublishLocationId = accountPlanId;}

insert cv;
List<ContentDocumentLink> cdl =[select id , ShareType from ContentDocumentLink 
where ContentDocumentId=:cv.ContentDocumentId and 
LinkedEntityId=:accountPlanId];
if(cdl.size()>0){
cdl[0].ShareType ='I';
}
update cdl;   
}*/
    
    
    
    
    public class returnMessageWrapper{
        @AuraEnabled public String MessageType;
        @AuraEnabled public String Message;
        @AuraEnabled public String AccountPlanId;
        @AuraEnabled public String Status;
        //Change Added Account Plan Phase 4 Prachi SSE-21126
        @AuraEnabled public Boolean showGlobal;
        @AuraEnabled public Boolean showRegional;
        @AuraEnabled public String apType;
        @AuraEnabled public List<accountPlanList> apList;
        @AuraEnabled public Boolean globalAPExists;
        //SSE-21126 changes end 
    }
    
    
    public class accountPlanList{
        @AuraEnabled public String apName ;
        @AuraEnabled public String apURL ;
        @AuraEnabled public String apType; 
        @AuraEnabled public String apStatus;  
        @AuraEnabled public Date   nextReview ;
        
    }
    
    //Change End Account Plan Phase 4
}
public class MakePaymentContact{
  
    public String conid{get;set;} 
    public String accid{get;set;} 
    public String inputText3{get;set;} 
    public String inputText4{get;set;}
    public Id Cid;
    
    
    public MakePaymentContact(ApexPages.StandardController controller) {
       conid = ApexPages.currentPage().getParameters().get('id');
       
    }
    
       public PageReference createCase(){
           contact con = [select id,Account.CurrencyIsoCode,Name,FirstName,LastName,Mailing_Address_Line_1__c,Mailing_Address_Line_2__c,Mailing_Address_Line_3__c,Mailing_Address_Line_4__c,Mailing_City__c,Mailing_ZIP_Postal_Code__c,Mailing_Country__c,Mailing_State_County__c from CONTACT where id =:conid ];
           Map<String,String> countryAndCountryCodeMap = new Map<String,String>();
           for(Payment_case_country_mapping__mdt obj : [select id,Country_Code__c,Country_Name__c from Payment_case_country_mapping__mdt 
                                                        where Country_Name__c =: con.Mailing_Country__c]){
               countryAndCountryCodeMap.put(obj.Country_Name__c,obj.Country_Code__c);
           }
           Case c = new Case();
           c.RecordtypeId = '012D0000000V9YhIAK';
           c.Origin = 'Phone';
           c.ContactId = conid;           
           c.Subject = 'Invoice Payment - ';
           c.Call_Type__c = 'Invoice/Credit/Licence';
           c.Status = 'In Progress';
           c.Caller_Type__c = 'Customer';
           
           c.CurrencyIsoCode =  con.Account.CurrencyIsoCode;
           //c.Assigned_To__c = 'APAC Customer Success'; // Assigned To logic to be discussed
           //c.Case_Country__c = con.Mailing_Country__c;
           if(!countryAndCountryCodeMap.isEmpty() && countryAndCountryCodeMap.containsKey(con.Mailing_Country__c)){
               c.Case_Country__c = countryAndCountryCodeMap.get(con.Mailing_Country__c);//added by sanjeev
           }
           c.Description = 'NVM Case';      
           c.Problem2__c = 'Other';
           c.Solution__c = 'Other';
           
           c.Preferred_Language__c = 'English';
           c.Caller_s_Name__c = con.Name;        
           c.First_Name__c= con.FirstName;
           c.Last_Name__c= con.LastName;
           c.Building_Name__c= con.Mailing_Address_Line_1__c;    
           c.Street__c = (con.Mailing_Address_Line_2__c + ' ' + con.Mailing_Address_Line_3__c + ' ' + con.Mailing_Address_Line_4__c).remove('null');
           c.City_town__c= con.Mailing_City__c;
           c.Zip_Postal__c= con.Mailing_ZIP_Postal_Code__c;
           c.Country__c= con.Mailing_Country__c;
           c.State__c = con.Mailing_State_County__c;   
           
           insert c;
           
           
           if(c.id != NULL){
               PageReference nextPage = new PageReference('/' + c.id );
               //PageReference pageRef = new PageReference('http://www.google.com');
               nextPage.setRedirect(false);
               //return pageRef;
               return nextPage;
               
           }
           
           else{
               return null;
           }
       }
}
/**************************************************************************************************************************************
CREATED BY :- RISHABH KANOTRA
CREATED DATE :- 26-06-2019
DESCRIPTION :- This is a payment form to: 
               (1.Prepopulate the data from the Case record), 
               (2. Fetch data from the agent and pass on to the PCIPAL form.)
***************************************************************************************************************************************/ 

public class NVM_Payment_Form_Controller{
  
    public Boolean showpg{get;set;}
    public Boolean countryflag{get;set;}
    public Boolean showwar{get;set;}
    public Boolean shownoagent{get;set;}
    public Boolean samecont{get;set;}
    public String CallerNamestr{get;set;}
    public String Sunrefnovf{get;set;}
    public String reftypevf{get;set;}
    
    public String agentid{get;set;}
    public String CardType{get;set;}
    public String conFirstName{get;set;}
    public String conLastName{get;set;}
    public String buildingname{get;set;}
    public String street{get;set;}
    public String city{get;set;}
    public String zip{get;set;}
    public String country{get;set;}
    public String state{get;set;}
    public String acccurrency{get;set;}
    public Decimal accamount{get;set;}
    public String selectedCurrency{get;set;}
    public String selectedCountry{get;set;}
    public List<Account_Configuration__mdt> curList {get;set;}
    public List<Account_Configuration__mdt> availbu {get;set;}
    public List<KB_CaseCountryCodeAndAssignmentEmails__c> conList {get;set;}
    public List<String> curcode = new List<String>();
    public List<String> curname {get;set;}

    
    //public String inputText1{get;set;} 
    //public String inputText2{get;set;} 
    //public String inputText3{get;set;} 
    //public String inputText4{get;set;}
    public Id Cid;
    public Id Uid;
    public Case c;
    public User u;
    
    ApexPages.StandardController scn;
        
    public NVM_Payment_Form_Controller(ApexPages.StandardController controller) {       
        scn = controller;
        showpg=true;   
        countryflag=false;
        
       Uid =  UserInfo.getUserId();
       u =[SELECT id,NVMContactWorld__NVM_Agent_Id__c FROM USER WHERE id =:Uid LIMIT 1 ];
       //To disable page if user is not agent
       if(u.NVMContactWorld__NVM_Agent_Id__c == NULL){
           
            showpg=false;
            showwar=false;
            shownoagent=true;
       
       }
       agentid=u.NVMContactWorld__NVM_Agent_Id__c ;
    
       Cid = System.currentPagereference().getParameters().get('id');
       c = [Select id,Sun_Reference_No__c,Ref_Type__c,Account.name,Case_Country__c,Account.Account_Number__c,CurrencyIsoCode ,Contact.Email,Country__c,State__c,First_Name__c,Last_Name__c,Building_Name__c,Street__c,Status,City_town__c,Zip_Postal__c,Call_Type__c,Assigned_To__c  ,Account.BU__c, Account.CurrencyIsoCode,Contact.Mailing_ZIP_Postal_Code__c,Contact.Mailing_Country__c,Contact.Mailing_State_County__c,Contact.Mailing_City__c,contact.name,Contact.FirstName,Contact.LastName, contact.Mailing_Address_Line_1__c, contact.Mailing_Address_Line_2__c, contact.Mailing_Address_Line_3__c, contact.Mailing_Address_Line_4__c  from Case where id =: Cid];
        
       availbu =[select BU__c from Account_Configuration__mdt where BU__c =: c.Account.Bu__c ];
       system.debug('This is availbu**'+ availbu+availbu.isEmpty() );
        //code to disable button
            if( ( availbu.isEmpty()) || c.Status == 'Resolved/Closed' || c.Call_Type__c!='Invoice/Credit/Licence' || c.Assigned_To__c == NULL){
                showpg=false;
                showwar=true;
            }
        
        selectedCurrency = c.CurrencyIsoCode;
        selectedCountry = c.Case_Country__c;
        CallerNamestr = c.contact.name;
        Sunrefnovf = c.Sun_Reference_No__c;
        reftypevf = c.Ref_Type__c;
        
        samecont =True; // setting checkbox by default true
        
        if(samecont == True){
            conFirstName = c.First_Name__c;
            conLastName = c.Last_Name__c;
            buildingname= c.Building_Name__c;        
            street = c.Street__c;
            city = c.City_town__c;
            zip = c.Zip_Postal__c;
            country = c.Country__c;
            state = c.State__c;
            
        }
    
    }
    
    public pagereference CallWebService(){
        System.debug('hello');     
        String token; 
        NVM_PaymentController nv = new NVM_PaymentController();
        token = nv.PaymentGetToken(c);
        System.debug('**token ' + token);
        System.debug('**amount ' + accamount);
        
        if(countryflag==true){
        
        return null;
        
        
        }
        else{
        if(token != null && token != ''){
           System.debug('Starting PCI Session');
           System.debug('**Case ' + c.id);
           return(nv.StartPCISession(token,c,accamount,u));          
        }
        else{
            return null;
        }
        
        }
    }
    
    public void save(){
       
            c.Caller_s_Name__c = CallerNamestr;
            c.Ref_Type__c = reftypevf;
            c.Sun_Reference_No__c = Sunrefnovf;
            c.First_Name__c= conFirstName;
            c.Last_Name__c= conLastName;
            c.Building_Name__c= buildingname;
            c.Street__c = street;
            c.City_town__c= city;
            c.Zip_Postal__c= zip;
            c.Country__c= selectedCountry;
            c.State__c = state;       
            
            
            
            //PageReference nextPage = new PageReference('/apex/PaymentCardDetailsVF?amt='+accamount+ '&Cid=' + c.id + '&Ctype=' +  CardType );
            //return nextPage;
            
            System.debug('This is new currency'+ selectedCurrency);
            c.CurrencyIsoCode = selectedCurrency;
            c.Case_Country__c=selectedCountry;
            System.debug('This is new case currency'+ c.CurrencyIsoCode);
            
            
            System.debug('testselectedCountry***' + selectedCountry +'**state.length' + state.length());
            if(selectedCountry == 'USA' && state.length()!=2){
            
                System.debug('2testselectedCountry***' + selectedCountry +'**state.length' + state.length());
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter valid data'));  
                countryflag=true;
                //return null;
            
            }
            
            else{
                
                countryflag=false;
           
                update c;
               //scn.save();
                
               // c.CurrencyIsoCode = selectedCurrency;
                //update c;
            }
           // System.debug('**case ' + c);
           // return null;
            
      
    }
    
    public void changeconinfo(){
          System.debug('This is value of samecont' + samecont ); 
        if(samecont == False){
        
            System.debug('This is value of samecont2' + samecont );
            conFirstName = '';
            conLastName = '';
            buildingname= '';       
            street = '';
            city = '';
            zip = '';
            //country = '';
            state = '';
            
            
         }
         
         else if(samecont == True){
         
            conFirstName = c.First_Name__c;
            conLastName = c.Last_Name__c;
            buildingname= c.Building_Name__c;        
            street = c.Street__c;
            city = c.City_town__c;
            zip = c.Zip_Postal__c;
            //country = c.Country__c;
            state = c.State__c;
            
         }
    
    }
    
    
    public List<SelectOption> getCurrencyOption() {
        List<SelectOption> options = new List<SelectOption>();
        curList = [select BU__c, Currency__c,CurrencyNames__c from Account_Configuration__mdt where BU__c =:c.Account.BU__c];
        for(Account_Configuration__mdt acc : curList ) {
        
            //if(!curcode.contains(acc.Currency__c)){
            
                options.add(new SelectOption(acc.Currency__c,acc.CurrencyNames__c ));
               // curcode.add(acc.Currency__c);
            //}
        }
        return options;
    }
    
    public List<SelectOption> getCountryOption () {
        List<SelectOption> options = new List<SelectOption>();
        conList = [select Name,ISO3__c from KB_CaseCountryCodeAndAssignmentEmails__c where ISO3__c!= null ORDER BY Name];
        for(KB_CaseCountryCodeAndAssignmentEmails__c kbc: conList ) {
        
            //if(!curcode.contains(acc.Currency__c)){
            
                options.add(new SelectOption(kbc.ISO3__c,kbc.Name ));
               // curcode.add(acc.Currency__c);
            //}
        }
        return options;
    }

}
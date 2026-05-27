/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 26-06-2019
DESCRIPTION :- This is a web service form to: 
               1.Get access token, 
               2. Starts PCI session and show IframeUI in success case or show Error in case of Failure
***************************************************************************************************************************************/ 

global class NVM_PaymentController{

    public String ClientId;
    public String ClientSecret;   
    public String accessToken;
    public String GrantType;
    public String Scope;
    public String ReqBody;    
    
    public NVM_Keys__c key;
    public id uid;
    public User u;
    public String session_Guid{get;set;}
    public String agent_AccessToken{get;set;}
    public String agent_RefreshToken{get;set;}   
    public String Iframe_URL{get;set;} 
    public String ReqBody2;
        

    public NVM_PaymentController() {       
        key = NVM_Keys__c.getAll().values();
        Id uid = UserInfo.getUserId();
        System.debug('**UserId ' + uid);
        User u = [Select id,NVMContactWorld__NVM_Agent_Id__c from user where id =: uid];
        System.debug('**users ' + u);
        System.debug('**user ' + u.NVMContactWorld__NVM_Agent_Id__c );
    }
    
    public String PaymentGetToken(Case cse) {                          // Get Access/Beare Token
        Case c = cse;
        System.debug('**key ' + key.ClientId__c);
        ClientId = key.ClientId__c;
        ClientSecret = key.SecretId__c;
        GrantType = 'client_credentials';
        Scope = 'globalpci';       
        ReqBody = 'grant_type='+GrantType+'&client_id='+ClientId +'&client_secret='+ClientSecret+'&scope='+Scope;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        if(c.Account.BU__c == 'Canada - CA1' || c.Account.BU__c == 'US - US5'){
            req.setEndpoint(key.US_AuthenticationURL__c);
            System.debug('This is USA Token end***' + key.US_AuthenticationURL__c );
        }
        else{
            req.setEndpoint(key.AuthenticationURL__c);
            System.debug('This is UK Token end***' + key.AuthenticationURL__c);
        }
        req.setBody(reqbody);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        HttpResponse res = h.send(req);
        String responseStr = res.getBody();
        System.debug('**body ' + responseStr);
        Integer responseCode = res.getStatusCode();
        String responseStatus = res.getStatus();
        
        if (res.getStatusCode() == 200) {
         JSONParser parser = JSON.createParser(res.getBody()); 
             while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='access_token')){
                        parser.nextToken();
                        accessToken = parser.getText();
                    }                 
             }  
         }
         System.debug('**token ' + accessToken);
        return accessToken;  
    }
    
     public pageReference StartPCISession(string token, Case cse, Decimal amnt, User usr) {                          // 1.Build PCI Session/Connection 2.To get Iframe URL in response
       
        String BearerToken = token;  // Storing all parameters
        Case c = cse;
        Decimal amount = amnt;
        User u = usr;       
        
        System.debug('**case ' + c);
        System.debug('**agentid ' + u.NVMContactWorld__NVM_Agent_Id__c);
        
        // FORM JSON BODY
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();  
        gen.writeStringField('agentId', u.NVMContactWorld__NVM_Agent_Id__c);
        Account_Configuration__mdt AccMet=[select AccountConfigurationId__c,Currency__c,BU__c from Account_Configuration__mdt where BU__c=:c.Account.BU__c AND Currency__c=:c.CurrencyIsoCode limit 1]; 
        if(AccMet!=null || AccMet.AccountConfigurationId__c!=''){
            gen.writeNumberField('accountConfigurationId', Integer.Valueof(AccMet.AccountConfigurationId__c));  // form logic here. Pending
        }
        gen.writeFieldName('paymentData');
        gen.writeStartObject();      
        gen.writeStringField('transactionType','Capture');
        gen.writeStringField('merchantReferenceCode', c.id);
        if(Test.isRunningTest()){
          amount = 12;
        }
        gen.writeNumberField('grandTotalAmount', amount);        
        gen.writeStringField('currency',c.CurrencyIsoCode);     
        gen.writeStringField('billToFirstName', c.First_Name__c);
        gen.writeStringField('billToLastName', c.Last_Name__c);       
        gen.writeStringField('billToEmail', c.Contact.Email);
        gen.writeStringField('billToCompany', c.Account.name);
        gen.writeStringField('customerId', c.Account.Account_Number__c);
        gen.writeStringField('billToStreet1', c.Building_Name__c);
        gen.writeStringField('billToStreet2', c.Street__c);
        gen.writeStringField('billToCity', c.City_town__c);
        gen.writeStringField('billToPostalCode', c.Zip_Postal__c);            
        gen.writeStringField('billToState', c.State__c);
        gen.writeStringField('extraDataField1',c.Sun_Reference_No__c);
        gen.writeStringField('extraDataField2',c.Ref_Type__c);
        KB_CaseCountryCodeAndAssignmentEmails__c Kbcst = [Select ISO2__c,ISO3__c from KB_CaseCountryCodeAndAssignmentEmails__c where ISO3__c =:c.Case_Country__c limit 1];
        if(Kbcst!=null || Kbcst.ISO2__c!=''){
            gen.writeStringField('billToCountry', Kbcst.ISO2__c);
        }          
        gen.writeEndObject();
        gen.writeEndObject();
        ReqBody2 = gen.getAsString();
        
        System.debug('**PaymentData ' + ReqBody2);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        if(c.Account.BU__c == 'Canada - CA1' || c.Account.BU__c == 'US - US5'){
            req.setEndpoint(key.US_PCI_Service__c);
            System.debug('This is USA service end***' + key.US_PCI_Service__c);
        } 
        else{
            req.setEndpoint(key.PCI_Service__c);
            System.debug('This is UK service end***' + key.PCI_Service__c);
        }
        req.setHeader('Authorization', 'Bearer '+BearerToken);
        req.setHeader('Content-Type', 'application/json');   
        req.setBody(ReqBody2);
        HTTPResponse res = http.send(req);    
        
         if (res.getStatusCode() == 200) {
         JSONParser parser = JSON.createParser(res.getBody()); 
             while (parser.nextToken() != null) {
                     if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                         String fieldName = parser.getText();
                         parser.nextToken();
                         if (fieldName == 'sessionGuid') {
                             session_Guid = parser.getText();
                             System.debug('**session_Guid ' + session_Guid );
                         }
                         if (fieldName == 'agentAccessToken') {
                             agent_AccessToken = parser.getText();
                             System.debug('**agent_AccessToken ' + agent_AccessToken );
                         }
                         if (fieldName == 'agentRefreshToken') {
                             agent_RefreshToken = parser.getText();
                             System.debug('**agent_RefreshToken ' + agent_RefreshToken);
                         }
                         if (fieldName == 'iframeUrl') {
                             Iframe_URL = parser.getText();
                             System.debug('**Iframe_URL ' + Iframe_URL);
                         }
                     }                                             
             }  // while over
            // if((agent_AccessToken != null || agent_AccessToken !='')  && (agent_RefreshToken!= null || agent_RefreshToken !='')  && (Iframe_URL!=null || Iframe_URL!='')){
                 pageReference pg = new pageReference('/apex/NVM_PaymentControllerVF?tk='+agent_AccessToken+'&t='+BearerToken +'&rtk='+agent_RefreshToken+'&Iurl='+Iframe_URL+'&Sid='+session_Guid+'&Csid='+c.id+'&amt='+amount); //+'&Sid'=session_Guid
                 pg.setRedirect(true);                
            // }
             return pg;
            
         }
        
        else{
          //String error = response.body().string();        
          pageReference pg = new pageReference('/apex/NVM_ErrorPaymentControllerVF?err='+res.getBody()+' StatusCode: '+res.getStatusCode() + '&Csid='+c.id);
          pg.setRedirect(true); 
          return pg;
          
          // return null;
        }
     }
    
}
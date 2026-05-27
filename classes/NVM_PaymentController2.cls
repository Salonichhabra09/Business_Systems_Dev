/**************************************************************************************************************************************
CREATED BY :- PANKHURI JAIN
CREATED DATE :- 03-07-2019
DESCRIPTION :- Associated with NVM_PaymentControllerVF: 
               Functionality: To get Success and Failure Payment results and log those results into Case comments
***************************************************************************************************************************************/ 

global class NVM_PaymentController2{
    
    public String session_Guid{get;set;}
    public String agent_AccessToken{get;set;}
    public String agent_RefreshToken{get;set;}   
    public String Iframe_URL{get;set;}
    public String token;
    public NVM_Keys__c key; 
    public String SessionState;
    public String Decision;
    public String RequestId;
    public String ReasonCode;
    public String Cid;
    public String Amount;
    public Case cse;
    public boolean flag{get;set;}
    
    public NVM_PaymentController2() {  
        session_Guid= ApexPages.currentPage().getParameters().get('Sid');
        System.debug('**session_Guid1 ' + session_Guid );
        
        agent_AccessToken= ApexPages.currentPage().getParameters().get('tk');
        System.debug('**agent_AccessToken1 ' + agent_AccessToken );
        
        token = ApexPages.currentPage().getParameters().get('t');
        System.debug('**token1 ' + token );
        
        agent_RefreshToken= ApexPages.currentPage().getParameters().get('rtk');
        System.debug('**agent_RefreshToken1 ' + agent_RefreshToken);
        
        Iframe_URL= ApexPages.currentPage().getParameters().get('Iurl');
        System.debug('**Iframe_URL1 ' + Iframe_URL);
        
        Cid = ApexPages.currentPage().getParameters().get('Csid');
        System.debug('**CaseId ' + Cid);
        
        Amount= ApexPages.currentPage().getParameters().get('amt');
        System.debug('**Amount ' + session_Guid );
        
        key = NVM_Keys__c.getAll().values();
        cse = [Select id,Account.BU__c,First_Name__c,Last_Name__c,Status,currencyIsoCode from Case where id =: Cid];
    }
    
    public void PaymentStatus(){
        flag = true;
        System.debug('**PaymentEnter');
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        if(cse.Account.BU__c == 'Canada - CA1' || cse.Account.BU__c == 'US - US5'){
            req.setEndpoint(key.US_PCI_Service__c + '/' + session_Guid);
            System.debug('This is USA service end2***' + key.US_PCI_Service__c );
        }
        else{
            req.setEndpoint(key.PCI_Service__c + '/' + session_Guid);
            System.debug('This is UK service end2***' + key.PCI_Service__c );
        }
        req.setHeader('Authorization', 'Bearer '+ token);                 
        HTTPResponse res = http.send(req); 
        
         if (res.getStatusCode() == 200) {
        // JSONParser parser = JSON.createParser(res.getBody()); 
         String jsonbody= res.getBody();
         System.debug('**jsonbody' + jsonbody);
            /* while (parser.nextToken() != null) {
                     if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                         String fieldName = parser.getText();
                         parser.nextToken();
                         if (fieldName == 'sessionState') {
                             SessionState = parser.getText();
                             System.debug('**SessionState ' + SessionState);
                         }
                         if (fieldName == 'paymentResultData') {
                             Decision= parser.getText();
                             System.debug('**Decision ' + Decision);
                         }
                     } 
            } */
            if(jsonbody.contains('decision')){
                Decision = jsonbody.substringBetween('"decision":"','",');
                System.debug('**Decision' + Decision);
            }
            if(jsonbody.contains('sessionState')){
                SessionState = jsonbody.substringBetween('"sessionState":"','"');
                System.debug('**SessionState' + SessionState);
            } 
            if(jsonbody.contains('requestID')){
                RequestId = jsonbody.substringBetween('"requestID":"','",');
                System.debug('**RequestId' + RequestId);
            } 
            if(jsonbody.contains('reasonCode')){
                ReasonCode = jsonbody.substringBetween('"reasonCode":"','",');
                System.debug('**ReasonCode ' + ReasonCode);
            } 
        }
        
        if(SessionState == 'Finished' && Decision == 'ACCEPT'){
            System.debug('**comments ');
            CaseComment cm = new CaseComment();   
            DateTime dt = System.now();   
            cm.commentbody = '\n' + 'Payment Details of Customer:' + '\n' + '\n'+ 'Customer Name:   ' + cse.First_Name__c + ' '+ cse.Last_Name__c + '\n' + 'Amount Paid:   ' + Amount + ' ' +cse.currencyIsoCode +
                         '\n' + 'TransactionId:   ' + RequestId + '\n' + 'Payment DateTime:   ' + dt + '\n' + 'Payment Status:  Success '+ ' '+ Decision + '\n' + 'Session Status:   ' +  SessionState + '\n' + 'ReasonCode:   ' + ReasonCode;
            cm.ParentId = cse.id;
            insert cm;           
            cse.status = 'Resolved/Closed';
            update cse;
            flag = false;
        }
        else{
         if(SessionState == 'InProgress'){
            flag = true;
            //PaymentStatus();
           System.debug('**IN PROGRESS');       
         }
         else if((SessionState == 'Error' || SessionState == 'Timeout' || SessionState == 'ExpiredOnProviderSide') || (SessionState == 'Finished' && (Decision != 'ACCEPT' || Decision !=null))){
            System.debug('**Error ');
            CaseComment cm = new CaseComment();    
            DateTime dt = System.now();   
            cm.commentbody = '\n' + 'Payment Details of Customer:' + '\n' + '\n'+ 'Customer Name:   ' + cse.First_Name__c + ' '+ cse.Last_Name__c + '\n' + 'Amount Paid:   ' + Amount + ' ' +cse.currencyIsoCode +
                         '\n' + 'TransactionId:   ' + RequestId + '\n' + 'Payment DateTime:   ' + dt + '\n' + 'Payment Status: Failure'  + ' '+ Decision + '\n' + 'Session Status:   ' +  SessionState + '\n' + 'ReasonCode:   ' + ReasonCode;
            cm.ParentId = cse.id;
            insert cm;
            flag = false;   
          }        
        } 
        // else for failure                 
    }// method over
}
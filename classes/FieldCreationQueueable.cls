public class FieldCreationQueueable implements Queueable, Database.AllowsCallouts {
    
    public String jsonData;
    public static final String TOKEN_ENDPOINT = URL.getOrgDomainURL().toExternalForm() + '/services/oauth2/token';

    public FieldCreationQueueable(String json) {
        this.jsonData = json;
    }
    
    public void execute(QueueableContext context) {
        
        OAuthResponse wrapper = getAccessToken();
        //if(!Test.isRunningTest()){
            FieldCreationController.fieldDataList(jsonData, wrapper.access_token);
        //}
    }
    
    public class OAuthResponse {
        public String access_token;
        public String instance_url;
        public String id;
        public String token_type;
        public String issued_at;
        public String signature;
    }

    public static OAuthResponse getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		
        Metadata_API_Setting__c setting = Metadata_API_Setting__c.getValues('Metadata');
    
		String CLIENT_ID = setting.Consumer_Key__c;
        String CLIENT_SECRET = setting.Consumer_Secret__c;
        System.debug('CLIENT_ID '+CLIENT_ID);
        System.debug('CLIENT_SECRET '+CLIENT_SECRET);
        String body = 'grant_type=client_credentials' +
                      '&client_id=' + CLIENT_ID +
                      '&client_secret=' + CLIENT_SECRET;

        req.setBody(body);

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
            System.debug('response '+res.getBody());
            if (res.getStatusCode() == 200) {
                OAuthResponse oauthResponse = (OAuthResponse) JSON.deserialize(res.getBody(), OAuthResponse.class);
                return oauthResponse;
            } else {
                System.debug('Error: ' + res.getStatus());
                System.debug('Response: ' + res.getBody());
                return null;
            } 
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }
    
    public class ResponseWrapper{
        String access_token;
        String instance_url;
        String token_type;
    }
    
}
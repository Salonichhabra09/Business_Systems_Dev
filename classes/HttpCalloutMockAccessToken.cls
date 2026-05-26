@isTest
public class HttpCalloutMockAccessToken implements HttpCalloutMock {
    // Implement the respond method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a new HTTPResponse object
        HttpResponse res = new HttpResponse();
        
        // Set the status code and body to simulate a successful OAuth response
        res.setStatusCode(200);
        res.setBody('{"access_token": "abc123", "token_type": "Bearer", "expires_in": 3600}');
        
        return res;
    }
}
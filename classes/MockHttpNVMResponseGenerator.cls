@isTest
global class MockHttpNVMResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {     
        // Create a fake response
        if (req.getEndpoint().endsWith('123')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"sessionGuid":"8692db6d-16d6-4dcc-b2d4-9fb474871fec", "paymentResultData": { "reasonCode":"102", "decision":"ACCEPT", "requestID":"5625563206446933104060","billToStreet1":"1"},"providerSessionGuid":"d2a9ac3d-d458-4108-bcc6-bdf313d5712d","sessionState":"Finished"}');
            res.setStatusCode(200);
            return res;
        }
        else if (req.getEndpoint().endsWith('234')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"sessionGuid":"8692db6d-16d6-4dcc-b2d4-9fb474871fec", "paymentResultData": { "reasonCode":"102", "decision":"ACCEPT", "requestID":"5625563206446933104060","billToStreet1":"1"},"providerSessionGuid":"d2a9ac3d-d458-4108-bcc6-bdf313d5712d","sessionState":"Error"}');
            res.setStatusCode(200);
            return res;
        }
        else{
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkxwZXhESmVNR0VFVHVLTUJxNUFKbXc4dEIyQSIsImtpZCI6IkxwZXhESmVNR0VFVHVLTUJxNUFKbXc4dEIyQSJ9.eyJpc3MiOiJodHRwczovL2VtZWEubmV3dm9pY2VtZWRpYS5jb20vQXV0aCIsImF1ZCI6Imh0dHBzOi8vZW1lYS5uZXd2b2ljZW1lZGlhLmNvbS9BdXRoL3Jlc291cmNlcyIsImV4cCI6MTU2MjkzNTI4NCwibmJmIjoxNTYyOTI4MDg0LCJjbGllbnRfaWQiOiJlYzlhMDRlZi00ZDNhLTQzMzctYWMxNi1iZDdhM2Y3MzQxOTciLCJBY2NvdW50SWQiOiIzMzI0NCIsIkFjY291bnQiOiJTSExTQiIsInNjb3BlIjoiZ2xvYmFscGNpIn0.brJxS0byasv6LiPsNKAesyIajShCvi8CPPuTSK06OXK9h-4-4sK4AnQ_6RcdccS1sGuisOQe2s3tXKnGxGzIIZ1rgKuLxqtx4qBW8bGFLFMKXbj8c0X-IcbINyxR9qt5DkLE09ficv-5F6alp0QGAqudvS3eC_tHAv4s-_wbcFBhIWvChnihn-gJcDjifX0HU8eg8mFG-_Fr0qDHhJ-dNUSZFQ3UzR5QqPDASrZX82RcXy1BzAZ_RelNt1GgrIRuRqGq4TbMuJ2YCyFpaTd82sRER4hjsCwqbXu4Y3GRm9xy06HyiBTyD_HmUqdIbefkudCbNlyzmjABDEtNsaeIrg","expires_in": 7200,"token_type": "Bearer"}');
            res.setStatusCode(200);
            return res;
        }
    }
}
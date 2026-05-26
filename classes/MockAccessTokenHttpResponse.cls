@isTest
global class MockAccessTokenHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        
        public MockAccessTokenHttpResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            //res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }
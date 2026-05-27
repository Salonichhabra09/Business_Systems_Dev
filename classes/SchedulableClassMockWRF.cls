@isTest
global class SchedulableClassMockWRF implements HttpCalloutMock{
    Integer numberRecordsProcessed;
    Integer numberRecordsFailed;
    String responseBody;
    
    global SchedulableClassMockWRF(Integer numberRecordsProcessed, Integer numberRecordsFailed, String responseBody){
        this.numberRecordsFailed = numberRecordsFailed;
        this.numberRecordsProcessed = numberRecordsProcessed;
        this.responseBody = responseBody;
    }
    
    global HTTPResponse respond(HTTPRequest request) {
        Work_Request__c wr = [SELECT Id FROM Work_Request__c LIMIT 1];
        HttpResponse response = new HttpResponse();
        String endpoint = request.getEndpoint();
        response.setStatusCode(200);
        if(numberRecordsFailed > 0){
            response.setBody(responseBody);
        }else{
            response.setBody(responseBody);
        }
        return response;
    }
}
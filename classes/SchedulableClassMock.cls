@isTest
global class SchedulableClassMock implements HttpCalloutMock{
    Integer numberRecordsProcessed;
    Integer numberRecordsFailed;
    String responseBody;
    
    global SchedulableClassMock(Integer numberRecordsProcessed, Integer numberRecordsFailed, String responseBody){
        this.numberRecordsFailed = numberRecordsFailed;
        this.numberRecordsProcessed = numberRecordsProcessed;
        this.responseBody = responseBody;
    }
    
    global HTTPResponse respond(HTTPRequest request) {
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c LIMIT 1];
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
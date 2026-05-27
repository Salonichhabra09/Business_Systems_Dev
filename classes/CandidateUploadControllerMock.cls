@isTest
global class CandidateUploadControllerMock implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest request) {
        Job__c jobObj = [SELECT Id, MS_Line_of_Business__c FROM Job__c WHERE Candidate_Username_Prefix__c = 'QA01' LIMIT 1];
        System.debug('jobObj Id ####'+jobObj);
        HttpResponse response = new HttpResponse();
        String endpoint = request.getEndpoint();
        response.setStatusCode(200);
        response.setBody('{"id":"'+jobObj.id+'","state":"JobComplete"}');
        return response;
    }
}
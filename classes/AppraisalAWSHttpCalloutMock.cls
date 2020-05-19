@isTest
global class AppraisalAWSHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global static HTTPResponse respond(HTTPRequest request) {
        // Create a mock response
        HttpResponse res = null;
        res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //res.setBody('{}');
        res.setStatusCode(200);
        
        return res;
    }
}
@isTest
global class UnisonAPIErrorHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global static HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{ "message": "error" }');
        response.setStatusCode(500);
        return response; 
    }
}
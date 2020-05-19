global class DelightedMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse resp = new HTTPResponse();
        resp.setBody('{ ' +
                      '"id": "1", ' +
                      '"email": "Test.Test923078@example.com", ' +
                      '"name": null, ' +
                      '"survey_scheduled_at": 1553190539 ' +
                    '}');
        resp.setStatusCode(200);
        return resp;
    }
    
}
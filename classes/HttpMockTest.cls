/**
 * Created by Ivan Garcia on 5/6/2019.
 */
@IsTest global class HttpMockTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"test"}');
        res.setStatusCode(200);
        return res;
    }
}
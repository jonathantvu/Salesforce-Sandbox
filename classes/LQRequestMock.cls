@isTest
public class LQRequestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{"":{"status_code":0,"status_description":"OK"}}');
            return resp;
        }
}
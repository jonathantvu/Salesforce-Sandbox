@isTest
global class UnisonAPIHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global static HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'text/xml');
        response.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><notificationsResponse xmlns="http://soap.sforce.com/2005/09/outbound"><Ack>true</Ack></notificationsResponse></soapenv:Body></soapenv:Envelope>');
        response.setStatusCode(200);
        return response; 
    }
}
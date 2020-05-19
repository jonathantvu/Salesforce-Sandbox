@isTest
global class UnisonRequirementUpsertHttpCalloutMock implements HttpCalloutMock {
    global static HTTPResponse respond(HTTPRequest request) {
		RequirementToAWSEndpoint__mdt AwsEndpointSetting = [SELECT X_API_Key__c, AWSEndpoint__c FROM RequirementToAWSEndpoint__mdt LIMIT 1];

        System.assertEquals(AwsEndpointSetting.AWSEndpoint__c, request.getEndpoint());
        System.assertEquals(AwsEndpointSetting.X_API_Key__c, request.getHeader('x-api-key'));
        //System.assertEquals('application/json', request.getHeader('Content-Type'));
        System.assertEquals('POST', request.getMethod());

        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(request.getBody());
        response.setStatusCode(200);
        return response;
    }
}
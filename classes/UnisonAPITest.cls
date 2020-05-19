@isTest
private class UnisonAPITest {
    @isTest static  void testFutureSendMRDUpsert() {
        Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock()); 
        
        Test.startTest();
        UnisonAPI.fSendMRDUpsert('mrdId');
        Test.stopTest();
    }
    
    @isTest static void testSendMRDUpsert() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new UnisonAPIHttpCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = UnisonAPI.SendMRDUpsert('mrdId');
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'text/xml');
        String actualValue = response.getBody();
        System.debug(response.getBody());
        String expectedValue = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><notificationsResponse xmlns="http://soap.sforce.com/2005/09/outbound"><Ack>true</Ack></notificationsResponse></soapenv:Body></soapenv:Envelope>';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, response.getStatusCode());
    }
    
    @isTest static void testSendMRDUpsertError() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new UnisonAPIErrorHttpCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        
        HttpResponse response = UnisonAPIErrorHttpCalloutMock.respond(new HTTPRequest());
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assertEquals('application/json',contentType);
        String actualValue = response.getBody();
        System.debug(response.getBody());
        String expectedValue = '{ "message": "error" }';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(500, response.getStatusCode());
    }   
    
    @isTest static  void testFutureSendRequirementUpsert() {
        Test.setMock(HttpCalloutMock.class, new UnisonRequirementUpsertHttpCalloutMock()); 
        
        /*List<Current_Conditions__c> data = new List<Current_Conditions__c>();
        Current_Conditions__c req = new Current_Conditions__c();
        //req.id = '1';
        data.add(req);*/
                    Account acc = new Account();
             acc.Name = 'test';
             insert acc;
             Opportunity opp = new Opportunity();
             opp.Name = 'test';
             opp.AccountId = acc.Id;
             opp.StageName = 'Submit to Ops';
             opp.CloseDate = system.today();
             insert opp;
             Success_Factor__c sf = new Success_Factor__c();
             sf.Status__c = 'In Progress';             
             insert sf;
             List<Current_Conditions__c> data = new List<Current_Conditions__c>();
             Current_Conditions__c req = new Current_Conditions__c();
             req.Opportunity__c = opp.Id;
             req.Code__c = 'R1002';
             req.Requirement__c = '1099';
             //req.Success_Factor_Type__c 'OAV';
             req.Success_Factor__c = sf.Id;
             data.add(req);
        Test.startTest();
          UnisonAPI.SendRequirementUpsert(data);
        Test.stopTest();
    }

    @isTest static void testSendRequirementUpsert() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new UnisonRequirementUpsertHttpCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        String expectedValue = '[{"foo":"bar"}]';
        HttpResponse response = UnisonAPI.SendRequirementUpsertRequest(expectedValue);
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        System.debug(response.getBody());
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, response.getStatusCode());
    }
        
    @isTest static void testSendRequirementUpsertError() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new UnisonAPIErrorHttpCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = UnisonAPI.SendRequirementUpsertRequest('{}');
        // Verify that the response received contains fake values
        System.assertEquals(500, response.getStatusCode());
    }   

    @isTest static  void testFutureSendDocumentUpsert() {
        Test.setMock(HttpCalloutMock.class, new UnisonDocumentUpsertHttpCalloutMock()); 
        
        List<Document_MetaData__c> data = new List<Document_MetaData__c>();
        Document_MetaData__c doc = new Document_MetaData__c();
        //doc.id = '1';
        data.add(doc);
        
        Test.startTest();
        UnisonAPI.SendDocumentUpsert(data);
        Test.stopTest();
    }

    @isTest static void testSendDocumentUpsert() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new UnisonDocumentUpsertHttpCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        String expectedValue = '[{"foo":"bar"}]';
        HttpResponse response = UnisonAPI.SendDocumentUpsertRequest(expectedValue);
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        System.debug(response.getBody());
        //System.assertEquals(actualValue, expectedValue);
        //System.assertEquals(200, response.getStatusCode());
    }
        
    @isTest static void testSendDocumentUpsertError() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new UnisonAPIErrorHttpCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = UnisonAPI.SendDocumentUpsertRequest('{}');
        // Verify that the response received contains fake values
        System.assertEquals(500, response.getStatusCode());
    }   
}
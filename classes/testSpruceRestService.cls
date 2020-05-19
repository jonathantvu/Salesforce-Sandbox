@isTest
public class testSpruceRestService {
        @testSetup static void setup(){
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
                AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
                AccountID = acc.Id);
        insert con2;

        /* 4/2/2019 Sundar Subramaniam - Is_there_Co_App__c removed from query for Data Model Cleanup */
        Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting',
                CloseDate = Date.today().addDays(20), Applicant__c = con.Id,Property_Type__c = '2-4 Family',Probability = 90,
                Co_Applicant__c = con2.Id,Encompass_Loan_Number__c = '10',Final_OAV_Calculation__c=100,Lien_First_Lender_Balance__c = 100);
        insert oppty;
            
            Property__c newprop = new Property__c();
            newprop.Name = 'Test';
            newprop.Property_Type__c = '2-4 Family';
            newprop.Build_Year__c = '2019';
            newprop.Property_New_Construction_Flag__c = True;
            newprop.Property_Street_Number_and_Name__c = 'test asd 123';
            newprop.Property_City__c = 'test asd 123';
            newprop.Property_State__c = 'CA';
            newprop.Property_Zip_Code__c = '12345';
            newprop.Property_County__c = 'test asd 123';
            newprop.Opportunity__c=oppty.Id;
            insert newprop;
            
            Property_Due_Diligence_Reports__c spruceOrder = new Property_Due_Diligence_Reports__c();
            spruceOrder.RecordTypeId = Schema.SObjectType.Property_Due_Diligence_Reports__c.getRecordTypeInfosByName().get(Label.Property_Due_Diligence_Rep_RT_Spruce).getRecordTypeId();
            spruceOrder.Spruce_Order_Id__c = '114360001409';
            spruceOrder.Opportunity__c = oppty.Id;
            insert spruceOrder;
    }
    /*
    @IsTest
    public class MockGetToken implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            Property__c newprop = [SELECT id FROM Property__c LIMIT 1];

            System.debug('newprop'+newprop);
              
            String mockResponseBody = '{"order":{ "order_status": "Ok","order": {"id": "'+spruceOrder.Id+'","order_status": "Ok"}}}';
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(mockResponseBody);

            return res;            
        }
    }*/
    @IsTest
    public static void testrest(){
        
        Property__c newprop = [SELECT id FROM Property__c LIMIT 1];
        System.debug('newprop'+newprop);
        String JSONMsg = '{ "event_id": "35e8609c-7ce4-43fd-9b43-61c0d9ebd1a8","event": "order_status_changed","timestamp": "2019-04-04T14:16:23Z","payload": {"file_number": "114360001409","order_id": "33048c21-3fd8-4182-8b06-1157f6b07979","status": "initial_docs_available"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/SpruceRS/*';
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('apikey', +System.Label.Spruce_Header);
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        String returndopost =SpruceRestService.doPost();
        Test.stopTest();
    }
    @IsTest
    public static void testrest2(){
        
        Property__c newprop = [SELECT id FROM Property__c LIMIT 1];
        System.debug('newprop'+newprop);
        String JSONMsg = '{ "event_id": "35e8609c-7ce4-43fd-9b43-61c0d9ebd1a8","event": "order_status_changed","timestamp": "2019-04-04T14:16:23Z","payload": {"file_number": "null","order_id": "33048c21-3fd8-4182-8b06-1157f6b07979","status": "initial_docs_available"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/SpruceRS/*';
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('apikey', +System.Label.Spruce_Header);
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        String returndopost =SpruceRestService.doPost();
        Test.stopTest();
    }
    
    @IsTest
    public static void testrest3(){
        
        Property__c newprop = [SELECT id FROM Property__c LIMIT 1];
        System.debug('newprop'+newprop);
        String JSONMsg = '{ "event1": "order_status_changed","timestamp": "2019-04-04T14:16:23Z","payloadtest": {"order_id": "33048c21-3fd8-4182-8b06-1157f6b07979","status": "initial_docs_available"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/SpruceRS/*';
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('apikey', +System.Label.Spruce_Header);
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        String returndopost =SpruceRestService.doPost();
        SpruceRestService.RequestWrapper rw = new SpruceRestService.RequestWrapper();
        rw.event_id = '35e8609c-7ce4-43fd-9b43-61c0d9ebd1a8';
        System.assertequals(rw.event_id,'35e8609c-7ce4-43fd-9b43-61c0d9ebd1a8');
        Test.stopTest();
    } 
    
}
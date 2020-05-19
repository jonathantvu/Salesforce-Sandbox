@isTest
public class GreenLightTest {
    
    public class MockClass implements HttpCalloutMock {
    
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse resp = new HTTPResponse();
            if (req.getEndpoint().contains('api/v3/inquiries')) {
                resp.setBody('{ ' +
                                '"inquiry_id": "test276834", ' +
                                '"inquiry_sequence_id": "test276835", ' +
                                '"decision": "approved", ' +
                                '"program": { ' +
                                    '"Pricing_Ratio__c": 4 ' +
                                '}, ' +  
                                '"notes": { ' +
                                    '"greenlight":{  ' +  
                                    	'"finalNotes":"Approved as HomeOwner, Owner-Occupied, Not New Construction."' +                             
                                	'} ' +                                
                                '}, ' +                                
                                '"property": { ' +
                                    '"cl_property_id": "test276836" ' +
                                '} ' +
                            '}');
            }
            resp.setStatusCode(200);
            return resp;
        }

    }
    
    public static testMethod void TestSendInquiry_Post() {
        
        // Data setup
        Lead le1 = new Lead();
        le1.LastName = 'Test937153';
        le1.Status = 'Pending Qualification';
        le1.Company = 'Test983729';
		le1.Income_Monthly_Base__c  = 6000;
		le1.Home_Value__c =100000;        
        insert le1;

        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        // Run the code
        Test.startTest();

        GreenLightHelper.SendInquiry(le1.Id);
        Lead le2 = [SELECT Greenlight_Id__c, Inquiry_Sequence_ID__c FROM Lead WHERE Id = :le1.Id];

        Test.stopTest();
        
        // Verify Results
        System.assertEquals('test276834', le2.Greenlight_Id__c);
        System.assertEquals('test276835', le2.Inquiry_Sequence_ID__c);
        if (GreenLightAPI.Settings.Save_Logs__c)
            System.assertEquals(1, [SELECT COUNT() FROM GreenLight_API_Log__c]);
        
    }

    public static testMethod void TestSendInquiry_Put() {
        
        // Data setup
        Lead le1 = new Lead();
        le1.LastName = 'Test937153';
        le1.Status = 'Pending Qualification';
        le1.Company = 'Test983729';
        le1.Greenlight_Id__c = 'test276834';
        le1.Inquiry_Sequence_ID__c = 'test276835';
		le1.Income_Monthly_Base__c  = 6000;
		le1.Home_Value__c =100000;            
        insert le1;

        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        // Run the code
        Test.startTest();

        GreenLightHelper.SendInquiry(le1.Id);
        Lead le2 = [SELECT Property_Pre_Qualification_Status__c FROM Lead WHERE Id = :le1.Id];

        Test.stopTest();
        
        // Verify Results
        System.assertEquals('Approved', le2.Property_Pre_Qualification_Status__c);
        if (GreenLightAPI.Settings.Save_Logs__c)
            System.assertEquals(1, [SELECT COUNT() FROM GreenLight_API_Log__c]);
        
    }

}
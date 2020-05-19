@isTest
public class TuneIntegrationTest {

    public class MockHttpResponse implements HttpCalloutMock {
    	public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('Success');
            res.setStatusCode(200);
            return res;
        }
    }

    public static testMethod void TestLeadInsert() {
        
        // Data setup
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        l.Tune_Transaction_Id__c = 'test283862';
        l.Tune_Offer_Id__c = '4';
        l.LastName = 'Tst918236';
        l.Company = 'Tst983273';
        l.Status = 'Pending Qualification';
        
		// Run the code
		Test.startTest();
		
		insert l;
        
		Test.stopTest();
		
		// Verify Results
		System.assertEquals(1, [SELECT COUNT() FROM Tune_Integration_Log__c]);
        
    }
    
    public static testMethod void TestLeadUpdate() {
        
        // Data setup
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        l.Tune_Transaction_Id__c = 'test283862';
        l.Tune_Offer_Id__c = '4';
        l.LastName = 'Test918236';
        l.Company = 'Test983273';
		insert l;
        
		// Run the code
		Test.startTest();
		
        LeadTriggerHandlerPC.tunedIds = new Set<Id>();
        l.Credit_Pre_Qualification_Status__c = 'Approved';
        l.Property_Pre_Qualification_Status__c = 'Approved';
        update l;
        
		Test.stopTest();
		
		// Verify Results
		System.assertEquals(2, [SELECT COUNT() FROM Tune_Integration_Log__c]);
        
    }
    
    public static testMethod void TestOpportunity() {
        
        // Data setup
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Opportunity o = new Opportunity();
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomeOwner').getRecordTypeId();
        o.Tune_Transaction_Id__c = 'test283862';
        o.Tune_Offer_Id__c = '4';
        o.Name = 'Test387263';
        o.StageName = 'Ready for Ops';
        o.CloseDate = Date.today();
		insert o;
        
		// Run the code
		Test.startTest();
        
        o.Wire_to_Agent_Date__c = Date.today();
        update o;
		
		Test.stopTest();
		
		// Verify Results
		System.assertEquals(1, [SELECT COUNT() FROM Tune_Integration_Log__c]);
        
    }
    
}
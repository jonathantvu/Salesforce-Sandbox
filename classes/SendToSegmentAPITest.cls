@isTest
public class SendToSegmentAPITest {
    
    @isTest
	public static void TestSuccess(){
        // Data setup
		Lead l = new Lead();
        l.LastName = 'Test 686483';
        l.Company = 'test 286830';
        insert l;

        Deal_Stage_Tracker__c dst = new Deal_Stage_Tracker__c();
        dst.Lead__c = l.Id;
        dst.Event_Name__c = 'Registration';
        insert dst;
		
        Test.setMock(HttpCalloutMock.class, new SegmentAPIMock());

		// Run the code
		Test.startTest();
        SendToSegmentAPI ctrl = new SendToSegmentAPI(new ApexPages.StandardController(dst));
        ctrl.Send();
        ctrl.GoBack();
		Test.stopTest();
		
		// Verify Results
		dst = [SELECT Id, Segment_Integration_Status__c FROM Deal_Stage_Tracker__c WHERE Id = :dst.Id];
        System.assertEquals('Success', dst.Segment_Integration_Status__c);
    }

    @isTest
	public static void TestError(){
        // Data setup
		Lead l = new Lead();
        l.LastName = 'Test 686483';
        l.Company = 'test 286830';
        insert l;

        Deal_Stage_Tracker__c dst = new Deal_Stage_Tracker__c();
        dst.Lead__c = l.Id;
        dst.Event_Name__c = 'Registration';
        
        Test.setMock(HttpCalloutMock.class, new SegmentAPIMock());

		// Run the code
		Test.startTest();
        SendToSegmentAPI ctrl = new SendToSegmentAPI(new ApexPages.StandardController(dst));
        ctrl.Send();
        ctrl.GoBack();
		Test.stopTest();
		
		// Verify Results
        System.assertEquals(ApexPages.Severity.ERROR, Apexpages.getMessages().get(0).getSeverity());
    }
}
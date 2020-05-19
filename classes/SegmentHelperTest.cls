@isTest
public with sharing class SegmentHelperTest {
 //VK - Commented out the code for BUS-155110189 
    @isTest
	public static void Test1(){
		
		// Data setup
		Lead l = new Lead();
        l.LastName = 'Name 686483';
        l.FirstName = 'Name 686487';
        l.Company = 'Name 286830';
        insert l;

        Deal_Stage_Tracker__c dst = new Deal_Stage_Tracker__c();
        dst.Lead__c = l.Id;
        dst.Event_Name__c = 'Registration';
        insert dst;
        
           Deal_Stage_Tracker__c dst1 = new Deal_Stage_Tracker__c();
        dst1.Lead__c = l.Id;
        dst1.Event_Name__c = 'Test Registration';
        insert dst1;
		
        Set<ID> dstIDs =  new Set<ID>();
        dstIDs.add(dst.ID);
        dstIDs.add(dst1.ID);
        
        
        Test.setMock(HttpCalloutMock.class, new SegmentAPIMock());

		// Run the code
		Test.startTest();
		SegmentHelper.Track(dst.Id);
        SegmentHelper.Track(dstIDs);
		Test.stopTest();
		
		// Verify Results
		//dst = [SELECT Id, Segment_Integration_Status__c FROM Deal_Stage_Tracker__c WHERE Id = :dst.Id];
        //System.assertEquals('Success', dst.Segment_Integration_Status__c);
	}
}
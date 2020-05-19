@isTest
public class DelightedScheduledBatchTest {

    @isTest
	public static void TestLead() {
		
		// Data setup
		Lead l = new Lead();
        l.FirstName = 'RealFirstName';
        l.LastName = 'RealLastName923078';
        l.Email = 'AnEmail.email923078@example.com';
        l.Company = 'Company923078';
        l.Campaign_Source__c = 'web';
        insert l;
        
        Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
        npm.Status__c = 'Draft';
        npm.Lead__c = l.Id;
        insert npm;
        
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
		
		// Run the code
		Test.startTest();
		(new DelightedScheduledBatch()).execute(null);
		Test.stopTest();
		
		// Verify Results
        System.assertEquals(1, [SELECT COUNT() FROM Net_Promoter_Measurement__c WHERE Status__c = 'Success']);
	}
    
    @isTest
	public static void TestOpp() {
		
		// Data setup
		Account a = new Account();
        a.Name = 'Totally a Real Account';
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Opportunity923079';
        o.StageName = 'Introduction';
        o.CloseDate = Date.today();
        o.AccountId = a.Id;
        insert o;
        
        Net_Promoter_Measurement__c npm = new Net_Promoter_Measurement__c();
        npm.Status__c = 'Draft';
        npm.Opportunity__c = o.Id;
        insert npm;
        
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
		
		// Run the code
		Test.startTest();
		(new DelightedScheduledBatch()).execute(null);
		Test.stopTest();
		
		// Verify Results
        System.assertEquals(1, [SELECT COUNT() FROM Net_Promoter_Measurement__c WHERE Status__c = 'Success']);
	}

}
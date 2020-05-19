@isTest
public class DelightedFundedOppBatchTest {

    @isTest
	private static void testName() {
		
        // Data setup
        Account a = new Account();
        a.Name = 'Totally a Real Account';
        insert a;
        
        contact con = new Contact();
        con.FirstName = 'fname';
        con.LastName = 'lname';
        con.Email='lname@test.com';
        con.AccountId = a.Id;
		insert con;
        
        Opportunity o = new Opportunity();
        o.Name = 'Opportunity923079';
        o.Applicant__c = con.Id;
        o.StageName = 'Post-Closing';
        o.CloseDate = Date.today();
        o.AccountId = a.Id;
        o.Wire_to_Agent_Date__c = Date.today().addDays(-7);
        insert o;
        
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        
        // Run the code
        Test.startTest();
			(new DelightedFundedOppBatch()).execute(null);
        Test.stopTest(); 
        
        // Verify Results
		o = [Select Id, Delighted_Post_Closing_Sent__c from Opportunity Where Id = :o.Id];
        System.assertEquals(true, o.Delighted_Post_Closing_Sent__c);
	}
    
}
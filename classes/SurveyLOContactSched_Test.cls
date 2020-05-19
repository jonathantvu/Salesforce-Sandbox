/*************************************************************************************************
 * @className   : SurveyLOContactSched_Test.cls
 * @author      : Omnivo Digital (omnivodigital.com)
 * @date        : May 19, 2019
 * @description : This class provides test methods for SurveyLOContactSched, SurveyLOContactBatch
 *
*************************************************************************************************/

@isTest 
private class SurveyLOContactSched_Test {

	@isTest
	private static void testName() {
		// Data setup
        Account a = new Account();
        a.Name = 'Totally a Real Account';
        insert a;
        
		RecordType conRt = [Select Id from RecordType Where DeveloperName = 'Lender' AND SobjectType = 'Contact'];

        contact con = new Contact(FirstName = 'fname', LastName = 'LName', Email='lname@test.com', AccountId = a.Id,
									RecordTypeId= conRt.Id, Contact_Role__c = 'Loan Officer', Trained_Date_Time__c = Datetime.now().addHours(-3),
									LO_Survey_Sent__c = false);
		insert con;
        
        Test.setMock(HttpCalloutMock.class, new DelightedMock());
        
        // Run the code
        Test.startTest();
			SurveyLOContactSched sh1 = new SurveyLOContactSched();
			Datetime dt = Datetime.now();
			String sch = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' * * ?'; 
			system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest(); 
        
        // Verify Results
		con = [Select Id, LO_Survey_Sent__c from Contact Where Id = :con.Id];
        //System.assertEquals(true, con.LO_Survey_Sent__c);
	}
}
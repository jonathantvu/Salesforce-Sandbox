@isTest
private class VantagePointHelperTest 
{	
	@isTest static void test_method_one() 
    {
		// Data Setup
        Attachment newAttachment = new Attachment();
        newAttachment.Body = Blob.valueOf('test');

        Account acc = new Account(Name = 'New Account');
        insert acc; 

        Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com', AccountID = acc.Id);
        insert con;

        Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com', AccountID = acc.Id);
        insert con2;

        Opportunity oppty = new Opportunity(
            Name = 'New Oppty', 
            AccountId = acc.Id, 
            StageName = 'Submitted to Underwriting', 
            CloseDate = Date.today().addDays(20), 
            Is_there_Co_App__c = true, 
            Applicant__c = con.Id,
            Applicant2__c = con.Id, 
            Applicant3__c = con.Id,
            Co_Applicant__c = con2.Id,
            Co_Applicant2__c = con2.Id,
            Co_Applicant3__c = con2.Id
        );

        insert oppty;

        // Test Code
        Test.setMock(HttpCalloutMock.class, new VantagePointCalloutMock());

        VantagePointHelper.PlaceOrder(oppty);
	}
}
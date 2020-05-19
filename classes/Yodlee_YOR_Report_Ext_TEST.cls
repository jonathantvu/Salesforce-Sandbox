/**********************************************************
 * @className   : Yodlee_YOR_Report_Ext_TEST.cls
 * @date        : May 11, 2018
 * @description : This class provides test methods for Yodlee_YOR_Report_Ext.cls
 *
 *
 **********************************************************/ 

@isTest 
private class Yodlee_YOR_Report_Ext_TEST {

	@isTest
	private static void testName() {
		Account acc = new Account(Name = 'New Account');
		insert acc; 

		Contact con = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = 'fisrtName.lastName@test.com',
		                          AccountID = acc.Id);
		insert con;

		Contact con2 = new Contact(FirstName = 'FirstNam2e', LastName = 'LastNa2me', Email = 'fisrtNa2me.lastName@test.com',
		                          AccountID = acc.Id);
		insert con2;

		Opportunity oppty = new Opportunity(Name = 'New Oppty', AccountId = acc.Id, StageName = 'Submitted to Underwriting', 
									CloseDate = Date.today().addDays(20), Is_there_Co_App__c = true, Applicant__c = con.Id,
									Co_Applicant__c = con2.Id);
		insert oppty;

		Yodlee_Order_Request__c yor = new Yodlee_Order_Request__c();
		yor.Opportunity__c = oppty.Id;
		yor.Name = 'YOR Name';
		yor.Yodlee_Public_Id__c = '6f098ce4-a14f-4604-622e-a0ab76d557dd';
		insert yor;

		System.Test.startTest();

			ApexPages.StandardController sc = new ApexPages.StandardController(yor);
			Yodlee_YOR_Report_Ext ctrl = new Yodlee_YOR_Report_Ext(sc);
			ctrl.init();

		System.Test.stopTest();
	
		List<Attachment> attachments = [Select Id FROM Attachment];
		System.assert(attachments.size() > 0);
	}
}